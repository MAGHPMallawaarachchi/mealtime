import 'package:mealtime/core/services/localization_service.dart';

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
  final String name; // Used for algorithms/processing (non-localized)
  final Map<String, String>? localizedName; // Localized ingredient names
  final double quantity;
  final IngredientUnit? unit;
  final double? metricQuantity;
  final IngredientUnit? metricUnit;

  const RecipeIngredient({
    required this.id,
    required this.name,
    required this.quantity,
    this.localizedName,
    this.unit,
    this.metricQuantity,
    this.metricUnit,
  });

  RecipeIngredient copyWith({
    String? id,
    String? name,
    Map<String, String>? localizedName,
    double? quantity,
    IngredientUnit? unit,
    double? metricQuantity,
    IngredientUnit? metricUnit,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      name: name ?? this.name,
      localizedName: localizedName ?? this.localizedName,
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

  String getDisplayText(UnitSystem unitSystem, [String? locale]) {
    final localizedIngredientName = getLocalizedName(locale ?? 'en');

    if (unitSystem == UnitSystem.metric) {
      if (metricQuantity != null && metricUnit != null) {
        return '${_formatQuantity(metricQuantity!)} ${_getUnitText(metricUnit!)} $localizedIngredientName';
      } else {
        // Try to convert automatically
        final converted = _convertToMetric();
        if (converted != null) {
          return '${_formatQuantity(converted.$1)} ${_getUnitText(converted.$2)} $localizedIngredientName';
        }
      }
    }
    return '${_formatQuantity(quantity)}${unit != null ? ' ${_getUnitText(unit!)}' : ''} $localizedIngredientName';
  }

  /// Get localized ingredient name with fallback strategy
  String getLocalizedName(String locale) {
    if (localizedName != null) {
      // Try the requested locale first
      if (localizedName!.containsKey(locale)) {
        final localizedText = localizedName![locale];
        if (localizedText != null && localizedText.trim().isNotEmpty) {
          return localizedText;
        }
      }

      // Fall back to English
      if (localizedName!.containsKey('en')) {
        final englishText = localizedName!['en'];
        if (englishText != null && englishText.trim().isNotEmpty) {
          return englishText;
        }
      }
    }

    // Ultimate fallback to base name
    return name;
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
    try {
      final localization = LocalizationService.instance;
      switch (unit) {
        case IngredientUnit.cups:
          return localization.cupsUnit;
        case IngredientUnit.teaspoons:
          return localization.tspUnit;
        case IngredientUnit.tablespoons:
          return localization.tbspUnit;
        case IngredientUnit.milliliters:
          return localization.mlUnit;
        case IngredientUnit.liters:
          return localization.lUnit;
        case IngredientUnit.grams:
          return localization.gUnit;
        case IngredientUnit.kilograms:
          return localization.kgUnit;
        case IngredientUnit.ounces:
          return localization.ozUnit;
        case IngredientUnit.pounds:
          return localization.lbsUnit;
        case IngredientUnit.centimeter:
          return localization.cmUnit;
        case IngredientUnit.pieces:
          return localization.pcsUnit;
        case IngredientUnit.whole:
          return localization.wholeUnit;
        case IngredientUnit.pinch:
          return localization.pinchUnit;
        case IngredientUnit.dash:
          return localization.dashUnit;
        case IngredientUnit.toTaste:
          return localization.toTasteUnit;
      }
    } catch (e) {
      // Fallback to English if localization fails
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
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'localizedName': localizedName,
      'quantity': quantity,
      'unit': unit?.name,
      'metricQuantity': metricQuantity,
      'metricUnit': metricUnit?.name,
    };
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    // Handle both new localized format and legacy string/map format
    dynamic nameData = json['name'];
    String baseName;
    Map<String, String>? localizedNameMap;

    try {
      if (nameData is Map<String, dynamic>) {
        // New localized format: "name": {"en": "...", "si": "..."}
        localizedNameMap = Map<String, String>.from(nameData);
        // Use English as base name, fallback to first available
        baseName = localizedNameMap['en'] ?? localizedNameMap.values.first;
      } else if (nameData is Map) {
        // Handle generic Map type (not specifically String, dynamic)
        localizedNameMap = <String, String>{};
        nameData.forEach((key, value) {
          if (key is String && value is String) {
            localizedNameMap![key] = value;
          }
        });
        baseName = localizedNameMap['en'] ?? localizedNameMap.values.first;
      } else {
        // Legacy format: "name": "ingredient name"
        baseName = nameData ?? 'Unknown ingredient';
        // Check for separate localizedName field
        final localizedNameData = json['localizedName'];
        if (localizedNameData is Map<String, dynamic>) {
          localizedNameMap = Map<String, String>.from(localizedNameData);
        } else if (localizedNameData is Map) {
          localizedNameMap = <String, String>{};
          localizedNameData.forEach((key, value) {
            if (key is String && value is String) {
              localizedNameMap![key] = value;
            }
          });
        }
      }
    } catch (e) {
      // Fallback in case of any parsing error
      baseName = nameData?.toString() ?? 'Unknown ingredient';
      localizedNameMap = null;
    }

    return RecipeIngredient(
      id: json['id'] ?? '',
      name: baseName,
      localizedName: localizedNameMap,
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

    final unitString = unitValue.toString().toLowerCase().trim();

    // Try exact match first
    try {
      return IngredientUnit.values.firstWhere(
        (e) => e.name.toLowerCase() == unitString,
      );
    } catch (e) {
      // Exact match failed, try normalized variations
    }

    // Handle common unit variations and abbreviations
    final normalized = _normalizeUnit(unitString);
    if (normalized != null) {
      try {
        return IngredientUnit.values.firstWhere(
          (e) => e.name.toLowerCase() == normalized,
        );
      } catch (e) {
        // Still no match
      }
    }

    return null;
  }

  static String? _normalizeUnit(String unit) {
    final unitLower = unit.toLowerCase().trim();

    // Handle plural/singular variations
    final pluralToSingular = {
      'cup': 'cups',
      'teaspoon': 'teaspoons',
      'tablespoon': 'tablespoons',
      'milliliter': 'milliliters',
      'liter': 'liters',
      'gram': 'grams',
      'kilogram': 'kilograms',
      'ounce': 'ounces',
      'pound': 'pounds',
      'piece': 'pieces',
      'centimeter': 'centimeter',
    };

    // Handle abbreviations
    final abbreviations = {
      'tsp': 'teaspoons',
      'tbsp': 'tablespoons',
      'tbsps': 'tablespoons',
      'ml': 'milliliters',
      'l': 'liters',
      'g': 'grams',
      'kg': 'kilograms',
      'oz': 'ounces',
      'lb': 'pounds',
      'lbs': 'pounds',
      'cm': 'centimeter',
    };

    // Check abbreviations first
    if (abbreviations.containsKey(unitLower)) {
      return abbreviations[unitLower];
    }

    // Check plural to singular mapping
    if (pluralToSingular.containsKey(unitLower)) {
      return pluralToSingular[unitLower];
    }

    // Check if it's already in the correct plural form
    if (IngredientUnit.values.any((e) => e.name.toLowerCase() == unitLower)) {
      return unitLower;
    }

    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeIngredient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class IngredientSection {
  final String id;
  final String title;
  final List<RecipeIngredient> ingredients;

  const IngredientSection({
    required this.id,
    required this.title,
    required this.ingredients,
  });

  IngredientSection copyWith({
    String? id,
    String? title,
    List<RecipeIngredient>? ingredients,
  }) {
    return IngredientSection(
      id: id ?? this.id,
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
    };
  }

  factory IngredientSection.fromJson(Map<String, dynamic> json) {
    return IngredientSection(
      id: json['id'] ?? '',
      title: json['title'] is String ? json['title'] : 'Ingredients',
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
                .where((e) => e is Map<String, dynamic>)
                .map(
                  (e) => RecipeIngredient.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IngredientSection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class InstructionSection {
  final String id;
  final String title;
  final List<String> steps; // Used for processing (non-localized, fallback)
  final Map<String, List<String>>? localizedSteps; // Localized steps

  const InstructionSection({
    required this.id,
    required this.title,
    required this.steps,
    this.localizedSteps,
  });

  InstructionSection copyWith({
    String? id,
    String? title,
    List<String>? steps,
    Map<String, List<String>>? localizedSteps,
  }) {
    return InstructionSection(
      id: id ?? this.id,
      title: title ?? this.title,
      steps: steps ?? this.steps,
      localizedSteps: localizedSteps ?? this.localizedSteps,
    );
  }

  /// Get localized steps with fallback strategy
  List<String> getLocalizedSteps(String locale) {
    if (localizedSteps != null) {
      // Try the requested locale first
      if (localizedSteps!.containsKey(locale)) {
        final localizedText = localizedSteps![locale];
        if (localizedText != null && localizedText.isNotEmpty) {
          return localizedText;
        }
      }

      // Fall back to English
      if (localizedSteps!.containsKey('en')) {
        final englishText = localizedSteps!['en'];
        if (englishText != null && englishText.isNotEmpty) {
          return englishText;
        }
      }
    }

    // Ultimate fallback to base steps
    return steps;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'steps': steps,
      'localizedSteps': localizedSteps,
    };
  }

  factory InstructionSection.fromJson(Map<String, dynamic> json) {
    // Handle both new localized format and legacy format
    dynamic stepsData = json['steps'];
    List<String> baseSteps = [];
    Map<String, List<String>>? localizedStepsMap;

    try {
      if (stepsData is List) {
        // Check if it's a list of localized objects or simple strings
        if (stepsData.isNotEmpty && stepsData.first is Map) {
          // New localized format: "steps": [{"en": "...", "si": "..."}, ...]
          final Map<String, List<String>> tempMap = {};
          for (final stepObj in stepsData) {
            if (stepObj is Map<String, dynamic>) {
              stepObj.forEach((locale, text) {
                if (locale is String && text is String) {
                  tempMap.putIfAbsent(locale, () => []).add(text);
                }
              });
            } else if (stepObj is Map) {
              // Handle generic Map type
              stepObj.forEach((locale, text) {
                if (locale is String && text is String) {
                  tempMap.putIfAbsent(locale, () => []).add(text);
                }
              });
            }
          }
          localizedStepsMap = tempMap;
          // Use English as base steps, fallback to first available
          if (tempMap.containsKey('en')) {
            baseSteps = tempMap['en']!;
          } else if (tempMap.isNotEmpty) {
            baseSteps = tempMap.values.first;
          }
        } else {
          // Legacy format: "steps": ["step1", "step2", ...]
          baseSteps = stepsData
              .where((step) => step is String)
              .map<String>((step) => step)
              .toList();
        }
      }

      // Check for separate localizedSteps field (backward compatibility)
      final localizedStepsData = json['localizedSteps'];
      if (localizedStepsData is Map<String, dynamic>) {
        localizedStepsMap ??= {};
        localizedStepsData.forEach((locale, steps) {
          if (steps is List) {
            localizedStepsMap![locale] = steps
                .where((step) => step is String)
                .map<String>((step) => step)
                .toList();
          }
        });
      } else if (localizedStepsData is Map) {
        localizedStepsMap ??= {};
        localizedStepsData.forEach((locale, steps) {
          if (locale is String && steps is List) {
            localizedStepsMap![locale] = steps
                .where((step) => step is String)
                .map<String>((step) => step)
                .toList();
          }
        });
      }
    } catch (e) {
      // Fallback in case of any parsing error
      baseSteps = [];
      localizedStepsMap = null;
    }

    return InstructionSection(
      id: json['id'] ?? '',
      title: json['title'] is String ? json['title'] : 'Instructions',
      steps: baseSteps,
      localizedSteps: localizedStepsMap,
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
  final String title; // Used for algorithms/recommendations (non-localized)
  final Map<String, String>?
  localizedTitle; // Localized titles {"en": "...", "si": "..."}
  final String time;
  final String imageUrl;
  final List<RecipeIngredient> ingredients;
  final List<String> legacyIngredients; // For backward compatibility
  final List<IngredientSection> ingredientSections;
  final List<InstructionSection> instructionSections;
  final List<String> legacyInstructions; // For backward compatibility
  final int calories;
  final RecipeMacros macros;
  final String?
  description; // Used for algorithms/recommendations (non-localized)
  final Map<String, String>? localizedDescription; // Localized descriptions
  final int defaultServings;
  final List<String> tags;
  final String? source;
  final String? dietaryType;

  const Recipe({
    required this.id,
    required this.title,
    required this.time,
    required this.imageUrl,
    required this.ingredients,
    required this.instructionSections,
    required this.calories,
    required this.macros,
    this.localizedTitle,
    this.description,
    this.localizedDescription,
    this.defaultServings = 4,
    this.ingredientSections = const [],
    this.legacyIngredients = const [],
    this.legacyInstructions = const [],
    this.tags = const [],
    this.source,
    this.dietaryType,
  });

  Recipe copyWith({
    String? id,
    String? title,
    Map<String, String>? localizedTitle,
    String? time,
    String? imageUrl,
    List<RecipeIngredient>? ingredients,
    List<IngredientSection>? ingredientSections,
    List<InstructionSection>? instructionSections,
    int? calories,
    RecipeMacros? macros,
    String? description,
    Map<String, String>? localizedDescription,
    int? defaultServings,
    List<String>? legacyIngredients,
    List<String>? legacyInstructions,
    List<String>? tags,
    String? source,
    String? dietaryType,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      localizedTitle: localizedTitle ?? this.localizedTitle,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      ingredientSections: ingredientSections ?? this.ingredientSections,
      instructionSections: instructionSections ?? this.instructionSections,
      calories: calories ?? this.calories,
      macros: macros ?? this.macros,
      description: description ?? this.description,
      localizedDescription: localizedDescription ?? this.localizedDescription,
      defaultServings: defaultServings ?? this.defaultServings,
      legacyIngredients: legacyIngredients ?? this.legacyIngredients,
      legacyInstructions: legacyInstructions ?? this.legacyInstructions,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      dietaryType: dietaryType ?? this.dietaryType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'localizedTitle': localizedTitle,
      'time': time,
      'imageUrl': imageUrl,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'ingredientSections': ingredientSections.map((e) => e.toJson()).toList(),
      'instructionSections': instructionSections
          .map((e) => e.toJson())
          .toList(),
      'calories': calories,
      'macros': macros.toJson(),
      'description': description,
      'localizedDescription': localizedDescription,
      'defaultServings': defaultServings,
      'legacyIngredients': legacyIngredients,
      'legacyInstructions': legacyInstructions,
      'tags': tags,
      'source': source,
      'dietaryType': dietaryType,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Handle both new and legacy formats for backward compatibility
    final ingredientsList = json['ingredients'] as List?;
    final ingredientSectionsList = json['ingredientSections'] as List?;
    final instructionsList = json['instructions'] as List?;
    final instructionSectionsList = json['instructionSections'] as List?;

    List<RecipeIngredient> ingredients = [];
    List<String> legacyIngredients = [];
    List<IngredientSection> ingredientSections = [];

    // Parse ingredient sections first (preferred format)
    if (ingredientSectionsList != null && ingredientSectionsList.isNotEmpty) {
      try {
        ingredientSections = ingredientSectionsList
            .where((e) => e is Map<String, dynamic>)
            .map((e) => IngredientSection.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        ingredientSections = [];
      }
    }

    // Parse flat ingredients list for backward compatibility
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
      // Fall back to empty lists
      instructionSections = [];
      legacyInstructions = [];
    }

    // Parse localized fields
    final localizedTitleMap = json['localizedTitle'];
    final localizedDescriptionMap = json['localizedDescription'];

    return Recipe(
      id: json['id'] ?? '',
      title: json['title'] is String ? json['title'] : 'Untitled Recipe',
      localizedTitle: localizedTitleMap is Map<String, dynamic>
          ? Map<String, String>.from(localizedTitleMap)
          : null,
      time: json['time'] is String ? json['time'] : '30 min',
      imageUrl: json['imageUrl'] is String ? json['imageUrl'] : '',
      ingredients: ingredients,
      ingredientSections: ingredientSections,
      instructionSections: instructionSections,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      macros: json['macros'] != null
          ? RecipeMacros.fromJson(json['macros'] as Map<String, dynamic>)
          : const RecipeMacros(protein: 0, carbs: 0, fats: 0, fiber: 0),
      description: json['description'] is String ? json['description'] : null,
      localizedDescription: localizedDescriptionMap is Map<String, dynamic>
          ? Map<String, String>.from(localizedDescriptionMap)
          : null,
      defaultServings: () {
        final servings = (json['defaultServings'] as num?)?.toInt() ?? 4;
        return servings;
      }(),
      legacyIngredients: legacyIngredients,
      legacyInstructions: legacyInstructions,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : const [],
      source: json['source'] is String ? json['source'] : null,
      dietaryType: json['dietaryType'] is String ? json['dietaryType'] : null,
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

  /// Check if this recipe has valid ingredients for grocery list generation
  bool get hasValidIngredientsForGroceryList {
    // Check structured ingredients
    if (ingredients.isNotEmpty) {
      return ingredients.any(
        (ingredient) =>
            ingredient.name.trim().isNotEmpty && ingredient.quantity > 0,
      );
    }

    // Check legacy ingredients
    if (legacyIngredients.isNotEmpty) {
      return legacyIngredients.any(
        (ingredient) => ingredient.trim().isNotEmpty,
      );
    }

    // Check ingredient sections (for recipes that use sectioned ingredients)
    if (ingredientSections.isNotEmpty) {
      return ingredientSections.any(
        (section) => section.ingredients.any(
          (ingredient) =>
              ingredient.name.trim().isNotEmpty && ingredient.quantity > 0,
        ),
      );
    }

    return false;
  }

  /// Get count of valid ingredients that can be used for grocery lists
  int get validIngredientsCount {
    int count = 0;

    // Count structured ingredients
    for (final ingredient in ingredients) {
      if (ingredient.name.trim().isNotEmpty && ingredient.quantity > 0) {
        count++;
      }
    }

    // Count legacy ingredients
    for (final ingredient in legacyIngredients) {
      if (ingredient.trim().isNotEmpty) {
        count++;
      }
    }

    // Count ingredients in sections
    for (final section in ingredientSections) {
      for (final ingredient in section.ingredients) {
        if (ingredient.name.trim().isNotEmpty && ingredient.quantity > 0) {
          count++;
        }
      }
    }

    return count;
  }

  /// Get localized title with fallback strategy
  /// 1. Try to get title for the specified locale
  /// 2. Fall back to English if specified locale is not available
  /// 3. Fall back to the base title field if no localized titles exist
  String getLocalizedTitle(String locale) {
    if (localizedTitle != null) {
      // Try the requested locale first
      if (localizedTitle!.containsKey(locale)) {
        final localizedText = localizedTitle![locale];
        if (localizedText != null && localizedText.trim().isNotEmpty) {
          return localizedText;
        }
      }

      // Fall back to English
      if (localizedTitle!.containsKey('en')) {
        final englishText = localizedTitle!['en'];
        if (englishText != null && englishText.trim().isNotEmpty) {
          return englishText;
        }
      }
    }

    // Ultimate fallback to base title
    return title;
  }

  /// Get localized description with fallback strategy
  String? getLocalizedDescription(String locale) {
    if (localizedDescription != null) {
      // Try the requested locale first
      if (localizedDescription!.containsKey(locale)) {
        final localizedText = localizedDescription![locale];
        if (localizedText != null && localizedText.trim().isNotEmpty) {
          return localizedText;
        }
      }

      // Fall back to English
      if (localizedDescription!.containsKey('en')) {
        final englishText = localizedDescription!['en'];
        if (englishText != null && englishText.trim().isNotEmpty) {
          return englishText;
        }
      }
    }

    // Ultimate fallback to base description
    return description;
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
