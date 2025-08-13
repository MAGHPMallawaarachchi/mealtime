import 'package:mealtime/features/recipes/domain/models/recipe.dart';

class DummyExploreData {
  static List<Recipe> getFeaturedRecipes() {
    return [
      Recipe(
        id: 'feat_1',
        title: 'Sri Lankan Fish Curry',
        time: '45 min',
        imageUrl:
            'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 420,
        macros: const RecipeMacros(protein: 32, carbs: 28, fats: 18, fiber: 6),
        description:
            'A traditional Sri Lankan fish curry with coconut milk and aromatic spices.',
      ),
      Recipe(
        id: 'feat_2',
        title: 'Leftover Rice Stir Fry',
        time: '15 min',
        imageUrl:
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 320,
        macros: const RecipeMacros(protein: 12, carbs: 45, fats: 8, fiber: 4),
        description:
            'Transform yesterday\'s rice into a delicious stir fry with vegetables.',
      ),
      Recipe(
        id: 'feat_3',
        title: 'Hoppers with Coconut Sambol',
        time: '30 min',
        imageUrl:
            'https://images.unsplash.com/photo-1574653803731-0f6c2d816e8f?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 280,
        macros: const RecipeMacros(protein: 8, carbs: 48, fats: 6, fiber: 3),
        description:
            'Traditional Sri Lankan hoppers served with fresh coconut sambol.',
      ),
      Recipe(
        id: 'feat_4',
        title: 'Chicken Kottu Roti',
        time: '25 min',
        imageUrl:
            'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 480,
        macros: const RecipeMacros(protein: 28, carbs: 42, fats: 22, fiber: 5),
        description:
            'Popular Sri Lankan street food made with chopped roti and chicken.',
      ),
      Recipe(
        id: 'feat_5',
        title: 'Pol Sambol with String Hoppers',
        time: '20 min',
        imageUrl:
            'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 250,
        macros: const RecipeMacros(protein: 6, carbs: 35, fats: 10, fiber: 8),
        description:
            'Fresh coconut sambol served with delicate string hoppers.',
      ),
    ];
  }

