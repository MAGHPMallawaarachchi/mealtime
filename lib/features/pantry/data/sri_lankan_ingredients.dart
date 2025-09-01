import '../domain/models/pantry_item.dart';

class SriLankanIngredients {
  static const Map<PantryCategory, List<Map<String, dynamic>>> ingredientsByCategory = {
    PantryCategory.grains: [
      {'name': 'Rice', 'localName': 'Buth', 'tags': ['staple', 'carbs']},
      {'name': 'Red Rice', 'localName': 'Rathu Buth', 'tags': ['healthy', 'fiber']},
      {'name': 'String Hoppers Flour', 'localName': 'Idiyaappa Piti', 'tags': ['breakfast']},
      {'name': 'Hoppers Flour', 'localName': 'Appa Piti', 'tags': ['breakfast']},
      {'name': 'Wheat Flour', 'localName': 'Gom Piti', 'tags': ['baking']},
      {'name': 'Semolina', 'localName': 'Suji', 'tags': ['desserts']},
      {'name': 'Rice Flour', 'localName': 'Indiappa Piti', 'tags': ['traditional']},
    ],

    PantryCategory.vegetables: [
      {'name': 'Onions', 'localName': 'Lunu', 'tags': ['essential', 'base']},
      {'name': 'Red Onions', 'localName': 'Rathu Lunu', 'tags': ['salads', 'curry']},
      {'name': 'Tomatoes', 'localName': 'Thakkali', 'tags': ['essential', 'curry']},
      {'name': 'Green Chilies', 'localName': 'Amu Miris', 'tags': ['spicy', 'essential']},
      {'name': 'Red Chilies', 'localName': 'Rathu Miris', 'tags': ['hot', 'dried']},
      {'name': 'Garlic', 'localName': 'Sudulunu', 'tags': ['essential', 'flavor']},
      {'name': 'Ginger', 'localName': 'Inguru', 'tags': ['essential', 'medicinal']},
      {'name': 'Potatoes', 'localName': 'Ala', 'tags': ['curry', 'fried']},
      {'name': 'Sweet Potatoes', 'localName': 'Bathala', 'tags': ['healthy', 'boiled']},
      {'name': 'Pumpkin', 'localName': 'Watakka', 'tags': ['curry', 'sweet']},
      {'name': 'Bottle Gourd', 'localName': 'Labu', 'tags': ['curry', 'healthy']},
      {'name': 'Ridge Gourd', 'localName': 'Pathola', 'tags': ['curry']},
      {'name': 'Bitter Gourd', 'localName': 'Karawila', 'tags': ['curry', 'medicinal']},
      {'name': 'Okra', 'localName': 'Bandakka', 'tags': ['curry', 'fried']},
      {'name': 'Eggplant', 'localName': 'Wambatu', 'tags': ['curry', 'fried']},
      {'name': 'Green Beans', 'localName': 'Bonchi', 'tags': ['curry', 'healthy']},
      {'name': 'Drumsticks', 'localName': 'Murunga', 'tags': ['curry', 'nutritious']},
      {'name': 'Jackfruit', 'localName': 'Kos', 'tags': ['curry', 'traditional']},
      {'name': 'Plantain', 'localName': 'Kesel', 'tags': ['curry', 'boiled']},
      {'name': 'Breadfruit', 'localName': 'Del', 'tags': ['curry', 'boiled']},
      {'name': 'Cabbage', 'localName': 'Gova', 'tags': ['salad', 'curry']},
      {'name': 'Leeks', 'localName': 'Liks', 'tags': ['curry', 'soup']},
      {'name': 'Carrot', 'localName': 'Carrot', 'tags': ['salad', 'curry']},
    ],

    PantryCategory.fruits: [
      {'name': 'Coconut', 'localName': 'Pol', 'tags': ['essential', 'oil', 'milk']},
      {'name': 'Lime', 'localName': 'Dehi', 'tags': ['sour', 'essential']},
      {'name': 'Mango', 'localName': 'Amba', 'tags': ['sweet', 'seasonal']},
      {'name': 'Papaya', 'localName': 'Papol', 'tags': ['curry', 'salad']},
      {'name': 'Pineapple', 'localName': 'Ananas', 'tags': ['curry', 'sweet']},
      {'name': 'Banana', 'localName': 'Kesel', 'tags': ['dessert', 'healthy']},
      {'name': 'Tamarind', 'localName': 'Siyambala', 'tags': ['sour', 'curry']},
      {'name': 'Wood Apple', 'localName': 'Divul', 'tags': ['traditional', 'drink']},
      {'name': 'King Coconut', 'localName': 'Thambili', 'tags': ['drink', 'healthy']},
    ],

    PantryCategory.spices: [
      {'name': 'Turmeric', 'localName': 'Kaha', 'tags': ['essential', 'color', 'medicinal']},
      {'name': 'Cinnamon', 'localName': 'Kurundu', 'tags': ['sweet', 'export']},
      {'name': 'Cardamom', 'localName': 'Enasal', 'tags': ['sweet', 'tea']},
      {'name': 'Cloves', 'localName': 'Karabu Nati', 'tags': ['sweet', 'medicinal']},
      {'name': 'Black Pepper', 'localName': 'Gammiris', 'tags': ['hot', 'export']},
      {'name': 'Coriander Seeds', 'localName': 'Kottamalli', 'tags': ['curry', 'powder']},
      {'name': 'Cumin Seeds', 'localName': 'Suduru', 'tags': ['curry', 'powder']},
      {'name': 'Fennel Seeds', 'localName': 'Maduru', 'tags': ['tea', 'digestive']},
      {'name': 'Fenugreek Seeds', 'localName': 'Uluhal', 'tags': ['curry', 'medicinal']},
      {'name': 'Mustard Seeds', 'localName': 'Aba', 'tags': ['tempering']},
      {'name': 'Chili Powder', 'localName': 'Miris Kudu', 'tags': ['hot', 'essential']},
      {'name': 'Curry Powder', 'localName': 'Kari Kudu', 'tags': ['essential', 'mix']},
      {'name': 'Roasted Curry Powder', 'localName': 'Thuna Kari Kudu', 'tags': ['dark', 'rich']},
      {'name': 'Nutmeg', 'localName': 'Sadikka', 'tags': ['sweet', 'dessert']},
      {'name': 'Mace', 'localName': 'Wasavasayyi', 'tags': ['sweet', 'color']},
    ],

    PantryCategory.herbs: [
      {'name': 'Curry Leaves', 'localName': 'Karapincha', 'tags': ['essential', 'tempering']},
      {'name': 'Pandan Leaves', 'localName': 'Rampe', 'tags': ['rice', 'dessert']},
      {'name': 'Lemongrass', 'localName': 'Sera', 'tags': ['tea', 'curry']},
      {'name': 'Gotukola', 'localName': 'Gotu Kola', 'tags': ['salad', 'medicinal']},
      {'name': 'Mint', 'localName': 'Menchi', 'tags': ['drink', 'chutney']},
      {'name': 'Dill', 'localName': 'Enduru', 'tags': ['fish', 'soup']},
      {'name': 'Cilantro', 'localName': 'Kottamalli Kolle', 'tags': ['garnish']},
    ],

    PantryCategory.proteins: [
      {'name': 'Fish', 'localName': 'Malu', 'tags': ['fresh', 'curry']},
      {'name': 'Dried Fish', 'localName': 'Karawala', 'tags': ['salty', 'preserved']},
      {'name': 'Chicken', 'localName': 'Kukul Mas', 'tags': ['curry', 'roast']},
      {'name': 'Beef', 'localName': 'Iri Mas', 'tags': ['curry', 'stew']},
      {'name': 'Pork', 'localName': 'Uru Mas', 'tags': ['curry', 'traditional']},
      {'name': 'Prawns', 'localName': 'Isso', 'tags': ['curry', 'fried']},
      {'name': 'Crab', 'localName': 'Kakula', 'tags': ['curry', 'specialty']},
      {'name': 'Eggs', 'localName': 'Bittara', 'tags': ['versatile', 'protein']},
      {'name': 'Red Lentils', 'localName': 'Rathu Parippu', 'tags': ['dal', 'protein']},
      {'name': 'Green Lentils', 'localName': 'Alu Parippu', 'tags': ['dal', 'healthy']},
      {'name': 'Black Lentils', 'localName': 'Kalu Parippu', 'tags': ['dal', 'rich']},
      {'name': 'Chickpeas', 'localName': 'Kadala', 'tags': ['curry', 'protein']},
      {'name': 'Cowpea', 'localName': 'Mee Karal', 'tags': ['curry', 'beans']},
    ],

    PantryCategory.dairy: [
      {'name': 'Coconut Milk', 'localName': 'Kiri', 'tags': ['essential', 'curry']},
      {'name': 'Fresh Milk', 'localName': 'Kiri', 'tags': ['tea', 'dessert']},
      {'name': 'Yogurt', 'localName': 'Curd', 'tags': ['dessert', 'healthy']},
      {'name': 'Buffalo Curd', 'localName': 'Mee Kiri', 'tags': ['traditional', 'dessert']},
      {'name': 'Butter', 'localName': 'Butta', 'tags': ['cooking']},
      {'name': 'Ghee', 'localName': 'Ghi', 'tags': ['traditional', 'rich']},
    ],

    PantryCategory.condiments: [
      {'name': 'Fish Sauce', 'localName': 'Malu Katta', 'tags': ['salty', 'umami']},
      {'name': 'Soy Sauce', 'localName': 'Soya Katta', 'tags': ['chinese', 'salty']},
      {'name': 'Vinegar', 'localName': 'Viniga', 'tags': ['sour', 'pickle']},
      {'name': 'Coconut Vinegar', 'localName': 'Pol Viniga', 'tags': ['local', 'mild']},
      {'name': 'Tomato Sauce', 'localName': 'Thakkali Katta', 'tags': ['sweet', 'kids']},
      {'name': 'Chili Sauce', 'localName': 'Miris Katta', 'tags': ['hot', 'spicy']},
      {'name': 'Pol Sambol Paste', 'localName': 'Pol Sambol', 'tags': ['spicy', 'traditional']},
    ],

    PantryCategory.oils: [
      {'name': 'Coconut Oil', 'localName': 'Pol Thel', 'tags': ['cooking', 'traditional']},
      {'name': 'Sesame Oil', 'localName': 'Thala Thel', 'tags': ['medicinal', 'massage']},
      {'name': 'Sunflower Oil', 'localName': 'Suriyakantha Thel', 'tags': ['light', 'frying']},
      {'name': 'Olive Oil', 'localName': 'Olive Thel', 'tags': ['healthy', 'salad']},
    ],

    PantryCategory.pantryStaples: [
      {'name': 'Salt', 'localName': 'Lunu', 'tags': ['essential']},
      {'name': 'Sugar', 'localName': 'Seeni', 'tags': ['sweet', 'tea']},
      {'name': 'Jaggery', 'localName': 'Hakuru', 'tags': ['traditional', 'healthy']},
      {'name': 'Palm Sugar', 'localName': 'Tal Seeni', 'tags': ['traditional', 'dessert']},
      {'name': 'Treacle', 'localName': 'Pani', 'tags': ['dessert', 'traditional']},
      {'name': 'Coconut Treacle', 'localName': 'Pol Pani', 'tags': ['dessert', 'local']},
      {'name': 'Vanilla', 'localName': 'Vanilla', 'tags': ['dessert', 'flavor']},
      {'name': 'Baking Powder', 'localName': 'Baking Powder', 'tags': ['baking']},
      {'name': 'Cornflour', 'localName': 'Corn Flour', 'tags': ['thickening']},
      {'name': 'Agar Agar', 'localName': 'China Grass', 'tags': ['dessert', 'gel']},
    ],

    PantryCategory.beverages: [
      {'name': 'Ceylon Tea', 'localName': 'Ceylon Tea', 'tags': ['export', 'quality']},
      {'name': 'Black Tea', 'localName': 'Kalu Tea', 'tags': ['strong', 'morning']},
      {'name': 'Green Tea', 'localName': 'Pachcha Tea', 'tags': ['healthy', 'antioxidant']},
      {'name': 'King Coconut Water', 'localName': 'Thambili Wathura', 'tags': ['healthy', 'natural']},
      {'name': 'Lime Juice', 'localName': 'Dehi Juice', 'tags': ['vitamin-c', 'fresh']},
    ],

    PantryCategory.frozen: [
      {'name': 'Frozen Fish', 'localName': 'Frozen Malu', 'tags': ['convenient', 'protein']},
      {'name': 'Frozen Prawns', 'localName': 'Frozen Isso', 'tags': ['seafood']},
      {'name': 'Frozen Vegetables', 'localName': 'Frozen Elawalu', 'tags': ['convenient']},
      {'name': 'Ice Cream', 'localName': 'Ice Cream', 'tags': ['dessert']},
    ],
  };

