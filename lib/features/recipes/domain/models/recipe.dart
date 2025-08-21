import 'package:flutter/foundation.dart';

enum UnitSystem { cups, metric }

enum IngredientUnit {
  // Volume units
  cups,
  teaspoons,
  tablespoons,
  milliliters,
  liters,

  // Weight units
  grams,
  kilograms,
  ounces,
  pounds,

  // Count units
  pieces,
  whole,

  // Length units
  centimeter,

  // Other
  pinch,
  dash,
  toTaste,
}

class RecipeIngredient {
  final String id;
  final String name;
  final double quantity;
  final IngredientUnit? unit;
  final double? metricQuantity;
  final IngredientUnit? metricUnit;

  const RecipeIngredient({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit,
    this.metricQuantity,
    this.metricUnit,
  });

  RecipeIngredient copyWith({
    String? id,
    String? name,
    double? quantity,
    IngredientUnit? unit,
    double? metricQuantity,
    IngredientUnit? metricUnit,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      metricQuantity: metricQuantity ?? this.metricQuantity,
      metricUnit: metricUnit ?? this.metricUnit,
    );
  }

  RecipeIngredient scaledForServings(int newServings, int originalServings) {
    final scale = newServings / originalServings;
    return copyWith(
      quantity: quantity * scale,
      metricQuantity: metricQuantity != null ? metricQuantity! * scale : null,
    );
  }

  String getDisplayText(UnitSystem unitSystem) {
    if (unitSystem == UnitSystem.metric) {
      if (metricQuantity != null && metricUnit != null) {
        return '${_formatQuantity(metricQuantity!)} ${_getUnitText(metricUnit!)} $name';
      } else {
        // Try to convert automatically
        final converted = _convertToMetric();
        if (converted != null) {
          return '${_formatQuantity(converted.$1)} ${_getUnitText(converted.$2)} $name';
        }
      }
    }
    return '${_formatQuantity(quantity)}${unit != null ? ' ${_getUnitText(unit!)}' : ''} $name';
  }

  // Convert common US measurements to metric
  (double, IngredientUnit)? _convertToMetric() {
    if (unit == null) return null;
    switch (unit!) {
      case IngredientUnit.cups:
        return (quantity * 240, IngredientUnit.milliliters); // 1 cup = 240ml
      case IngredientUnit.teaspoons:
        return (quantity * 5, IngredientUnit.milliliters); // 1 tsp = 5ml
      case IngredientUnit.tablespoons:
        return (quantity * 15, IngredientUnit.milliliters); // 1 tbsp = 15ml
      case IngredientUnit.ounces:
        return (quantity * 28.35, IngredientUnit.grams); // 1 oz = 28.35g
      case IngredientUnit.pounds:
        return (quantity * 453.6, IngredientUnit.grams); // 1 lb = 453.6g
      default:
        return null; // No conversion available
    }
  }

