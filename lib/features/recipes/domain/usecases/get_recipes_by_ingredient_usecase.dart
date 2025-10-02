import '../../../../core/models/user_model.dart';
import '../repositories/recipes_repository.dart';

class GetRecipesByIngredientUseCase {
  final RecipesRepository _repository;

  GetRecipesByIngredientUseCase(this._repository);

  Future<RecipesPagination> execute(
    String ingredientName, {
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
    DietaryType? dietaryType,
  }) {
    return _repository.getRecipesByIngredient(
      ingredientName,
      page: page,
      limit: limit,
      forceRefresh: forceRefresh,
      dietaryType: dietaryType,
    );
  }
}
