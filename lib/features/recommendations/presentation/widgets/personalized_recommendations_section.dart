import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/recommendation_score.dart';
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
      icon: PhosphorIcons.forkKnife,
      type: RecommendationSectionType.pantry,
    ),
    RecommendationSectionConfig(
      title: "Just for You",
      subtitle: "Based on your preferences",
      icon: PhosphorIcons.heart,
      type: RecommendationSectionType.personalized,
    ),
    RecommendationSectionConfig(
      title: "Quick Weeknight Meals",
      subtitle: "Ready in 30 minutes or less",
      icon: PhosphorIcons.clock,
      type: RecommendationSectionType.quick,
    ),
    RecommendationSectionConfig(
      title: "Seasonal Favorites",
      subtitle: "Perfect for this time of year",
      icon: PhosphorIcons.leaf,
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
        final sectionRecommendations = _getRecommendationsForSection(_sections[i].type);
        if (sectionRecommendations.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _currentSectionIndex = i);
          });
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(currentSection),
        const SizedBox(height: 16),
        _buildRecipesList(recommendations),
      ],
    );
  }

  List<RecommendationScore> _getRecommendationsForSection(RecommendationSectionType type) {
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: PhosphorIcon(
            section.icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                section.subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _buildSectionTabs(),
      ],
    );
  }

  Widget _buildSectionTabs() {
    return Row(
      children: List.generate(
        _sections.length,
        (index) => GestureDetector(
          onTap: () => setState(() => _currentSectionIndex = index),
          child: Container(
            margin: const EdgeInsets.only(left: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentSectionIndex
                  ? AppColors.primary
                  : AppColors.textSecondary.withOpacity(0.3),
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = recommendations[index];
          return _buildRecommendationCard(recommendation, index);
        },
      ),
    );
  }

  Widget _buildRecommendationCard(RecommendationScore recommendation, int index) {
    final recipesState = ref.watch(recipesProvider);
    
    // Handle loading state
    if (recipesState.isLoading) {
      return _buildRecipeCardSkeleton();
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
      width: 200,
      margin: EdgeInsets.only(
        left: index == 0 ? 0 : 12,
        right: index == recommendations.length - 1 ? 16 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ExploreRecipeCard(
              recipe: recipe!,
              onTap: () => _onRecipeTap(recipe),
              onFavoriteToggle: () => _onFavoriteToggle(recipe),
              isFavorite: false, // This will be managed by the parent
              onAddToMealPlan: () => _onAddToMealPlan(recipe),
            ),
          ),
          const SizedBox(height: 8),
          _buildRecommendationReason(recommendation),
        ],
      ),
    );
  }

  Widget _buildRecommendationReason(RecommendationScore recommendation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        recommendation.reason,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptySection() {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              PhosphorIcons.cookingPot,
              size: 32,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8),
            Text(
              'No recommendations yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            Text(
              'Try adding items to your pantry',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
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
            PhosphorIcons.sparkle,
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
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) => _buildRecipeCardSkeleton(),
      ),
    );
  }

  Widget _buildRecipeCardSkeleton() {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Expanded(
            flex: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SizedBox(width: double.infinity, height: 16),
                  ),
                  SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SizedBox(width: 100, height: 12),
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
              PhosphorIcons.warning,
              size: 24,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8),
            Text(
              'Failed to load',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
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
            PhosphorIcons.warning,
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
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
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

  void _onRecipeTap(Recipe recipe) {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;
    
    // Record interaction and navigate to recipe detail
    ref.recordRecipeInteraction(
      userId: currentUser.uid,
      recipeId: recipe.id,
      type: InteractionType.view,
    );
    
    Navigator.pushNamed(context, '/recipe-detail', arguments: recipe);
  }

  void _onFavoriteToggle(Recipe recipe) {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;
    
    // This will be handled by the parent widget
    // Record interaction
    ref.recordRecipeInteraction(
      userId: currentUser.uid,
      recipeId: recipe.id,
      type: InteractionType.favorite,
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

enum RecommendationSectionType {
  pantry,
  personalized,
  quick,
  seasonal,
}