import '../domain/models/seasonal_ingredient.dart';

class DummySeasonalData {
  static List<SeasonalIngredient> getSeasonalIngredients() {
    return [
      const SeasonalIngredient(
        id: 'mango',
        name: 'Mango',
        imageUrl:
            'https://freedomjars.ca/cdn/shop/products/AdobeStock_240311486_1600x.jpg?v=1591200616?w=800&h=600&fit=crop',
        description:
            'Sweet, tropical mangoes are at their peak during summer months in Sri Lanka.',
      ),
      const SeasonalIngredient(
        id: 'avocado',
        name: 'Avocado',
        imageUrl:
            'https://blog.lexmed.com/images/librariesprovider80/blog-post-featured-images/avocadosea5afd66b7296e538033ff0000e6f23e.jpg?sfvrsn=a273930b_0?w=800&h=600&fit=crop',
        description:
            'Creamy avocados are abundant during the rainy season, perfect for healthy meals.',
      ),
      const SeasonalIngredient(
        id: 'jackfruit',
        name: 'Jackfruit',
        imageUrl:
            'https://www.gardenia.net/wp-content/uploads/2025/05/shutterstock_2453997129.jpg?w=800&h=600&fit=crop',
        description:
            'Large, sweet jackfruits are a seasonal favorite, great for curries and desserts.',
      ),
      const SeasonalIngredient(
        id: 'coconut',
        name: 'Coconut',
        imageUrl:
            'https://5.imimg.com/data5/SELLER/Default/2025/5/510397718/MX/XI/WK/32300332/pure-coconut-oil-500x500.jpg?w=800&h=600&fit=crop',
        description:
            'Fresh coconuts are available year-round and essential in Sri Lankan cooking.',
      ),
      const SeasonalIngredient(
        id: 'papaya',
        name: 'Papaya',
        imageUrl:
            'https://lirp.cdn-website.com/7a5d8045/dms3rep/multi/opt/papaya+fruit-640w.jpg?w=800&h=600&fit=crop',
        description:
            'Sweet papayas are perfect for salads and traditional Sri Lankan preparations.',
      ),
      const SeasonalIngredient(
        id: 'pineapple',
        name: 'Pineapple',
        imageUrl:
            'https://images.contentstack.io/v3/assets/bltcedd8dbd5891265b/blt67e90f4668076285/667081330cc0e5049ca6b14a/types-of-pineapple-hero.jpg?q=70&width=3840&auto=webp?w=800&h=600&fit=crop',
        description:
            'Juicy pineapples add tropical sweetness to curries and chutneys.',
      ),
    ];
  }

  static SeasonalIngredient? getSeasonalIngredientById(String id) {
    try {
      return getSeasonalIngredients().firstWhere(
        (ingredient) => ingredient.id == id,
      );
    } catch (e) {
      return null;
    }
  }
}
