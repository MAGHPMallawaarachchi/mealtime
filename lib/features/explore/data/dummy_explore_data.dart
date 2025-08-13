import 'package:mealtime/features/recipes/domain/models/recipe.dart';

class DummyExploreData {
  static List<Recipe> getFeaturedRecipes() {
    return [
      Recipe(
        id: 'feat_1',
        title: 'Sri Lankan Fish Curry',
        time: '45 min',
        imageUrl:
            'https://www.loveandotherspices.com/wp-content/uploads/2015/10/sri-lankan-fish-curry-spicy-featured.jpg?w=400&h=300&fit=crop',
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
            'https://www.simplyrecipes.com/thmb/5XV_wV6gRcTxC50oGLtvm9JOePk=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/__opt__aboutcom__coeus__resources__content_migration__simply_recipes__uploads__2018__07__Veggie-Fried-Rice-LEAD-HORIZONTAL-5f6ac64a24b44f9ebd4b3ef854747f4a.jpg?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 320,
        macros: const RecipeMacros(protein: 12, carbs: 45, fats: 8, fiber: 4),
        description:
            'Transform yesterday\'s rice into a delicious stir fry with vegetables.',
      ),
      Recipe(
        id: 'feat_3',
        title: 'String Hoppers',
        time: '30 min',
        imageUrl:
            'https://i.pinimg.com/736x/86/bd/4e/86bd4e7abe5c4f59ded4b6802418e2d8.jpg?w=400&h=300&fit=crop',
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
            'https://www.theflavorbender.com/wp-content/uploads/2018/03/Chicken-Kottu-Roti-The-Flavor-Bender-Featured-Image-SQ-8.jpg?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 480,
        macros: const RecipeMacros(protein: 28, carbs: 42, fats: 22, fiber: 5),
        description:
            'Popular Sri Lankan street food made with chopped roti and chicken.',
      ),
      Recipe(
        id: 'feat_5',
        title: 'Pol Sambol',
        time: '20 min',
        imageUrl:
            'https://media-cdn2.greatbritishchefs.com/media/etbpfsnk/img86979.whqc_768x512q90.jpg?w=400&h=300&fit=crop',
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
            'https://i0.wp.com/kalapu.lk/wp-content/uploads/2021/08/DSC9297-2LowRes.jpg?fit=1437%2C993&ssl=1?w=400&h=300&fit=crop',
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
            'https://saltedmint.com/wp-content/uploads/2024/01/red-lentil-curry-dhal-6.jpg?w=400&h=300&fit=crop',
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
            'https://i0.wp.com/theperfectcurry.com/wp-content/uploads/2022/10/PXL_20221004_141950841.PORTRAIT.jpg?w=400&h=300&fit=crop',
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
            'https://images.slurrp.com/prod/recipe_images/transcribe/salad/Gotukola-Sambol.webp?impolicy=slurrp-20210601&width=1200&height=900&q=75?w=400&h=300&fit=crop',
        ingredients: _getBasicIngredients(),
        instructionSections: _getBasicInstructions(),
        calories: 120,
        macros: const RecipeMacros(protein: 4, carbs: 8, fats: 8, fiber: 4),
        description: 'Fresh pennywort salad with coconut and lime.',
      ),

      // Leftover Magic Recipes
      Recipe(
        id: 'left_2',
        title: 'Bread Pudding from Stale Bread',
        time: '45 min',
        imageUrl:
            'https://www.allrecipes.com/thmb/NDzgJ1x6qWxJ_M-VYWULFzM-jl8=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/658615_Bread-Pudding-II-4x3-bc7dce39c1984a12bd1a38fe3c3ea42d.jpg?w=400&h=300&fit=crop',
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
            'https://livingkitchenwellness.com/wp-content/uploads/2020/04/scrappy-vegetable-soup-or-vegetable-scrap-soup-scaled.jpg?w=400&h=300&fit=crop',
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
            'https://troovyfoods.com/cdn/shop/articles/3_8cbed97b-3671-4af8-8826-1c12663db79a.png?v=1689925564?w=400&h=300&fit=crop',
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
            'https://i0.wp.com/www.lavenderandlovage.com/wp-content/uploads/2016/05/Sri-Lankan-Egg-Hoppers-for-Breakfast.jpg?fit=1200%2C901&ssl=1?w=400&h=300&fit=crop',
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
            'https://iamhomesteader.com/wp-content/uploads/2025/05/Bang-Bang-Chicken-Fried-Rice-2.jpg?w=400&h=300&fit=crop',
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
            'https://www.ohmyveg.co.uk/wp-content/uploads/2024/08/hakka-noodles.jpg?w=400&h=300&fit=crop',
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
            'https://images.immediate.co.uk/production/volatile/sites/2/2019/12/Vegan-jackfruit-massaman-curry-V2-29c66ff-scaled.jpg?w=400&h=300&fit=crop',
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
            'https://www.sneakyveg.com/wp-content/uploads/2015/05/easy-potato-curry-vegan-sneaky-veg-FEAT-scaled.jpg?w=400&h=300&fit=crop',
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
            'https://images.immediate.co.uk/production/volatile/sites/30/2020/08/sri-lankan-runner-bean-curry-15-08-2016-july-2013-c126a3d.jpg?w=400&h=300&fit=crop',
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
            'https://www.vegkit.com/wp-content/uploads/sites/2/2022/12/FPST3_Ep17_Sweet_Sri_Lankan_Coconut_Pancakes_details.jpg?w=400&h=300&fit=crop',
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
            'https://www.thecookierookie.com/wp-content/uploads/2018/11/bourbon-chai-tea-latte-recipe-9-of-10.jpg?w=400&h=300&fit=crop',
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
            'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiDm40nZTi53jyhS2Dvkz9wKb3110mlPPe5n5Xgthlhh9ZPw5HmYwD1z1OuFa67Yol9obY_DuLUcQbtaycW9lKAka9KIAGHogZGuhE699YewFEldGo1QlgDV_gqtM00cCGbR56JSJNv18SKvI7qThrioN2GtRCV3X8NwiCpu2_yT7s7s5NuBvKcNhb-Nl8k/s1440/36EC5893-7F99-4CFF-8327-04B8D11A02C3.jpeg?w=400&h=300&fit=crop',
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
