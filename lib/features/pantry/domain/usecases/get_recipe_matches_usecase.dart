import '../models/recipe_match.dart';
import '../repositories/pantry_repository.dart';
import '../../../recipes/domain/repositories/recipes_repository.dart';
import '../../../user_recipes/domain/repositories/user_recipes_repository.dart';

class GetRecipeMatchesUseCase {
  final PantryRepository pantryRepository;
  final RecipesRepository recipesRepository;
  final UserRecipesRepository userRecipesRepository;

  const GetRecipeMatchesUseCase({
    required this.pantryRepository,
    required this.recipesRepository,
    required this.userRecipesRepository,
  });

  Future<List<RecipeMatch>> execute(String userId, {
    MatchType? minMatchType,
    int? limit,
  }) async {
    try {
      final pantryIngredients = await pantryRepository.getPantryIngredientNames(userId);
      
      if (pantryIngredients.isEmpty) {
        return [];
      }

      final List<RecipeMatch> matches = [];

      // Get system recipes
      final recipes = await recipesRepository.getRecipes();
      for (final recipe in recipes) {
        final match = _createRecipeMatch(recipe, pantryIngredients, false);
        if (match != null && _meetsMinimumCriteria(match, minMatchType)) {
          matches.add(match);
        }
      }

      // Get user recipes
      final userRecipes = await userRecipesRepository.getUserRecipes(userId);
      for (final userRecipe in userRecipes) {
        final match = _createUserRecipeMatch(userRecipe, pantryIngredients);
        if (match != null && _meetsMinimumCriteria(match, minMatchType)) {
          matches.add(match);
        }
      }

      // Sort by match percentage (highest first)
      matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

      // Apply limit if specified
      if (limit != null && matches.length > limit) {
        return matches.take(limit).toList();
      }

      return matches;
    } catch (e) {
      throw Exception('Failed to get recipe matches: ${e.toString()}');
    }
  }

  RecipeMatch? _createRecipeMatch(dynamic recipe, List<String> pantryIngredients, bool isUserRecipe) {
    try {
      List<String> recipeIngredientNames;
      
      if (recipe.ingredients.isNotEmpty) {
        // New format with RecipeIngredient objects
        recipeIngredientNames = recipe.ingredients
            .map<String>((ingredient) => ingredient.name.toLowerCase())
            .toList();
      } else {
        // Legacy format with string ingredients
        recipeIngredientNames = recipe.legacyIngredients
            .map<String>((ingredient) => _extractIngredientName(ingredient))
            .toList();
      }

      if (recipeIngredientNames.isEmpty) {
        return null;
      }

      final normalizedPantryIngredients = pantryIngredients
          .map((ingredient) => ingredient.toLowerCase())
          .toList();

      final List<String> availableIngredients = [];
      final List<String> missingIngredients = [];

      for (final recipeIngredient in recipeIngredientNames) {
        bool found = false;
        
        for (final pantryIngredient in normalizedPantryIngredients) {
          if (_isIngredientMatch(recipeIngredient, pantryIngredient)) {
            availableIngredients.add(recipeIngredient);
            found = true;
            break;
          }
        }
        
        if (!found) {
          missingIngredients.add(recipeIngredient);
        }
      }

      if (availableIngredients.isEmpty) {
        return null;
      }

      return RecipeMatch.fromRecipe(
        recipe: recipe,
        availableIngredientNames: availableIngredients,
        missingIngredientNames: missingIngredients,
        pantryIngredients: pantryIngredients,
      );
    } catch (e) {
      return null;
    }
  }

