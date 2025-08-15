import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/weekly_meal_plan.dart';
import '../../domain/models/daily_meal_plan.dart';
import '../../domain/models/meal_slot.dart';
import '../../data/dummy_meal_plan_service.dart';
import 'meal_slot_card.dart';

class WeeklyCalendarView extends StatefulWidget {
  final DateTime? initialWeek;
  final Function(MealSlot, DateTime)? onMealSlotTap;
  final Function(MealSlot, DateTime)? onMealSlotLongPress;

  const WeeklyCalendarView({
    super.key,
    this.initialWeek,
    this.onMealSlotTap,
    this.onMealSlotLongPress,
  });

  @override
  State<WeeklyCalendarView> createState() => _WeeklyCalendarViewState();
}

class _WeeklyCalendarViewState extends State<WeeklyCalendarView> {
  late DateTime currentWeekStart;
  late WeeklyMealPlan currentWeekPlan;
  final PageController _pageController = PageController(initialPage: 1000);

  @override
  void initState() {
    super.initState();
    final today = widget.initialWeek ?? DateTime.now();
    currentWeekStart = _getWeekStart(today);
    _loadWeekPlan();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _loadWeekPlan() {
    currentWeekPlan = DummyMealPlanService.getWeekPlan(currentWeekStart);
  }

  void _navigateToWeek(int direction) {
    setState(() {
      currentWeekStart = currentWeekStart.add(Duration(days: 7 * direction));
      _loadWeekPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeekHeader(),
        _buildDayHeaders(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              final weekOffset = index - 1000;
              final newWeekStart = _getWeekStart(DateTime.now()).add(Duration(days: 7 * weekOffset));
              setState(() {
                currentWeekStart = newWeekStart;
                _loadWeekPlan();
              });
            },
            itemBuilder: (context, index) {
              final weekOffset = index - 1000;
              final weekStart = _getWeekStart(DateTime.now()).add(Duration(days: 7 * weekOffset));
              final weekPlan = DummyMealPlanService.getWeekPlan(weekStart);
              return _buildWeekContent(weekPlan);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekHeader() {
    final weekEnd = currentWeekStart.add(const Duration(days: 6));
    final isCurrentWeek = _isCurrentWeek(currentWeekStart);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _navigateToWeek(-1),
            icon: PhosphorIcon(
              PhosphorIcons.caretLeft(),
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _formatWeekRange(currentWeekStart, weekEnd),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isCurrentWeek)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
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
              ],
            ),
          ),
          IconButton(
            onPressed: () => _navigateToWeek(1),
            icon: PhosphorIcon(
              PhosphorIcons.caretRight(),
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeaders() {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: List.generate(7, (index) {
          final dayDate = currentWeekStart.add(Duration(days: index));
          final isToday = _isSameDay(dayDate, today);
          
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(
                    dayNames[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isToday ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        dayDate.day.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isToday ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWeekContent(WeeklyMealPlan weekPlan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: List.generate(7, (dayIndex) {
          final dayDate = weekPlan.weekStartDate.add(Duration(days: dayIndex));
          final dayPlan = weekPlan.getDayPlan(dayDate);
          
          return Expanded(
            child: _buildDayColumn(dayPlan, dayDate),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumn(DailyMealPlan? dayPlan, DateTime date) {
    if (dayPlan == null) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        children: [
          // Breakfast
          Expanded(
            child: () {
              final mealSlot = dayPlan.getFirstMealByCategory(MealCategory.breakfast) ?? MealSlot.createDefault(
                id: '${date.toIso8601String().split('T')[0]}_breakfast',
                category: MealCategory.breakfast,
                date: date,
              );
              return MealSlotCard(
                mealSlot: mealSlot,
                isCompact: true,
                showTime: false,
                onTap: () => _handleMealSlotTap(mealSlot, date),
                onLongPress: () => _handleMealSlotLongPress(mealSlot, date),
              );
            }(),
          ),
          // Lunch
          Expanded(
            child: () {
              final mealSlot = dayPlan.getFirstMealByCategory(MealCategory.lunch) ?? MealSlot.createDefault(
                id: '${date.toIso8601String().split('T')[0]}_lunch',
                category: MealCategory.lunch,
                date: date,
              );
              return MealSlotCard(
                mealSlot: mealSlot,
                isCompact: true,
                showTime: false,
                onTap: () => _handleMealSlotTap(mealSlot, date),
                onLongPress: () => _handleMealSlotLongPress(mealSlot, date),
              );
            }(),
          ),
          // Dinner
          Expanded(
            child: () {
              final mealSlot = dayPlan.getFirstMealByCategory(MealCategory.dinner) ?? MealSlot.createDefault(
                id: '${date.toIso8601String().split('T')[0]}_dinner',
                category: MealCategory.dinner,
                date: date,
              );
              return MealSlotCard(
                mealSlot: mealSlot,
                isCompact: true,
                showTime: false,
                onTap: () => _handleMealSlotTap(mealSlot, date),
                onLongPress: () => _handleMealSlotLongPress(mealSlot, date),
              );
            }(),
          ),
        ],
      ),
    );
  }

  void _handleMealSlotTap(MealSlot mealSlot, DateTime date) {
    widget.onMealSlotTap?.call(mealSlot, date);
  }

  void _handleMealSlotLongPress(MealSlot mealSlot, DateTime date) {
    widget.onMealSlotLongPress?.call(mealSlot, date);
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
}