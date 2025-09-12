import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/seasonal_ingredient.dart';
import '../../domain/repositories/seasonal_ingredients_repository.dart';
import '../datasources/seasonal_ingredients_datasource.dart';
import '../datasources/seasonal_ingredients_firebase_datasource.dart';
import '../datasources/seasonal_ingredients_local_datasource.dart';

class SeasonalIngredientsRepositoryImpl implements SeasonalIngredientsRepository {
  final SeasonalIngredientsDataSource _remoteDataSource;
  final SeasonalIngredientsLocalDataSource _localDataSource;

  SeasonalIngredientsRepositoryImpl({
    SeasonalIngredientsDataSource? remoteDataSource,
    SeasonalIngredientsLocalDataSource? localDataSource,
  })  : _remoteDataSource = remoteDataSource ?? SeasonalIngredientsFirebaseDataSource(),
        _localDataSource = localDataSource ?? SeasonalIngredientsLocalDataSource();

  @override
  Future<List<SeasonalIngredient>> getSeasonalIngredients({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && await _localDataSource.isCacheValid()) {
        final cachedIngredients = await _localDataSource.getSeasonalIngredients();
        if (cachedIngredients.isNotEmpty) {
          return cachedIngredients;
        }
      }

      final remoteIngredients = await _remoteDataSource.getSeasonalIngredients();
      
      await _localDataSource.cacheSeasonalIngredients(remoteIngredients);
      
      return remoteIngredients;
    } catch (e) {
      
      try {
        final cachedIngredients = await _localDataSource.getSeasonalIngredients();
        if (cachedIngredients.isNotEmpty) {
          return cachedIngredients;
        }
      } catch (cacheError) {
      }
      
      throw SeasonalIngredientsRepositoryException(
        'Failed to fetch seasonal ingredients: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<SeasonalIngredient>> getSeasonalIngredientsStream() {
    try {
      return _remoteDataSource.getSeasonalIngredientsStream().handleError((error) {
        throw SeasonalIngredientsRepositoryException(
          'Failed to stream seasonal ingredients: ${error.toString()}',
        );
      });
    } catch (e) {
      throw SeasonalIngredientsRepositoryException(
        'Failed to create seasonal ingredients stream: ${e.toString()}',
      );
    }
  }

  @override
  Future<SeasonalIngredient?> getSeasonalIngredientById(String id) async {
    try {
      final ingredient = await _remoteDataSource.getSeasonalIngredientById(id);
      if (ingredient != null) {
        return ingredient;
      }

      return await _localDataSource.getSeasonalIngredientById(id);
    } catch (e) {
      
      try {
        return await _localDataSource.getSeasonalIngredientById(id);
      } catch (cacheError) {
      }
      
      throw SeasonalIngredientsRepositoryException(
        'Failed to fetch seasonal ingredient with id $id: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> refreshSeasonalIngredients() async {
    try {
      await getSeasonalIngredients(forceRefresh: true);
    } catch (e) {
      throw SeasonalIngredientsRepositoryException(
        'Failed to refresh seasonal ingredients: ${e.toString()}',
      );
    }
  }
}

class SeasonalIngredientsRepositoryException implements Exception {
  final String message;

  SeasonalIngredientsRepositoryException(this.message);

  @override
  String toString() => 'SeasonalIngredientsRepositoryException: $message';
}