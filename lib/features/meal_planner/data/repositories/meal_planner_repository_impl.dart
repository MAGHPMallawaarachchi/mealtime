import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/weekly_meal_plan.dart';
import '../../domain/models/meal_slot.dart';
import '../../domain/repositories/meal_planner_repository.dart';
import '../datasources/meal_planner_datasource.dart';
import '../datasources/meal_planner_firebase_datasource.dart';

class MealPlannerRepositoryImpl implements MealPlannerRepository {
  final MealPlannerDataSource _dataSource;

  MealPlannerRepositoryImpl({MealPlannerDataSource? dataSource})
    : _dataSource = dataSource ?? MealPlannerFirebaseDataSource();

  @override
  Future<WeeklyMealPlan?> getWeeklyMealPlan(
    String userId,
    DateTime weekStartDate,
  ) async {
    try {
      debugPrint(
        'MealPlannerRepository: Loading meal plan for user $userId, week ${weekStartDate.toIso8601String()}',
      );
      final weekPlan = await _dataSource.getWeeklyMealPlan(
        userId,
        weekStartDate,
      );

      if (weekPlan != null) {
        debugPrint(
          'MealPlannerRepository: Found existing meal plan with ${weekPlan.totalPlannedMeals} planned meals',
        );
      } else {
        debugPrint('MealPlannerRepository: No existing meal plan found');
      }

      return weekPlan;
    } catch (e) {
      debugPrint('MealPlannerRepository: Failed to get weekly meal plan: $e');
      throw MealPlannerRepositoryException(
        'Failed to fetch weekly meal plan: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveWeeklyMealPlan(WeeklyMealPlan weekPlan) async {
    try {
      debugPrint(
        'MealPlannerRepository: Saving weekly meal plan ${weekPlan.id} with ${weekPlan.totalPlannedMeals} meals',
      );
      await _dataSource.saveWeeklyMealPlan(weekPlan);
      debugPrint('MealPlannerRepository: Successfully saved weekly meal plan');
    } catch (e) {
      debugPrint('MealPlannerRepository: Failed to save weekly meal plan: $e');
      throw MealPlannerRepositoryException(
        'Failed to save weekly meal plan: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveMealSlot(
    String userId,
    DateTime date,
    MealSlot mealSlot,
  ) async {
    try {
      debugPrint(
        'MealPlannerRepository: Saving meal slot ${mealSlot.id} for ${date.toIso8601String()}',
      );
      await _dataSource.saveMealSlot(userId, date, mealSlot);
      debugPrint('MealPlannerRepository: Successfully saved meal slot');
    } catch (e) {
      debugPrint('MealPlannerRepository: Failed to save meal slot: $e');
      throw MealPlannerRepositoryException(
        'Failed to save meal slot: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteMealSlot(
    String userId,
    DateTime date,
    String mealSlotId,
  ) async {
    try {
      debugPrint(
        'MealPlannerRepository: Deleting meal slot $mealSlotId from ${date.toIso8601String()}',
      );
      await _dataSource.deleteMealSlot(userId, date, mealSlotId);
      debugPrint('MealPlannerRepository: Successfully deleted meal slot');
    } catch (e) {
      debugPrint('MealPlannerRepository: Failed to delete meal slot: $e');
      throw MealPlannerRepositoryException(
        'Failed to delete meal slot: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateDailyNotes(
    String userId,
    DateTime date,
    String? notes,
  ) async {
    try {
      debugPrint(
        'MealPlannerRepository: Updating daily notes for ${date.toIso8601String()}',
      );
      await _dataSource.updateDailyNotes(userId, date, notes);
      debugPrint('MealPlannerRepository: Successfully updated daily notes');
    } catch (e) {
      debugPrint('MealPlannerRepository: Failed to update daily notes: $e');
      throw MealPlannerRepositoryException(
        'Failed to update daily notes: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<WeeklyMealPlan>> getMealPlansForRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      debugPrint(
        'MealPlannerRepository: Loading meal plans for range ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
      );
      final plans = await _dataSource.getMealPlansForRange(
        userId,
        startDate,
        endDate,
      );
      debugPrint(
        'MealPlannerRepository: Found ${plans.length} meal plans in range',
      );
      return plans;
    } catch (e) {
      debugPrint(
        'MealPlannerRepository: Failed to get meal plans for range: $e',
      );
      throw MealPlannerRepositoryException(
        'Failed to get meal plans for range: ${e.toString()}',
      );
    }
  }

  @override
  Stream<WeeklyMealPlan?> getWeeklyMealPlanStream(
    String userId,
    DateTime weekStartDate,
  ) {
    try {
      debugPrint(
        'MealPlannerRepository: Creating stream for meal plan, user $userId, week ${weekStartDate.toIso8601String()}',
      );
      return _dataSource
          .getWeeklyMealPlanStream(userId, weekStartDate)
          .handleError((error) {
            debugPrint('MealPlannerRepository: Stream error: $error');
            throw MealPlannerRepositoryException(
              'Failed to stream weekly meal plan: ${error.toString()}',
            );
          });
    } catch (e) {
      throw MealPlannerRepositoryException(
        'Failed to create weekly meal plan stream: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasMealPlanForWeek(String userId, DateTime weekStartDate) async {
    try {
      final exists = await _dataSource.hasMealPlanForWeek(
        userId,
        weekStartDate,
      );
      debugPrint(
        'MealPlannerRepository: Meal plan exists for week ${weekStartDate.toIso8601String()}: $exists',
      );
      return exists;
    } catch (e) {
      debugPrint(
        'MealPlannerRepository: Error checking if meal plan exists: $e',
      );
      // Return false if there's an error checking
      return false;
    }
  }

  @override
  Future<void> deleteWeeklyMealPlan(
    String userId,
    DateTime weekStartDate,
  ) async {
    try {
      debugPrint(
        'MealPlannerRepository: Deleting weekly meal plan for week ${weekStartDate.toIso8601String()}',
      );
      await _dataSource.deleteWeeklyMealPlan(userId, weekStartDate);
      debugPrint(
        'MealPlannerRepository: Successfully deleted weekly meal plan',
      );
    } catch (e) {
      debugPrint(
        'MealPlannerRepository: Failed to delete weekly meal plan: $e',
      );
      throw MealPlannerRepositoryException(
        'Failed to delete weekly meal plan: ${e.toString()}',
      );
    }
  }
}

class MealPlannerRepositoryException implements Exception {
  final String message;

  MealPlannerRepositoryException(this.message);

  @override
  String toString() => 'MealPlannerRepositoryException: $message';
}
