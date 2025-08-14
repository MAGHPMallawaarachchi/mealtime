import 'daily_meal_plan.dart';
import 'meal_slot.dart';

class WeeklyMealPlan {
  final String id;
  final DateTime weekStartDate;
  final List<DailyMealPlan> dailyPlans;
  final String? householdId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WeeklyMealPlan({
    required this.id,
    required this.weekStartDate,
    required this.dailyPlans,
    this.householdId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get the week identifier (YYYYWW format as mentioned in PRD)
  String get weekId {
    final year = weekStartDate.year;
    final dayOfYear = weekStartDate.difference(DateTime(year, 1, 1)).inDays + 1;
    final weekNumber = ((dayOfYear - weekStartDate.weekday + 10) / 7).floor();
    return '$year${weekNumber.toString().padLeft(2, '0')}';
  }

  DateTime get weekEndDate => weekStartDate.add(const Duration(days: 6));

  // Get plan for specific date
  DailyMealPlan? getDayPlan(DateTime date) {
    return dailyPlans
        .where((plan) => isSameDay(plan.date, date))
        .firstOrNull;
  }

  // Get today's plan
  DailyMealPlan? get todaysPlan => getDayPlan(DateTime.now());

  // Get all scheduled meals for the week
  List<MealSlot> get allScheduledMeals {
    return dailyPlans
        .expand((day) => day.scheduledMeals)
        .toList();
  }

  // Get count of planned meals for the week
  int get totalPlannedMeals => allScheduledMeals.length;

  // Check if week has any planned meals
  bool get hasPlannedMeals => totalPlannedMeals > 0;

  // Get all locked meals
  List<MealSlot> get lockedMeals {
    return allScheduledMeals.where((meal) => meal.isLocked).toList();
  }

  // Get empty meal slots that can be auto-filled
  List<MealSlot> get emptySlots {
    return dailyPlans
        .expand((day) => day.meals)
        .where((meal) => meal.isEmpty && !meal.isLocked)
        .toList();
  }

  // Get estimated weekly calories
  int get estimatedWeeklyCalories {
    return dailyPlans.fold(0, (sum, day) => sum + day.estimatedCalories);
  }

  WeeklyMealPlan copyWith({
    String? id,
    DateTime? weekStartDate,
    List<DailyMealPlan>? dailyPlans,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeeklyMealPlan(
      id: id ?? this.id,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      dailyPlans: dailyPlans ?? this.dailyPlans,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  WeeklyMealPlan updateDayPlan(DailyMealPlan updatedDay) {
    final updatedPlans = dailyPlans.map((day) {
      return isSameDay(day.date, updatedDay.date) ? updatedDay : day;
    }).toList();

    return copyWith(
      dailyPlans: updatedPlans,
      updatedAt: DateTime.now(),
    );
  }

  WeeklyMealPlan updateMealSlot(DateTime date, MealSlot updatedSlot) {
    final dayPlan = getDayPlan(date);
    if (dayPlan != null) {
      final updatedDayPlan = dayPlan.updateMealSlot(updatedSlot);
      return updateDayPlan(updatedDayPlan);
    }
    return this;
  }

  // Create a new weekly meal plan for a given week start date
  static WeeklyMealPlan createForWeek(DateTime weekStart, {String? householdId}) {
    // Ensure weekStart is a Monday
    final monday = weekStart.subtract(Duration(days: weekStart.weekday - 1));
    final weekId = _generateWeekId(monday);
    
    final dailyPlans = List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      return DailyMealPlan.createDefault(date);
    });

    return WeeklyMealPlan(
      id: weekId,
      weekStartDate: monday,
      dailyPlans: dailyPlans,
      householdId: householdId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Create for current week
  static WeeklyMealPlan createForCurrentWeek({String? householdId}) {
    return createForWeek(DateTime.now(), householdId: householdId);
  }

  static String _generateWeekId(DateTime weekStart) {
    final year = weekStart.year;
    final dayOfYear = weekStart.difference(DateTime(year, 1, 1)).inDays + 1;
    final weekNumber = ((dayOfYear - weekStart.weekday + 10) / 7).floor();
    return '$year${weekNumber.toString().padLeft(2, '0')}';
  }

  // Helper function to check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyMealPlan &&
        other.id == id &&
        other.weekStartDate == weekStartDate &&
        other.dailyPlans.length == dailyPlans.length &&
        other.householdId == householdId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        weekStartDate.hashCode ^
        dailyPlans.hashCode ^
        householdId.hashCode;
  }

  @override
  String toString() {
    return 'WeeklyMealPlan(id: $id, week: $weekId, plannedMeals: $totalPlannedMeals)';
  }
}

// Extension to help with null safety for DailyMealPlan
extension DailyMealPlanFirstWhereOrNull on Iterable<DailyMealPlan> {
  DailyMealPlan? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}