import '../models/meal_slot.dart';
import '../repositories/meal_planner_repository.dart';

class SaveMealSlotUseCase {
  final MealPlannerRepository _repository;

  SaveMealSlotUseCase(this._repository);

  Future<void> execute(String userId, DateTime date, MealSlot mealSlot) {
    return _repository.saveMealSlot(userId, date, mealSlot);
  }
}