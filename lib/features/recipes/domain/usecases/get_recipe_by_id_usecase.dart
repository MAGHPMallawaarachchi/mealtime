import '../models/recipe.dart';
import '../repositories/recipes_repository.dart';

class GetRecipeByIdUseCase {
  final RecipesRepository _repository;

  GetRecipeByIdUseCase(this._repository);

  Future<Recipe?> execute(String recipeId) {
    return _repository.getRecipe(recipeId);
  }
}
