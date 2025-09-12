import '../../../../core/models/user_model.dart';
import '../models/recipe.dart';

class RecipesPagination {
  final List<Recipe> recipes;
  final bool hasMore;
  final int totalCount;

  const RecipesPagination({
    required this.recipes,
    required this.hasMore,
    required this.totalCount,
  });
}

abstract class RecipesRepository {
  Future<List<Recipe>> getRecipes({
    bool forceRefresh = false,
    DietaryType? dietaryType,
  });
  Stream<List<Recipe>> getRecipesStream({DietaryType? dietaryType});
  Future<Recipe?> getRecipe(String id);
  Future<List<Recipe>> getRecipesByTags(
    List<String> tags, {
    bool forceRefresh = false,
    DietaryType? dietaryType,
  });
  Future<List<Recipe>> searchRecipes(
    String query, {
    bool forceRefresh = false,
    DietaryType? dietaryType,
  });
  Future<RecipesPagination> getRecipesByIngredient(
    String ingredientName, {
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
    DietaryType? dietaryType,
  });
  Future<List<String>> getAvailableCategories({DietaryType? dietaryType});
  Future<void> refreshRecipes();
}