  static List<Map<String, dynamic>> getEssentialIngredients() {
    return [
      // Most essential Sri Lankan ingredients
      {'name': 'Rice', 'category': PantryCategory.grains, 'priority': 1},
      {'name': 'Coconut', 'category': PantryCategory.fruits, 'priority': 1},
      {'name': 'Onions', 'category': PantryCategory.vegetables, 'priority': 1},
      {'name': 'Garlic', 'category': PantryCategory.vegetables, 'priority': 1},
      {'name': 'Green Chilies', 'category': PantryCategory.vegetables, 'priority': 1},
      {'name': 'Curry Leaves', 'category': PantryCategory.herbs, 'priority': 1},
      {'name': 'Turmeric', 'category': PantryCategory.spices, 'priority': 1},
      {'name': 'Coconut Oil', 'category': PantryCategory.oils, 'priority': 1},
      {'name': 'Salt', 'category': PantryCategory.pantryStaples, 'priority': 1},
      {'name': 'Curry Powder', 'category': PantryCategory.spices, 'priority': 1},
      
      // Secondary essentials
      {'name': 'Tomatoes', 'category': PantryCategory.vegetables, 'priority': 2},
      {'name': 'Ginger', 'category': PantryCategory.vegetables, 'priority': 2},
      {'name': 'Lime', 'category': PantryCategory.fruits, 'priority': 2},
      {'name': 'Cinnamon', 'category': PantryCategory.spices, 'priority': 2},
      {'name': 'Cardamom', 'category': PantryCategory.spices, 'priority': 2},
      {'name': 'Black Pepper', 'category': PantryCategory.spices, 'priority': 2},
      {'name': 'Coconut Milk', 'category': PantryCategory.dairy, 'priority': 2},
      {'name': 'Red Lentils', 'category': PantryCategory.proteins, 'priority': 2},
      {'name': 'Fish', 'category': PantryCategory.proteins, 'priority': 2},
      {'name': 'Pandan Leaves', 'category': PantryCategory.herbs, 'priority': 2},
    ];
  }

