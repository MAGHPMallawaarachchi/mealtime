import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mealtime/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/seasonal_ingredient.dart';
import '../../domain/usecases/get_seasonal_ingredients_usecase.dart';
import 'seasonal_spotlight_card.dart';

class SeasonalSpotlightSection extends StatefulWidget {
  const SeasonalSpotlightSection({super.key});

  @override
  State<SeasonalSpotlightSection> createState() =>
      _SeasonalSpotlightSectionState();
}

class _SeasonalSpotlightSectionState extends State<SeasonalSpotlightSection> {
  late PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPageIndex = 0;
  List<SeasonalIngredient> _seasonalIngredients = [];
  bool _isLoading = true;
  String? _errorMessage;
  final GetSeasonalIngredientsUseCase _getSeasonalIngredientsUseCase =
      GetSeasonalIngredientsUseCase();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadSeasonalIngredients();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSeasonalIngredients() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final ingredients = await _getSeasonalIngredientsUseCase.call();

      if (mounted) {
        setState(() {
          _seasonalIngredients = ingredients;
          _isLoading = false;
        });

        if (_seasonalIngredients.isNotEmpty) {
          _startAutoPlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load seasonal ingredients. Please try again.';
        });
      }
    }
  }

  Future<void> _refreshData() async {
    try {
      await _getSeasonalIngredientsUseCase.refresh();
      await _loadSeasonalIngredients();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_seasonalIngredients.isEmpty) {
      return _buildEmptyState();
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

  Widget _buildLoadingState() {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            SizedBox(height: 16),
            Text(
              'Loading seasonal ingredients...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                PhosphorIcons.warningCircle(),
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadSeasonalIngredients,
                child: Text(
                  AppLocalizations.of(context)!.tryAgain,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                PhosphorIcons.plant(),
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'No seasonal ingredients available at the moment.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _refreshData,
                child: const Text(
                  'Refresh',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
