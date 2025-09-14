import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/recipes/data/repositories/recipes_repository_impl.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  static const String _localeKey = 'app_locale';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    
    if (localeCode != null) {
      state = Locale(localeCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);

    // Clear recipe cache when locale changes to ensure fresh localized data
    try {
      final recipesRepository = RecipesRepositoryImpl();
      await recipesRepository.clearCache();
    } catch (e) {
      // Log the error but don't prevent locale change
      debugPrint('Failed to clear recipes cache on locale change: $e');
    }

    state = locale;
  }

  Future<void> setSinhala() async {
    await setLocale(const Locale('si'));
  }

  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }
}