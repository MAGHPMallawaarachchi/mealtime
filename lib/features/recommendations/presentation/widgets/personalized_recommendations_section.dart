import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/recommendation_score.dart';
import '../../../../core/models/user_interaction.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../l10n/app_localizations.dart';
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
    extends ConsumerState<PersonalizedRecommendationsSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<RecommendationSectionConfig> _getSections(BuildContext context) => [
    RecommendationSectionConfig(
      title: AppLocalizations.of(context)!.perfectForYourPantry,
      subtitle: AppLocalizations.of(context)!.useUpPantryItems,
      icon: PhosphorIconsRegular.forkKnife,
      type: RecommendationSectionType.pantry,
    ),
    RecommendationSectionConfig(
      title: AppLocalizations.of(context)!.justForYou,
      subtitle: AppLocalizations.of(context)!.basedOnPreferences,
      icon: PhosphorIconsRegular.heart,
      type: RecommendationSectionType.personalized,
    ),
    RecommendationSectionConfig(
      title: AppLocalizations.of(context)!.quickWeeknightMeals,
      subtitle: AppLocalizations.of(context)!.readyInMinutes,
      icon: PhosphorIconsRegular.clock,
      type: RecommendationSectionType.quick,
    ),
    RecommendationSectionConfig(
      title: AppLocalizations.of(context)!.seasonalFavorites,
      subtitle: AppLocalizations.of(context)!.perfectForTimeOfYear,
      icon: PhosphorIconsRegular.leaf,
      type: RecommendationSectionType.seasonal,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int? _lastSectionIndex;

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(autoRecommendationProvider);
    final currentSectionIndex = ref.watch(selectedRecommendationTabProvider);

    // Reset animation when section changes
    if (_lastSectionIndex != currentSectionIndex) {
      _animationController.reset();
      _animationController.forward();
      _lastSectionIndex = currentSectionIndex;
    }

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
    final currentSectionIndex = ref.watch(selectedRecommendationTabProvider);
    final sections = _getSections(context);
    final currentSection = sections[currentSectionIndex];
    final recommendations = _getRecommendationsForSection(currentSection.type);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          key: ValueKey(currentSectionIndex),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStaticHeader(),
            const SizedBox(height: 24),
            _buildRecipesList(recommendations),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticHeader() {
    final currentSectionIndex = ref.watch(selectedRecommendationTabProvider);
    final sections = _getSections(context);
    final currentSection = sections[currentSectionIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: _buildSectionHeader(currentSection, currentSectionIndex),
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

  Widget _buildSectionHeader(
    RecommendationSectionConfig section,
    int currentIndex,
  ) {
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  section.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _buildSectionTabs(currentIndex, context),
        ],
      ),
    );
  }

  Widget _buildSectionTabs(int currentIndex, BuildContext context) {
    final sections = _getSections(context);
    return Row(
      children: List.generate(
        sections.length,
        (index) => _RecommendationTabIndicator(
          isActive: index == currentIndex,
          onTap: () {
            // Update the provider, which will trigger the listener to animate PageController
            ref.read(selectedRecommendationTabProvider.notifier).state = index;
            _animationController.reset();
            _animationController.forward();
          },
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
            physics: const ClampingScrollPhysics(),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return _AnimatedRecommendationCard(
                recommendation: recommendation,
                index: index,
                totalCount: recommendations.length,
                onAddToMealPlan: _onAddToMealPlan,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection() {
    final currentSectionIndex = ref.watch(selectedRecommendationTabProvider);
    final sections = _getSections(context);
    final currentSection = sections[currentSectionIndex];

    final emptyStateInfo = _getEmptyStateInfo(currentSection.type, context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
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
              child: PhosphorIcon(
                emptyStateInfo['icon'] as IconData,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyStateInfo['title'] as String,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              emptyStateInfo['subtitle'] as String,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getEmptyStateInfo(
    RecommendationSectionType type,
    BuildContext context,
  ) {
    switch (type) {
      case RecommendationSectionType.pantry:
        return {
          'icon': PhosphorIconsRegular.forkKnife,
          'title': AppLocalizations.of(context)!.noPantryMatchesFound,
          'subtitle': AppLocalizations.of(context)!.addItemsToGetSuggestions,
        };
      case RecommendationSectionType.personalized:
        return {
          'icon': PhosphorIconsRegular.heart,
          'title': AppLocalizations.of(context)!.buildingYourPreferences,
          'subtitle': AppLocalizations.of(context)!.interactToGetSuggestions,
        };
      case RecommendationSectionType.quick:
        return {
          'icon': PhosphorIconsRegular.clock,
          'title': AppLocalizations.of(context)!.noQuickMealsAvailable,
          'subtitle': AppLocalizations.of(context)!.quickMealSuggestions,
        };
      case RecommendationSectionType.seasonal:
        return {
          'icon': PhosphorIconsRegular.leaf,
          'title': AppLocalizations.of(context)!.noSeasonalRecipesFound,
          'subtitle': AppLocalizations.of(context)!.seasonalRecommendations,
        };
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const PhosphorIcon(
            PhosphorIconsRegular.sparkle,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.personalizedRecommendations,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.addItemsAndSetPreferences,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) => AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 100)),
          curve: Curves.easeOutBack,
          child: Container(
            width: 220,
            margin: const EdgeInsets.only(right: 16),
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
                          child: const SizedBox(
                            width: double.infinity,
                            height: 18,
                          ),
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
          ),
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
          Text(
            AppLocalizations.of(context)!.unableToLoadRecommendations,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.checkConnectionAndRetry,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
            child: Text(AppLocalizations.of(context)!.retry),
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
        content: Text(
          AppLocalizations.of(context)!.addedToMealPlan(recipe.title),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _refreshRecommendations() {
    // This will trigger a refresh of recommendations
    // Implementation depends on how you want to trigger refresh
  }

  String _getLocalizedReason(String originalReason, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Handle dynamic reasons with placeholders
    if (originalReason.startsWith('Perfect for your ')) {
      final items = originalReason.substring('Perfect for your '.length);
      return localizations.perfectForYourItems(items);
    }

    if (originalReason.startsWith('Uses ') &&
        originalReason.contains(' ingredients from your pantry')) {
      final regex = RegExp(r'Uses (\d+) ingredients? from your pantry');
      final match = regex.firstMatch(originalReason);
      if (match != null) {
        final count = int.parse(match.group(1)!);
        return localizations.usesPantryIngredients(count);
      }
    }

    // Handle static reasons
    switch (originalReason) {
      case 'Uses ingredients from your pantry':
        return localizations.usesIngredientsFromPantry;
      case 'Based on your preferences':
        return localizations.basedOnYourPreferences;
      case 'Similar to your preferences':
        return localizations.similarToPreferences;
      case 'Perfect for this season':
        return localizations.perfectForThisSeason;
      case 'Quick and easy':
        return localizations.quickAndEasy;
      case 'Similar to recipes you\'ve enjoyed':
        return localizations.similarToEnjoyedRecipes;
      case 'Perfect match!':
        return localizations.perfectMatch;
      case 'Great match!':
        return localizations.greatMatch;
      default:
        // Return original reason as fallback if not recognized
        return originalReason;
    }
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

class _RecommendationTabIndicator extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _RecommendationTabIndicator({
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isActive ? 1.0 : 0.9,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(left: 6),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: isActive
                ? LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : AppColors.textSecondary.withOpacity(0.2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

class _AnimatedRecommendationCard extends ConsumerWidget {
  final RecommendationScore recommendation;
  final int index;
  final int totalCount;
  final Function(Recipe) onAddToMealPlan;

  const _AnimatedRecommendationCard({
    required this.recommendation,
    required this.index,
    required this.totalCount,
    required this.onAddToMealPlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _buildRecommendationCard(context, ref),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationCard(BuildContext context, WidgetRef ref) {
    final recipesState = ref.watch(recipesProvider);

    if (recipesState.isLoading) {
      return _buildRecipeCardSkeleton();
    }

    if (recipesState.error != null) {
      return _buildRecipeCardError(context);
    }

    final recipe = recipesState.recipes.cast<Recipe?>().firstWhere(
      (r) => r?.id == recommendation.recipeId,
      orElse: () => Recipe(
        id: recommendation.recipeId,
        title: AppLocalizations.of(context)!.recipeNotFound,
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
              Expanded(
                child: Stack(
                  children: [
                    ExploreRecipeCard(
                      recipe: recipe!,
                      onAddToMealPlan: onAddToMealPlan,
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: _buildRecommendationReason(
                        recommendation,
                        context,
                      ),
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

  Widget _buildRecommendationReason(
    RecommendationScore recommendation,
    BuildContext context,
  ) {
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
              _getLocalizedReason(recommendation.reason, context),
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

  Widget _buildRecipeCardSkeleton() {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
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

  Widget _buildRecipeCardError(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PhosphorIcon(
              PhosphorIconsRegular.warning,
              size: 24,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.failedToLoad,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedReason(String originalReason, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Handle dynamic reasons with placeholders
    if (originalReason.startsWith('Perfect for your ')) {
      final items = originalReason.substring('Perfect for your '.length);
      return localizations.perfectForYourItems(items);
    }

    if (originalReason.startsWith('Uses ') &&
        originalReason.contains(' ingredients from your pantry')) {
      final regex = RegExp(r'Uses (\d+) ingredients? from your pantry');
      final match = regex.firstMatch(originalReason);
      if (match != null) {
        final count = int.parse(match.group(1)!);
        return localizations.usesPantryIngredients(count);
      }
    }

    // Handle static reasons
    switch (originalReason) {
      case 'Uses ingredients from your pantry':
        return localizations.usesIngredientsFromPantry;
      case 'Based on your preferences':
        return localizations.basedOnYourPreferences;
      case 'Similar to your preferences':
        return localizations.similarToPreferences;
      case 'Perfect for this season':
        return localizations.perfectForThisSeason;
      case 'Quick and easy':
        return localizations.quickAndEasy;
      case 'Similar to recipes you\'ve enjoyed':
        return localizations.similarToEnjoyedRecipes;
      case 'Perfect match!':
        return localizations.perfectMatch;
      case 'Great match!':
        return localizations.greatMatch;
      default:
        // Return original reason as fallback if not recognized
        return originalReason;
    }
  }
}
