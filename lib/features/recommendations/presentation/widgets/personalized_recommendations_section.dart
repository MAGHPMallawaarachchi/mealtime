import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/recommendation_score.dart';
import '../../../../core/models/user_interaction.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../../explore/presentation/widgets/explore_recipe_card.dart';
import '../../../recipes/presentation/providers/recipes_providers.dart';
import '../providers/recommendation_provider.dart';

class PersonalizedRecommendationsSection extends ConsumerStatefulWidget {
  const PersonalizedRecommendationsSection({super.key});

  @override
  ConsumerState<PersonalizedRecommendationsSection> createState() =>
      _PersonalizedRecommendationsSectionState();
}

class _PersonalizedRecommendationsSectionState
    extends ConsumerState<PersonalizedRecommendationsSection> {
  int _currentSectionIndex = 0;

  final List<RecommendationSectionConfig> _sections = [
    RecommendationSectionConfig(
      title: "Perfect for Your Pantry",
      subtitle: "Use up your ingredients",
      icon: PhosphorIconsRegular.forkKnife,
      type: RecommendationSectionType.pantry,
    ),
    RecommendationSectionConfig(
      title: "Just for You",
      subtitle: "Based on your preferences",
      icon: PhosphorIconsRegular.heart,
      type: RecommendationSectionType.personalized,
    ),
    RecommendationSectionConfig(
      title: "Quick Weeknight Meals",
      subtitle: "Ready in 30 minutes or less",
      icon: PhosphorIconsRegular.clock,
      type: RecommendationSectionType.quick,
    ),
    RecommendationSectionConfig(
      title: "Seasonal Favorites",
      subtitle: "Perfect for this time of year",
      icon: PhosphorIconsRegular.leaf,
      type: RecommendationSectionType.seasonal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(recommendationProvider);

    return recommendationsAsync.when(
      data: (batch) {
        if (batch == null || batch.recommendations.isEmpty) {
          return _buildEmptyState();
        }
        return _buildRecommendationsContent(batch);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(),
    );
  }

  Widget _buildRecommendationsContent(RecommendationBatch batch) {
    final currentSection = _sections[_currentSectionIndex];
    final recommendations = _getRecommendationsForSection(currentSection.type);

    if (recommendations.isEmpty) {
      // If current section is empty, try to find a section with recommendations
      for (int i = 0; i < _sections.length; i++) {
        final sectionRecommendations = _getRecommendationsForSection(
          _sections[i].type,
        );
        if (sectionRecommendations.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _currentSectionIndex = i);
          });
          break;
        }
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0, 0.1), end: Offset.zero),
            ),
            child: child,
          ),
        );
      },
      child: Column(
        key: ValueKey(_currentSectionIndex),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(currentSection),
          const SizedBox(height: 24),
          _buildRecipesList(recommendations),
        ],
      ),
    );
  }

  List<RecommendationScore> _getRecommendationsForSection(
    RecommendationSectionType type,
  ) {
    switch (type) {
      case RecommendationSectionType.pantry:
        return ref.watch(pantryBasedRecommendationsProvider).take(10).toList();
      case RecommendationSectionType.personalized:
        return ref.watch(personalizedRecommendationsProvider).take(10).toList();
      case RecommendationSectionType.quick:
        return ref.watch(quickMealRecommendationsProvider).take(10).toList();
      case RecommendationSectionType.seasonal:
        return ref.watch(seasonalRecommendationsProvider).take(10).toList();
    }
  }

  Widget _buildSectionHeader(RecommendationSectionConfig section) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primaryLight.withOpacity(0.02),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PhosphorIcon(section.icon, size: 22, color: AppColors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  section.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _buildSectionTabs(),
        ],
      ),
    );
  }

  Widget _buildSectionTabs() {
    return Row(
      children: List.generate(
        _sections.length,
        (index) => GestureDetector(
          onTap: () => setState(() => _currentSectionIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(left: 6),
            width: index == _currentSectionIndex ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: index == _currentSectionIndex
                  ? LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    )
                  : null,
              color: index == _currentSectionIndex
                  ? null
                  : AppColors.textSecondary.withOpacity(0.2),
              boxShadow: index == _currentSectionIndex
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipesList(List<RecommendationScore> recommendations) {
    if (recommendations.isEmpty) {
      return _buildEmptySection();
    }

    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // Subtle gradient background
          Container(
            height: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.primary.withOpacity(0.01),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Recipe cards list
          ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 200 + (index * 50)),
                curve: Curves.easeOutBack,
                child: _buildRecommendationCard(
                  recommendation,
                  index,
                  recommendations.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    RecommendationScore recommendation,
    int index,
    int totalCount,
  ) {
    final recipesState = ref.watch(recipesProvider);

    // Handle loading state
    if (recipesState.isLoading) {
      return _buildRecipeCardSkeleton(index);
    }

    // Handle error state
    if (recipesState.error != null) {
      return _buildRecipeCardError();
    }

    // Find the recipe
    final recipe = recipesState.recipes.cast<Recipe?>().firstWhere(
      (r) => r?.id == recommendation.recipeId,
      orElse: () => Recipe(
        id: recommendation.recipeId,
        title: 'Recipe Not Found',
        time: '',
        imageUrl: '',
        ingredients: [],
        instructionSections: [],
        calories: 0,
        macros: const RecipeMacros(protein: 0, carbs: 0, fats: 0, fiber: 0),
      ),
    );

    return Container(
      width: 220,
      margin: EdgeInsets.only(
        left: index == 0 ? 0 : 16,
        right: index == totalCount - 1 ? 16 : 0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Card with embedded recommendation reason
              Expanded(
                child: Stack(
                  children: [
                    ExploreRecipeCard(
                      recipe: recipe!,
                      onAddToMealPlan: _onAddToMealPlan,
                    ),
                    // Recommendation reason overlay at the bottom
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: _buildRecommendationReason(recommendation),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationReason(RecommendationScore recommendation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.primaryLight.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(
            PhosphorIconsRegular.sparkle,
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              recommendation.reason,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.primary.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchScore(double score) {
    final percentage = (score * 100).round();
    final color = score >= 0.8
        ? AppColors.success
        : score >= 0.6
        ? AppColors.primary
        : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(PhosphorIconsRegular.percent, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            '$percentage',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withOpacity(0.3),
            AppColors.primary.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const PhosphorIcon(
                PhosphorIconsRegular.sparkle,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No recommendations yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adding items to your pantry',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Column(
        children: [
          PhosphorIcon(
            PhosphorIconsRegular.sparkle,
            size: 48,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'Personalized recommendations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add items to your pantry and set your preferences to get personalized recipe recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) => AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 100)),
          curve: Curves.easeOutBack,
          child: _buildRecipeCardSkeleton(index),
        ),
      ),
    );
  }

  Widget _buildRecipeCardSkeleton(int index) {
    return Container(
      width: 220,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.border.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: PhosphorIcon(
                  PhosphorIconsRegular.image,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.border.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const SizedBox(width: double.infinity, height: 18),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.border.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const SizedBox(width: 120, height: 14),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const SizedBox(width: 80, height: 24),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.border.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const SizedBox(width: 40, height: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCardError() {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIconsRegular.warning,
              size: 24,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8),
            Text(
              'Failed to load',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const PhosphorIcon(
            PhosphorIconsRegular.warning,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to load recommendations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshRecommendations,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _onAddToMealPlan(Recipe recipe) {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    // Record interaction and add to meal plan
    ref.recordRecipeInteraction(
      userId: currentUser.uid,
      recipeId: recipe.id,
      type: InteractionType.addToMealPlan,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipe.title} added to meal plan'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _refreshRecommendations() {
    // This will trigger a refresh of recommendations
    // Implementation depends on how you want to trigger refresh
  }
}

class RecommendationSectionConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final RecommendationSectionType type;

  const RecommendationSectionConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
  });
}

enum RecommendationSectionType { pantry, personalized, quick, seasonal }
