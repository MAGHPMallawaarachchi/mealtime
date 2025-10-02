import '../../../recipes/domain/models/recipe.dart';
import '../../../recipes/domain/repositories/recipes_repository.dart';
import '../models/weekly_meal_plan.dart';
import '../models/meal_slot.dart';
import '../models/grocery_list.dart';
import '../models/grocery_item.dart';

class GenerateGroceryListUseCase {
  final RecipesRepository _recipesRepository;

  GenerateGroceryListUseCase(this._recipesRepository);

  Future<GroceryList> execute(WeeklyMealPlan weekPlan) async {
    final Map<String, GroceryItem> aggregatedIngredients = {};
    final List<RecipeProcessingResult> processingResults = [];
    
    // Debug: Count different types of meals
    int daysWithMeals = 0;
    int totalScheduledMeals = 0;
    int mealsWithRecipes = 0;
    int mealsWithoutRecipes = 0;

    // Process each day in the week
    for (final dayPlan in weekPlan.dailyPlans) {
      if (dayPlan.scheduledMeals.isNotEmpty) {
        daysWithMeals++;
      }
      
      // Process all scheduled (non-empty) meals
      for (final mealSlot in dayPlan.scheduledMeals) {
        totalScheduledMeals++;
        
        if (mealSlot.recipeId != null) {
          mealsWithRecipes++;
          final result = await _processRecipe(
            mealSlot,
            aggregatedIngredients,
          );
          processingResults.add(result);
        } else {
          mealsWithoutRecipes++;
        }
      }
    }

    final groceryItems = aggregatedIngredients.values.toList();
    
    // Analyze processing results for detailed error reporting
    final errors = processingResults.where((r) => r.hasError).toList();
    final warnings = processingResults.where((r) => r.hasWarning).toList();
    final successful = processingResults.where((r) => r.isSuccessful).toList();
    
    // If no items but there are meals with recipes, provide detailed error info
    if (groceryItems.isEmpty && mealsWithRecipes > 0) {
      final errorMessages = <String>[];
      
      // Add summary
      errorMessages.add('Found $totalScheduledMeals scheduled meals ($mealsWithRecipes with recipes, $mealsWithoutRecipes without recipes) across $daysWithMeals days, but no grocery items were generated.');
      
      // Add specific error details
      if (errors.isNotEmpty) {
        errorMessages.add('\nErrors encountered:');
        for (final error in errors) {
          errorMessages.add('• ${error.mealName}: ${error.error}');
        }
      }
      
      if (warnings.isNotEmpty) {
        errorMessages.add('\nWarnings:');
        for (final warning in warnings) {
          errorMessages.add('• ${warning.mealName}: ${warning.warning}');
        }
      }
      
      if (successful.isNotEmpty) {
        errorMessages.add('\nSuccessfully processed:');
        for (final success in successful) {
          errorMessages.add('• ${success.mealName} (${success.ingredientsProcessed} ingredients)');
        }
      }
      
      if (mealsWithoutRecipes > 0) {
        errorMessages.add('\nNote: $mealsWithoutRecipes meals without recipes were skipped. Only meals with recipes can generate grocery items.');
      }
      
      throw GenerateGroceryListException(errorMessages.join('\n'));
    }
    
    return GroceryList.create(
      weekStart: weekPlan.weekStartDate,
      items: groceryItems,
    );
  }

