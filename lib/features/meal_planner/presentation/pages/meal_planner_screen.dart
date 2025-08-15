import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/meal_slot.dart';
import '../../domain/models/daily_meal_plan.dart';
import '../../domain/models/weekly_meal_plan.dart';
import '../../data/dummy_meal_plan_service.dart';
import '../widgets/day_timeline_view.dart';
import '../widgets/week_navigation_header.dart';
import '../widgets/meal_detail_expanded_view.dart';
import '../widgets/time_picker_modal.dart';
import '../widgets/recipe_selection_modal.dart';
import '../widgets/meal_confirmation_modal.dart';
import '../../../recipes/domain/models/recipe.dart';

class MealPlannerScreen extends StatefulWidget {
  final Function(VoidCallback)? onRegisterAddMealCallback;

  const MealPlannerScreen({super.key, this.onRegisterAddMealCallback});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  late PageController _pageController;
  late DateTime currentWeekStart;
  late WeeklyMealPlan currentWeekPlan;
  late DateTime selectedDate;
  late DateTime _todayNormalized; // Cached normalized today reference
  bool _isUserSwipe = true; // Track if page change is from user swipe or programmatic
  
  static const int _initialPage = 1000; // For infinite scroll

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    final today = DateTime.now();
    _todayNormalized = _normalizeDate(today);
    currentWeekStart = _getWeekStart(_todayNormalized);
    selectedDate = _todayNormalized;
    _loadWeekPlan();
    
