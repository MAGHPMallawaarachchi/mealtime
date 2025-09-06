import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../domain/models/recipe.dart';
import 'recipes_datasource.dart';

class RecipesMockDataSource implements RecipesDataSource {
  static const String _sampleRecipesPath = 'data/sample_recipes.json';
  
  @override
  Future<List<Recipe>> getRecipes() async {
    try {
      if (kDebugMode) {
        print('📚 [Mock Recipes] Loading sample recipes from $_sampleRecipesPath');
      }
      
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(_sampleRecipesPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      
      if (kDebugMode) {
        print('📚 [Mock Recipes] Raw data received: ${jsonList.length} recipes');
      }

      if (jsonList.isEmpty) {
        if (kDebugMode) {
          print('⚠️  [Mock Recipes] No recipe data found in sample file!');
        }
        return [];
      }

      final recipes = <Recipe>[];
      int successfullyParsed = 0;
      int failedToParse = 0;
      
      for (final data in jsonList) {
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
              print('🍽️  [Mock Recipes] Recipe: "${recipe.title}" ($ingredientCount ingredients)');
              
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
            print('❌ [Mock Recipes] Failed to parse recipe: $e');
            print('   Raw data: ${data.toString().substring(0, 100)}...');
          }
        }
      }
      
      if (kDebugMode) {
        print('📊 [Mock Recipes] Summary: $successfullyParsed parsed successfully, $failedToParse failed');
        
        // Check for banana recipes specifically
        final bananaRecipes = recipes.where((r) => r.title.toLowerCase().contains('banana')).toList();
        print('🍌 [Mock Recipes] Found ${bananaRecipes.length} banana-related recipes');
        
        if (bananaRecipes.isNotEmpty) {
          for (final recipe in bananaRecipes.take(3)) {
            print('   • "${recipe.title}" (ID: ${recipe.id})');
          }
        }
      }
      
      return recipes;
    } catch (e) {
      if (kDebugMode) {
        print('💥 [Mock Recipes] Error loading sample recipes: $e');
      }
      throw RecipesDataSourceException(
        'Failed to load sample recipes: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<Recipe>> getRecipesStream() {
    return Stream.fromFuture(getRecipes());
  }

  @override
  Future<Recipe?> getRecipe(String id) async {
    try {
      final recipes = await getRecipes();
      final matchingRecipes = recipes.where((recipe) => recipe.id == id);
      return matchingRecipes.isEmpty ? null : matchingRecipes.first;
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