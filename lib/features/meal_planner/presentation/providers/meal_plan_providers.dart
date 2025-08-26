import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_meal_plan_repository.dart';
import '../../domain/models/weekly_meal_plan.dart';
import '../../domain/repositories/meal_plan_repository.dart';

// Repository provider
final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return FirebaseMealPlanRepository();
});

// Current week meal plan provider with caching
final currentWeekMealPlanProvider = StreamProvider<WeeklyMealPlan?>((ref) {
  final repository = ref.watch(mealPlanRepositoryProvider);
  return repository.watchCurrentWeekPlan();
});

// Family provider for specific week meal plans
final weekMealPlanProvider = StreamProvider.family<WeeklyMealPlan?, String>((ref, weekId) {
  final repository = ref.watch(mealPlanRepositoryProvider);
  return repository.watchWeekPlan(weekId);
});

// Provider for today's meal plan data (derived from current week)
final todaysMealPlanProvider = Provider<AsyncValue<List<dynamic>>>((ref) {
  final currentWeekAsync = ref.watch(currentWeekMealPlanProvider);
  
  return currentWeekAsync.when(
    data: (weekPlan) {
      if (weekPlan == null) {
        return const AsyncValue.data([]);
      }
      
      final todaysPlan = weekPlan.todaysPlan;
      if (todaysPlan == null) {
        return const AsyncValue.data([]);
      }
      
      return AsyncValue.data(todaysPlan.scheduledMeals);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) {
      // Silent failure - return empty data instead of error
      return const AsyncValue.data([]);
    },
  );
});

// Actions for meal plan operations
class MealPlanActions {
  final MealPlanRepository _repository;
  
  MealPlanActions(this._repository);
  
  Future<void> saveWeekPlan(WeeklyMealPlan weekPlan) async {
    await _repository.saveWeekPlan(weekPlan);
  }
  
  Future<void> deleteWeekPlan(String weekId) async {
    await _repository.deleteWeekPlan(weekId);
  }
  
  Future<WeeklyMealPlan?> getCachedWeekPlan(String weekId) async {
    return await _repository.getCachedWeekPlan(weekId);
  }
}

// Actions provider
final mealPlanActionsProvider = Provider<MealPlanActions>((ref) {
  final repository = ref.watch(mealPlanRepositoryProvider);
  return MealPlanActions(repository);
});