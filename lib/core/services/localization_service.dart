import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class LocalizationService {
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  // Helper method to get localizations without context
  static AppLocalizations? _instance;

  static void setInstance(AppLocalizations instance) {
    _instance = instance;
  }

  static AppLocalizations get instance {
    if (_instance == null) {
      throw Exception(
        'LocalizationService not initialized. Call setInstance first.',
      );
    }
    return _instance!;
  }
}
