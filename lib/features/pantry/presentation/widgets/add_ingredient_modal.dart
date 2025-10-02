import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtime/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/pantry_item.dart';
import '../providers/pantry_providers.dart';
import '../../data/sri_lankan_ingredients.dart';

class AddIngredientModal extends ConsumerStatefulWidget {
  final PantryItem? editingItem;

  const AddIngredientModal({super.key, this.editingItem});

  @override
  ConsumerState<AddIngredientModal> createState() => _AddIngredientModalState();
}

class _AddIngredientModalState extends ConsumerState<AddIngredientModal> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  PantryCategory _selectedCategory = PantryCategory.other;
  PantryItemType _selectedType = PantryItemType.ingredient;
  List<String> _tags = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();

    if (widget.editingItem != null) {
      _nameController.text = widget.editingItem!.name;
      _selectedCategory = widget.editingItem!.category;
      _selectedType = widget.editingItem!.type;
      _tags = List.from(widget.editingItem!.tags);
    }

    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final query = _nameController.text.trim();
    if (query.isNotEmpty && query.length >= 2) {
      _loadSuggestions(query);
    } else {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  Future<void> _loadSuggestions(String query) async {
    try {
      final searchUseCase = ref.read(searchIngredientsUseCaseProvider);
      final suggestions = await searchUseCase.execute(query, limit: 8);

      if (mounted &&
          _nameController.text.trim().toLowerCase() == query.toLowerCase()) {
        setState(() {
          _suggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
        });
      }
    } catch (e) {
      // Ignore search errors
    }
  }

  void _selectSuggestion(String suggestion) {
    _nameController.text = suggestion;
    _autoSelectCategory(suggestion);
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
    _nameFocusNode.unfocus();
  }

  void _autoSelectCategory(String ingredientName) {
    // Use Sri Lankan ingredients database for smart categorization
    final category = SriLankanIngredients.getCategoryForIngredient(
      ingredientName,
    );
    if (category != null) {
      setState(() {
        _selectedCategory = category;
      });
    }
  }

  String _getItemTypeDisplayName(BuildContext context, PantryItemType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case PantryItemType.ingredient:
        return l10n.ingredient;
      case PantryItemType.leftover:
        return l10n.leftover;
    }
  }

  String _getCategoryDisplayName(
    BuildContext context,
    PantryCategory category,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case PantryCategory.vegetables:
        return l10n.vegetables;
      case PantryCategory.fruits:
        return l10n.fruits;
      case PantryCategory.grains:
        return l10n.grainsRice;
      case PantryCategory.proteins:
        return l10n.meatFish;
      case PantryCategory.dairy:
        return l10n.dairy;
      case PantryCategory.spices:
        return l10n.spices;
      case PantryCategory.condiments:
        return l10n.oilsCondiments;
      case PantryCategory.oils:
        return l10n.oilsCondiments;
      case PantryCategory.herbs:
        return l10n.spices;
      case PantryCategory.pantryStaples:
        return l10n.other;
      case PantryCategory.frozen:
        return l10n.other;
      case PantryCategory.beverages:
        return l10n.beverages;
      case PantryCategory.other:
        return l10n.other;
    }
  }

  Future<void> _saveIngredient() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = l10n.pleaseEnterItemName;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pantryNotifier = ref.read(pantryProvider.notifier);

      if (widget.editingItem != null) {
        // Update existing item
        final updatedItem = widget.editingItem!.copyWith(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          type: _selectedType,
          tags: _tags,
          updatedAt: DateTime.now(),
        );

        await pantryNotifier.updatePantryItem(updatedItem);
      } else {
        // Add new item
        await pantryNotifier.addPantryItem(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          type: _selectedType,
          tags: _tags,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.editingItem != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing
                        ? l10n.editItem(
                            _getItemTypeDisplayName(
                              context,
                              widget.editingItem!.type,
                            ),
                          )
                        : l10n.addItem(
                            _getItemTypeDisplayName(context, _selectedType),
                          ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
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
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.warningCircle(),
                            color: AppColors.error,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Type selection
                  Text(
                    l10n.itemType,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: PantryItemType.values.map((type) {
                        final isSelected = type == _selectedType;
                        final color = type == PantryItemType.leftover
                            ? AppColors.leftover
                            : AppColors.primary;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedType = type;
                                // Reset category when switching to leftover (no categories for leftovers)
                                if (type == PantryItemType.leftover) {
                                  _selectedCategory = PantryCategory.other;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? color : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    type.emoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getItemTypeDisplayName(context, type),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Item name
                  Text(
                    l10n.itemNameLabel(
                      _getItemTypeDisplayName(context, _selectedType),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Stack(
                    children: [
                      TextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        decoration: InputDecoration(
                          hintText: l10n.enterItemName(
                            _getItemTypeDisplayName(
                              context,
                              _selectedType,
                            ).toLowerCase(),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _saveIngredient(),
                      ),

                      // Suggestions dropdown
                      if (_showSuggestions && _suggestions.isNotEmpty)
                        Positioned(
                          top: 60,
                          left: 0,
                          right: 0,
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _suggestions.length,
                                itemBuilder: (context, index) {
                                  final suggestion = _suggestions[index];
                                  return ListTile(
                                    title: Text(
                                      suggestion,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onTap: () => _selectSuggestion(suggestion),
                                    dense: true,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Category selection (only for ingredients)
                  if (_selectedType == PantryItemType.ingredient) ...[
                    Text(
                      l10n.category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PantryCategory.values.map((category) {
                        final isSelected = category == _selectedCategory;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  category.emoji,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getCategoryDisplayName(context, category),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Save button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveIngredient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing
                            ? l10n.updateItem(
                                _getItemTypeDisplayName(
                                  context,
                                  widget.editingItem!.type,
                                ),
                              )
                            : l10n.addItemAction(
                                _getItemTypeDisplayName(context, _selectedType),
                              ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
