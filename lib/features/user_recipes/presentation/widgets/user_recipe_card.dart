import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/optimized_cached_image.dart';
import '../../domain/models/user_recipe.dart';

class UserRecipeCard extends StatelessWidget {
  final UserRecipe recipe;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserRecipeCard({
    super.key,
    required this.recipe,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/user-recipe/${recipe.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 12,
                    left: 12,
                    right: 12,
                    bottom: 8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: recipe.imageUrl != null
                          ? OptimizedCachedImage(
                              imageUrl: recipe.imageUrl!,
                              fit: BoxFit.cover,
                              preload: true,
                            )
                          : Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PhosphorIcon(
                                    PhosphorIcons.forkKnife(),
                                    size: 32,
                                    color: AppColors.primary.withOpacity(0.6),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No Image',
                                    style: TextStyle(
                                      color: AppColors.primary.withOpacity(0.6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
                
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: PhosphorIcon(
                      PhosphorIcons.user(),
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor().withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          recipe.difficulty.emoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.difficulty.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.clock(),
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.totalTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 12),
                        PhosphorIcon(
                          PhosphorIcons.users(),
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.servings} servings',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onEdit != null || onDelete != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (onEdit != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onEdit,
                                icon: PhosphorIcon(PhosphorIcons.pencil(), size: 14),
                                label: const Text(
                                  'Edit',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  minimumSize: const Size(0, 32),
                                ),
                              ),
                            ),
                          if (onEdit != null && onDelete != null) const SizedBox(width: 8),
                          if (onDelete != null)
                            IconButton(
                              onPressed: onDelete,
                              icon: PhosphorIcon(PhosphorIcons.trash(), size: 16),
                              style: IconButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.all(4),
                                minimumSize: const Size(32, 32),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (recipe.difficulty) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.medium:
        return Colors.orange;
      case DifficultyLevel.hard:
        return Colors.red;
    }
  }
}