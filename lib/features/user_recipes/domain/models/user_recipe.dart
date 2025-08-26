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
  final String time;
  final int defaultServings;
  final List<RecipeIngredient> ingredients;
  final List<IngredientSection> ingredientSections;
  final List<InstructionSection> instructionSections;
  final List<String> tags;
  final String? imageUrl;
  final int calories;
  final RecipeMacros macros;
  final String? source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;

  const UserRecipe({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.time,
    required this.defaultServings,
    required this.ingredients,
    required this.ingredientSections,
    required this.instructionSections,
    required this.tags,
    this.imageUrl,
    this.calories = 0,
    required this.macros,
    this.source,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
  });

  UserRecipe copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? time,
    int? defaultServings,
    DifficultyLevel? difficulty,
    List<RecipeIngredient>? ingredients,
    List<IngredientSection>? ingredientSections,
    List<InstructionSection>? instructionSections,
    List<String>? tags,
    String? imageUrl,
    int? calories,
    RecipeMacros? macros,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
  }) {
    return UserRecipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      defaultServings: defaultServings ?? this.defaultServings,
      ingredients: ingredients ?? this.ingredients,
      ingredientSections: ingredientSections ?? this.ingredientSections,
      instructionSections: instructionSections ?? this.instructionSections,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      macros: macros ?? this.macros,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  Recipe toRecipe() {
    return Recipe(
      id: id,
      title: title,
      time: time,
      imageUrl: imageUrl ?? '',
      ingredients: ingredients,
      ingredientSections: ingredientSections,
      instructionSections: instructionSections,
      calories: calories,
      macros: macros,
      description: description,
      defaultServings: defaultServings,
      tags: tags,
      source: source ?? 'User Created',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'time': time,
      'defaultServings': defaultServings,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'ingredientSections': ingredientSections.map((e) => e.toJson()).toList(),
      'instructionSections': instructionSections
          .map((e) => e.toJson())
          .toList(),
      'tags': tags,
      'imageUrl': imageUrl,
      'calories': calories,
      'macros': macros.toJson(),
      'source': source,
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
      time: json['time'] as String? ?? '30 min',
      defaultServings: (json['defaultServings'] as num?)?.toInt() ?? 4,
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
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      macros: json['macros'] != null
          ? RecipeMacros.fromJson(json['macros'] as Map<String, dynamic>)
          : const RecipeMacros(protein: 0, carbs: 0, fats: 0, fiber: 0),
      source: json['source'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      isPublic: json['isPublic'] as bool? ?? false,
    );
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
    return 'UserRecipe(id: $id, title: $title, userId: $userId, defaultServings: $defaultServings)';
  }
}
