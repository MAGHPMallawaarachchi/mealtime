import '../../domain/models/recipe.dart';

abstract class RecipesDataSource {
  Future<List<Recipe>> getRecipes();
  Stream<List<Recipe>> getRecipesStream();
  Future<Recipe?> getRecipe(String id);
}