import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealtime/features/recipes/domain/models/recipe.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import 'explore_recipe_card.dart';

class RecipesGridSection extends StatelessWidget {
  final List<Recipe> recipes;
  final String? selectedCategory;
  final Function(Recipe)? onFavoriteToggle;
  final Function(Recipe)? onAddToMealPlan;
  final Set<String>? favoriteRecipes;

  const RecipesGridSection({
    super.key,
    required this.recipes,
    this.selectedCategory,
    this.onFavoriteToggle,
    this.onAddToMealPlan,
    this.favoriteRecipes,
  });

  @override
  Widget build(BuildContext context) {
    final displayedRecipes = recipes
        .take(20)
        .toList(); // Limit to 20 for performance

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    '${recipes.length} recipes found',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              if (recipes.length > 20)
                TextButton(
                  onPressed: () {
                    // Navigate to full recipes list page
                    context.push('/explore/all-recipes');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
        ),
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
            PhosphorIcons.magnifyingGlass(),
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
