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
  String get inSeason => 'In Season';

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
  String get seasonalSpotlight => 'Seasonal Spotlight';

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

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get guestUser => 'Guest User';

  @override
  String get notificationsComingSoon => 'Notifications coming soon!';

  @override
  String get home => 'Home';

  @override
  String get explore => 'Explore';

  @override
  String get pantry => 'Pantry';

  @override
  String get mealPlanner => 'Meal Planner';

  @override
  String get profile => 'Profile';

  @override
  String get searchRecipesIngredients => 'Search recipes, ingredients...';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String addedToFavorites(String recipeName) {
    return '$recipeName added to favorites!';
  }

  @override
  String removedFromFavorites(String recipeName) {
    return '$recipeName removed from favorites';
  }

  @override
  String get undo => 'Undo';

  @override
  String addedToMealPlan(String recipeName) {
    return '$recipeName added to meal plan';
  }

  @override
  String get myPantry => 'My Pantry';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get leftovers => 'Leftovers';

  @override
  String ingredientsCount(int count) {
    return '$count ingredients';
  }

  @override
  String leftoversCount(int count) {
    return '$count leftovers';
  }

  @override
  String get deleteIngredient => 'Delete Ingredient';

  @override
  String confirmDeleteIngredient(String itemName) {
    return 'Are you sure you want to remove \"$itemName\" from your pantry?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get loadingYourPantry => 'Loading your pantry...';

  @override
  String get failedToLoadPantry => 'Failed to Load Pantry';

  @override
  String get noIngredientsYet => 'No Ingredients Yet';

  @override
  String get addFreshIngredientsDiscover =>
      'Add fresh ingredients to discover recipes you can make!';

  @override
  String get addIngredient => 'Add Ingredient';

  @override
  String get quickAddPopularItems => 'Quick Add Popular Items:';

  @override
  String get noLeftoversYet => 'No Leftovers Yet';

  @override
  String get addLeftoverFoodItems =>
      'Add leftover food items to find creative ways to use them up!';

  @override
  String get addLeftover => 'Add Leftover';

  @override
  String get commonLeftoversToTrack => 'Common leftovers to track:';

  @override
  String get planYourMealsFlexibility => 'Plan your meals with flexibility';

  @override
  String get addMeal => 'Add Meal';

  @override
  String get customMeal => 'Custom Meal';

  @override
  String get addCustomMeal => 'Add Custom Meal';

  @override
  String get mealName => 'Meal Name';

  @override
  String get enterMealName => 'Enter meal name';

  @override
  String get add => 'Add';

  @override
  String get editMeal => 'Edit Meal';

  @override
  String get lockMeal => 'Lock Meal';

  @override
  String get unlockMeal => 'Unlock Meal';

  @override
  String get removeMeal => 'Remove Meal';

  @override
  String confirmRemoveMeal(String mealName) {
    return 'Are you sure you want to remove \"$mealName\"?';
  }

  @override
  String get remove => 'Remove';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get brunch => 'Brunch';

  @override
  String get lateNight => 'Late Night';

  @override
  String get addingMeal => 'Adding meal...';

  @override
  String mealAddedSuccessfully(String mealName) {
    return '$mealName added successfully!';
  }

  @override
  String get mealUpdatedSuccessfully => 'Meal updated successfully!';

  @override
  String get mealDeleted => 'Meal deleted';

  @override
  String openingMeal(String mealName) {
    return 'Opening $mealName...';
  }

  @override
  String get noRecipeAvailable => 'No recipe available for this meal';

  @override
  String get close => 'Close';

  @override
  String get viewRecipes => 'View Recipes';

  @override
  String get failedToLoadMoreRecipes => 'Failed to load more recipes';

  @override
  String get youHaveSeenAllRecipes => 'You have seen all recipes';

  @override
  String get checkBackLaterForNewRecipes =>
      'Check back later for new recipes featuring this ingredient.';

  @override
  String get loadingMoreRecipes => 'Loading more recipes...';

  @override
  String get loadMoreRecipes => 'Load More Recipes';

  @override
  String get noRecipesFoundForThisIngredient =>
      'No recipes found for this ingredient';

  @override
  String get checkBackLater =>
      'Check back later as we add more seasonal recipes to our collection.';

  @override
  String get refresh => 'Refresh';

  @override
  String get recipeNotFound => 'Recipe Not Found';

  @override
  String get failedToLoad => 'Failed to load';

  @override
  String perfectForYourItems(String items) {
    return 'Perfect for your $items';
  }

  @override
  String get usesIngredientsFromPantry => 'Uses ingredients from your pantry';

  @override
  String get basedOnYourPreferences => 'Based on your preferences';

  @override
  String get similarToPreferences => 'Similar to your preferences';

  @override
  String get perfectForThisSeason => 'Perfect for this season';

  @override
  String get quickAndEasy => 'Quick and easy';

  @override
  String get similarToEnjoyedRecipes => 'Similar to recipes you\'ve enjoyed';

  @override
  String get perfectMatch => 'Perfect match!';

  @override
  String get greatMatch => 'Great match!';

  @override
  String usesPantryIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ingredients',
      one: 'ingredient',
    );
    return 'Uses $count $_temp0 from your pantry';
  }
}
