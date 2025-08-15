import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/seasonal_ingredient.dart';
import 'seasonal_ingredients_datasource.dart';

class SeasonalIngredientsLocalDataSource implements SeasonalIngredientsDataSource {
  static const String _cacheKey = 'seasonal_ingredients_cache';
  static const String _lastUpdatedKey = 'seasonal_ingredients_last_updated';
  static const Duration _cacheValidDuration = Duration(hours: 24);

  @override
  Future<List<SeasonalIngredient>> getSeasonalIngredients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      
      if (cachedData == null) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(cachedData);
      return jsonList.map((json) => SeasonalIngredient.fromJson(json)).toList();
    } catch (e) {
      throw SeasonalIngredientsLocalDataSourceException(
        'Failed to load cached seasonal ingredients: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<SeasonalIngredient>> getSeasonalIngredientsStream() {
    throw UnsupportedError('Local data source does not support streams');
  }

  @override
  Future<SeasonalIngredient?> getSeasonalIngredientById(String id) async {
    try {
      final ingredients = await getSeasonalIngredients();
      try {
        return ingredients.firstWhere((ingredient) => ingredient.id == id);
      } catch (e) {
        return null;
      }
    } catch (e) {
      throw SeasonalIngredientsLocalDataSourceException(
        'Failed to find seasonal ingredient with id $id: ${e.toString()}',
      );
    }
  }

  Future<void> cacheSeasonalIngredients(List<SeasonalIngredient> ingredients) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = ingredients.map((ingredient) => ingredient.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(_lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw SeasonalIngredientsLocalDataSourceException(
        'Failed to cache seasonal ingredients: ${e.toString()}',
      );
    }
  }

  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdated = prefs.getInt(_lastUpdatedKey);
      
      if (lastUpdated == null) {
        return false;
      }

      final lastUpdatedDate = DateTime.fromMillisecondsSinceEpoch(lastUpdated);
      final now = DateTime.now();
      
      return now.difference(lastUpdatedDate) < _cacheValidDuration;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastUpdatedKey);
    } catch (e) {
      throw SeasonalIngredientsLocalDataSourceException(
        'Failed to clear cache: ${e.toString()}',
      );
    }
  }
}

class SeasonalIngredientsLocalDataSourceException implements Exception {
  final String message;

  SeasonalIngredientsLocalDataSourceException(this.message);

  @override
  String toString() => 'SeasonalIngredientsLocalDataSourceException: $message';
}