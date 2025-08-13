import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealtime/features/recipes/domain/models/recipe.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/dummy_explore_data.dart';

class FeaturedRecipesSection extends StatefulWidget {
  const FeaturedRecipesSection({super.key});

  @override
  State<FeaturedRecipesSection> createState() => _FeaturedRecipesSectionState();
}

class _FeaturedRecipesSectionState extends State<FeaturedRecipesSection> {
  late PageController _pageController;
  late Timer _autoPlayTimer;
  int _currentPageIndex = 0;
  final List<Recipe> _featuredRecipes = DummyExploreData.getFeaturedRecipes();

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
      if (_currentPageIndex < _featuredRecipes.length - 1) {
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
    if (_featuredRecipes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _featuredRecipes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _FeaturedRecipeCard(recipe: _featuredRecipes[index]),
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
        _featuredRecipes.length,
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

class _FeaturedRecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _FeaturedRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/recipe/${recipe.id}');
      },
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: recipe.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Featured Recipe',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recipe.title,
                            style: const TextStyle(
                              fontSize: 24,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              PhosphorIcon(
                                PhosphorIcons.clock(),
                                size: 16,
                                color: AppColors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.time,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 16),
                              PhosphorIcon(
                                PhosphorIcons.fire(),
                                size: 16,
                                color: AppColors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.calories} cal',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Try Recipe',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
