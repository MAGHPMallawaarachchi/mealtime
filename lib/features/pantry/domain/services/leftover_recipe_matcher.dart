import '../../../recipes/domain/models/recipe.dart';
import '../models/pantry_item.dart';

class RecipeMatch {
  final Recipe recipe;
  final double relevanceScore;
  final String matchedIngredient;

  const RecipeMatch({
    required this.recipe,
    required this.relevanceScore,
    required this.matchedIngredient,
  });
}

class LeftoverRecipeMatcher {
  static const int maxSuggestionsPerLeftover = 5;

  List<RecipeMatch> findMatchingRecipes(PantryItem leftover, List<Recipe> recipes) {
    if (recipes.isEmpty) return [];

    final List<RecipeMatch> matches = [];
    final leftoverName = leftover.name.toLowerCase().trim();

    for (final recipe in recipes) {
      final matchResult = _findBestMatch(leftoverName, recipe);
      if (matchResult != null) {
        matches.add(matchResult);
      }
    }

    matches.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return matches.take(maxSuggestionsPerLeftover).toList();
  }

  Map<PantryItem, List<Recipe>> findAllMatches(
    List<PantryItem> leftovers, 
    List<Recipe> recipes,
  ) {
    final Map<PantryItem, List<Recipe>> results = {};

    for (final leftover in leftovers) {
      final matches = findMatchingRecipes(leftover, recipes);
      if (matches.isNotEmpty) {
        results[leftover] = matches.map((match) => match.recipe).toList();
      }
    }

    return results;
  }

  RecipeMatch? _findBestMatch(String leftoverName, Recipe recipe) {
    double bestScore = 0.0;
    String? bestMatchedIngredient;

    final allIngredients = _getAllRecipeIngredients(recipe);

    for (final ingredient in allIngredients) {
      final score = _calculateMatchScore(leftoverName, ingredient.toLowerCase().trim());
      if (score > bestScore && score >= 0.7) {
        bestScore = score;
        bestMatchedIngredient = ingredient;
      }
    }

    if (bestMatchedIngredient != null) {
      return RecipeMatch(
        recipe: recipe,
        relevanceScore: bestScore,
        matchedIngredient: bestMatchedIngredient,
      );
    }

    return null;
  }

  List<String> _getAllRecipeIngredients(Recipe recipe) {
    final List<String> allIngredients = [];

    if (recipe.ingredientSections.isNotEmpty) {
      for (final section in recipe.ingredientSections) {
        for (final ingredient in section.ingredients) {
          allIngredients.add(ingredient.name);
        }
      }
    }

    if (recipe.ingredients.isNotEmpty) {
      for (final ingredient in recipe.ingredients) {
        allIngredients.add(ingredient.name);
      }
    }

    if (recipe.legacyIngredients.isNotEmpty) {
      allIngredients.addAll(recipe.legacyIngredients);
    }

    return allIngredients;
  }

  double _calculateMatchScore(String leftoverName, String recipeIngredient) {
    final normalizedLeftover = _normalizeIngredientName(leftoverName);
    final normalizedRecipeIngredient = _normalizeIngredientName(recipeIngredient);

    // Check for incompatible ingredient forms first
    if (_areIncompatibleForms(normalizedLeftover, normalizedRecipeIngredient)) {
      return 0.0;
    }

    if (normalizedLeftover == normalizedRecipeIngredient) {
      return 1.0;
    }

    final leftoverWords = normalizedLeftover.split(' ').where((w) => w.isNotEmpty).toList();
    final recipeWords = normalizedRecipeIngredient.split(' ').where((w) => w.isNotEmpty).toList();

    if (_hasExactMatch(leftoverWords, recipeWords)) {
      return 0.95;
    }

    double score = _calculateWordMatchScore(leftoverWords, recipeWords);

    if (score > 0.5) {
      score += _calculateContextBonus(leftoverName, recipeIngredient);
    }

    return score.clamp(0.0, 1.0);
  }

