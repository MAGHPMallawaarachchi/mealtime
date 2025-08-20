import '../models/recipe.dart';
import '../repositories/recipes_repository.dart';

class SearchRecipesUseCase {
  final RecipesRepository _repository;

  SearchRecipesUseCase(this._repository);

  Future<List<Recipe>> execute(String query) {
    return _repository.searchRecipes(query);
  }
}