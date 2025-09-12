import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/domain/models/seasonal_ingredient.dart';
import '../../../explore/presentation/widgets/explore_recipe_card.dart';
import '../providers/seasonal_ingredient_recipes_provider.dart';
import '../widgets/seasonal_ingredient_header.dart';
import '../widgets/load_more_button.dart';

class SeasonalIngredientRecipesScreen extends ConsumerStatefulWidget {
  final SeasonalIngredient ingredient;

  const SeasonalIngredientRecipesScreen({super.key, required this.ingredient});

  @override
  ConsumerState<SeasonalIngredientRecipesScreen> createState() =>
      _SeasonalIngredientRecipesScreenState();
}

class _SeasonalIngredientRecipesScreenState
    extends ConsumerState<SeasonalIngredientRecipesScreen> {
  @override
  void initState() {
    super.initState();
    // Load recipes when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(seasonalIngredientRecipesProvider.notifier)
          .loadRecipes(widget.ingredient.name);
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(seasonalIngredientRecipesProvider.notifier).refresh();
  }

  void _loadMoreRecipes() {
    ref.read(seasonalIngredientRecipesProvider.notifier).loadMoreRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seasonalIngredientRecipesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header
            SeasonalIngredientHeader(
              ingredient: widget.ingredient,
              totalRecipesCount: state.totalCount,
            ),

            // Scrollable content
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SeasonalIngredientRecipesState state) {
    if (state.isLoading && state.recipes.isEmpty) {
      return _buildLoadingState();
    }

    if (state.error != null && state.recipes.isEmpty) {
      return _buildErrorState(state.error!);
    }

    if (state.recipes.isEmpty && !state.isLoading) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.89,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final recipe = state.recipes[index];
                return ExploreRecipeCard(
                  recipe: recipe,
                  onAddToMealPlan: null, // Optional meal plan integration
                );
              }, childCount: state.recipes.length),
            ),
          ),

          // Load more button
          SliverToBoxAdapter(
            child: LoadMoreButton(
              isLoading: state.isLoadingMore,
              hasMore: state.hasMore,
              onPressed: _loadMoreRecipes,
            ),
          ),

          // Error message for load more
          if (state.error != null && state.recipes.isNotEmpty)
            SliverToBoxAdapter(child: _buildLoadMoreError(state.error!)),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'Finding recipes with ${widget.ingredient.name.toLowerCase()}...',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.warningCircle(),
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load recipes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(seasonalIngredientRecipesProvider.notifier)
                    .loadRecipes(widget.ingredient.name, forceRefresh: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.tryAgain,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.magnifyingGlass(),
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No recipes found with ${widget.ingredient.name.toLowerCase()}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later as we add more seasonal recipes to our collection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PhosphorIcon(
                    PhosphorIcons.arrowClockwise(),
                    size: 16,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Refresh',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreError(String error) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              PhosphorIcon(
                PhosphorIcons.warningCircle(),
                size: 20,
                color: Colors.red.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to load more recipes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              ref.read(seasonalIngredientRecipesProvider.notifier).clearError();
              _loadMoreRecipes();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              AppLocalizations.of(context)!.tryAgain,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
