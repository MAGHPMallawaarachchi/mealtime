import '../../../../core/models/user_model.dart';
import '../models/recipe.dart';
import '../repositories/recipes_repository.dart';

class SearchRecipesUseCase {
  final RecipesRepository _repository;

  SearchRecipesUseCase(this._repository);

  Future<List<Recipe>> execute(
    String query, {
    bool forceRefresh = false,
    DietaryType? dietaryType,
  }) {
    return _repository.searchRecipes(
      query,
      forceRefresh: forceRefresh,
      dietaryType: dietaryType,
    );
  }
}
