import '../models/weekly_meal_plan.dart';
import '../models/meal_slot.dart';

abstract class MealPlannerRepository {
  /// Get weekly meal plan for a specific week and user
  Future<WeeklyMealPlan?> getWeeklyMealPlan(
    String userId,
    DateTime weekStartDate,
  );

  /// Save a complete weekly meal plan
  Future<void> saveWeeklyMealPlan(WeeklyMealPlan weekPlan);

  /// Update a specific meal slot in a day
  Future<void> saveMealSlot(String userId, DateTime date, MealSlot mealSlot);

  /// Delete a meal slot from a day
  Future<void> deleteMealSlot(String userId, DateTime date, String mealSlotId);

  /// Update daily meal plan notes
  Future<void> updateDailyNotes(String userId, DateTime date, String? notes);

  /// Get meal plans for a date range (useful for viewing multiple weeks)
  Future<List<WeeklyMealPlan>> getMealPlansForRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Stream real-time updates for a specific week
  Stream<WeeklyMealPlan?> getWeeklyMealPlanStream(
    String userId,
    DateTime weekStartDate,
  );

  /// Check if a meal plan exists for a specific week
  Future<bool> hasMealPlanForWeek(String userId, DateTime weekStartDate);

  /// Delete entire weekly meal plan
  Future<void> deleteWeeklyMealPlan(String userId, DateTime weekStartDate);
}
