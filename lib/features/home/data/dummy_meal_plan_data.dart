import '../domain/models/meal_plan_item.dart';
import '../../recipes/domain/models/recipe.dart';

class DummyMealPlanData {
  static List<MealPlanItem> getTodaysMealPlan() {
    return [
      const MealPlanItem(
        id: 'recipe_1',
        title: 'Kiribath and Lunu Miris',
        time: '8:30 am',
        imageUrl:
            'https://whirlpool.com.au/cdn/shop/articles/kiribath.jpg?v=1713936421?w=800&h=600&fit=crop',
      ),
      const MealPlanItem(
        id: 'recipe_2',
        title: 'Rice and Curry',
        time: '12:30 pm',
        imageUrl:
            'https://i0.wp.com/kalapu.lk/wp-content/uploads/2021/08/DSC9297-2LowRes.jpg?fit=1437%2C993&ssl=1?w=800&h=600&fit=crop',
      ),
      const MealPlanItem(
        id: 'recipe_3',
        title: 'Kottu Roti',
        time: '7:00 pm',
        imageUrl:
            'https://www.maggi.lk/sites/default/files/styles/home_stage_944_531/public/srh_recipes/de0a5945fe8e322a4d7711389c7a4830.jpg?h=4f5b30f1&itok=mCvylZbE?w=800&h=600&fit=crop',
      ),
      const MealPlanItem(
        id: 'recipe_4',
        title: 'String Hoppers & Curry',
        time: '8:00 am',
        imageUrl:
            'https://harischandramills.com/wp-content/uploads/2018/06/3-2.jpg?w=800&h=600&fit=crop',
      ),
    ];
  }

