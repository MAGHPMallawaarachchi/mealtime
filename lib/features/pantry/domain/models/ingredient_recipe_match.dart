import '../../../recipes/domain/models/recipe.dart';

class IngredientRecipeMatch {
  final Recipe recipe;
  final double matchPercentage;
  final int availableIngredients;
  final int totalIngredients;
  final List<String> matchedIngredients;
  final List<String> missingIngredients;
  final double relevanceScore;

  const IngredientRecipeMatch({
    required this.recipe,
    required this.matchPercentage,
    required this.availableIngredients,
    required this.totalIngredients,
    required this.matchedIngredients,
    required this.missingIngredients,
    required this.relevanceScore,
  });

  IngredientRecipeMatch copyWith({
    Recipe? recipe,
    double? matchPercentage,
    int? availableIngredients,
    int? totalIngredients,
    List<String>? matchedIngredients,
    List<String>? missingIngredients,
    double? relevanceScore,
  }) {
    return IngredientRecipeMatch(
      recipe: recipe ?? this.recipe,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      availableIngredients: availableIngredients ?? this.availableIngredients,
      totalIngredients: totalIngredients ?? this.totalIngredients,
      matchedIngredients: matchedIngredients ?? this.matchedIngredients,
      missingIngredients: missingIngredients ?? this.missingIngredients,
      relevanceScore: relevanceScore ?? this.relevanceScore,
    );
  }

  bool get isFullMatch => availableIngredients == totalIngredients;
  
  bool get isHighMatch => matchPercentage >= 0.8;
  
  bool get isMediumMatch => matchPercentage >= 0.6;

  MatchLevel get matchLevel {
    if (isFullMatch) return MatchLevel.perfect;
    if (isHighMatch) return MatchLevel.high;
    if (isMediumMatch) return MatchLevel.medium;
    return MatchLevel.low;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IngredientRecipeMatch && other.recipe.id == recipe.id;
  }

  @override
  int get hashCode => recipe.id.hashCode;

  @override
  String toString() {
    return 'IngredientRecipeMatch(recipe: ${recipe.title}, matchPercentage: $matchPercentage, availableIngredients: $availableIngredients/$totalIngredients)';
  }
}

enum MatchLevel {
  perfect,
  high,
  medium,
  low,
}

extension MatchLevelExtension on MatchLevel {
  String get displayName {
    switch (this) {
      case MatchLevel.perfect:
        return 'Perfect Match';
      case MatchLevel.high:
        return 'Great Match';
      case MatchLevel.medium:
        return 'Good Match';
      case MatchLevel.low:
        return 'Partial Match';
    }
  }

  String get emoji {
    switch (this) {
      case MatchLevel.perfect:
        return '🎯';
      case MatchLevel.high:
        return '⭐';
      case MatchLevel.medium:
        return '👍';
      case MatchLevel.low:
        return '💡';
    }
  }
}