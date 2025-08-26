import '../models/seasonal_ingredient.dart';
import '../repositories/seasonal_ingredients_repository.dart';
import '../../data/repositories/seasonal_ingredients_repository_impl.dart';

class GetSeasonalIngredientsUseCase {
  final SeasonalIngredientsRepository _repository;

  GetSeasonalIngredientsUseCase({
    SeasonalIngredientsRepository? repository,
  }) : _repository = repository ?? SeasonalIngredientsRepositoryImpl();

  Future<List<SeasonalIngredient>> call({bool forceRefresh = false}) async {
    try {
      final ingredients = await _repository.getSeasonalIngredients(forceRefresh: forceRefresh);
      
      return ingredients;
    } catch (e) {
      throw GetSeasonalIngredientsUseCaseException(
        'Failed to get seasonal ingredients: ${e.toString()}',
      );
    }
  }

  Stream<List<SeasonalIngredient>> getStream() {
    try {
      return _repository.getSeasonalIngredientsStream();
    } catch (e) {
      throw GetSeasonalIngredientsUseCaseException(
        'Failed to get seasonal ingredients stream: ${e.toString()}',
      );
    }
  }

  Future<void> refresh() async {
    try {
      await _repository.refreshSeasonalIngredients();
    } catch (e) {
      throw GetSeasonalIngredientsUseCaseException(
        'Failed to refresh seasonal ingredients: ${e.toString()}',
      );
    }
  }
}

class GetSeasonalIngredientsUseCaseException implements Exception {
  final String message;

  GetSeasonalIngredientsUseCaseException(this.message);

  @override
  String toString() => 'GetSeasonalIngredientsUseCaseException: $message';
}