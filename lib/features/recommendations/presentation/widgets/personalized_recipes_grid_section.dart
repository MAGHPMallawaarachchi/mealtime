import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/recommendation_score.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../../explore/presentation/widgets/explore_recipe_card.dart';
import '../../../explore/presentation/providers/explore_pagination_provider.dart';
import '../../../explore/presentation/utils/pagination_utils.dart';
import '../../../explore/presentation/utils/performance_utils.dart';
import '../../../explore/presentation/widgets/error_handling_widgets.dart';
import '../providers/recommendation_provider.dart';

class PersonalizedRecipesGridSection extends ConsumerWidget {
  final List<Recipe> allRecipes;
  final String? selectedCategory;
  final String? searchQuery;
  final Function(Recipe)? onFavoriteToggle;
  final Function(Recipe)? onAddToMealPlan;
  final Set<String>? favoriteRecipes;
  final VoidCallback? onLoadMore;
  final bool enablePagination;

  const PersonalizedRecipesGridSection({
    super.key,
    required this.allRecipes,
    this.selectedCategory,
    this.searchQuery,
    this.onFavoriteToggle,
    this.onAddToMealPlan,
    this.favoriteRecipes,
    this.onLoadMore,
    this.enablePagination = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationProvider);

    if (enablePagination) {
      final paginationState = ref.watch(explorePaginationProvider);

      // Show regular loading state if pagination hasn't been initialized yet
      if (allRecipes.isNotEmpty &&
          paginationState.displayedRecipes.isEmpty &&
          !paginationState.isLoading) {
        // Initialize pagination when recipes are available but pagination state is empty
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updatePaginationIfNeeded(ref, recommendationsAsync.value);
        });
        return _buildLoadingGrid(context);
      }

