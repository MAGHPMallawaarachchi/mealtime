import '../../../../core/services/time_service.dart';
import '../models/seasonal_ingredient.dart';
import '../repositories/seasonal_ingredients_repository.dart';
import '../../data/repositories/seasonal_ingredients_repository_impl.dart';

class GetCurrentSeasonalIngredientsUseCase {
  final SeasonalIngredientsRepository _repository;
  final TimeService _timeService;
  
  // Cache variables
  List<SeasonalIngredient>? _cachedIngredients;
  DateTime? _cacheTimestamp;
  int? _cachedForMonth;
  
  // Cache duration - cache for 6 hours or until month changes
  static const Duration _cacheDuration = Duration(hours: 6);

  GetCurrentSeasonalIngredientsUseCase({
    SeasonalIngredientsRepository? repository,
    TimeService? timeService,
  })  : _repository = repository ?? SeasonalIngredientsRepositoryImpl(),
        _timeService = timeService ?? TimeServiceImpl();

  Future<List<SeasonalIngredient>> call({bool forceRefresh = false}) async {
    try {
      final currentMonth = _timeService.getCurrentSriLankanMonth();
      
      // Check if cache is valid and not forcing refresh
      if (!forceRefresh && _isCacheValid(currentMonth)) {
        return _cachedIngredients!;
      }
      
      // Fetch fresh data
      final allIngredients = await _repository.getSeasonalIngredients();
      
      final currentSeasonalIngredients = allIngredients
          .where((ingredient) => _isInSeason(ingredient, currentMonth))
          .toList();

      List<SeasonalIngredient> result;
      if (currentSeasonalIngredients.isEmpty) {
        result = _getFallbackIngredients(allIngredients, currentMonth);
      } else {
        result = _prioritizePeakSeasonIngredients(currentSeasonalIngredients, currentMonth);
      }
      
      // Update cache
      _updateCache(result, currentMonth);
      
      return result;
    } catch (e) {
      // If we have cached data and the request fails, return cached data
      if (_cachedIngredients != null && _cachedIngredients!.isNotEmpty) {
        return _cachedIngredients!;
      }
      
      throw GetCurrentSeasonalIngredientsUseCaseException(
        'Failed to get current seasonal ingredients: ${e.toString()}',
      );
    }
  }

  Stream<List<SeasonalIngredient>> getStream() {
    try {
      return _repository.getSeasonalIngredientsStream().map((allIngredients) {
        final currentMonth = _timeService.getCurrentSriLankanMonth();
        
        final currentSeasonalIngredients = allIngredients
            .where((ingredient) => _isInSeason(ingredient, currentMonth))
            .toList();

        if (currentSeasonalIngredients.isEmpty) {
          return _getFallbackIngredients(allIngredients, currentMonth);
        }

        return _prioritizePeakSeasonIngredients(currentSeasonalIngredients, currentMonth);
      });
    } catch (e) {
      throw GetCurrentSeasonalIngredientsUseCaseException(
        'Failed to get current seasonal ingredients stream: ${e.toString()}',
      );
    }
  }

  Future<void> refresh() async {
    try {
      _clearCache();
      await _repository.refreshSeasonalIngredients();
      // Force fresh data fetch
      await call(forceRefresh: true);
    } catch (e) {
      throw GetCurrentSeasonalIngredientsUseCaseException(
        'Failed to refresh current seasonal ingredients: ${e.toString()}',
      );
    }
  }

  bool _isInSeason(SeasonalIngredient ingredient, int currentMonth) {
    if (ingredient.seasonalMonths == null || ingredient.seasonalMonths!.isEmpty) {
      return true;
    }
    return ingredient.seasonalMonths!.contains(currentMonth);
  }

  List<SeasonalIngredient> _prioritizePeakSeasonIngredients(
    List<SeasonalIngredient> ingredients,
    int currentMonth,
  ) {
    final peakSeasonIngredients = <SeasonalIngredient>[];
    final availableButNotPeakIngredients = <SeasonalIngredient>[];

    for (final ingredient in ingredients) {
      if (_isInPeakSeason(ingredient, currentMonth)) {
        peakSeasonIngredients.add(ingredient);
      } else {
        availableButNotPeakIngredients.add(ingredient);
      }
    }

    return [...peakSeasonIngredients, ...availableButNotPeakIngredients];
  }

  bool _isInPeakSeason(SeasonalIngredient ingredient, int currentMonth) {
    final peakSeason = ingredient.peakSeason?.toLowerCase() ?? '';
    
    final monthNames = {
      1: 'january',
      2: 'february', 
      3: 'march',
      4: 'april',
      5: 'may',
      6: 'june',
      7: 'july',
      8: 'august',
      9: 'september',
      10: 'october',
      11: 'november',
      12: 'december'
    };

    final currentMonthName = monthNames[currentMonth] ?? '';
    return peakSeason.contains(currentMonthName);
  }

  List<SeasonalIngredient> _getFallbackIngredients(
    List<SeasonalIngredient> allIngredients,
    int currentMonth,
  ) {
    final adjacentMonths = _getAdjacentMonths(currentMonth);
    
    final fallbackIngredients = allIngredients
        .where((ingredient) => 
            ingredient.seasonalMonths?.any((month) => adjacentMonths.contains(month)) ?? false)
        .toList();

    if (fallbackIngredients.isNotEmpty) {
      return fallbackIngredients.take(3).toList();
    }

    return allIngredients.take(3).toList();
  }

  List<int> _getAdjacentMonths(int currentMonth) {
    final previousMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    final nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
    return [previousMonth, nextMonth];
  }

  bool _isCacheValid(int currentMonth) {
    if (_cachedIngredients == null || 
        _cacheTimestamp == null || 
        _cachedForMonth == null) {
      return false;
    }

    // Cache is invalid if we're in a different month
    if (_cachedForMonth != currentMonth) {
      return false;
    }

    // Cache is invalid if it's older than the cache duration
    final now = _timeService.getCurrentSriLankanTime();
    final age = now.difference(_cacheTimestamp!);
    if (age > _cacheDuration) {
      return false;
    }

    return true;
  }

  void _updateCache(List<SeasonalIngredient> ingredients, int currentMonth) {
    _cachedIngredients = List.from(ingredients);
    _cacheTimestamp = _timeService.getCurrentSriLankanTime();
    _cachedForMonth = currentMonth;
  }

  void _clearCache() {
    _cachedIngredients = null;
    _cacheTimestamp = null;
    _cachedForMonth = null;
  }

  // Method to get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedData': _cachedIngredients != null,
      'cacheTimestamp': _cacheTimestamp?.toIso8601String(),
      'cachedForMonth': _cachedForMonth,
      'cacheSize': _cachedIngredients?.length ?? 0,
      'isValid': _isCacheValid(_timeService.getCurrentSriLankanMonth()),
    };
  }
}

class GetCurrentSeasonalIngredientsUseCaseException implements Exception {
  final String message;

  GetCurrentSeasonalIngredientsUseCaseException(this.message);

  @override
  String toString() => 'GetCurrentSeasonalIngredientsUseCaseException: $message';
}