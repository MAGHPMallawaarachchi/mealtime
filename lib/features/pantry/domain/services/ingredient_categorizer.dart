// Ingredient categorization with robust normalization, aliasing, and fuzzy matching.
// Paste this entire file into your project.

enum IngredientImportance {
  essential, // Proteins, main vegetables, grains - must match for good suggestions
  important, // Secondary ingredients that add value
  supplementary, // Nice to have but not critical for core matching
  excluded, // Basic spices, salt, water - excluded from core matching
}

class IngredientCategory {
  final IngredientImportance importance;
  final String displayName;
  final double matchWeight;

  const IngredientCategory({
    required this.importance,
    required this.displayName,
    required this.matchWeight,
  });
}

class IngredientCategorizer {
  // Cache for frequently accessed ingredient categories
  static final Map<String, IngredientCategory> _categoryCache =
      <String, IngredientCategory>{};

  /// ===== Canonical Categories =====
  static const Map<String, IngredientCategory> _ingredientCategories = {
    // ESSENTIAL INGREDIENTS (High match weight - core ingredients)

    // Proteins
    'chicken': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Protein',
      matchWeight: 1.0,
    ),
    'beef': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Protein',
      matchWeight: 1.0,
    ),
    'pork': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Protein',
      matchWeight: 1.0,
    ),
    'fish': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Protein',
      matchWeight: 1.0,
    ),
    'prawns': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Protein',
      matchWeight: 1.0,
    ),
    'crab': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Protein',
      matchWeight: 1.0,
    ),
    'eggs': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Protein',
      matchWeight: 1.0,
    ),
    'egg': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Protein',
      matchWeight: 1.0,
    ),
    'tofu': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Protein',
      matchWeight: 1.0,
    ),
    'lentils': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Protein',
      matchWeight: 1.0,
    ),
    'dal': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Protein',
      matchWeight: 1.0,
    ),

    // Main vegetables
    'potatoes': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'sweet potatoes': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'pumpkin': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'brinjal': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'eggplant': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'okra': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'cabbage': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'cauliflower': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'beans': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'green beans': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'long beans': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'drumsticks': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'murunga': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'jackfruit': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),
    'banana flowers': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Vegetable',
      matchWeight: 0.9,
    ),

    // Grains and carbs
    'rice': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Grain',
      matchWeight: 0.8,
    ),
    'basmati rice': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Grain',
      matchWeight: 0.8,
    ),
    'red rice': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Grain',
      matchWeight: 0.8,
    ),
    'pasta': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Grain',
      matchWeight: 0.8,
    ),
    'noodles': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Grain',
      matchWeight: 0.8,
    ),
    'bread': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Grain',
      matchWeight: 0.8,
    ),
    'flour': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Grain',
      matchWeight: 0.8,
    ),
    'wheat flour': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Grain',
      matchWeight: 0.8,
    ),
    'string hoppers': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Grain',
      matchWeight: 0.8,
    ),

    // Fruits (essential for fruit-based recipes)
    'banana': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Fruit',
      matchWeight: 0.9,
    ),
    'apple': IngredientCategory(
      importance: IngredientImportance.essential,
      displayName: 'Fruit',
      matchWeight: 0.9,
    ),

    // IMPORTANT INGREDIENTS (Medium match weight)

    // Aromatics and flavor base
    'onions': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Aromatic',
      matchWeight: 0.6,
    ),
    'red onions': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Aromatic',
      matchWeight: 0.6,
    ),
    'big onions': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Aromatic',
      matchWeight: 0.6,
    ),
    'shallots': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Aromatic',
      matchWeight: 0.6,
    ),
    'garlic': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Aromatic',
      matchWeight: 0.6,
    ),
    'ginger': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Aromatic',
      matchWeight: 0.6,
    ),
    'tomatoes': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Aromatic',
      matchWeight: 0.6,
    ),
    'green chilies': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Aromatic',
      matchWeight: 0.6,
    ),
    'red chilies': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Aromatic',
      matchWeight: 0.6,
    ),

    // Coconut products
    'coconut': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Coconut Product',
      matchWeight: 0.7,
    ),
    'coconut milk': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Coconut Product',
      matchWeight: 0.7,
    ),
    'coconut cream': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Coconut Product',
      matchWeight: 0.7,
    ),
    'desiccated coconut': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Coconut Product',
      matchWeight: 0.7,
    ),
    'coconut oil': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Coconut Product',
      matchWeight: 0.7,
    ),

    // Secondary vegetables
    'leeks': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Vegetable',
      matchWeight: 0.5,
    ),
    'carrots': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Vegetable',
      matchWeight: 0.5,
    ),
    'capsicum': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Vegetable',
      matchWeight: 0.5,
    ),
    'bell pepper': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Vegetable',
      matchWeight: 0.5,
    ),
    'bell peppers': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Vegetable',
      matchWeight: 0.5,
    ),
    'mushrooms': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Vegetable',
      matchWeight: 0.5,
    ),
    'spinach': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Leafy Green',
      matchWeight: 0.5,
    ),
    'kale': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Leafy Green',
      matchWeight: 0.5,
    ),
    'gotukola': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Leafy Green',
      matchWeight: 0.5,
    ),
    'mukunuwenna': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Leafy Green',
      matchWeight: 0.5,
    ),
    'kathurumurunga': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Leafy Green',
      matchWeight: 0.5,
    ),

    // SUPPLEMENTARY INGREDIENTS (Low match weight)

    // Fresh herbs
    'curry leaves': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Fresh Herb',
      matchWeight: 0.3,
    ),
    'karapincha': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Fresh Herb',
      matchWeight: 0.3,
    ),
    'coriander': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Fresh Herb',
      matchWeight: 0.3,
    ),
    'cilantro': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Fresh Herb',
      matchWeight: 0.3,
    ),
    'mint': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Fresh Herb',
      matchWeight: 0.3,
    ),
    'basil': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Fresh Herb',
      matchWeight: 0.3,
    ),
    'dill': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Fresh Herb',
      matchWeight: 0.3,
    ),
    'parsley': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Fresh Herb',
      matchWeight: 0.3,
    ),
    'lemongrass': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Fresh Herb',
      matchWeight: 0.3,
    ),
    'pandan': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Fresh Herb',
      matchWeight: 0.3,
    ),

    // Key spices (supplementary for core matching but should still contribute)
    'cinnamon': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),
    'cinnamon powder': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),
    'cardamom': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),
    'cardamom powder': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),
    'cloves': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),
    'clove powder': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),
    'nutmeg': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),
    'star anise': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),
    'fennel': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),
    'fenugreek': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),
    'mustard seeds': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),
    'cumin': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),
    'coriander seeds': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Spice',
      matchWeight: 0.2,
    ),

    // EXCLUDED INGREDIENTS (No match weight - excluded from core matching)
    'salt': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Basic Seasoning',
      matchWeight: 0.0,
    ),
    'pepper': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Basic Seasoning',
      matchWeight: 0.0,
    ),
    'black pepper': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Basic Seasoning',
      matchWeight: 0.0,
    ),
    'white pepper': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Basic Seasoning',
      matchWeight: 0.0,
    ),

    // Baking
    'sugar': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Baking Ingredient',
      matchWeight: 0.5,
    ),
    'brown sugar': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Baking Ingredient',
      matchWeight: 0.5,
    ),
    'butter': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Baking Ingredient',
      matchWeight: 0.6,
    ),
    'margarine': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Baking Ingredient',
      matchWeight: 0.6,
    ),
    'baking powder': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Baking Ingredient',
      matchWeight: 0.4,
    ),
    'baking soda': IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Baking Ingredient',
      matchWeight: 0.4,
    ),
    'vanilla extract': IngredientCategory(
      importance: IngredientImportance.supplementary,
      displayName: 'Baking Extract',
      matchWeight: 0.3,
    ),

    // Common spice powders (too basic to be meaningful for core matching)
    'turmeric': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Common Spice',
      matchWeight: 0.0,
    ),
    'turmeric powder': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Common Spice',
      matchWeight: 0.0,
    ),
    'chili powder': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Common Spice',
      matchWeight: 0.0,
    ),
    'red chili powder': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Common Spice',
      matchWeight: 0.0,
    ),
    'curry powder': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Common Spice',
      matchWeight: 0.0,
    ),
    'roasted curry powder': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Common Spice',
      matchWeight: 0.0,
    ),
    'unroasted curry powder': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Common Spice',
      matchWeight: 0.0,
    ),

    // Liquids and basics (assumed to be available)
    'water': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Basic Liquid',
      matchWeight: 0.0,
    ),
    'oil': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Basic Liquid',
      matchWeight: 0.0,
    ),
    'cooking oil': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Basic Liquid',
      matchWeight: 0.0,
    ),
    'vegetable oil': IngredientCategory(
      importance: IngredientImportance.excluded,
      displayName: 'Basic Liquid',
      matchWeight: 0.0,
    ),
  };

  /// ===== Aliases (normalized to canonical keys) =====
  static const Map<String, List<String>> _ingredientAliases = {
    // Protein aliases
    'chicken': [
      'chicken breast',
      'chicken thigh',
      'chicken pieces',
      'chicken curry cut',
      'boneless chicken',
    ],
    'fish': [
      'fresh fish',
      'fish fillets',
      'fish pieces',
      'sea fish',
      'river fish',
    ],
    'prawns': ['shrimp', 'jumbo prawns', 'medium prawns'],
    'eggs': ['egg', 'chicken eggs', 'fresh eggs', 'large eggs', 'medium eggs', 'whole eggs'],
    'egg': ['eggs', 'chicken eggs', 'fresh eggs', 'large eggs', 'medium eggs', 'whole eggs'],
    'lentils': [
      'red lentils',
      'yellow lentils',
      'green lentils',
      'masoor dal',
      'toor dal',
      'parippu',
    ],

    // Vegetable aliases
    'potatoes': ['potato', 'new potatoes', 'baby potatoes'],
    'sweet potatoes': ['sweet potato', 'orange sweet potato'],
    'brinjal': ['eggplant', 'aubergine', 'baby brinjal', 'large brinjal'],
    'okra': ['ladies fingers', 'ladies finger', 'bandakka'],
    'beans': ['common beans', 'bush beans'],
    'green beans': [
      'french beans',
      'string beans',
    ], // NOTE: removed plain 'beans' to avoid ambiguity
    'long beans': ['snake beans', 'yard long beans'],
    'drumsticks': ['murunga', 'moringa pods', 'murunga kaya'],
    'jackfruit': ['young jackfruit', 'jackfruit pieces', 'polos'],
    'bell peppers': ['bell pepper', 'capsicum'],

    // Grain aliases
    'rice': [
      'white rice',
      'jasmine rice',
      'long grain rice',
      'short grain rice',
      'cooked rice',
      'boiled rice',
      'steamed rice',
      'leftover rice',
      'fried rice rice',
    ],
    'red rice': ['brown rice', 'unpolished rice'],
    'wheat flour': [
      'all purpose flour',
      'plain flour', 
      'atta flour',
      'white flour',
      'flour',
      'all-purpose flour',
      'ap flour',
      'refined flour',
      'maida',
    ],
    'noodles': [
      'egg noodles',
      'rice noodles',
      'stringhoppers',
      'string hoppers',
      'idiyappam',
    ],

    // Aromatic aliases
    'onions': ['onion', 'yellow onions', 'cooking onions'],
    'red onions': ['red onion', 'purple onions'],
    'big onions': ['large onions', 'big onion'],
    'shallots': ['small onions', 'pearl onions', 'rathu lunu'],
    'tomatoes': ['tomato', 'fresh tomatoes', 'ripe tomatoes'],
    'green chilies': [
      'green chili',
      'green chilli',
      'fresh green chilies',
      'green chillies',
    ],
    'red chilies': [
      'red chili',
      'red chilli',
      'fresh red chilies',
      'dried red chilies',
      'red chillies',
    ],

    // Coconut aliases
    'coconut milk': [
      'thick coconut milk',
      'thin coconut milk',
      'canned coconut milk',
    ],
    'coconut': ['fresh coconut', 'grated coconut', 'coconut pieces'],
    'desiccated coconut': ['dried coconut', 'coconut flakes'],

    // Herb aliases
    'curry leaves': ['karapincha', 'fresh curry leaves', 'curry leaf'],
    'coriander': ['cilantro', 'fresh coriander', 'coriander leaves'],
    'mint': ['fresh mint', 'mint leaves'],
    'basil': ['fresh basil', 'thai basil'],
    'lemongrass': ['lemon grass', 'citronella'],

    // Spice aliases
    'cinnamon': [
      'cinnamon stick',
      'cinnamon sticks',
      'ground cinnamon',
      'cinnamon powder',
    ],
    'cinnamon powder': [
      'ground cinnamon',
      'cinnamon',
      'cinnamon spice',
      'powdered cinnamon',
    ],
    'cardamom': ['green cardamom', 'cardamom pods', 'cardamom powder'],
    'cardamom powder': [
      'ground cardamom',
      'cardamom',
      'green cardamom powder',
      'powdered cardamom',
    ],
    'cloves': ['whole cloves', 'ground cloves', 'clove powder'],
    'clove powder': [
      'ground cloves',
      'cloves',
      'powdered cloves',
    ],
    'turmeric': ['turmeric powder', 'ground turmeric', 'haldi'],
    'chili powder': ['red chili powder', 'cayenne powder'],
    'curry powder': ['sri lankan curry powder', 'homemade curry powder'],

    // Fruit aliases
    'banana': [
      'bananas',
      'ripe banana',
      'ripe bananas', 
      'overripe banana',
      'overripe bananas',
      'mashed banana',
      'mashed bananas',
      'banana puree',
      'fresh banana',
      'fresh bananas',
    ],
    'apple': ['apples', 'green apple', 'red apple'],

    // Baking ingredient aliases
    'sugar': ['white sugar', 'granulated sugar', 'caster sugar'],
    'brown sugar': ['dark brown sugar', 'light brown sugar'],
    'butter': ['unsalted butter', 'salted butter', 'fresh butter'],
    'baking soda': ['bicarbonate of soda', 'sodium bicarbonate'],
    'baking powder': ['double acting baking powder'],
    'vanilla extract': ['pure vanilla extract', 'vanilla essence', 'vanilla', 'vanilla flavoring', 'liquid vanilla'],
  };

  /// Reverse alias index for O(1) lookup of main ingredient by alias.
  static final Map<String, String> _aliasToMain = _buildAliasToMain();

  static Map<String, String> _buildAliasToMain() {
    final Map<String, String> map = {};
    for (final e in _ingredientAliases.entries) {
      final main = _normalizeIngredientName(e.key);
      // Map the main term to itself too (helps when singular/plural normalization kicks in)
      map[main] = main;
      for (final a in e.value) {
        map[_normalizeIngredientName(a)] = main;
      }
    }
    return map;
  }

  /// Common preparation adjectives/noise to drop during normalization.
  static const Set<String> _prepStop = {
    'leftover',
    'cooked',
    'boiled',
    'fried',
    'ripe',
    'fresh',
    'raw',
    'grated',
    'chopped',
    'sliced',
    'diced',
    'minced',
    'shredded',
    'ground',
    'powdered',
    'whole',
    'dry',
    'dried',
    'small',
    'medium',
    'large',
    'boneless',
    'skinless',
    'with',
    'without',
    'skin',
    'pieces',
    'fillet',
    'fillets',
    'cubes',
    'julienned',
    'thin',
    'thick',
    'green',
    'red',
    'yellow',
    'hot',
    'mild',
    'sweet',
    'sour',
  };

  /// Lemmas/unifications for common variants (en-GB vs en-US, plurals irregulars).
  static const Map<String, String> _lemmaMap = {
    'chilies': 'chili',
    'chillies': 'chili',
    'tomatoes': 'tomato',
    'potatoes': 'potato',
    'buses': 'bus',
    'mice': 'mouse', // general example; unlikely used
  };

  static const Set<String> _excludedTokens = {'salt', 'pepper', 'water', 'oil'};

  /// ===== Public API =====

  static IngredientCategory categorizeIngredient(String ingredientName) {
    final normalizedName = _normalizeIngredientName(ingredientName);

    // Check cache first
    final cached = _categoryCache[normalizedName];
    if (cached != null) return cached;

    IngredientCategory category;

    // Direct canonical hit
    if (_ingredientCategories.containsKey(normalizedName)) {
      category = _ingredientCategories[normalizedName]!;
    } else {
      // Alias (exact) -> main
      final main = _aliasToMain[normalizedName];
      if (main != null && _ingredientCategories.containsKey(main)) {
        category = _ingredientCategories[main]!;
      } else {
        // Fallback: heuristics with fuzzy support
        category = _getDefaultCategory(normalizedName);
      }
    }

    _categoryCache[normalizedName] = category;
    return category;
  }

  static bool shouldIncludeInCoreMatching(String ingredientName) {
    final category = categorizeIngredient(ingredientName);
    return category.importance != IngredientImportance.excluded;
  }

  static bool isEssentialIngredient(String ingredientName) {
    final category = categorizeIngredient(ingredientName);
    return category.importance == IngredientImportance.essential;
  }

  static double getIngredientWeight(String ingredientName) {
    final category = categorizeIngredient(ingredientName);
    return category.matchWeight;
  }

  static List<String> getIngredientAliases(String ingredientName) {
    final normalized = _normalizeIngredientName(ingredientName);
    // Try canonical
    if (_ingredientAliases.containsKey(normalized)) {
      return _ingredientAliases[normalized]!;
    }
    // Try via alias->main
    final main = _aliasToMain[normalized];
    if (main != null && _ingredientAliases.containsKey(main)) {
      return _ingredientAliases[main]!;
    }
    return const [];
  }

  static Map<IngredientImportance, List<String>> groupIngredientsByImportance(
    List<String> ingredients,
  ) {
    final Map<IngredientImportance, List<String>> groups = {
      IngredientImportance.essential: [],
      IngredientImportance.important: [],
      IngredientImportance.supplementary: [],
      IngredientImportance.excluded: [],
    };
    for (final ingredient in ingredients) {
      final category = categorizeIngredient(ingredient);
      groups[category.importance]!.add(ingredient);
    }
    return groups;
  }

  // Cache ops
  static void clearCache() => _categoryCache.clear();
  static int get cacheSize => _categoryCache.length;

  /// ===== Heuristics & Helpers =====

  static IngredientCategory _getDefaultCategory(String name) {
    // Excluded overrides (only if we didn’t match a canonical/alias above)
    if (_containsExcludedToken(name)) {
      return const IngredientCategory(
        importance: IngredientImportance.excluded,
        displayName: 'Basic',
        matchWeight: 0.0,
      );
    }

    if (_isProtein(name)) {
      return const IngredientCategory(
        importance: IngredientImportance.essential,
        displayName: 'Protein',
        matchWeight: 1.0,
      );
    }

    if (_isVegetable(name)) {
      return const IngredientCategory(
        importance: IngredientImportance.essential,
        displayName: 'Vegetable',
        matchWeight: 0.9,
      );
    }

    if (_isGrain(name)) {
      return const IngredientCategory(
        importance: IngredientImportance.essential,
        displayName: 'Grain',
        matchWeight: 0.8,
      );
    }

    if (_isSpice(name)) {
      return const IngredientCategory(
        importance: IngredientImportance.supplementary,
        displayName: 'Spice',
        matchWeight: 0.2,
      );
    }

    // Default: treat as important ingredient
    return const IngredientCategory(
      importance: IngredientImportance.important,
      displayName: 'Other',
      matchWeight: 0.5,
    );
  }

  static bool _containsExcludedToken(String normalizedName) {
    final words = normalizedName.split(' ');
    for (final w in words) {
      if (_excludedTokens.contains(w)) return true;
    }
    return false;
  }

  static bool _isProtein(String name) {
    final proteinKeywords = [
      'chicken',
      'fish',
      'egg',
      'eggs',
      'beef',
      'meat',
      'prawn',
      'prawns',
      'dal',
      'lentil',
      'lentils',
      'mutton',
      'lamb',
      'pork',
      'duck',
      'crab',
      'lobster',
      'tofu',
      'tempeh',
    ];
    return proteinKeywords.any((k) => name.contains(k));
  }

  static bool _isVegetable(String name) {
    final vegetableKeywords = [
      'carrot', 'bean', 'beans', 'pea', 'peas', 'corn', 'lettuce', 'spinach',
      'kale',
      'beetroot',
      'radish',
      'turnip',
      'parsnip',
      'broccoli',
      'cauliflower',
      'brinjal',
      'eggplant',
      'okra',
      'bandakka',
      'cabbage',
      'capsicum',
      'pepper', // bell pepper/capsicum
      'jackfruit', 'polos', 'murunga', 'drumstick', 'moringa', 'leek', 'leeks',
    ];
    return vegetableKeywords.any((k) => name.contains(k));
  }

  static bool _isGrain(String name) {
    final grainKeywords = [
      'rice',
      'noodle',
      'noodles',
      'pasta',
      'bread',
      'flour',
      'atta',
      'wheat',
    ];
    return grainKeywords.any((k) => name.contains(k));
  }

  static bool _isSpice(String name) {
    // If it looks like a prepared spice form, treat as spice unless explicitly excluded already.
    final spiceFormKeywords = [
      'powder',
      'ground',
      'whole',
      'seed',
      'masala',
      'garam',
      'paste',
    ];
    final commonSpices = [
      'turmeric', 'coriander', 'cumin', 'fenugreek', 'fennel', 'mustard',
      'cardamom',
      'clove',
      'cloves',
      'cinnamon',
      'nutmeg',
      'anise',
      'star anise',
      'pepper', // handled by excluded if basic; left here for general spice detection
    ];
    return spiceFormKeywords.any((k) => name.contains(k)) ||
        commonSpices.any((k) => name.contains(k));
  }

  static String _normalizeIngredientName(String ingredientName) {
    // Lowercase, strip punctuation to spaces, collapse spaces
    String s = ingredientName
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Split → intelligent prep word removal → lemma map → singularize
    final words = s
        .split(' ')
        .where((w) => w.isNotEmpty && !_shouldRemoveWord(w, s))
        .map((w) => _lemmaMap[w] ?? w)
        .map(_singularize)
        .toList();

    s = words.join(' ').trim();

    // Special collapses (e.g., multiword forms post-stopword removal)
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    return s;
  }

  /// Intelligent word removal that preserves important spice form descriptors
  static bool _shouldRemoveWord(String word, String fullIngredientName) {
    // Never remove these spice form descriptors
    const spiceFormWords = {
      'powder', 'powdered', 'ground', 'whole', 'paste', 'extract'
    };
    
    // If it's a spice form word, only remove if it's clearly redundant
    if (spiceFormWords.contains(word)) {
      // Don't remove form words for spices
      return false;
    }
    
    // For other words, use the normal prep stop list
    return _prepStop.contains(word);
  }

  static String _singularize(String w) {
    if (_lemmaMap.containsKey(w)) return _lemmaMap[w]!;
    if (w.endsWith('ies') && w.length > 3) {
      return w.substring(0, w.length - 3) + 'y'; // chilies -> chili
    }
    if (w.endsWith('oes') && w.length > 3) {
      return w.substring(0, w.length - 2); // tomatoes -> tomato
    }
    if (w.endsWith('ses') && w.length > 3) {
      return w.substring(0, w.length - 2); // buses -> bus
    }
    if (w.endsWith('s') && w.length > 3 && !w.endsWith('ss')) {
      return w.substring(0, w.length - 1);
    }
    return w;
  }

  /// Fuzzy ingredient string match used in some flows (not needed for direct categorize, but available).
  static bool isLikelySameIngredient(String a, String b) {
    final s1 = _normalizeIngredientName(a);
    final s2 = _normalizeIngredientName(b);
    if (s1.isEmpty || s2.isEmpty) return false;
    if (s1 == s2) return true;
    if (s1.contains(s2) || s2.contains(s1)) return true;

    final t1 = s1.split(' ').where((w) => w.length > 2).toSet();
    final t2 = s2.split(' ').where((w) => w.length > 2).toSet();
    if (t1.isEmpty || t2.isEmpty) return false;
    final inter = t1.intersection(t2).length;
    final uni = t1.union(t2).length;
    final jaccard = inter / uni;
    return jaccard >= 0.5;
  }
}
