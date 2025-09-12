import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'MealTime'**
  String get appTitle;

  /// Title for today's meal plan section
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meal Plan'**
  String get todaysMealPlan;

  /// Button text to view all items
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Message shown when no meals are planned
  ///
  /// In en, this message translates to:
  /// **'No meals planned yet'**
  String get noMealsPlanned;

  /// Instruction to start planning meals
  ///
  /// In en, this message translates to:
  /// **'Tap \"See All\" to start planning your meals'**
  String get startPlanningMeals;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// App language setting title
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Sinhala language option
  ///
  /// In en, this message translates to:
  /// **'Sinhala'**
  String get sinhala;

  /// Household section title
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get household;

  /// Household size setting
  ///
  /// In en, this message translates to:
  /// **'Household Size'**
  String get householdSize;

  /// Dietary preferences section title
  ///
  /// In en, this message translates to:
  /// **'Dietary Preferences'**
  String get dietaryPreferences;

  /// Single dietary preference setting
  ///
  /// In en, this message translates to:
  /// **'Dietary Preference'**
  String get dietaryPreference;

  /// Non-vegetarian diet option
  ///
  /// In en, this message translates to:
  /// **'Non-Vegetarian'**
  String get nonVegetarian;

  /// Vegetarian diet option
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// Vegan diet option
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// Pescatarian diet option
  ///
  /// In en, this message translates to:
  /// **'Pescatarian'**
  String get pescatarian;

  /// Recipe recommendations section title
  ///
  /// In en, this message translates to:
  /// **'Recipe Recommendations'**
  String get recipeRecommendations;

  /// Setting to prioritize pantry items
  ///
  /// In en, this message translates to:
  /// **'Prioritize Pantry Items'**
  String get prioritizePantryItems;

  /// Description for prioritize pantry items setting
  ///
  /// In en, this message translates to:
  /// **'When enabled, recipes using ingredients from your pantry will be prioritized in recommendations'**
  String get prioritizePantryDescription;

  /// Notifications section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Meal plan reminders setting
  ///
  /// In en, this message translates to:
  /// **'Meal Plan Reminders'**
  String get mealPlanReminders;

  /// Description for meal plan reminders
  ///
  /// In en, this message translates to:
  /// **'Get reminded about your planned meals'**
  String get mealPlanRemindersDescription;

  /// Shopping list updates setting
  ///
  /// In en, this message translates to:
  /// **'Shopping List Updates'**
  String get shoppingListUpdates;

  /// Description for shopping list updates
  ///
  /// In en, this message translates to:
  /// **'Get notified when shopping list changes'**
  String get shoppingListUpdatesDescription;

  /// Button text to save settings
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// Success message when settings are saved
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSavedSuccessfully;

  /// In-season tag
  ///
  /// In en, this message translates to:
  /// **'In Season'**
  String get inSeason;

  /// Perfect tag
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get perfect;

  /// Good tag
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// Item label
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// Items label
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// Error message when settings fail to save
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings: {error}'**
  String failedToSaveSettings(String error);

  /// Error message when preferences fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading preferences: {error}'**
  String errorLoadingPreferences(String error);

  /// Recommendation section title for pantry-based recipes
  ///
  /// In en, this message translates to:
  /// **'Perfect for Your Pantry'**
  String get perfectForYourPantry;

  /// Subtitle for pantry-based recommendations
  ///
  /// In en, this message translates to:
  /// **'Use up your pantry items'**
  String get useUpPantryItems;

  /// Personalized recommendations title
  ///
  /// In en, this message translates to:
  /// **'Just for You'**
  String get justForYou;

  /// Subtitle for personalized recommendations
  ///
  /// In en, this message translates to:
  /// **'Based on your preferences'**
  String get basedOnPreferences;

  /// Quick meals recommendation title
  ///
  /// In en, this message translates to:
  /// **'Quick Weeknight Meals'**
  String get quickWeeknightMeals;

  /// Subtitle for quick meals
  ///
  /// In en, this message translates to:
  /// **'Ready in 30 minutes or less'**
  String get readyInMinutes;

  /// Seasonal recommendations title
  ///
  /// In en, this message translates to:
  /// **'Seasonal Favorites'**
  String get seasonalFavorites;

  /// Seasonal spotlight card title
  ///
  /// In en, this message translates to:
  /// **'Seasonal Spotlight'**
  String get seasonalSpotlight;

  /// Subtitle for seasonal recommendations
  ///
  /// In en, this message translates to:
  /// **'Perfect for this time of year'**
  String get perfectForTimeOfYear;

  /// Empty state for pantry recommendations
  ///
  /// In en, this message translates to:
  /// **'No pantry matches found'**
  String get noPantryMatchesFound;

  /// Empty state description for pantry recommendations
  ///
  /// In en, this message translates to:
  /// **'Add items to your pantry to get recipe suggestions'**
  String get addItemsToGetSuggestions;

  /// Empty state for personalized recommendations
  ///
  /// In en, this message translates to:
  /// **'Building your preferences'**
  String get buildingYourPreferences;

  /// Empty state description for personalized recommendations
  ///
  /// In en, this message translates to:
  /// **'Interact with recipes to get personalized suggestions'**
  String get interactToGetSuggestions;

  /// Empty state for quick meals
  ///
  /// In en, this message translates to:
  /// **'No quick meals available'**
  String get noQuickMealsAvailable;

  /// Empty state description for quick meals
  ///
  /// In en, this message translates to:
  /// **'Quick meal suggestions will appear here'**
  String get quickMealSuggestions;

  /// Empty state for seasonal recommendations
  ///
  /// In en, this message translates to:
  /// **'No seasonal recipes found'**
  String get noSeasonalRecipesFound;

  /// Empty state description for seasonal recommendations
  ///
  /// In en, this message translates to:
  /// **'Seasonal recommendations based on current time of year'**
  String get seasonalRecommendations;

  /// Title for personalized recommendations section
  ///
  /// In en, this message translates to:
  /// **'Personalized recommendations'**
  String get personalizedRecommendations;

  /// Description for personalized recommendations setup
  ///
  /// In en, this message translates to:
  /// **'Add items to your pantry and set your preferences to get personalized recipe recommendations.'**
  String get addItemsAndSetPreferences;

  /// Error message for failed recommendations
  ///
  /// In en, this message translates to:
  /// **'Unable to load recommendations'**
  String get unableToLoadRecommendations;

  /// Error description for connection issues
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get checkConnectionAndRetry;

  /// Button text to retry an action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Placeholder text when no image is available
  ///
  /// In en, this message translates to:
  /// **'No Image'**
  String get noImage;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// Default text for guest users
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// Notification placeholder message
  ///
  /// In en, this message translates to:
  /// **'Notifications coming soon!'**
  String get notificationsComingSoon;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Explore tab label
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// Pantry tab label
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get pantry;

  /// Meal Planner tab label
  ///
  /// In en, this message translates to:
  /// **'Meal Planner'**
  String get mealPlanner;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Search bar placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search recipes, ingredients...'**
  String get searchRecipesIngredients;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Button text to retry an action
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Recipes section title
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// Message when recipe is added to favorites
  ///
  /// In en, this message translates to:
  /// **'{recipeName} added to favorites!'**
  String addedToFavorites(String recipeName);

  /// Message when recipe is removed from favorites
  ///
  /// In en, this message translates to:
  /// **'{recipeName} removed from favorites'**
  String removedFromFavorites(String recipeName);

  /// Undo action button text
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Message when recipe is added to meal plan
  ///
  /// In en, this message translates to:
  /// **'{recipeName} added to meal plan'**
  String addedToMealPlan(String recipeName);

  /// Pantry screen title
  ///
  /// In en, this message translates to:
  /// **'My Pantry'**
  String get myPantry;

  /// Ingredients label
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// Leftovers label
  ///
  /// In en, this message translates to:
  /// **'Leftovers'**
  String get leftovers;

  /// Count of ingredients
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients'**
  String ingredientsCount(int count);

  /// Count of leftovers
  ///
  /// In en, this message translates to:
  /// **'{count} leftovers'**
  String leftoversCount(int count);

  /// Delete ingredient dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Ingredient'**
  String get deleteIngredient;

  /// Delete ingredient confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{itemName}\" from your pantry?'**
  String confirmDeleteIngredient(String itemName);

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Loading message for pantry
  ///
  /// In en, this message translates to:
  /// **'Loading your pantry...'**
  String get loadingYourPantry;

  /// Error title when pantry fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Pantry'**
  String get failedToLoadPantry;

  /// Empty state title for ingredients
  ///
  /// In en, this message translates to:
  /// **'No Ingredients Yet'**
  String get noIngredientsYet;

  /// Empty state description for ingredients
  ///
  /// In en, this message translates to:
  /// **'Add fresh ingredients to discover recipes you can make!'**
  String get addFreshIngredientsDiscover;

  /// Add ingredient button text
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// Quick add section title
  ///
  /// In en, this message translates to:
  /// **'Quick Add Popular Items:'**
  String get quickAddPopularItems;

  /// Empty state title for leftovers
  ///
  /// In en, this message translates to:
  /// **'No Leftovers Yet'**
  String get noLeftoversYet;

  /// Empty state description for leftovers
  ///
  /// In en, this message translates to:
  /// **'Add leftover food items to find creative ways to use them up!'**
  String get addLeftoverFoodItems;

  /// Add leftover button text
  ///
  /// In en, this message translates to:
  /// **'Add Leftover'**
  String get addLeftover;

  /// Common leftovers section title
  ///
  /// In en, this message translates to:
  /// **'Common leftovers to track:'**
  String get commonLeftoversToTrack;

  /// Meal planner subtitle
  ///
  /// In en, this message translates to:
  /// **'Plan your meals with flexibility'**
  String get planYourMealsFlexibility;

  /// Add meal button text
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// Custom meal option text
  ///
  /// In en, this message translates to:
  /// **'Custom Meal'**
  String get customMeal;

  /// Add custom meal dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Custom Meal'**
  String get addCustomMeal;

  /// Meal name input label
  ///
  /// In en, this message translates to:
  /// **'Meal Name'**
  String get mealName;

  /// Meal name input hint
  ///
  /// In en, this message translates to:
  /// **'Enter meal name'**
  String get enterMealName;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Edit meal option text
  ///
  /// In en, this message translates to:
  /// **'Edit Meal'**
  String get editMeal;

  /// Lock meal option text
  ///
  /// In en, this message translates to:
  /// **'Lock Meal'**
  String get lockMeal;

  /// Unlock meal option text
  ///
  /// In en, this message translates to:
  /// **'Unlock Meal'**
  String get unlockMeal;

  /// Remove meal option text
  ///
  /// In en, this message translates to:
  /// **'Remove Meal'**
  String get removeMeal;

  /// Remove meal confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{mealName}\"?'**
  String confirmRemoveMeal(String mealName);

  /// Remove button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Breakfast meal category
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// Lunch meal category
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// Dinner meal category
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// Snack meal category
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// Brunch meal category
  ///
  /// In en, this message translates to:
  /// **'Brunch'**
  String get brunch;

  /// Late night meal category
  ///
  /// In en, this message translates to:
  /// **'Late Night'**
  String get lateNight;

  /// Loading message when adding meal
  ///
  /// In en, this message translates to:
  /// **'Adding meal...'**
  String get addingMeal;

  /// Success message when meal is added
  ///
  /// In en, this message translates to:
  /// **'{mealName} added successfully!'**
  String mealAddedSuccessfully(String mealName);

  /// Success message when meal is updated
  ///
  /// In en, this message translates to:
  /// **'Meal updated successfully!'**
  String get mealUpdatedSuccessfully;

  /// Message when meal is deleted
  ///
  /// In en, this message translates to:
  /// **'Meal deleted'**
  String get mealDeleted;

  /// Message when opening meal details
  ///
  /// In en, this message translates to:
  /// **'Opening {mealName}...'**
  String openingMeal(String mealName);

  /// Message when meal has no recipe
  ///
  /// In en, this message translates to:
  /// **'No recipe available for this meal'**
  String get noRecipeAvailable;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Button text to view recipes
  ///
  /// In en, this message translates to:
  /// **'View Recipes'**
  String get viewRecipes;

  /// Error message when failed to load more recipes
  ///
  /// In en, this message translates to:
  /// **'Failed to load more recipes'**
  String get failedToLoadMoreRecipes;

  /// Message when all recipes have been viewed
  ///
  /// In en, this message translates to:
  /// **'You have seen all recipes'**
  String get youHaveSeenAllRecipes;

  /// Instruction to check back later for new recipes
  ///
  /// In en, this message translates to:
  /// **'Check back later for new recipes featuring this ingredient.'**
  String get checkBackLaterForNewRecipes;

  /// Loading message when more recipes are being fetched
  ///
  /// In en, this message translates to:
  /// **'Loading more recipes...'**
  String get loadingMoreRecipes;

  /// Button text to load more recipes
  ///
  /// In en, this message translates to:
  /// **'Load More Recipes'**
  String get loadMoreRecipes;

  /// Message when no recipes are found for a specific ingredient
  ///
  /// In en, this message translates to:
  /// **'No recipes found for this ingredient'**
  String get noRecipesFoundForThisIngredient;

  /// Instruction to check back later for seasonal recipes
  ///
  /// In en, this message translates to:
  /// **'Check back later as we add more seasonal recipes to our collection.'**
  String get checkBackLater;

  /// Button text to refresh content
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Placeholder text when a recipe cannot be found
  ///
  /// In en, this message translates to:
  /// **'Recipe Not Found'**
  String get recipeNotFound;

  /// Generic error message when something fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failedToLoad;

  /// Recommendation reason when recipe matches pantry items
  ///
  /// In en, this message translates to:
  /// **'Perfect for your {items}'**
  String perfectForYourItems(String items);

  /// Recommendation reason for pantry-based recipes
  ///
  /// In en, this message translates to:
  /// **'Uses ingredients from your pantry'**
  String get usesIngredientsFromPantry;

  /// Recommendation reason for content-based recommendations
  ///
  /// In en, this message translates to:
  /// **'Based on your preferences'**
  String get basedOnYourPreferences;

  /// Recommendation reason for similar content
  ///
  /// In en, this message translates to:
  /// **'Similar to your preferences'**
  String get similarToPreferences;

  /// Recommendation reason for seasonal recipes
  ///
  /// In en, this message translates to:
  /// **'Perfect for this season'**
  String get perfectForThisSeason;

  /// Recommendation reason for quick meals
  ///
  /// In en, this message translates to:
  /// **'Quick and easy'**
  String get quickAndEasy;

  /// Recommendation reason for similar recipes
  ///
  /// In en, this message translates to:
  /// **'Similar to recipes you\'ve enjoyed'**
  String get similarToEnjoyedRecipes;

  /// Recommendation reason for perfect matches
  ///
  /// In en, this message translates to:
  /// **'Perfect match!'**
  String get perfectMatch;

  /// Recommendation reason for great matches
  ///
  /// In en, this message translates to:
  /// **'Great match!'**
  String get greatMatch;

  /// Recommendation reason showing number of matched pantry ingredients
  ///
  /// In en, this message translates to:
  /// **'Uses {count} {count, plural, =1{ingredient} other{ingredients}} from your pantry'**
  String usesPantryIngredients(int count);

  /// Loading message when searching for recipes
  ///
  /// In en, this message translates to:
  /// **'Finding recipes...'**
  String get findingRecipes;

  /// Error message when seasonal ingredients fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load current seasonal ingredients. Please try again.'**
  String get failedToLoadCurrentSeasonalIngredients;

  /// Error message when refresh action fails
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh'**
  String get failedToRefresh;

  /// Loading message when fetching seasonal ingredients
  ///
  /// In en, this message translates to:
  /// **'Loading current seasonal ingredients...'**
  String get loadingCurrentSeasonalIngredients;

  /// Message when no seasonal ingredients are available
  ///
  /// In en, this message translates to:
  /// **'No ingredients are in peak season right now. Check back later!'**
  String get noIngredientsInPeakSeason;

  /// Generic fallback error message when no specific error is provided
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownErrorOccurred;

  /// Categories section title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// All categories filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Beverages category
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get beverages;

  /// Snacks category
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacks;

  /// Desserts category
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get desserts;

  /// All recipes section title
  ///
  /// In en, this message translates to:
  /// **'All Recipes'**
  String get allRecipes;

  /// Personalized recommendations badge
  ///
  /// In en, this message translates to:
  /// **'Personalized'**
  String get personalized;

  /// Loading message when fetching more recipes
  ///
  /// In en, this message translates to:
  /// **'Loading more recipes...'**
  String get loadingMoreRecipesEllipsis;

  /// Error message when recipes fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipes'**
  String get failedToLoadRecipes;

  /// Status text for personalized recipes
  ///
  /// In en, this message translates to:
  /// **'{count} recipes, sorted by your preferences'**
  String recipesSortedByPreferences(int count);

  /// Status text for found recipes
  ///
  /// In en, this message translates to:
  /// **'{count} recipes found'**
  String recipesFound(int count);

  /// Empty state message for category recipes
  ///
  /// In en, this message translates to:
  /// **'No {category} recipes yet'**
  String noCategoryRecipesYet(String category);

  /// Empty state message when no recipes available
  ///
  /// In en, this message translates to:
  /// **'No recipes available yet'**
  String get noRecipesAvailableYet;

  /// Empty state instruction for general recipes
  ///
  /// In en, this message translates to:
  /// **'Check back later for delicious recipes'**
  String get checkBackLaterForDeliciousRecipes;

  /// Error message for recipe loading failure
  ///
  /// In en, this message translates to:
  /// **'Error loading recipes'**
  String get errorLoadingRecipes;

  /// Loading message for initial recipe load
  ///
  /// In en, this message translates to:
  /// **'Loading recipes...'**
  String get loadingRecipes;

  /// Count of total recipes found
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recipe} other{{count} recipes}} found'**
  String recipesFoundCount(int count);

  /// Status showing displayed vs total recipes
  ///
  /// In en, this message translates to:
  /// **'Showing {displayed} of {total, plural, =1{1 recipe} other{{total} recipes}}'**
  String showingRecipesCount(int displayed, int total);

  /// Message when recipe is not found
  ///
  /// In en, this message translates to:
  /// **'The recipe you are looking for does not exist.'**
  String get recipeDoesNotExist;

  /// Button to collapse expanded text
  ///
  /// In en, this message translates to:
  /// **'View Less'**
  String get viewLess;

  /// Button to expand collapsed text
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// Instructions tab label
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// Servings label
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// Cups unit system
  ///
  /// In en, this message translates to:
  /// **'Cups'**
  String get cups;

  /// Metric unit system
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// Calories nutrition label
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// Protein nutrition label
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// Carbs nutrition label
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// Fat nutrition label
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// Button to add recipe to meal plan
  ///
  /// In en, this message translates to:
  /// **'Add to Meal Plan'**
  String get addToMealPlan;

  /// Modal title for adding recipe to meal plan
  ///
  /// In en, this message translates to:
  /// **'Add \"{recipeTitle}\" to Meal Plan'**
  String addRecipeToMealPlan(String recipeTitle);

  /// Option to navigate to meal planner
  ///
  /// In en, this message translates to:
  /// **'Go to Meal Planner'**
  String get goToMealPlanner;

  /// Subtitle for meal planner option
  ///
  /// In en, this message translates to:
  /// **'Choose specific day and meal time'**
  String get chooseSpecificDayAndMeal;

  /// Option to add recipe to today's meals
  ///
  /// In en, this message translates to:
  /// **'Add to Today'**
  String get addToToday;

  /// Subtitle for add to today option
  ///
  /// In en, this message translates to:
  /// **'Quick add to next available meal today'**
  String get quickAddToTodayMeal;

  /// Question for selecting meal time
  ///
  /// In en, this message translates to:
  /// **'Which meal would you like to add \"{recipeTitle}\" to?'**
  String whichMealToAdd(String recipeTitle);

  /// Success message when recipe is added to today's meal
  ///
  /// In en, this message translates to:
  /// **'Added to today\'s {mealType}!'**
  String addedToTodayMeal(String mealType);

  /// Default breakfast time
  ///
  /// In en, this message translates to:
  /// **'8:30 AM'**
  String get breakfastTime;

  /// Default lunch time
  ///
  /// In en, this message translates to:
  /// **'12:30 PM'**
  String get lunchTime;

  /// Default dinner time
  ///
  /// In en, this message translates to:
  /// **'7:00 PM'**
  String get dinnerTime;

  /// Error message when user is not logged in
  ///
  /// In en, this message translates to:
  /// **'Please login to view your meal plans'**
  String get pleaseLoginToViewMealPlans;

  /// Generic error message when meal plan fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load meal plan'**
  String get failedToLoadMealPlan;

  /// Permission denied error message
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access meal plans'**
  String get youDoNotHavePermission;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection'**
  String get networkError;

  /// Service unavailable error message
  ///
  /// In en, this message translates to:
  /// **'Service is currently unavailable'**
  String get serviceUnavailable;

  /// Auto-fill week dialog title
  ///
  /// In en, this message translates to:
  /// **'Auto-fill Week'**
  String get autoFillWeek;

  /// Auto-fill week dialog description
  ///
  /// In en, this message translates to:
  /// **'Automatically fill empty meal slots with suggestions based on your pantry, leftovers, and seasonal recipes?'**
  String get autoFillWeekDescription;

  /// Auto-fill feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'Auto-fill feature coming soon!'**
  String get autoFillFeatureComingSoon;

  /// Menu option to view previous weeks
  ///
  /// In en, this message translates to:
  /// **'View Previous Weeks'**
  String get viewPreviousWeeks;

  /// Menu option to duplicate current week
  ///
  /// In en, this message translates to:
  /// **'Duplicate Week'**
  String get duplicateWeek;

  /// Menu option to clear all meals
  ///
  /// In en, this message translates to:
  /// **'Clear All Meals'**
  String get clearAllMeals;

  /// Error message when trying to add meals without login
  ///
  /// In en, this message translates to:
  /// **'Please login to add meals'**
  String get pleaseLoginToAddMeals;

  /// Validation error for meal category
  ///
  /// In en, this message translates to:
  /// **'Meal category is required'**
  String get mealCategoryRequired;

  /// Error message when trying to update meals without login
  ///
  /// In en, this message translates to:
  /// **'Please login to update meals'**
  String get pleaseLoginToUpdateMeals;

  /// Error message when meal update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update meal: {error}'**
  String failedToUpdateMeal(String error);

  /// Error message when trying to delete meals without login
  ///
  /// In en, this message translates to:
  /// **'Please login to delete meals'**
  String get pleaseLoginToDeleteMeals;

  /// Error message when meal deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete meal: {error}'**
  String failedToDeleteMeal(String error);

  /// Error message when recipe fails to open
  ///
  /// In en, this message translates to:
  /// **'Failed to open recipe. Please try again.'**
  String get failedToOpenRecipe;

  /// Permission denied error for adding meals
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to add meals'**
  String get youDoNotHavePermissionToAddMeals;

  /// Network error message for meal operations
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again'**
  String get networkErrorCheckConnection;

  /// Service unavailable message for meal operations
  ///
  /// In en, this message translates to:
  /// **'Service is currently unavailable. Please try again later'**
  String get serviceUnavailableTryLater;

  /// Error when no meal plan is available for grocery list
  ///
  /// In en, this message translates to:
  /// **'No meal plan available'**
  String get noMealPlanAvailable;

  /// Instruction to add meals with recipes
  ///
  /// In en, this message translates to:
  /// **'Please add meals with recipes to generate a grocery list.'**
  String get addMealsWithRecipes;

  /// Error when no meals are planned for grocery list
  ///
  /// In en, this message translates to:
  /// **'No meals planned'**
  String get noMealsPlannedForGrocery;

  /// Instruction to add meals to meal plan
  ///
  /// In en, this message translates to:
  /// **'Add meals to your meal plan first, then generate a grocery list.'**
  String get addMealsToMealPlan;

  /// Error when no recipe-based meals exist
  ///
  /// In en, this message translates to:
  /// **'No recipe-based meals'**
  String get noRecipeBasedMeals;

  /// Instruction to add recipe-based meals
  ///
  /// In en, this message translates to:
  /// **'Add meals with recipes to generate ingredients for your grocery list.'**
  String get addMealsWithRecipesForGrocery;

  /// Loading message when generating grocery list
  ///
  /// In en, this message translates to:
  /// **'Generating grocery list...'**
  String get generatingGroceryList;

  /// Detailed loading message for grocery list generation
  ///
  /// In en, this message translates to:
  /// **'Analyzing your meal plan and calculating ingredients'**
  String get analyzingMealPlan;

  /// Error dialog title when grocery list generation fails
  ///
  /// In en, this message translates to:
  /// **'Grocery List Generation Failed'**
  String get groceryListGenerationFailed;

  /// Label for current week in meal planner
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Number of meals planned in a week
  ///
  /// In en, this message translates to:
  /// **'{count} meals planned'**
  String mealsPlanned(int count);

  /// Short abbreviation for Monday
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get mondayShort;

  /// Short abbreviation for Tuesday
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get tuesdayShort;

  /// Short abbreviation for Wednesday
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get wednesdayShort;

  /// Short abbreviation for Thursday
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get thursdayShort;

  /// Short abbreviation for Friday
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fridayShort;

  /// Short abbreviation for Saturday
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get saturdayShort;

  /// Short abbreviation for Sunday
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get sundayShort;

  /// Today badge text
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Monday day name
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// Tuesday day name
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// Wednesday day name
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// Thursday day name
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// Friday day name
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// Saturday day name
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// Sunday day name
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// Unknown fallback text
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Meals count suffix
  ///
  /// In en, this message translates to:
  /// **'meals'**
  String get meals;

  /// Empty state message when no meals are planned for the day
  ///
  /// In en, this message translates to:
  /// **'No meals planned'**
  String get noMealsPlannedEmpty;

  /// Instruction to add first meal
  ///
  /// In en, this message translates to:
  /// **'Tap the + button in navigation to add your first meal'**
  String get tapPlusButtonToAddMeal;

  /// Time picker modal header
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// Time picker subtitle for edit mode
  ///
  /// In en, this message translates to:
  /// **'Select new time for your meal'**
  String get selectNewTimeForMeal;

  /// Time picker subtitle for add mode
  ///
  /// In en, this message translates to:
  /// **'Choose time for {mealCategory}'**
  String chooseTimeForMeal(String mealCategory);

  /// Label for currently selected time display
  ///
  /// In en, this message translates to:
  /// **'Selected Time'**
  String get selectedTime;

  /// Label for preset time selection section
  ///
  /// In en, this message translates to:
  /// **'Quick Select'**
  String get quickSelect;

  /// Button text for custom time picker
  ///
  /// In en, this message translates to:
  /// **'Custom Time'**
  String get customTime;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Recipe selection modal title
  ///
  /// In en, this message translates to:
  /// **'Select Recipe'**
  String get selectRecipe;

  /// Recipe selection modal subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose a recipe for your meal'**
  String get chooseRecipeForMeal;

  /// Loading message in recipe selection modal
  ///
  /// In en, this message translates to:
  /// **'Loading recipes...'**
  String get loadingRecipesEllipsis;

  /// Error message when recipe search fails
  ///
  /// In en, this message translates to:
  /// **'Search failed. Please try again.'**
  String get searchFailed;

  /// Error message when recipe loading fails in selection modal
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipes. Please try again.'**
  String get failedToLoadRecipesPleaseTryAgain;

  /// Empty state title when no recipes are found in selection modal
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get noRecipesFoundEmpty;

  /// Empty state description for search results in selection modal
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get trySearchingWithDifferentKeywords;

  /// Empty state title when no recipes are available in selection modal
  ///
  /// In en, this message translates to:
  /// **'No recipes available'**
  String get noRecipesAvailable;

  /// Empty state description when no recipes are available in selection modal
  ///
  /// In en, this message translates to:
  /// **'Please check back later'**
  String get pleaseCheckBackLater;

  /// Button text to clear search in recipe selection modal
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// Meal confirmation modal title
  ///
  /// In en, this message translates to:
  /// **'Confirm Meal'**
  String get confirmMeal;

  /// Meal confirmation modal subtitle
  ///
  /// In en, this message translates to:
  /// **'Review your meal details'**
  String get reviewMealDetails;

  /// Label for scheduled time section in meal confirmation
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get scheduledTime;

  /// Button text to change scheduled time
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Label for servings selector in meal confirmation
  ///
  /// In en, this message translates to:
  /// **'Number of Servings'**
  String get numberOfServings;

  /// Servings prefix label
  ///
  /// In en, this message translates to:
  /// **'Servings:'**
  String get servingsLabel;

  /// Label for meal category selector
  ///
  /// In en, this message translates to:
  /// **'Meal Category'**
  String get mealCategory;

  /// Button text to go back to recipe selection
  ///
  /// In en, this message translates to:
  /// **'Back to Recipes'**
  String get backToRecipes;

  /// Button text to confirm adding meal to plan
  ///
  /// In en, this message translates to:
  /// **'Add to Meal Plan'**
  String get addToMealPlanAction;

  /// Add meal category text in empty compact meal card
  ///
  /// In en, this message translates to:
  /// **'Add {category}'**
  String addMealCategory(String category);

  /// Generic loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Text shown when recipe name is unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown Recipe'**
  String get unknownRecipe;

  /// Text shown for leftover meals
  ///
  /// In en, this message translates to:
  /// **'Leftover Meal'**
  String get leftoverMeal;

  /// Grocery list title
  ///
  /// In en, this message translates to:
  /// **'Grocery List'**
  String get groceryList;

  /// Week date range display
  ///
  /// In en, this message translates to:
  /// **'Week of {dateRange}'**
  String weekOf(String dateRange);

  /// Empty state title when no grocery items are generated
  ///
  /// In en, this message translates to:
  /// **'No Grocery Items Generated'**
  String get noGroceryItemsGenerated;

  /// Empty state description when no grocery items can be generated
  ///
  /// In en, this message translates to:
  /// **'Your meal plan doesn\'t contain meals with\ningredient information that can generate grocery items'**
  String get mealPlanNoIngredientsInfo;

  /// Step title for adding recipe-based meals
  ///
  /// In en, this message translates to:
  /// **'Add recipe-based meals'**
  String get addRecipeBasedMeals;

  /// Step description for adding recipe-based meals
  ///
  /// In en, this message translates to:
  /// **'Use the + button to add meals from your recipe collection'**
  String get addRecipeBasedMealsDescription;

  /// Step title for ensuring recipes have ingredients
  ///
  /// In en, this message translates to:
  /// **'Ensure recipes have ingredients'**
  String get ensureRecipesHaveIngredients;

  /// Step description for ensuring recipes have ingredients
  ///
  /// In en, this message translates to:
  /// **'Only recipes with ingredient lists can generate grocery items'**
  String get ensureRecipesHaveIngredientsDescription;

  /// Step title for generating grocery list
  ///
  /// In en, this message translates to:
  /// **'Generate your list'**
  String get generateYourList;

  /// Step description for generating grocery list
  ///
  /// In en, this message translates to:
  /// **'Once you have recipe-based meals, try generating again'**
  String get generateYourListDescription;

  /// Summary of grocery items and categories
  ///
  /// In en, this message translates to:
  /// **'{totalItems} items across {categoriesCount} categories'**
  String itemsAcrossCategories(int totalItems, int categoriesCount);

  /// Export button text
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Export button text when in progress
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// Item name input label
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// Quantity input label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Unit input label
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// Category input label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Success message when grocery list is exported
  ///
  /// In en, this message translates to:
  /// **'Grocery list exported successfully!'**
  String get groceryListExportedSuccessfully;

  /// Error message when export fails
  ///
  /// In en, this message translates to:
  /// **'Failed to export: {error}'**
  String failedToExport(String error);

  /// Message when item is removed from grocery list
  ///
  /// In en, this message translates to:
  /// **'{itemName} removed'**
  String itemRemoved(String itemName);

  /// Vegetables category
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// Fruits category
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get fruits;

  /// Meat & Fish category
  ///
  /// In en, this message translates to:
  /// **'Meat & Fish'**
  String get meatFish;

  /// Dairy category
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get dairy;

  /// Grains & Rice category
  ///
  /// In en, this message translates to:
  /// **'Grains & Rice'**
  String get grainsRice;

  /// Oils & Condiments category
  ///
  /// In en, this message translates to:
  /// **'Oils & Condiments'**
  String get oilsCondiments;

  /// Spices category
  ///
  /// In en, this message translates to:
  /// **'Spices'**
  String get spices;

  /// Other category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Placeholder text for recipe image
  ///
  /// In en, this message translates to:
  /// **'Recipe Image'**
  String get recipeImage;

  /// Count of available vs total ingredients
  ///
  /// In en, this message translates to:
  /// **'{available}/{total} ingredients'**
  String availableIngredientsCount(int available, int total);

  /// Text showing missing ingredients
  ///
  /// In en, this message translates to:
  /// **'Missing: {ingredients}'**
  String missingIngredients(String ingredients);

  /// Edit item modal title
  ///
  /// In en, this message translates to:
  /// **'Edit {itemType}'**
  String editItem(String itemType);

  /// Add item modal title
  ///
  /// In en, this message translates to:
  /// **'Add {itemType}'**
  String addItem(String itemType);

  /// Item type selection label
  ///
  /// In en, this message translates to:
  /// **'Item Type'**
  String get itemType;

  /// Ingredient item type
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get ingredient;

  /// Leftover item type
  ///
  /// In en, this message translates to:
  /// **'Leftover'**
  String get leftover;

  /// Item name input label
  ///
  /// In en, this message translates to:
  /// **'{itemType} Name'**
  String itemNameLabel(String itemType);

  /// Item name input hint
  ///
  /// In en, this message translates to:
  /// **'Enter {itemType} name...'**
  String enterItemName(String itemType);

  /// Validation error for empty item name
  ///
  /// In en, this message translates to:
  /// **'Please enter an ingredient name'**
  String get pleaseEnterItemName;

  /// Update button text
  ///
  /// In en, this message translates to:
  /// **'Update {itemType}'**
  String updateItem(String itemType);

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add {itemType}'**
  String addItemAction(String itemType);

  /// Loading message when finding recipes for leftovers
  ///
  /// In en, this message translates to:
  /// **'Finding recipes...'**
  String get findingRecipesEllipsis;

  /// Count of available recipes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recipe} other{{count} recipes}} available'**
  String recipesAvailable(int count);

  /// Title for recipe suggestions section
  ///
  /// In en, this message translates to:
  /// **'Recipe Suggestions'**
  String get recipeSuggestions;

  /// Error message when recipe suggestions fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipe suggestions'**
  String get failedToLoadRecipeSuggestions;

  /// Empty state message when no recipes match the leftover
  ///
  /// In en, this message translates to:
  /// **'No matching recipes found for this leftover'**
  String get noMatchingRecipesFound;

  /// Edit action text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Loading message when searching for leftover recipes
  ///
  /// In en, this message translates to:
  /// **'Finding recipes...'**
  String get findingRecipesForLeftover;

  /// Recipe suggestions title with count
  ///
  /// In en, this message translates to:
  /// **'Recipe suggestions ({count})'**
  String recipeSuggestionsCount(int count);

  /// Message when no recipes are found for leftover
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get noRecipesFound;

  /// Instruction to tap to view recipes
  ///
  /// In en, this message translates to:
  /// **'Tap to view recipes'**
  String get tapToViewRecipes;

  /// Instruction to tap to hide recipes
  ///
  /// In en, this message translates to:
  /// **'Tap to hide recipes'**
  String get tapToHideRecipes;

  /// Error message when suggestions fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load suggestions'**
  String get failedToLoadSuggestions;

  /// Empty state message when no recipes match the leftover item
  ///
  /// In en, this message translates to:
  /// **'No matching recipes found for this leftover'**
  String get noMatchingRecipesFoundForLeftover;

  /// Title for recipes you can make section
  ///
  /// In en, this message translates to:
  /// **'Recipes You Can Make'**
  String get recipesYouCanMake;

  /// Count of recipes text
  ///
  /// In en, this message translates to:
  /// **'{count} recipes'**
  String recipesCountText(int count);

  /// Count of perfect matches
  ///
  /// In en, this message translates to:
  /// **'{count} perfect'**
  String perfectCount(int count);

  /// Count of good matches
  ///
  /// In en, this message translates to:
  /// **'{count} good'**
  String goodCount(int count);

  /// Title for add more ingredients prompt
  ///
  /// In en, this message translates to:
  /// **'Add More Ingredients'**
  String get addMoreIngredients;

  /// Description for add more ingredients prompt
  ///
  /// In en, this message translates to:
  /// **'We\'ll find recipes that match what you have! Add a few more ingredients to see recipe suggestions.'**
  String get addMoreIngredientsDescription;

  /// Suggestion for ingredients to add
  ///
  /// In en, this message translates to:
  /// **'Try adding: Rice, Onions, Garlic'**
  String get tryAddingSuggestion;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
