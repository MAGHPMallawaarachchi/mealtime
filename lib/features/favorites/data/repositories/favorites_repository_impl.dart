import 'package:flutter/foundation.dart';
import '../../domain/models/favorite_recipe.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_firebase_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesFirebaseDataSource _dataSource;

  FavoritesRepositoryImpl({
    FavoritesFirebaseDataSource? dataSource,
  }) : _dataSource = dataSource ?? FavoritesFirebaseDataSource();

  @override
  Future<void> addToFavorites(String userId, String recipeId) async {
    try {
      await _dataSource.addToFavorites(userId, recipeId);
    } catch (e) {
      throw FavoritesRepositoryException('Failed to add recipe to favorites: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFromFavorites(String userId, String recipeId) async {
    try {
      await _dataSource.removeFromFavorites(userId, recipeId);
    } catch (e) {
      throw FavoritesRepositoryException('Failed to remove recipe from favorites: ${e.toString()}');
    }
  }

  @override
  Future<List<FavoriteRecipe>> getUserFavorites(String userId) async {
    try {
      final favorites = await _dataSource.getUserFavorites(userId);
      return favorites;
    } catch (e) {
      throw FavoritesRepositoryException('Failed to get user favorites: ${e.toString()}');
    }
  }

  @override
  Future<bool> isFavorite(String userId, String recipeId) async {
    try {
      final isFavorite = await _dataSource.isFavorite(userId, recipeId);
      return isFavorite;
    } catch (e) {
      throw FavoritesRepositoryException('Failed to check favorite status: ${e.toString()}');
    }
  }

  @override
  Stream<List<FavoriteRecipe>> getUserFavoritesStream(String userId) {
    try {
      return _dataSource.getUserFavoritesStream(userId).handleError((error) {
        throw FavoritesRepositoryException('Failed to stream favorites: ${error.toString()}');
      });
    } catch (e) {
      throw FavoritesRepositoryException('Failed to create favorites stream: ${e.toString()}');
    }
  }
}

class FavoritesRepositoryException implements Exception {
  final String message;

  FavoritesRepositoryException(this.message);

  @override
  String toString() => 'FavoritesRepositoryException: $message';
}