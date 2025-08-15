import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/weekly_meal_plan.dart';
import '../../domain/models/daily_meal_plan.dart';
import '../../domain/models/meal_slot.dart';
import '../../data/dummy_meal_plan_service.dart';
import '../../../home/data/dummy_meal_plan_data.dart';

class TodaysPrepView extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(MealSlot)? onMealTap;

  const TodaysPrepView({
    super.key,
    this.selectedDate,
    this.onMealTap,
  });

  @override
  State<TodaysPrepView> createState() => _TodaysPrepViewState();
}

class _TodaysPrepViewState extends State<TodaysPrepView> {
  late DateTime currentDate;
  DailyMealPlan? todaysPlan;

  @override
  void initState() {
    super.initState();
    currentDate = widget.selectedDate ?? DateTime.now();
    _loadTodaysPlan();
  }

  @override
  void didUpdateWidget(TodaysPrepView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      currentDate = widget.selectedDate ?? DateTime.now();
      _loadTodaysPlan();
    }
  }

  void _loadTodaysPlan() {
    final weekPlan = DummyMealPlanService.getWeekPlan(currentDate);
    setState(() {
      todaysPlan = weekPlan.getDayPlan(currentDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateHeader(),
          const SizedBox(height: 20),
          if (todaysPlan?.hasPlannedMeals ?? false) ...[
            _buildPrepSchedule(),
            const SizedBox(height: 24),
            _buildMealsList(),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final isToday = _isToday(currentDate);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isToday ? 'Today\'s Prep Schedule' : 'Meal Prep Schedule',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(currentDate),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: _showDatePicker,
          icon: PhosphorIcon(
            PhosphorIcons.calendar(),
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPrepSchedule() {
    final meals = todaysPlan!.scheduledMeals;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(
                PhosphorIcons.clock(),
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Recommended Prep Timeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...meals.map((meal) => _buildPrepTimelineItem(meal)).toList(),
        ],
      ),
    );
  }

  Widget _buildPrepTimelineItem(MealSlot meal) {
    final prepTime = _calculatePrepTime(meal);
    final cookingTime = _getCookingTime(meal);
    final mealName = _getMealName(meal);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            child: Text(
              prepTime,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prep for $mealName',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Cooking time: $cookingTime',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList() {
    final meals = todaysPlan!.scheduledMeals;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Planned Meals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...meals.map((meal) => _buildMealItem(meal)).toList(),
      ],
    );
  }

  Widget _buildMealItem(MealSlot meal) {
    final mealName = _getMealName(meal);
    final imageUrl = _getMealImageUrl(meal);
    
    return GestureDetector(
      onTap: () => widget.onMealTap?.call(meal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          PhosphorIcons.forkKnife(),
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Icon(
                      PhosphorIcons.forkKnife(),
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        meal.displayTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${meal.category}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (meal.isLocked)
              Icon(
                PhosphorIcons.lock(),
                size: 16,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.calendar(),
              size: 64,
              color: AppColors.textSecondary,
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
              'Add meals to your weekly plan to see\nyour prep schedule here',
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

  String _calculatePrepTime(MealSlot meal) {
    // Calculate prep time based on meal time and cooking duration
    final mealTimeStr = meal.displayTime;
    final cookingDuration = _getCookingDurationMinutes(meal);
    
    try {
      final mealTime = _parseTime(mealTimeStr);
      final prepTime = mealTime.subtract(Duration(minutes: cookingDuration + 30)); // 30 min prep buffer
      return DateFormat('h:mm a').format(prepTime);
    } catch (e) {
      return '1 hr before';
    }
  }

  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final time = DateFormat('h:mm a').parse(timeStr);
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  String _getCookingTime(MealSlot meal) {
    final minutes = _getCookingDurationMinutes(meal);
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    } else {
      return '${minutes}m';
    }
  }

  int _getCookingDurationMinutes(MealSlot meal) {
    if (meal.recipeId != null) {
      final recipe = DummyMealPlanData.getRecipeById(meal.recipeId!);
      if (recipe != null) {
        // Parse time string like "30 Min" or "1 hour 30 min"
        final timeStr = recipe.time.toLowerCase();
        if (timeStr.contains('hour')) {
          final hours = int.tryParse(timeStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
          return hours * 60;
        } else {
          final minutes = int.tryParse(timeStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
          return minutes;
        }
      }
    }
    
    // Default cooking times based on meal category
    switch (meal.category) {
      case MealCategory.breakfast:
        return 15;
      case MealCategory.lunch:
        return 45;
      case MealCategory.dinner:
        return 60;
      case MealCategory.snack:
        return 10;
      default:
        return 30; // Default cooking time for custom categories
    }
  }

  String _getMealName(MealSlot meal) {
    if (meal.customMealName != null) {
      return meal.customMealName!;
    }
    
    if (meal.recipeId != null) {
      final recipe = DummyMealPlanData.getRecipeById(meal.recipeId!);
      return recipe?.title ?? 'Unknown Recipe';
    }
    
    if (meal.leftoverId != null) {
      return 'Leftover Meal';
    }
    
    return meal.category;
  }

  String? _getMealImageUrl(MealSlot meal) {
    if (meal.recipeId != null) {
      final recipe = DummyMealPlanData.getRecipeById(meal.recipeId!);
      return recipe?.imageUrl;
    }
    return null;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != currentDate) {
      setState(() {
        currentDate = picked;
        _loadTodaysPlan();
      });
    }
  }
}