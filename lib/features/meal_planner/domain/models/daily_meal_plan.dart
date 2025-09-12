import 'package:flutter/material.dart';
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

  // Get meals sorted by scheduled time
  List<MealSlot> get mealsByTime => [...meals]..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  
  // Get meals by category
  List<MealSlot> getMealsByCategory(String category) => meals.where((m) => m.category == category).toList();
  
  // Get first meal of specific category
  MealSlot? getFirstMealByCategory(String category) => meals.where((m) => m.category == category).firstOrNull;
  
  // Get meals in time range
  List<MealSlot> getMealsInTimeRange(TimeOfDay start, TimeOfDay end) {
    return meals.where((meal) {
      final mealTime = TimeOfDay.fromDateTime(meal.scheduledTime);
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      final mealMinutes = mealTime.hour * 60 + mealTime.minute;
      
      if (endMinutes > startMinutes) {
        return mealMinutes >= startMinutes && mealMinutes <= endMinutes;
      } else {
        // Handle overnight range (e.g., 10 PM to 6 AM)
        return mealMinutes >= startMinutes || mealMinutes <= endMinutes;
      }
    }).toList();
  }

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
  
  // Add new meal slot
  DailyMealPlan addMealSlot(MealSlot newSlot) {
    final updatedMeals = [...meals, newSlot];
    return copyWith(meals: updatedMeals);
  }

  DailyMealPlan removeMealSlot(String mealSlotId) {
    final updatedMeals = meals.where((m) => m.id != mealSlotId).toList();
    return copyWith(meals: updatedMeals);
  }

  // Create default meal slots for a day (now empty to allow flexible meal planning)
  static DailyMealPlan createDefault(DateTime date) {
    return DailyMealPlan(
      date: date,
      meals: [], // Start with no predefined meals - users can add their own
    );
  }
  
  // Create empty day plan
  static DailyMealPlan createEmpty(DateTime date) {
    return DailyMealPlan(
      date: date,
      meals: [],
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

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    return DailyMealPlan(
      date: _parseDateTime(json['date'], fallback: DateTime.now()),
      meals: (json['meals'] as List<dynamic>? ?? [])
          .map((mealJson) => MealSlot.fromJson(mealJson as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Helper method to parse DateTime from either String or Timestamp
  static DateTime _parseDateTime(dynamic value, {DateTime? fallback}) {
    if (value == null) {
      if (fallback != null) {
        return fallback;
      }
      throw ArgumentError('DateTime value cannot be null and no fallback provided');
    }
    
    try {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value.runtimeType.toString() == 'Timestamp') {
        // Handle Firebase Timestamp
        return (value as dynamic).toDate();
      } else {
        throw ArgumentError('Expected String or Timestamp, got ${value.runtimeType}');
      }
    } catch (e) {
      if (fallback != null) {
        return fallback;
      }
      rethrow;
    }
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