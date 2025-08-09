import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) =>
                    _buildPage(context, _onboardingData[index]),
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  static const List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Welcome to Mealtime.",
      body:
          "Plan delicious meals using ingredients you already have. Reduce food waste while enjoying authentic Sri Lankan cuisine.",
      imagePath: 'assets/images/onboarding/onboarding-1.svg',
    ),
    OnboardingData(
      title: "Smart Pantry Management.",
      body:
          "Keep track of your ingredients, get expiry notifications, and discover delicious recipes based on what's available in your kitchen.",
      imagePath: 'assets/images/onboarding/onboarding-2.svg',
    ),
    OnboardingData(
      title: "Transform Leftovers.",
      body:
          "Turn yesterday's meals into today's delicious creations with safe, creative leftover transformation recipes and cooking tips.",
      imagePath: 'assets/images/onboarding/onboarding-3.svg',
    ),
    OnboardingData(
      title: "Seasonal & Local.",
      body:
          "Get recipe recommendations based on seasonal ingredients and authentic local Sri Lankan food traditions.",
      imagePath: 'assets/images/onboarding/onboarding-4.svg',
    ),
  ];

  Widget _buildPage(BuildContext context, OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          const SizedBox(height: 120),
          // Illustration
          Expanded(
            flex: 3,
            child: Center(
              child: SvgPicture.asset(
                data.imagePath,
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.85,
              ),
            ),
          ),
          const SizedBox(height: 0),
          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 50),
      child: Column(
        children: [
          _buildDotIndicators(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage < _onboardingData.length - 1)
                TextButton(
                  onPressed: () => _onDone(context),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              if (_currentPage < _onboardingData.length - 1)
                GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF58700),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => _onDone(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF58700),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 20 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFFF58700)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _onDone(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingData {
  final String title;
  final String body;
  final String imagePath;

  const OnboardingData({
    required this.title,
    required this.body,
    required this.imagePath,
  });
}
