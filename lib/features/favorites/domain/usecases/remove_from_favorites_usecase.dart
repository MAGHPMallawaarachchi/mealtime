import '../repositories/favorites_repository.dart';

class RemoveFromFavoritesUseCase {
  final FavoritesRepository _repository;

  RemoveFromFavoritesUseCase(this._repository);

  Future<void> execute(String userId, String recipeId) async {
    if (userId.isEmpty || recipeId.isEmpty) {
      throw ArgumentError('User ID and Recipe ID cannot be empty');
    }
    
    await _repository.removeFromFavorites(userId, recipeId);
  }
}