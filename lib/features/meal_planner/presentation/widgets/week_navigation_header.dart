import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/weekly_meal_plan.dart';

class WeekNavigationHeader extends StatelessWidget {
  final WeeklyMealPlan weekPlan;
  final DateTime selectedDate;
  final Function(DateTime) onDaySelected;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;

  const WeekNavigationHeader({
    super.key,
    required this.weekPlan,
    required this.selectedDate,
    required this.onDaySelected,
    this.onPreviousWeek,
    this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildWeekHeader(),
          const SizedBox(height: 16),
          _buildDayIndicators(),
        ],
      ),
    );
  }

  Widget _buildWeekHeader() {
    final weekEnd = weekPlan.weekStartDate.add(const Duration(days: 6));
    final isCurrentWeek = _isCurrentWeek(weekPlan.weekStartDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPreviousWeek,
          icon: PhosphorIcon(
            PhosphorIcons.caretLeft(),
            color: AppColors.textPrimary,
          ),
          tooltip: 'Previous week',
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                _formatWeekRange(weekPlan.weekStartDate, weekEnd),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCurrentWeek) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'This Week',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _buildWeekStats(),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNextWeek,
          icon: PhosphorIcon(
            PhosphorIcons.caretRight(),
            color: AppColors.textPrimary,
          ),
          tooltip: 'Next week',
        ),
      ],
    );
  }

  Widget _buildWeekStats() {
    final totalMeals = weekPlan.dailyPlans.fold<int>(
      0,
      (sum, dayPlan) => sum + dayPlan.scheduledMeals.length,
    );

    return Text(
      '$totalMeals meals planned',
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDayIndicators() {
    final today = DateTime.now();
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      children: List.generate(7, (index) {
        final dayDate = weekPlan.weekStartDate.add(Duration(days: index));
        final dayPlan = weekPlan.getDayPlan(dayDate);
        final isToday = _isSameDay(dayDate, today);
        final isSelected = _isSameDay(dayDate, selectedDate);
        final mealCount = dayPlan?.scheduledMeals.length ?? 0;

        return Expanded(
          child: GestureDetector(
            onTap: () => onDaySelected(dayDate),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: _buildDayIndicator(
                dayName: dayNames[index],
                dayNumber: dayDate.day,
                isToday: isToday,
                isSelected: isSelected,
                mealCount: mealCount,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayIndicator({
    required String dayName,
    required int dayNumber,
    required bool isToday,
    required bool isSelected,
    required int mealCount,
  }) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      borderColor = AppColors.primary;
    } else if (isToday) {
      backgroundColor = AppColors.primary.withOpacity(0.1);
      textColor = AppColors.primary;
      borderColor = AppColors.primary.withOpacity(0.3);
    } else {
      backgroundColor = Colors.transparent;
      textColor = AppColors.textPrimary;
      borderColor = AppColors.border.withOpacity(0.5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayNumber.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          // Meal count indicator
          if (mealCount > 0) ...[
            Container(
              height: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    mealCount.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.9)
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  String _formatWeekRange(DateTime start, DateTime end) {
    if (start.month == end.month) {
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('d, yyyy').format(end)}';
    } else {
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
    }
  }

  bool _isCurrentWeek(DateTime weekStart) {
    final now = DateTime.now();
    final thisWeekStart = _getWeekStart(now);
    return _isSameDay(weekStart, thisWeekStart);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
}