      return _buildPaginatedContent(
        context,
        ref,
        paginationState,
        recommendationsAsync.value,
      );
    }

    // Fallback to original behavior when pagination is disabled
    return recommendationsAsync.when(
      data: (batch) {
        final personalizedRecipes = _getPersonalizedOrderedRecipes(
          batch,
          allRecipes,
        );
        final displayedRecipes = personalizedRecipes.take(20).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, personalizedRecipes.length, batch),
            const SizedBox(height: 16),
            if (displayedRecipes.isNotEmpty)
              _buildRecipesGrid(context, displayedRecipes, batch)
            else
              _buildEmptyState(context),
          ],
        );
      },
      loading: () => _buildLoadingGrid(context),
      error: (_, __) => _buildRegularGrid(context),
    );
  }

  List<Recipe> _getPersonalizedOrderedRecipes(
    RecommendationBatch? batch,
    List<Recipe> recipes,
  ) {
    return PaginationUtils.applyPersonalizedOrdering(recipes, batch);
  }

  void _updatePaginationIfNeeded(WidgetRef ref, RecommendationBatch? batch) {
    final filteredRecipes = PaginationUtils.applyFiltering(
      allRecipes: allRecipes,
      searchQuery: searchQuery,
      selectedCategory: selectedCategory,
    );

    final personalizedRecipes = _getPersonalizedOrderedRecipes(
      batch,
      filteredRecipes,
    );

    // Initialize or update pagination with the processed recipes
    final paginationState = ref.read(explorePaginationProvider);
    if (paginationState.displayedRecipes.isEmpty ||
        personalizedRecipes != paginationState.displayedRecipes) {
      ref
          .read(explorePaginationProvider.notifier)
          .loadInitialRecipes(personalizedRecipes);
    }
  }

  Widget _buildPaginatedContent(
    BuildContext context,
    WidgetRef ref,
    PaginationState paginationState,
    RecommendationBatch? recommendationBatch,
  ) {
    if (paginationState.isInitialLoading) {
      return _buildLoadingGrid(context);
    }

    if (paginationState.hasError && paginationState.displayedRecipes.isEmpty) {
      return _buildErrorState(paginationState.error!, ref, context);
    }

    // Fallback: if pagination has no recipes but we have allRecipes, show them directly
    if (paginationState.displayedRecipes.isEmpty && allRecipes.isNotEmpty) {
      final filteredRecipes = PaginationUtils.applyFiltering(
        allRecipes: allRecipes,
        searchQuery: searchQuery,
        selectedCategory: selectedCategory,
      );
      final personalizedRecipes = _getPersonalizedOrderedRecipes(
        recommendationBatch,
        filteredRecipes,
      );
      final fallbackRecipes = personalizedRecipes.take(20).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaginatedHeader(
            context,
            paginationState,
            recommendationBatch,
            ref,
          ),
          const SizedBox(height: 16),
          if (fallbackRecipes.isNotEmpty)
            _buildRecipesGrid(context, fallbackRecipes, recommendationBatch)
          else
            _buildEmptyState(context),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPaginatedHeader(
          context,
          paginationState,
          recommendationBatch,
          ref,
        ),
        const SizedBox(height: 16),
        if (paginationState.displayedRecipes.isNotEmpty)
          _buildRecipesGrid(
            context,
            paginationState.displayedRecipes,
            recommendationBatch,
          )
        else
          _buildEmptyState(context),
        if (paginationState.isLoadingMore)
          _buildLoadMoreIndicator(context)
        else if (paginationState.hasError &&
            paginationState.displayedRecipes.isNotEmpty)
          LoadMoreErrorWidget(
            errorMessage: paginationState.error!.message,
            onRetry: () => ref
                .read(explorePaginationProvider.notifier)
                .retryLastOperation(),
            onDismiss: () =>
                ref.read(explorePaginationProvider.notifier).clearError(),
          ),
      ],
    );
  }

  Widget _buildPaginatedHeader(
    BuildContext context,
    PaginationState paginationState,
    RecommendationBatch? batch,
    WidgetRef ref,
  ) {
    final hasRecommendations =
        batch != null && batch.recommendations.isNotEmpty;
    final statusText = PaginationUtils.getPaginationStatus(
      context,
      displayedCount: paginationState.displayedRecipes.length,
      totalCount: _getTotalAvailableCount(),
      isLoading: paginationState.isLoading,
      hasError: paginationState.hasError,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                selectedCategory == null
                    ? AppLocalizations.of(context)!.allRecipes
                    : selectedCategory!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (hasRecommendations) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PhosphorIcon(
                        PhosphorIconsRegular.sparkle,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.personalized,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            statusText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalAvailableCount() {
    final filteredRecipes = PaginationUtils.applyFiltering(
      allRecipes: allRecipes,
      searchQuery: searchQuery,
      selectedCategory: selectedCategory,
    );
    return filteredRecipes.length;
  }

  Widget _buildLoadMoreIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.loadingMoreRecipesEllipsis,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    PaginationError error,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(
            _getErrorIcon(error.type),
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.failedToLoadRecipes,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          RetryButton(
            onPressed: () => ref
                .read(explorePaginationProvider.notifier)
                .retryLastOperation(),
            isLoading: false,
          ),
        ],
      ),
    );
  }

  PhosphorIconData _getErrorIcon(PaginationErrorType errorType) {
    switch (errorType) {
      case PaginationErrorType.network:
        return PhosphorIconsRegular.wifiSlash;
      case PaginationErrorType.timeout:
        return PhosphorIconsRegular.clock;
      case PaginationErrorType.rateLimit:
        return PhosphorIconsRegular.prohibit;
      case PaginationErrorType.generic:
        return PhosphorIconsRegular.warning;
    }
  }

  Widget _buildHeader(
    BuildContext context,
    int totalCount,
    RecommendationBatch? batch,
  ) {
    final bool hasRecommendations =
        batch != null && batch.recommendations.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    selectedCategory == null
                        ? AppLocalizations.of(context)!.allRecipes
                        : selectedCategory!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (hasRecommendations) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PhosphorIcon(
                            PhosphorIconsRegular.sparkle,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.personalized,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                hasRecommendations
                    ? AppLocalizations.of(
                        context,
                      )!.recipesSortedByPreferences(totalCount)
                    : AppLocalizations.of(context)!.recipesFound(totalCount),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesGrid(
    BuildContext context,
    List<Recipe> displayedRecipes,
    RecommendationBatch? batch,
  ) {
    // Create recommendation lookup for displaying reasons
    final recommendationMap = <String, RecommendationScore>{};
    if (batch != null) {
      for (final rec in batch.recommendations) {
        recommendationMap[rec.recipeId] = rec;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: PerformanceUtils.createOptimizedGridDelegate(
          screenWidth: MediaQuery.of(context).size.width,
          crossAxisCount: PerformanceUtils.calculateOptimalCrossAxisCount(
            MediaQuery.of(context).size.width,
          ).clamp(2, 2), // Force 2 columns for explore screen
          aspectRatio: 0.89,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: displayedRecipes.length,
        itemBuilder: (context, index) {
          return PerformanceUtils.optimizedRecipeBuilder(
            context: context,
            index: index,
            recipes: displayedRecipes,
            itemBuilder: (context, recipe) => ExploreRecipeCard(
              recipe: recipe,
              onAddToMealPlan: onAddToMealPlan,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: PerformanceUtils.createOptimizedGridDelegate(
              screenWidth: MediaQuery.of(context).size.width,
              crossAxisCount: 2,
              aspectRatio: 0.89,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6, // Show 6 skeleton items
            itemBuilder: (context, index) => _buildSkeletonCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Expanded(
            flex: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const SizedBox(width: double.infinity, height: 16),
                  ),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const SizedBox(width: 100, height: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularGrid(BuildContext context) {
    // Fallback to regular grid if recommendations fail to load
    final displayedRecipes = allRecipes.take(20).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, allRecipes.length, null),
        const SizedBox(height: 16),
        if (displayedRecipes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: PerformanceUtils.createOptimizedGridDelegate(
                screenWidth: MediaQuery.of(context).size.width,
                crossAxisCount: 2,
                aspectRatio: 0.89,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: displayedRecipes.length,
              itemBuilder: (context, index) {
                return PerformanceUtils.optimizedRecipeBuilder(
                  context: context,
                  index: index,
                  recipes: displayedRecipes,
                  itemBuilder: (context, recipe) => ExploreRecipeCard(
                    recipe: recipe,
                    onAddToMealPlan: onAddToMealPlan,
                  ),
                );
              },
            ),
          )
        else
          _buildEmptyState(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    String message;
    String subMessage;

    if (selectedCategory != null) {
      message = localizations.noCategoryRecipesYet(
        selectedCategory!.toLowerCase(),
      );
      subMessage = localizations.checkBackLaterForNewRecipes;
    } else {
      message = localizations.noRecipesAvailableYet;
      subMessage = localizations.checkBackLaterForDeliciousRecipes;
    }

    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(
            PhosphorIconsRegular.magnifyingGlass,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subMessage,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
