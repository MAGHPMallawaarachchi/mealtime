import '../models/user_recipe.dart';
import '../repositories/user_recipes_repository.dart';

class GetUserRecipeUseCase {
  final UserRecipesRepository _repository;

  GetUserRecipeUseCase(this._repository);

  Future<UserRecipe?> execute(String userId, String recipeId) async {
    return await _repository.getUserRecipe(userId, recipeId);
  }
}