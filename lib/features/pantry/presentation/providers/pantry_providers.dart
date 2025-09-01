import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';
import '../../../recipes/data/repositories/recipes_repository_impl.dart';
import '../../../user_recipes/data/repositories/user_recipes_repository_impl.dart';
import '../../data/repositories/pantry_repository_impl.dart';
import '../../domain/usecases/get_pantry_items_usecase.dart';
import '../../domain/usecases/add_pantry_item_usecase.dart';
import '../../domain/usecases/update_pantry_item_usecase.dart';
import '../../domain/usecases/delete_pantry_item_usecase.dart';
import '../../domain/usecases/search_ingredients_usecase.dart';
import '../../domain/usecases/get_recipe_matches_usecase.dart';
import '../../domain/usecases/add_starter_kit_usecase.dart';
import '../../domain/models/pantry_item.dart';
import '../../domain/models/recipe_match.dart';

// Repository providers
final pantryRepositoryProvider = Provider<PantryRepositoryImpl>((ref) {
  return PantryRepositoryImpl();
});

final recipesRepositoryProvider = Provider<RecipesRepositoryImpl>((ref) {
  return RecipesRepositoryImpl();
});

final userRecipesRepositoryProvider = Provider<UserRecipesRepositoryImpl>((ref) {
  return UserRecipesRepositoryImpl();
});

// Use case providers
final getPantryItemsUseCaseProvider = Provider<GetPantryItemsUseCase>((ref) {
  final repository = ref.read(pantryRepositoryProvider);
  return GetPantryItemsUseCase(repository);
});

final addPantryItemUseCaseProvider = Provider<AddPantryItemUseCase>((ref) {
  final repository = ref.read(pantryRepositoryProvider);
  return AddPantryItemUseCase(repository);
});

final updatePantryItemUseCaseProvider = Provider<UpdatePantryItemUseCase>((ref) {
  final repository = ref.read(pantryRepositoryProvider);
  return UpdatePantryItemUseCase(repository);
});

final deletePantryItemUseCaseProvider = Provider<DeletePantryItemUseCase>((ref) {
  final repository = ref.read(pantryRepositoryProvider);
  return DeletePantryItemUseCase(repository);
});

final searchIngredientsUseCaseProvider = Provider<SearchIngredientsUseCase>((ref) {
  final repository = ref.read(pantryRepositoryProvider);
  return SearchIngredientsUseCase(repository);
});

final getRecipeMatchesUseCaseProvider = Provider<GetRecipeMatchesUseCase>((ref) {
  final pantryRepository = ref.read(pantryRepositoryProvider);
  final recipesRepository = ref.read(recipesRepositoryProvider);
  final userRecipesRepository = ref.read(userRecipesRepositoryProvider);
  
  return GetRecipeMatchesUseCase(
    pantryRepository: pantryRepository,
    recipesRepository: recipesRepository,
    userRecipesRepository: userRecipesRepository,
  );
});

final addStarterKitUseCaseProvider = Provider<AddStarterKitUseCase>((ref) {
  final repository = ref.read(pantryRepositoryProvider);
  return AddStarterKitUseCase(repository);
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Pantry state
class PantryState {
  final List<PantryItem> items;
  final bool isLoading;
  final String? error;
  final Map<PantryCategory, List<PantryItem>> itemsByCategory;

  const PantryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.itemsByCategory = const {},
  });

  PantryState copyWith({
    List<PantryItem>? items,
    bool? isLoading,
    String? error,
    Map<PantryCategory, List<PantryItem>>? itemsByCategory,
  }) {
    return PantryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      itemsByCategory: itemsByCategory ?? this.itemsByCategory,
    );
  }
}

// Pantry state notifier
class PantryNotifier extends StateNotifier<PantryState> {
  final GetPantryItemsUseCase _getPantryItemsUseCase;
  final AddPantryItemUseCase _addPantryItemUseCase;
  final UpdatePantryItemUseCase _updatePantryItemUseCase;
  final DeletePantryItemUseCase _deletePantryItemUseCase;
  final AddStarterKitUseCase _addStarterKitUseCase;
  final AuthService _authService;
  
  StreamSubscription<List<PantryItem>>? _pantrySubscription;

  PantryNotifier(
    this._getPantryItemsUseCase,
    this._addPantryItemUseCase,
    this._updatePantryItemUseCase,
    this._deletePantryItemUseCase,
    this._addStarterKitUseCase,
    this._authService,
  ) : super(const PantryState());

  String? get _currentUserId => _authService.currentUser?.uid;

  @override
  void dispose() {
    _pantrySubscription?.cancel();
    super.dispose();
  }

  Future<void> loadPantryItems() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Cancel existing subscription if any
      _pantrySubscription?.cancel();

