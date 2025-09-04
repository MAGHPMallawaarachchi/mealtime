import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum InteractionType {
  view,
  favorite,
  unfavorite,
  addToMealPlan,
  startCooking,
  completeCooking,
  share,
  search,
  categorySelect,
}

class UserInteraction {
  final String id;
  final String userId;
  final String? recipeId;
  final InteractionType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const UserInteraction({
    required this.id,
    required this.userId,
    this.recipeId,
    required this.type,
    required this.timestamp,
    this.metadata = const {},
  });

  UserInteraction copyWith({
    String? id,
    String? userId,
    String? recipeId,
    InteractionType? type,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return UserInteraction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipeId: recipeId ?? this.recipeId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recipeId': recipeId,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory UserInteraction.fromJson(Map<String, dynamic> json) {
    return UserInteraction(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      recipeId: json['recipeId'] as String?,
      type: _parseInteractionType(json['type']),
      timestamp: _parseDateTime(json['timestamp']),
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'recipeId': recipeId,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  factory UserInteraction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserInteraction.fromJson(data);
  }

  static InteractionType _parseInteractionType(dynamic value) {
    if (value == null) return InteractionType.view;
    try {
      return InteractionType.values.firstWhere((e) => e.name == value.toString());
    } catch (e) {
      return InteractionType.view;
    }
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    }
    
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    if (dateValue is DateTime) {
      return dateValue;
    }
    
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInteraction &&
        other.id == id &&
        other.userId == userId &&
        other.recipeId == recipeId &&
        other.type == type &&
        other.timestamp == timestamp &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, recipeId, type, timestamp, Object.hashAll(metadata.entries));
  }

  @override
  String toString() {
    return 'UserInteraction(id: $id, userId: $userId, recipeId: $recipeId, type: $type, timestamp: $timestamp, metadata: $metadata)';
  }
}

class InteractionSummary {
  final String userId;
  final Map<String, int> recipeFavorites;
  final Map<String, int> recipeViews;
  final Map<String, int> categorySelections;
  final List<String> recentSearches;
  final Map<InteractionType, int> interactionCounts;

  const InteractionSummary({
    required this.userId,
    this.recipeFavorites = const {},
    this.recipeViews = const {},
    this.categorySelections = const {},
    this.recentSearches = const [],
    this.interactionCounts = const {},
  });

  factory InteractionSummary.fromInteractions(List<UserInteraction> interactions) {
    if (interactions.isEmpty) {
      return const InteractionSummary(userId: '');
    }

    final userId = interactions.first.userId;
    final recipeFavorites = <String, int>{};
    final recipeViews = <String, int>{};
    final categorySelections = <String, int>{};
    final recentSearches = <String>[];
    final interactionCounts = <InteractionType, int>{};

    for (final interaction in interactions) {
      interactionCounts[interaction.type] = (interactionCounts[interaction.type] ?? 0) + 1;

      switch (interaction.type) {
        case InteractionType.favorite:
          if (interaction.recipeId != null) {
            recipeFavorites[interaction.recipeId!] = (recipeFavorites[interaction.recipeId!] ?? 0) + 1;
          }
          break;
        case InteractionType.view:
          if (interaction.recipeId != null) {
            recipeViews[interaction.recipeId!] = (recipeViews[interaction.recipeId!] ?? 0) + 1;
          }
          break;
        case InteractionType.categorySelect:
          final category = interaction.metadata['category'] as String?;
          if (category != null) {
            categorySelections[category] = (categorySelections[category] ?? 0) + 1;
          }
          break;
        case InteractionType.search:
          final query = interaction.metadata['query'] as String?;
          if (query != null && query.isNotEmpty && !recentSearches.contains(query)) {
            recentSearches.add(query);
          }
          break;
        default:
          break;
      }
    }

    return InteractionSummary(
      userId: userId,
      recipeFavorites: recipeFavorites,
      recipeViews: recipeViews,
      categorySelections: categorySelections,
      recentSearches: recentSearches.take(10).toList(),
      interactionCounts: interactionCounts,
    );
  }

  List<String> get mostViewedRecipes {
    final sorted = recipeViews.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).take(20).toList();
  }

  List<String> get mostFavoritedRecipes {
    final sorted = recipeFavorites.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).take(20).toList();
  }

  List<String> get preferredCategories {
    final sorted = categorySelections.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).take(5).toList();
  }
}