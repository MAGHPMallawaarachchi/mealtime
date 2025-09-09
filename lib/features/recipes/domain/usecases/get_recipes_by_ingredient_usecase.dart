import '../repositories/recipes_repository.dart';

class GetRecipesByIngredientUseCase {
  final RecipesRepository _repository;

  GetRecipesByIngredientUseCase(this._repository);

  Future<RecipesPagination> execute(
    String ingredientName, {
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) {
    return _repository.getRecipesByIngredient(
      ingredientName,
      page: page,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}