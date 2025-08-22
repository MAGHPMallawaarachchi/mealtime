import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/meal_plan_shimmer_card.dart';
import '../../data/dummy_meal_plan_data.dart';
import '../../domain/models/meal_plan_item.dart';
import 'meal_plan_card.dart';
import '../../../meal_planner/domain/models/meal_slot.dart';
import '../../../meal_planner/presentation/providers/meal_plan_providers.dart';

class TodaysMealPlanSection extends ConsumerWidget {
  const TodaysMealPlanSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaysMealPlanAsync = ref.watch(todaysMealPlanProvider);
    final String todayDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

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
                  const Text(
                    "Today's Meal Plan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    todayDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  context.push('/meal-planner');
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
        SizedBox(
          height: 250,
          child: todaysMealPlanAsync.when(
            data: (todaysMeals) {
              if (todaysMeals.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 12),
                itemCount: todaysMeals.length,
                itemBuilder: (context, index) {
                  final mealSlot = todaysMeals[index] as MealSlot;
                  final mealPlanItem = _convertMealSlotToMealPlanItem(mealSlot);
                  return MealPlanCard(mealPlan: mealPlanItem);
                },
              );
            },
            loading: () => const MealPlanShimmerSection(itemCount: 3),
            error: (error, stack) => _buildEmptyState(), // Silent failure
          ),
        ),
      ],
    );
  }

  MealPlanItem _convertMealSlotToMealPlanItem(MealSlot mealSlot) {
    String title = 'Unknown Meal';
    String imageUrl = 'https://images.unsplash.com/photo-1547573854-74d2a71d0826?w=800&h=600&fit=crop';

    if (mealSlot.customMealName != null) {
      title = mealSlot.customMealName!;
    } else if (mealSlot.recipeId != null) {
      final recipe = DummyMealPlanData.getRecipeById(mealSlot.recipeId!);
      if (recipe != null) {
        title = recipe.title;
        imageUrl = recipe.imageUrl;
      }
    }

    return MealPlanItem(
      id: mealSlot.id,
      title: title,
      time: mealSlot.displayTime,
      imageUrl: imageUrl,
      recipeId: mealSlot.recipeId,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
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
            PhosphorIcons.forkKnife(),
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            'No meals planned yet',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap "See All" to start planning your meals',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
