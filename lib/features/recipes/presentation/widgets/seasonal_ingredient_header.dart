import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/optimized_cached_image.dart';
import '../../../home/domain/models/seasonal_ingredient.dart';

class SeasonalIngredientHeader extends StatelessWidget {
  final SeasonalIngredient ingredient;
  final int totalRecipesCount;
  final VoidCallback? onBackPressed;

  const SeasonalIngredientHeader({
    super.key,
    required this.ingredient,
    required this.totalRecipesCount,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Navigation bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  icon: PhosphorIcon(
                    PhosphorIcons.arrowLeft(),
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seasonal Recipes',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Ingredient showcase
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Ingredient image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ingredient.imageUrl.isNotEmpty
                          ? OptimizedCachedImage(
                              imageUrl: ingredient.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Ingredient info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seasonal badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PhosphorIcon(
                                PhosphorIcons.leaf(),
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'In Season',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Ingredient name
                        Text(
                          ingredient.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Recipe count
                        Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.cookingPot(),
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$totalRecipesCount recipe${totalRecipesCount != 1 ? 's' : ''} found',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(
            PhosphorIcons.leaf(),
            size: 28,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 4),
          Text(
            'Seasonal',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}