  RecipeMatch? _createUserRecipeMatch(dynamic userRecipe, List<String> pantryIngredients) {
    try {
      List<String> recipeIngredientNames = [];
      
      if (userRecipe.ingredientSections.isNotEmpty) {
        // New format with ingredient sections
        for (final section in userRecipe.ingredientSections) {
          recipeIngredientNames.addAll(
            section.ingredients.map<String>((ingredient) => ingredient.name.toLowerCase())
          );
        }
      } else {
        // Legacy format with simple ingredients list
        recipeIngredientNames = userRecipe.ingredients
            .map<String>((ingredient) => ingredient.toLowerCase())
            .toList();
      }

      if (recipeIngredientNames.isEmpty) {
        return null;
      }

      final normalizedPantryIngredients = pantryIngredients
          .map((ingredient) => ingredient.toLowerCase())
          .toList();

      final List<String> availableIngredients = [];
      final List<String> missingIngredients = [];

      for (final recipeIngredient in recipeIngredientNames) {
        bool found = false;
        
        for (final pantryIngredient in normalizedPantryIngredients) {
          if (_isIngredientMatch(recipeIngredient, pantryIngredient)) {
            availableIngredients.add(recipeIngredient);
            found = true;
            break;
          }
        }
        
        if (!found) {
          missingIngredients.add(recipeIngredient);
        }
      }

      if (availableIngredients.isEmpty) {
        return null;
      }

      return RecipeMatch.fromUserRecipe(
        userRecipe: userRecipe,
        availableIngredientNames: availableIngredients,
        missingIngredientNames: missingIngredients,
        pantryIngredients: pantryIngredients,
      );
    } catch (e) {
      return null;
    }
  }

  String _extractIngredientName(String ingredient) {
    // Extract ingredient name from strings like "2 cups rice" -> "rice"
    final words = ingredient.toLowerCase().split(' ');
    
    // Skip quantities and units at the beginning
    int startIndex = 0;
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (!_isQuantityOrUnit(word)) {
        startIndex = i;
        break;
      }
    }
    
    return words.sublist(startIndex).join(' ').trim();
  }

  bool _isQuantityOrUnit(String word) {
    // Check if word is a quantity or unit
    final quantities = ['cup', 'cups', 'tsp', 'tbsp', 'ml', 'l', 'g', 'kg', 'oz', 'lb', 'lbs'];
    final numbers = RegExp(r'^\d+\.?\d*$');
    
    return numbers.hasMatch(word) || 
           quantities.contains(word.toLowerCase()) ||
           word.contains('½') || word.contains('¼') || word.contains('¾');
  }

  bool _isIngredientMatch(String recipeIngredient, String pantryIngredient) {
    // Exact match
    if (recipeIngredient == pantryIngredient) {
      return true;
    }

    // Fuzzy matching - check if ingredients contain each other
    if (recipeIngredient.contains(pantryIngredient) || 
        pantryIngredient.contains(recipeIngredient)) {
      return true;
    }

    // Check for common variations
    final Map<String, List<String>> variations = {
      'onion': ['red onion', 'white onion', 'yellow onion', 'onions'],
      'tomato': ['tomatoes', 'fresh tomato', 'ripe tomato'],
      'garlic': ['garlic cloves', 'fresh garlic'],
      'ginger': ['fresh ginger', 'ginger root'],
      'chili': ['chilies', 'chilli', 'chillies', 'green chili', 'red chili'],
      'coconut': ['coconut milk', 'fresh coconut', 'coconut flakes'],
      'curry leaves': ['fresh curry leaves', 'karapincha'],
      'cinnamon': ['cinnamon stick', 'ground cinnamon'],
    };

    for (final entry in variations.entries) {
      if ((entry.key == recipeIngredient || entry.value.contains(recipeIngredient)) &&
          (entry.key == pantryIngredient || entry.value.contains(pantryIngredient))) {
        return true;
      }
    }

    return false;
  }

  bool _meetsMinimumCriteria(RecipeMatch match, MatchType? minMatchType) {
    if (minMatchType == null) {
      return true;
    }

    switch (minMatchType) {
      case MatchType.complete:
        return match.matchType == MatchType.complete;
      case MatchType.partial:
        return match.matchType == MatchType.complete || 
               match.matchType == MatchType.partial;
      case MatchType.minimal:
        return true; // All match types are acceptable
    }
  }
}