  String _normalizeIngredientName(String ingredient) {
    String normalized = ingredient.toLowerCase().trim();
    
    final prefixesToRemove = [
      'leftover ', 'left over ', 'day old ', 'day-old ',
      'stale ', 'old ', 'remaining ', 'extra ',
    ];
    
    for (final prefix in prefixesToRemove) {
      if (normalized.startsWith(prefix)) {
        normalized = normalized.substring(prefix.length).trim();
      }
    }

    final suffixesToRemove = [' leftover', ' leftovers'];
    for (final suffix in suffixesToRemove) {
      if (normalized.endsWith(suffix)) {
        normalized = normalized.substring(0, normalized.length - suffix.length).trim();
      }
    }

    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    
    return normalized.trim();
  }

  bool _hasExactMatch(List<String> leftoverWords, List<String> recipeWords) {
    final leftoverCore = _extractCoreWords(leftoverWords);
    final recipeCore = _extractCoreWords(recipeWords);
    
    return leftoverCore.isNotEmpty && recipeCore.isNotEmpty &&
           leftoverCore.every((word) => recipeCore.contains(word));
  }

  List<String> _extractCoreWords(List<String> words) {
    final stopWords = {
      'cooked', 'fresh', 'raw', 'dried', 'frozen', 'canned', 'chopped', 
      'sliced', 'diced', 'minced', 'grated', 'shredded', 'whole', 'ground',
      'the', 'a', 'an', 'and', 'or', 'of', 'in', 'with', 'for',
    };
    
    return words.where((word) => 
      word.length > 2 && 
      !stopWords.contains(word) && 
      !RegExp(r'^\d+$').hasMatch(word)
    ).toList();
  }

  double _calculateWordMatchScore(List<String> leftoverWords, List<String> recipeWords) {
    if (leftoverWords.isEmpty || recipeWords.isEmpty) return 0.0;

    final leftoverCore = _extractCoreWords(leftoverWords);
    final recipeCore = _extractCoreWords(recipeWords);
    
    if (leftoverCore.isEmpty || recipeCore.isEmpty) return 0.0;

    int matchingWords = 0;
    for (final leftoverWord in leftoverCore) {
      for (final recipeWord in recipeCore) {
        if (_wordsMatch(leftoverWord, recipeWord)) {
          matchingWords++;
          break;
        }
      }
    }

    return matchingWords / leftoverCore.length;
  }

  bool _wordsMatch(String word1, String word2) {
    if (word1 == word2) return true;
    
    if (word1.length >= 4 && word2.length >= 4) {
      if (word1.startsWith(word2) || word2.startsWith(word1)) {
        return true;
      }
      
      final shorter = word1.length < word2.length ? word1 : word2;
      final longer = word1.length < word2.length ? word2 : word1;
      
      if (longer.contains(shorter) && shorter.length >= 3) {
        return true;
      }
    }

    final synonyms = _getSynonyms();
    return synonyms[word1]?.contains(word2) == true ||
           synonyms[word2]?.contains(word1) == true;
  }

  double _calculateContextBonus(String leftoverName, String recipeIngredient) {
    double bonus = 0.0;

    final contextMatches = {
      'cooked': ['cooked', 'leftover', 'remaining'],
      'bread': ['bread', 'toast', 'slice', 'loaf'],
      'rice': ['rice', 'grain', 'basmati', 'jasmine'],
      'chicken': ['chicken', 'poultry', 'meat'],
      'vegetables': ['vegetable', 'veggie', 'green'],
    };

    for (final entry in contextMatches.entries) {
      final key = entry.key;
      final contexts = entry.value;
      
      if (leftoverName.contains(key) || recipeIngredient.contains(key)) {
        for (final context in contexts) {
          if ((leftoverName.contains(context) && recipeIngredient.contains(key)) ||
              (recipeIngredient.contains(context) && leftoverName.contains(key))) {
            bonus += 0.1;
          }
        }
      }
    }

    return bonus.clamp(0.0, 0.3);
  }

