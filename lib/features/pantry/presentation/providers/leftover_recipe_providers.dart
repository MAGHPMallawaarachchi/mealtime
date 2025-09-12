import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../../recipes/presentation/providers/recipes_providers.dart';
import '../../domain/models/pantry_item.dart';
import '../../domain/services/leftover_recipe_matcher.dart';
import 'pantry_providers.dart';

final leftoverRecipeMatcherProvider = Provider<LeftoverRecipeMatcher>((ref) {
  return LeftoverRecipeMatcher();
});

class LeftoverRecipeSuggestionsState {
  final Map<String, List<Recipe>> recipesByLeftoverId;
  final bool isLoading;
  final String? error;

  const LeftoverRecipeSuggestionsState({
    this.recipesByLeftoverId = const {},
    this.isLoading = false,
    this.error,
  });

  LeftoverRecipeSuggestionsState copyWith({
    Map<String, List<Recipe>>? recipesByLeftoverId,
    bool? isLoading,
    String? error,
  }) {
    return LeftoverRecipeSuggestionsState(
      recipesByLeftoverId: recipesByLeftoverId ?? this.recipesByLeftoverId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LeftoverRecipeSuggestionsNotifier extends StateNotifier<LeftoverRecipeSuggestionsState> {
  final LeftoverRecipeMatcher _matcher;
  final Ref _ref;

  LeftoverRecipeSuggestionsNotifier(this._matcher, this._ref) : super(const LeftoverRecipeSuggestionsState());

  Future<void> updateSuggestions() async {
    final pantryState = _ref.read(pantryProvider);
    final recipesState = _ref.read(recipesProvider);

    final leftovers = pantryState.leftoverItems;
    
    if (leftovers.isEmpty) {
      state = state.copyWith(
        recipesByLeftoverId: {},
        isLoading: false,
        error: null,
      );
      return;
    }

    if (recipesState.isLoading) {
      state = state.copyWith(isLoading: true, error: null);
      return;
    }

    if (recipesState.error != null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load recipes: ${recipesState.error}',
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final Map<String, List<Recipe>> recipesByLeftoverId = {};

      for (final leftover in leftovers) {
        final matches = _matcher.findMatchingRecipes(leftover, recipesState.recipes);
        if (matches.isNotEmpty) {
          recipesByLeftoverId[leftover.id] = matches.map((match) => match.recipe).toList();
        }
      }

      state = state.copyWith(
        recipesByLeftoverId: recipesByLeftoverId,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate recipe suggestions: $e',
      );
    }
  }

  List<Recipe> getRecipesForLeftover(String leftoverId) {
    return state.recipesByLeftoverId[leftoverId] ?? [];
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

final leftoverRecipeSuggestionsProvider = StateNotifierProvider<LeftoverRecipeSuggestionsNotifier, LeftoverRecipeSuggestionsState>((ref) {
  final matcher = ref.read(leftoverRecipeMatcherProvider);
  final notifier = LeftoverRecipeSuggestionsNotifier(matcher, ref);

  ref.listen(pantryProvider, (previous, next) {
    if (previous?.leftoverItems != next.leftoverItems) {
      notifier.updateSuggestions();
    }
  });

  ref.listen(recipesProvider, (previous, next) {
    if (previous != next && !next.isLoading) {
      notifier.updateSuggestions();
    }
  });

  Future.microtask(() => notifier.updateSuggestions());

  return notifier;
});

final leftoverRecipesProvider = Provider.family<List<Recipe>, String>((ref, leftoverId) {
  final suggestionsState = ref.watch(leftoverRecipeSuggestionsProvider);
  return suggestionsState.recipesByLeftoverId[leftoverId] ?? [];
});

final hasRecipeSuggestionsProvider = Provider<bool>((ref) {
  final suggestionsState = ref.watch(leftoverRecipeSuggestionsProvider);
  return suggestionsState.recipesByLeftoverId.isNotEmpty;
});

final leftoverRecipeCountProvider = Provider.family<int, String>((ref, leftoverId) {
  final recipes = ref.watch(leftoverRecipesProvider(leftoverId));
  return recipes.length;
});