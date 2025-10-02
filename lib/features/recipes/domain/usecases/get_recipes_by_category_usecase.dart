import '../../../../core/models/user_model.dart';
import '../models/recipe.dart';
import '../repositories/recipes_repository.dart';

class GetRecipesByCategoryUseCase {
  final RecipesRepository _repository;

  GetRecipesByCategoryUseCase(this._repository);

  Future<List<Recipe>> execute(
    List<String> tags, {
    bool forceRefresh = false,
    DietaryType? dietaryType,
  }) {
    return _repository.getRecipesByTags(
      tags,
      forceRefresh: forceRefresh,
      dietaryType: dietaryType,
    );
  }
}
