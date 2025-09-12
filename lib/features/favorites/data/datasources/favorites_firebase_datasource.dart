import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/favorite_recipe.dart';

class FavoritesFirebaseDataSource {
  final FirebaseFirestore _firestore;

  FavoritesFirebaseDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addToFavorites(String userId, String recipeId) async {
    try {
      final favoriteDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(recipeId);

      await favoriteDoc.set({
        'recipeId': recipeId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FavoritesDataSourceException(
        'Failed to add recipe to favorites: ${e.toString()}',
      );
    }
  }

  Future<void> removeFromFavorites(String userId, String recipeId) async {
    try {
      final favoriteDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(recipeId);

      await favoriteDoc.delete();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FavoritesDataSourceException(
        'Failed to remove recipe from favorites: ${e.toString()}',
      );
    }
  }

  Future<List<FavoriteRecipe>> getUserFavorites(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      final favorites = querySnapshot.docs
          .map(
            (doc) => FavoriteRecipe.fromJson({
              'recipeId': doc.id,
              'addedAt': doc.data()['addedAt'] as Timestamp,
            }),
          )
          .toList();

      return favorites;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FavoritesDataSourceException(
        'Failed to get user favorites: ${e.toString()}',
      );
    }
  }

  Future<bool> isFavorite(String userId, String recipeId) async {
    try {
      final favoriteDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(recipeId)
          .get();

      final isFavorite = favoriteDoc.exists;

      return isFavorite;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FavoritesDataSourceException(
        'Failed to check if recipe is favorite: ${e.toString()}',
      );
    }
  }

  Stream<List<FavoriteRecipe>> getUserFavoritesStream(String userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map(
                  (doc) => FavoriteRecipe.fromJson({
                    'recipeId': doc.id,
                    'addedAt': doc.data()['addedAt'] as Timestamp,
                  }),
                )
                .toList();
          });
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FavoritesDataSourceException(
        'Failed to create favorites stream: ${e.toString()}',
      );
    }
  }

  FavoritesDataSourceException _handleFirebaseException(FirebaseException e) {
    String message;
    switch (e.code) {
      case 'permission-denied':
        message = 'You do not have permission to access favorites.';
        break;
      case 'unavailable':
        message =
            'Favorites service is currently unavailable. Please try again later.';
        break;
      case 'not-found':
        message = 'User not found.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      default:
        message = e.message ?? 'An error occurred while accessing favorites.';
    }
    return FavoritesDataSourceException(message);
  }
}

class FavoritesDataSourceException implements Exception {
  final String message;

  FavoritesDataSourceException(this.message);

  @override
  String toString() => 'FavoritesDataSourceException: $message';
}
