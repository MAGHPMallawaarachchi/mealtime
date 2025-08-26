import '../../../recipes/domain/models/recipe.dart';

enum DifficultyLevel { easy, medium, hard }

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  String get emoji {
    switch (this) {
      case DifficultyLevel.easy:
        return '👶';
      case DifficultyLevel.medium:
        return '👨';
      case DifficultyLevel.hard:
        return '👨‍🍳';
    }
  }
}

class UserRecipe {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String prepTime;
  final String cookTime;
  final String totalTime;
  final int servings;
  final DifficultyLevel difficulty;
  final List<RecipeIngredient> ingredients;
  final List<IngredientSection> ingredientSections;
  final List<InstructionSection> instructionSections;
  final List<String> tags;
  final String? imageUrl;
  final double? calories;
  final double? protein;
  final double? carbohydrates;
  final double? fats;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;

  const UserRecipe({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.prepTime,
    required this.cookTime,
    required this.totalTime,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.ingredientSections,
    required this.instructionSections,
    required this.tags,
    this.imageUrl,
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fats,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
  });

  UserRecipe copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? prepTime,
    String? cookTime,
    String? totalTime,
    int? servings,
    DifficultyLevel? difficulty,
    List<RecipeIngredient>? ingredients,
    List<IngredientSection>? ingredientSections,
    List<InstructionSection>? instructionSections,
    List<String>? tags,
    String? imageUrl,
    double? calories,
    double? protein,
    double? carbohydrates,
    double? fats,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
  }) {
    return UserRecipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      totalTime: totalTime ?? this.totalTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      ingredients: ingredients ?? this.ingredients,
      ingredientSections: ingredientSections ?? this.ingredientSections,
      instructionSections: instructionSections ?? this.instructionSections,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fats: fats ?? this.fats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  Recipe toRecipe() {
    return Recipe(
      id: id,
      title: title,
      time: totalTime,
      imageUrl: imageUrl ?? '',
      ingredients: ingredients,
      ingredientSections: ingredientSections,
      instructionSections: instructionSections,
      calories: calories?.toInt() ?? 0,
      macros: RecipeMacros(
        protein: protein ?? 0,
        carbs: carbohydrates ?? 0,
        fats: fats ?? 0,
        fiber: 0,
      ),
      description: description,
      defaultServings: servings,
      tags: tags,
      source: 'User Created',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'totalTime': totalTime,
      'servings': servings,
      'difficulty': difficulty.name,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'ingredientSections': ingredientSections.map((e) => e.toJson()).toList(),
      'instructionSections': instructionSections
          .map((e) => e.toJson())
          .toList(),
      'tags': tags,
      'imageUrl': imageUrl,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fats': fats,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPublic': isPublic,
    };
  }

  factory UserRecipe.fromJson(Map<String, dynamic> json) {
    return UserRecipe(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Recipe',
      description: json['description'] as String?,
      prepTime: json['prepTime'] as String? ?? '0 min',
      cookTime: json['cookTime'] as String? ?? '0 min',
      totalTime: json['totalTime'] as String? ?? '0 min',
      servings: (json['servings'] as num?)?.toInt() ?? 4,
      difficulty: _parseDifficulty(json['difficulty']),
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
                .where((e) => e is Map<String, dynamic>)
                .map(
                  (e) => RecipeIngredient.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
      ingredientSections: json['ingredientSections'] != null
          ? (json['ingredientSections'] as List)
                .where((e) => e is Map<String, dynamic>)
                .map(
                  (e) => IngredientSection.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
      instructionSections: json['instructionSections'] != null
          ? (json['instructionSections'] as List)
                .where((e) => e is Map<String, dynamic>)
                .map(
                  (e) => InstructionSection.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      imageUrl: json['imageUrl'] as String?,
      calories: json['calories'] != null
          ? (json['calories'] as num).toDouble()
          : null,
      protein: json['protein'] != null
          ? (json['protein'] as num).toDouble()
          : null,
      carbohydrates: json['carbohydrates'] != null
          ? (json['carbohydrates'] as num).toDouble()
          : null,
      fats: json['fats'] != null ? (json['fats'] as num).toDouble() : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      isPublic: json['isPublic'] as bool? ?? false,
    );
  }

  static DifficultyLevel _parseDifficulty(dynamic difficulty) {
    if (difficulty == null) return DifficultyLevel.medium;

    try {
      return DifficultyLevel.values.firstWhere(
        (e) => e.name == difficulty.toString(),
      );
    } catch (e) {
      return DifficultyLevel.medium;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserRecipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserRecipe(id: $id, title: $title, userId: $userId, servings: $servings)';
  }
}
