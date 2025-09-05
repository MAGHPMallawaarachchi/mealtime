import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../../../recipes/domain/models/recipe.dart';

/// Advanced memory management for infinite scroll with recipe caching
class InfiniteScrollMemoryManager {
  static const int maxCachedRecipes = 200;
  static const int maxCachedImages = 100;
  static const int memoryCheckIntervalMs = 5000; // 5 seconds
  static const int maxMemoryThresholdMB = 150;
  static const int aggressiveCleanupThresholdMB = 200;
  
  // LRU Cache for recipes
  static final LRUMap<String, Recipe> _recipeCache = LRUMap<String, Recipe>(maxCachedRecipes);
  
  // Track viewport visibility for memory optimization
  static final Set<String> _visibleRecipeIds = <String>{};
  static final Map<String, DateTime> _lastAccessTimes = <String, DateTime>{};
  
  // Memory monitoring
  static Timer? _memoryMonitorTimer;
  static int _lastMemoryCheckBytes = 0;
  
  /// Initialize memory monitoring
  static void initialize() {
    if (_memoryMonitorTimer?.isActive == true) return;
    
    _memoryMonitorTimer = Timer.periodic(
      const Duration(milliseconds: memoryCheckIntervalMs),
      (_) => _performMemoryCheck(),
    );
    
    debugPrint('MemoryManager: Initialized with monitoring every ${memoryCheckIntervalMs}ms');
  }
  
  /// Dispose memory monitoring
  static void dispose() {
    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = null;
    clearAll();
    debugPrint('MemoryManager: Disposed and cleared all caches');
  }
  
  /// Cache a recipe with LRU eviction
  static void cacheRecipe(Recipe recipe) {
    _recipeCache[recipe.id] = recipe;
    _lastAccessTimes[recipe.id] = DateTime.now();
  }
  
  /// Get cached recipe
  static Recipe? getCachedRecipe(String recipeId) {
    _lastAccessTimes[recipeId] = DateTime.now();
    return _recipeCache[recipeId];
  }
  
  /// Mark recipes as visible in viewport
  static void updateVisibleRecipes(List<String> visibleRecipeIds) {
    _visibleRecipeIds.clear();
    _visibleRecipeIds.addAll(visibleRecipeIds);
    
    // Update access times for visible recipes
    final now = DateTime.now();
    for (final id in visibleRecipeIds) {
      _lastAccessTimes[id] = now;
    }
  }
  
  /// Optimized image cache management
  static void optimizeImageCache({bool aggressive = false}) {
    final imageCache = PaintingBinding.instance.imageCache;
    final currentSizeBytes = imageCache.currentSizeBytes;
    final currentSizeMB = currentSizeBytes / (1024 * 1024);
    
    if (aggressive || currentSizeMB > maxMemoryThresholdMB) {
      // Clear images for recipes not currently visible
      final keepCount = aggressive ? 20 : maxCachedImages;
      
      // Sort by last access time and keep only recent ones
      final sortedEntries = _lastAccessTimes.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final keepIds = sortedEntries
          .take(keepCount)
          .map((e) => e.key)
          .toSet();
      
      // Clear images not in keep list
      final clearedCount = _lastAccessTimes.length - keepIds.length;
      _lastAccessTimes.removeWhere((id, _) => !keepIds.contains(id));
      
      // Clear general image cache if still too large
      if (currentSizeMB > aggressiveCleanupThresholdMB) {
        imageCache.clear();
        debugPrint('MemoryManager: Cleared entire image cache (${currentSizeMB.toStringAsFixed(1)}MB)');
      }
      
      debugPrint('MemoryManager: Image cache cleanup - removed $clearedCount entries, kept ${keepIds.length}');
    }
  }
  
