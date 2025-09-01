import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/recipe_match.dart';
import '../providers/pantry_providers.dart';
import 'recipe_match_card.dart';

class RecipeMatchesSection extends ConsumerStatefulWidget {
  final int maxItemsToShow;
  final bool showViewAll;

  const RecipeMatchesSection({
    super.key,
    this.maxItemsToShow = 5,
    this.showViewAll = true,
  });

  @override
  ConsumerState<RecipeMatchesSection> createState() =>
      _RecipeMatchesSectionState();
}

class _RecipeMatchesSectionState extends ConsumerState<RecipeMatchesSection> {
  bool _isExpanded = false;
  MatchType _selectedFilter = MatchType.complete;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipeMatches();
    });
  }

  Future<void> _loadRecipeMatches() async {
    final recipeMatchesNotifier = ref.read(recipeMatchesProvider.notifier);
    await recipeMatchesNotifier.loadRecipeMatches();
  }

  List<RecipeMatch> _getFilteredMatches(List<RecipeMatch> allMatches) {
    return allMatches
        .where((match) => match.matchType == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final recipeMatchesState = ref.watch(recipeMatchesProvider);

    if (recipeMatchesState.isLoading) {
      return _buildLoadingState();
    }

    if (recipeMatchesState.error != null) {
      return _buildErrorState(recipeMatchesState.error!);
    }

    if (recipeMatchesState.matches.isEmpty) {
      return _buildEmptyState();
    }

    final filteredMatches = _getFilteredMatches(recipeMatchesState.matches);
    final displayMatches = _isExpanded
        ? filteredMatches
        : filteredMatches.take(widget.maxItemsToShow).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
                bottom: Radius.circular(0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.chefHat(),
                      size: 24,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Recipes You Can Make',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadRecipeMatches,
                      icon: PhosphorIcon(
                        PhosphorIcons.arrowClockwise(),
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Filter tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterTab(
                        MatchType.complete,
                        'Complete',
                        recipeMatchesState.matches
                            .where((m) => m.matchType == MatchType.complete)
                            .length,
                        AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterTab(
                        MatchType.partial,
                        'Partial',
                        recipeMatchesState.matches
                            .where((m) => m.matchType == MatchType.partial)
                            .length,
                        AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterTab(
                        MatchType.minimal,
                        'Some',
                        recipeMatchesState.matches
                            .where((m) => m.matchType == MatchType.minimal)
                            .length,
                        AppColors.info,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Recipe matches list
          if (displayMatches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...displayMatches.map(
                    (match) => RecipeMatchCard(match: match),
                  ),

                  // View all/less button
                  if (widget.showViewAll &&
                      filteredMatches.length > widget.maxItemsToShow)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isExpanded
                                  ? 'Show Less'
                                  : 'View All ${filteredMatches.length} Recipes',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            PhosphorIcon(
                              _isExpanded
                                  ? PhosphorIcons.caretUp()
                                  : PhosphorIcons.caretDown(),
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Empty filtered state
          if (displayMatches.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.magnifyingGlass(),
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No ${_selectedFilter.displayName.toLowerCase()} recipes found',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try selecting a different filter or add more ingredients to your pantry',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    MatchType matchType,
    String label,
    int count,
    Color color,
  ) {
    final isSelected = matchType == _selectedFilter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = matchType;
          _isExpanded = false; // Reset expansion when changing filter
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.textSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
              SizedBox(height: 16),
              Text(
                'Finding recipes you can make...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              PhosphorIcon(
                PhosphorIcons.warningCircle(),
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load recipe matches',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadRecipeMatches,
                child: const Text(
                  'Try Again',
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

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              PhosphorIcon(
                PhosphorIcons.chefHat(),
                size: 48,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'No Recipe Matches Yet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add some ingredients to your pantry to discover recipes you can make!',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