      // Start listening to real-time updates
      _pantrySubscription = _getPantryItemsUseCase.executeStream(userId).listen(
        (items) {
          final itemsByCategory = _groupItemsByCategory(items);
          state = state.copyWith(
            items: items,
            isLoading: false,
            error: null,
            itemsByCategory: itemsByCategory,
          );
        },
        onError: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.toString(),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<String?> addPantryItem({
    required String name,
    required PantryCategory category,
    List<String>? tags,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final itemId = await _addPantryItemUseCase.executeWithDetails(
        userId: userId,
        name: name,
        category: category,
        tags: tags,
      );
      
      // State will be updated via stream
      return itemId;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> updatePantryItem(PantryItem item) async {
    try {
      await _updatePantryItemUseCase.execute(item);
      // State will be updated via stream
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deletePantryItem(String itemId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _deletePantryItemUseCase.execute(userId, itemId);
      // State will be updated via stream
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearAllItems() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _deletePantryItemUseCase.executeAll(userId);
      // State will be updated via stream
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<List<String>> addStarterKit() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final addedIngredients = await _addStarterKitUseCase.execute(userId);
      // State will be updated via stream
      return addedIngredients;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      throw Exception(e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Map<PantryCategory, List<PantryItem>> _groupItemsByCategory(List<PantryItem> items) {
    final Map<PantryCategory, List<PantryItem>> grouped = {};
    
    for (final item in items) {
      if (grouped[item.category] == null) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }
    
    // Sort items within each category alphabetically
    for (final category in grouped.keys) {
      grouped[category]!.sort((a, b) => a.name.compareTo(b.name));
    }
    
    return grouped;
  }
}

// Main pantry provider
final pantryProvider = StateNotifierProvider<PantryNotifier, PantryState>((ref) {
  final getPantryItemsUseCase = ref.read(getPantryItemsUseCaseProvider);
  final addPantryItemUseCase = ref.read(addPantryItemUseCaseProvider);
  final updatePantryItemUseCase = ref.read(updatePantryItemUseCaseProvider);
  final deletePantryItemUseCase = ref.read(deletePantryItemUseCaseProvider);
  final addStarterKitUseCase = ref.read(addStarterKitUseCaseProvider);
  final authService = ref.read(authServiceProvider);

  return PantryNotifier(
    getPantryItemsUseCase,
    addPantryItemUseCase,
    updatePantryItemUseCase,
    deletePantryItemUseCase,
    addStarterKitUseCase,
    authService,
  );
});

// Recipe matches state
class RecipeMatchesState {
  final List<RecipeMatch> matches;
  final bool isLoading;
  final String? error;

  const RecipeMatchesState({
    this.matches = const [],
    this.isLoading = false,
    this.error,
  });

  RecipeMatchesState copyWith({
    List<RecipeMatch>? matches,
    bool? isLoading,
    String? error,
  }) {
    return RecipeMatchesState(
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Recipe matches notifier
class RecipeMatchesNotifier extends StateNotifier<RecipeMatchesState> {
  final GetRecipeMatchesUseCase _getRecipeMatchesUseCase;
  final AuthService _authService;

  RecipeMatchesNotifier(
    this._getRecipeMatchesUseCase,
    this._authService,
  ) : super(const RecipeMatchesState());

  String? get _currentUserId => _authService.currentUser?.uid;

  Future<void> loadRecipeMatches({
    MatchType? minMatchType,
    int? limit,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final matches = await _getRecipeMatchesUseCase.execute(
        userId,
        minMatchType: minMatchType,
        limit: limit,
      );

      state = state.copyWith(
        matches: matches,
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

  void clearError() {
    state = state.copyWith(error: null);
  }

  List<RecipeMatch> getMatchesByType(MatchType matchType) {
    return state.matches.where((match) => match.matchType == matchType).toList();
  }

  List<RecipeMatch> getCompleteMatches() => getMatchesByType(MatchType.complete);
  List<RecipeMatch> getPartialMatches() => getMatchesByType(MatchType.partial);
  List<RecipeMatch> getMinimalMatches() => getMatchesByType(MatchType.minimal);
}

// Recipe matches provider
final recipeMatchesProvider = StateNotifierProvider<RecipeMatchesNotifier, RecipeMatchesState>((ref) {
  final getRecipeMatchesUseCase = ref.read(getRecipeMatchesUseCaseProvider);
  final authService = ref.read(authServiceProvider);

  return RecipeMatchesNotifier(
    getRecipeMatchesUseCase,
    authService,
  );
});

// Ingredient search provider
final ingredientSearchProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  final searchUseCase = ref.read(searchIngredientsUseCaseProvider);
  return await searchUseCase.execute(query, limit: 15);
});

// Helper providers
final pantryItemCountProvider = Provider<int>((ref) {
  final pantryState = ref.watch(pantryProvider);
  return pantryState.items.length;
});

final pantryItemsByCategoryProvider = Provider<Map<PantryCategory, List<PantryItem>>>((ref) {
  final pantryState = ref.watch(pantryProvider);
  return pantryState.itemsByCategory;
});

final recipeMatchCountProvider = Provider<int>((ref) {
  final recipeMatchesState = ref.watch(recipeMatchesProvider);
  return recipeMatchesState.matches.length;
});