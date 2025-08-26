import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../domain/models/user_recipe.dart';

class RecipeForm extends StatefulWidget {
  final UserRecipe? initialRecipe;
  final Function(UserRecipe) onSave;
  final VoidCallback onCancel;
  final bool isLoading;

  const RecipeForm({
    super.key,
    this.initialRecipe,
    required this.onSave,
    required this.onCancel,
    this.isLoading = false,
  });

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;
  late final TextEditingController _servingsController;

  DifficultyLevel _difficulty = DifficultyLevel.medium;
  List<RecipeIngredient> _ingredients = [];
  List<String> _instructions = [];
  List<String> _tags = [];
  String? _imageUrl;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final recipe = widget.initialRecipe;
    _titleController = TextEditingController(text: recipe?.title ?? '');
    _descriptionController = TextEditingController(
      text: recipe?.description ?? '',
    );
    _prepTimeController = TextEditingController(text: recipe?.prepTime ?? '');
    _cookTimeController = TextEditingController(text: recipe?.cookTime ?? '');
    _servingsController = TextEditingController(
      text: recipe?.servings.toString() ?? '4',
    );

    if (recipe != null) {
      _difficulty = recipe.difficulty;
      _ingredients = List.from(recipe.ingredients);
      _instructions = recipe.instructionSections.isNotEmpty
          ? recipe.instructionSections
                .expand((section) => section.steps)
                .toList()
          : [];
      _tags = List.from(recipe.tags);
      _imageUrl = recipe.imageUrl;
    }

    if (_ingredients.isEmpty) {
      _ingredients.add(
        RecipeIngredient(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '',
          quantity: 1.0,
        ),
      );
    }