  Future<RecipeProcessingResult> _processRecipe(
    MealSlot mealSlot,
    Map<String, GroceryItem> aggregatedIngredients,
  ) async {
    try {
      final recipe = await _recipesRepository.getRecipe(mealSlot.recipeId!);
      if (recipe == null) {
        return RecipeProcessingResult.error(
          mealSlotId: mealSlot.id,
          mealName: mealSlot.displayName,
          recipeId: mealSlot.recipeId!,
          error: 'Recipe not found',
        );
      }

      // Check if recipe has valid ingredients for grocery list generation
      if (!recipe.hasValidIngredientsForGroceryList) {
        // Provide a more detailed error message with potential solutions
        String detailMessage;
        if (recipe.ingredients.isEmpty && recipe.legacyIngredients.isEmpty && recipe.ingredientSections.isEmpty) {
          detailMessage = 'Recipe "${recipe.title}" has no ingredients data at all';
        } else if (recipe.ingredients.isNotEmpty || recipe.ingredientSections.isNotEmpty) {
          detailMessage = 'Recipe "${recipe.title}" has ${recipe.ingredients.length} structured ingredients and ${recipe.ingredientSections.length} ingredient sections, but none have valid names/quantities';
        } else {
          detailMessage = 'Recipe "${recipe.title}" has ${recipe.legacyIngredients.length} legacy ingredients, but they are all empty';
        }
        
        // As a fallback, create a generic grocery item for the recipe
        final fallbackItem = GroceryItem(
          ingredientName: 'Ingredients for ${recipe.title}',
          quantity: 1,
          unit: 'recipe',
          category: 'Recipe Ingredients',
          displayName: 'Ingredients for ${recipe.title}',
        );
        
        final ingredientKey = 'recipe_${recipe.id}';
        aggregatedIngredients[ingredientKey] = fallbackItem;
        
        return RecipeProcessingResult.warning(
          mealSlotId: mealSlot.id,
          mealName: mealSlot.displayName,
          recipeId: mealSlot.recipeId!,
          warning: '$detailMessage (Added generic ingredient item as fallback)',
        );
      }

      final scalingFactor = _calculateScalingFactor(
        recipeServings: recipe.defaultServings,
        mealServings: mealSlot.servingSize,
      );

      int ingredientsProcessed = 0;

      // Process new-style structured ingredients
      for (final ingredient in recipe.ingredients) {
        await _addIngredientToList(
          ingredient,
          scalingFactor,
          aggregatedIngredients,
        );
        ingredientsProcessed++;
      }

      // Process ingredients from ingredient sections
      for (final section in recipe.ingredientSections) {
        for (final ingredient in section.ingredients) {
          await _addIngredientToList(
            ingredient,
            scalingFactor,
            aggregatedIngredients,
          );
          ingredientsProcessed++;
        }
      }

      // Process legacy string ingredients if any
      for (final legacyIngredient in recipe.legacyIngredients) {
        _addLegacyIngredientToList(
          legacyIngredient,
          aggregatedIngredients,
        );
        ingredientsProcessed++;
      }

      return RecipeProcessingResult.success(
        mealSlotId: mealSlot.id,
        mealName: mealSlot.displayName,
        recipeId: mealSlot.recipeId!,
        recipeTitle: recipe.title,
        ingredientsProcessed: ingredientsProcessed,
      );
    } catch (e) {
      return RecipeProcessingResult.error(
        mealSlotId: mealSlot.id,
        mealName: mealSlot.displayName,
        recipeId: mealSlot.recipeId!,
        error: 'Failed to fetch recipe: ${e.toString()}',
      );
    }
  }

  double _calculateScalingFactor({
    required int recipeServings,
    required int mealServings,
  }) {
    if (recipeServings <= 0) return 1.0;
    return mealServings / recipeServings;
  }

  Future<void> _addIngredientToList(
    RecipeIngredient ingredient,
    double scalingFactor,
    Map<String, GroceryItem> aggregatedIngredients,
  ) async {
    // Try to get metric quantity and unit, fall back to original
    double quantity;
    String unit;
    
    if (ingredient.metricQuantity != null && ingredient.metricUnit != null) {
      quantity = ingredient.metricQuantity! * scalingFactor;
      unit = _getUnitString(ingredient.metricUnit!);
    } else {
      // Try to convert to metric using our own conversion
      final metricConversion = _convertToMetric(ingredient.quantity, ingredient.unit);
      if (metricConversion != null) {
        quantity = metricConversion.$1 * scalingFactor;
        unit = _getUnitString(metricConversion.$2);
      } else {
        // Fall back to original units
        quantity = ingredient.quantity * scalingFactor;
        unit = ingredient.unit != null ? _getUnitString(ingredient.unit!) : 'item';
      }
    }
    
    // Convert to preferred unit for the ingredient category to avoid duplicates
    final category = _categorizeIngredient(ingredient.name);
    final (convertedQuantity, preferredUnit) = _convertToPreferredUnit(quantity, unit, category, ingredient.name);
    
    // Create aggregation key using normalized ingredient name and preferred unit
    final normalizedName = _normalizeIngredientName(ingredient.name);
    final ingredientKey = '${normalizedName}_$preferredUnit';
    
    if (aggregatedIngredients.containsKey(ingredientKey)) {
      // Add to existing ingredient
      final existingItem = aggregatedIngredients[ingredientKey]!;
      print('🔄 CONSOLIDATING: ${ingredient.name} ($quantity$unit) + existing ${existingItem.quantity}${existingItem.unit} = ${(existingItem.quantity + convertedQuantity).toStringAsFixed(1)}$preferredUnit');
      aggregatedIngredients[ingredientKey] = existingItem.addQuantity(convertedQuantity);
    } else {
      // Create new grocery item with preferred unit
      print('➕ ADDING NEW: ${ingredient.name} → $normalizedName ($convertedQuantity$preferredUnit) [key: $ingredientKey]');
      final groceryItem = GroceryItem(
        ingredientName: ingredient.name,
        quantity: convertedQuantity,
        unit: preferredUnit,
        category: category,
        displayName: ingredient.name,
      );
      aggregatedIngredients[ingredientKey] = groceryItem;
    }
  }

