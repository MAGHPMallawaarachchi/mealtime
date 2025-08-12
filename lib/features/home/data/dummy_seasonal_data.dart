import '../domain/models/seasonal_ingredient.dart';

class DummySeasonalData {
  static List<SeasonalIngredient> getSeasonalIngredients() {
    return [
      const SeasonalIngredient(
        id: 'mango',
        name: 'Mango',
        imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=800&h=600&fit=crop',
        description: 'Sweet, tropical mangoes are at their peak during summer months in Sri Lanka.',
      ),
      const SeasonalIngredient(
        id: 'avocado',
        name: 'Avocado',
        imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=800&h=600&fit=crop',
        description: 'Creamy avocados are abundant during the rainy season, perfect for healthy meals.',
      ),
      const SeasonalIngredient(
        id: 'jackfruit',
        name: 'Jackfruit',
        imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800&h=600&fit=crop',
        description: 'Large, sweet jackfruits are a seasonal favorite, great for curries and desserts.',
      ),
      const SeasonalIngredient(
        id: 'coconut',
        name: 'Coconut',
        imageUrl: 'https://images.unsplash.com/photo-1447754749270-1c23aba09adf?w=800&h=600&fit=crop',
        description: 'Fresh coconuts are available year-round and essential in Sri Lankan cooking.',
      ),
      const SeasonalIngredient(
        id: 'papaya',
        name: 'Papaya',
        imageUrl: 'https://images.unsplash.com/photo-1600359756350-809ac8019418?w=800&h=600&fit=crop',
        description: 'Sweet papayas are perfect for salads and traditional Sri Lankan preparations.',
      ),
      const SeasonalIngredient(
        id: 'pineapple',
        name: 'Pineapple',
        imageUrl: 'https://images.unsplash.com/photo-1576990632741-c6b86ca87a18?w=800&h=600&fit=crop',
        description: 'Juicy pineapples add tropical sweetness to curries and chutneys.',
      ),
    ];
  }

  static SeasonalIngredient? getSeasonalIngredientById(String id) {
    try {
      return getSeasonalIngredients().firstWhere((ingredient) => ingredient.id == id);
    } catch (e) {
      return null;
    }
  }
}