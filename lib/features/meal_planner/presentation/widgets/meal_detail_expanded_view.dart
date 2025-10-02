import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/optimized_cached_image.dart';
import '../../../recipes/data/repositories/recipes_repository_impl.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../../recipes/domain/repositories/recipes_repository.dart';
import '../../domain/models/meal_slot.dart';
import 'time_picker_modal.dart';

class MealDetailExpandedView extends StatefulWidget {
  final MealSlot mealSlot;
  final DateTime date;
  final Function(MealSlot)? onMealUpdated;
  final Function(MealSlot)? onMealDeleted;
  final VoidCallback? onViewRecipe;

  const MealDetailExpandedView({
    super.key,
    required this.mealSlot,
    required this.date,
    this.onMealUpdated,
    this.onMealDeleted,
    this.onViewRecipe,
  });

  @override
  State<MealDetailExpandedView> createState() => _MealDetailExpandedViewState();
}

class _MealDetailExpandedViewState extends State<MealDetailExpandedView> {
  late MealSlot currentMeal;
  int servingSize = 1;
  Recipe? _recipe;
  bool _isLoadingRecipe = false;
  late final RecipesRepository _recipesRepository;

  @override
  void initState() {
    super.initState();
    _recipesRepository = RecipesRepositoryImpl();
    currentMeal = widget.mealSlot;
    servingSize = currentMeal.servingSize;
    if (currentMeal.recipeId != null) {
      _loadRecipe();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTimeSection(),
                  const SizedBox(height: 20),
                  _buildServingSection(),
                  const SizedBox(height: 20),
                  if (currentMeal.description != null) ...[
                    _buildDescriptionSection(),
                    const SizedBox(height: 20),
                  ],
                  _buildActionButtons(),
                  const SizedBox(height: 20),
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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildMealInfo()),
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

  Widget _buildMealInfo() {
    final imageUrl = _getMealImageUrl();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null
                ? OptimizedCachedImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    preload: true,
                  )
                : Icon(
                    PhosphorIcons.forkKnife(),
                    color: AppColors.primary,
                    size: 32,
                  ),
          ),
        ),
        const SizedBox(width: 16),
        // Meal details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentMeal.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getMealDisplayName(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return _buildSection(
      title: 'Scheduled Time',
      icon: PhosphorIcons.clock(),
      child: GestureDetector(
        onTap: currentMeal.isLocked ? null : _showTimePicker,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Text(
                currentMeal.displayTime,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (!currentMeal.isLocked)
                Icon(
                  PhosphorIcons.caretRight(),
                  size: 16,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServingSection() {
    return _buildSection(
      title: 'Serving Size',
      icon: PhosphorIcons.users(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Text(
              'Servings:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            _buildServingControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildServingControls() {
    return Row(
      children: [
        _buildServingButton(
          icon: PhosphorIcons.minus(),
          onTap: currentMeal.isLocked || servingSize <= 1
              ? null
              : () => _updateServingSize(servingSize - 1),
        ),
        Container(
          width: 40,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            servingSize.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        _buildServingButton(
          icon: PhosphorIcons.plus(),
          onTap: currentMeal.isLocked || servingSize >= 10
              ? null
              : () => _updateServingSize(servingSize + 1),
        ),
      ],
    );
  }

  Widget _buildServingButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return _buildSection(
      title: 'Notes',
      icon: PhosphorIcons.note(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Text(
          currentMeal.description ?? '',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            if (!currentMeal.isLocked) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showDeleteConfirmation,
                  icon: Icon(PhosphorIcons.trash()),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: Icon(PhosphorIcons.check()),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showTimePicker() {
    showTimePickerModal(
      context: context,
      initialTime: currentMeal.timeOfDay,
      mealCategory: currentMeal.category,
      onTimeSelected: (time) {
        setState(() {
          currentMeal = currentMeal.copyWith(
            scheduledTime: DateTime(
              widget.date.year,
              widget.date.month,
              widget.date.day,
              time.hour,
              time.minute,
            ),
          );
        });
      },
    );
  }

  void _updateServingSize(int newSize) {
    setState(() {
      servingSize = newSize;
      currentMeal = currentMeal.copyWith(servingSize: newSize);
    });
  }

  void _saveChanges() {
    widget.onMealUpdated?.call(currentMeal);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meal updated successfully!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text(
          'Are you sure you want to delete ${_getMealDisplayName()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close expanded view
              widget.onMealDeleted?.call(currentMeal);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
      if (mounted && currentMeal.recipeId == recipeId) {
        setState(() {
          _recipe = recipe;
          _isLoadingRecipe = false;
        });
      }
    } catch (e) {
      if (mounted && currentMeal.recipeId == recipeId) {
        setState(() {
          _isLoadingRecipe = false;
        });
      }
    }
  }

  String _getMealDisplayName() {
    if (currentMeal.customMealName != null &&
        currentMeal.customMealName!.isNotEmpty) {
      return currentMeal.customMealName!;
    }

    if (currentMeal.recipeId != null) {
      if (_isLoadingRecipe) {
        return 'Loading...';
      }
      return _recipe?.title ?? 'Unknown Recipe';
    }

    if (currentMeal.leftoverId != null) {
      return 'Leftover Meal';
    }

    return currentMeal.category;
  }

  String? _getMealImageUrl() {
    if (currentMeal.recipeId != null) {
      return _recipe?.imageUrl;
    }
    return null;
  }
}

// Helper function to show the expanded view
void showMealDetailExpandedView({
  required BuildContext context,
  required MealSlot mealSlot,
  required DateTime date,
  Function(MealSlot)? onMealUpdated,
  Function(MealSlot)? onMealDeleted,
  VoidCallback? onViewRecipe,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MealDetailExpandedView(
      mealSlot: mealSlot,
      date: date,
      onMealUpdated: onMealUpdated,
      onMealDeleted: onMealDeleted,
      onViewRecipe: onViewRecipe,
    ),
  );
}
