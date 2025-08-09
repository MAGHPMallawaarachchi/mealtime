import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: _buildPages(context),
      onDone: () => _onDone(context),
      onSkip: () => _onDone(context),
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Colors.grey.shade300,
        activeColor: Theme.of(context).primaryColor,
        activeSize: const Size(22.0, 10.0),
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  List<PageViewModel> _buildPages(BuildContext context) {
    return [
      PageViewModel(
        title: "Welcome to MealTime",
        body: "Plan delicious meals using ingredients you already have. Reduce food waste while enjoying authentic Sri Lankan cuisine.",
        image: _buildImage(Icons.restaurant_menu, Colors.green),
        decoration: _getPageDecoration(context),
      ),
      PageViewModel(
        title: "Smart Pantry Management",
        body: "Keep track of your ingredients, get expiry notifications, and discover recipes based on what's available in your kitchen.",
        image: _buildImage(Icons.kitchen, Colors.orange),
        decoration: _getPageDecoration(context),
      ),
      PageViewModel(
        title: "Transform Leftovers",
        body: "Turn yesterday's meals into today's delicious creations with safe, creative leftover transformation recipes.",
        image: _buildImage(Icons.refresh, Colors.blue),
        decoration: _getPageDecoration(context),
      ),
      PageViewModel(
        title: "Seasonal & Local",
        body: "Get recipe recommendations based on seasonal ingredients and local Sri Lankan food traditions.",
        image: _buildImage(Icons.eco, Colors.teal),
        decoration: _getPageDecoration(context),
      ),
    ];
  }

  Widget _buildImage(IconData icon, Color color) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 80,
        color: color,
      ),
    );
  }

  PageDecoration _getPageDecoration(BuildContext context) {
    return PageDecoration(
      titleTextStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
      bodyTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontSize: 16,
        height: 1.5,
        color: Colors.grey.shade600,
      ),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: const EdgeInsets.only(top: 40),
    );
  }

  Future<void> _onDone(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    if (context.mounted) {
      context.go('/home');
    }
  }
}