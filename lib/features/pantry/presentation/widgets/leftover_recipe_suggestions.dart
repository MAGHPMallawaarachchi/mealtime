import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../domain/models/pantry_item.dart';
import '../providers/leftover_recipe_providers.dart';

class LeftoverRecipeSuggestionsSection extends ConsumerStatefulWidget {
  final PantryItem leftover;

  const LeftoverRecipeSuggestionsSection({super.key, required this.leftover});

  @override
  ConsumerState<LeftoverRecipeSuggestionsSection> createState() =>
      _LeftoverRecipeSuggestionsSectionState();
}

class _LeftoverRecipeSuggestionsSectionState
    extends ConsumerState<LeftoverRecipeSuggestionsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(leftoverRecipesProvider(widget.leftover.id));
    final suggestionsState = ref.watch(leftoverRecipeSuggestionsProvider);

    if (recipes.isEmpty && !suggestionsState.isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildHeader(recipes.length, suggestionsState.isLoading),
          if (_isExpanded) ...[
            const Divider(height: 1, color: AppColors.border),
            _buildRecipeList(recipes, suggestionsState),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(int recipeCount, bool isLoading) {
    return InkWell(
      onTap: () {
        if (!isLoading && recipeCount > 0) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: PhosphorIcon(
                PhosphorIcons.forkKnife(),
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoading
                        ? AppLocalizations.of(
                            context,
                          )!.findingRecipesForLeftover
                        : recipeCount > 0
                        ? AppLocalizations.of(
                            context,
                          )!.recipeSuggestionsCount(recipeCount)
                        : AppLocalizations.of(context)!.noRecipesFound,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (!isLoading && recipeCount > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      _isExpanded
                          ? AppLocalizations.of(context)!.tapToHideRecipes
                          : AppLocalizations.of(context)!.tapToViewRecipes,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isLoading) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ] else if (recipeCount > 0) ...[
              PhosphorIcon(
                _isExpanded
                    ? PhosphorIcons.caretUp()
                    : PhosphorIcons.caretDown(),
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeList(
    List<Recipe> recipes,
    LeftoverRecipeSuggestionsState state,
  ) {
    if (state.error != null) {
      return _buildErrorState(state.error!);
    }

    if (recipes.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ...recipes.map((recipe) => _buildRecipeCard(recipe)).toList(),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToRecipe(recipe.id),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                _buildRecipeImage(recipe.imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.clock(),
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recipe.time,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          PhosphorIcon(
                            PhosphorIcons.fire(),
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.calories} cal',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PhosphorIcon(
                  PhosphorIcons.arrowRight(),
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeImage(String imageUrl) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder();
                },
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: PhosphorIcon(
          PhosphorIcons.forkKnife(),
          size: 20,
          color: AppColors.primary.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          PhosphorIcon(
            PhosphorIcons.warningCircle(),
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.failedToLoadSuggestions,
              style: TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(leftoverRecipeSuggestionsProvider.notifier)
                  .updateSuggestions();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(0, 0),
            ),
            child: Text(
              AppLocalizations.of(context)!.retry,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          PhosphorIcon(
            PhosphorIcons.magnifyingGlass(),
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.noMatchingRecipesFoundForLeftover,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRecipe(String recipeId) {
    context.push('/recipe/$recipeId');
  }
}
