import '../domain/models/meal_plan_item.dart';
import '../../recipes/domain/models/recipe.dart';

class DummyMealPlanData {
  static List<MealPlanItem> getTodaysMealPlan() {
    return [
      const MealPlanItem(
        id: 'recipe_1',
        title: 'Kiribath and Lunu Miris',
        time: '8:30 am',
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&h=600&fit=crop',
      ),
      const MealPlanItem(
        id: 'recipe_2',
        title: 'Rice and Curry',
        time: '12:30 pm',
        imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800&h=600&fit=crop',
      ),
      const MealPlanItem(
        id: 'recipe_3',
        title: 'Kottu Roti',
        time: '7:00 pm',
        imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&h=600&fit=crop',
      ),
      const MealPlanItem(
        id: 'recipe_4',
        title: 'String Hoppers & Curry',
        time: '8:00 am',
        imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&h=600&fit=crop',
      ),
    ];
  }

  static List<Recipe> getRecipes() {
    return [
      Recipe(
        id: 'recipe_1',
        title: 'Kiribath and Lunu Miris',
        time: '45 min',
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&h=600&fit=crop',
        description: 'Traditional Sri Lankan milk rice served with spicy onion relish',
        ingredients: [
          '2 cups basmati rice',
          '1 can coconut milk (400ml)',
          '1 tsp salt',
          '2 cups water',
          '4 red onions (for lunu miris)',
          '10 dried red chilies',
          '1 tsp salt',
          '1 tbsp lime juice',
          '1 tbsp Maldive fish flakes',
        ],
        instructions: [
          'Wash and cook rice with water until tender',
          'Add coconut milk and salt, simmer until thick',
          'Let it set in a flat dish to cool',
          'For lunu miris: blend onions, chilies, salt, and Maldive fish',
          'Add lime juice and mix well',
          'Cut kiribath into diamond shapes and serve with lunu miris',
        ],
        calories: 320,
        macros: const RecipeMacros(
          protein: 8.5,
          carbs: 58.2,
          fats: 12.8,
          fiber: 2.1,
        ),
      ),
      Recipe(
        id: 'recipe_2',
        title: 'Rice and Curry',
        time: '1 hour 30 min',
        imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800&h=600&fit=crop',
        description: 'Classic Sri Lankan rice and curry with dhal, vegetable curries, and sambola',
        ingredients: [
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
        instructions: [
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
        imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&h=600&fit=crop',
        description: 'Popular Sri Lankan street food made with chopped roti, vegetables, and spices',
        ingredients: [
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
        instructions: [
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
        imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&h=600&fit=crop',
        description: 'Delicate rice noodle nests served with aromatic coconut curry',
        ingredients: [
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
        instructions: [
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