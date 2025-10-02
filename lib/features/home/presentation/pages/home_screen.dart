import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recommendations/presentation/widgets/personalized_recommendations_section.dart';
import '../widgets/todays_meal_plan_section.dart';
import '../widgets/seasonal_spotlight_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              PhosphorIcon(
                                _getGreetingIcon(),
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getGreeting(context),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            user?.displayName ??
                                AppLocalizations.of(context)!.guestUser,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.notificationsComingSoon,
                            ),
                          ),
                        );
                      },
                      icon: PhosphorIcon(
                        PhosphorIcons.bell(),
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const SeasonalSpotlightSection(),
              const SizedBox(height: 20),
              const TodaysMealPlanSection(),
              const SizedBox(height: 20),
              const PersonalizedRecommendationsSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final localizations = AppLocalizations.of(context);
    if (hour < 12) {
      return localizations!.goodMorning;
    } else if (hour < 17) {
      return localizations!.goodAfternoon;
    } else {
      return localizations!.goodEvening;
    }
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return PhosphorIcons.sun();
    } else if (hour < 17) {
      return PhosphorIcons.sun();
    } else {
      return PhosphorIcons.moon();
    }
  }
}
