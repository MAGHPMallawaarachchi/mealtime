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
    
    // Create a unique key for ingredient aggregation (normalize similar units)
    final normalizedUnit = _normalizeUnitForAggregation(unit);
    final ingredientKey = '${ingredient.name.toLowerCase()}_$normalizedUnit';
    
    if (aggregatedIngredients.containsKey(ingredientKey)) {
      // Add to existing ingredient
      final existingItem = aggregatedIngredients[ingredientKey]!;
      aggregatedIngredients[ingredientKey] = existingItem.addQuantity(quantity);
    } else {
      // Create new grocery item
      final groceryItem = GroceryItem(
        ingredientName: ingredient.name,
        quantity: quantity,
        unit: unit,
        category: _categorizeIngredient(ingredient.name),
        displayName: ingredient.name, // Use ingredient name as display name
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

  String _categorizeIngredient(String ingredientName) {
    final name = ingredientName.toLowerCase();
    
    // Vegetables
    if (_isVegetable(name)) return 'Vegetables';
    
    // Fruits
    if (_isFruit(name)) return 'Fruits';
    
    // Meat & Fish
    if (_isMeatOrFish(name)) return 'Meat & Fish';
    
    // Dairy
    if (_isDairy(name)) return 'Dairy';
    
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
      'okra', 'kale', 'bok choy', 'radish', 'turnip', 'beetroot'
    ];
    return vegetables.any((veg) => name.contains(veg));
  }

  bool _isFruit(String name) {
    const fruits = [
      'apple', 'banana', 'orange', 'lemon', 'lime', 'mango', 'papaya',
      'pineapple', 'coconut', 'grape', 'strawberry', 'blueberry',
      'raspberry', 'avocado', 'tomato', 'cucumber', 'watermelon',
      'melon', 'kiwi', 'peach', 'pear', 'cherry', 'plum'
    ];
    return fruits.any((fruit) => name.contains(fruit));
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
      'ghee', 'paneer', 'cottage cheese', 'sour cream'
    ];
    return dairy.any((item) => name.contains(item));
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
      'cardamom', 'cloves', 'nutmeg', 'paprika', 'curry', 'chili powder',
      'garam masala', 'bay leaves', 'thyme', 'oregano', 'basil',
      'rosemary', 'sage', 'parsley', 'cilantro', 'mint', 'dill',
      'vanilla', 'soy sauce', 'vinegar', 'oil', 'olive oil'
    ];
    return spices.any((spice) => name.contains(spice));
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