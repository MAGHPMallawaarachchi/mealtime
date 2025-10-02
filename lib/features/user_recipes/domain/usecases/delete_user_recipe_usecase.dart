import '../repositories/user_recipes_repository.dart';

class DeleteUserRecipeUseCase {
  final UserRecipesRepository _repository;

  DeleteUserRecipeUseCase(this._repository);

  Future<void> execute(String userId, String recipeId) async {
    await _repository.deleteUserRecipe(userId, recipeId);
  }
}