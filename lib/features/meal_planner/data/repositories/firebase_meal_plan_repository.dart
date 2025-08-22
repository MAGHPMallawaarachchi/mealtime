import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/weekly_meal_plan.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../../utils/meal_plan_test_utils.dart';

class FirebaseMealPlanRepository implements MealPlanRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  FirebaseMealPlanRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  @override
  Future<WeeklyMealPlan?> getCurrentWeekPlan() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekId = _generateWeekId(monday);
    return getWeekPlan(weekId);
  }

  @override
  Future<WeeklyMealPlan?> getWeekPlan(String weekId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return await getCachedWeekPlan(weekId);
      }

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .doc(weekId)
          .get();

      if (doc.exists && doc.data() != null) {
        final weekPlan = WeeklyMealPlan.fromJson(doc.data()!);
        // Cache the fetched data
        await cacheWeekPlan(weekPlan);
        return weekPlan;
      }

      // Fallback to cached data if no server data
      final cachedPlan = await getCachedWeekPlan(weekId);
      if (cachedPlan != null) {
        return cachedPlan;
      }
      
      // If no cached data and user is authenticated, create and save a sample plan
      if (userId != null) {
        final samplePlan = MealPlanTestUtils.createSampleWeekPlan(userId: userId);
        if (samplePlan.id == weekId) {
          await cacheWeekPlan(samplePlan);
          return samplePlan;
        }
      }
      
      return null;
    } catch (e) {
      // Silent failure - return cached data or sample data
      final cachedPlan = await getCachedWeekPlan(weekId);
      if (cachedPlan != null) {
        return cachedPlan;
      }
      
      // Provide sample data for testing
      final samplePlan = MealPlanTestUtils.createSampleWeekPlan(userId: _currentUserId);
      if (samplePlan.id == weekId) {
        await cacheWeekPlan(samplePlan);
        return samplePlan;
      }
      
      return null;
    }
  }

  @override
  Future<void> saveWeekPlan(WeeklyMealPlan weekPlan) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        // Cache locally if user is not authenticated
        await cacheWeekPlan(weekPlan);
        return;
      }

      // Ensure the userId is set on the meal plan
      final planWithUserId = weekPlan.copyWith(userId: userId);
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .doc(weekPlan.id)
          .set(planWithUserId.toJson());

      // Also cache locally
      await cacheWeekPlan(planWithUserId);
    } catch (e) {
      // If save fails, at least cache locally
      await cacheWeekPlan(weekPlan);
      rethrow;
    }
  }

  @override
  Future<void> deleteWeekPlan(String weekId) async {
    try {
      final userId = _currentUserId;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('meal_plans')
            .doc(weekId)
            .delete();
      }

      // Also remove from cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('meal_plan_$weekId');
    } catch (e) {
      // Silent failure for delete operations
    }
  }

  @override
  Future<WeeklyMealPlan?> getCachedWeekPlan(String weekId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('meal_plan_$weekId');
      
      if (cachedData != null) {
        final jsonData = json.decode(cachedData) as Map<String, dynamic>;
        return WeeklyMealPlan.fromJson(jsonData);
      }
    } catch (e) {
      // Silent failure
    }
    return null;
  }

  @override
  Future<void> cacheWeekPlan(WeeklyMealPlan weekPlan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(weekPlan.toJson());
      await prefs.setString('meal_plan_${weekPlan.id}', jsonData);
    } catch (e) {
      // Silent failure for caching
    }
  }

  @override
  Stream<WeeklyMealPlan?> watchCurrentWeekPlan() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekId = _generateWeekId(monday);
    return watchWeekPlan(weekId);
  }

  @override
  Stream<WeeklyMealPlan?> watchWeekPlan(String weekId) {
    final userId = _currentUserId;
    if (userId == null) {
      // Return cached or sample data as a stream when not authenticated
      return Stream.fromFuture(_getFallbackWeekPlan(weekId, userId));
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('meal_plans')
        .doc(weekId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.exists && snapshot.data() != null) {
            final weekPlan = WeeklyMealPlan.fromJson(snapshot.data()!);
            // Cache in background
            await cacheWeekPlan(weekPlan);
            return weekPlan;
          }
          // Return fallback data if no Firebase data exists
          return await _getFallbackWeekPlan(weekId, userId);
        })
        .handleError((error) async {
          // Silent failure - return fallback data
          return await _getFallbackWeekPlan(weekId, userId);
        });
  }
  
  /// Get fallback data (cached or sample) for a week plan
  Future<WeeklyMealPlan?> _getFallbackWeekPlan(String weekId, String? userId) async {
    // Try cached data first
    final cachedPlan = await getCachedWeekPlan(weekId);
    if (cachedPlan != null) {
      return cachedPlan;
    }
    
    // Provide sample data for testing
    final samplePlan = MealPlanTestUtils.createSampleWeekPlan(userId: userId);
    if (samplePlan.id == weekId) {
      await cacheWeekPlan(samplePlan);
      return samplePlan;
    }
    
    return null;
  }

  /// Generate week ID in YYYYWW format
  String _generateWeekId(DateTime weekStart) {
    final year = weekStart.year;
    final dayOfYear = weekStart.difference(DateTime(year, 1, 1)).inDays + 1;
    final weekNumber = ((dayOfYear - weekStart.weekday + 10) / 7).floor();
    return '$year${weekNumber.toString().padLeft(2, '0')}';
  }
}