import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/recipes_repository_impl.dart';
import '../../domain/usecases/get_recipes_by_ingredient_usecase.dart';
import '../../domain/models/recipe.dart';

// Repository provider
final seasonalIngredientRecipesRepositoryProvider = Provider<RecipesRepositoryImpl>((ref) {
  return RecipesRepositoryImpl();
});

// Use case provider
final getRecipesByIngredientUseCaseProvider = Provider<GetRecipesByIngredientUseCase>((ref) {
  final repository = ref.read(seasonalIngredientRecipesRepositoryProvider);
  return GetRecipesByIngredientUseCase(repository);
});

// State for seasonal ingredient recipes
class SeasonalIngredientRecipesState {
  final List<Recipe> recipes;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final int totalCount;
  final String ingredientName;

  const SeasonalIngredientRecipesState({
    this.recipes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = false,
    this.currentPage = 0,
    this.totalCount = 0,
    this.ingredientName = '',
  });

  SeasonalIngredientRecipesState copyWith({
    List<Recipe>? recipes,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
    String? ingredientName,
  }) {
    return SeasonalIngredientRecipesState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      ingredientName: ingredientName ?? this.ingredientName,
    );
  }
}

// Notifier for managing seasonal ingredient recipes state
class SeasonalIngredientRecipesNotifier extends StateNotifier<SeasonalIngredientRecipesState> {
  final GetRecipesByIngredientUseCase _getRecipesByIngredientUseCase;
  static const int _pageSize = 20;

  SeasonalIngredientRecipesNotifier(this._getRecipesByIngredientUseCase) 
    : super(const SeasonalIngredientRecipesState());

  Future<void> loadRecipes(String ingredientName, {bool forceRefresh = false}) async {
    if (state.ingredientName != ingredientName || forceRefresh) {
      // Reset state for new ingredient or refresh
      state = SeasonalIngredientRecipesState(
        isLoading: true,
        ingredientName: ingredientName,
      );
    } else if (state.recipes.isNotEmpty && !state.isLoading) {
      // Data already loaded and not refreshing
      return;
    } else {
      // Set loading state for same ingredient
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final pagination = await _getRecipesByIngredientUseCase.execute(
        ingredientName,
        page: 1,
        limit: _pageSize,
        forceRefresh: forceRefresh,
      );
      
      state = state.copyWith(
        recipes: pagination.recipes,
        isLoading: false,
        hasMore: pagination.hasMore,
        currentPage: 1,
        totalCount: pagination.totalCount,
        error: null,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreRecipes() async {
    if (state.isLoadingMore || !state.hasMore || state.ingredientName.isEmpty) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      
      final pagination = await _getRecipesByIngredientUseCase.execute(
        state.ingredientName,
        page: nextPage,
        limit: _pageSize,
      );
      
      final allRecipes = [...state.recipes, ...pagination.recipes];
      
      state = state.copyWith(
        recipes: allRecipes,
        isLoadingMore: false,
        hasMore: pagination.hasMore,
        currentPage: nextPage,
        totalCount: pagination.totalCount,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    if (state.ingredientName.isNotEmpty) {
      await loadRecipes(state.ingredientName, forceRefresh: true);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const SeasonalIngredientRecipesState();
  }
}

// Main provider for seasonal ingredient recipes
final seasonalIngredientRecipesProvider = StateNotifierProvider<
    SeasonalIngredientRecipesNotifier, SeasonalIngredientRecipesState>((ref) {
  final getRecipesByIngredientUseCase = ref.read(getRecipesByIngredientUseCaseProvider);
  return SeasonalIngredientRecipesNotifier(getRecipesByIngredientUseCase);
});