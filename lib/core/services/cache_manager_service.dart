import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../features/recipes/data/datasources/recipes_local_datasource.dart';
import '../../features/home/data/datasources/seasonal_ingredients_local_datasource.dart';

class CacheManagerService extends WidgetsBindingObserver {
  static final CacheManagerService _instance = CacheManagerService._internal();
  factory CacheManagerService() => _instance;
  CacheManagerService._internal();

  bool _isAppInBackground = false;
  
  // Data source instances for cache management
  late final RecipesLocalDataSource _recipesLocalDataSource;
  late final SeasonalIngredientsLocalDataSource _seasonalIngredientsLocalDataSource;
  
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _recipesLocalDataSource = RecipesLocalDataSource();
    _seasonalIngredientsLocalDataSource = SeasonalIngredientsLocalDataSource();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInBackground = false;
        break;
      case AppLifecycleState.paused:
        _isAppInBackground = true;
        break;
      case AppLifecycleState.detached:
        // App is being removed from background tasks
        if (_isAppInBackground) {
          clearAllCaches();
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> clearImageCache() async {
    try {
      // Clear the default cache
      await DefaultCacheManager().emptyCache();
      
      // Clear custom image cache
      final customCacheManager = CacheManager(
        Config(
          'customImageCache',
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 200,
        ),
      );
      await customCacheManager.emptyCache();
    } catch (e) {
      debugPrint('Error clearing image cache: $e');
    }
  }

  Future<void> clearDataCache() async {
    try {
      await Future.wait([
        _recipesLocalDataSource.clearCache(),
        _seasonalIngredientsLocalDataSource.clearCache(),
      ]);
    } catch (e) {
    }
  }

  Future<void> clearAllCaches() async {
    try {
      await Future.wait([
        clearImageCache(),
        clearDataCache(),
      ]);
    } catch (e) {
    }
  }

  Future<void> preloadImage(String imageUrl) async {
    try {
      // Validate URL before preloading
      if (imageUrl.isEmpty || (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://'))) {
        return;
      }
      
      // Preload image by adding it to cache manager
      await DefaultCacheManager().downloadFile(imageUrl);
    } catch (e) {
      debugPrint('Error preloading image: $imageUrl, Error: $e');
    }
  }

  Future<void> clearCorruptedCache() async {
    try {
      // Clear the entire cache to remove any corrupted files
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      debugPrint('Error clearing corrupted cache: $e');
    }
  }
}