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
  Future<List<Recipe>> getRecipes({bool forceRefresh = false});
  Stream<List<Recipe>> getRecipesStream();
  Future<Recipe?> getRecipe(String id);
  Future<List<Recipe>> getRecipesByTags(List<String> tags, {bool forceRefresh = false});
  Future<List<Recipe>> searchRecipes(String query, {bool forceRefresh = false});
  Future<RecipesPagination> getRecipesByIngredient(
    String ingredientName, {
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  });
  Future<List<String>> getAvailableCategories();
  Future<void> refreshRecipes();
}