import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtime/features/recipes/domain/models/recipe.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../recipes/domain/usecases/get_recipes_usecase.dart';
import '../../../recipes/domain/usecases/search_recipes_usecase.dart';
import '../../../recipes/domain/usecases/get_recipes_by_category_usecase.dart';
import '../../../recipes/data/repositories/recipes_repository_impl.dart';
import '../widgets/explore_search_bar.dart';
import '../widgets/featured_recipes_section.dart';
import '../widgets/explore_categories_section.dart';
import '../widgets/recipes_grid_section.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<State<FeaturedRecipesSection>> _featuredRecipesKey =
      GlobalKey<State<FeaturedRecipesSection>>();
  String? _selectedCategory;
  String _searchQuery = '';
  List<Recipe> _filteredRecipes = [];
  final Set<String> _favoriteRecipes = <String>{}; // Local-only favorites
  bool _isLoading = true;
  String? _errorMessage;

  // Dependencies
  late final RecipesRepositoryImpl _recipesRepository;
  late final GetRecipesUseCase _getRecipesUseCase;
  late final SearchRecipesUseCase _searchRecipesUseCase;
  late final GetRecipesByCategoryUseCase _getRecipesByCategoryUseCase;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _loadRecipes();
    _loadFavorites();
  }

  void _loadFavorites() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesProvider.notifier).loadUserFavorites();
    });
  }

  void _initializeDependencies() {
    _recipesRepository = RecipesRepositoryImpl();
    _getRecipesUseCase = GetRecipesUseCase(_recipesRepository);
    _searchRecipesUseCase = SearchRecipesUseCase(_recipesRepository);
    _getRecipesByCategoryUseCase = GetRecipesByCategoryUseCase(
      _recipesRepository,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final recipes = await _getFilteredRecipes();

      if (mounted) {
        setState(() {
          _filteredRecipes = recipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<List<Recipe>> _getFilteredRecipes() async {
    if (_searchQuery.isNotEmpty) {
      // Use search functionality
      return await _searchRecipesUseCase.execute(_searchQuery);
    } else if (_selectedCategory != null) {
      // Filter by category
      return await _getRecipesByCategoryUseCase.execute([_selectedCategory!]);
    } else {
      // Get all recipes
      return await _getRecipesUseCase.execute();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadRecipes(); // This will now use the async method
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadRecipes(); // This will now use the async method
  }

  void _onFavoriteToggle(Recipe recipe) {
    // Local-only favorite toggle (no backend calls)
    setState(() {
      if (_favoriteRecipes.contains(recipe.id)) {
        _favoriteRecipes.remove(recipe.id);
      } else {
        _favoriteRecipes.add(recipe.id);
      }
    });

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _favoriteRecipes.contains(recipe.id)
              ? '${recipe.title} added to favorites!'
              : '${recipe.title} removed from favorites',
        ),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Undo the favorite toggle
            setState(() {
              if (_favoriteRecipes.contains(recipe.id)) {
                _favoriteRecipes.remove(recipe.id);
              } else {
                _favoriteRecipes.add(recipe.id);
              }
            });
          },
        ),
      ),
    );
  }

  void _onAddToMealPlan(Recipe recipe) {
    // Placeholder implementation - will be connected to actual meal planner later
    // For now, just show a snackbar confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipe.title} added to meal plan'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Force refresh from database to get latest data
    await _recipesRepository.refreshRecipes();

    // Refresh both the main recipes and featured recipes
    await Future.wait([
      _loadRecipes(),
      (_featuredRecipesKey.currentState as FeaturedRecipesSectionController?)
              ?.refreshFeaturedRecipes() ??
          Future.value(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(onRefresh: _refreshData, child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 12),
          ExploreSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            hintText: 'Search recipes, ingredients...',
          ),
          const SizedBox(height: 20),
          FeaturedRecipesSection(key: _featuredRecipesKey),
          const SizedBox(height: 24),
          ExploreCategoriesSection(
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),
          const SizedBox(height: 24),
          RecipesGridSection(
            recipes: _filteredRecipes,
            selectedCategory: _selectedCategory,
            favoriteRecipes: _favoriteRecipes,
            onFavoriteToggle: _onFavoriteToggle,
            onAddToMealPlan: _onAddToMealPlan,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unknown error occurred',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
