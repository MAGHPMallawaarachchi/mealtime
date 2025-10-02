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
      
      for (int i = 0; i < rawData.length; i++) {
        final data = rawData[i];
        try {
          final recipe = Recipe.fromJson(data);
          if (recipe.id.isNotEmpty) {
            recipes.add(recipe);
            successfullyParsed++;

            // Log first few recipes and any banana-related recipes for debugging
            if (kDebugMode && (successfullyParsed <= 3 || recipe.title.toLowerCase().contains('banana'))) {
              final ingredientCount = recipe.ingredients.isNotEmpty
                  ? recipe.ingredients.length
                  : (recipe.ingredientSections.isNotEmpty
                      ? recipe.ingredientSections.fold<int>(0, (sum, section) => sum + section.ingredients.length)
                      : recipe.legacyIngredients.length);
              print('🍽️  [Firebase Recipes] Recipe: "${recipe.title}" ($ingredientCount ingredients)');

              // Log ingredients for banana-related recipes
              if (recipe.title.toLowerCase().contains('banana')) {
                List<String> recipeIngredients = [];
                if (recipe.ingredients.isNotEmpty) {
                  recipeIngredients = recipe.ingredients.map((i) => i.name).toList();
                } else if (recipe.ingredientSections.isNotEmpty) {
                  recipeIngredients = recipe.ingredientSections
                      .expand((section) => section.ingredients.map((i) => i.name))
                      .toList();
                } else {
                  recipeIngredients = recipe.legacyIngredients;
                }
                print('   └─ Ingredients: ${recipeIngredients.take(8).join(", ")}${recipeIngredients.length > 8 ? "..." : ""}');
              }
            }
          } else {
            failedToParse++;
            if (kDebugMode) {
              print('⚠️  [Firebase Recipes] Recipe at index $i has empty ID, skipping');
            }
          }
        } catch (e, stackTrace) {
          failedToParse++;
          if (kDebugMode) {
            print('❌ [Firebase Recipes] Failed to parse recipe at index $i: $e');
            print('   📋 Raw data sample: ${data.toString().length > 200 ? data.toString().substring(0, 200) + "..." : data.toString()}');

            // Additional debugging for specific issues
            if (data is Map<String, dynamic>) {
              final title = data['title'];
              final ingredientSections = data['ingredientSections'];
              final instructionSections = data['instructionSections'];

              print('   🔍 Recipe title: ${title ?? "N/A"}');
              print('   🔍 Has ingredientSections: ${ingredientSections is List ? "Yes (${ingredientSections.length})" : "No"}');
              print('   🔍 Has instructionSections: ${instructionSections is List ? "Yes (${instructionSections.length})" : "No"}');

              if (ingredientSections is List && ingredientSections.isNotEmpty) {
                final firstSection = ingredientSections.first;
                if (firstSection is Map && firstSection.containsKey('ingredients')) {
                  final ingredients = firstSection['ingredients'];
                  if (ingredients is List && ingredients.isNotEmpty) {
                    final firstIngredient = ingredients.first;
                    print('   🔍 First ingredient structure: ${firstIngredient.runtimeType}');
                    if (firstIngredient is Map) {
                      print('   🔍 First ingredient keys: ${firstIngredient.keys.toList()}');
                      if (firstIngredient.containsKey('name')) {
                        print('   🔍 Name field type: ${firstIngredient['name'].runtimeType}');
                        print('   🔍 Name field value: ${firstIngredient['name']}');
                      }
                    }
                  }
                }
              }
            }

            if (failedToParse <= 3) {
              print('   📄 Stack trace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
            }
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