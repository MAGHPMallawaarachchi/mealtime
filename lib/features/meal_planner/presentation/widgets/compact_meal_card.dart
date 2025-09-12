import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/optimized_cached_image.dart';
import '../../domain/models/meal_slot.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../../recipes/domain/repositories/recipes_repository.dart';
import '../../../recipes/data/repositories/recipes_repository_impl.dart';
import '../../../../l10n/app_localizations.dart';

class CompactMealCard extends StatefulWidget {
  final MealSlot mealSlot;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showTime;

  const CompactMealCard({
    super.key,
    required this.mealSlot,
    this.onTap,
    this.onLongPress,
    this.showTime = false,
  });

  @override
  State<CompactMealCard> createState() => _CompactMealCardState();
}

class _CompactMealCardState extends State<CompactMealCard> {
  Recipe? _recipe;
  bool _isLoadingRecipe = false;
  late final RecipesRepository _recipesRepository;

  @override
  void initState() {
    super.initState();
    _recipesRepository = RecipesRepositoryImpl();
    if (widget.mealSlot.recipeId != null) {
      _loadRecipe();
    }
  }

  @override
  void didUpdateWidget(CompactMealCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the meal slot changed
    if (oldWidget.mealSlot.id != widget.mealSlot.id ||
        oldWidget.mealSlot.recipeId != widget.mealSlot.recipeId) {
      // Reset recipe state
      _recipe = null;
      _isLoadingRecipe = false;

      // Load new recipe if needed
      if (widget.mealSlot.recipeId != null) {
        _loadRecipe();
      }
    }
  }

  Future<void> _loadRecipe() async {
    final recipeId = widget.mealSlot.recipeId;
    if (recipeId == null) return;

    setState(() {
      _isLoadingRecipe = true;
    });

    try {
      final recipe = await _recipesRepository.getRecipe(recipeId);

      // Only update state if the widget still needs this recipe
      // This prevents stale updates when the widget changes during loading
      if (mounted && widget.mealSlot.recipeId == recipeId) {
        setState(() {
          _recipe = recipe;
          _isLoadingRecipe = false;
        });
      } else {}
    } catch (e) {
      // Only update error state if still relevant
      if (mounted && widget.mealSlot.recipeId == recipeId) {
        setState(() {
          _isLoadingRecipe = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mealSlot.isEmpty) {
      return _buildEmptyCard();
    }

    return _buildFilledCard();
  }

  Widget _buildEmptyCard() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: double.infinity,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.addMealCategory(_getLocalizedCategory()),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (widget.showTime) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.mealSlot.displayTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilledCard() {
    final mealName = _getMealDisplayName();
    final imageUrl = _getMealImageUrl();

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Image or icon section
                Container(
                  width: 70,
                  height: double.infinity,
                  margin: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl != null
                        ? OptimizedCachedImage(
                            key: ValueKey('${widget.mealSlot.id}_$imageUrl'),
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            preload: true,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              PhosphorIcons.forkKnife(),
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                  ),
                ),
                // Content section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Meal name
                        Text(
                          mealName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Category and serving info
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _getLocalizedCategory(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.mealSlot.servingSize > 1) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${widget.mealSlot.servingSize}x',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.showTime) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.mealSlot.displayTime,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Action indicator
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    PhosphorIcons.caretRight(),
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            // Lock indicator
            if (widget.mealSlot.isLocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIcons.lock(),
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getMealDisplayName() {
    if (widget.mealSlot.customMealName != null &&
        widget.mealSlot.customMealName!.isNotEmpty) {
      return widget.mealSlot.customMealName!;
    }

    if (widget.mealSlot.recipeId != null) {
      if (_isLoadingRecipe) {
        return AppLocalizations.of(context)!.loading;
      }
      return _recipe?.title ?? AppLocalizations.of(context)!.unknownRecipe;
    }

    if (widget.mealSlot.leftoverId != null) {
      return AppLocalizations.of(
        context,
      )!.leftoverMeal; // Would fetch actual leftover data
    }

    return _getLocalizedCategory();
  }

  String? _getMealImageUrl() {
    if (widget.mealSlot.recipeId != null) {
      return _recipe?.imageUrl;
    }

    // Could add leftover images or category-based default images
    return null;
  }

  String _getLocalizedCategory() {
    final localizations = AppLocalizations.of(context)!;
    final category = widget.mealSlot.category.toLowerCase();

    switch (category) {
      case 'breakfast':
        return localizations.breakfast;
      case 'lunch':
        return localizations.lunch;
      case 'dinner':
        return localizations.dinner;
      case 'snack':
        return localizations.snack;
      case 'brunch':
        return localizations.brunch;
      case 'late night':
        return localizations.lateNight;
      default:
        // Fallback to original category if no translation found
        return widget.mealSlot.category;
    }
  }
}
