import 'package:mealtime/features/recipes/domain/models/recipe.dart';

class DummyExploreData {
  static List<Recipe> getFeaturedRecipes() {
    return [];
  }

  static List<Recipe> getAllRecipes() {
    return [];
  }

  static List<Recipe> getRecipesByCategory(String category) {
    final allRecipes = getAllRecipes();

    switch (category.toLowerCase()) {
      case 'sri lankan':
        return allRecipes
            .where(
              (recipe) =>
                  recipe.id.startsWith('sri_') || recipe.id.startsWith('feat_'),
            )
            .toList();
      case 'leftover magic':
        return allRecipes
            .where((recipe) => recipe.id.startsWith('left_'))
            .toList();
      case 'quick meals':
        return allRecipes
            .where((recipe) => recipe.id.startsWith('quick_'))
            .toList();
      case 'vegetarian':
        return allRecipes
            .where((recipe) => recipe.id.startsWith('veg_'))
            .toList();
      case 'breakfast':
        return allRecipes
            .where(
              (recipe) =>
                  recipe.title.toLowerCase().contains('hopper') ||
                  recipe.title.toLowerCase().contains('pancake') ||
                  recipe.title.toLowerCase().contains('tea'),
            )
            .toList();
      case 'lunch':
        return allRecipes
            .where(
              (recipe) =>
                  recipe.title.toLowerCase().contains('rice') ||
                  recipe.title.toLowerCase().contains('curry') ||
                  recipe.title.toLowerCase().contains('kottu'),
            )
            .toList();
      case 'dinner':
        return allRecipes
            .where(
              (recipe) =>
                  recipe.title.toLowerCase().contains('fish') ||
                  recipe.title.toLowerCase().contains('chicken') ||
                  recipe.title.toLowerCase().contains('curry'),
            )
            .toList();
      case 'desserts':
        return allRecipes
            .where(
              (recipe) =>
                  recipe.title.toLowerCase().contains('pudding') ||
                  recipe.title.toLowerCase().contains('pancake'),
            )
            .toList();
      case 'snacks':
        return allRecipes
            .where(
              (recipe) =>
                  recipe.title.toLowerCase().contains('fritter') ||
                  recipe.title.toLowerCase().contains('vadai') ||
                  recipe.title.toLowerCase().contains('sambol'),
            )
            .toList();
      case 'beverages':
        return allRecipes
            .where((recipe) => recipe.title.toLowerCase().contains('tea'))
            .toList();
      default:
        return allRecipes;
    }
  }

}