    // Register our add meal callback with the parent
    widget.onRegisterAddMealCallback?.call(triggerAddMeal);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  /// Normalizes a DateTime to midnight (00:00:00) for consistent date calculations
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Checks if two dates represent the same calendar day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  
  DateTime _getWeekStart(DateTime date) {
    final normalized = _normalizeDate(date);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  /// Public method to trigger add meal functionality from external sources (like navbar)
  void triggerAddMeal() {
    _showAddMealOptions(selectedDate);
  }
  
  void _loadWeekPlan() {
    setState(() {
      currentWeekPlan = DummyMealPlanService.getWeekPlan(currentWeekStart);
    });
  }

  void _navigateToWeek(int direction) {
    setState(() {
      currentWeekStart = currentWeekStart.add(Duration(days: 7 * direction));
      // Ensure selected date is within the new week
      final weekEnd = currentWeekStart.add(const Duration(days: 6));
      if (direction < 0 && selectedDate.isAfter(weekEnd)) {
        selectedDate = weekEnd;
      } else if (direction > 0 && selectedDate.isBefore(currentWeekStart)) {
        selectedDate = currentWeekStart;
      }
      _loadWeekPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            WeekNavigationHeader(
              weekPlan: currentWeekPlan,
              selectedDate: selectedDate,
              onDaySelected: _onDaySelected,
              onPreviousWeek: () => _navigateToWeek(-1),
              onNextWeek: () => _navigateToWeek(1),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final dayOffset = index - _initialPage;
                  final dayDate = _todayNormalized.add(Duration(days: dayOffset));
                  final dayPlan = _getDayPlan(dayDate);
                  
                  return DayTimelineView(
                    dayPlan: dayPlan,
                    onMealTap: (meal) => _handleMealTap(meal, dayDate),
                    onMealLongPress: (meal) => _handleMealLongPress(meal, dayDate),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meal Planner',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Plan your meals with flexibility',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: _showAutoFillDialog,
                icon: PhosphorIcon(
                  PhosphorIcons.magicWand(),
                  color: AppColors.primary,
                ),
                tooltip: 'Auto-fill meals',
              ),
              IconButton(
                onPressed: _showMealPlanOptions,
                icon: PhosphorIcon(
                  PhosphorIcons.dotsThreeVertical(),
                  color: AppColors.textPrimary,
                ),
                tooltip: 'More options',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onDaySelected(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    
    // Only update if the date has actually changed
    if (!_isSameDay(selectedDate, normalizedDate)) {
      setState(() {
        selectedDate = normalizedDate;
      });
    }
    
    // Calculate the offset from today to the selected date using normalized dates
    final difference = normalizedDate.difference(_todayNormalized).inDays;
    final targetPage = _initialPage + difference;
    
    // Flag this as programmatic navigation to prevent circular updates
    _isUserSwipe = false;
    
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ).then((_) {
      // Reset the flag after animation completes
      _isUserSwipe = true;
    });
  }
  
  void _onPageChanged(int index) {
    // Only update selectedDate for user swipes, not programmatic navigation
    if (!_isUserSwipe) return;
    
    final dayOffset = index - _initialPage;
    final newDate = _normalizeDate(_todayNormalized.add(Duration(days: dayOffset)));
    
    setState(() {
      selectedDate = newDate;
      
      // Update week if we've moved to a different week
      final newWeekStart = _getWeekStart(newDate);
      if (!_isSameDay(newWeekStart, currentWeekStart)) {
        currentWeekStart = newWeekStart;
        _loadWeekPlan();
      }
    });
  }
  
  DailyMealPlan _getDayPlan(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final weekStart = _getWeekStart(normalizedDate);
    final weekPlan = _isSameDay(weekStart, currentWeekStart)
        ? currentWeekPlan 
        : DummyMealPlanService.getWeekPlan(weekStart);
    
    return weekPlan.getDayPlan(normalizedDate) ?? DailyMealPlan.createDefault(normalizedDate);
  }

  void _handleMealTap(MealSlot mealSlot, DateTime date) {
    if (mealSlot.isEmpty) {
      _showAddMealModal(mealSlot, date);
    } else {
      showMealDetailExpandedView(
        context: context,
        mealSlot: mealSlot,
        date: date,
        onMealUpdated: (updatedMeal) => _updateMeal(updatedMeal, date),
        onMealDeleted: (meal) => _deleteMeal(meal, date),
        onViewRecipe: () => _viewRecipe(mealSlot),
      );
    }
  }

  void _handleMealLongPress(MealSlot mealSlot, DateTime date) {
    _showMealContextMenu(mealSlot, date);
  }

  void _showAddMealModal(MealSlot mealSlot, DateTime date) {
    _showQuickAddMealDialog(date);
  }
  
  void _showQuickAddMealDialog(DateTime date) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Meal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...MealCategory.predefined.map((category) => 
              ListTile(
                leading: PhosphorIcon(_getCategoryIcon(category)),
                title: Text(category),
                onTap: () {
                  Navigator.pop(context);
                  _addQuickMeal(date, category);
                },
              ),
            ),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.plus()),
              title: const Text('Custom Meal'),
              onTap: () {
                Navigator.pop(context);
                _showCustomMealDialog(date);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addQuickMeal(DateTime date, String category) {
    showTimePickerModal(
      context: context,
      initialTime: MealCategory.defaultTimes[category] ?? const TimeOfDay(hour: 12, minute: 0),
      mealCategory: category,
      onTimeSelected: (time) {
        final mealSlot = MealSlot(
          id: '${date.toIso8601String().split('T')[0]}_${DateTime.now().millisecondsSinceEpoch}',
          category: category,
          scheduledTime: DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          ),
          customMealName: category,
        );
        
        _addMeal(mealSlot, date);
      },
    );
  }
  
  void _showCustomMealDialog(DateTime date) {
    String mealName = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Meal'),
        content: TextField(
          onChanged: (value) => mealName = value,
          decoration: const InputDecoration(
            labelText: 'Meal Name',
            hintText: 'Enter meal name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (mealName.isNotEmpty) {
                Navigator.pop(context);
                _addQuickMeal(date, mealName);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showMealContextMenu(MealSlot mealSlot, DateTime date) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.pencil()),
              title: const Text('Edit Meal'),
              onTap: () {
                Navigator.pop(context);
                showMealDetailExpandedView(
                  context: context,
                  mealSlot: mealSlot,
                  date: date,
                  onMealUpdated: (updatedMeal) => _updateMeal(updatedMeal, date),
                  onMealDeleted: (meal) => _deleteMeal(meal, date),
                  onViewRecipe: () => _viewRecipe(mealSlot),
                );
              },
            ),
            if (!mealSlot.isLocked)
              ListTile(
                leading: PhosphorIcon(PhosphorIcons.lock()),
                title: const Text('Lock Meal'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement lock functionality
                },
              )
            else
              ListTile(
                leading: PhosphorIcon(PhosphorIcons.lockOpen()),
                title: const Text('Unlock Meal'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement unlock functionality
                },
              ),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.trash()),
              title: const Text('Remove Meal'),
              textColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement remove functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMealOptions(DateTime date) {
    _showTimeSelectionForNewMeal(date);
  }

  void _showTimeSelectionForNewMeal(DateTime date) {
    showTimePickerModal(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      mealCategory: 'Custom', // This won't be used in the new flow
      onTimeSelected: (time) {
        _showRecipeSelectionModal(date, time);
      },
    );
  }

  void _showRecipeSelectionModal(DateTime date, TimeOfDay selectedTime) {
    // Add a small delay to ensure the time picker modal is fully closed
    Future.delayed(const Duration(milliseconds: 100), () {
      showRecipeSelectionModal(
        context: context,
        onRecipeSelected: (recipe) {
          Navigator.of(context).pop(); // Close recipe modal
          _showMealConfirmationModal(date, selectedTime, recipe);
        },
        onBack: () {
          Navigator.of(context).pop(); // Close recipe modal
          _showTimeSelectionForNewMeal(date); // Go back to time selection
        },
      );
    });
  }

  void _showMealConfirmationModal(DateTime date, TimeOfDay selectedTime, Recipe recipe) {
    showMealConfirmationModal(
      context: context,
      recipe: recipe,
      selectedTime: selectedTime,
      date: date,
      onConfirm: (mealSlot) {
        Navigator.of(context).pop(); // Close confirmation modal
        _addMeal(mealSlot, date);
      },
      onBackToRecipes: () {
        Navigator.of(context).pop(); // Close confirmation modal
        _showRecipeSelectionModal(date, selectedTime); // Go back to recipe selection
      },
      onBackToTime: () {
        Navigator.of(context).pop(); // Close confirmation modal
        _showTimeSelectionForNewMeal(date); // Go back to time selection
      },
      onTimeChangeRequest: (currentTime, onTimeChanged) {
        _showTimePickerForEdit(date, currentTime, selectedTime, recipe, onTimeChanged);
      },
      defaultServings: 4, // TODO: Get from user profile
    );
  }

  void _showTimePickerForEdit(
    DateTime date,
    TimeOfDay currentTime,
    TimeOfDay originalTime,
    Recipe recipe,
    Function(TimeOfDay) onTimeChanged,
  ) {
    showTimePickerModal(
      context: context,
      initialTime: currentTime,
      mealCategory: 'Edit', // Special mode for editing
      isEditMode: true,
      onTimeSelected: (newTime) {
        onTimeChanged(newTime); // Update the confirmation modal's time
      },
    );
  }
  
  void _addMeal(MealSlot mealSlot, DateTime date) {
    // TODO: Implement actual data persistence
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${mealSlot.displayName} added successfully!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
  
  void _updateMeal(MealSlot updatedMeal, DateTime date) {
    // TODO: Implement actual data persistence
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meal updated successfully!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
  
  void _deleteMeal(MealSlot meal, DateTime date) {
    // TODO: Implement actual data persistence
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meal deleted'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }
  
  void _viewRecipe(MealSlot mealSlot) {
    // TODO: Navigate to recipe detail
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recipe view coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case MealCategory.breakfast:
        return PhosphorIcons.coffee();
      case MealCategory.lunch:
        return PhosphorIcons.forkKnife();
      case MealCategory.dinner:
        return PhosphorIcons.cookingPot();
      case MealCategory.snack:
        return PhosphorIcons.cookie();
      case MealCategory.brunch:
        return PhosphorIcons.wine();
      case MealCategory.lateNight:
        return PhosphorIcons.moon();
      default:
        return PhosphorIcons.forkKnife();
    }
  }

  void _showAutoFillDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-fill Week'),
        content: const Text(
          'Automatically fill empty meal slots with suggestions based on your pantry, leftovers, and seasonal recipes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement auto-fill functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Auto-fill feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Auto-fill'),
          ),
        ],
      ),
    );
  }

  void _showMealPlanOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.shoppingCart()),
              title: const Text('Generate Shopping List'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to shopping list generation
              },
            ),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.clockCounterClockwise()),
              title: const Text('View Previous Weeks'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show week history
              },
            ),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.copy()),
              title: const Text('Duplicate Week'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement week duplication
              },
            ),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.trash()),
              title: const Text('Clear All Meals'),
              textColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                // TODO: Show clear confirmation
              },
            ),
          ],
        ),
      ),
    );
  }
}
