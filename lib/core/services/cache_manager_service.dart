import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheManagerService extends WidgetsBindingObserver {
  static final CacheManagerService _instance = CacheManagerService._internal();
  factory CacheManagerService() => _instance;
  CacheManagerService._internal();

  bool _isAppInBackground = false;
  
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
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
          clearImageCache();
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
      await CachedNetworkImage.evictFromCache('');
      await DefaultCacheManager().emptyCache();
      debugPrint('Image cache cleared successfully');
    } catch (e) {
      debugPrint('Error clearing image cache: $e');
    }
  }

  Future<void> preloadImage(String imageUrl) async {
    try {
      // Preload image by adding it to cache manager
      await DefaultCacheManager().downloadFile(imageUrl);
      debugPrint('Image preloaded successfully: $imageUrl');
    } catch (e) {
      debugPrint('Error preloading image: $e');
    }
  }
}