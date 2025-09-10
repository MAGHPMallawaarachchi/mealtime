// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MealTime';

  @override
  String get todaysMealPlan => 'Today\'s Meal Plan';

  @override
  String get seeAll => 'See All';

  @override
  String get noMealsPlanned => 'No meals planned yet';

  @override
  String get startPlanningMeals =>
      'Tap \"See All\" to start planning your meals';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get appLanguage => 'App Language';

  @override
  String get english => 'English';

  @override
  String get sinhala => 'Sinhala';

  @override
  String get household => 'Household';

  @override
  String get householdSize => 'Household Size';

  @override
  String get dietaryPreferences => 'Dietary Preferences';

  @override
  String get dietaryPreference => 'Dietary Preference';

  @override
  String get nonVegetarian => 'Non-Vegetarian';

  @override
  String get vegetarian => 'Vegetarian';

  @override
  String get vegan => 'Vegan';

  @override
  String get pescatarian => 'Pescatarian';

  @override
  String get recipeRecommendations => 'Recipe Recommendations';

  @override
  String get prioritizePantryItems => 'Prioritize Pantry Items';

  @override
  String get prioritizePantryDescription =>
      'When enabled, recipes using ingredients from your pantry will be prioritized in recommendations';

  @override
  String get notifications => 'Notifications';

  @override
  String get mealPlanReminders => 'Meal Plan Reminders';

  @override
  String get mealPlanRemindersDescription =>
      'Get reminded about your planned meals';

  @override
  String get shoppingListUpdates => 'Shopping List Updates';

  @override
  String get shoppingListUpdatesDescription =>
      'Get notified when shopping list changes';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get settingsSavedSuccessfully => 'Settings saved successfully';

  @override
  String failedToSaveSettings(String error) {
    return 'Failed to save settings: $error';
  }

  @override
  String errorLoadingPreferences(String error) {
    return 'Error loading preferences: $error';
  }

  @override
  String get perfectForYourPantry => 'Perfect for Your Pantry';

  @override
  String get useUpPantryItems => 'Use up your pantry items';

  @override
  String get justForYou => 'Just for You';

  @override
  String get basedOnPreferences => 'Based on your preferences';

  @override
  String get quickWeeknightMeals => 'Quick Weeknight Meals';

  @override
  String get readyInMinutes => 'Ready in 30 minutes or less';

  @override
  String get seasonalFavorites => 'Seasonal Favorites';

  @override
  String get perfectForTimeOfYear => 'Perfect for this time of year';

  @override
  String get noPantryMatchesFound => 'No pantry matches found';

  @override
  String get addItemsToGetSuggestions =>
      'Add items to your pantry to get recipe suggestions';

  @override
  String get buildingYourPreferences => 'Building your preferences';

  @override
  String get interactToGetSuggestions =>
      'Interact with recipes to get personalized suggestions';

  @override
  String get noQuickMealsAvailable => 'No quick meals available';

  @override
  String get quickMealSuggestions => 'Quick meal suggestions will appear here';

  @override
  String get noSeasonalRecipesFound => 'No seasonal recipes found';

  @override
  String get seasonalRecommendations =>
      'Seasonal recommendations based on current time of year';

  @override
  String get personalizedRecommendations => 'Personalized recommendations';

  @override
  String get addItemsAndSetPreferences =>
      'Add items to your pantry and set your preferences to get personalized recipe recommendations.';

  @override
  String get unableToLoadRecommendations => 'Unable to load recommendations';

  @override
  String get checkConnectionAndRetry =>
      'Please check your connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get noImage => 'No Image';
}
