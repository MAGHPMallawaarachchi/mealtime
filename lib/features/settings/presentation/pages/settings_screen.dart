import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/user_preferences_providers.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/locale_providers.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _householdSize = 4;
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;
  bool _mealPlanReminders = true;
  bool _shoppingListUpdates = false;

  DietaryType? _selectedDietaryType;
  bool _prioritizePantryItems = true;

  // Languages will be loaded dynamically from localization
  final List<DietaryType> _dietaryTypes = [
    DietaryType.nonVegetarian,
    DietaryType.vegetarian,
    DietaryType.vegan,
    DietaryType.pescatarian,
  ];

  @override
  Widget build(BuildContext context) {
    final userPreferences = ref.watch(currentUserProvider);
    final currentLocale = ref.watch(localeProvider);

    return userPreferences.when(
      data: (user) {
        // Initialize local state from server data on first load
        if (user != null) {
          _selectedDietaryType ??= user.dietaryType;
          _prioritizePantryItems = user.prioritizePantryItems;
        }

        // Update selected language based on current locale
        if (currentLocale != null) {
          _selectedLanguage = currentLocale.languageCode == 'si' ? 'Sinhala' : 'English';
        }

        return _buildSettingsContent(context);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text(
            AppLocalizations.of(
              context,
            )!.errorLoadingPreferences(error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button and title
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: PhosphorIcon(
                      PhosphorIcons.arrowLeft(),
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.settings,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildSectionTitle(AppLocalizations.of(context)!.household),
            const SizedBox(height: 8),
            _buildHouseholdCard(),

            const SizedBox(height: 24),
            _buildSectionTitle(AppLocalizations.of(context)!.language),
            const SizedBox(height: 8),
            _buildLanguageCard(),

            const SizedBox(height: 24),
            _buildSectionTitle(
              AppLocalizations.of(context)!.dietaryPreferences,
            ),
            const SizedBox(height: 8),
            _buildDietaryPreferencesCard(),

            const SizedBox(height: 24),
            _buildSectionTitle(
              AppLocalizations.of(context)!.recipeRecommendations,
            ),
            const SizedBox(height: 8),
            _buildRecommendationSettingsCard(),

            const SizedBox(height: 24),
            _buildSectionTitle(AppLocalizations.of(context)!.notifications),
            const SizedBox(height: 8),
            _buildNotificationsCard(),

            const SizedBox(height: 32),
            _buildSaveButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildHouseholdCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.house(),
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.householdSize,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    '$_householdSize ${_householdSize == 1 ? 'person' : 'people'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: _householdSize > 1
                      ? () => setState(() => _householdSize--)
                      : null,
                  icon: PhosphorIcon(PhosphorIcons.minus()),
                  style: IconButton.styleFrom(
                    backgroundColor: _householdSize > 1
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    foregroundColor: _householdSize > 1
                        ? AppColors.primary
                        : Colors.grey,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _householdSize.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() => _householdSize = value.round());
                    },
                  ),
                ),
                IconButton(
                  onPressed: _householdSize < 10
                      ? () => setState(() => _householdSize++)
                      : null,
                  icon: PhosphorIcon(PhosphorIcons.plus()),
                  style: IconButton.styleFrom(
                    backgroundColor: _householdSize < 10
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    foregroundColor: _householdSize < 10
                        ? AppColors.primary
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.translate(),
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.appLanguage,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(
              'English',
              AppLocalizations.of(context)!.english,
            ),
            _buildLanguageOption(
              'Sinhala',
              AppLocalizations.of(context)!.sinhala,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String languageKey, String languageDisplay) {
    final isSelected = _selectedLanguage == languageKey;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () async {
          setState(() => _selectedLanguage = languageKey);
          
          // Update the app locale
          final localeNotifier = ref.read(localeProvider.notifier);
          if (languageKey == 'Sinhala') {
            await localeNotifier.setSinhala();
          } else {
            await localeNotifier.setEnglish();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              PhosphorIcon(
                isSelected
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIcons.circle(),
                size: 20,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  languageDisplay,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.bell(),
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.notifications,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
              ],
            ),
            if (_notificationsEnabled) ...[
              const Divider(height: 24),
              _buildNotificationOption(
                AppLocalizations.of(context)!.mealPlanReminders,
                AppLocalizations.of(context)!.mealPlanRemindersDescription,
                PhosphorIcons.calendar(),
                _mealPlanReminders,
                (value) => setState(() => _mealPlanReminders = value),
              ),
              _buildNotificationOption(
                AppLocalizations.of(context)!.shoppingListUpdates,
                AppLocalizations.of(context)!.shoppingListUpdatesDescription,
                PhosphorIcons.shoppingCart(),
                _shoppingListUpdates,
                (value) => setState(() => _shoppingListUpdates = value),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption(
    String title,
    String subtitle,
    PhosphorIconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          PhosphorIcon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryPreferencesCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.forkKnife(),
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.dietaryPreference,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._dietaryTypes.map((type) => _buildDietaryOption(type)),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryOption(DietaryType dietaryType) {
    final isSelected = _selectedDietaryType == dietaryType;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => setState(() => _selectedDietaryType = dietaryType),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              PhosphorIcon(
                isSelected
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIcons.circle(),
                size: 20,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getDietaryTypeDisplayName(
                    dietaryType,
                    AppLocalizations.of(context)!,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.lightbulb(),
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.prioritizePantryItems,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Switch(
                  value: _prioritizePantryItems,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _prioritizePantryItems = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.prioritizePantryDescription,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _getDietaryTypeDisplayName(DietaryType type, AppLocalizations l10n) {
    switch (type) {
      case DietaryType.nonVegetarian:
        return l10n.nonVegetarian;
      case DietaryType.vegetarian:
        return l10n.vegetarian;
      case DietaryType.vegan:
        return l10n.vegan;
      case DietaryType.pescatarian:
        return l10n.pescatarian;
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          AppLocalizations.of(context)!.saveSettings,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _saveSettings() async {
    try {
      final updatePreferences = ref.read(updateUserPreferencesProvider);

      await updatePreferences(
        dietaryType: _selectedDietaryType,
        prioritizePantryItems: _prioritizePantryItems,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.checkCircle(),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.settingsSavedSuccessfully,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.xCircle(),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.failedToSaveSettings(e.toString()),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
