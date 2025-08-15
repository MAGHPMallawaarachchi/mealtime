import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/daily_meal_plan.dart';
import '../../domain/models/meal_slot.dart';
import 'compact_meal_card.dart';

class DayTimelineView extends StatelessWidget {
  final DailyMealPlan dayPlan;
  final Function(MealSlot)? onMealTap;
  final Function(MealSlot)? onMealLongPress;

  const DayTimelineView({
    super.key,
    required this.dayPlan,
    this.onMealTap,
    this.onMealLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final sortedMeals = dayPlan.mealsByTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDayHeader(),
        const SizedBox(height: 16),
        if (sortedMeals.isEmpty) ...[
          _buildEmptyState(),
        ] else ...[
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sortedMeals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final meal = sortedMeals[index];
                return _buildTimelineItem(meal, index);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDayHeader() {
    final today = DateTime.now();
    final isToday = dayPlan.date.year == today.year &&
        dayPlan.date.month == today.month &&
        dayPlan.date.day == today.day;

    final dayName = _getDayName(dayPlan.date.weekday);
    final dateStr = '${dayPlan.date.day}/${dayPlan.date.month}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildDayStats(),
        ],
      ),
    );
  }

  Widget _buildDayStats() {
    final plannedMeals = dayPlan.scheduledMeals.length;
    final totalServings = dayPlan.scheduledMeals.fold<int>(
      0,
      (sum, meal) => sum + meal.servingSize,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$plannedMeals meals',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$totalServings servings',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.calendar(),
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No meals planned',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button in navigation to add your first meal',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(MealSlot meal, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time indicator column
        SizedBox(
          width: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                meal.displayTime,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 2,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Meal card
        Expanded(
          child: CompactMealCard(
            mealSlot: meal,
            onTap: () => onMealTap?.call(meal),
            onLongPress: () => onMealLongPress?.call(meal),
          ),
        ),
      ],
    );
  }


  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}