  bool _areIncompatibleForms(String leftover, String recipeIngredient) {
    // Define incompatible ingredient forms
    final incompatiblePairs = <String, List<String>>{
      // Cooked vs Raw/Flour forms  
      'cooked rice': ['rice flour', 'raw rice', 'uncooked rice', 'rice grain'],
      'leftover rice': ['rice flour', 'raw rice', 'uncooked rice', 'rice grain'],
      
      // Bread vs Crumbs/Flour
      'bread': ['bread crumbs', 'breadcrumbs', 'bread flour'],
      'cooked bread': ['bread flour', 'all purpose flour', 'wheat flour'],
      
      // Chicken forms
      'cooked chicken': ['raw chicken', 'chicken breast', 'chicken thigh', 'whole chicken'],
      'leftover chicken': ['raw chicken', 'chicken breast', 'chicken thigh'],
      
      // Vegetable forms
      'cooked vegetables': ['fresh vegetables', 'raw vegetables'],
      'cooked carrots': ['raw carrots', 'carrot juice'],
      'cooked onions': ['raw onions'],
      
      // Banana forms
      'overripe bananas': ['green bananas', 'raw bananas', 'unripe bananas'],
      'ripe bananas': ['green bananas', 'unripe bananas'],
      
      // Potato forms
      'cooked potatoes': ['raw potatoes', 'potato flour', 'potato starch'],
      'mashed potatoes': ['raw potatoes', 'potato flour'],
    };

    // Check predefined incompatible pairs
    for (final entry in incompatiblePairs.entries) {
      final leftoverForm = entry.key;
      final incompatibleForms = entry.value;
      
      if (leftover.contains(leftoverForm)) {
        for (final incompatibleForm in incompatibleForms) {
          if (recipeIngredient.contains(incompatibleForm)) {
            return true;
          }
        }
      }
    }

    // Specific rice-based checks (the main issue you reported)
    if (leftover.contains('rice') && recipeIngredient.contains('rice')) {
      // Cooked rice should NEVER match rice flour, rice powder, etc.
      if ((leftover.contains('cooked') || leftover.contains('leftover')) && 
          (recipeIngredient.contains('flour') || recipeIngredient.contains('powder'))) {
        return true;
      }
    }

    // General flour vs whole ingredient incompatibility
    final flourForms = ['flour', 'powder', 'starch'];
    final leftoverHasFlour = flourForms.any((f) => leftover.contains(f));
    final recipeHasFlour = flourForms.any((f) => recipeIngredient.contains(f));
    
    // If one is flour form and other is whole form, they're incompatible
    if (leftoverHasFlour != recipeHasFlour) {
      final leftoverBase = _extractBaseIngredient(leftover);
      final recipeBase = _extractBaseIngredient(recipeIngredient);
      
      // Same base ingredient but different forms = incompatible
      if (leftoverBase == recipeBase && leftoverBase.isNotEmpty && leftoverBase.length > 2) {
        return true;
      }
    }

    // Oil vs whole ingredient incompatibility  
    final leftoverHasOil = leftover.contains('oil');
    final recipeHasOil = recipeIngredient.contains('oil');
    
    if (leftoverHasOil != recipeHasOil) {
      final leftoverBase = _extractBaseIngredient(leftover);
      final recipeBase = _extractBaseIngredient(recipeIngredient);
      
      if (leftoverBase == recipeBase && leftoverBase.isNotEmpty && leftoverBase.length > 2) {
        return true;
      }
    }

    return false;
  }

  String _extractBaseIngredient(String ingredient) {
    // Remove common modifiers to get base ingredient
    String base = ingredient
        .replaceAll(RegExp(r'\b(cooked|raw|fresh|dried|ground|flour|powder|starch|leftover|day.old|overripe)\b'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    // Return the first significant word
    final words = base.split(' ').where((w) => w.length > 2).toList();
    return words.isNotEmpty ? words.first : '';
  }

  Map<String, List<String>> _getSynonyms() {
    return {
      'banana': ['bananas', 'plantain'],
      'bananas': ['banana', 'plantain'],
      'rice': ['basmati', 'jasmine', 'grain'],
      'chicken': ['poultry', 'fowl'],
      'bread': ['toast', 'bun', 'roll', 'loaf'],
      'potato': ['potatoes', 'spud'],
      'potatoes': ['potato', 'spud'],
      'tomato': ['tomatoes'],
      'tomatoes': ['tomato'],
      'onion': ['onions'],
      'onions': ['onion'],
      'curry': ['curries'],
      'curries': ['curry'],
      'roti': ['rotis', 'flatbread'],
      'rotis': ['roti', 'flatbread'],
    };
  }
}