import '../models/favorite_recipe.dart';
import '../repositories/favorites_repository.dart';

class GetUserFavoritesUseCase {
  final FavoritesRepository _repository;

  GetUserFavoritesUseCase(this._repository);

  Future<List<FavoriteRecipe>> execute(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    
    return await _repository.getUserFavorites(userId);
  }

  Stream<List<FavoriteRecipe>> executeStream(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    
    return _repository.getUserFavoritesStream(userId);
  }
}