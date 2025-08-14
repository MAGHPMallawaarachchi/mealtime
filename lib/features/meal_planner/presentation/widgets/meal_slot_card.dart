import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/optimized_cached_image.dart';
import '../../domain/models/meal_slot.dart';
import '../../data/dummy_meal_plan_service.dart';
import '../../../home/data/dummy_meal_plan_data.dart';

class MealSlotCard extends StatelessWidget {
  final MealSlot mealSlot;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isCompact;
  final bool showTime;

  const MealSlotCard({
    super.key,
    required this.mealSlot,
    this.onTap,
    this.onLongPress,
    this.isCompact = false,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    if (mealSlot.isEmpty) {
      return _buildEmptySlot();
    }

    return _buildFilledSlot();
  }

  Widget _buildEmptySlot() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isCompact ? 80 : 100,
        margin: EdgeInsets.symmetric(
          vertical: 4,
          horizontal: isCompact ? 2 : 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border.withOpacity(0.5),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: isCompact ? 20 : 24,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              mealSlot.type.displayName,
              style: TextStyle(
                fontSize: isCompact ? 12 : 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showTime) ...[
              const SizedBox(height: 2),
              Text(
                mealSlot.displayTime,
                style: TextStyle(
                  fontSize: isCompact ? 10 : 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilledSlot() {
    final mealName = _getMealDisplayName();
    final imageUrl = _getMealImageUrl();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: isCompact ? 80 : 100,
        margin: EdgeInsets.symmetric(
          vertical: 4,
          horizontal: isCompact ? 2 : 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Image section
                if (imageUrl != null) ...[
                  Container(
                    width: isCompact ? 50 : 70,
                    height: double.infinity,
                    margin: EdgeInsets.all(isCompact ? 6 : 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: OptimizedCachedImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        preload: true,
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: isCompact ? 50 : 70,
                    height: double.infinity,
                    margin: EdgeInsets.all(isCompact ? 6 : 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      PhosphorIcons.forkKnife(),
                      color: AppColors.primary,
                      size: isCompact ? 20 : 24,
                    ),
                  ),
                ],
                // Content section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isCompact ? 4 : 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showTime) ...[
                          Text(
                            mealSlot.displayTime,
                            style: TextStyle(
                              fontSize: isCompact ? 10 : 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          mealName,
                          style: TextStyle(
                            fontSize: isCompact ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: isCompact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mealSlot.type.displayName,
                          style: TextStyle(
                            fontSize: isCompact ? 10 : 12,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
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
                    borderRadius: BorderRadius.circular(12),
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
    if (mealSlot.customMealName != null) {
      return mealSlot.customMealName!;
    }

    if (mealSlot.recipeId != null) {
      final recipe = DummyMealPlanData.getRecipeById(mealSlot.recipeId!);
      return recipe?.title ?? 'Unknown Recipe';
    }

    if (mealSlot.leftoverId != null) {
      return 'Leftover Meal'; // Would fetch actual leftover data
    }

    return 'Unknown Meal';
  }

  String? _getMealImageUrl() {
    if (mealSlot.recipeId != null) {
      final recipe = DummyMealPlanData.getRecipeById(mealSlot.recipeId!);
      return recipe?.imageUrl;
    }

    // Could add leftover images or default meal type images
    return null;
  }
}
