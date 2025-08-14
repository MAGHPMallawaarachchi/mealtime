enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get defaultTime {
    switch (this) {
      case MealType.breakfast:
        return '8:30 AM';
      case MealType.lunch:
        return '12:30 PM';
      case MealType.dinner:
        return '7:00 PM';
      case MealType.snack:
        return '4:00 PM';
    }
  }
}

class MealSlot {
  final String id;
  final MealType type;
  final String? recipeId;
  final String? leftoverId;
  final String? customMealName;
  final String? customTime;
  final bool isLocked;
  final DateTime? scheduledTime;

  const MealSlot({
    required this.id,
    required this.type,
    this.recipeId,
    this.leftoverId,
    this.customMealName,
    this.customTime,
    this.isLocked = false,
    this.scheduledTime,
  });

  bool get isEmpty => recipeId == null && leftoverId == null && customMealName == null;

  String get displayTime => customTime ?? type.defaultTime;

  MealSlot copyWith({
    String? id,
    MealType? type,
    String? recipeId,
    String? leftoverId,
    String? customMealName,
    String? customTime,
    bool? isLocked,
    DateTime? scheduledTime,
  }) {
    return MealSlot(
      id: id ?? this.id,
      type: type ?? this.type,
      recipeId: recipeId ?? this.recipeId,
      leftoverId: leftoverId ?? this.leftoverId,
      customMealName: customMealName ?? this.customMealName,
      customTime: customTime ?? this.customTime,
      isLocked: isLocked ?? this.isLocked,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }

  MealSlot clearMeal() {
    return copyWith(
      recipeId: null,
      leftoverId: null,
      customMealName: null,
      isLocked: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealSlot &&
        other.id == id &&
        other.type == type &&
        other.recipeId == recipeId &&
        other.leftoverId == leftoverId &&
        other.customMealName == customMealName &&
        other.customTime == customTime &&
        other.isLocked == isLocked &&
        other.scheduledTime == scheduledTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        recipeId.hashCode ^
        leftoverId.hashCode ^
        customMealName.hashCode ^
        customTime.hashCode ^
        isLocked.hashCode ^
        scheduledTime.hashCode;
  }

  @override
  String toString() {
    return 'MealSlot(id: $id, type: $type, recipeId: $recipeId, leftoverId: $leftoverId, customMealName: $customMealName, isLocked: $isLocked)';
  }
}