  static List<Recipe> getAllRecipes() {
    return [
      ...getFeaturedRecipes(),
      // Sri Lankan Recipes
      Recipe(
        id: 'sri_1',
        title: 'Rice and Curry',
        time: '60 min',
        imageUrl:
            'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 520,
        macros: const RecipeMacros(protein: 22, carbs: 68, fats: 16, fiber: 8),
        description:
            'Traditional Sri Lankan rice and curry with multiple curries and sides.',
      ),
      Recipe(
        id: 'sri_2',
        title: 'Dhal Curry',
        time: '35 min',
        imageUrl:
            'https://images.unsplash.com/photo-1574653817022-0a16ac2a8c5d?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 280,
        macros: const RecipeMacros(protein: 18, carbs: 35, fats: 8, fiber: 12),
        description:
            'Creamy lentil curry with coconut milk and Sri Lankan spices.',
      ),
      Recipe(
        id: 'sri_3',
        title: 'Ambulthiyal (Fish Curry)',
        time: '40 min',
        imageUrl:
            'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 350,
        macros: const RecipeMacros(protein: 35, carbs: 12, fats: 18, fiber: 3),
        description: 'Sour fish curry from Southern Sri Lanka with goraka.',
      ),
      Recipe(
        id: 'sri_4',
        title: 'Gotu Kola Sambol',
        time: '10 min',
        imageUrl:
            'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 120,
        macros: const RecipeMacros(protein: 4, carbs: 8, fats: 8, fiber: 4),
        description: 'Fresh pennywort salad with coconut and lime.',
      ),
      Recipe(
        id: 'sri_5',
        title: 'Parippu (Dhal)',
        time: '25 min',
        imageUrl:
            'https://images.unsplash.com/photo-1574653803731-0f6c2d816e8f?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 240,
        macros: const RecipeMacros(protein: 16, carbs: 32, fats: 6, fiber: 10),
        description: 'Simple Sri Lankan lentil curry perfect with rice.',
      ),

      // Leftover Magic Recipes
      Recipe(
        id: 'left_1',
        title: 'Leftover Curry Fried Rice',
        time: '20 min',
        imageUrl:
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 380,
        macros: const RecipeMacros(protein: 15, carbs: 52, fats: 12, fiber: 4),
        description:
            'Transform yesterday\'s rice and curry into a delicious fried rice.',
      ),
      Recipe(
        id: 'left_2',
        title: 'Bread Pudding from Stale Bread',
        time: '45 min',
        imageUrl:
            'https://images.unsplash.com/photo-1571197119282-7c4e15040d6a?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 320,
        macros: const RecipeMacros(protein: 12, carbs: 48, fats: 8, fiber: 3),
        description: 'Turn stale bread into a delicious dessert pudding.',
      ),
      Recipe(
        id: 'left_3',
        title: 'Vegetable Soup from Scraps',
        time: '30 min',
        imageUrl:
            'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 180,
        macros: const RecipeMacros(protein: 6, carbs: 28, fats: 4, fiber: 8),
        description:
            'Make nutritious soup from vegetable scraps and leftovers.',
      ),
      Recipe(
        id: 'left_4',
        title: 'Roti Pizza',
        time: '15 min',
        imageUrl:
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 290,
        macros: const RecipeMacros(protein: 14, carbs: 35, fats: 10, fiber: 4),
        description: 'Use leftover roti as a base for quick mini pizzas.',
      ),

      // Quick Meals
      Recipe(
        id: 'quick_1',
        title: 'Egg Hoppers',
        time: '20 min',
        imageUrl:
            'https://images.unsplash.com/photo-1582169296194-1ffc98106e56?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 220,
        macros: const RecipeMacros(protein: 14, carbs: 18, fats: 10, fiber: 2),
        description: 'Quick and easy egg hoppers for breakfast or dinner.',
      ),
      Recipe(
        id: 'quick_2',
        title: 'Chicken Fried Rice',
        time: '25 min',
        imageUrl:
            'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 420,
        macros: const RecipeMacros(protein: 28, carbs: 45, fats: 12, fiber: 3),
        description: 'Quick chicken fried rice with vegetables and soy sauce.',
      ),
      Recipe(
        id: 'quick_3',
        title: 'Vegetable Noodles',
        time: '18 min',
        imageUrl:
            'https://images.unsplash.com/photo-1555126634-323283e090fa?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 350,
        macros: const RecipeMacros(protein: 12, carbs: 58, fats: 8, fiber: 6),
        description: 'Quick stir-fried noodles with fresh vegetables.',
      ),

      // Vegetarian
      Recipe(
        id: 'veg_1',
        title: 'Jackfruit Curry',
        time: '40 min',
        imageUrl:
            'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 280,
        macros: const RecipeMacros(protein: 8, carbs: 48, fats: 6, fiber: 12),
        description: 'Traditional Sri Lankan young jackfruit curry.',
      ),
      Recipe(
        id: 'veg_2',
        title: 'Potato Curry',
        time: '30 min',
        imageUrl:
            'https://images.unsplash.com/photo-1574653803731-0f6c2d816e8f?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 260,
        macros: const RecipeMacros(protein: 6, carbs: 42, fats: 8, fiber: 5),
        description: 'Spiced potato curry with coconut milk.',
      ),
      Recipe(
        id: 'veg_3',
        title: 'Green Bean Curry',
        time: '25 min',
        imageUrl:
            'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 180,
        macros: const RecipeMacros(protein: 8, carbs: 22, fats: 6, fiber: 8),
        description: 'Fresh green bean curry with spices and coconut.',
      ),

      // Desserts and Beverages
      Recipe(
        id: 'dess_1',
        title: 'Coconut Pancakes',
        time: '25 min',
        imageUrl:
            'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 310,
        macros: const RecipeMacros(protein: 8, carbs: 45, fats: 12, fiber: 4),
        description: 'Fluffy pancakes made with fresh coconut milk.',
      ),
      Recipe(
        id: 'bev_1',
        title: 'Spiced Tea (Ceylon Tea)',
        time: '10 min',
        imageUrl:
            'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 45,
        macros: const RecipeMacros(protein: 1, carbs: 8, fats: 2, fiber: 0),
        description: 'Traditional Sri Lankan spiced tea with milk.',
      ),
      Recipe(
        id: 'snack_1',
        title: 'Isso Vadai (Prawn Fritters)',
        time: '30 min',
        imageUrl:
            'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 250,
        macros: const RecipeMacros(protein: 18, carbs: 15, fats: 14, fiber: 2),
        description: 'Crispy Sri Lankan prawn fritters perfect for snacking.',
      ),
    ];
  }

