import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../data/repositories/recipes_repository_impl.dart';
import '../../domain/usecases/get_recipes_usecase.dart';
import '../../domain/models/recipe.dart';

// Repository provider
final recipesRepositoryProvider = Provider<RecipesRepositoryImpl>((ref) {
  return RecipesRepositoryImpl();
});

// Use case providers
final getRecipesUseCaseProvider = Provider<GetRecipesUseCase>((ref) {
  final repository = ref.read(recipesRepositoryProvider);
  return GetRecipesUseCase(repository);
});

// Recipes state
class RecipesState {
  final List<Recipe> recipes;
  final bool isLoading;
  final String? error;

  const RecipesState({
    this.recipes = const [],
    this.isLoading = false,
    this.error,
  });

  RecipesState copyWith({
    List<Recipe>? recipes,
    bool? isLoading,
    String? error,
  }) {
    return RecipesState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Recipes state notifier
class RecipesNotifier extends StateNotifier<RecipesState> {
  final GetRecipesUseCase _getRecipesUseCase;

  RecipesNotifier(this._getRecipesUseCase) : super(const RecipesState());

  Future<void> loadRecipes() async {
    if (state.recipes.isNotEmpty && !state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final recipes = await _getRecipesUseCase.execute();
      
      state = state.copyWith(
        recipes: recipes,
        isLoading: false,
        error: null,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Recipe? getRecipeById(String recipeId) {
    try {
      return state.recipes.firstWhere((recipe) => recipe.id == recipeId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Main recipes provider
final recipesProvider = StateNotifierProvider<RecipesNotifier, RecipesState>((ref) {
  final getRecipesUseCase = ref.read(getRecipesUseCaseProvider);
  final notifier = RecipesNotifier(getRecipesUseCase);
  
  notifier.loadRecipes();
  
  return notifier;
});

// Helper provider to get a specific recipe
final recipeProvider = Provider.family<Recipe?, String>((ref, recipeId) {
  final recipesState = ref.watch(recipesProvider);
  return recipesState.recipes.cast<Recipe?>().firstWhere(
    (recipe) => recipe?.id == recipeId,
    orElse: () => null,
  );
});