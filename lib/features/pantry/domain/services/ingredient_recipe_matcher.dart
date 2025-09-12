import '../../../recipes/domain/models/recipe.dart';
import '../models/pantry_item.dart';
import '../models/ingredient_recipe_match.dart';

class IngredientRecipeMatcher {
  static const int maxSuggestionsPerPage = 10;
  static const double minMatchThreshold = 0.6;
  
  // Cache for normalized ingredient names to improve performance
  final Map<String, String> _normalizedNameCache = <String, String>{};
  
  // Cache for recipe ingredients extraction
  final Map<String, List<String>> _recipeIngredientsCache = <String, List<String>>{};

  final Map<String, List<String>> _substitutionMap = {
    'vegetable oil': ['coconut oil', 'sunflower oil', 'olive oil', 'canola oil'],
    'coconut oil': ['vegetable oil', 'sunflower oil', 'olive oil'],
    'olive oil': ['vegetable oil', 'coconut oil', 'sunflower oil'],
    'onion': ['onions', 'red onion', 'white onion', 'yellow onion', 'shallot'],
    'onions': ['onion', 'red onion', 'white onion', 'yellow onion', 'shallot'],
    'garlic': ['garlic cloves', 'garlic powder', 'minced garlic'],
    'tomato': ['tomatoes', 'cherry tomatoes', 'roma tomatoes'],
    'tomatoes': ['tomato', 'cherry tomatoes', 'roma tomatoes'],
    'chili powder': ['chilli powder', 'red chili powder', 'paprika'],
    'chilli powder': ['chili powder', 'red chili powder', 'paprika'],
    'cumin powder': ['ground cumin', 'cumin seeds'],
    'coriander powder': ['ground coriander', 'coriander seeds'],
    'turmeric': ['turmeric powder', 'ground turmeric'],
    'ginger': ['fresh ginger', 'ginger paste', 'ground ginger'],
    'rice': ['basmati rice', 'jasmine rice', 'white rice', 'brown rice'],
    'flour': ['all purpose flour', 'wheat flour', 'plain flour'],
    'wheat flour': ['all purpose flour', 'flour', 'plain flour'],
    'coconut': ['fresh coconut', 'coconut flakes', 'desiccated coconut'],
    'curry leaves': ['fresh curry leaves', 'dried curry leaves'],
    'mustard seeds': ['yellow mustard seeds', 'black mustard seeds'],
    'salt': ['sea salt', 'table salt', 'rock salt'],
    'sugar': ['white sugar', 'brown sugar', 'palm sugar', 'jaggery'],
    'milk': ['whole milk', 'coconut milk', '2% milk', 'almond milk'],
    'yogurt': ['greek yogurt', 'plain yogurt', 'curd'],
    'lemon': ['lemon juice', 'lime', 'lime juice'],
    'lime': ['lime juice', 'lemon', 'lemon juice'],
  };

  List<IngredientRecipeMatch> findMatchingRecipes(
    List<PantryItem> availableIngredients,
    List<Recipe> recipes,
  ) {
    if (recipes.isEmpty || availableIngredients.isEmpty) return [];

    final List<IngredientRecipeMatch> matches = [];
    final availableIngredientNames = availableIngredients
        .where((item) => item.type == PantryItemType.ingredient)
        .map((item) => item.name.toLowerCase().trim())
        .toSet();

    for (final recipe in recipes) {
      final matchResult = _analyzeRecipeMatch(recipe, availableIngredientNames);
      if (matchResult != null && matchResult.matchPercentage >= minMatchThreshold) {
        matches.add(matchResult);
      }
    }

    matches.sort((a, b) {
      final aScore = a.relevanceScore;
      final bScore = b.relevanceScore;
      if (aScore != bScore) {
        return bScore.compareTo(aScore);
      }
      return b.matchPercentage.compareTo(a.matchPercentage);
    });

    return matches.take(maxSuggestionsPerPage).toList();
  }

  IngredientRecipeMatch? _analyzeRecipeMatch(
    Recipe recipe,
    Set<String> availableIngredients,
  ) {
    final recipeIngredients = _extractRecipeIngredients(recipe);
    if (recipeIngredients.isEmpty) return null;

    final List<String> matchedIngredients = [];
    final List<String> missingIngredients = [];
    
    for (final recipeIngredient in recipeIngredients) {
      if (_hasMatchingIngredient(recipeIngredient, availableIngredients)) {
        matchedIngredients.add(recipeIngredient);
      } else {
        missingIngredients.add(recipeIngredient);
      }
    }

    final matchPercentage = matchedIngredients.length / recipeIngredients.length;
    
    final relevanceScore = _calculateRelevanceScore(
      recipe,
      matchPercentage,
      matchedIngredients.length,
      recipeIngredients.length,
    );

    return IngredientRecipeMatch(
      recipe: recipe,
      matchPercentage: matchPercentage,
      availableIngredients: matchedIngredients.length,
      totalIngredients: recipeIngredients.length,
      matchedIngredients: matchedIngredients,
      missingIngredients: missingIngredients,
      relevanceScore: relevanceScore,
    );
  }

  List<String> _extractRecipeIngredients(Recipe recipe) {
    // Use cache to avoid re-processing the same recipe
    final cacheKey = recipe.id;
    if (_recipeIngredientsCache.containsKey(cacheKey)) {
      return _recipeIngredientsCache[cacheKey]!;
    }
    
    final Set<String> ingredients = <String>{};

    if (recipe.ingredientSections.isNotEmpty) {
      for (final section in recipe.ingredientSections) {
        for (final ingredient in section.ingredients) {
          ingredients.add(ingredient.name.toLowerCase().trim());
        }
      }
    }

    if (recipe.ingredients.isNotEmpty) {
      for (final ingredient in recipe.ingredients) {
        ingredients.add(ingredient.name.toLowerCase().trim());
      }
    }

    if (recipe.legacyIngredients.isNotEmpty) {
      for (final ingredient in recipe.legacyIngredients) {
        final cleanIngredient = _extractIngredientName(ingredient);
        if (cleanIngredient.isNotEmpty) {
          ingredients.add(cleanIngredient);
        }
      }
    }

    final result = ingredients.toList();
    _recipeIngredientsCache[cacheKey] = result;
    return result;
  }

