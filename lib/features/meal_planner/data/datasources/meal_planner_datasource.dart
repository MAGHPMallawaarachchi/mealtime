import '../../domain/models/weekly_meal_plan.dart';
import '../../domain/models/meal_slot.dart';

abstract class MealPlannerDataSource {
  Future<WeeklyMealPlan?> getWeeklyMealPlan(String userId, DateTime weekStartDate);
  Future<void> saveWeeklyMealPlan(WeeklyMealPlan weekPlan);
  Future<void> saveMealSlot(String userId, DateTime date, MealSlot mealSlot);
  Future<void> deleteMealSlot(String userId, DateTime date, String mealSlotId);
  Future<void> updateDailyNotes(String userId, DateTime date, String? notes);
  Future<List<WeeklyMealPlan>> getMealPlansForRange(String userId, DateTime startDate, DateTime endDate);
  Stream<WeeklyMealPlan?> getWeeklyMealPlanStream(String userId, DateTime weekStartDate);
  Future<bool> hasMealPlanForWeek(String userId, DateTime weekStartDate);
  Future<void> deleteWeeklyMealPlan(String userId, DateTime weekStartDate);
}

class MealPlannerDataSourceException implements Exception {
  final String message;

  MealPlannerDataSourceException(this.message);

  @override
  String toString() => 'MealPlannerDataSourceException: $message';
}