/// Context information for preserving meal planner state during navigation
class MealPlannerReturnContext {
  final DateTime selectedDate;
  final DateTime weekStart;

  const MealPlannerReturnContext({
    required this.selectedDate,
    required this.weekStart,
  });

  /// Convert to query parameters for URL
  Map<String, String> toQueryParameters() {
    return {
      'selectedDate': selectedDate.toIso8601String(),
      'weekStart': weekStart.toIso8601String(),
    };
  }

  /// Create from query parameters
  static MealPlannerReturnContext? fromQueryParameters(Map<String, String> params) {
    final selectedDate = params['selectedDate'];
    final weekStart = params['weekStart'];
    
    if (selectedDate != null && weekStart != null) {
      try {
        return MealPlannerReturnContext(
          selectedDate: DateTime.parse(selectedDate),
          weekStart: DateTime.parse(weekStart),
        );
      } catch (e) {
        // Return null if parsing fails
        return null;
      }
    }
    
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlannerReturnContext &&
        other.selectedDate == selectedDate &&
        other.weekStart == weekStart;
  }

  @override
  int get hashCode => selectedDate.hashCode ^ weekStart.hashCode;

  @override
  String toString() {
    return 'MealPlannerReturnContext(selectedDate: $selectedDate, weekStart: $weekStart)';
  }
}