  String _formatQuantity(double qty) {
    if (qty == qty.round()) {
      return qty.round().toString();
    }
    // Handle common fractions
    if ((qty * 4).round() / 4 == qty) {
      final whole = qty.floor();
      final frac = qty - whole;
      if (whole == 0) {
        if (frac == 0.25) return '¼';
        if (frac == 0.5) return '½';
        if (frac == 0.75) return '¾';
      } else {
        if (frac == 0.25) return '$whole ¼';
        if (frac == 0.5) return '$whole ½';
        if (frac == 0.75) return '$whole ¾';
      }
    }
    return qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 1);
  }

  String _getUnitText(IngredientUnit unit) {
    switch (unit) {
      case IngredientUnit.cups:
        return 'cups';
      case IngredientUnit.teaspoons:
        return 'tsp';
      case IngredientUnit.tablespoons:
        return 'tbsp';
      case IngredientUnit.milliliters:
        return 'ml';
      case IngredientUnit.liters:
        return 'L';
      case IngredientUnit.grams:
        return 'g';
      case IngredientUnit.kilograms:
        return 'kg';
      case IngredientUnit.ounces:
        return 'oz';
      case IngredientUnit.pounds:
        return 'lbs';
      case IngredientUnit.centimeter:
        return 'cm';
      case IngredientUnit.pieces:
        return 'pieces';
      case IngredientUnit.whole:
        return '';
      case IngredientUnit.pinch:
        return 'pinch';
      case IngredientUnit.dash:
        return 'dash';
      case IngredientUnit.toTaste:
        return 'to taste';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit?.name,
      'metricQuantity': metricQuantity,
      'metricUnit': metricUnit?.name,
    };
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown ingredient',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: _parseIngredientUnit(json['unit']),
      metricQuantity: json['metricQuantity'] != null
          ? (json['metricQuantity'] as num).toDouble()
          : null,
      metricUnit: json['metricUnit'] != null
          ? _parseIngredientUnit(json['metricUnit'])
          : null,
    );
  }

  static IngredientUnit? _parseIngredientUnit(dynamic unitValue) {
    if (unitValue == null) return null;

    final unitString = unitValue.toString().toLowerCase();
    try {
      return IngredientUnit.values.firstWhere(
        (e) => e.name.toLowerCase() == unitString,
      );
    } catch (e) {
      debugPrint(
        'RecipeIngredient: Unknown unit "$unitValue" (normalized: "$unitString"), returning null',
      );
      debugPrint(
        'RecipeIngredient: Available units: ${IngredientUnit.values.map((e) => e.name).join(', ')}',
      );
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeIngredient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class InstructionSection {
  final String id;
  final String title;
  final List<String> steps;

  const InstructionSection({
    required this.id,
    required this.title,
    required this.steps,
  });

  InstructionSection copyWith({
    String? id,
    String? title,
    List<String>? steps,
  }) {
    return InstructionSection(
      id: id ?? this.id,
      title: title ?? this.title,
      steps: steps ?? this.steps,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'steps': steps};
  }

  factory InstructionSection.fromJson(Map<String, dynamic> json) {
    return InstructionSection(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Instructions',
      steps: json['steps'] != null
          ? List<String>.from(json['steps'] as List)
          : [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InstructionSection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Recipe {
  final String id;
  final String title;
  final String time;
  final String imageUrl;
  final List<RecipeIngredient> ingredients;
  final List<String> legacyIngredients; // For backward compatibility
  final List<InstructionSection> instructionSections;
  final List<String> legacyInstructions; // For backward compatibility
  final int calories;
  final RecipeMacros macros;
  final String? description;
  final int defaultServings;
  final List<String> tags;
  final String? source;

  const Recipe({
    required this.id,
    required this.title,
    required this.time,
    required this.imageUrl,
    required this.ingredients,
    required this.instructionSections,
    required this.calories,
    required this.macros,
    this.description,
    this.defaultServings = 4,
    this.legacyIngredients = const [],
    this.legacyInstructions = const [],
    this.tags = const [],
    this.source,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? time,
    String? imageUrl,
    List<RecipeIngredient>? ingredients,
    List<InstructionSection>? instructionSections,
    int? calories,
    RecipeMacros? macros,
    String? description,
    int? defaultServings,
    List<String>? legacyIngredients,
    List<String>? legacyInstructions,
    List<String>? tags,
    String? source,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      instructionSections: instructionSections ?? this.instructionSections,
      calories: calories ?? this.calories,
      macros: macros ?? this.macros,
      description: description ?? this.description,
      defaultServings: defaultServings ?? this.defaultServings,
      legacyIngredients: legacyIngredients ?? this.legacyIngredients,
      legacyInstructions: legacyInstructions ?? this.legacyInstructions,
      tags: tags ?? this.tags,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'imageUrl': imageUrl,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'instructionSections': instructionSections
          .map((e) => e.toJson())
          .toList(),
      'calories': calories,
      'macros': macros.toJson(),
      'description': description,
      'defaultServings': defaultServings,
      'legacyIngredients': legacyIngredients,
      'legacyInstructions': legacyInstructions,
      'tags': tags,
      'source': source,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Handle both new and legacy formats for backward compatibility
    final ingredientsList = json['ingredients'] as List?;
    final instructionsList = json['instructions'] as List?;
    final instructionSectionsList = json['instructionSections'] as List?;

    List<RecipeIngredient> ingredients = [];
    List<String> legacyIngredients = [];

    if (ingredientsList != null && ingredientsList.isNotEmpty) {
      try {
        if (ingredientsList.first is Map) {
          // New format with RecipeIngredient objects
          ingredients = ingredientsList
              .where((e) => e is Map<String, dynamic>)
              .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          // Legacy format with strings
          legacyIngredients = List<String>.from(ingredientsList);
        }
      } catch (e) {
        debugPrint('Recipe.fromJson: Error parsing ingredients: $e');
        // Fall back to empty lists
        ingredients = [];
        legacyIngredients = [];
      }
    }

    List<InstructionSection> instructionSections = [];
    List<String> legacyInstructions = [];

    try {
      if (instructionSectionsList != null &&
          instructionSectionsList.isNotEmpty) {
        // New format with InstructionSection objects
        instructionSections = instructionSectionsList
            .where((e) => e is Map<String, dynamic>)
            .map((e) => InstructionSection.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (instructionsList != null && instructionsList.isNotEmpty) {
        // Legacy format with strings
        legacyInstructions = List<String>.from(instructionsList);
      }
    } catch (e) {
      debugPrint('Recipe.fromJson: Error parsing instructions: $e');
      // Fall back to empty lists
      instructionSections = [];
      legacyInstructions = [];
    }

    return Recipe(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Recipe',
      time: json['time'] as String? ?? '30 min',
      imageUrl: json['imageUrl'] as String? ?? '',
      ingredients: ingredients,
      instructionSections: instructionSections,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      macros: json['macros'] != null
          ? RecipeMacros.fromJson(json['macros'] as Map<String, dynamic>)
          : const RecipeMacros(protein: 0, carbs: 0, fats: 0, fiber: 0),
      description: json['description'] as String?,
      defaultServings: () {
        final servings = (json['defaultServings'] as num?)?.toInt() ?? 4;
        debugPrint(
          'Recipe ${json['id']}: defaultServings from JSON = ${json['defaultServings']}, parsed = $servings',
        );
        return servings;
      }(),
      legacyIngredients: legacyIngredients,
      legacyInstructions: legacyInstructions,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : const [],
      source: json['source'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods for backward compatibility
  List<String> get instructionsAsList {
    if (legacyInstructions.isNotEmpty) {
      return legacyInstructions;
    }

    List<String> allInstructions = [];
    for (final section in instructionSections) {
      allInstructions.addAll(section.steps);
    }
    return allInstructions;
  }

  List<String> get ingredientsAsList {
    if (legacyIngredients.isNotEmpty) {
      return legacyIngredients;
    }

    return ingredients
        .map((ingredient) => ingredient.getDisplayText(UnitSystem.cups))
        .toList();
  }

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
    return {'protein': protein, 'carbs': carbs, 'fats': fats, 'fiber': fiber};
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
