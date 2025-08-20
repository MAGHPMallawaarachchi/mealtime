import '../models/recipe.dart';

abstract class RecipesRepository {
  Future<List<Recipe>> getRecipes({bool forceRefresh = false});
  Stream<List<Recipe>> getRecipesStream();
  Future<Recipe?> getRecipe(String id);
  Future<List<Recipe>> getRecipesByTags(List<String> tags);
  Future<List<Recipe>> searchRecipes(String query);
  Future<List<String>> getAvailableCategories();
  Future<void> refreshRecipes();
}