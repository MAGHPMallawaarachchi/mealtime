import '../models/user_model.dart';
import '../../features/recipes/domain/models/recipe.dart';

class DietaryFilterService {
  static List<Recipe> filterRecipesByDietaryType(
    List<Recipe> recipes,
    DietaryType? userDietaryType,
  ) {
    if (userDietaryType == null) {
      // If user hasn't set dietary preference, show all recipes with valid dietaryType
      return recipes.where((recipe) => 
        recipe.dietaryType != null && recipe.dietaryType!.trim().isNotEmpty
      ).toList();
    }

    return recipes.where((recipe) {
      // Filter out recipes with missing dietaryType as per requirement
      if (recipe.dietaryType == null || recipe.dietaryType!.trim().isEmpty) {
        return false;
      }

      final recipeDietaryType = DietaryTypeExtension.fromDatabaseValue(recipe.dietaryType);
      if (recipeDietaryType == null) {
        return false; // Invalid dietary type, don't show
      }

      return _isRecipeAllowedForUser(recipeDietaryType, userDietaryType);
    }).toList();
  }

  static bool _isRecipeAllowedForUser(
    DietaryType recipeDietaryType,
    DietaryType userDietaryType,
  ) {
    switch (userDietaryType) {
      case DietaryType.nonVegetarian:
        // Non-vegetarians can eat everything
        return true;
        
      case DietaryType.vegetarian:
        // Vegetarians can eat vegetarian and vegan, but not pescatarian or non-vegetarian
        return recipeDietaryType == DietaryType.vegetarian || 
               recipeDietaryType == DietaryType.vegan;
        
      case DietaryType.pescatarian:
        // Pescatarians can eat pescatarian, vegetarian, and vegan, but not non-vegetarian
        return recipeDietaryType == DietaryType.pescatarian || 
               recipeDietaryType == DietaryType.vegetarian || 
               recipeDietaryType == DietaryType.vegan;
        
      case DietaryType.vegan:
        // Vegans can only eat vegan recipes
        return recipeDietaryType == DietaryType.vegan;
    }
  }

  static bool isRecipeAllowedForUser(Recipe recipe, DietaryType? userDietaryType) {
    if (userDietaryType == null) {
      // If user hasn't set dietary preference, allow all recipes with valid dietaryType
      return recipe.dietaryType != null && recipe.dietaryType!.trim().isNotEmpty;
    }

    if (recipe.dietaryType == null || recipe.dietaryType!.trim().isEmpty) {
      return false; // Filter out recipes with missing dietaryType
    }

    final recipeDietaryType = DietaryTypeExtension.fromDatabaseValue(recipe.dietaryType);
    if (recipeDietaryType == null) {
      return false; // Invalid dietary type
    }

    return _isRecipeAllowedForUser(recipeDietaryType, userDietaryType);
  }

  static List<String> getAllowedDietaryTypesForFirestore(DietaryType? userDietaryType) {
    if (userDietaryType == null) {
      // Return all valid dietary types for Firestore query
      return ['vegan', 'vegetarian', 'pescatarian', 'non-vegetarian'];
    }

    switch (userDietaryType) {
      case DietaryType.nonVegetarian:
        return ['vegan', 'vegetarian', 'pescatarian', 'non-vegetarian'];
        
      case DietaryType.vegetarian:
        return ['vegetarian', 'vegan'];
        
      case DietaryType.pescatarian:
        return ['pescatarian', 'vegetarian', 'vegan'];
        
      case DietaryType.vegan:
        return ['vegan'];
    }
  }
}