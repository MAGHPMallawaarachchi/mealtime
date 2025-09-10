// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appTitle => 'ආහාර වේලාව';

  @override
  String get todaysMealPlan => 'අද ආහාර සැලැස්ම';

  @override
  String get seeAll => 'සියල්ල බලන්න';

  @override
  String get noMealsPlanned => 'තවම ආහාර සැලසුම් නැත';

  @override
  String get startPlanningMeals =>
      'ආහාර සැලසුම් කිරීම ආරම්භ කිරීමට \"සියල්ල බලන්න\" ක්ලික් කරන්න';

  @override
  String get settings => 'සැකසුම්';

  @override
  String get language => 'භාෂාව';

  @override
  String get appLanguage => 'යෙදුම භාෂාව';

  @override
  String get english => 'ඉංග්‍රීසි';

  @override
  String get sinhala => 'සිංහල';

  @override
  String get household => 'ගෘහස්ථය';

  @override
  String get householdSize => 'ගෘහස්ථ ප්‍රමාණය';

  @override
  String get dietaryPreferences => 'ආහාර මනාපයන්';

  @override
  String get dietaryPreference => 'ආහාර මනාපය';

  @override
  String get nonVegetarian => 'මස් භක්ෂක';

  @override
  String get vegetarian => 'නිර්මාංශිත';

  @override
  String get vegan => 'සම්පූර්ණ ශාක ආහාර';

  @override
  String get pescatarian => 'මත්ස්‍ය භක්ෂක';

  @override
  String get recipeRecommendations => 'වට්ටෝරු නිර්දේශ';

  @override
  String get prioritizePantryItems => 'ගබඩා ද්‍රව්‍ය ප්‍රමුඛතාව';

  @override
  String get prioritizePantryDescription =>
      'සක්‍රීය කළ විට, ඔබේ ගබඩාවේ ඇති අමුද්‍රව්‍ය භාවිතා කරන වට්ටෝරුවලට නිර්දේශවල ප්‍රමුඛතාව ලැබෙනු ඇත';

  @override
  String get notifications => 'දැනුම් දීම්';

  @override
  String get mealPlanReminders => 'ආහාර සැලැස්ම සිහිකැඳවීම්';

  @override
  String get mealPlanRemindersDescription =>
      'ඔබේ සැලසුම් කළ ආහාර ගැන සිහිකැඳවීම් ලබා ගන්න';

  @override
  String get shoppingListUpdates => 'සාප්පු ලැයිස්තු යාවත්කාලීන';

  @override
  String get shoppingListUpdatesDescription =>
      'සාප්පු ලැයිස්තුව වෙනස් වන විට දැනුම් ලබා ගන්න';

  @override
  String get saveSettings => 'සැකසුම් සුරකින්න';

  @override
  String get settingsSavedSuccessfully => 'සැකසුම් සාර්ථකව සුරකින ලදී';

  @override
  String failedToSaveSettings(String error) {
    return 'සැකසුම් සුරැකීම අසාර්ථක විය: $error';
  }

  @override
  String errorLoadingPreferences(String error) {
    return 'මනාපයන් පැටවීමේ දෝෂය: $error';
  }

  @override
  String get perfectForYourPantry => 'ඔබේ ගබඩාවට සුදුසු';

  @override
  String get useUpPantryItems => 'ඔබේ ගබඩා ද්‍රව්‍ය භාවිතා කරන්න';

  @override
  String get justForYou => 'ඔබ සඳහා පමණි';

  @override
  String get basedOnPreferences => 'ඔබේ මනාපයන් මත පදනම් වූ';

  @override
  String get quickWeeknightMeals => 'ඉක්මන් සතියේ දින ආහාර';

  @override
  String get readyInMinutes => 'මිනිත්තු 30කට වඩා අඩු කාලයකින් සූදානම්';

  @override
  String get seasonalFavorites => 'කාලීන ප්‍රියතම';

  @override
  String get perfectForTimeOfYear => 'වර්ෂයේ මෙම කාලයට සුදුසු';

  @override
  String get noPantryMatchesFound => 'ගබඩා ගැලපීම් හමු නොවීය';

  @override
  String get addItemsToGetSuggestions =>
      'වට්ටෝරු යෝජනා ලබා ගැනීමට ඔබේ ගබඩාවට අයිතම එක් කරන්න';

  @override
  String get buildingYourPreferences => 'ඔබේ මනාපයන් ගොඩනගමින්';

  @override
  String get interactToGetSuggestions =>
      'පුද්ගලික යෝජනා ලබා ගැනීමට වට්ටෝරු සමග අන්තර්ක්‍රියා කරන්න';

  @override
  String get noQuickMealsAvailable => 'ඉක්මන් ආහාර නොමැත';

  @override
  String get quickMealSuggestions => 'ඉක්මන් ආහාර යෝජනා මෙහි දිස්වෙනු ඇත';

  @override
  String get noSeasonalRecipesFound => 'කාලීන වට්ටෝරු හමු නොවීය';

  @override
  String get seasonalRecommendations =>
      'වර්ෂයේ වර්තමාන කාලය මත පදනම් වූ කාලීන නිර්දේශ';

  @override
  String get personalizedRecommendations => 'පුද්ගලික නිර්දේශ';

  @override
  String get addItemsAndSetPreferences =>
      'පුද්ගලික වට්ටෝරු නිර්දේශ ලබා ගැනීමට ඔබේ ගබඩාවට අයිතම එක් කර ඔබේ මනාපයන් සකසන්න.';

  @override
  String get unableToLoadRecommendations => 'නිර්දේශ පැටවීමට නොහැකිය';

  @override
  String get checkConnectionAndRetry =>
      'කරුණාකර ඔබේ සම්බන්ධතාවය පරීක්ෂා කර නැවත උත්සාහ කරන්න.';

  @override
  String get retry => 'නැවත උත්සාහ කරන්න';

  @override
  String get noImage => 'පින්තූරයක් නැත';
}
