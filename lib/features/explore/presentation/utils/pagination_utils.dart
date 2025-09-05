import '../../../recipes/domain/models/recipe.dart';
import '../../../../core/models/recommendation_score.dart';

class PaginationUtils {
  static const int defaultItemsPerPage = 20;
  static const int maxItemsPerPage = 50;
  static const int minItemsPerPage = 10;

  /// Applies personalized ordering to recipes while maintaining efficient pagination
  static List<Recipe> applyPersonalizedOrdering(
    List<Recipe> recipes,
    RecommendationBatch? recommendationBatch,
  ) {
    if (recommendationBatch == null || recommendationBatch.recommendations.isEmpty) {
      return recipes; // Return original order if no recommendations
    }

    // Create a map of recipe ID to recommendation score for quick lookup
    final scoreMap = <String, double>{};
    for (final rec in recommendationBatch.recommendations) {
      scoreMap[rec.recipeId] = rec.totalScore;
    }

    // Sort recipes by recommendation score (high to low),
    // with recipes not in recommendations appearing at the end
    final sortedRecipes = [...recipes];
    sortedRecipes.sort((a, b) {
      final scoreA = scoreMap[a.id] ?? 0.0;
      final scoreB = scoreMap[b.id] ?? 0.0;

      if (scoreA == scoreB) {
        // If scores are equal, maintain original order
        return recipes.indexOf(a).compareTo(recipes.indexOf(b));
      }

      return scoreB.compareTo(scoreA); // Higher score first
    });

    return sortedRecipes;
  }

  /// Filters recipes based on search query and selected category
  static List<Recipe> applyFiltering({
    required List<Recipe> allRecipes,
    String? searchQuery,
    String? selectedCategory,
  }) {
    List<Recipe> filteredRecipes = allRecipes;

    // Apply category filtering
    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      filteredRecipes = filteredRecipes.where((recipe) {
        return recipe.tags.contains(selectedCategory);
      }).toList();
    }

    // Apply search filtering
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase().trim();
      
      filteredRecipes = filteredRecipes.where((recipe) {
        // Search in title
        if (recipe.title.toLowerCase().contains(lowerQuery)) {
          return true;
        }

        // Search in description
        if (recipe.description?.toLowerCase().contains(lowerQuery) == true) {
          return true;
        }

        // Search in tags
        if (recipe.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))) {
          return true;
        }

        // Search in ingredients
        final hasMatchingIngredient = recipe.ingredients.any((ingredient) {
          return ingredient.name.toLowerCase().contains(lowerQuery);
        });

        if (hasMatchingIngredient) {
          return true;
        }

        // Search in legacy ingredients for backward compatibility
        if (recipe.legacyIngredients.any((ingredient) => 
            ingredient.toLowerCase().contains(lowerQuery))) {
          return true;
        }

        return false;
      }).toList();
    }

    return filteredRecipes;
  }

  /// Calculates optimal items per page based on screen size and performance constraints
  static int calculateOptimalItemsPerPage({
    double? screenHeight,
    double? itemHeight,
    int columnsCount = 2,
  }) {
    if (screenHeight == null || itemHeight == null) {
      return defaultItemsPerPage;
    }

    // Calculate how many rows can fit on screen
    final rowsVisible = (screenHeight / itemHeight).ceil();
    
    // Add 2-3 extra rows for smooth scrolling experience
    final optimalRows = rowsVisible + 3;
    final optimalItems = (optimalRows * columnsCount);

    // Ensure it's within reasonable bounds
    return optimalItems.clamp(minItemsPerPage, maxItemsPerPage);
  }

  /// Determines if the user is near the bottom and should trigger loading more content
  static bool shouldLoadMore({
    required double currentOffset,
    required double maxScrollExtent,
    double threshold = 200.0, // Load more when 200px from bottom
  }) {
    if (maxScrollExtent <= 0) return false;
    
    final remainingDistance = maxScrollExtent - currentOffset;
    return remainingDistance <= threshold;
  }

  /// Calculates the total number of pages needed for a given recipe count
  static int calculateTotalPages(int totalItems, int itemsPerPage) {
    if (totalItems <= 0 || itemsPerPage <= 0) return 0;
    return (totalItems / itemsPerPage).ceil();
  }

  /// Gets a human-readable status for pagination state
  static String getPaginationStatus({
    required int displayedCount,
    required int totalCount,
    required bool isLoading,
    required bool hasError,
  }) {
    if (hasError) {
      return 'Error loading recipes';
    }
    
    if (isLoading && displayedCount == 0) {
      return 'Loading recipes...';
    }
    
    if (isLoading) {
      return 'Loading more recipes...';
    }
    
    if (displayedCount == 0) {
      return 'No recipes found';
    }
    
    if (displayedCount >= totalCount) {
      return '$totalCount recipe${totalCount == 1 ? '' : 's'} found';
    }
    
    return 'Showing $displayedCount of $totalCount recipe${totalCount == 1 ? '' : 's'}';
  }

  /// Debounces search queries to prevent excessive filtering operations
  static String? debounceSearchQuery(String? currentQuery, String? newQuery, {
    Duration debounceTime = const Duration(milliseconds: 300),
  }) {
    // This is a simple implementation - in a real scenario, you'd use a proper debounce mechanism
    // For now, we'll just return the new query and let the caller handle debouncing
    return newQuery?.trim().isEmpty == true ? null : newQuery?.trim();
  }
}