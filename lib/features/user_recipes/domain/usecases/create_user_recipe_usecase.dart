import '../models/user_recipe.dart';
import '../repositories/user_recipes_repository.dart';

class CreateUserRecipeUseCase {
  final UserRecipesRepository _repository;

  CreateUserRecipeUseCase(this._repository);

  Future<String> execute(UserRecipe recipe) async {
    return await _repository.createUserRecipe(recipe);
  }
}