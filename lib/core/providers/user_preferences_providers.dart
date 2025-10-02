import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_preferences_service.dart';
import '../models/user_model.dart';

final userPreferencesServiceProvider = Provider<UserPreferencesService>((ref) {
  return UserPreferencesService();
});


final updateDietaryPreferenceProvider = Provider<Future<void> Function(DietaryType?)>((ref) {
  final service = ref.watch(userPreferencesServiceProvider);
  return (DietaryType? dietaryType) async {
    await service.updateDietaryPreference(dietaryType);
  };
});

final updatePantryPrioritizationProvider = Provider<Future<void> Function(bool)>((ref) {
  final service = ref.watch(userPreferencesServiceProvider);
  return (bool prioritizePantryItems) async {
    await service.updatePantryPrioritization(prioritizePantryItems);
  };
});

final updateHouseholdSizeProvider = Provider<Future<void> Function(int)>((ref) {
  final service = ref.watch(userPreferencesServiceProvider);
  return (int householdSize) async {
    await service.updateHouseholdSize(householdSize);
  };
});

final updateUserPreferencesProvider = Provider<Future<void> Function({DietaryType? dietaryType, bool? prioritizePantryItems, int? householdSize})>((ref) {
  final service = ref.watch(userPreferencesServiceProvider);
  return ({DietaryType? dietaryType, bool? prioritizePantryItems, int? householdSize}) async {
    await service.updateUserPreferences(
      dietaryType: dietaryType,
      prioritizePantryItems: prioritizePantryItems,
      householdSize: householdSize,
    );
  };
});