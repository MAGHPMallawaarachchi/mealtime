import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/optimized_cached_image.dart';
import 'package:mealtime/features/recipes/domain/models/recipe.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../recipes/domain/usecases/get_recipes_usecase.dart';
import '../../../recipes/data/repositories/recipes_repository_impl.dart';

class FeaturedRecipesSection extends ConsumerStatefulWidget {
  const FeaturedRecipesSection({super.key});

  @override
  ConsumerState<FeaturedRecipesSection> createState() => _FeaturedRecipesSectionState();
}

abstract class FeaturedRecipesSectionController {
  Future<void> refreshFeaturedRecipes();
}

class _FeaturedRecipesSectionState extends ConsumerState<FeaturedRecipesSection> implements FeaturedRecipesSectionController {
  late PageController _pageController;
  late Timer _autoPlayTimer;
  int _currentPageIndex = 0;
  List<Recipe> _featuredRecipes = [];
  bool _isLoading = true;
  bool _hasError = false;

  // Dependencies
  late final RecipesRepositoryImpl _recipesRepository;
  late final GetRecipesUseCase _getRecipesUseCase;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeDependencies();
    _loadFeaturedRecipes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set up listener in post frame callback to avoid build phase conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.listen(currentUserProvider, (previousUser, currentUser) {
          if (previousUser?.value?.dietaryType != currentUser?.value?.dietaryType) {
            // User's dietary preference changed, refresh featured recipes
            _loadFeaturedRecipes(forceRefresh: true);
          }
        });
      }
    });
  }

  void _initializeDependencies() {
    _recipesRepository = RecipesRepositoryImpl();
    _getRecipesUseCase = GetRecipesUseCase(_recipesRepository);
  }

  Future<void> _loadFeaturedRecipes({bool forceRefresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      if (forceRefresh) {
        // Force refresh from database to get latest data
        await _recipesRepository.refreshRecipes();
      }

      // Get all recipes and take the first 5 as featured
      // In the future, this could be replaced with a featured flag or algorithm
      final currentUser = ref.read(currentUserProvider).value;
      final allRecipes = await _getRecipesUseCase.execute(dietaryType: currentUser?.dietaryType);
      
      if (mounted) {
        setState(() {
          _featuredRecipes = allRecipes.take(5).toList();
          _isLoading = false;
        });

        if (_featuredRecipes.isNotEmpty) {
          _startAutoPlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> refreshFeaturedRecipes() async {
    await _loadFeaturedRecipes(forceRefresh: true);
  }

  @override
  void dispose() {
    if (_featuredRecipes.isNotEmpty) {
      _autoPlayTimer.cancel();
    }
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
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError || _featuredRecipes.isEmpty) {
      return const SizedBox.shrink(); // Hide section if error or no featured recipes
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

  Widget _buildLoadingState() {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
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
            OptimizedCachedImage(
              imageUrl: recipe.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.background,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.background,
                child: Center(
                  child: PhosphorIcon(
                    PhosphorIcons.image(),
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                ),
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
