import '../../domain/models/seasonal_ingredient.dart';

abstract class SeasonalIngredientsDataSource {
  Future<List<SeasonalIngredient>> getSeasonalIngredients();
  Stream<List<SeasonalIngredient>> getSeasonalIngredientsStream();
  Future<SeasonalIngredient?> getSeasonalIngredientById(String id);
}