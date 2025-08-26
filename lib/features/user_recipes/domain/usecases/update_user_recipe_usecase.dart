import '../models/user_recipe.dart';
import '../repositories/user_recipes_repository.dart';

class UpdateUserRecipeUseCase {
  final UserRecipesRepository _repository;

  UpdateUserRecipeUseCase(this._repository);

  Future<void> execute(UserRecipe recipe) async {
    await _repository.updateUserRecipe(recipe);
  }
}