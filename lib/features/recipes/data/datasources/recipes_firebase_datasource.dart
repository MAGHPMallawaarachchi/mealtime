import 'package:flutter/foundation.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/models/recipe.dart';
import 'recipes_datasource.dart';

class RecipesFirebaseDataSource implements RecipesDataSource {
  static const String _collectionPath = 'recipes';
  
  final FirestoreService _firestoreService;

  RecipesFirebaseDataSource({
    FirestoreService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<List<Recipe>> getRecipes() async {
    try {
      final rawData = await _firestoreService.getCollection(_collectionPath);

      if (rawData.isEmpty) {
        return [];
      }

      final recipes = <Recipe>[];
      
      for (final data in rawData) {
        try {
          final recipe = Recipe.fromJson(data);
          if (recipe.id.isNotEmpty) {
            recipes.add(recipe);
          }
        } catch (e) {
          // Skip invalid recipes and continue
        }
      }
      
      return recipes;
    } catch (e) {
      throw RecipesDataSourceException(
        'Failed to fetch recipes: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<Recipe>> getRecipesStream() {
    try {
      return _firestoreService.getCollectionStream(_collectionPath).map(
        (rawDataList) => rawDataList
            .map((data) => Recipe.fromJson(data))
            .toList()
          ..sort((a, b) => a.title.compareTo(b.title)),
      );
    } catch (e) {
      throw RecipesDataSourceException(
        'Failed to stream recipes: ${e.toString()}',
      );
    }
  }

  @override
  Future<Recipe?> getRecipe(String id) async {
    try {
      final rawData = await _firestoreService.getDocument(_collectionPath, id);
      
      if (rawData == null) {
        return null;
      }

      return Recipe.fromJson(rawData);
    } catch (e) {
      throw RecipesDataSourceException(
        'Failed to fetch recipe with id $id: ${e.toString()}',
      );
    }
  }
}

class RecipesDataSourceException implements Exception {
  final String message;

  RecipesDataSourceException(this.message);

  @override
  String toString() => 'RecipesDataSourceException: $message';
}