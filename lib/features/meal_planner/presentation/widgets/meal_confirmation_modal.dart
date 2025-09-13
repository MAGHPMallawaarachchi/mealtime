import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/optimized_cached_image.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../domain/models/meal_slot.dart';
import '../../../../l10n/app_localizations.dart';

class MealConfirmationModal extends StatefulWidget {
  final Recipe recipe;
  final TimeOfDay selectedTime;
  final DateTime date;
  final int defaultServings;
  final Function(MealSlot) onConfirm;
  final VoidCallback? onBackToRecipes;
  final VoidCallback? onBackToTime;
  final Function(TimeOfDay, Function(TimeOfDay))? onTimeChangeRequest;

  const MealConfirmationModal({
    super.key,
    required this.recipe,
    required this.selectedTime,
    required this.date,
    required this.onConfirm,
    this.defaultServings = 4,
    this.onBackToRecipes,
    this.onBackToTime,
    this.onTimeChangeRequest,
  });

  @override
  State<MealConfirmationModal> createState() => _MealConfirmationModalState();
}

class _MealConfirmationModalState extends State<MealConfirmationModal> {
  late int _servings;
  late String _selectedCategory;
  late TimeOfDay _currentSelectedTime;
  bool _categoryManuallyChanged = false;

  @override
  void initState() {
    super.initState();
    _servings = widget.defaultServings;
    _currentSelectedTime = widget.selectedTime;
    _selectedCategory = _getCategoryFromTime(widget.selectedTime);
  }

  String _getCategoryFromTime(TimeOfDay time) {
    final hour = time.hour;

    if (hour >= 6 && hour < 11) {
      return MealCategory.breakfast;
    } else if (hour >= 11 && hour < 16) {
      return MealCategory.lunch;
    } else if (hour >= 16 && hour < 20) {
      return MealCategory.snack;
    } else if (hour >= 20 || hour < 2) {
      return MealCategory.dinner;
    } else if (hour >= 2 && hour < 6) {
      return MealCategory.lateNight;
    }

    return MealCategory.custom;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _currentSelectedTime = newTime;
      // Only update category if user hasn't manually changed it
      if (!_categoryManuallyChanged) {
        _selectedCategory = _getCategoryFromTime(newTime);
      }
    });
  }

  String _getLocalizedCategoryName(String category) {
    final localizations = AppLocalizations.of(context)!;
    switch (category) {
      case MealCategory.breakfast:
        return localizations.breakfast;
      case MealCategory.lunch:
        return localizations.lunch;
      case MealCategory.dinner:
        return localizations.dinner;
      case MealCategory.snack:
        return localizations.snack;
      case MealCategory.brunch:
        return localizations.brunch;
      case MealCategory.lateNight:
        return localizations.lateNight;
      case MealCategory.custom:
        return localizations.customMeal;
      default:
        return category;
    }
  }

  void _confirmMeal() {
    final scheduledTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      _currentSelectedTime.hour,
      _currentSelectedTime.minute,
    );

    final mealSlot = MealSlot(
      id: '${widget.date.toIso8601String().split('T')[0]}_${DateTime.now().millisecondsSinceEpoch}',
      category: _selectedCategory,
      scheduledTime: scheduledTime,
      recipeId: widget.recipe.id,
      customMealName: widget.recipe.title,
      servingSize: _servings,
    );

    widget.onConfirm(mealSlot);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecipePreview(),
                  const SizedBox(height: 24),
                  _buildTimeDisplay(),
                  const SizedBox(height: 24),
                  _buildServingSelector(),
                  const SizedBox(height: 24),
                  _buildCategorySelector(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.confirmMeal,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.reviewMealDetails,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                PhosphorIcons.x(),
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: OptimizedCachedImage(
                imageUrl: widget.recipe.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recipe.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.clock(),
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.recipe.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    PhosphorIcon(
                      PhosphorIcons.fire(),
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.recipe.calories} cal',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.scheduledTime,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                ),
                child: Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.clock(),
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatTime(_currentSelectedTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: widget.onTimeChangeRequest != null
                  ? () => widget.onTimeChangeRequest!(
                      _currentSelectedTime,
                      _onTimeChanged,
                    )
                  : widget.onBackToTime,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
              child: Text(AppLocalizations.of(context)!.change),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.numberOfServings,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: Row(
            children: [
              PhosphorIcon(
                PhosphorIcons.users(),
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.servingsLabel,
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _servings > 1 ? () => setState(() => _servings--) : null,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _servings > 1
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PhosphorIcon(
                    PhosphorIcons.minus(),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$_servings',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _servings < 12
                    ? () => setState(() => _servings++)
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _servings < 12
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PhosphorIcon(
                    PhosphorIcons.plus(),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.mealCategory,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...MealCategory.predefined.map(
              (category) => _CategoryChip(
                category: category,
                displayName: _getLocalizedCategoryName(category),
                isSelected: _selectedCategory == category,
                onTap: () => setState(() {
                  _selectedCategory = category;
                  _categoryManuallyChanged = true;
                }),
              ),
            ),
            _CategoryChip(
              category: MealCategory.custom,
              displayName: _getLocalizedCategoryName(MealCategory.custom),
              isSelected: _selectedCategory == MealCategory.custom,
              onTap: () => setState(() {
                _selectedCategory = MealCategory.custom;
                _categoryManuallyChanged = true;
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onBackToRecipes,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
                child: Text(AppLocalizations.of(context)!.backToRecipes),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _confirmMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.addToMealPlanAction,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  final String displayName;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.displayName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Text(
          displayName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

void showMealConfirmationModal({
  required BuildContext context,
  required Recipe recipe,
  required TimeOfDay selectedTime,
  required DateTime date,
  required Function(MealSlot) onConfirm,
  VoidCallback? onBackToRecipes,
  VoidCallback? onBackToTime,
  Function(TimeOfDay, Function(TimeOfDay))? onTimeChangeRequest,
  int defaultServings = 4,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MealConfirmationModal(
      recipe: recipe,
      selectedTime: selectedTime,
      date: date,
      onConfirm: onConfirm,
      onBackToRecipes: onBackToRecipes,
      onBackToTime: onBackToTime,
      onTimeChangeRequest: onTimeChangeRequest,
      defaultServings: defaultServings,
    ),
  );
}
