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
      final weekPlan = await _dataSource.getWeeklyMealPlan(
        userId,
        weekStartDate,
      );

      if (weekPlan != null) {
      } else {
      }

      return weekPlan;
    } catch (e) {
      throw MealPlannerRepositoryException(
        'Failed to fetch weekly meal plan: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveWeeklyMealPlan(WeeklyMealPlan weekPlan) async {
    try {
      await _dataSource.saveWeeklyMealPlan(weekPlan);
    } catch (e) {
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
      await _dataSource.saveMealSlot(userId, date, mealSlot);
    } catch (e) {
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
      await _dataSource.deleteMealSlot(userId, date, mealSlotId);
    } catch (e) {
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
      await _dataSource.updateDailyNotes(userId, date, notes);
    } catch (e) {
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
      final plans = await _dataSource.getMealPlansForRange(
        userId,
        startDate,
        endDate,
      );
      return plans;
    } catch (e) {
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
      return _dataSource
          .getWeeklyMealPlanStream(userId, weekStartDate)
          .handleError((error) {
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
      return exists;
    } catch (e) {
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
      await _dataSource.deleteWeeklyMealPlan(userId, weekStartDate);
    } catch (e) {
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
