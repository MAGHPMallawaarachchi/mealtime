import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/daily_meal_plan.dart';
import '../../domain/models/meal_slot.dart';
import 'compact_meal_card.dart';

class DayTimelineView extends StatelessWidget {
  final DailyMealPlan dayPlan;
  final DateTime? selectedDate;
  final Function(MealSlot)? onMealTap;
  final Function(MealSlot)? onMealLongPress;

  const DayTimelineView({
    super.key,
    required this.dayPlan,
    this.selectedDate,
    this.onMealTap,
    this.onMealLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final sortedMeals = dayPlan.mealsByTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDayHeader(context),
        const SizedBox(height: 16),
        if (sortedMeals.isEmpty) ...[
          _buildEmptyState(context),
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

  Widget _buildDayHeader(BuildContext context) {
    final today = DateTime.now();
    final displayDate = selectedDate ?? dayPlan.date;
    final isToday =
        displayDate.year == today.year &&
        displayDate.month == today.month &&
        displayDate.day == today.day;

    final dayName = _getDayName(displayDate.weekday, context);
    final dateStr = '${displayDate.day}/${displayDate.month}';

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.today,
                        style: const TextStyle(
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
          _buildDayStats(context),
        ],
      ),
    );
  }

  Widget _buildDayStats(BuildContext context) {
    final plannedMeals = dayPlan.scheduledMeals.length;
    final totalServings = dayPlan.scheduledMeals.fold<int>(
      0,
      (sum, meal) => sum + meal.servingSize,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$plannedMeals ${AppLocalizations.of(context)!.meals}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$totalServings ${AppLocalizations.of(context)!.servings}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            Text(
              AppLocalizations.of(context)!.noMealsPlannedEmpty,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.tapPlusButtonToAddMeal,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
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

  String _getDayName(int weekday, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (weekday) {
      case 1:
        return l10n!.monday;
      case 2:
        return l10n!.tuesday;
      case 3:
        return l10n!.wednesday;
      case 4:
        return l10n!.thursday;
      case 5:
        return l10n!.friday;
      case 6:
        return l10n!.saturday;
      case 7:
        return l10n!.sunday;
      default:
        return l10n!.unknown;
    }
  }
}
