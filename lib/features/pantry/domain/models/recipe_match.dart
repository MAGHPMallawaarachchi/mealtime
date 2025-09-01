import '../../../recipes/domain/models/recipe.dart';
import '../../../user_recipes/domain/models/user_recipe.dart';

enum MatchType { complete, partial, minimal }

class RecipeMatch {
  final String recipeId;
  final String title;
  final String imageUrl;
  final String time;
  final int calories;
  final MatchType matchType;
  final int availableIngredients;
  final int totalIngredients;
  final double matchPercentage;
  final List<String> availableIngredientNames;
  final List<String> missingIngredientNames;
  final bool isUserRecipe;
  final String? source;

  const RecipeMatch({
    required this.recipeId,
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.calories,
    required this.matchType,
    required this.availableIngredients,
    required this.totalIngredients,
    required this.matchPercentage,
    required this.availableIngredientNames,
    required this.missingIngredientNames,
    required this.isUserRecipe,
    this.source,
  });

  factory RecipeMatch.fromRecipe({
    required Recipe recipe,
    required List<String> availableIngredientNames,
    required List<String> missingIngredientNames,
    required List<String> pantryIngredients,
  }) {
    final totalIngredients = recipe.ingredients.isNotEmpty
        ? recipe.ingredients.length
        : recipe.legacyIngredients.length;

    final availableCount = availableIngredientNames.length;
    final matchPercentage = totalIngredients > 0
        ? (availableCount / totalIngredients) * 100
        : 0.0;

    final matchType = _determineMatchType(matchPercentage);

    return RecipeMatch(
      recipeId: recipe.id,
      title: recipe.title,
      imageUrl: recipe.imageUrl,
      time: recipe.time,
      calories: recipe.calories,
      matchType: matchType,
      availableIngredients: availableCount,
      totalIngredients: totalIngredients,
      matchPercentage: matchPercentage,
      availableIngredientNames: availableIngredientNames,
      missingIngredientNames: missingIngredientNames,
      isUserRecipe: false,
      source: recipe.source,
    );
  }

  factory RecipeMatch.fromUserRecipe({
    required UserRecipe userRecipe,
    required List<String> availableIngredientNames,
    required List<String> missingIngredientNames,
    required List<String> pantryIngredients,
  }) {
    final totalIngredients = userRecipe.ingredientSections.isNotEmpty
        ? userRecipe.ingredientSections.fold<int>(
            0,
            (sum, section) => sum + section.ingredients.length,
          )
        : userRecipe.ingredients.length;

    final availableCount = availableIngredientNames.length;
    final matchPercentage = totalIngredients > 0
        ? (availableCount / totalIngredients) * 100
        : 0.0;

    final matchType = _determineMatchType(matchPercentage);

    return RecipeMatch(
      recipeId: userRecipe.id,
      title: userRecipe.title,
      imageUrl: userRecipe.imageUrl ?? '',
      time: userRecipe.time,
      calories: userRecipe.calories,
      matchType: matchType,
      availableIngredients: availableCount,
      totalIngredients: totalIngredients,
      matchPercentage: matchPercentage,
      availableIngredientNames: availableIngredientNames,
      missingIngredientNames: missingIngredientNames,
      isUserRecipe: true,
    );
  }

  static MatchType _determineMatchType(double percentage) {
    if (percentage >= 90.0) {
      return MatchType.complete;
    } else if (percentage >= 60.0) {
      return MatchType.partial;
    } else {
      return MatchType.minimal;
    }
  }

  RecipeMatch copyWith({
    String? recipeId,
    String? title,
    String? imageUrl,
    String? time,
    int? calories,
    MatchType? matchType,
    int? availableIngredients,
    int? totalIngredients,
    double? matchPercentage,
    List<String>? availableIngredientNames,
    List<String>? missingIngredientNames,
    bool? isUserRecipe,
    String? source,
  }) {
    return RecipeMatch(
      recipeId: recipeId ?? this.recipeId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      time: time ?? this.time,
      calories: calories ?? this.calories,
      matchType: matchType ?? this.matchType,
      availableIngredients: availableIngredients ?? this.availableIngredients,
      totalIngredients: totalIngredients ?? this.totalIngredients,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      availableIngredientNames:
          availableIngredientNames ?? this.availableIngredientNames,
      missingIngredientNames:
          missingIngredientNames ?? this.missingIngredientNames,
      isUserRecipe: isUserRecipe ?? this.isUserRecipe,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeMatch && other.recipeId == recipeId;
  }

  @override
  int get hashCode => recipeId.hashCode;

  @override
  String toString() {
    return 'RecipeMatch(recipeId: $recipeId, title: $title, matchType: $matchType, percentage: ${matchPercentage.toStringAsFixed(1)}%)';
  }
}

// Extension for better match type display
extension MatchTypeExtension on MatchType {
  String get displayName {
    switch (this) {
      case MatchType.complete:
        return 'Complete Match';
      case MatchType.partial:
        return 'Good Match';
      case MatchType.minimal:
        return 'Few Ingredients';
    }
  }

  String get description {
    switch (this) {
      case MatchType.complete:
        return 'You have all or almost all ingredients!';
      case MatchType.partial:
        return 'You have most ingredients needed';
      case MatchType.minimal:
        return 'You have some key ingredients';
    }
  }
}
