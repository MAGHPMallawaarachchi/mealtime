import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/optimized_cached_image.dart';
import '../../domain/models/meal_slot.dart';
import '../../../home/data/dummy_meal_plan_data.dart';

class CompactMealCard extends StatelessWidget {
  final MealSlot mealSlot;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showTime;

  const CompactMealCard({
    super.key,
    required this.mealSlot,
    this.onTap,
    this.onLongPress,
    this.showTime = false,
  });

  @override
  Widget build(BuildContext context) {
    if (mealSlot.isEmpty) {
      return _buildEmptyCard();
    }

    return _buildFilledCard();
  }

  Widget _buildEmptyCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: double.infinity,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add ${mealSlot.category}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (showTime) ...[
                      const SizedBox(height: 2),
                      Text(
                        mealSlot.displayTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
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

  Widget _buildFilledCard() {
    final mealName = _getMealDisplayName();
    final imageUrl = _getMealImageUrl();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Image or icon section
                Container(
                  width: 60,
                  height: double.infinity,
                  margin: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl != null
                        ? OptimizedCachedImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            preload: true,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              PhosphorIcons.forkKnife(),
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                  ),
                ),
                // Content section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Meal name
                        Text(
                          mealName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Category and serving info
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                mealSlot.category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (mealSlot.servingSize > 1) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${mealSlot.servingSize}x',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (showTime) ...[
                          const SizedBox(height: 2),
                          Text(
                            mealSlot.displayTime,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Action indicator
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    PhosphorIcons.caretRight(),
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            // Lock indicator
            if (mealSlot.isLocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIcons.lock(),
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getMealDisplayName() {
    if (mealSlot.customMealName != null && mealSlot.customMealName!.isNotEmpty) {
      return mealSlot.customMealName!;
    }

    if (mealSlot.recipeId != null) {
      final recipe = DummyMealPlanData.getRecipeById(mealSlot.recipeId!);
      return recipe?.title ?? 'Unknown Recipe';
    }

    if (mealSlot.leftoverId != null) {
      return 'Leftover Meal'; // Would fetch actual leftover data
    }

    return mealSlot.category;
  }

  String? _getMealImageUrl() {
    if (mealSlot.recipeId != null) {
      final recipe = DummyMealPlanData.getRecipeById(mealSlot.recipeId!);
      return recipe?.imageUrl;
    }

    // Could add leftover images or category-based default images
    return null;
  }
}