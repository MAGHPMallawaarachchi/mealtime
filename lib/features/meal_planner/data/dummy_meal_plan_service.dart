import '../domain/models/weekly_meal_plan.dart';
import '../domain/models/daily_meal_plan.dart';
import '../domain/models/meal_slot.dart';

class DummyMealPlanService {
  static WeeklyMealPlan getCurrentWeekPlan() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    return WeeklyMealPlan(
      id: _generateWeekId(monday),
      weekStartDate: monday,
      householdId: 'household_1',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      dailyPlans: _generateWeekPlan(monday),
    );
  }

  static WeeklyMealPlan getNextWeekPlan() {
    final now = DateTime.now();
    final nextMonday = now.add(Duration(days: 7 - now.weekday + 1));
    
    return WeeklyMealPlan(
      id: _generateWeekId(nextMonday),
      weekStartDate: nextMonday,
      householdId: 'household_1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      dailyPlans: _generateWeekPlan(nextMonday, isNextWeek: true),
    );
  }

  static WeeklyMealPlan getWeekPlan(DateTime weekStart) {
    final monday = weekStart.subtract(Duration(days: weekStart.weekday - 1));
    
    return WeeklyMealPlan(
      id: _generateWeekId(monday),
      weekStartDate: monday,
      householdId: 'household_1',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      dailyPlans: _generateWeekPlan(monday),
    );
  }

  static List<DailyMealPlan> _generateWeekPlan(DateTime monday, {bool isNextWeek = false}) {
    final weekPlans = <DailyMealPlan>[];
    
    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      
      // Create realistic Sri Lankan meal patterns
      final dayPlan = DailyMealPlan(
        date: date,
        meals: _generateDayMeals(dateStr, i, isNextWeek),
        notes: _getDayNotes(i),
      );
      
      weekPlans.add(dayPlan);
    }
    
    return weekPlans;
  }

  static List<MealSlot> _generateDayMeals(String dateStr, int dayIndex, bool isNextWeek) {
    final date = DateTime.parse('${dateStr}T00:00:00');
    
    // Return empty meal slots to demonstrate the UI
    return [
      MealSlot.createDefault(
        id: '${dateStr}_breakfast',
        category: MealCategory.breakfast,
        date: date,
      ),
      MealSlot.createDefault(
        id: '${dateStr}_lunch',
        category: MealCategory.lunch,
        date: date,
      ),
      MealSlot.createDefault(
        id: '${dateStr}_dinner',
        category: MealCategory.dinner,
        date: date,
      ),
    ];
  }

  static String? _getDayNotes(int dayIndex) {
    switch (dayIndex) {
      case 0:
        return 'Start the week with traditional Kiribath';
      case 3:
        return 'Consider using leftover vegetables';
      case 6:
        return 'Special Sunday meal preparation';
      default:
        return null;
    }
  }

  static String _generateWeekId(DateTime weekStart) {
    final year = weekStart.year;
    final dayOfYear = weekStart.difference(DateTime(year, 1, 1)).inDays + 1;
    final weekNumber = ((dayOfYear - weekStart.weekday + 10) / 7).floor();
    return '$year${weekNumber.toString().padLeft(2, '0')}';
  }

  // Get available recipe suggestions for meal planning
  static List<String> getBreakfastSuggestions() {
    return [
      'recipe_1', // Kiribath
      'Hoppers and Curry',
      'Bread and Tea',
      'Pol Roti and Curry',
      'String Hoppers',
      'Pittu and Curry',
    ];
  }

  static List<String> getLunchSuggestions() {
    return [
      'recipe_2', // Rice and Curry
      'recipe_3', // Kottu Roti
      'Fried Rice',
      'Noodles',
      'Biriyani',
      'Fish Curry and Rice',
    ];
  }

  static List<String> getDinnerSuggestions() {
    return [
      'recipe_2', // Rice and Curry
      'recipe_3', // Kottu Roti
      'recipe_4', // String Hoppers & Curry
      'Fish Curry and Rice',
      'Chicken Curry and Rice',
      'Biriyani',
      'Fried Rice',
    ];
  }

  // Get leftover transformation suggestions
  static List<String> getLeftoverSuggestions() {
    return [
      'Yesterday\'s Rice → Fried Rice',
      'Leftover Curry → Kottu Roti',
      'Cooked Rice → Rice Porridge',
      'Leftover Vegetables → Vegetable Stir Fry',
      'Remaining Dhal → Dhal Soup',
    ];
  }

  // Get seasonal recommendations (placeholder - would be enhanced with actual seasonal data)
  static List<String> getSeasonalSuggestions() {
    final month = DateTime.now().month;
    
    if (month >= 4 && month <= 9) {
      // Rainy season recommendations
      return [
        'Hot Soup and Rice',
        'Spicy Kottu Roti',
        'Ginger Tea with Snacks',
        'Fish Curry (fresh catch)',
      ];
    } else {
      // Dry season recommendations
      return [
        'Fresh Salads',
        'Coconut Water',
        'Light Curries',
        'Fresh Fruit Meals',
      ];
    }
  }
}