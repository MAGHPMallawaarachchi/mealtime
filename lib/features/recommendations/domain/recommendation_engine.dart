import 'dart:math' as math;
import '../../../core/models/user_model.dart';
import '../../../core/models/user_interaction.dart';
import '../../../core/models/recommendation_score.dart';
import '../../recipes/domain/models/recipe.dart';
import '../../pantry/domain/models/pantry_item.dart';

class RecommendationEngine {
  Future<RecommendationBatch> generateRecommendations({
    required UserModel user,
    required List<Recipe> allRecipes,
    required List<PantryItem> pantryItems,
    InteractionSummary? interactionSummary,
    Map<String, dynamic>? context,
  }) async {
    if (!user.enableRecommendations) {
      return RecommendationBatch(
        recommendations: [],
        generatedAt: DateTime.now(),
        userId: user.uid,
        context: context ?? {},
      );
    }

    final recommendations = <RecommendationScore>[];

    final leftoverFirstEngine = LeftoverFirstEngine();
    final contentBasedEngine = ContentBasedEngine();
    final seasonalEngine = SeasonalEngine();
    final quickMealEngine = QuickMealEngine();

    for (final recipe in allRecipes) {
      final scores = <RecommendationType, double>{};
      final matchedPantryItems = <String>[];
      final matchedTags = <String>[];

      if (user.prioritizePantryItems) {
        final pantryScore = await leftoverFirstEngine.calculateScore(
          recipe: recipe,
          pantryItems: pantryItems,
          user: user,
        );
        scores[RecommendationType.pantryMatch] = pantryScore.score;
        matchedPantryItems.addAll(pantryScore.matchedItems);
      }

      final contentScore = await contentBasedEngine.calculateScore(
        recipe: recipe,
        user: user,
        interactionSummary: interactionSummary,
      );
      scores[RecommendationType.contentBased] = contentScore.score;
      matchedTags.addAll(contentScore.matchedTags);

      final seasonalScore = await seasonalEngine.calculateScore(
        recipe: recipe,
        user: user,
        currentDate: DateTime.now(),
      );
      scores[RecommendationType.seasonal] = seasonalScore.score;

      final quickMealScore = await quickMealEngine.calculateScore(
        recipe: recipe,
        context: context,
      );
      scores[RecommendationType.quickMeal] = quickMealScore.score;

      final totalScore = _calculateWeightedScore(scores, user);

      if (totalScore > 0.1) {
        recommendations.add(
          RecommendationScore(
            recipeId: recipe.id,
            totalScore: totalScore,
            componentScores: scores,
            reason: _generateReason(scores, matchedPantryItems, matchedTags),
            generatedAt: DateTime.now(),
            matchedPantryItems: matchedPantryItems,
            matchedTags: matchedTags,
          ),
        );
      }
    }

    recommendations.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return RecommendationBatch(
      recommendations: recommendations,
      generatedAt: DateTime.now(),
      userId: user.uid,
      context: context ?? {},
    );
  }

  double _calculateWeightedScore(
    Map<RecommendationType, double> scores,
    UserModel user,
  ) {
    final weights = <RecommendationType, double>{
      RecommendationType.pantryMatch: user.prioritizePantryItems ? 0.5 : 0.3,
      RecommendationType.contentBased: 0.3,
      RecommendationType.seasonal: 0.15,
      RecommendationType.quickMeal: 0.05,
    };

    double totalScore = 0.0;
    for (final entry in scores.entries) {
      final weight = weights[entry.key] ?? 0.0;
      totalScore += entry.value * weight;
    }

    return totalScore;
  }