  String _extractIngredientName(String rawIngredient) {
    String cleaned = rawIngredient.toLowerCase().trim();
    
    final regex = RegExp(r'^\d+[\.\d]*\s*(?:cups?|tsp|tbsp|ml|l|g|kg|oz|lbs?|pieces?|whole|pinch|dash|to taste)?\s*(.+)$');
    final match = regex.firstMatch(cleaned);
    
    if (match != null) {
      cleaned = match.group(1) ?? cleaned;
    }

    cleaned = cleaned.replaceAll(RegExp(r'\([^)]*\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r',.*$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.trim();
    
    final modifiers = [
      'fresh', 'dried', 'ground', 'chopped', 'sliced', 'diced', 'minced',
      'grated', 'shredded', 'whole', 'raw', 'cooked', 'frozen', 'canned',
    ];
    
    for (final modifier in modifiers) {
      cleaned = cleaned.replaceAll(RegExp(r'\b' + modifier + r'\b'), '').trim();
      cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    }
    
    return cleaned.trim();
  }

  bool _hasMatchingIngredient(String recipeIngredient, Set<String> availableIngredients) {
    final normalized = _normalizeIngredientName(recipeIngredient);
    
    for (final available in availableIngredients) {
      final normalizedAvailable = _normalizeIngredientName(available);
      
      if (_ingredientsMatch(normalized, normalizedAvailable)) {
        return true;
      }
    }
    
    return false;
  }

  bool _ingredientsMatch(String ingredient1, String ingredient2) {
    if (ingredient1 == ingredient2) return true;
    
    if (_wordsMatch(ingredient1, ingredient2)) {
      return true;
    }
    
    if (_hasSubstitution(ingredient1, ingredient2)) {
      return true;
    }
    
    if (_hasFuzzyMatch(ingredient1, ingredient2)) {
      return true;
    }
    
    return false;
  }

  String _normalizeIngredientName(String ingredient) {
    // Use cache to avoid re-processing the same ingredient names
    if (_normalizedNameCache.containsKey(ingredient)) {
      return _normalizedNameCache[ingredient]!;
    }
    
    String normalized = ingredient.toLowerCase().trim();
    
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    
    final pluralMappings = {
      'bananas': 'banana',
      'potatoes': 'potato',
      'tomatoes': 'tomato',
      'onions': 'onion',
      'carrots': 'carrot',
      'eggs': 'egg',
      'cloves': 'clove',
      'leaves': 'leaf',
      'seeds': 'seed',
      'spices': 'spice',
    };
    
    for (final entry in pluralMappings.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }
    
    final result = normalized.trim();
    _normalizedNameCache[ingredient] = result;
    return result;
  }

  bool _wordsMatch(String ingredient1, String ingredient2) {
    final words1 = ingredient1.split(' ').where((w) => w.length > 2).toSet();
    final words2 = ingredient2.split(' ').where((w) => w.length > 2).toSet();
    
    if (words1.isEmpty || words2.isEmpty) return false;
    
    final intersection = words1.intersection(words2);
    final union = words1.union(words2);
    
    return intersection.isNotEmpty && (intersection.length / union.length) >= 0.5;
  }

  bool _hasSubstitution(String ingredient1, String ingredient2) {
    return _substitutionMap[ingredient1]?.contains(ingredient2) == true ||
           _substitutionMap[ingredient2]?.contains(ingredient1) == true;
  }

  bool _hasFuzzyMatch(String ingredient1, String ingredient2) {
    if (ingredient1.length < 4 || ingredient2.length < 4) return false;
    
    final distance = _levenshteinDistance(ingredient1, ingredient2);
    final maxLength = [ingredient1.length, ingredient2.length].reduce((a, b) => a > b ? a : b);
    
    return distance <= (maxLength * 0.3).round();
  }

  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (var i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= s1.length; i++) {
      for (var j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  double _calculateRelevanceScore(
    Recipe recipe,
    double matchPercentage,
    int matchedIngredientsCount,
    int totalIngredientsCount,
  ) {
    double score = matchPercentage;
    
    if (matchPercentage >= 0.9) {
      score += 0.2;
    } else if (matchPercentage >= 0.8) {
      score += 0.1;
    }
    
    if (matchedIngredientsCount >= 8) {
      score += 0.1;
    } else if (matchedIngredientsCount >= 5) {
      score += 0.05;
    }
    
    if (totalIngredientsCount <= 8) {
      score += 0.05;
    }
    
    final tagBonus = _calculateTagBonus(recipe.tags);
    score += tagBonus;
    
    return (score * 100).clamp(0.0, 100.0);
  }

  double _calculateTagBonus(List<String> tags) {
    double bonus = 0.0;
    
    final preferredTags = ['sri lankan', 'quick', 'easy', 'healthy'];
    final commonTags = ['leftovers', 'vegetarian', 'comfort food'];
    
    for (final tag in tags) {
      if (preferredTags.contains(tag.toLowerCase())) {
        bonus += 0.05;
      } else if (commonTags.contains(tag.toLowerCase())) {
        bonus += 0.02;
      }
    }
    
    return bonus.clamp(0.0, 0.15);
  }
}