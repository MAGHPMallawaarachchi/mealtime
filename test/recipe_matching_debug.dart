import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'dart:io';
import '../lib/features/recipes/domain/models/recipe.dart';
import '../lib/features/pantry/domain/usecases/get_recipe_matches_usecase.dart';
import '../lib/features/pantry/domain/services/ingredient_categorizer.dart';

void main() {
  group('Recipe Matching Debug Tests', () {
    test('Test banana bread recipe loading and matching', () async {
      print('🧪 [Test] Loading sample recipes...');
      
      // Load the sample recipes JSON
      final file = File('data/sample_recipes.json');
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      
      print('🧪 [Test] Loaded ${jsonList.length} recipes from JSON');
      
      // Find the banana bread recipe
      final bananaRecipeJson = jsonList.firstWhere(
        (recipe) => recipe['title'].toString().toLowerCase().contains('banana'),
        orElse: () => null,
      );
      
      if (bananaRecipeJson == null) {
        print('❌ [Test] No banana recipe found in sample data!');
        return;
      }
      
      print('🍌 [Test] Found banana recipe: "${bananaRecipeJson['title']}"');
      
      // Parse the recipe
      try {
        final recipe = Recipe.fromJson(bananaRecipeJson);
        print('✅ [Test] Successfully parsed banana recipe');
        print('   - ID: ${recipe.id}');
        print('   - Title: ${recipe.title}');
        print('   - Ingredient sections: ${recipe.ingredientSections.length}');
        
        if (recipe.ingredientSections.isNotEmpty) {
          final ingredients = recipe.ingredientSections.first.ingredients;
          print('   - Ingredients (${ingredients.length}):');
          for (final ingredient in ingredients) {
            print('     • ${ingredient.name}');
          }
        }
        
        // Test ingredient categorization
        print('\\n🧪 [Test] Testing ingredient categorization:');
        final testIngredients = ['banana', 'wheat flour', 'sugar', 'butter', 'egg'];
        
        for (final ingredient in testIngredients) {
          final category = IngredientCategorizer.categorizeIngredient(ingredient);
          final weight = IngredientCategorizer.getIngredientWeight(ingredient);
          final isEssential = IngredientCategorizer.isEssentialIngredient(ingredient);
          final shouldInclude = IngredientCategorizer.shouldIncludeInCoreMatching(ingredient);
          
          print('   $ingredient -> ${category.importance.name} (weight: $weight, essential: $isEssential, include: $shouldInclude)');
        }
        
        // Test ingredient matching
        print('\\n🧪 [Test] Testing ingredient matching with sample pantry:');
        final mockPantryIngredients = ['banana', 'wheat flour', 'sugar', 'butter', 'egg', 'baking soda'];
        
        print('   Pantry ingredients: ${mockPantryIngredients.join(", ")}');
        
        // Extract recipe ingredients
        List<String> recipeIngredientNames = [];
        if (recipe.ingredientSections.isNotEmpty) {
          for (final section in recipe.ingredientSections) {
            recipeIngredientNames.addAll(
              section.ingredients.map<String>((ingredient) => ingredient.name.toLowerCase())
            );
          }
        }
        
        print('   Recipe ingredients: ${recipeIngredientNames.join(", ")}');
        
        // Check matches
        final matches = <String>[];
        final missing = <String>[];
        
        for (final recipeIngredient in recipeIngredientNames) {
          bool found = false;
          for (final pantryIngredient in mockPantryIngredients.map((i) => i.toLowerCase())) {
            if (_isIngredientMatch(recipeIngredient, pantryIngredient)) {
              matches.add(recipeIngredient);
              found = true;
              break;
            }
          }
          if (!found) {
            missing.add(recipeIngredient);
          }
        }
        
        print('   Matched ingredients (${matches.length}): ${matches.join(", ")}');
        print('   Missing ingredients (${missing.length}): ${missing.join(", ")}');
        
        final matchPercentage = recipeIngredientNames.isEmpty 
            ? 0.0 
            : (matches.length / recipeIngredientNames.length) * 100;
        print('   Match percentage: ${matchPercentage.toStringAsFixed(1)}%');
        
      } catch (e) {
        print('❌ [Test] Failed to parse banana recipe: $e');
      }
    });
  });
}

bool _isIngredientMatch(String ingredient1, String ingredient2) {
  // Simple matching logic for testing
  if (ingredient1 == ingredient2) return true;
  
  // Check if one contains the other
  if (ingredient1.contains(ingredient2) || ingredient2.contains(ingredient1)) {
    return true;
  }
  
  // Check aliases through categorizer
  final aliases1 = IngredientCategorizer.getIngredientAliases(ingredient1);
  final aliases2 = IngredientCategorizer.getIngredientAliases(ingredient2);
  
  if (aliases1.contains(ingredient2) || aliases2.contains(ingredient1)) {
    return true;
  }
  
  return false;
}