  String _generateReason(
    Map<RecommendationType, double> scores,
    List<String> matchedPantryItems,
    List<String> matchedTags,
  ) {
    final primaryType = scores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    switch (primaryType) {
      case RecommendationType.pantryMatch:
        if (matchedPantryItems.isNotEmpty) {
          final items = matchedPantryItems.take(2).join(', ');
          return 'Perfect for your $items';
        }
        return 'Uses ingredients from your pantry';
      case RecommendationType.contentBased:
        if (matchedTags.isNotEmpty) {
          return 'Based on your preferences';
        }
        return 'Similar to your preferences';
      case RecommendationType.seasonal:
        return 'Perfect for this season';
      case RecommendationType.quickMeal:
        return 'Quick and easy';
      case RecommendationType.similar:
        return 'Similar to recipes you\'ve enjoyed';
      case RecommendationType.popular:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

class EngineScore {
  final double score;
  final List<String> matchedItems;
  final List<String> matchedTags;
  final String reason;

  const EngineScore({
    required this.score,
    this.matchedItems = const [],
    this.matchedTags = const [],
    this.reason = '',
  });
}

class LeftoverFirstEngine {
  Future<EngineScore> calculateScore({
    required Recipe recipe,
    required List<PantryItem> pantryItems,
    required UserModel user,
  }) async {
    if (pantryItems.isEmpty) return const EngineScore(score: 0.0);

    final pantryItemNames = pantryItems
        .map((item) => item.name.toLowerCase())
        .toSet();
    final matchedItems = <String>[];
    int totalIngredients = 0;

    for (final section in recipe.ingredientSections) {
      totalIngredients += section.ingredients.length;
      for (final ingredient in section.ingredients) {
        final ingredientName = ingredient.name.toLowerCase();

        for (final pantryName in pantryItemNames) {
          if (_isIngredientMatch(ingredientName, pantryName)) {
            matchedItems.add(pantryName);
            break;
          }
        }
      }
    }

    if (totalIngredients == 0) return const EngineScore(score: 0.0);

    final matchRatio = matchedItems.length / totalIngredients;

    double score = 0.0;
    if (matchedItems.isNotEmpty) {
      if (recipe.tags.contains('leftovers')) {
        score = matchRatio * 1.5; // Boost leftover recipes
      } else {
        score = matchRatio;
      }

      score = math.min(score, 1.0);
    }

    return EngineScore(
      score: score,
      matchedItems: matchedItems,
      reason: matchedItems.isNotEmpty
          ? 'Uses ${matchedItems.length} ingredients from your pantry'
          : '',
    );
  }

  bool _isIngredientMatch(String recipeIngredient, String pantryItem) {
    final recipe = recipeIngredient.toLowerCase().trim();
    final pantry = pantryItem.toLowerCase().trim();

    if (recipe == pantry) return true;
    if (recipe.contains(pantry) || pantry.contains(recipe)) return true;

    final commonSynonyms = {
      'onion': ['onions', 'yellow onion', 'white onion'],
      'tomato': ['tomatoes', 'fresh tomato'],
      'garlic': ['garlic cloves', 'fresh garlic'],
      'ginger': ['fresh ginger', 'ginger root'],
      'coconut': ['grated coconut', 'fresh coconut', 'dessicated coconut'],
      'rice': ['white rice', 'basmati rice', 'cooked rice'],
      'curry leaves': ['fresh curry leaves'],
      'chili': ['chilies', 'green chili', 'red chili'],
    };

    for (final entry in commonSynonyms.entries) {
      if ((recipe == entry.key || entry.value.contains(recipe)) &&
          (pantry == entry.key || entry.value.contains(pantry))) {
        return true;
      }
    }

    return false;
  }
}

class ContentBasedEngine {
  Future<EngineScore> calculateScore({
    required Recipe recipe,
    required UserModel user,
    InteractionSummary? interactionSummary,
  }) async {
    double score = 0.0;
    final matchedTags = <String>[];

    if (user.dietaryType != null) {
      score += _checkDietaryCompatibility(recipe, user.dietaryType!);
    }

    if (user.spicePreference != null) {
      score += _checkSpiceCompatibility(recipe, user.spicePreference!);
    }

    score += _checkRegionalPreferences(recipe, user.preferredRegions);

    if (user.allergens.isNotEmpty) {
      final allergenPenalty = _checkAllergens(recipe, user.allergens);
      score *=
          allergenPenalty; // Multiply to significantly reduce score if allergens present
    }

    if (interactionSummary != null) {
      score += _checkUserHistory(recipe, interactionSummary);

      for (final tag in recipe.tags) {
        if (interactionSummary.preferredCategories.contains(tag)) {
          matchedTags.add(tag);
        }
      }
    }

    return EngineScore(score: math.min(score, 1.0), matchedTags: matchedTags);
  }

  double _checkDietaryCompatibility(Recipe recipe, DietaryType dietaryType) {
    final tags = recipe.tags.map((t) => t.toLowerCase()).toList();

    switch (dietaryType) {
      case DietaryType.vegetarian:
        if (tags.contains('vegetarian') || tags.contains('vegan')) return 0.3;
        if (tags.any(
          (t) => ['meat', 'fish', 'seafood', 'chicken', 'beef'].contains(t),
        ))
          return -0.5;
        break;
      case DietaryType.vegan:
        if (tags.contains('vegan')) return 0.3;
        if (tags.any(
          (t) => ['meat', 'fish', 'dairy', 'eggs', 'seafood'].contains(t),
        ))
          return -0.5;
        break;
      case DietaryType.pescatarian:
        if (tags.contains('fish') || tags.contains('seafood')) return 0.2;
        if (tags.any((t) => ['meat', 'chicken', 'beef', 'pork'].contains(t)))
          return -0.5;
        break;
      case DietaryType.nonVegetarian:
        return 0.1; // Neutral for non-vegetarian
    }
    return 0.0;
  }

  double _checkSpiceCompatibility(
    Recipe recipe,
    SpicePreference spicePreference,
  ) {
    final tags = recipe.tags.map((t) => t.toLowerCase()).toList();

    switch (spicePreference) {
      case SpicePreference.mild:
        if (tags.contains('mild')) return 0.2;
        if (tags.contains('spicy') || tags.contains('hot')) return -0.3;
        break;
      case SpicePreference.medium:
        if (tags.contains('medium') || tags.contains('moderate')) return 0.2;
        break;
      case SpicePreference.spicy:
        if (tags.contains('spicy') || tags.contains('hot')) return 0.2;
        if (tags.contains('mild')) return -0.1;
        break;
    }
    return 0.0;
  }

  double _checkRegionalPreferences(
    Recipe recipe,
    List<SriLankanRegion> preferredRegions,
  ) {
    if (preferredRegions.isEmpty) return 0.0;

    final tags = recipe.tags.map((t) => t.toLowerCase()).toList();
    final regionTags = preferredRegions
        .map((r) => r.name.toLowerCase())
        .toList();

    for (final regionTag in regionTags) {
      if (tags.contains(regionTag) || tags.contains('$regionTag cuisine')) {
        return 0.25;
      }
    }

    return 0.0;
  }

  double _checkAllergens(Recipe recipe, List<Allergen> allergens) {
    final allergenTags = allergens.map((a) => a.name.toLowerCase()).toList();
    final recipeTags = recipe.tags.map((t) => t.toLowerCase()).toList();

    final problematicIngredients = {
      'dairy': ['milk', 'butter', 'cheese', 'yogurt', 'cream'],
      'eggs': ['egg', 'eggs'],
      'fishseafood': ['fish', 'seafood', 'shrimp', 'crab'],
      'nuts': ['nuts', 'peanut', 'almond', 'cashew'],
      'gluten': ['wheat', 'flour', 'bread'],
    };

    for (final allergen in allergenTags) {
      if (recipeTags.contains(allergen)) return 0.1; // Significant penalty

      final ingredients = problematicIngredients[allergen] ?? [];
      for (final ingredient in ingredients) {
        if (recipeTags.contains(ingredient)) return 0.1;

        for (final section in recipe.ingredientSections) {
          for (final recipeIngredient in section.ingredients) {
            if (recipeIngredient.name.toLowerCase().contains(ingredient)) {
              return 0.1;
            }
          }
        }
      }
    }

    return 1.0; // No penalty if no allergens detected
  }

  double _checkUserHistory(
    Recipe recipe,
    InteractionSummary interactionSummary,
  ) {
    double historyScore = 0.0;

    if (interactionSummary.mostViewedRecipes.contains(recipe.id)) {
      historyScore -= 0.2; // Slightly reduce score for already viewed recipes
    }

    // Don't recommend recipes they've already favorited
    if (interactionSummary.mostFavoritedRecipes.contains(recipe.id)) {
      historyScore -= 0.5; // Significantly reduce score for already favorited recipes
    }

    // Boost recipes similar to their favorited ones
    historyScore += _calculateSimilarityToFavorites(recipe, interactionSummary.mostFavoritedRecipes);

    return historyScore;
  }

  double _calculateSimilarityToFavorites(Recipe recipe, List<String> favoritedRecipeIds) {
    if (favoritedRecipeIds.isEmpty) return 0.0;

    // For now, we don't have access to favorited recipe details in this context
    // This would ideally compare tags, ingredients, cuisine types, etc.
    // As a simple implementation, we'll boost recipes that match common patterns
    double similarityScore = 0.0;

    // If user has favorited multiple recipes, look for common patterns
    if (favoritedRecipeIds.length >= 2) {
      // This is a placeholder - in a full implementation, you'd:
      // 1. Get the full Recipe objects for favoritedRecipeIds
      // 2. Analyze common tags, ingredients, cooking methods, etc.
      // 3. Score current recipe based on similarity to those patterns
      
      // For now, give a small boost to encourage some variety
      similarityScore += 0.1;
    }

    return similarityScore;
  }
}

class SeasonalEngine {
  Future<EngineScore> calculateScore({
    required Recipe recipe,
    required UserModel user,
    required DateTime currentDate,
  }) async {
    final season = _getCurrentSeason(currentDate);
    final seasonalTags = _getSeasonalTags(season);

    double score = 0.0;

    for (final tag in recipe.tags) {
      if (seasonalTags.contains(tag.toLowerCase())) {
        score += 0.3;
      }
    }

    // Check for seasonal ingredients in Sri Lankan context
    final seasonalIngredients = _getSeasonalIngredients(season);
    for (final section in recipe.ingredientSections) {
      for (final ingredient in section.ingredients) {
        if (seasonalIngredients.contains(ingredient.name.toLowerCase())) {
          score += 0.2;
        }
      }
    }

    return EngineScore(score: math.min(score, 1.0));
  }

  String _getCurrentSeason(DateTime date) {
    final month = date.month;
    // Sri Lankan seasons (simplified)
    if (month >= 3 && month <= 5) return 'dry'; // March-May: Hot/Dry season
    if (month >= 6 && month <= 9)
      return 'monsoon'; // June-September: Southwest monsoon
    if (month >= 10 && month <= 11)
      return 'intermonsoon'; // October-November: Inter-monsoon
    return 'northeast'; // December-February: Northeast monsoon
  }

  List<String> _getSeasonalTags(String season) {
    switch (season) {
      case 'dry':
        return ['cooling', 'refreshing', 'coconut', 'summer'];
      case 'monsoon':
        return ['warming', 'spicy', 'comfort-food', 'hot'];
      case 'intermonsoon':
        return ['light', 'fresh', 'vegetables'];
      case 'northeast':
        return ['warming', 'festive', 'comfort-food'];
      default:
        return [];
    }
  }

  List<String> _getSeasonalIngredients(String season) {
    switch (season) {
      case 'dry':
        return ['mango', 'pineapple', 'coconut water', 'cucumber'];
      case 'monsoon':
        return ['ginger', 'turmeric', 'cinnamon', 'pepper'];
      case 'intermonsoon':
        return ['green vegetables', 'leafy greens', 'beans'];
      case 'northeast':
        return ['root vegetables', 'yam', 'sweet potato'];
      default:
        return [];
    }
  }
}

class QuickMealEngine {
  Future<EngineScore> calculateScore({
    required Recipe recipe,
    Map<String, dynamic>? context,
  }) async {
    final timeOfDay = DateTime.now().hour;
    final isWeeknight = _isWeeknight();

    double score = 0.0;

    // Parse cooking time
    final cookingMinutes = _parseCookingTime(recipe.time);

    if (isWeeknight) {
      if (cookingMinutes <= 30) {
        score += 0.4;
      } else if (cookingMinutes <= 45) {
        score += 0.2;
      }
    }

    // Time-of-day context
    if (timeOfDay >= 17 && timeOfDay <= 20) {
      // Evening (5-8 PM)
      if (recipe.tags.contains('quick')) score += 0.3;
      if (recipe.tags.contains('weeknight')) score += 0.3;
    }

    // Tag-based scoring
    final quickTags = ['quick', 'easy', 'simple', '30-minute', 'weeknight'];
    for (final tag in recipe.tags) {
      if (quickTags.contains(tag.toLowerCase())) {
        score += 0.2;
      }
    }

    return EngineScore(score: math.min(score, 1.0));
  }

  bool _isWeeknight() {
    final now = DateTime.now();
    final weekday = now.weekday;
    return weekday >= 1 && weekday <= 5; // Monday to Friday
  }

  int _parseCookingTime(String timeString) {
    final regex = RegExp(r'(\d+)');
    final matches = regex.allMatches(timeString.toLowerCase());

    int totalMinutes = 0;

    for (final match in matches) {
      final number = int.parse(match.group(1)!);

      if (timeString.contains('hr') || timeString.contains('hour')) {
        totalMinutes += number * 60;
      } else {
        totalMinutes += number; // Assume minutes
      }
    }

    return totalMinutes > 0 ? totalMinutes : 30; // Default to 30 minutes
  }
}
