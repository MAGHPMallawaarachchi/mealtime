import '../repositories/favorites_repository.dart';

class CheckIsFavoriteUseCase {
  final FavoritesRepository _repository;

  CheckIsFavoriteUseCase(this._repository);

  Future<bool> execute(String userId, String recipeId) async {
    if (userId.isEmpty || recipeId.isEmpty) {
      return false;
    }
    
    return await _repository.isFavorite(userId, recipeId);
  }
}