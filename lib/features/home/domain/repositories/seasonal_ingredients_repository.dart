import '../models/seasonal_ingredient.dart';

abstract class SeasonalIngredientsRepository {
  Future<List<SeasonalIngredient>> getSeasonalIngredients();
  Stream<List<SeasonalIngredient>> getSeasonalIngredientsStream();
  Future<SeasonalIngredient?> getSeasonalIngredientById(String id);
  Future<void> refreshSeasonalIngredients();
}