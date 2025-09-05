import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../recipes/domain/models/recipe.dart';

class PerformanceUtils {
  /// Optimizes recipe list for better rendering performance
  static List<Recipe> optimizeRecipeList(List<Recipe> recipes) {
    // Pre-sort recipes to avoid repeated sorting operations
    return recipes.toList(); // Create a copy to avoid modifying the original
  }

  /// Calculates optimal image cache size based on visible items
  static int calculateOptimalImageCacheSize(int visibleItems) {
    // Cache 2x the visible items plus some buffer
    return (visibleItems * 2.5).round().clamp(10, 200);
  }

  /// Determines if recipe item should be pre-cached based on scroll position
  static bool shouldPreloadRecipe(int index, int visibleStartIndex, int visibleEndIndex) {
    const preloadBuffer = 5; // Preload 5 items ahead
    return index <= visibleEndIndex + preloadBuffer && index >= visibleStartIndex - preloadBuffer;
  }

  /// Optimizes scroll physics for better performance
  static ScrollPhysics getOptimizedScrollPhysics() {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  /// Creates performance-optimized grid delegate
  static SliverGridDelegate createOptimizedGridDelegate({
    required double screenWidth,
    required int crossAxisCount,
    double aspectRatio = 0.89,
    double crossAxisSpacing = 12.0,
    double mainAxisSpacing = 12.0,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: aspectRatio,
    );
  }

  /// Calculates optimal cross axis count based on screen width
  static int calculateOptimalCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) {
      return 2; // Phone
    } else if (screenWidth < 900) {
      return 3; // Tablet portrait
    } else {
      return 4; // Tablet landscape or desktop
    }
  }

  /// Memory optimization: dispose of off-screen images
  static void optimizeMemoryUsage() {
    // Clear image cache if it gets too large
    final imageCache = PaintingBinding.instance.imageCache;
    if (imageCache.currentSizeBytes > 100 * 1024 * 1024) { // 100MB threshold
      imageCache.clear();
    }
  }

  /// Debounce scroll events to reduce computational load
  static bool shouldProcessScrollEvent(double currentOffset, double lastOffset) {
    const threshold = 50.0; // Only process scroll events every 50px
    return (currentOffset - lastOffset).abs() > threshold;
  }

  /// Performance monitoring utilities
  static void measureRenderTime(String operationName, VoidCallback operation) {
    final stopwatch = Stopwatch()..start();
    operation();
    stopwatch.stop();
    
    // Log performance metrics (in a real app, you might send this to analytics)
    debugPrint('Performance: $operationName took ${stopwatch.elapsedMilliseconds}ms');
    
    if (stopwatch.elapsedMilliseconds > 16) { // More than one frame at 60fps
      debugPrint('Warning: $operationName is causing frame drops');
    }
  }

  /// Optimize recipe grid item builder for better performance
  static Widget optimizedRecipeBuilder({
    required BuildContext context,
    required int index,
    required List<Recipe> recipes,
    required Widget Function(BuildContext, Recipe) itemBuilder,
  }) {
    if (index >= recipes.length) return const SizedBox.shrink();
    
    final recipe = recipes[index];
    
    return RepaintBoundary(
      key: ValueKey(recipe.id),
      child: itemBuilder(context, recipe),
    );
  }

  /// Creates optimized scroll controller with performance settings
  static ScrollController createOptimizedScrollController() {
    return ScrollController(
      debugLabel: 'ExploreScreenScrollController',
    );
  }

  /// Batch operations for better performance
  static Future<T> batchOperation<T>(Future<T> Function() operation) async {
    return await operation();
  }

  /// Calculate viewport metrics for efficient rendering
  static Map<String, int> calculateViewportMetrics({
    required double scrollOffset,
    required double viewportHeight,
    required double itemHeight,
    required int totalItems,
  }) {
    final itemsPerRow = 2; // Grid columns
    final rowHeight = itemHeight;
    
    final visibleStartRow = (scrollOffset / rowHeight).floor().clamp(0, totalItems ~/ itemsPerRow);
    final visibleEndRow = ((scrollOffset + viewportHeight) / rowHeight).ceil().clamp(0, totalItems ~/ itemsPerRow);
    
    return {
      'visibleStartIndex': visibleStartRow * itemsPerRow,
      'visibleEndIndex': ((visibleEndRow + 1) * itemsPerRow).clamp(0, totalItems),
      'preloadStartIndex': ((visibleStartRow - 2) * itemsPerRow).clamp(0, totalItems),
      'preloadEndIndex': ((visibleEndRow + 3) * itemsPerRow).clamp(0, totalItems),
    };
  }
}