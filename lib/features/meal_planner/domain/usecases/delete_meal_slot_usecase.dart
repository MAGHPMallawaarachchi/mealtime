import '../repositories/meal_planner_repository.dart';

class DeleteMealSlotUseCase {
  final MealPlannerRepository _repository;

  DeleteMealSlotUseCase(this._repository);

  Future<void> execute(String userId, DateTime date, String mealSlotId) {
    return _repository.deleteMealSlot(userId, date, mealSlotId);
  }
}