import '../../domain/models/seasonal_ingredient.dart';
import 'seasonal_ingredients_datasource.dart';

class SeasonalIngredientsLocalDataSource implements SeasonalIngredientsDataSource {
  @override
  Future<List<SeasonalIngredient>> getSeasonalIngredients() async {
    return [];
  }

  @override
  Stream<List<SeasonalIngredient>> getSeasonalIngredientsStream() {
    throw UnsupportedError('Local data source does not support streams');
  }

  @override
  Future<SeasonalIngredient?> getSeasonalIngredientById(String id) async {
    return null;
  }

  Future<void> cacheSeasonalIngredients(List<SeasonalIngredient> ingredients) async {
    // No-op: caching disabled for seasonal ingredients
  }

  Future<bool> isCacheValid() async {
    return false;
  }

  Future<void> clearCache() async {
    // No-op: caching disabled for seasonal ingredients
  }
}

class SeasonalIngredientsLocalDataSourceException implements Exception {
  final String message;

  SeasonalIngredientsLocalDataSourceException(this.message);

  @override
  String toString() => 'SeasonalIngredientsLocalDataSourceException: $message';
}