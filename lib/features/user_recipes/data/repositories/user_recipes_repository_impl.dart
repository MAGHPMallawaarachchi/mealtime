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
      return await _dataSource.getUserRecipes(userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<UserRecipe>> getUserRecipesStream(String userId) {
    try {
      return _dataSource.getUserRecipesStream(userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserRecipe?> getUserRecipe(String userId, String recipeId) async {
    try {
      return await _dataSource.getUserRecipe(userId, recipeId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> createUserRecipe(UserRecipe recipe) async {
    try {
      return await _dataSource.createUserRecipe(recipe);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserRecipe(UserRecipe recipe) async {
    try {
      await _dataSource.updateUserRecipe(recipe);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteUserRecipe(String userId, String recipeId) async {
    try {
      await _dataSource.deleteUserRecipe(userId, recipeId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<UserRecipe>> searchUserRecipes(String userId, String query) async {
    try {
      return await _dataSource.searchUserRecipes(userId, query);
    } catch (e) {
      rethrow;
    }
  }
}