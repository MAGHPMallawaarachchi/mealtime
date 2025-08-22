import '../domain/models/weekly_meal_plan.dart';
import '../domain/models/daily_meal_plan.dart';
import '../domain/models/meal_slot.dart';

class MealPlanTestUtils {
  /// Create a sample weekly meal plan for testing
  static WeeklyMealPlan createSampleWeekPlan({String? userId}) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    // Create sample meal slots for today
    final today = DateTime.now();
    final todayDateStr = today.toIso8601String().split('T')[0];
    
    final todayMeals = [
      MealSlot(
        id: '${todayDateStr}_breakfast',
        category: MealCategory.breakfast,
        scheduledTime: DateTime(today.year, today.month, today.day, 8, 30),
        customMealName: 'Kiribath with Pol Sambol',
      ),
      MealSlot(
        id: '${todayDateStr}_lunch',
        category: MealCategory.lunch,
        scheduledTime: DateTime(today.year, today.month, today.day, 12, 30),
        recipeId: 'recipe_2', // Rice and Curry
      ),
      MealSlot(
        id: '${todayDateStr}_dinner',
        category: MealCategory.dinner,
        scheduledTime: DateTime(today.year, today.month, today.day, 19, 0),
        recipeId: 'recipe_3', // Kottu Roti
      ),
    ];
    
    final dailyPlans = List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      final isToday = date.day == today.day && 
                     date.month == today.month && 
                     date.year == today.year;
      
      return DailyMealPlan(
        date: date,
        meals: isToday ? todayMeals : [],
      );
    });
    
    return WeeklyMealPlan(
      id: _generateWeekId(monday),
      weekStartDate: monday,
      dailyPlans: dailyPlans,
      userId: userId,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now(),
    );
  }
  
  static String _generateWeekId(DateTime weekStart) {
    final year = weekStart.year;
    final dayOfYear = weekStart.difference(DateTime(year, 1, 1)).inDays + 1;
    final weekNumber = ((dayOfYear - weekStart.weekday + 10) / 7).floor();
    return '$year${weekNumber.toString().padLeft(2, '0')}';
  }
}