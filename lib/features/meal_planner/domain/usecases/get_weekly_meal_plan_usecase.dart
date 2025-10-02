import '../models/weekly_meal_plan.dart';
import '../repositories/meal_planner_repository.dart';

class GetWeeklyMealPlanUseCase {
  final MealPlannerRepository _repository;

  GetWeeklyMealPlanUseCase(this._repository);

  Future<WeeklyMealPlan?> execute(String userId, DateTime weekStartDate) {
    return _repository.getWeeklyMealPlan(userId, weekStartDate);
  }
}