  void _addLegacyIngredientToList(
    String legacyIngredient,
    Map<String, GroceryItem> aggregatedIngredients,
  ) {
    // For legacy ingredients, just add them as uncategorized text items
    final ingredientKey = 'legacy_${legacyIngredient.toLowerCase()}';
    
    if (!aggregatedIngredients.containsKey(ingredientKey)) {
      final groceryItem = GroceryItem(
        ingredientName: legacyIngredient,
        quantity: 1,
        unit: 'item',
        category: 'Other',
        displayName: legacyIngredient,
      );
      aggregatedIngredients[ingredientKey] = groceryItem;
    }
  }

  // Convert common US measurements to metric
  (double, IngredientUnit)? _convertToMetric(double quantity, IngredientUnit? unit) {
    if (unit == null) return null;
    switch (unit) {
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

  String _getUnitString(IngredientUnit unit) {
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
        return 'item';
      case IngredientUnit.pinch:
        return 'pinch';
      case IngredientUnit.dash:
        return 'dash';
      case IngredientUnit.toTaste:
        return 'to taste';
    }
  }

  String _normalizeUnitForAggregation(String unit) {
    // Normalize similar units for aggregation
    switch (unit.toLowerCase()) {
      case 'ml':
      case 'milliliters':
        return 'ml';
      case 'l':
      case 'liters':
        return 'L';
      case 'g':
      case 'grams':
        return 'g';
      case 'kg':
      case 'kilograms':
        return 'kg';
      case 'tsp':
      case 'teaspoons':
        return 'tsp';
      case 'tbsp':
      case 'tablespoons':
        return 'tbsp';
      case 'cups':
        return 'cups';
      case 'pieces':
        return 'pieces';
      case 'item':
      case 'whole':
        return 'item';
      default:
        return unit.toLowerCase();
    }
  }

  // Convert ingredients to their preferred units to prevent duplicates
  (double, String) _convertToPreferredUnit(double quantity, String unit, String category, String ingredientName) {
    final normalizedUnit = unit.toLowerCase();
    final ingredientLower = ingredientName.toLowerCase();
    
    // Determine preferred unit based on ingredient type and category
    String preferredUnit = _getPreferredUnit(category, ingredientLower);
    
    // If already in preferred unit, return as-is
    if (_normalizeUnitForAggregation(normalizedUnit) == _normalizeUnitForAggregation(preferredUnit)) {
      return (quantity, preferredUnit);
    }
    
    // Convert between weight and volume for specific ingredients that can be measured both ways
    if (_canConvertBetweenWeightVolume(ingredientLower)) {
      final converted = _convertBetweenWeightAndVolume(quantity, normalizedUnit, preferredUnit, ingredientLower);
      if (converted != null) {
        return converted;
      }
    }
    
    // If no conversion is possible or appropriate, use preferred unit anyway
    // This ensures ingredients aggregate properly even without unit conversion
    return (quantity, preferredUnit);
  }
  
  // Determine preferred unit for each category and ingredient type
  String _getPreferredUnit(String category, String ingredientName) {
    switch (category) {
      case 'Vegetables':
      case 'Fruits':
        // Fresh produce typically measured by weight
        return _isTypicallyLiquid(ingredientName) ? 'ml' : 'g';
        
      case 'Meat & Fish':
        return 'g'; // Always weight for proteins
        
      case 'Dairy':
        // Dairy products - liquids in ml, solids in g
        return _isTypicallyLiquid(ingredientName) ? 'ml' : 'g';
        
      case 'Oils & Condiments':
        return 'ml'; // Mostly liquids
        
      case 'Grains & Rice':
        return 'g'; // Dry goods by weight
        
      case 'Spices':
        return 'g'; // Small amounts by weight
        
      default:
        // For uncategorized items, check if it's liquid
        return _isTypicallyLiquid(ingredientName) ? 'ml' : 'item';
    }
  }
  
  // Check if an ingredient is typically liquid
  bool _isTypicallyLiquid(String ingredientName) {
    const liquidIngredients = [
      'milk', 'cream', 'water', 'oil', 'vinegar', 'sauce', 'syrup',
      'honey', 'juice', 'wine', 'broth', 'stock', 'coconut milk',
      'coconut cream', 'coconut water'
    ];
    return liquidIngredients.any((liquid) => ingredientName.contains(liquid));
  }
  
  // Check if we can convert between weight and volume for specific ingredients
  bool _canConvertBetweenWeightVolume(String ingredientName) {
    // Only allow conversion for ingredients where weight-volume relationship is well-known
    const convertibleIngredients = [
      'milk', 'water', 'cream', 'coconut milk', 'coconut cream',
      'oil', 'honey', 'syrup'
    ];
    return convertibleIngredients.any((ingredient) => ingredientName.contains(ingredient));
  }
  
  // Convert between weight and volume for specific ingredients
  (double, String)? _convertBetweenWeightAndVolume(double quantity, String fromUnit, String toUnit, String ingredientName) {
    final fromUnitNorm = _normalizeUnitForAggregation(fromUnit);
    final toUnitNorm = _normalizeUnitForAggregation(toUnit);
    
    // Get density factor for the ingredient (approximate)
    double? densityFactor = _getIngredientDensity(ingredientName);
    if (densityFactor == null) return null;
    
    double convertedQuantity = quantity;
    
    // Convert from weight to volume (g/kg → ml/L)
    if ((fromUnitNorm == 'g' || fromUnitNorm == 'kg') && (toUnitNorm == 'ml' || toUnitNorm == 'L')) {
      if (fromUnitNorm == 'kg') convertedQuantity *= 1000; // kg to g
      convertedQuantity = convertedQuantity / densityFactor; // g to ml
      if (toUnitNorm == 'L') convertedQuantity /= 1000; // ml to L
      return (convertedQuantity, toUnit);
    }
    
    // Convert from volume to weight (ml/L → g/kg)
    if ((fromUnitNorm == 'ml' || fromUnitNorm == 'L') && (toUnitNorm == 'g' || toUnitNorm == 'kg')) {
      if (fromUnitNorm == 'L') convertedQuantity *= 1000; // L to ml
      convertedQuantity = convertedQuantity * densityFactor; // ml to g
      if (toUnitNorm == 'kg') convertedQuantity /= 1000; // g to kg
      return (convertedQuantity, toUnit);
    }
    
    return null;
  }
  
  // Get approximate density for common ingredients (g/ml)
  double? _getIngredientDensity(String ingredientName) {
    // Approximate densities in g/ml
    if (ingredientName.contains('water')) return 1.0;
    if (ingredientName.contains('milk')) return 1.03;
    if (ingredientName.contains('cream')) return 1.0;
    if (ingredientName.contains('coconut milk')) return 0.95;
    if (ingredientName.contains('coconut cream')) return 0.9;
    if (ingredientName.contains('oil')) return 0.9;
    if (ingredientName.contains('honey')) return 1.4;
    if (ingredientName.contains('syrup')) return 1.3;
    return null;
  }

  // Normalize ingredient names to handle variations and ensure proper aggregation
  String _normalizeIngredientName(String ingredientName) {
    String normalized = ingredientName.toLowerCase().trim();
    
    // Remove common variations and standardize names
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' '); // Multiple spaces to single
    normalized = normalized.replaceAll(RegExp(r'[,\-\(\)]'), ''); // Remove punctuation
    
    // Standardize common ingredient variations
    if (normalized.contains('coconut milk')) return 'coconut milk';
    if (normalized.contains('coconut oil')) return 'coconut oil';
    if (normalized.contains('coconut water')) return 'coconut water';
    if (normalized.contains('coconut cream')) return 'coconut cream';
    if (normalized.contains('olive oil')) return 'olive oil';
    if (normalized.contains('vegetable oil')) return 'vegetable oil';
    if (normalized.contains('sunflower oil')) return 'sunflower oil';
    if (normalized.contains('sesame oil')) return 'sesame oil';
    
    // Remove articles and common modifiers for better aggregation
    normalized = normalized.replaceAll(RegExp(r'^(the|a|an)\s+'), '');
    normalized = normalized.replaceAll(RegExp(r'\s+(fresh|frozen|dried|raw|cooked)$'), '');
    
    return normalized;
  }

