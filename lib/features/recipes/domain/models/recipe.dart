class Recipe {
  final String id;
  final String title;
  final String time;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final int calories;
  final RecipeMacros macros;
  final String? description;

  const Recipe({
    required this.id,
    required this.title,
    required this.time,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.calories,
    required this.macros,
    this.description,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? time,
    String? imageUrl,
    List<String>? ingredients,
    List<String>? instructions,
    int? calories,
    RecipeMacros? macros,
    String? description,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      calories: calories ?? this.calories,
      macros: macros ?? this.macros,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'calories': calories,
      'macros': macros.toJson(),
      'description': description,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      time: json['time'] as String,
      imageUrl: json['imageUrl'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      instructions: List<String>.from(json['instructions'] as List),
      calories: json['calories'] as int,
      macros: RecipeMacros.fromJson(json['macros'] as Map<String, dynamic>),
      description: json['description'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Recipe(id: $id, title: $title, time: $time, calories: $calories)';
  }
}

class RecipeMacros {
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;

  const RecipeMacros({
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
  });

  RecipeMacros copyWith({
    double? protein,
    double? carbs,
    double? fats,
    double? fiber,
  }) {
    return RecipeMacros(
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      fiber: fiber ?? this.fiber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
    };
  }

  factory RecipeMacros.fromJson(Map<String, dynamic> json) {
    return RecipeMacros(
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeMacros &&
        other.protein == protein &&
        other.carbs == carbs &&
        other.fats == fats &&
        other.fiber == fiber;
  }

  @override
  int get hashCode => Object.hash(protein, carbs, fats, fiber);

  @override
  String toString() {
    return 'RecipeMacros(protein: ${protein}g, carbs: ${carbs}g, fats: ${fats}g, fiber: ${fiber}g)';
  }
}