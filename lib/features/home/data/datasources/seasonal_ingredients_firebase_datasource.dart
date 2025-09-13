import '../../../../core/services/firestore_service.dart';
import '../../domain/models/seasonal_ingredient.dart';
import 'seasonal_ingredients_datasource.dart';

class SeasonalIngredientsFirebaseDataSource implements SeasonalIngredientsDataSource {
  static const String _collectionPath = 'seasonal_ingredients';
  
  final FirestoreService _firestoreService;

  SeasonalIngredientsFirebaseDataSource({
    FirestoreService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<List<SeasonalIngredient>> getSeasonalIngredients() async {
    try {
      final rawData = await _firestoreService.getCollectionWithQuery(
        _collectionPath,
        orderBy: 'name',
        descending: false,
      );

      return rawData.map((data) => SeasonalIngredient.fromJson(data)).toList();
    } catch (e) {
      throw SeasonalIngredientsDataSourceException(
        'Failed to fetch seasonal ingredients: ${e.toString()}',
      );
    }
  }

  Future<List<SeasonalIngredient>> getSeasonalIngredientsFromServer() async {
    try {
      final rawData = await _firestoreService.getCollectionWithQueryFromServer(
        _collectionPath,
        orderBy: 'name',
        descending: false,
      );

      return rawData.map((data) => SeasonalIngredient.fromJson(data)).toList();
    } catch (e) {
      throw SeasonalIngredientsDataSourceException(
        'Failed to fetch seasonal ingredients from server: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<SeasonalIngredient>> getSeasonalIngredientsStream() {
    try {
      return _firestoreService.getCollectionStream(_collectionPath).map(
        (rawDataList) => rawDataList
            .map((data) => SeasonalIngredient.fromJson(data))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name)),
      );
    } catch (e) {
      throw SeasonalIngredientsDataSourceException(
        'Failed to stream seasonal ingredients: ${e.toString()}',
      );
    }
  }

  @override
  Future<SeasonalIngredient?> getSeasonalIngredientById(String id) async {
    try {
      final rawData = await _firestoreService.getDocument(_collectionPath, id);
      
      if (rawData == null) {
        return null;
      }

      return SeasonalIngredient.fromJson(rawData);
    } catch (e) {
      throw SeasonalIngredientsDataSourceException(
        'Failed to fetch seasonal ingredient with id $id: ${e.toString()}',
      );
    }
  }
}

class SeasonalIngredientsDataSourceException implements Exception {
  final String message;

  SeasonalIngredientsDataSourceException(this.message);

  @override
  String toString() => 'SeasonalIngredientsDataSourceException: $message';
}