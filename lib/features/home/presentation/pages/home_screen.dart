import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../recommendations/presentation/widgets/personalized_recommendations_section.dart';
import '../widgets/todays_meal_plan_section.dart';
import '../widgets/category_section.dart';
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
                                _getGreeting(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            user?.displayName ?? 'Guest User',
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
                          const SnackBar(
                            content: Text('Notifications coming soon!'),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
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
