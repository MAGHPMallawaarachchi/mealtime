import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/optimized_cached_image.dart';
import '../../domain/models/recipe_match.dart';

class RecipeMatchCard extends StatelessWidget {
  final RecipeMatch match;
  final VoidCallback? onTap;

  const RecipeMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getMatchBorderColor().withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () => _navigateToRecipe(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: OptimizedCachedImage(
                    imageUrl: match.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Recipe details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and user recipe indicator
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              match.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (match.isUserRecipe) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'MINE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Match indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getMatchColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PhosphorIcon(
                              _getMatchIcon(),
                              size: 14,
                              color: _getMatchColor(),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${match.availableIngredients}/${match.totalIngredients} ingredients',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getMatchColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Recipe info
                      Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.clock(),
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            match.time,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          PhosphorIcon(
                            PhosphorIcons.flame(),
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${match.calories} cal',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      
                      // Missing ingredients preview
                      if (match.missingIngredientNames.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Missing: ${match.missingIngredientNames.take(2).join(', ')}${match.missingIngredientNames.length > 2 ? '...' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getMatchColor() {
    switch (match.matchType) {
      case MatchType.complete:
        return AppColors.success;
      case MatchType.partial:
        return AppColors.warning;
      case MatchType.minimal:
        return AppColors.info;
    }
  }

  Color _getMatchBorderColor() {
    switch (match.matchType) {
      case MatchType.complete:
        return AppColors.success;
      case MatchType.partial:
        return AppColors.warning;
      case MatchType.minimal:
        return AppColors.info;
    }
  }

  IconData _getMatchIcon() {
    switch (match.matchType) {
      case MatchType.complete:
        return PhosphorIcons.checkCircle();
      case MatchType.partial:
        return PhosphorIcons.clockCountdown();
      case MatchType.minimal:
        return PhosphorIcons.info();
    }
  }

  void _navigateToRecipe(BuildContext context) {
    if (match.isUserRecipe) {
      context.push('/user-recipe/${match.recipeId}');
    } else {
      context.push('/recipe/${match.recipeId}');
    }
  }
}