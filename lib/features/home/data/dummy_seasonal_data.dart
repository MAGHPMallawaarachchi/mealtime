import '../domain/models/seasonal_ingredient.dart';

@Deprecated('Use GetSeasonalIngredientsUseCase instead')
class DummySeasonalData {
  static List<SeasonalIngredient> getSeasonalIngredients() {
    return [];
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
