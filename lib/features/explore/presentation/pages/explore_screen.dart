import 'package:flutter/material.dart';
import 'package:mealtime/features/recipes/domain/models/recipe.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/explore_search_bar.dart';
import '../widgets/featured_recipes_section.dart';
import '../widgets/explore_categories_section.dart';
import '../widgets/recipes_grid_section.dart';
import '../../data/dummy_explore_data.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String _searchQuery = '';
  List<Recipe> _filteredRecipes = [];
  final Set<String> _favoriteRecipes = <String>{};

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRecipes() {
    setState(() {
      _filteredRecipes = _getFilteredRecipes();
    });
  }

  List<Recipe> _getFilteredRecipes() {
    List<Recipe> recipes;

    if (_selectedCategory != null) {
      recipes = DummyExploreData.getRecipesByCategory(_selectedCategory!);
    } else {
      recipes = DummyExploreData.getAllRecipes();
    }

    if (_searchQuery.isNotEmpty) {
      recipes = recipes.where((recipe) {
        return recipe.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            recipe.description?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ==
                true;
      }).toList();
    }

    return recipes;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredRecipes = _getFilteredRecipes();
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      _filteredRecipes = _getFilteredRecipes();
    });
  }

  void _onFavoriteToggle(Recipe recipe) {
    setState(() {
      if (_favoriteRecipes.contains(recipe.id)) {
        _favoriteRecipes.remove(recipe.id);
      } else {
        _favoriteRecipes.add(recipe.id);
      }
    });
  }

  void _onAddToMealPlan(Recipe recipe) {
    // Placeholder implementation - will be connected to actual meal planner later
    // For now, just show a snackbar confirmation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              ExploreSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Search recipes, ingredients...',
              ),
              const SizedBox(height: 20),
              const FeaturedRecipesSection(),
              const SizedBox(height: 24),
              ExploreCategoriesSection(
                selectedCategory: _selectedCategory,
                onCategorySelected: _onCategorySelected,
              ),
              const SizedBox(height: 24),
              RecipesGridSection(
                recipes: _filteredRecipes,
                selectedCategory: _selectedCategory,
                onFavoriteToggle: _onFavoriteToggle,
                onAddToMealPlan: _onAddToMealPlan,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
