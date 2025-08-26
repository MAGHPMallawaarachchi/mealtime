import 'package:flutter/foundation.dart';
import '../../domain/models/user_recipe.dart';
import '../../domain/repositories/user_recipes_repository.dart';
import '../datasources/user_recipes_firebase_datasource.dart';

class UserRecipesRepositoryImpl implements UserRecipesRepository {
  final UserRecipesFirebaseDataSource _dataSource;

  UserRecipesRepositoryImpl({
    UserRecipesFirebaseDataSource? dataSource,
  }) : _dataSource = dataSource ?? UserRecipesFirebaseDataSource();

  @override
  Future<List<UserRecipe>> getUserRecipes(String userId) async {
    try {
      debugPrint('UserRecipesRepositoryImpl: Getting user recipes for $userId');
      return await _dataSource.getUserRecipes(userId);
    } catch (e) {
      debugPrint('UserRecipesRepositoryImpl: Error getting user recipes: $e');
      rethrow;
    }
  }

  @override
  Stream<List<UserRecipe>> getUserRecipesStream(String userId) {
    try {
      debugPrint('UserRecipesRepositoryImpl: Getting user recipes stream for $userId');
      return _dataSource.getUserRecipesStream(userId);
    } catch (e) {
      debugPrint('UserRecipesRepositoryImpl: Error getting user recipes stream: $e');
      rethrow;
    }
  }

  @override
  Future<UserRecipe?> getUserRecipe(String userId, String recipeId) async {
    try {
      debugPrint('UserRecipesRepositoryImpl: Getting user recipe $recipeId for $userId');
      return await _dataSource.getUserRecipe(userId, recipeId);
    } catch (e) {
      debugPrint('UserRecipesRepositoryImpl: Error getting user recipe: $e');
      rethrow;
    }
  }

  @override
  Future<String> createUserRecipe(UserRecipe recipe) async {
    try {
      debugPrint('UserRecipesRepositoryImpl: Creating user recipe for ${recipe.userId}');
      return await _dataSource.createUserRecipe(recipe);
    } catch (e) {
      debugPrint('UserRecipesRepositoryImpl: Error creating user recipe: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserRecipe(UserRecipe recipe) async {
    try {
      debugPrint('UserRecipesRepositoryImpl: Updating user recipe ${recipe.id} for ${recipe.userId}');
      await _dataSource.updateUserRecipe(recipe);
    } catch (e) {
      debugPrint('UserRecipesRepositoryImpl: Error updating user recipe: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUserRecipe(String userId, String recipeId) async {
    try {
      debugPrint('UserRecipesRepositoryImpl: Deleting user recipe $recipeId for $userId');
      await _dataSource.deleteUserRecipe(userId, recipeId);
    } catch (e) {
      debugPrint('UserRecipesRepositoryImpl: Error deleting user recipe: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserRecipe>> searchUserRecipes(String userId, String query) async {
    try {
      debugPrint('UserRecipesRepositoryImpl: Searching user recipes for "$query" (user: $userId)');
      return await _dataSource.searchUserRecipes(userId, query);
    } catch (e) {
      debugPrint('UserRecipesRepositoryImpl: Error searching user recipes: $e');
      rethrow;
    }
  }
}