  static List<Recipe> getRecipes() {
    return [
      Recipe(
        id: 'recipe_1',
        title: 'Kiribath',
        time: '30 Min',
        imageUrl:
            'https://whirlpool.com.au/cdn/shop/articles/kiribath.jpg?v=1713936421?w=800&h=600&fit=crop',
        description:
            'Kiribath aka Sri Lankan milk rice is Sri Lanka\'s national dish that we make for every celebration in Sri Lanka. Kiribath is essentially cooked rice cooked in thick coconut milk. It is often served at breakfast with lunu miris (chili onion paste) and jaggery. It is also served during special occasions like New Year and weddings.',
        defaultServings: 4,
        ingredients: [
          const RecipeIngredient(
            id: 'rice',
            name: '"Kekulu" Rice',
            quantity: 2,
            unit: IngredientUnit.cups,
            metricQuantity: 400,
            metricUnit: IngredientUnit.grams,
          ),
          const RecipeIngredient(
            id: 'water',
            name: 'water',
            quantity: 3.75,
            unit: IngredientUnit.cups,
            metricQuantity: 900,
            metricUnit: IngredientUnit.milliliters,
          ),
          const RecipeIngredient(
            id: 'coconut_milk',
            name: 'Thick coconut milk',
            quantity: 1.75,
            unit: IngredientUnit.cups,
            metricQuantity: 420,
            metricUnit: IngredientUnit.milliliters,
          ),
          const RecipeIngredient(
            id: 'salt',
            name: 'salt',
            quantity: 2,
            unit: IngredientUnit.teaspoons,
            metricQuantity: 10,
            metricUnit: IngredientUnit.grams,
          ),
        ],
        instructionSections: [
          const InstructionSection(
            id: 'making_kiribath',
            title: 'Making Kiribath',
            steps: [
              'Wash your rice first, then drain water and put it into the rice cooker or any pot you cook your rice usually.',
              'Add water and 1 tsp salt (keep rest of the salt for after). Cook your rice using your usual method. If you\'re using a rice cooker, turn on the cook switch. If you\'re using an instant pot, press the rice button at the top. All you do here is cook rice the normal way but with just a little bit of water than you\'d normally use.',
              'Add the coconut milk to the cooked rice as soon as the rice is done cooking. Do NOT wait until the rice cools down.',
              'Mix your rice and coconut milk very well using a spoon until the rice grains breakdown and everything sticks together. You can transfer the rice to a banana leaf if you have. If not at this point and shape it. But if you still get the raw coconut milk smell, turn on heat and cook for about 2- 3 more minutes on the stove or in the rice cooker. If you\'re using an instant pot, press the "Keep warm" option and leave it covered for about 5 - 8 mins',
            ],
          ),
          const InstructionSection(
            id: 'shaping_cutting',
            title: 'Shaping and cutting Kiribath',
            steps: [
              'Transfer the rice to a cleaned banana leaf. Make sure to do it while Kiribath/milk rice is still hot. It starts to become hardened as it cools down. Which makes it hard to smother and cut into squares.',
              'Shape the Kiribath using another piece of banana leaf/ a baking paper/ spatula into a flat round or a square or to any other shape of your liking. Press it down so the broken rice sticks to each other.',
              'Get a knife and wrap the knife with a plastic wrap. And apply a little bit of coconut milk/milk or water so the knife doesn\'t stick to the rice.',
              'Cut your shaped Kiribath into squares or diamond shapes. Let it cool down a bit. It\'s easier to separate squares when Kiribath has cooled down.',
            ],
          ),
        ],
        calories: 490,
        macros: const RecipeMacros(
          protein: 8,
          carbs: 68,
          fats: 20.5,
          fiber: 2.1,
        ),
      ),
      Recipe(
        id: 'recipe_2',
        title: 'Rice and Curry',
        time: '1 hour 30 min',
        imageUrl:
            'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800&h=600&fit=crop',
        description:
            'Classic Sri Lankan rice and curry with dhal, vegetable curries, and sambola',
        defaultServings: 4,
        ingredients: [],
        instructionSections: [],
        legacyIngredients: [
          '2 cups basmati rice',
          '1 cup red lentils',
          '1 large eggplant',
          '200g green beans',
          '2 large onions',
          '4 cloves garlic',
          '1 inch ginger',
          '2 tbsp curry powder',
          '1 can coconut milk',
          '2 tbsp coconut oil',
          '1 cinnamon stick',
          '4 cardamom pods',
          '1 tsp turmeric powder',
          'Salt to taste',
        ],
        legacyInstructions: [
          'Cook rice separately and keep warm',
          'Cook red lentils with turmeric, salt, and water until soft',
          'Cut eggplant and green beans into pieces',
          'Heat oil, add cinnamon and cardamom',
          'Add sliced onions, garlic, and ginger',
          'Add curry powder and cook until fragrant',
          'Add vegetables and cook until tender',
          'Add coconut milk and simmer',
          'Season with salt and serve with rice',
        ],
        calories: 485,
        macros: const RecipeMacros(
          protein: 15.2,
          carbs: 72.5,
          fats: 18.3,
          fiber: 8.4,
        ),
      ),
      Recipe(
        id: 'recipe_3',
        title: 'Kottu Roti',
        time: '30 min',
        imageUrl:
            'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&h=600&fit=crop',
        description:
            'Popular Sri Lankan street food made with chopped roti, vegetables, and spices',
        defaultServings: 4,
        ingredients: [],
        instructionSections: [],
        legacyIngredients: [
          '4 plain roti (or leftover roti)',
          '200g chicken (cut into strips)',
          '2 eggs',
          '1 large onion (sliced)',
          '2 green chilies',
          '3 cloves garlic (minced)',
          '1 tbsp ginger-garlic paste',
          '2 tbsp soy sauce',
          '1 tbsp tomato sauce',
          '1 tsp curry powder',
          '2 tbsp vegetable oil',
          '1 leek (chopped)',
          'Salt and pepper to taste',
        ],
        legacyInstructions: [
          'Cut roti into small strips',
          'Heat oil in a large pan or wok',
          'Cook chicken strips until done, remove and set aside',
          'Beat eggs and scramble in the same pan',
          'Add onions, chilies, garlic, and ginger-garlic paste',
          'Add roti strips and mix well',
          'Add soy sauce, tomato sauce, and curry powder',
          'Return chicken to pan and mix everything',
          'Add leeks and cook for 2 minutes',
          'Season with salt and pepper, serve hot',
        ],
        calories: 420,
        macros: const RecipeMacros(
          protein: 28.5,
          carbs: 45.8,
          fats: 14.2,
          fiber: 3.6,
        ),
      ),
      Recipe(
        id: 'recipe_4',
        title: 'String Hoppers & Curry',
        time: '1 hour',
        imageUrl:
            'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&h=600&fit=crop',
        description:
            'Delicate rice noodle nests served with aromatic coconut curry',
        defaultServings: 4,
        ingredients: [],
        instructionSections: [],
        legacyIngredients: [
          '2 cups red rice flour',
          '2 cups water',
          '1 tsp salt',
          '500g beef (cut into cubes)',
          '2 large onions',
          '4 cloves garlic',
          '1 inch ginger',
          '3 tbsp curry powder',
          '1 can coconut milk',
          '2 tbsp coconut oil',
          '2 cinnamon sticks',
          '4 cardamom pods',
          '2 pandan leaves',
          '2 tbsp tomato paste',
        ],
        legacyInstructions: [
          'Boil water with salt, gradually add rice flour stirring continuously',
          'Cook until mixture forms a dough, let it cool slightly',
          'Use string hopper maker to create nests, steam for 10 minutes',
          'For curry: heat oil, add whole spices and pandan',
          'Add sliced onions, cook until golden',
          'Add garlic, ginger, and curry powder',
          'Add beef and brown on all sides',
          'Add tomato paste and cook for 2 minutes',
          'Add coconut milk and simmer until beef is tender',
          'Serve string hoppers with curry',
        ],
        calories: 380,
        macros: const RecipeMacros(
          protein: 22.8,
          carbs: 48.5,
          fats: 12.7,
          fiber: 2.3,
        ),
      ),
    ];
  }

  static Recipe? getRecipeById(String id) {
    try {
      return getRecipes().firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }
}
