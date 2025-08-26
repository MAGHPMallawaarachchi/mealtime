import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/user_recipe.dart';
import '../providers/user_recipes_providers.dart';
import '../widgets/recipe_form.dart';

class EditRecipeScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const EditRecipeScreen({
    super.key,
    required this.recipeId,
  });

  @override
  ConsumerState<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends ConsumerState<EditRecipeScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final recipe = ref.watch(userRecipeProvider(widget.recipeId));

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Recipe'),
          leading: IconButton(
            icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('Recipe not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Recipe',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.trash()),
            onPressed: () => _showDeleteDialog(recipe),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RecipeForm(
              initialRecipe: recipe,
              onSave: _handleSave,
              onCancel: () => context.pop(),
              isLoading: _isLoading,
            ),
    );
  }

  Future<void> _handleSave(UserRecipe recipe) async {
    setState(() => _isLoading = true);

    try {
      await ref.read(userRecipesProvider.notifier).updateUserRecipe(recipe);
      
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
                const Text('Recipe updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        context.pop();
      }
    } catch (e) {
      if (mounted) {
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
                Text('Error: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteDialog(UserRecipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: PhosphorIcon(
          PhosphorIcons.trash(),
          size: 24,
          color: Colors.red,
        ),
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${recipe.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleDelete(recipe.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(String recipeId) async {
    setState(() => _isLoading = true);

    try {
      await ref.read(userRecipesProvider.notifier).deleteUserRecipe(recipeId);
      
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
                const Text('Recipe deleted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        context.pop();
      }
    } catch (e) {
      if (mounted) {
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
                Text('Error: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}