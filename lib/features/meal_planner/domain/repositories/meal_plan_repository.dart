import '../models/weekly_meal_plan.dart';

abstract class MealPlanRepository {
  /// Get the current week's meal plan for the authenticated user
  Future<WeeklyMealPlan?> getCurrentWeekPlan();
  
  /// Get a specific week's meal plan for the authenticated user
  Future<WeeklyMealPlan?> getWeekPlan(String weekId);
  
  /// Save/update a weekly meal plan for the authenticated user
  Future<void> saveWeekPlan(WeeklyMealPlan weekPlan);
  
  /// Delete a weekly meal plan for the authenticated user
  Future<void> deleteWeekPlan(String weekId);
  
  /// Get cached meal plan (for offline support)
  Future<WeeklyMealPlan?> getCachedWeekPlan(String weekId);
  
  /// Cache a meal plan locally
  Future<void> cacheWeekPlan(WeeklyMealPlan weekPlan);
  
  /// Listen to real-time updates for current week's meal plan
  Stream<WeeklyMealPlan?> watchCurrentWeekPlan();
  
  /// Listen to real-time updates for a specific week's meal plan
  Stream<WeeklyMealPlan?> watchWeekPlan(String weekId);
}