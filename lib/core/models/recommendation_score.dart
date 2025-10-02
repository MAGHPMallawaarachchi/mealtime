import 'package:flutter/foundation.dart';

enum RecommendationType {
  pantryMatch,
  contentBased,
  seasonal,
  quickMeal,
  popular,
  similar,
}

class RecommendationScore {
  final String recipeId;
  final double totalScore;
  final Map<RecommendationType, double> componentScores;
  final String reason;
  final DateTime generatedAt;
  final List<String> matchedPantryItems;
  final List<String> matchedTags;

  const RecommendationScore({
    required this.recipeId,
    required this.totalScore,
    required this.componentScores,
    required this.reason,
    required this.generatedAt,
    this.matchedPantryItems = const [],
    this.matchedTags = const [],
  });

  RecommendationScore copyWith({
    String? recipeId,
    double? totalScore,
    Map<RecommendationType, double>? componentScores,
    String? reason,
    DateTime? generatedAt,
    List<String>? matchedPantryItems,
    List<String>? matchedTags,
  }) {
    return RecommendationScore(
      recipeId: recipeId ?? this.recipeId,
      totalScore: totalScore ?? this.totalScore,
      componentScores: componentScores ?? this.componentScores,
      reason: reason ?? this.reason,
      generatedAt: generatedAt ?? this.generatedAt,
      matchedPantryItems: matchedPantryItems ?? this.matchedPantryItems,
      matchedTags: matchedTags ?? this.matchedTags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'totalScore': totalScore,
      'componentScores': componentScores.map((key, value) => MapEntry(key.name, value)),
      'reason': reason,
      'generatedAt': generatedAt.toIso8601String(),
      'matchedPantryItems': matchedPantryItems,
      'matchedTags': matchedTags,
    };
  }

  factory RecommendationScore.fromJson(Map<String, dynamic> json) {
    final componentScoresMap = <RecommendationType, double>{};
    final rawComponentScores = json['componentScores'] as Map<String, dynamic>?;
    
    if (rawComponentScores != null) {
      for (final entry in rawComponentScores.entries) {
        try {
          final type = RecommendationType.values.firstWhere(
            (e) => e.name == entry.key,
          );
          componentScoresMap[type] = (entry.value as num).toDouble();
        } catch (e) {
          // Skip invalid component scores
        }
      }
    }

    return RecommendationScore(
      recipeId: json['recipeId'] as String? ?? '',
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      componentScores: componentScoresMap,
      reason: json['reason'] as String? ?? '',
      generatedAt: json['generatedAt'] != null 
          ? DateTime.parse(json['generatedAt'] as String)
          : DateTime.now(),
      matchedPantryItems: json['matchedPantryItems'] != null
          ? List<String>.from(json['matchedPantryItems'] as List)
          : const [],
      matchedTags: json['matchedTags'] != null
          ? List<String>.from(json['matchedTags'] as List)
          : const [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendationScore &&
        other.recipeId == recipeId &&
        other.totalScore == totalScore &&
        mapEquals(other.componentScores, componentScores) &&
        other.reason == reason &&
        other.generatedAt == generatedAt &&
        listEquals(other.matchedPantryItems, matchedPantryItems) &&
        listEquals(other.matchedTags, matchedTags);
  }

  @override
  int get hashCode {
    return Object.hash(
      recipeId,
      totalScore,
      Object.hashAll(componentScores.entries),
      reason,
      generatedAt,
      Object.hashAll(matchedPantryItems),
      Object.hashAll(matchedTags),
    );
  }

  @override
  String toString() {
    return 'RecommendationScore(recipeId: $recipeId, totalScore: $totalScore, reason: $reason, generatedAt: $generatedAt)';
  }

  RecommendationType get primaryReason {
    if (componentScores.isEmpty) return RecommendationType.popular;
    
    return componentScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  bool get isStale {
    final now = DateTime.now();
    final ageInHours = now.difference(generatedAt).inHours;
    
    switch (primaryReason) {
      case RecommendationType.pantryMatch:
        return ageInHours > 4; // Refresh pantry-based recommendations every 4 hours
      case RecommendationType.seasonal:
        return ageInHours > 24; // Refresh seasonal recommendations daily
      case RecommendationType.contentBased:
      case RecommendationType.similar:
        return ageInHours > 12; // Refresh content-based recommendations every 12 hours
      case RecommendationType.quickMeal:
      case RecommendationType.popular:
        return ageInHours > 8; // Refresh quick meals and popular recommendations every 8 hours
    }
  }
}

class RecommendationBatch {
  final List<RecommendationScore> recommendations;
  final DateTime generatedAt;
  final String userId;
  final Map<String, dynamic> context;

  const RecommendationBatch({
    required this.recommendations,
    required this.generatedAt,
    required this.userId,
    this.context = const {},
  });

  List<RecommendationScore> get topRecommendations => 
      recommendations.take(10).toList();

  List<RecommendationScore> getByType(RecommendationType type) =>
      recommendations.where((r) => r.primaryReason == type).toList();

  List<RecommendationScore> get pantryBasedRecommendations =>
      getByType(RecommendationType.pantryMatch);

  List<RecommendationScore> get contentBasedRecommendations =>
      getByType(RecommendationType.contentBased);

  List<RecommendationScore> get seasonalRecommendations =>
      getByType(RecommendationType.seasonal);

  List<RecommendationScore> get quickMealRecommendations =>
      getByType(RecommendationType.quickMeal);

  bool get isStale {
    if (recommendations.isEmpty) return true;
    return recommendations.any((r) => r.isStale);
  }

  RecommendationBatch copyWith({
    List<RecommendationScore>? recommendations,
    DateTime? generatedAt,
    String? userId,
    Map<String, dynamic>? context,
  }) {
    return RecommendationBatch(
      recommendations: recommendations ?? this.recommendations,
      generatedAt: generatedAt ?? this.generatedAt,
      userId: userId ?? this.userId,
      context: context ?? this.context,
    );
  }
}