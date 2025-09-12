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
      if (kDebugMode) {
        print('📚 [Firebase Recipes] Fetching recipes from collection: $_collectionPath');
      }
      
      final rawData = await _firestoreService.getCollection(_collectionPath);

      if (kDebugMode) {
        print('📚 [Firebase Recipes] Raw data received: ${rawData.length} documents');
      }

      if (rawData.isEmpty) {
        if (kDebugMode) {
          print('⚠️  [Firebase Recipes] No recipe documents found in Firestore!');
        }
        return [];
      }

      final recipes = <Recipe>[];
      int successfullyParsed = 0;
      int failedToParse = 0;
      
      for (final data in rawData) {
        try {
          final recipe = Recipe.fromJson(data);
          if (recipe.id.isNotEmpty) {
            recipes.add(recipe);
            successfullyParsed++;
            
            // Log first few recipes and any banana-related recipes for debugging
            if (kDebugMode && (successfullyParsed <= 3 || recipe.title.toLowerCase().contains('banana'))) {
              final ingredientCount = recipe.ingredients.isNotEmpty 
                  ? recipe.ingredients.length 
                  : recipe.legacyIngredients.length;
              print('🍽️  [Firebase Recipes] Recipe: "${recipe.title}" ($ingredientCount ingredients)');
              
              // Log ingredients for banana-related recipes
              if (recipe.title.toLowerCase().contains('banana')) {
                final recipeIngredients = recipe.ingredients.isNotEmpty 
                    ? recipe.ingredients.map((i) => i.name).toList()
                    : recipe.legacyIngredients;
                print('   └─ Ingredients: ${recipeIngredients.take(8).join(", ")}${recipeIngredients.length > 8 ? "..." : ""}');
              }
            }
          }
        } catch (e) {
          failedToParse++;
          if (kDebugMode && failedToParse <= 3) {
            print('❌ [Firebase Recipes] Failed to parse recipe: $e');
          }
        }
      }
      
      if (kDebugMode) {
        print('📊 [Firebase Recipes] Summary: $successfullyParsed parsed successfully, $failedToParse failed');
        
        // Check for banana recipes specifically
        final bananaRecipes = recipes.where((r) => r.title.toLowerCase().contains('banana')).toList();
        print('🍌 [Firebase Recipes] Found ${bananaRecipes.length} banana-related recipes');
        
        if (bananaRecipes.isNotEmpty) {
          for (final recipe in bananaRecipes.take(3)) {
            print('   • "${recipe.title}"');
          }
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