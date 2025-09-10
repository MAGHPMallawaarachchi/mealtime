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