  String _categorizeIngredient(String ingredientName) {
    final name = ingredientName.toLowerCase();
    
    // Check specific product rules first (most specific)
    if (_isSpecificProduct(name)) {
      return _categorizeSpecificProduct(name);
    }
    
    // Dairy products (check before fruits to catch "coconut milk")
    if (_isDairy(name)) return 'Dairy';
    
    // Oils & Condiments (check before spices)
    if (_isOilOrCondiment(name)) return 'Oils & Condiments';
    
    // Meat & Fish
    if (_isMeatOrFish(name)) return 'Meat & Fish';
    
    // Vegetables
    if (_isVegetable(name)) return 'Vegetables';
    
    // Fruits
    if (_isFruit(name)) return 'Fruits';
    
    // Grains & Rice
    if (_isGrainOrRice(name)) return 'Grains & Rice';
    
    // Spices
    if (_isSpice(name)) return 'Spices';
    
    return 'Other';
  }

  bool _isVegetable(String name) {
    const vegetables = [
      'onion', 'garlic', 'ginger', 'tomato', 'potato', 'carrot', 'cabbage',
      'lettuce', 'spinach', 'cucumber', 'bell pepper', 'green pepper',
      'red pepper', 'chili', 'broccoli', 'cauliflower', 'beans', 'peas',
      'corn', 'celery', 'mushroom', 'eggplant', 'zucchini', 'leek',
      'okra', 'kale', 'bok choy', 'radish', 'turnip', 'beetroot',
      // Sri Lankan specific vegetables
      'karavila', 'mukunuwenna', 'kankun', 'gotukola', 'nivithi', 'sarana',
      'bandakka', 'pathola', 'kakiri', 'elabatu', 'wambatu', 'kakka',
      'lunu miris', 'curry leaves', 'pandan', 'rampe'
    ];
    return vegetables.any((veg) => _containsWord(name, veg));
  }

