import '../models/user_recipe.dart';
import '../repositories/user_recipes_repository.dart';

class GetUserRecipesUseCase {
  final UserRecipesRepository _repository;

  GetUserRecipesUseCase(this._repository);

  Future<List<UserRecipe>> execute(String userId) async {
    return await _repository.getUserRecipes(userId);
  }

  Stream<List<UserRecipe>> executeStream(String userId) {
    return _repository.getUserRecipesStream(userId);
  }
}