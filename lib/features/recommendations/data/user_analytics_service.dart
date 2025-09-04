import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/models/user_interaction.dart';

class UserAnalyticsService {
  static UserAnalyticsService? _instance;
  static Database? _database;

  UserAnalyticsService._();

  static UserAnalyticsService get instance {
    _instance ??= UserAnalyticsService._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'user_analytics.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE interactions (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            recipeId TEXT,
            type TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            metadata TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_interactions_user_id ON interactions(userId)
        ''');

        await db.execute('''
          CREATE INDEX idx_interactions_recipe_id ON interactions(recipeId)
        ''');

        await db.execute('''
          CREATE INDEX idx_interactions_type ON interactions(type)
        ''');

        await db.execute('''
          CREATE INDEX idx_interactions_timestamp ON interactions(timestamp)
        ''');
      },
    );
  }

  Future<void> recordInteraction(UserInteraction interaction) async {
    try {
      final db = await database;
      await db.insert(
        'interactions',
        {
          'id': interaction.id,
          'userId': interaction.userId,
          'recipeId': interaction.recipeId,
          'type': interaction.type.name,
          'timestamp': interaction.timestamp.millisecondsSinceEpoch,
          'metadata': jsonEncode(interaction.metadata),
          'synced': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error recording interaction: $e');
    }
  }

  Future<List<UserInteraction>> getUserInteractions(
    String userId, {
    DateTime? since,
    int? limit,
    List<InteractionType>? types,
  }) async {
    try {
      final db = await database;
      
      String whereClause = 'userId = ?';
      List<dynamic> whereArgs = [userId];

      if (since != null) {
        whereClause += ' AND timestamp >= ?';
        whereArgs.add(since.millisecondsSinceEpoch);
      }

      if (types != null && types.isNotEmpty) {
        final typePlaceholders = types.map((e) => '?').join(',');
        whereClause += ' AND type IN ($typePlaceholders)';
        whereArgs.addAll(types.map((t) => t.name));
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'interactions',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return maps.map((map) => _mapToUserInteraction(map)).toList();
    } catch (e) {
      debugPrint('Error getting user interactions: $e');
      return [];
    }
  }

  Future<InteractionSummary> getUserInteractionSummary(
    String userId, {
    DateTime? since,
  }) async {
    final interactions = await getUserInteractions(
      userId,
      since: since ?? DateTime.now().subtract(const Duration(days: 90)),
    );
    
    return InteractionSummary.fromInteractions(interactions);
  }

  Future<Map<String, int>> getRecipeInteractionCounts(
    List<String> recipeIds, {
    List<InteractionType>? types,
  }) async {
    try {
      final db = await database;
      
      if (recipeIds.isEmpty) return {};

      final recipePlaceholders = recipeIds.map((e) => '?').join(',');
      String whereClause = 'recipeId IN ($recipePlaceholders)';
      List<dynamic> whereArgs = recipeIds;

      if (types != null && types.isNotEmpty) {
        final typePlaceholders = types.map((e) => '?').join(',');
        whereClause += ' AND type IN ($typePlaceholders)';
        whereArgs.addAll(types.map((t) => t.name));
      }

      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT recipeId, COUNT(*) as count
        FROM interactions
        WHERE $whereClause AND recipeId IS NOT NULL
        GROUP BY recipeId
      ''', whereArgs);

      final counts = <String, int>{};
      for (final row in result) {
        counts[row['recipeId'] as String] = row['count'] as int;
      }

      return counts;
    } catch (e) {
      debugPrint('Error getting recipe interaction counts: $e');
      return {};
    }
  }

  Future<List<String>> getTopRecipesByInteraction(
    InteractionType type, {
    int limit = 20,
    DateTime? since,
  }) async {
    try {
      final db = await database;
      
      String whereClause = 'type = ? AND recipeId IS NOT NULL';
      List<dynamic> whereArgs = [type.name];

      if (since != null) {
        whereClause += ' AND timestamp >= ?';
        whereArgs.add(since.millisecondsSinceEpoch);
      }

      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT recipeId, COUNT(*) as count
        FROM interactions
        WHERE $whereClause
        GROUP BY recipeId
        ORDER BY count DESC
        LIMIT ?
      ''', [...whereArgs, limit]);

      return result.map((row) => row['recipeId'] as String).toList();
    } catch (e) {
      debugPrint('Error getting top recipes: $e');
      return [];
    }
  }

  Future<void> markInteractionsAsSynced(List<String> interactionIds) async {
    try {
      final db = await database;
      final placeholders = interactionIds.map((e) => '?').join(',');
      
      await db.rawUpdate('''
        UPDATE interactions 
        SET synced = 1 
        WHERE id IN ($placeholders)
      ''', interactionIds);
    } catch (e) {
      debugPrint('Error marking interactions as synced: $e');
    }
  }

  Future<List<UserInteraction>> getUnsyncedInteractions({int? limit}) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'interactions',
        where: 'synced = 0',
        orderBy: 'timestamp ASC',
        limit: limit,
      );

      return maps.map((map) => _mapToUserInteraction(map)).toList();
    } catch (e) {
      debugPrint('Error getting unsynced interactions: $e');
      return [];
    }
  }

  Future<void> clearUserData(String userId) async {
    try {
      final db = await database;
      await db.delete('interactions', where: 'userId = ?', whereArgs: [userId]);
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  Future<void> clearOldInteractions({Duration retention = const Duration(days: 365)}) async {
    try {
      final db = await database;
      final cutoff = DateTime.now().subtract(retention);
      
      await db.delete(
        'interactions',
        where: 'timestamp < ? AND synced = 1',
        whereArgs: [cutoff.millisecondsSinceEpoch],
      );
    } catch (e) {
      debugPrint('Error clearing old interactions: $e');
    }
  }

  UserInteraction _mapToUserInteraction(Map<String, dynamic> map) {
    Map<String, dynamic> metadata = {};
    try {
      metadata = jsonDecode(map['metadata'] as String? ?? '{}');
    } catch (e) {
      metadata = {};
    }

    return UserInteraction(
      id: map['id'] as String,
      userId: map['userId'] as String,
      recipeId: map['recipeId'] as String?,
      type: InteractionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => InteractionType.view,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      metadata: metadata,
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}