  static List<Recipe> getRecipesByCategory(String category) {
    final allRecipes = getAllRecipes();

    switch (category.toLowerCase()) {
      case 'sri lankan':
        return allRecipes
            .where(
              (recipe) =>
                  recipe.id.startsWith('sri_') || recipe.id.startsWith('feat_'),
            )
            .toList();
      case 'leftover magic':
        return allRecipes
            .where((recipe) => recipe.id.startsWith('left_'))
            .toList();
      case 'quick meals':
        return allRecipes
            .where((recipe) => recipe.id.startsWith('quick_'))
            .toList();
      case 'vegetarian':
        return allRecipes
            .where((recipe) => recipe.id.startsWith('veg_'))
            .toList();
      case 'breakfast':
        return allRecipes
            .where(
              (recipe) =>
                  recipe.title.toLowerCase().contains('hopper') ||
                  recipe.title.toLowerCase().contains('pancake') ||
                  recipe.title.toLowerCase().contains('tea'),
            )
            .toList();
      case 'lunch':
        return allRecipes
            .where(
              (recipe) =>
                  recipe.title.toLowerCase().contains('rice') ||
                  recipe.title.toLowerCase().contains('curry') ||
                  recipe.title.toLowerCase().contains('kottu'),
            )
            .toList();
      case 'dinner':
        return allRecipes
            .where(
              (recipe) =>
                  recipe.title.toLowerCase().contains('fish') ||
                  recipe.title.toLowerCase().contains('chicken') ||
                  recipe.title.toLowerCase().contains('curry'),
            )
            .toList();
      case 'desserts':
        return allRecipes
            .where(
              (recipe) =>
                  recipe.title.toLowerCase().contains('pudding') ||
                  recipe.title.toLowerCase().contains('pancake'),
            )
            .toList();
      case 'snacks':
        return allRecipes
            .where(
              (recipe) =>
                  recipe.title.toLowerCase().contains('fritter') ||
                  recipe.title.toLowerCase().contains('vadai') ||
                  recipe.title.toLowerCase().contains('sambol'),
            )
            .toList();
      case 'beverages':
        return allRecipes
            .where((recipe) => recipe.title.toLowerCase().contains('tea'))
            .toList();
      default:
        return allRecipes;
    }
  }

  static List<RecipeIngredient> _getBasicIngredients() {
    return [
      const RecipeIngredient(
        id: '1',
        name: 'Rice',
        quantity: 2,
        unit: IngredientUnit.cups,
      ),
      const RecipeIngredient(
        id: '2',
        name: 'Coconut milk',
        quantity: 400,
        unit: IngredientUnit.milliliters,
      ),
      const RecipeIngredient(
        id: '3',
        name: 'Onions',
        quantity: 2,
        unit: IngredientUnit.pieces,
      ),
    ];
  }

  static List<InstructionSection> _getBasicInstructions() {
    return [
      const InstructionSection(
        id: '1',
        title: 'Preparation',
        steps: [
          'Gather all ingredients and prepare workspace',
          'Chop vegetables and prepare spices',
        ],
      ),
      const InstructionSection(
        id: '2',
        title: 'Cooking',
        steps: [
          'Heat oil in a large pan over medium heat',
          'Add ingredients and cook according to recipe',
          'Season to taste and serve hot',
        ],
      ),
    ];
  }
}