    if (_instructions.isEmpty) {
      _instructions.add('');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildPhotoSection(),
            const SizedBox(height: 24),
            _buildIngredientsSection(),
            const SizedBox(height: 24),
            _buildInstructionsSection(),
            const SizedBox(height: 24),
            _buildTagsSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Recipe Title *',
                prefixIcon: PhosphorIcon(PhosphorIcons.forkKnife()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a recipe title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: PhosphorIcon(PhosphorIcons.textT()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    decoration: InputDecoration(
                      labelText: 'Time *',
                      prefixIcon: PhosphorIcon(PhosphorIcons.clock()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'e.g., 15 min',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    decoration: InputDecoration(
                      labelText: 'Servings *',
                      prefixIcon: PhosphorIcon(PhosphorIcons.users()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 1) {
                        return 'Must be a positive number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recipe Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a photo to make your recipe more appealing',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null || _imageUrl != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : _imageUrl != null
                      ? Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade100,
                              child: const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : const SizedBox(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: PhosphorIcon(PhosphorIcons.camera()),
                      label: const Text('Change Photo'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _removeImage,
                    icon: PhosphorIcon(PhosphorIcons.trash()),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.camera(),
                        size: 48,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add a photo',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose from camera or gallery',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addIngredient,
                  icon: PhosphorIcon(PhosphorIcons.plus()),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;
              return _buildIngredientField(index, ingredient);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientField(int index, RecipeIngredient ingredient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: TextFormField(
              initialValue: ingredient.quantity.toString(),
              decoration: InputDecoration(
                labelText: 'Qty',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) {
                final quantity = double.tryParse(value) ?? 1.0;
                _updateIngredient(
                  index,
                  ingredient.copyWith(quantity: quantity),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: ingredient.name,
              decoration: InputDecoration(
                labelText: 'Ingredient',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
              onChanged: (value) {
                _updateIngredient(index, ingredient.copyWith(name: value));
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _ingredients.length > 1
                ? () => _removeIngredient(index)
                : null,
            icon: PhosphorIcon(PhosphorIcons.trash()),
            style: IconButton.styleFrom(
              foregroundColor: _ingredients.length > 1
                  ? Colors.red
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addInstruction,
                  icon: PhosphorIcon(PhosphorIcons.plus()),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._instructions.asMap().entries.map((entry) {
              final index = entry.key;
              final instruction = entry.value;
              return _buildInstructionField(index, instruction);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionField(int index, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: instruction,
              decoration: InputDecoration(
                labelText: 'Step ${index + 1}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter instruction for step ${index + 1}';
                }
                return null;
              },
              onChanged: (value) {
                setState(() => _instructions[index] = value);
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _instructions.length > 1
                ? () => _removeInstruction(index)
                : null,
            icon: PhosphorIcon(PhosphorIcons.trash()),
            style: IconButton.styleFrom(
              foregroundColor: _instructions.length > 1
                  ? Colors.red
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tags (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add tags to help categorize your recipe',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._tags.map((tag) => _buildTagChip(tag)),
                _buildAddTagChip(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: PhosphorIcon(PhosphorIcons.x(), size: 16),
      onDeleted: () {
        setState(() => _tags.remove(tag));
      },
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: const TextStyle(color: AppColors.primary),
    );
  }

  Widget _buildAddTagChip() {
    return ActionChip(
      label: const Text('Add Tag'),
      avatar: PhosphorIcon(PhosphorIcons.plus(), size: 16),
      onPressed: _showAddTagDialog,
      backgroundColor: Colors.grey.withOpacity(0.1),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.isLoading ? null : widget.onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Recipe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(
        RecipeIngredient(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '',
          quantity: 1.0,
        ),
      );
    });
  }

  void _updateIngredient(int index, RecipeIngredient ingredient) {
    setState(() {
      _ingredients[index] = ingredient;
    });
  }

  void _removeIngredient(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  void _addInstruction() {
    setState(() => _instructions.add(''));
  }

  void _removeInstruction(int index) {
    setState(() => _instructions.removeAt(index));
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageUrl = null; // Clear existing URL when selecting new image
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
    });
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: const Text('Choose where to get your recipe photo from:'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            icon: PhosphorIcon(PhosphorIcons.camera()),
            label: const Text('Camera'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            icon: PhosphorIcon(PhosphorIcons.image()),
            label: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tag name',
            hintText: 'e.g., vegetarian, spicy, quick',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final tag = controller.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() => _tags.add(tag));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    final prepTime = _prepTimeController.text.trim();
    final cookTime = _cookTimeController.text.trim();
    final totalTime = _calculateTotalTime(prepTime, cookTime);

    final now = DateTime.now();
    final recipe = UserRecipe(
      id: widget.initialRecipe?.id ?? '',
      userId: userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      prepTime: prepTime,
      cookTime: cookTime,
      totalTime: totalTime,
      servings: int.parse(_servingsController.text),
      difficulty: _difficulty,
      ingredients: _ingredients.where((i) => i.name.trim().isNotEmpty).toList(),
      ingredientSections: [],
      instructionSections: [
        InstructionSection(
          id: '1',
          title: 'Instructions',
          steps: _instructions.where((i) => i.trim().isNotEmpty).toList(),
        ),
      ],
      tags: _tags,
      imageUrl: _selectedImage?.path ?? _imageUrl,
      createdAt: widget.initialRecipe?.createdAt ?? now,
      updatedAt: now,
    );

    widget.onSave(recipe);
  }

  String _calculateTotalTime(String prepTime, String cookTime) {
    try {
      final prepMinutes = _parseTimeToMinutes(prepTime);
      final cookMinutes = _parseTimeToMinutes(cookTime);
      final totalMinutes = prepMinutes + cookMinutes;

      if (totalMinutes >= 60) {
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        if (minutes == 0) {
          return '${hours}h';
        }
        return '${hours}h ${minutes}min';
      }

      return '${totalMinutes}min';
    } catch (e) {
      return '$prepTime + $cookTime';
    }
  }

  int _parseTimeToMinutes(String timeStr) {
    final cleaned = timeStr.toLowerCase().replaceAll(RegExp(r'[^0-9h\s]'), '');

    if (cleaned.contains('h')) {
      final parts = cleaned.split('h');
      final hours = int.tryParse(parts[0].trim()) ?? 0;
      final minutesPart = parts.length > 1 ? parts[1].trim() : '0';
      final minutes = int.tryParse(minutesPart) ?? 0;
      return hours * 60 + minutes;
    }

    return int.tryParse(cleaned.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
}
