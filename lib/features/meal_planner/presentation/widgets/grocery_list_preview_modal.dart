import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/grocery_list.dart';
import '../../domain/models/grocery_item.dart';

class GroceryListPreviewModal extends StatefulWidget {
  final GroceryList initialGroceryList;

  const GroceryListPreviewModal({super.key, required this.initialGroceryList});

  @override
  State<GroceryListPreviewModal> createState() =>
      _GroceryListPreviewModalState();
}

class _GroceryListPreviewModalState extends State<GroceryListPreviewModal> {
  late GroceryList groceryList;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    groceryList = widget.initialGroceryList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (groceryList.isEmpty)
            _buildEmptyState()
          else
            Expanded(child: _buildContent()),
          if (!groceryList.isEmpty) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              PhosphorIcon(
                PhosphorIcons.shoppingCart(),
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.groceryList,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.weekOf(groceryList.dateRange),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: PhosphorIcon(
                  PhosphorIcons.x(),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.shoppingCartSimple(),
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noGroceryItemsGenerated,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.mealPlanNoIngredientsInfo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildEmptyStateSteps(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateSteps() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _buildEmptyStateStep(
            icon: PhosphorIcons.plus(),
            title: AppLocalizations.of(context)!.addRecipeBasedMeals,
            description: AppLocalizations.of(
              context,
            )!.addRecipeBasedMealsDescription,
          ),
          const SizedBox(height: 16),
          _buildEmptyStateStep(
            icon: PhosphorIcons.cookingPot(),
            title: AppLocalizations.of(context)!.ensureRecipesHaveIngredients,
            description: AppLocalizations.of(
              context,
            )!.ensureRecipesHaveIngredientsDescription,
          ),
          const SizedBox(height: 16),
          _buildEmptyStateStep(
            icon: PhosphorIcons.shoppingCart(),
            title: AppLocalizations.of(context)!.generateYourList,
            description: AppLocalizations.of(
              context,
            )!.generateYourListDescription,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: PhosphorIcon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummary(),
          const SizedBox(height: 20),
          ...groceryList.categories.map(_buildCategorySection),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          PhosphorIcon(
            PhosphorIcons.listBullets(),
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.itemsAcrossCategories(
              groceryList.totalItems,
              groceryList.categories.length,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final items = groceryList.getItemsForCategory(category);
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(
                category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildGroceryItem(item, category)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGroceryItem(GroceryItem item, String category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.formattedQuantity,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editItem(item),
                icon: PhosphorIcon(
                  PhosphorIcons.pencil(),
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: const EdgeInsets.all(8),
              ),
              IconButton(
                onPressed: () => _removeItem(item),
                icon: PhosphorIcon(
                  PhosphorIcons.trash(),
                  size: 16,
                  color: AppColors.error,
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _addCustomItem,
              icon: PhosphorIcon(PhosphorIcons.plus()),
              label: Text(AppLocalizations.of(context)!.addItem as String),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportList,
              icon: _isExporting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : PhosphorIcon(PhosphorIcons.export()),
              label: Text(
                _isExporting
                    ? AppLocalizations.of(context)!.exporting
                    : AppLocalizations.of(context)!.export,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editItem(GroceryItem item) {
    showDialog(
      context: context,
      builder: (context) => _EditItemDialog(
        item: item,
        onSave: (updatedItem) {
          setState(() {
            groceryList = groceryList.updateItem(item, updatedItem);
          });
        },
      ),
    );
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      groceryList = groceryList.removeItem(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.itemRemoved(item.name)),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.undo,
          onPressed: () {
            setState(() {
              groceryList = groceryList.addItem(item);
            });
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _addCustomItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onAdd: (newItem) {
          setState(() {
            groceryList = groceryList.addItem(newItem);
          });
        },
      ),
    );
  }

  Future<void> _exportList() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final formattedText = groceryList.toFormattedText();

      // Use share_plus to export
      await Share.share(
        formattedText,
        subject: 'Grocery List (${groceryList.dateRange})',
      );

      // Provide feedback
      if (mounted) {
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
                Text(
                  AppLocalizations.of(context)!.groceryListExportedSuccessfully,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToExport(e.toString()),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}

class _EditItemDialog extends StatefulWidget {
  final GroceryItem item;
  final Function(GroceryItem) onSave;

  const _EditItemDialog({required this.item, required this.onSave});

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  String _selectedCategory = '';

  static const List<String> _categoryKeys = [
    'Vegetables',
    'Fruits',
    'Meat & Fish',
    'Dairy',
    'Grains & Rice',
    'Oils & Condiments',
    'Spices',
    'Other',
  ];

  List<String> get _localizedCategories => [
    AppLocalizations.of(context)!.vegetables,
    AppLocalizations.of(context)!.fruits,
    AppLocalizations.of(context)!.meatFish,
    AppLocalizations.of(context)!.dairy,
    AppLocalizations.of(context)!.grainsRice,
    AppLocalizations.of(context)!.oilsCondiments,
    AppLocalizations.of(context)!.spices,
    AppLocalizations.of(context)!.other,
  ];

  String _getLocalizedCategory(String key) {
    final index = _categoryKeys.indexOf(key);
    return index >= 0 ? _localizedCategories[index] : key;
  }

  String _getCategoryKey(String localizedCategory) {
    final index = _localizedCategories.indexOf(localizedCategory);
    return index >= 0 ? _categoryKeys[index] : localizedCategory;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _unitController = TextEditingController(text: widget.item.unit);
    _selectedCategory = _getLocalizedCategory(widget.item.category);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editItem as String),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.itemName,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.quantity,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.unit,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.category,
            ),
            items: _localizedCategories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _saveItem,
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }

  void _saveItem() {
    if (_nameController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty ||
        _unitController.text.trim().isEmpty) {
      return;
    }

    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      return;
    }

    final updatedItem = GroceryItem(
      ingredientName: _nameController.text.trim(),
      quantity: quantity,
      unit: _unitController.text.trim(),
      category: _getCategoryKey(_selectedCategory),
      displayName: _nameController.text.trim(),
    );

    widget.onSave(updatedItem);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}

class _AddItemDialog extends StatefulWidget {
  final Function(GroceryItem) onAdd;

  const _AddItemDialog({required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitController = TextEditingController(text: 'item');
  late String _selectedCategory;

  static const List<String> _categoryKeys = [
    'Vegetables',
    'Fruits',
    'Meat & Fish',
    'Dairy',
    'Grains & Rice',
    'Oils & Condiments',
    'Spices',
    'Other',
  ];

  List<String> get _localizedCategories => [
    AppLocalizations.of(context)!.vegetables,
    AppLocalizations.of(context)!.fruits,
    AppLocalizations.of(context)!.meatFish,
    AppLocalizations.of(context)!.dairy,
    AppLocalizations.of(context)!.grainsRice,
    AppLocalizations.of(context)!.oilsCondiments,
    AppLocalizations.of(context)!.spices,
    AppLocalizations.of(context)!.other,
  ];

  String _getLocalizedCategory(String key) {
    final index = _categoryKeys.indexOf(key);
    return index >= 0 ? _localizedCategories[index] : key;
  }

  String _getCategoryKey(String localizedCategory) {
    final index = _localizedCategories.indexOf(localizedCategory);
    return index >= 0 ? _categoryKeys[index] : localizedCategory;
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = _getLocalizedCategory('Other');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addItem as String),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.itemName,
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.quantity,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.unit,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.category,
            ),
            items: _localizedCategories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _addItem,
          child: Text(AppLocalizations.of(context)!.add),
        ),
      ],
    );
  }

  void _addItem() {
    if (_nameController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty ||
        _unitController.text.trim().isEmpty) {
      return;
    }

    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      return;
    }

    final newItem = GroceryItem(
      ingredientName: _nameController.text.trim(),
      quantity: quantity,
      unit: _unitController.text.trim(),
      category: _getCategoryKey(_selectedCategory),
      displayName: _nameController.text.trim(),
    );

    widget.onAdd(newItem);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
