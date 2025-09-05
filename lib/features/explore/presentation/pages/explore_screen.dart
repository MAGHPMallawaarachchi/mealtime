import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtime/features/recipes/domain/models/recipe.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/models/user_interaction.dart';
import '../../../recipes/domain/usecases/get_recipes_usecase.dart';
import '../../../recipes/domain/usecases/search_recipes_usecase.dart';
import '../../../recipes/domain/usecases/get_recipes_by_category_usecase.dart';
import '../../../recipes/data/repositories/recipes_repository_impl.dart';
import '../../../pantry/presentation/providers/pantry_providers.dart';
import '../../../recommendations/presentation/widgets/personalized_recipes_grid_section.dart';
import '../../../recommendations/presentation/providers/recommendation_provider.dart';
import '../widgets/explore_search_bar.dart';
import '../widgets/explore_categories_section.dart';
import '../widgets/recipes_grid_section.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../providers/explore_pagination_provider.dart';
import '../utils/pagination_utils.dart';
import '../utils/performance_utils.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String _searchQuery = '';
  List<Recipe> _filteredRecipes = [];
  final Set<String> _favoriteRecipes = <String>{}; // Local-only favorites
  bool _isLoading = true;
  String? _errorMessage;
  late ScrollController _scrollController;
  double _lastScrollOffset = 0;

  // Dependencies
  late final RecipesRepositoryImpl _recipesRepository;
  late final GetRecipesUseCase _getRecipesUseCase;
  late final SearchRecipesUseCase _searchRecipesUseCase;
  late final GetRecipesByCategoryUseCase _getRecipesByCategoryUseCase;

  @override
  void initState() {
    super.initState();
    _scrollController = PerformanceUtils.createOptimizedScrollController();
    _initializeDependencies();
    _loadRecipes();
    _loadFavorites();
    _setupScrollListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeRecommendations();
    });
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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes({bool forceRefresh = false}) async {
    await PerformanceUtils.batchOperation(() async {
      try {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

        final recipes = await _getFilteredRecipes(forceRefresh: forceRefresh);
        final optimizedRecipes = PerformanceUtils.optimizeRecipeList(recipes);

        if (mounted) {
          setState(() {
            _filteredRecipes = optimizedRecipes;
            _isLoading = false;
          });
          
          // Initialize pagination after recipes are loaded
          _updatePagination();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString();
          });
        }
      }
    });
  }

  Future<List<Recipe>> _getFilteredRecipes({bool forceRefresh = false}) async {
    if (_searchQuery.isNotEmpty) {
      // Use search functionality
      return await _searchRecipesUseCase.execute(_searchQuery, forceRefresh: forceRefresh);
    } else if (_selectedCategory != null) {
      // Filter by category
      return await _getRecipesByCategoryUseCase.execute([_selectedCategory!], forceRefresh: forceRefresh);
    } else {
      // Get all recipes
      return await _getRecipesUseCase.execute(forceRefresh: forceRefresh);
    }
  }

  void _initializeRecommendations() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final allRecipes = await _getRecipesUseCase.execute();
    final pantryItems = ref.read(pantryProvider).items;

    await ref.read(recommendationProvider.notifier).generateRecommendations(
      user: currentUser,
      allRecipes: allRecipes,
      pantryItems: pantryItems,
    );
  }

  void _onSearchChanged(String query) {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null && query.isNotEmpty) {
      ref.recordSearchInteraction(
        userId: currentUser.uid,
        query: query,
      );
    }

    setState(() {
      _searchQuery = query;
    });
    _loadRecipes(); // This will now use the async method
    _updatePagination();
  }

  void _onCategorySelected(String? category) {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null && category != null) {
      ref.recordCategoryInteraction(
        userId: currentUser.uid,
        category: category,
      );
    }

    setState(() {
      _selectedCategory = category;
    });
    _loadRecipes(); // This will now use the async method
    _updatePagination();
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

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final currentOffset = _scrollController.offset;
      
      // Optimize scroll event processing
      if (PerformanceUtils.shouldProcessScrollEvent(currentOffset, _lastScrollOffset)) {
        _lastScrollOffset = currentOffset;
        
        if (PaginationUtils.shouldLoadMore(
          currentOffset: currentOffset,
          maxScrollExtent: _scrollController.position.maxScrollExtent,
        )) {
          _loadMoreRecipes();
        }
        
        // Periodic memory optimization
        if (currentOffset % 5000 < 50) { // Every ~5000px of scrolling
          PerformanceUtils.optimizeMemoryUsage();
        }
      }
    });
  }

  Future<void> _loadMoreRecipes() async {
    await ref.read(explorePaginationProvider.notifier).loadNextPage();
  }

  void _updatePagination() {
    final filteredRecipes = PaginationUtils.applyFiltering(
      allRecipes: _filteredRecipes,
      searchQuery: _searchQuery,
      selectedCategory: _selectedCategory,
    );
    
    debugPrint('ExploreScreen: _updatePagination called with ${filteredRecipes.length} recipes');
    
    // Initialize pagination if this is the first time or update with new filtered recipes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (filteredRecipes.isNotEmpty) {
        debugPrint('ExploreScreen: Initializing pagination with ${filteredRecipes.length} recipes');
        ref.read(explorePaginationProvider.notifier).loadInitialRecipes(filteredRecipes);
      } else {
        debugPrint('ExploreScreen: No filtered recipes to initialize pagination with');
      }
    });
  }

  Future<void> _refreshData() async {
    // Refresh recipes and recommendations
    await _loadRecipes(forceRefresh: true);
    
    // Refresh recommendations if user is available
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      final allRecipes = await _getRecipesUseCase.execute(forceRefresh: true);
      final pantryItems = ref.read(pantryProvider).items;
      
      await ref.read(recommendationProvider.notifier).generateRecommendations(
        user: currentUser,
        allRecipes: allRecipes,
        pantryItems: pantryItems,
        forceRefresh: true,
      );
    }
    
    // Refresh pagination
    _updatePagination();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: _buildBody(),
        ),
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

    return CustomScrollView(
      controller: _scrollController,
      physics: PerformanceUtils.getOptimizedScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 12),
              ExploreSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Search recipes, ingredients...',
              ),
              const SizedBox(height: 20),
              ExploreCategoriesSection(
                selectedCategory: _selectedCategory,
                onCategorySelected: _onCategorySelected,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: PersonalizedRecipesGridSection(
              allRecipes: _filteredRecipes,
              selectedCategory: _selectedCategory,
              searchQuery: _searchQuery,
              favoriteRecipes: _favoriteRecipes,
              onFavoriteToggle: _onFavoriteToggle,
              onAddToMealPlan: _onAddToMealPlan,
              onLoadMore: _loadMoreRecipes,
              enablePagination: true,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
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
        ),
      ],
    );
  }
}
