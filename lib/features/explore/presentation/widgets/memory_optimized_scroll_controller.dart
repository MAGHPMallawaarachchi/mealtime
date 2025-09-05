import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../utils/memory_manager.dart';
import '../utils/performance_utils.dart';

/// Memory-optimized scroll controller for infinite recipe lists
class MemoryOptimizedScrollController extends ScrollController {
  final List<Recipe> allRecipes;
  final int itemsPerRow;
  final double estimatedItemHeight;
  
  // Viewport tracking
  double _lastMemoryOptimizationOffset = 0;
  DateTime _lastOptimizationTime = DateTime.now();
  
  // Performance tracking
  int _scrollEventCount = 0;
  DateTime _sessionStartTime = DateTime.now();
  
  MemoryOptimizedScrollController({
    required this.allRecipes,
    this.itemsPerRow = 2,
    this.estimatedItemHeight = 220,
    super.debugLabel,
  }) {
    addListener(_handleMemoryOptimizedScroll);
    InfiniteScrollMemoryManager.initialize();
    debugPrint('MemoryOptimizedScrollController: Initialized for ${allRecipes.length} recipes');
  }
  
  @override
  void dispose() {
    removeListener(_handleMemoryOptimizedScroll);
    InfiniteScrollMemoryManager.dispose();
    
    // Log session statistics
    final sessionDuration = DateTime.now().difference(_sessionStartTime);
    debugPrint('MemoryOptimizedScrollController: Session stats - ${_scrollEventCount} scroll events in ${sessionDuration.inSeconds}s');
    
    super.dispose();
  }
  
  void _handleMemoryOptimizedScroll() {
    if (!hasClients) return;
    
    _scrollEventCount++;
    final currentOffset = offset;
    
    // Throttle memory optimization calls
    const optimizationInterval = Duration(milliseconds: 500);
    final now = DateTime.now();
    
    if (now.difference(_lastOptimizationTime) < optimizationInterval) {
      return;
    }
    
    // Only optimize if scroll distance is significant
    const minimumScrollDelta = 200.0;
    if ((currentOffset - _lastMemoryOptimizationOffset).abs() < minimumScrollDelta) {
      return;
    }
    
    _lastMemoryOptimizationOffset = currentOffset;
    _lastOptimizationTime = now;
    
    // Calculate visible recipe indices
    final visibleIndices = _calculateVisibleIndices();
    final visibleRecipeIds = visibleIndices
        .where((index) => index < allRecipes.length)
        .map((index) => allRecipes[index].id)
        .toList();
    
    // Update memory manager with visible recipes
    InfiniteScrollMemoryManager.updateVisibleRecipes(visibleRecipeIds);
    
    // Trigger memory cleanup if needed
    if (_scrollEventCount % 20 == 0) { // Every 20 scroll events
      InfiniteScrollMemoryManager.cleanupOffScreenRecipes();
    }
    
    // Aggressive cleanup for long scrolling sessions
    if (_scrollEventCount % 100 == 0) { // Every 100 scroll events
      InfiniteScrollMemoryManager.optimizeImageCache();
      _logMemoryStats();
    }
  }
  
  /// Calculate which recipe indices are currently visible
  List<int> _calculateVisibleIndices() {
    if (!hasClients) return [];
    
    final viewportHeight = position.viewportDimension;
    final currentOffset = offset;
    
    // Calculate visible rows
    final startRow = (currentOffset / estimatedItemHeight).floor();
    final endRow = ((currentOffset + viewportHeight) / estimatedItemHeight).ceil();
    
    // Add buffer for smooth scrolling
    const bufferRows = 2;
    final bufferedStartRow = (startRow - bufferRows).clamp(0, double.infinity).toInt();
    final bufferedEndRow = endRow + bufferRows;
    
    // Convert rows to item indices
    final visibleIndices = <int>[];
    for (int row = bufferedStartRow; row <= bufferedEndRow; row++) {
      for (int col = 0; col < itemsPerRow; col++) {
        final index = row * itemsPerRow + col;
        if (index < allRecipes.length) {
          visibleIndices.add(index);
        }
      }
    }
    
    return visibleIndices;
  }
  
  /// Get viewport metrics for performance monitoring
  Map<String, dynamic> getViewportMetrics() {
    if (!hasClients) return {};
    
    return PerformanceUtils.calculateViewportMetrics(
      scrollOffset: offset,
      viewportHeight: position.viewportDimension,
      itemHeight: estimatedItemHeight,
      totalItems: allRecipes.length,
    );
  }
  
  /// Force memory optimization (useful for testing or manual cleanup)
  void forceMemoryOptimization() {
    debugPrint('MemoryOptimizedScrollController: Force memory optimization triggered');
    
    final visibleIndices = _calculateVisibleIndices();
    final visibleRecipeIds = visibleIndices
        .where((index) => index < allRecipes.length)
        .map((index) => allRecipes[index].id)
        .toList();
    
    InfiniteScrollMemoryManager.updateVisibleRecipes(visibleRecipeIds);
    InfiniteScrollMemoryManager.cleanupOffScreenRecipes();
    InfiniteScrollMemoryManager.optimizeImageCache(aggressive: true);
    
    _logMemoryStats();
  }
  
  /// Log current memory statistics
  void _logMemoryStats() {
    final stats = InfiniteScrollMemoryManager.getMemoryStats();
    final visibleIndices = _calculateVisibleIndices();
    
    debugPrint('MemoryOptimizedScrollController Stats:');
    debugPrint('  - Visible items: ${visibleIndices.length}');
    debugPrint('  - Cached recipes: ${stats['cachedRecipes']}/${stats['maxCachedRecipes']}');
    debugPrint('  - Image cache: ${stats['imageCacheSizeMB']}MB (${stats['imageCacheCount']} images)');
    debugPrint('  - Scroll events: $_scrollEventCount');
    debugPrint('  - Current offset: ${offset.toStringAsFixed(1)}px');
  }
  
  /// Check if scroll performance is healthy
  bool get isPerformanceHealthy {
    final sessionDuration = DateTime.now().difference(_sessionStartTime);
    final eventsPerSecond = _scrollEventCount / sessionDuration.inSeconds;
    
    // Healthy if less than 10 scroll events per second on average
    return eventsPerSecond < 10;
  }
  
  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final sessionDuration = DateTime.now().difference(_sessionStartTime);
    final visibleIndices = _calculateVisibleIndices();
    
    return {
      'sessionDurationSeconds': sessionDuration.inSeconds,
      'scrollEventCount': _scrollEventCount,
      'eventsPerSecond': sessionDuration.inSeconds > 0 
          ? (_scrollEventCount / sessionDuration.inSeconds).toStringAsFixed(2)
          : '0',
      'currentOffset': offset.toStringAsFixed(1),
      'visibleItemCount': visibleIndices.length,
      'totalItemCount': allRecipes.length,
      'memoryStats': InfiniteScrollMemoryManager.getMemoryStats(),
      'isHealthy': isPerformanceHealthy,
    };
  }
}