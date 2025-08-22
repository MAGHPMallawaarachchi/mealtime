import '../models/favorite_recipe.dart';

abstract class FavoritesRepository {
  Future<void> addToFavorites(String userId, String recipeId);
  Future<void> removeFromFavorites(String userId, String recipeId);
  Future<List<FavoriteRecipe>> getUserFavorites(String userId);
  Future<bool> isFavorite(String userId, String recipeId);
  Stream<List<FavoriteRecipe>> getUserFavoritesStream(String userId);
}