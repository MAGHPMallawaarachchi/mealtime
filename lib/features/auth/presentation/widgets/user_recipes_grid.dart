import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../user_recipes/presentation/providers/user_recipes_providers.dart';
import '../../../user_recipes/presentation/widgets/user_recipe_card.dart';

class UserRecipesGrid extends ConsumerWidget {
  const UserRecipesGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRecipesState = ref.watch(userRecipesProvider);

    if (userRecipesState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (userRecipesState.error != null) {
      return _buildErrorState(userRecipesState.error!);
    }

    if (userRecipesState.recipes.isEmpty) {
      return _buildEmptyState(context);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: userRecipesState.recipes.length,
      itemBuilder: (context, index) {
        final recipe = userRecipesState.recipes[index];
        return UserRecipeCard(
          recipe: recipe,
          onEdit: () => context.push('/edit-recipe/${recipe.id}'),
          onDelete: () => _showDeleteDialog(context, ref, recipe.id, recipe.title),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: PhosphorIcon(
              PhosphorIcons.cookingPot(),
              size: 40,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Recipes Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first recipe to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/create-recipe'),
            icon: PhosphorIcon(PhosphorIcons.plus()),
            label: const Text('Create Recipe'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: PhosphorIcon(
              PhosphorIcons.warning(),
              size: 40,
              color: Colors.red.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Recipes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String recipeId, String recipeTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: PhosphorIcon(
          PhosphorIcons.trash(),
          size: 24,
          color: Colors.red,
        ),
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "$recipeTitle"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(userRecipesProvider.notifier).deleteUserRecipe(recipeId);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.checkCircle(),
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text('Recipe deleted successfully'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}