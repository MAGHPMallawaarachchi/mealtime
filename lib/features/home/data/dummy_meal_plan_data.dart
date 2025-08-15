import '../domain/models/meal_plan_item.dart';
import '../../recipes/domain/models/recipe.dart';

class DummyMealPlanData {
  static List<MealPlanItem> getTodaysMealPlan() {
    return [];
  }

  static List<Recipe> getRecipes() {
    return [];
  }

  static Recipe? getRecipeById(String id) {
    try {
      return getRecipes().firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }
}
