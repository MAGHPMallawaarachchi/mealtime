import '../models/recipe.dart';
import '../repositories/recipes_repository.dart';

class GetRecipesByCategoryUseCase {
  final RecipesRepository _repository;

  GetRecipesByCategoryUseCase(this._repository);

  Future<List<Recipe>> execute(List<String> tags) {
    return _repository.getRecipesByTags(tags);
  }
}