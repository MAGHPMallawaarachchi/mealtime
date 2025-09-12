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
  Future<List<SeasonalIngredient>> getSeasonalIngredients() async {
    try {
      // Always fetch from server to ensure fresh data
      List<SeasonalIngredient> remoteIngredients;
      
      if (_remoteDataSource is SeasonalIngredientsFirebaseDataSource) {
        // Always force fetch from server to bypass all caches
        remoteIngredients = await (_remoteDataSource as SeasonalIngredientsFirebaseDataSource).getSeasonalIngredientsFromServer();
      } else {
        remoteIngredients = await _remoteDataSource.getSeasonalIngredients();
      }
      
      return remoteIngredients;
    } catch (e) {
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
      return await _remoteDataSource.getSeasonalIngredientById(id);
    } catch (e) {
      throw SeasonalIngredientsRepositoryException(
        'Failed to fetch seasonal ingredient with id $id: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> refreshSeasonalIngredients() async {
    try {
      await getSeasonalIngredients();
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