  bool _isFruit(String name) {
    const fruits = [
      'apple', 'banana', 'orange', 'lemon', 'lime', 'mango', 'papaya',
      'pineapple', 'grape', 'strawberry', 'blueberry', 'raspberry', 
      'avocado', 'watermelon', 'melon', 'kiwi', 'peach', 'pear', 'cherry', 
      'plum', 'guava', 'passion fruit', 'dragon fruit',
      // Sri Lankan specific fruits  
      'rambutan', 'mangosteen', 'wood apple', 'beli', 'nelli', 'jambu',
      'rata del', 'puhul', 'dan', 'king coconut', 'fresh coconut'
    ];
    return fruits.any((fruit) => _containsWord(name, fruit));
  }

  bool _isMeatOrFish(String name) {
    const proteins = [
      'chicken', 'beef', 'pork', 'fish', 'salmon', 'tuna', 'shrimp',
      'prawn', 'crab', 'lamb', 'mutton', 'duck', 'turkey', 'bacon',
      'ham', 'sausage', 'egg', 'tofu', 'tempeh'
    ];
    return proteins.any((protein) => name.contains(protein));
  }

  bool _isDairy(String name) {
    const dairy = [
      'milk', 'cheese', 'butter', 'cream', 'yogurt', 'yoghurt',
      'ghee', 'paneer', 'cottage cheese', 'sour cream', 'curd',
      // Coconut dairy products
      'coconut milk', 'coconut cream'
    ];
    return dairy.any((item) => _containsWord(name, item));
  }

  bool _isGrainOrRice(String name) {
    const grains = [
      'rice', 'flour', 'bread', 'pasta', 'noodle', 'wheat', 'oats',
      'barley', 'quinoa', 'bulgur', 'couscous', 'cereal', 'crackers',
      'tortilla', 'pita', 'bagel'
    ];
    return grains.any((grain) => name.contains(grain));
  }

