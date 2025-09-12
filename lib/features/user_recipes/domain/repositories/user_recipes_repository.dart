import '../models/user_recipe.dart';

abstract class UserRecipesRepository {
  Future<List<UserRecipe>> getUserRecipes(String userId);
  Stream<List<UserRecipe>> getUserRecipesStream(String userId);
  Future<UserRecipe?> getUserRecipe(String userId, String recipeId);
  Future<String> createUserRecipe(UserRecipe recipe);
  Future<void> updateUserRecipe(UserRecipe recipe);
  Future<void> deleteUserRecipe(String userId, String recipeId);
  Future<List<UserRecipe>> searchUserRecipes(String userId, String query);
}