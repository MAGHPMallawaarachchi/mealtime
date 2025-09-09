import '../../../../core/models/user_model.dart';
import '../models/recipe.dart';
import '../repositories/recipes_repository.dart';

class GetRecipesUseCase {
  final RecipesRepository _repository;

  GetRecipesUseCase(this._repository);

  Future<List<Recipe>> execute({
    bool forceRefresh = false,
    DietaryType? dietaryType,
  }) {
    return _repository.getRecipes(
      forceRefresh: forceRefresh,
      dietaryType: dietaryType,
    );
  }
}
