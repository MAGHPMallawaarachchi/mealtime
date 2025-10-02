import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtime/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/ingredient_recipe_match.dart';
import '../providers/pantry_providers.dart';
import 'recipe_match_card.dart';

class MatchingRecipesSection extends ConsumerWidget {
  const MatchingRecipesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeMatches = ref.watch(ingredientRecipeMatchesProvider);
    final hasMatches = ref.watch(hasMatchingRecipesProvider);
    final pantryState = ref.watch(pantryProvider);

    if (pantryState.ingredientItems.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!hasMatches) {
      return _buildNoMatchesState(context);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, recipeMatches),
          const SizedBox(height: 16),
          _buildRecipeList(context, recipeMatches),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    List<IngredientRecipeMatch> matches,
  ) {
    final perfectMatches = matches
        .where((m) => m.matchLevel == MatchLevel.perfect)
        .length;
    final goodMatches = matches
        .where(
          (m) =>
              m.matchLevel == MatchLevel.high ||
              m.matchLevel == MatchLevel.medium,
        )
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(
                PhosphorIcons.forkKnife(),
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.recipesYouCanMake,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${matches.length} ${AppLocalizations.of(context)!.recipes}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (perfectMatches > 0 || goodMatches > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (perfectMatches > 0) ...[
                  _buildMatchChip(
                    icon: PhosphorIcons.checkCircle(),
                    label:
                        '$perfectMatches ${AppLocalizations.of(context)!.perfect}',
                    color: AppColors.success,
                  ),
                  if (goodMatches > 0) const SizedBox(width: 8),
                ],
                if (goodMatches > 0) ...[
                  _buildMatchChip(
                    icon: PhosphorIcons.star(),
                    label: '$goodMatches ${AppLocalizations.of(context)!.good}',
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(
    BuildContext context,
    List<IngredientRecipeMatch> matches,
  ) {
    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: matches.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final match = matches[index];
          return RecipeMatchCard(match: match, width: 200);
        },
      ),
    );
  }

  Widget _buildNoMatchesState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(
                PhosphorIcons.forkKnife(),
                size: 24,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.recipesYouCanMake,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              children: [
                PhosphorIcon(
                  PhosphorIcons.magnifyingGlass(),
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add More Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We\'ll find recipes that match what you have! Add a few more ingredients to see recipe suggestions.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.lightbulb(),
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Try adding: Rice, Onions, Garlic',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
