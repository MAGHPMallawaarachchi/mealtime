import 'package:flutter/material.dart';

// Flexible meal categories
class MealCategory {
  static const String breakfast = 'Breakfast';
  static const String lunch = 'Lunch';
  static const String dinner = 'Dinner';
  static const String snack = 'Snack';
  static const String brunch = 'Brunch';
  static const String lateNight = 'Late Night';
  static const String custom = 'Custom';
  
  // Common predefined categories for quick selection
  static const List<String> predefined = [
    breakfast,
    lunch,
    dinner,
    snack,
    brunch,
    lateNight,
  ];
  
  // Default times for common categories (can be overridden)
  static Map<String, TimeOfDay> get defaultTimes => {
    breakfast: const TimeOfDay(hour: 8, minute: 30),
    lunch: const TimeOfDay(hour: 12, minute: 30),
    dinner: const TimeOfDay(hour: 19, minute: 0),
    snack: const TimeOfDay(hour: 16, minute: 0),
    brunch: const TimeOfDay(hour: 10, minute: 30),
    lateNight: const TimeOfDay(hour: 22, minute: 0),
  };
}

class MealSlot {
  final String id;
  final String category;
  final DateTime scheduledTime;
  final String? recipeId;
  final String? leftoverId;
  final String? customMealName;
  final String? description;
  final int servingSize;
  final bool isLocked;

  const MealSlot({
    required this.id,
    required this.category,
    required this.scheduledTime,
    this.recipeId,
    this.leftoverId,
    this.customMealName,
    this.description,
    this.servingSize = 1,
    this.isLocked = false,
  });

  bool get isEmpty => recipeId == null && leftoverId == null && customMealName == null;

  // Get display time as formatted string
  String get displayTime {
    final hour = scheduledTime.hour;
    final minute = scheduledTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  // Get TimeOfDay from scheduledTime
  TimeOfDay get timeOfDay => TimeOfDay.fromDateTime(scheduledTime);

  // Get meal name for display
  String get displayName {
    if (customMealName != null && customMealName!.isNotEmpty) {
      return customMealName!;
    }
    return category;
  }

  MealSlot copyWith({
    String? id,
    String? category,
    DateTime? scheduledTime,
    String? recipeId,
    String? leftoverId,
    String? customMealName,
    String? description,
    int? servingSize,
    bool? isLocked,
  }) {
    return MealSlot(
      id: id ?? this.id,
      category: category ?? this.category,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      recipeId: recipeId ?? this.recipeId,
      leftoverId: leftoverId ?? this.leftoverId,
      customMealName: customMealName ?? this.customMealName,
      description: description ?? this.description,
      servingSize: servingSize ?? this.servingSize,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  MealSlot clearMeal() {
    return copyWith(
      recipeId: null,
      leftoverId: null,
      customMealName: null,
      description: null,
      isLocked: false,
      servingSize: 1,
    );
  }

  // Create a meal slot with default time for category
  static MealSlot createDefault({
    required String id,
    required String category,
    required DateTime date,
  }) {
    final defaultTime = MealCategory.defaultTimes[category] ?? const TimeOfDay(hour: 12, minute: 0);
    final scheduledTime = DateTime(
      date.year,
      date.month,
      date.day,
      defaultTime.hour,
      defaultTime.minute,
    );
    
    return MealSlot(
      id: id,
      category: category,
      scheduledTime: scheduledTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealSlot &&
        other.id == id &&
        other.category == category &&
        other.scheduledTime == scheduledTime &&
        other.recipeId == recipeId &&
        other.leftoverId == leftoverId &&
        other.customMealName == customMealName &&
        other.description == description &&
        other.servingSize == servingSize &&
        other.isLocked == isLocked;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        category.hashCode ^
        scheduledTime.hashCode ^
        recipeId.hashCode ^
        leftoverId.hashCode ^
        customMealName.hashCode ^
        description.hashCode ^
        servingSize.hashCode ^
        isLocked.hashCode;
  }

  @override
  String toString() {
    return 'MealSlot(id: $id, category: $category, scheduledTime: $scheduledTime, recipeId: $recipeId, leftoverId: $leftoverId, customMealName: $customMealName, servingSize: $servingSize, isLocked: $isLocked)';
  }
}