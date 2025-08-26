import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtime/features/recipes/domain/models/recipe.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/optimized_cached_image.dart';
import '../../domain/models/user_recipe.dart';
import '../providers/user_recipes_providers.dart';

class UserRecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const UserRecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = ref.watch(userRecipeProvider(recipeId));

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recipe'),
          leading: IconButton(
            icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Recipe not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, recipe),
          SliverToBoxAdapter(child: _buildRecipeContent(context, ref, recipe)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserRecipe recipe) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: IconButton(
        icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: PhosphorIcon(PhosphorIcons.pencil()),
          onPressed: () => context.push('/edit-recipe/${recipe.id}'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: recipe.imageUrl != null
            ? OptimizedCachedImage(
                imageUrl: recipe.imageUrl!,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppColors.primary.withOpacity(0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.forkKnife(),
                      size: 64,
                      color: AppColors.primary.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Image',
                      style: TextStyle(
                        color: AppColors.primary.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRecipeContent(
    BuildContext context,
    WidgetRef ref,
    UserRecipe recipe,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (recipe.description != null) ...[
            const SizedBox(height: 8),
            Text(
              recipe.description!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildRecipeMetrics(recipe),
          const SizedBox(height: 24),
          _buildIngredients(recipe),
          const SizedBox(height: 24),
          _buildInstructions(recipe),
          if (recipe.tags.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildTags(recipe),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildRecipeMetrics(UserRecipe recipe) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: _buildMetric(
                PhosphorIcons.clock(),
                'Total Time',
                recipe.time,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.withOpacity(0.3),
            ),
            Expanded(
              child: _buildMetric(
                PhosphorIcons.fire(),
                'Calories',
                recipe.calories > 0 ? '${recipe.calories}' : 'N/A',
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.withOpacity(0.3),
            ),
            Expanded(
              child: _buildMetric(
                PhosphorIcons.users(),
                'Servings',
                recipe.defaultServings.toString(),
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(PhosphorIconData icon, String label, String value) {
    return Column(
      children: [
        PhosphorIcon(icon, size: 24, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildIngredients(UserRecipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: recipe.ingredients.map((ingredient) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ingredient.getDisplayText(UnitSystem.cups),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(UserRecipe recipe) {
    final steps = recipe.instructionSections.isNotEmpty
        ? recipe.instructionSections.expand((section) => section.steps).toList()
        : <String>[];

    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags(UserRecipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recipe.tags.map((tag) {
            return Chip(
              label: Text(tag),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
