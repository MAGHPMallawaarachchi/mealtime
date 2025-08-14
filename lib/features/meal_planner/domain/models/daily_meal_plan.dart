import 'meal_slot.dart';

class DailyMealPlan {
  final DateTime date;
  final List<MealSlot> meals;
  final String? notes;
  final bool isCompleted;

  const DailyMealPlan({
    required this.date,
    required this.meals,
    this.notes,
    this.isCompleted = false,
  });

  // Get specific meal slots by type
  MealSlot? get breakfast => meals.where((m) => m.type == MealType.breakfast).firstOrNull;
  MealSlot? get lunch => meals.where((m) => m.type == MealType.lunch).firstOrNull;
  MealSlot? get dinner => meals.where((m) => m.type == MealType.dinner).firstOrNull;
  List<MealSlot> get snacks => meals.where((m) => m.type == MealType.snack).toList();

  // Get all non-empty meals
  List<MealSlot> get scheduledMeals => meals.where((m) => !m.isEmpty).toList();

  // Check if any meals are planned for this day
  bool get hasPlannedMeals => meals.any((m) => !m.isEmpty);

  // Check if any meals are locked
  bool get hasLockedMeals => meals.any((m) => m.isLocked);

  // Get count of planned meals
  int get plannedMealsCount => scheduledMeals.length;

  // Get total calories for the day (placeholder - would integrate with recipe data)
  int get estimatedCalories {
    // This would be calculated from actual recipe data
    return scheduledMeals.length * 400; // Placeholder calculation
  }

  DailyMealPlan copyWith({
    DateTime? date,
    List<MealSlot>? meals,
    String? notes,
    bool? isCompleted,
  }) {
    return DailyMealPlan(
      date: date ?? this.date,
      meals: meals ?? this.meals,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  DailyMealPlan updateMealSlot(MealSlot updatedSlot) {
    final updatedMeals = meals.map((meal) {
      return meal.id == updatedSlot.id ? updatedSlot : meal;
    }).toList();

    return copyWith(meals: updatedMeals);
  }

  DailyMealPlan removeMealSlot(String mealSlotId) {
    final meal = meals.where((m) => m.id == mealSlotId).firstOrNull;
    if (meal != null) {
      return updateMealSlot(meal.clearMeal());
    }
    return this;
  }

  // Create default meal slots for a day
  static DailyMealPlan createDefault(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    
    return DailyMealPlan(
      date: date,
      meals: [
        MealSlot(
          id: '${dateStr}_breakfast',
          type: MealType.breakfast,
        ),
        MealSlot(
          id: '${dateStr}_lunch',
          type: MealType.lunch,
        ),
        MealSlot(
          id: '${dateStr}_dinner',
          type: MealType.dinner,
        ),
      ],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyMealPlan &&
        other.date == date &&
        other.meals.length == meals.length &&
        other.meals.every((meal) => meals.contains(meal)) &&
        other.notes == notes &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        meals.hashCode ^
        notes.hashCode ^
        isCompleted.hashCode;
  }

  @override
  String toString() {
    return 'DailyMealPlan(date: $date, mealsCount: ${meals.length}, plannedMeals: $plannedMealsCount)';
  }
}

// Extension to help with null safety
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}