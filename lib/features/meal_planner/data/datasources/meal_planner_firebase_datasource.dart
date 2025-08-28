import 'package:flutter/foundation.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/models/weekly_meal_plan.dart';
import '../../domain/models/daily_meal_plan.dart';
import '../../domain/models/meal_slot.dart';
import 'meal_planner_datasource.dart';

class MealPlannerFirebaseDataSource implements MealPlannerDataSource {
  static const String _usersCollection = 'users';
  static const String _mealPlansSubcollection = 'meal_plans';
  
  final FirestoreService _firestoreService;

  MealPlannerFirebaseDataSource({
    FirestoreService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<WeeklyMealPlan?> getWeeklyMealPlan(String userId, DateTime weekStartDate) async {
    try {
      final weekId = _generateWeekId(weekStartDate);
      final docPath = _buildDocumentPath(userId, weekId);
      
      final data = await _firestoreService.getDocument(_usersCollection, docPath);
      
      if (data == null) {
        return null;
      }

      return WeeklyMealPlan.fromJson(data);
    } catch (e) {
      throw MealPlannerDataSourceException(
        'Failed to fetch weekly meal plan: ${e.toString()}',
      );
    }
  }

  @override
  Stream<WeeklyMealPlan?> getWeeklyMealPlanStream(String userId, DateTime weekStartDate) {
    try {
      final weekId = _generateWeekId(weekStartDate);
      final docPath = _buildDocumentPath(userId, weekId);
      
      return _firestoreService.getDocumentStream(_usersCollection, docPath)
          .map((data) => data != null ? WeeklyMealPlan.fromJson(data) : null)
          .handleError((error) {
        throw MealPlannerDataSourceException(
          'Failed to stream weekly meal plan: ${error.toString()}',
        );
      });
    } catch (e) {
      throw MealPlannerDataSourceException(
        'Failed to create weekly meal plan stream: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveWeeklyMealPlan(WeeklyMealPlan weekPlan) async {
    try {
      if (weekPlan.userId == null) {
        throw MealPlannerDataSourceException('WeeklyMealPlan must have a userId');
      }

      final weekId = weekPlan.weekId;
      final docPath = _buildDocumentPath(weekPlan.userId!, weekId);
      
      await _firestoreService.setDocument(_usersCollection, docPath, weekPlan.toJson());
    } catch (e) {
      throw MealPlannerDataSourceException(
        'Failed to save weekly meal plan: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveMealSlot(String userId, DateTime date, MealSlot mealSlot) async {
    try {
      final weekStart = _getWeekStart(date);
      
      // First, get the current week plan
      var weekPlan = await getWeeklyMealPlan(userId, weekStart);
      
      // If no week plan exists, create a new one
      if (weekPlan == null) {
        weekPlan = WeeklyMealPlan.createForWeek(weekStart, userId: userId);
      }
      
      // Find the day plan and update it
      var dayPlan = weekPlan.getDayPlan(date);
      if (dayPlan == null) {
        dayPlan = DailyMealPlan.createEmpty(date);
      }
      
      // Check if this is a new meal slot or updating an existing one
      final existingMeal = dayPlan.meals.where((meal) => meal.id == mealSlot.id).firstOrNull;
      
      DailyMealPlan updatedDayPlan;
      if (existingMeal != null) {
        // Update existing meal slot
        updatedDayPlan = dayPlan.updateMealSlot(mealSlot);
      } else {
        // Add new meal slot
        updatedDayPlan = dayPlan.addMealSlot(mealSlot);
      }
      
      final updatedWeekPlan = weekPlan.updateDayPlan(updatedDayPlan);
      
      await saveWeeklyMealPlan(updatedWeekPlan);
    } catch (e) {
      throw MealPlannerDataSourceException(
        'Failed to save meal slot: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteMealSlot(String userId, DateTime date, String mealSlotId) async {
    try {
      final weekStart = _getWeekStart(date);
      final weekPlan = await getWeeklyMealPlan(userId, weekStart);
      
      if (weekPlan == null) {
        return; // Nothing to delete
      }
      
      final dayPlan = weekPlan.getDayPlan(date);
      if (dayPlan == null) {
        return; // Nothing to delete
      }
      
      final updatedDayPlan = dayPlan.removeMealSlot(mealSlotId);
      final updatedWeekPlan = weekPlan.updateDayPlan(updatedDayPlan);
      
      await saveWeeklyMealPlan(updatedWeekPlan);
    } catch (e) {
      throw MealPlannerDataSourceException(
        'Failed to delete meal slot: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateDailyNotes(String userId, DateTime date, String? notes) async {
    try {
      final weekStart = _getWeekStart(date);
      var weekPlan = await getWeeklyMealPlan(userId, weekStart);
      
      if (weekPlan == null) {
        weekPlan = WeeklyMealPlan.createForWeek(weekStart, userId: userId);
      }
      
      var dayPlan = weekPlan.getDayPlan(date);
      if (dayPlan == null) {
        dayPlan = DailyMealPlan.createEmpty(date);
      }
      
      final updatedDayPlan = dayPlan.copyWith(notes: notes);
      final updatedWeekPlan = weekPlan.updateDayPlan(updatedDayPlan);
      
      await saveWeeklyMealPlan(updatedWeekPlan);
    } catch (e) {
      throw MealPlannerDataSourceException(
        'Failed to update daily notes: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<WeeklyMealPlan>> getMealPlansForRange(String userId, DateTime startDate, DateTime endDate) async {
    try {
      final plans = <WeeklyMealPlan>[];
      
      // Get all weeks between start and end date
      var currentWeekStart = _getWeekStart(startDate);
      final endWeekStart = _getWeekStart(endDate);
      
      while (currentWeekStart.isBefore(endWeekStart) || currentWeekStart.isAtSameMomentAs(endWeekStart)) {
        final weekPlan = await getWeeklyMealPlan(userId, currentWeekStart);
        if (weekPlan != null) {
          plans.add(weekPlan);
        }
        currentWeekStart = currentWeekStart.add(const Duration(days: 7));
      }
      
      return plans;
    } catch (e) {
      throw MealPlannerDataSourceException(
        'Failed to get meal plans for range: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasMealPlanForWeek(String userId, DateTime weekStartDate) async {
    try {
      final weekPlan = await getWeeklyMealPlan(userId, weekStartDate);
      return weekPlan != null;
    } catch (e) {
      // If there's an error fetching, assume it doesn't exist
      return false;
    }
  }

  @override
  Future<void> deleteWeeklyMealPlan(String userId, DateTime weekStartDate) async {
    try {
      final weekId = _generateWeekId(weekStartDate);
      final docPath = _buildDocumentPath(userId, weekId);
      
      await _firestoreService.deleteDocument(_usersCollection, docPath);
    } catch (e) {
      throw MealPlannerDataSourceException(
        'Failed to delete weekly meal plan: ${e.toString()}',
      );
    }
  }

  /// Helper method to build the document path for meal plans
  String _buildDocumentPath(String userId, String weekId) {
    return '$userId/$_mealPlansSubcollection/$weekId';
  }

  /// Helper method to get the start of the week (Monday) for a given date
  DateTime _getWeekStart(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  /// Generate week ID in YYYYWW format
  String _generateWeekId(DateTime weekStart) {
    final year = weekStart.year;
    final dayOfYear = weekStart.difference(DateTime(year, 1, 1)).inDays + 1;
    final weekNumber = ((dayOfYear - weekStart.weekday + 10) / 7).floor();
    return '$year${weekNumber.toString().padLeft(2, '0')}';
  }
}

// Extension to help with null safety
extension _MealSlotFirstWhereOrNull on Iterable<MealSlot> {
  MealSlot? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}