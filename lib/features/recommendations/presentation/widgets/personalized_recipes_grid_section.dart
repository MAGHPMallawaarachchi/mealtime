import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/recommendation_score.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../../explore/presentation/widgets/explore_recipe_card.dart';
import '../providers/recommendation_provider.dart';

class PersonalizedRecipesGridSection extends ConsumerWidget {
  final List<Recipe> recipes;
  final String? selectedCategory;
  final Function(Recipe)? onFavoriteToggle;
  final Function(Recipe)? onAddToMealPlan;
  final Set<String>? favoriteRecipes;

  const PersonalizedRecipesGridSection({
    super.key,
    required this.recipes,
    this.selectedCategory,
    this.onFavoriteToggle,
    this.onAddToMealPlan,
    this.favoriteRecipes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationProvider);

    return recommendationsAsync.when(
      data: (batch) {
        final personalizedRecipes = _getPersonalizedOrderedRecipes(batch);
        final displayedRecipes = personalizedRecipes.take(20).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, personalizedRecipes.length, batch),
            const SizedBox(height: 16),
            if (displayedRecipes.isNotEmpty)
              _buildRecipesGrid(displayedRecipes, batch)
            else
              _buildEmptyState(),
          ],
        );
      },
      loading: () => _buildLoadingGrid(),
      error: (_, __) => _buildRegularGrid(context),
    );
  }

  List<Recipe> _getPersonalizedOrderedRecipes(RecommendationBatch? batch) {
    if (batch == null || batch.recommendations.isEmpty) {
      return recipes; // Fallback to original order
    }

    // Create a map of recipe ID to recommendation score for quick lookup
    final scoreMap = <String, double>{};
    for (final rec in batch.recommendations) {
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
                        ? 'All Recipes'
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PhosphorIcon(
                            PhosphorIconsRegular.sparkle,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Personalized',
                            style: TextStyle(
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
                    ? '$totalCount recipes, sorted by your preferences'
                    : '$totalCount recipes found',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          if (totalCount > 20)
            TextButton(
              onPressed: () {
                context.push('/explore/all-recipes');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecipesGrid(
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.89,
        ),
        itemCount: displayedRecipes.length,
        itemBuilder: (context, index) {
          final recipe = displayedRecipes[index];

          return ExploreRecipeCard(
            recipe: recipe,
            onAddToMealPlan: onAddToMealPlan,
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.89,
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
    final displayedRecipes = recipes.take(20).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, recipes.length, null),
        const SizedBox(height: 16),
        if (displayedRecipes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.89,
              ),
              itemCount: displayedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = displayedRecipes[index];
                return ExploreRecipeCard(
                  recipe: recipe,
                  onAddToMealPlan: onAddToMealPlan,
                );
              },
            ),
          )
        else
          _buildEmptyState(),
      ],
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subMessage;

    if (selectedCategory != null) {
      message = 'No ${selectedCategory!.toLowerCase()} recipes yet';
      subMessage = 'Check back later for new recipes';
    } else {
      message = 'No recipes available yet';
      subMessage = 'Check back later for delicious recipes';
    }

    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.2),
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
