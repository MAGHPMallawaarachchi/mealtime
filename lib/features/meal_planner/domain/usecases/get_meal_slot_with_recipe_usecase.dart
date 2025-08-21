import '../models/meal_slot.dart';
import '../repositories/meal_planner_repository.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../../recipes/domain/repositories/recipes_repository.dart';

class MealSlotWithRecipe {
  final MealSlot mealSlot;
  final Recipe? recipe;

  const MealSlotWithRecipe({
    required this.mealSlot,
    this.recipe,
  });
}

class GetMealSlotWithRecipeUseCase {
  final MealPlannerRepository _mealPlannerRepository;
  final RecipesRepository _recipesRepository;

  GetMealSlotWithRecipeUseCase(
    this._mealPlannerRepository,
    this._recipesRepository,
  );

  Future<MealSlotWithRecipe?> execute(String userId, DateTime date, String mealSlotId) async {
    try {
      final weekPlan = await _mealPlannerRepository.getWeeklyMealPlan(userId, date);
      if (weekPlan == null) return null;

      final dayPlan = weekPlan.getDayPlan(date);
      if (dayPlan == null) return null;

      final mealSlot = dayPlan.meals.where((m) => m.id == mealSlotId).firstOrNull;
      if (mealSlot == null) return null;

      Recipe? recipe;
      if (mealSlot.recipeId != null) {
        recipe = await _recipesRepository.getRecipe(mealSlot.recipeId!);
      }

      return MealSlotWithRecipe(
        mealSlot: mealSlot,
        recipe: recipe,
      );
    } catch (e) {
      throw GetMealSlotWithRecipeException('Failed to get meal slot with recipe: ${e.toString()}');
    }
  }
}

class GetMealSlotWithRecipeException implements Exception {
  final String message;

  GetMealSlotWithRecipeException(this.message);

  @override
  String toString() => 'GetMealSlotWithRecipeException: $message';
}

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}