  bool _isSpice(String name) {
    const spices = [
      'salt', 'pepper', 'cumin', 'coriander', 'turmeric', 'cinnamon',
      'cardamom', 'cloves', 'nutmeg', 'paprika', 'curry powder', 'chili powder',
      'garam masala', 'bay leaves', 'thyme', 'oregano', 'basil',
      'rosemary', 'sage', 'parsley', 'cilantro', 'mint', 'dill',
      'vanilla', 'fennel', 'mustard seeds', 'fenugreek',
      // Sri Lankan specific spices
      'goraka', 'gamboge', 'lemongrass', 'curry leaves', 'pandan leaves',
      'rampe', 'sera', 'karapincha', 'kaha', 'rathu miris', 'miris kudu'
    ];
    return spices.any((spice) => _containsWord(name, spice));
  }

  // Helper method for precise word-boundary matching
  bool _containsWord(String text, String word) {
    // Handle multi-word phrases
    if (word.contains(' ')) {
      return text.contains(word);
    }
    
    // For single words, use word boundary matching
    final regex = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
    return regex.hasMatch(text);
  }

  // Check for specific product rules that need custom categorization
  bool _isSpecificProduct(String name) {
    const specificProducts = [
      'coconut oil', 'coconut water', 'coconut milk', 'coconut cream',
      'coconut flour', 'desiccated coconut', 'coconut flakes'
    ];
    return specificProducts.any((product) => name.contains(product));
  }

  // Categorize specific products with custom rules
  String _categorizeSpecificProduct(String name) {
    // Coconut products
    if (name.contains('coconut oil')) return 'Oils & Condiments';
    if (name.contains('coconut milk') || name.contains('coconut cream')) return 'Dairy';
    if (name.contains('coconut water')) return 'Other'; // Beverages
    if (name.contains('coconut flour')) return 'Grains & Rice';
    if (name.contains('desiccated coconut') || name.contains('coconut flakes')) return 'Other';
    
    return 'Other';
  }

  // New category for oils and condiments
  bool _isOilOrCondiment(String name) {
    const oilsAndCondiments = [
      'oil', 'olive oil', 'coconut oil', 'sunflower oil', 'vegetable oil',
      'sesame oil', 'mustard oil', 'vinegar', 'soy sauce', 'fish sauce',
      'oyster sauce', 'tomato sauce', 'chili sauce', 'mayo', 'mayonnaise',
      'ketchup', 'honey', 'syrup', 'jam', 'marmalade',
      // Sri Lankan condiments
      'pol sambol', 'lunu miris', 'maalu miris', 'amu miris'
    ];
    return oilsAndCondiments.any((item) => _containsWord(name, item));
  }
}

class GenerateGroceryListException implements Exception {
  final String message;

  GenerateGroceryListException(this.message);

  @override
  String toString() => 'GenerateGroceryListException: $message';
}

class RecipeProcessingResult {
  final String mealSlotId;
  final String mealName;
  final String recipeId;
  final String? recipeTitle;
  final String? error;
  final String? warning;
  final int? ingredientsProcessed;

  const RecipeProcessingResult._({
    required this.mealSlotId,
    required this.mealName,
    required this.recipeId,
    this.recipeTitle,
    this.error,
    this.warning,
    this.ingredientsProcessed,
  });

  factory RecipeProcessingResult.success({
    required String mealSlotId,
    required String mealName,
    required String recipeId,
    required String recipeTitle,
    required int ingredientsProcessed,
  }) {
    return RecipeProcessingResult._(
      mealSlotId: mealSlotId,
      mealName: mealName,
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      ingredientsProcessed: ingredientsProcessed,
    );
  }

  factory RecipeProcessingResult.error({
    required String mealSlotId,
    required String mealName,
    required String recipeId,
    required String error,
  }) {
    return RecipeProcessingResult._(
      mealSlotId: mealSlotId,
      mealName: mealName,
      recipeId: recipeId,
      error: error,
    );
  }

  factory RecipeProcessingResult.warning({
    required String mealSlotId,
    required String mealName,
    required String recipeId,
    required String warning,
  }) {
    return RecipeProcessingResult._(
      mealSlotId: mealSlotId,
      mealName: mealName,
      recipeId: recipeId,
      warning: warning,
    );
  }

  bool get isSuccessful => error == null && warning == null && ingredientsProcessed != null;
  bool get hasError => error != null;
  bool get hasWarning => warning != null;
}