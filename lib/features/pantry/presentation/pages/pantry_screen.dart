import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/pantry_item.dart';
import '../providers/pantry_providers.dart';
import '../widgets/pantry_category_section.dart';
import '../widgets/add_ingredient_modal.dart';
import '../widgets/recipe_matches_section.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final Map<PantryCategory, bool> _expandedCategories = {};
  bool _showRecipeMatches = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pantryProvider.notifier).loadPantryItems();
    });
  }

  void _showAddIngredientModal({PantryItem? editingItem}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddIngredientModal(editingItem: editingItem),
    );
  }

  void _showDeleteConfirmation(PantryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Ingredient'),
        content: Text(
          'Are you sure you want to remove "${item.name}" from your pantry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(pantryProvider.notifier).deletePantryItem(item.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleCategoryExpansion(PantryCategory category) {
    setState(() {
      _expandedCategories[category] = !(_expandedCategories[category] ?? false);
    });
  }

  bool _isCategoryExpanded(PantryCategory category) {
    return _expandedCategories[category] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final pantryState = ref.watch(pantryProvider);
    final pantryItemCount = ref.watch(pantryItemCountProvider);
    final recipeMatchCount = ref.watch(recipeMatchCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.jar(),
                        size: 32,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'My Pantry',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      // Recipe matches toggle
                      if (pantryItemCount > 0)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showRecipeMatches = !_showRecipeMatches;
                            });
                          },
                          icon: PhosphorIcon(
                            _showRecipeMatches
                                ? PhosphorIcons.chefHat()
                                : PhosphorIconsBold.chefHat,
                            size: 24,
                            color: _showRecipeMatches
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),

                      // Add ingredient button
                      IconButton(
                        onPressed: () => _showAddIngredientModal(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PhosphorIcon(
                            PhosphorIcons.plus(),
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Stats
                  Row(
                    children: [
                      _buildStatChip(
                        icon: PhosphorIcons.package(),
                        label: '$pantryItemCount ingredients',
                        color: AppColors.primary,
                      ),
                      if (recipeMatchCount > 0) ...[
                        const SizedBox(width: 12),
                        _buildStatChip(
                          icon: PhosphorIcons.chefHat(),
                          label: '$recipeMatchCount recipes',
                          color: AppColors.success,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(child: _buildContent(pantryState)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PantryState pantryState) {
    if (pantryState.isLoading) {
      return _buildLoadingState();
    }

    if (pantryState.error != null) {
      return _buildErrorState(pantryState.error!);
    }

    if (pantryState.items.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe matches section
          if (_showRecipeMatches) const RecipeMatchesSection(),

          // Pantry items by category
          ...pantryState.itemsByCategory.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;

            return PantryCategorySection(
              category: category,
              items: items,
              isExpanded: _isCategoryExpanded(category),
              onToggleExpanded: () => _toggleCategoryExpansion(category),
              onEditItem: (item) => _showAddIngredientModal(editingItem: item),
              onDeleteItem: _showDeleteConfirmation,
            );
          }),

          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          SizedBox(height: 16),
          Text(
            'Loading your pantry...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.warningCircle(),
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to Load Pantry',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(pantryProvider.notifier).loadPantryItems();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.jar(),
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Pantry is Empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add ingredients to discover recipes you can make with what you have!',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddIngredientModal(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: PhosphorIcon(
                      PhosphorIcons.plus(),
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Add Ingredient',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addStarterKit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: PhosphorIcon(
                      PhosphorIcons.package(),
                      size: 20,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Starter Kit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick add suggestions
            const Text(
              'Quick Add Popular Items:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAddItems.map((item) {
                return GestureDetector(
                  onTap: () =>
                      _quickAddIngredient(item['name']!, item['category']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      item['name']!,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  static const List<Map<String, String>> _quickAddItems = [
    {'name': 'Rice', 'category': 'grains'},
    {'name': 'Coconut', 'category': 'pantryStaples'},
    {'name': 'Onions', 'category': 'vegetables'},
    {'name': 'Garlic', 'category': 'vegetables'},
    {'name': 'Curry Leaves', 'category': 'herbs'},
    {'name': 'Turmeric', 'category': 'spices'},
    {'name': 'Chili Powder', 'category': 'spices'},
    {'name': 'Coconut Oil', 'category': 'oils'},
  ];

  Future<void> _quickAddIngredient(String name, String categoryName) async {
    try {
      final category = PantryCategory.values.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => PantryCategory.other,
      );

      await ref
          .read(pantryProvider.notifier)
          .addPantryItem(name: name, category: category);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add $name: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _addStarterKit() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      final addedIngredients = await ref
          .read(pantryProvider.notifier)
          .addStarterKit();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.checkCircle(),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Added ${addedIngredients.length} essential Sri Lankan ingredients!',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.xCircle(),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(e.toString().replaceAll('Exception: ', '')),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
