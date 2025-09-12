import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/optimized_cached_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/domain/models/seasonal_ingredient.dart';
import '../../../home/domain/usecases/get_seasonal_ingredients_usecase.dart';
import '../../../explore/presentation/widgets/explore_recipe_card.dart';
import '../providers/seasonal_ingredient_recipes_provider.dart';
import '../widgets/load_more_button.dart';

class SeasonalIngredientRecipesScreen extends ConsumerStatefulWidget {
  final String ingredientId;

  const SeasonalIngredientRecipesScreen({
    super.key,
    required this.ingredientId,
  });

  @override
  ConsumerState<SeasonalIngredientRecipesScreen> createState() =>
      _SeasonalIngredientRecipesScreenState();
}

class _SeasonalIngredientRecipesScreenState
    extends ConsumerState<SeasonalIngredientRecipesScreen> {
  SeasonalIngredient? ingredient;
  bool isLoadingIngredient = true;
  String? ingredientError;
  final GetSeasonalIngredientsUseCase _getSeasonalIngredientsUseCase =
      GetSeasonalIngredientsUseCase();

  @override
  void initState() {
    super.initState();
    _loadIngredientData();
  }

  Future<void> _loadIngredientData() async {
    try {
      final fetchedIngredient = await _getSeasonalIngredientsUseCase.getById(
        widget.ingredientId,
      );
      if (fetchedIngredient != null) {
        setState(() {
          ingredient = fetchedIngredient;
          isLoadingIngredient = false;
        });

        // Load recipes using the ingredient name (fallback to localized name)
        final searchName = fetchedIngredient.name.isNotEmpty
            ? fetchedIngredient.name
            : fetchedIngredient.getLocalizedName('en');
        ref
            .read(seasonalIngredientRecipesProvider.notifier)
            .loadRecipes(searchName);
      } else {
        setState(() {
          ingredientError = 'Seasonal ingredient not found';
          isLoadingIngredient = false;
        });
      }
    } catch (e) {
      setState(() {
        ingredientError = 'Failed to load ingredient: ${e.toString()}';
        isLoadingIngredient = false;
      });
    }
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
      body: _buildMainContent(state),
    );
  }

  Widget _buildMainContent(SeasonalIngredientRecipesState state) {
    // Show loading state while ingredient is being fetched
    if (isLoadingIngredient) {
      return _buildIngredientLoadingState();
    }

    // Show error state if ingredient couldn't be loaded
    if (ingredientError != null) {
      return _buildIngredientErrorState(ingredientError!);
    }

    // Show recipe content once ingredient is loaded
    return _buildContent(state);
  }

  Widget _buildIngredientLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading ingredient...',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(
            PhosphorIcons.warningCircle(),
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading ingredient',
            style: const TextStyle(
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
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadIngredientData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SeasonalIngredientRecipesState state) {
    if (state.isLoading && state.recipes.isEmpty) {
      return _buildLoadingStateWithHeader();
    }

    if (state.error != null && state.recipes.isEmpty) {
      return _buildErrorStateWithHeader(state.error!);
    }

    if (state.recipes.isEmpty && !state.isLoading) {
      return _buildEmptyStateWithHeader();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          // SliverAppBar with ingredient image and info
          if (ingredient != null)
            _buildSliverAppBar(ingredient!, state.totalCount),

          if (state.recipes.isNotEmpty)
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
                  if (index < 0 || index >= state.recipes.length) {
                    return const SizedBox.shrink();
                  }
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
            'Finding recipes...',
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
                ref.read(seasonalIngredientRecipesProvider.notifier).refresh();
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
              'No recipes found for this ingredient',
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

  Widget _buildSliverAppBar(SeasonalIngredient ingredient, int totalCount) {
    final locale = Localizations.localeOf(context).languageCode;
    final localizedName = ingredient.getLocalizedName(locale);

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          icon: PhosphorIcon(
            PhosphorIcons.arrowLeft(),
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: ingredient.imageUrl.isNotEmpty
                  ? Image.network(
                      ingredient.imageUrl, 
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.primary.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Center(
                        child: PhosphorIcon(
                          PhosphorIcons.leaf(),
                          size: 80,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Content overlay
            Positioned(
              left: 20,
              right: 20,
              bottom: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seasonal badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.leaf(),
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'In Season',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Ingredient name
                  Text(
                    localizedName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Description if available
                  if (ingredient.getLocalizedDescription(locale).isNotEmpty &&
                      ingredient.getLocalizedDescription(locale) !=
                          'No description available') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ingredient.getLocalizedDescription(locale),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStateWithHeader() {
    return CustomScrollView(
      slivers: [
        if (ingredient != null) _buildSliverAppBar(ingredient!, 0),
        SliverFillRemaining(child: _buildLoadingState()),
      ],
    );
  }

  Widget _buildErrorStateWithHeader(String error) {
    return CustomScrollView(
      slivers: [
        if (ingredient != null) _buildSliverAppBar(ingredient!, 0),
        SliverFillRemaining(child: _buildErrorState(error)),
      ],
    );
  }

  Widget _buildEmptyStateWithHeader() {
    return CustomScrollView(
      slivers: [
        if (ingredient != null) _buildSliverAppBar(ingredient!, 0),
        SliverFillRemaining(child: _buildEmptyState()),
      ],
    );
  }
}
