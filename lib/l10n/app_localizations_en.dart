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
  String get perfect => 'Perfect';

  @override
  String get good => 'Good';

  @override
  String get item => 'Item';

  @override
  String get items => 'Items';

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
  String get recipes => 'Recipes';

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

  @override
  String get findingRecipes => 'Finding recipes...';

  @override
  String get failedToLoadCurrentSeasonalIngredients =>
      'Failed to load current seasonal ingredients. Please try again.';

  @override
  String get failedToRefresh => 'Failed to refresh';

  @override
  String get loadingCurrentSeasonalIngredients =>
      'Loading current seasonal ingredients...';

  @override
  String get noIngredientsInPeakSeason =>
      'No ingredients are in peak season right now. Check back later!';

  @override
  String get unknownErrorOccurred => 'Unknown error occurred';

  @override
  String get categories => 'Categories';

  @override
  String get all => 'All';

  @override
  String get beverages => 'Beverages';

  @override
  String get snacks => 'Snacks';

  @override
  String get desserts => 'Desserts';

  @override
  String get allRecipes => 'All Recipes';

  @override
  String get personalized => 'Personalized';

  @override
  String get loadingMoreRecipesEllipsis => 'Loading more recipes...';

  @override
  String get failedToLoadRecipes => 'Failed to load recipes';

  @override
  String recipesSortedByPreferences(int count) {
    return '$count recipes, sorted by your preferences';
  }

  @override
  String recipesFound(int count) {
    return '$count recipes found';
  }

  @override
  String noCategoryRecipesYet(String category) {
    return 'No $category recipes yet';
  }

  @override
  String get noRecipesAvailableYet => 'No recipes available yet';

  @override
  String get checkBackLaterForDeliciousRecipes =>
      'Check back later for delicious recipes';

  @override
  String get errorLoadingRecipes => 'Error loading recipes';

  @override
  String get loadingRecipes => 'Loading recipes...';

  @override
  String recipesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
    );
    return '$_temp0 found';
  }

  @override
  String showingRecipesCount(int displayed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total recipes',
      one: '1 recipe',
    );
    return 'Showing $displayed of $_temp0';
  }

  @override
  String get recipeDoesNotExist =>
      'The recipe you are looking for does not exist.';

  @override
  String get viewLess => 'View Less';

  @override
  String get viewMore => 'View More';

  @override
  String get instructions => 'Instructions';

  @override
  String get servings => 'Servings';

  @override
  String get cups => 'Cups';

  @override
  String get metric => 'Metric';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get addToMealPlan => 'Add to Meal Plan';

  @override
  String addRecipeToMealPlan(String recipeTitle) {
    return 'Add \"$recipeTitle\" to Meal Plan';
  }

  @override
  String get goToMealPlanner => 'Go to Meal Planner';

  @override
  String get chooseSpecificDayAndMeal => 'Choose specific day and meal time';

  @override
  String get addToToday => 'Add to Today';

  @override
  String get quickAddToTodayMeal => 'Quick add to next available meal today';

  @override
  String whichMealToAdd(String recipeTitle) {
    return 'Which meal would you like to add \"$recipeTitle\" to?';
  }

  @override
  String addedToTodayMeal(String mealType) {
    return 'Added to today\'s $mealType!';
  }

  @override
  String get breakfastTime => '8:30 AM';

  @override
  String get lunchTime => '12:30 PM';

  @override
  String get dinnerTime => '7:00 PM';

  @override
  String get pleaseLoginToViewMealPlans =>
      'Please login to view your meal plans';

  @override
  String get failedToLoadMealPlan => 'Failed to load meal plan';

  @override
  String get youDoNotHavePermission =>
      'You do not have permission to access meal plans';

  @override
  String get networkError => 'Network error. Please check your connection';

  @override
  String get serviceUnavailable => 'Service is currently unavailable';

  @override
  String get autoFillWeek => 'Auto-fill Week';

  @override
  String get autoFillWeekDescription =>
      'Automatically fill empty meal slots with suggestions based on your pantry, leftovers, and seasonal recipes?';

  @override
  String get autoFillFeatureComingSoon => 'Auto-fill feature coming soon!';

  @override
  String get viewPreviousWeeks => 'View Previous Weeks';

  @override
  String get duplicateWeek => 'Duplicate Week';

  @override
  String get clearAllMeals => 'Clear All Meals';

  @override
  String get pleaseLoginToAddMeals => 'Please login to add meals';

  @override
  String get mealCategoryRequired => 'Meal category is required';

  @override
  String get pleaseLoginToUpdateMeals => 'Please login to update meals';

  @override
  String failedToUpdateMeal(String error) {
    return 'Failed to update meal: $error';
  }

  @override
  String get pleaseLoginToDeleteMeals => 'Please login to delete meals';

  @override
  String failedToDeleteMeal(String error) {
    return 'Failed to delete meal: $error';
  }

  @override
  String get failedToOpenRecipe => 'Failed to open recipe. Please try again.';

  @override
  String get youDoNotHavePermissionToAddMeals =>
      'You do not have permission to add meals';

  @override
  String get networkErrorCheckConnection =>
      'Network error. Please check your connection and try again';

  @override
  String get serviceUnavailableTryLater =>
      'Service is currently unavailable. Please try again later';

  @override
  String get noMealPlanAvailable => 'No meal plan available';

  @override
  String get addMealsWithRecipes =>
      'Please add meals with recipes to generate a grocery list.';

  @override
  String get noMealsPlannedForGrocery => 'No meals planned';

  @override
  String get addMealsToMealPlan =>
      'Add meals to your meal plan first, then generate a grocery list.';

  @override
  String get noRecipeBasedMeals => 'No recipe-based meals';

  @override
  String get addMealsWithRecipesForGrocery =>
      'Add meals with recipes to generate ingredients for your grocery list.';

  @override
  String get generatingGroceryList => 'Generating grocery list...';

  @override
  String get analyzingMealPlan =>
      'Analyzing your meal plan and calculating ingredients';

  @override
  String get groceryListGenerationFailed => 'Grocery List Generation Failed';

  @override
  String get thisWeek => 'This Week';

  @override
  String mealsPlanned(int count) {
    return '$count meals planned';
  }

  @override
  String get mondayShort => 'M';

  @override
  String get tuesdayShort => 'T';

  @override
  String get wednesdayShort => 'W';

  @override
  String get thursdayShort => 'T';

  @override
  String get fridayShort => 'F';

  @override
  String get saturdayShort => 'S';

  @override
  String get sundayShort => 'S';

  @override
  String get today => 'Today';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get unknown => 'Unknown';

  @override
  String get meals => 'meals';

  @override
  String get noMealsPlannedEmpty => 'No meals planned';

  @override
  String get tapPlusButtonToAddMeal =>
      'Tap the + button in navigation to add your first meal';

  @override
  String get selectTime => 'Select Time';

  @override
  String get selectNewTimeForMeal => 'Select new time for your meal';

  @override
  String chooseTimeForMeal(String mealCategory) {
    return 'Choose time for $mealCategory';
  }

  @override
  String get selectedTime => 'Selected Time';

  @override
  String get quickSelect => 'Quick Select';

  @override
  String get customTime => 'Custom Time';

  @override
  String get next => 'Next';

  @override
  String get confirm => 'Confirm';

  @override
  String get selectRecipe => 'Select Recipe';

  @override
  String get chooseRecipeForMeal => 'Choose a recipe for your meal';

  @override
  String get loadingRecipesEllipsis => 'Loading recipes...';

  @override
  String get searchFailed => 'Search failed. Please try again.';

  @override
  String get failedToLoadRecipesPleaseTryAgain =>
      'Failed to load recipes. Please try again.';

  @override
  String get noRecipesFoundEmpty => 'No recipes found';

  @override
  String get trySearchingWithDifferentKeywords =>
      'Try searching with different keywords';

  @override
  String get noRecipesAvailable => 'No recipes available';

  @override
  String get pleaseCheckBackLater => 'Please check back later';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get confirmMeal => 'Confirm Meal';

  @override
  String get reviewMealDetails => 'Review your meal details';

  @override
  String get scheduledTime => 'Scheduled Time';

  @override
  String get change => 'Change';

  @override
  String get numberOfServings => 'Number of Servings';

  @override
  String get servingsLabel => 'Servings:';

  @override
  String get mealCategory => 'Meal Category';

  @override
  String get backToRecipes => 'Back to Recipes';

  @override
  String get addToMealPlanAction => 'Add to Meal Plan';

  @override
  String addMealCategory(String category) {
    return 'Add $category';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get unknownRecipe => 'Unknown Recipe';

  @override
  String get leftoverMeal => 'Leftover Meal';

  @override
  String get groceryList => 'Grocery List';

  @override
  String weekOf(String dateRange) {
    return 'Week of $dateRange';
  }

  @override
  String get noGroceryItemsGenerated => 'No Grocery Items Generated';

  @override
  String get mealPlanNoIngredientsInfo =>
      'Your meal plan doesn\'t contain meals with\ningredient information that can generate grocery items';

  @override
  String get addRecipeBasedMeals => 'Add recipe-based meals';

  @override
  String get addRecipeBasedMealsDescription =>
      'Use the + button to add meals from your recipe collection';

  @override
  String get ensureRecipesHaveIngredients => 'Ensure recipes have ingredients';

  @override
  String get ensureRecipesHaveIngredientsDescription =>
      'Only recipes with ingredient lists can generate grocery items';

  @override
  String get generateYourList => 'Generate your list';

  @override
  String get generateYourListDescription =>
      'Once you have recipe-based meals, try generating again';

  @override
  String itemsAcrossCategories(int totalItems, int categoriesCount) {
    return '$totalItems items across $categoriesCount categories';
  }

  @override
  String get export => 'Export';

  @override
  String get exporting => 'Exporting...';

  @override
  String get itemName => 'Item Name';

  @override
  String get quantity => 'Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get category => 'Category';

  @override
  String get save => 'Save';

  @override
  String get groceryListExportedSuccessfully =>
      'Grocery list exported successfully!';

  @override
  String failedToExport(String error) {
    return 'Failed to export: $error';
  }

  @override
  String itemRemoved(String itemName) {
    return '$itemName removed';
  }

  @override
  String get vegetables => 'Vegetables';

  @override
  String get fruits => 'Fruits';

  @override
  String get meatFish => 'Meat & Fish';

  @override
  String get dairy => 'Dairy';

  @override
  String get grainsRice => 'Grains & Rice';

  @override
  String get oilsCondiments => 'Oils & Condiments';

  @override
  String get spices => 'Spices';

  @override
  String get other => 'Other';

  @override
  String get recipeImage => 'Recipe Image';

  @override
  String availableIngredientsCount(int available, int total) {
    return '$available/$total ingredients';
  }

  @override
  String missingIngredients(String ingredients) {
    return 'Missing: $ingredients';
  }

  @override
  String editItem(String itemType) {
    return 'Edit $itemType';
  }

  @override
  String addItem(String itemType) {
    return 'Add $itemType';
  }

  @override
  String get itemType => 'Item Type';

  @override
  String get ingredient => 'Ingredient';

  @override
  String get leftover => 'Leftover';

  @override
  String itemNameLabel(String itemType) {
    return '$itemType Name';
  }

  @override
  String enterItemName(String itemType) {
    return 'Enter $itemType name...';
  }

  @override
  String get pleaseEnterItemName => 'Please enter an ingredient name';

  @override
  String updateItem(String itemType) {
    return 'Update $itemType';
  }

  @override
  String addItemAction(String itemType) {
    return 'Add $itemType';
  }

  @override
  String get findingRecipesEllipsis => 'Finding recipes...';

  @override
  String recipesAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
    );
    return '$_temp0 available';
  }

  @override
  String get recipeSuggestions => 'Recipe Suggestions';

  @override
  String get failedToLoadRecipeSuggestions =>
      'Failed to load recipe suggestions';

  @override
  String get noMatchingRecipesFound =>
      'No matching recipes found for this leftover';

  @override
  String get edit => 'Edit';

  @override
  String get findingRecipesForLeftover => 'Finding recipes...';

  @override
  String recipeSuggestionsCount(int count) {
    return 'Recipe suggestions ($count)';
  }

  @override
  String get noRecipesFound => 'No recipes found';

  @override
  String get tapToViewRecipes => 'Tap to view recipes';

  @override
  String get tapToHideRecipes => 'Tap to hide recipes';

  @override
  String get failedToLoadSuggestions => 'Failed to load suggestions';

  @override
  String get noMatchingRecipesFoundForLeftover =>
      'No matching recipes found for this leftover';

  @override
  String get recipesYouCanMake => 'Recipes You Can Make';

  @override
  String recipesCountText(int count) {
    return '$count recipes';
  }

  @override
  String perfectCount(int count) {
    return '$count perfect';
  }

  @override
  String goodCount(int count) {
    return '$count good';
  }

  @override
  String get addMoreIngredients => 'Add More Ingredients';

  @override
  String get addMoreIngredientsDescription =>
      'We\'ll find recipes that match what you have! Add a few more ingredients to see recipe suggestions.';

  @override
  String get tryAddingSuggestion => 'Try adding: Rice, Onions, Garlic';
}
