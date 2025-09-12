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
