import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/dummy_seasonal_data.dart';
import '../../domain/models/seasonal_ingredient.dart';
import 'seasonal_spotlight_card.dart';

class SeasonalSpotlightSection extends StatefulWidget {
  const SeasonalSpotlightSection({super.key});

  @override
  State<SeasonalSpotlightSection> createState() =>
      _SeasonalSpotlightSectionState();
}

class _SeasonalSpotlightSectionState extends State<SeasonalSpotlightSection> {
  late PageController _pageController;
  late Timer _autoPlayTimer;
  int _currentPageIndex = 0;
  final List<SeasonalIngredient> _seasonalIngredients =
      DummySeasonalData.getSeasonalIngredients();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPageIndex < _seasonalIngredients.length - 1) {
        _currentPageIndex++;
      } else {
        _currentPageIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPageIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_seasonalIngredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _seasonalIngredients.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SeasonalSpotlightCard(
                  ingredient: _seasonalIngredients[index],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildIndicators(),
      ],
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _seasonalIngredients.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPageIndex == index
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
