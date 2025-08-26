import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../domain/models/user_recipe.dart';
import '../providers/user_recipes_providers.dart';
import '../widgets/recipe_form.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Create Recipe',
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RecipeForm(
              onSave: _handleSave,
              onCancel: () => context.pop(),
              isLoading: _isLoading,
            ),
    );
  }

  Future<void> _handleSave(UserRecipe recipe) async {
    setState(() => _isLoading = true);

    try {
      final recipeId = await ref.read(userRecipesProvider.notifier).createUserRecipe(recipe);
      
      if (recipeId != null && mounted) {
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
                const Text('Recipe created successfully!'),
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
      } else if (mounted) {
        throw Exception('Failed to create recipe');
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