  static List<Map<String, dynamic>> getStarterKit() {
    return getEssentialIngredients()
        .where((ingredient) => ingredient['priority'] == 1)
        .toList();
  }

  static List<String> searchIngredients(String query) {
    final results = <String>[];
    final lowerQuery = query.toLowerCase();

    for (final categoryEntry in ingredientsByCategory.entries) {
      for (final ingredient in categoryEntry.value) {
        final name = ingredient['name'] as String;
        final localName = ingredient['localName'] as String;
        final tags = ingredient['tags'] as List<String>;

        if (name.toLowerCase().contains(lowerQuery) ||
            localName.toLowerCase().contains(lowerQuery) ||
            tags.any((tag) => tag.toLowerCase().contains(lowerQuery))) {
          results.add(name);
        }
      }
    }

    return results;
  }

  static PantryCategory? getCategoryForIngredient(String ingredientName) {
    final lowerName = ingredientName.toLowerCase();

    for (final categoryEntry in ingredientsByCategory.entries) {
      for (final ingredient in categoryEntry.value) {
        final name = (ingredient['name'] as String).toLowerCase();
        final localName = (ingredient['localName'] as String).toLowerCase();

        if (name == lowerName || localName == lowerName) {
          return categoryEntry.key;
        }
      }
    }

    return null;
  }

  static List<String> getPopularIngredientsForCategory(PantryCategory category) {
    final categoryIngredients = ingredientsByCategory[category] ?? [];
    return categoryIngredients
        .map((ingredient) => ingredient['name'] as String)
        .take(10)
        .toList();
  }
}