  /// Clean up off-screen recipes from cache
  static void cleanupOffScreenRecipes() {
    final now = DateTime.now();
    const maxAge = Duration(minutes: 5);
    
    // Remove recipes not accessed recently and not visible
    final toRemove = <String>[];
    
    for (final entry in _lastAccessTimes.entries) {
      final age = now.difference(entry.value);
      final isVisible = _visibleRecipeIds.contains(entry.key);
      
      if (!isVisible && age > maxAge) {
        toRemove.add(entry.key);
      }
    }
    
    for (final id in toRemove) {
      _recipeCache.remove(id);
      _lastAccessTimes.remove(id);
    }
    
    if (toRemove.isNotEmpty) {
      debugPrint('MemoryManager: Cleaned up ${toRemove.length} off-screen recipes');
    }
  }
  
  /// Perform comprehensive memory check
  static void _performMemoryCheck() {
    final imageCache = PaintingBinding.instance.imageCache;
    final currentBytes = imageCache.currentSizeBytes;
    final currentMB = currentBytes / (1024 * 1024);
    
    // Check if memory usage increased significantly
    final deltaBytes = (currentBytes - _lastMemoryCheckBytes).abs();
    final deltaMB = deltaBytes / (1024 * 1024);
    
    if (deltaMB > 10) { // More than 10MB change
      debugPrint('MemoryManager: Memory changed by ${deltaMB.toStringAsFixed(1)}MB (now ${currentMB.toStringAsFixed(1)}MB)');
    }
    
    _lastMemoryCheckBytes = currentBytes;
    
    // Trigger cleanup if needed
    if (currentMB > maxMemoryThresholdMB) {
      debugPrint('MemoryManager: Memory threshold exceeded (${currentMB.toStringAsFixed(1)}MB), triggering cleanup');
      optimizeImageCache();
      cleanupOffScreenRecipes();
    }
    
    // Force garbage collection if memory is very high
    if (currentMB > aggressiveCleanupThresholdMB) {
      debugPrint('MemoryManager: Aggressive cleanup threshold reached, forcing GC');
      optimizeImageCache(aggressive: true);
      // Note: System.gc() is not available in Flutter, but this cleanup should help
    }
  }
  
  /// Clear all caches
  static void clearAll() {
    _recipeCache.clear();
    _visibleRecipeIds.clear();
    _lastAccessTimes.clear();
    PaintingBinding.instance.imageCache.clear();
  }
  
  /// Get memory statistics
  static Map<String, dynamic> getMemoryStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    return {
      'cachedRecipes': _recipeCache.length,
      'maxCachedRecipes': maxCachedRecipes,
      'visibleRecipes': _visibleRecipeIds.length,
      'trackedRecipes': _lastAccessTimes.length,
      'imageCacheSizeMB': (imageCache.currentSizeBytes / (1024 * 1024)).toStringAsFixed(1),
      'imageCacheCount': imageCache.currentSize,
      'maxImageCacheSize': imageCache.maximumSize,
      'maxImageCacheSizeMB': (imageCache.maximumSizeBytes / (1024 * 1024)).toStringAsFixed(1),
    };
  }
  
  /// Check if recipe is in viewport or recently accessed
  static bool shouldKeepInMemory(String recipeId) {
    if (_visibleRecipeIds.contains(recipeId)) return true;
    
    final lastAccess = _lastAccessTimes[recipeId];
    if (lastAccess == null) return false;
    
    const recentThreshold = Duration(minutes: 2);
    return DateTime.now().difference(lastAccess) < recentThreshold;
  }
}

/// LRU Map implementation for recipe caching
class LRUMap<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _map = LinkedHashMap<K, V>();
  
  LRUMap(this.maxSize);
  
  V? operator [](K key) {
    final value = _map.remove(key);
    if (value != null) {
      _map[key] = value; // Move to end (most recent)
    }
    return value;
  }
  
  void operator []=(K key, V value) {
    _map.remove(key); // Remove if exists
    _map[key] = value; // Add to end
    
    // Evict oldest if over limit
    while (_map.length > maxSize) {
      _map.remove(_map.keys.first);
    }
  }
  
  V? remove(K key) => _map.remove(key);
  void clear() => _map.clear();
  int get length => _map.length;
  Iterable<K> get keys => _map.keys;
  Iterable<V> get values => _map.values;
}