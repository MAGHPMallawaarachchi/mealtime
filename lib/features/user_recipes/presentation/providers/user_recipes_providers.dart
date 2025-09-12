import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/repositories/user_recipes_repository_impl.dart';
import '../../domain/usecases/get_user_recipes_usecase.dart';
import '../../domain/usecases/create_user_recipe_usecase.dart';
import '../../domain/usecases/update_user_recipe_usecase.dart';
import '../../domain/usecases/delete_user_recipe_usecase.dart';
import '../../domain/usecases/get_user_recipe_usecase.dart';
import '../../domain/models/user_recipe.dart';

// Repository provider
final userRecipesRepositoryProvider = Provider<UserRecipesRepositoryImpl>((ref) {
  return UserRecipesRepositoryImpl();
});

// Use case providers
final getUserRecipesUseCaseProvider = Provider<GetUserRecipesUseCase>((ref) {
  final repository = ref.read(userRecipesRepositoryProvider);
  return GetUserRecipesUseCase(repository);
});

final createUserRecipeUseCaseProvider = Provider<CreateUserRecipeUseCase>((ref) {
  final repository = ref.read(userRecipesRepositoryProvider);
  return CreateUserRecipeUseCase(repository);
});

final updateUserRecipeUseCaseProvider = Provider<UpdateUserRecipeUseCase>((ref) {
  final repository = ref.read(userRecipesRepositoryProvider);
  return UpdateUserRecipeUseCase(repository);
});

final deleteUserRecipeUseCaseProvider = Provider<DeleteUserRecipeUseCase>((ref) {
  final repository = ref.read(userRecipesRepositoryProvider);
  return DeleteUserRecipeUseCase(repository);
});

final getUserRecipeUseCaseProvider = Provider<GetUserRecipeUseCase>((ref) {
  final repository = ref.read(userRecipesRepositoryProvider);
  return GetUserRecipeUseCase(repository);
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// User recipes state
class UserRecipesState {
  final List<UserRecipe> recipes;
  final bool isLoading;
  final String? error;

  const UserRecipesState({
    this.recipes = const [],
    this.isLoading = false,
    this.error,
  });

  UserRecipesState copyWith({
    List<UserRecipe>? recipes,
    bool? isLoading,
    String? error,
  }) {
    return UserRecipesState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// User recipes state notifier
class UserRecipesNotifier extends StateNotifier<UserRecipesState> {
  final GetUserRecipesUseCase _getUserRecipesUseCase;
  final CreateUserRecipeUseCase _createUserRecipeUseCase;
  final UpdateUserRecipeUseCase _updateUserRecipeUseCase;
  final DeleteUserRecipeUseCase _deleteUserRecipeUseCase;
  final AuthService _authService;

  UserRecipesNotifier(
    this._getUserRecipesUseCase,
    this._createUserRecipeUseCase,
    this._updateUserRecipeUseCase,
    this._deleteUserRecipeUseCase,
    this._authService,
  ) : super(const UserRecipesState());

  String? get _currentUserId => _authService.currentUser?.uid;

  Future<void> loadUserRecipes() async {
    
    // Wait for auth state to be established if needed
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      
      // Wait for auth state changes for up to 3 seconds
      final authStateCompleter = Completer<User?>();
      late StreamSubscription<User?> subscription;
      
      final timeout = Timer(const Duration(seconds: 3), () {
        if (!authStateCompleter.isCompleted) {
          authStateCompleter.complete(null);
        }
      });
      
      subscription = _authService.authStateChanges.listen((user) {
        if (!authStateCompleter.isCompleted) {
          authStateCompleter.complete(user);
        }
      });
      
      final user = await authStateCompleter.future;
      subscription.cancel();
      timeout.cancel();
      
      if (user == null) {
        state = state.copyWith(recipes: [], error: 'User not authenticated');
        return;
      }
      
    }
    
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      state = state.copyWith(recipes: [], error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final recipes = await _getUserRecipesUseCase.execute(userId);
      
      state = state.copyWith(
        recipes: recipes,
        isLoading: false,
        error: null,
      );
      
    } catch (e) {
      
      // Check if it's a permission error specifically
      if (e.toString().contains('permission-denied')) {
        final errorMsg = 'Permission denied: User $userId cannot access user_recipes. Check authentication and Firestore rules.';
        state = state.copyWith(
          isLoading: false,
          error: errorMsg,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  Future<String?> createUserRecipe(UserRecipe recipe) async {
    final userId = _currentUserId;
    if (userId == null) {
      return null;
    }

    try {
      final recipeId = await _createUserRecipeUseCase.execute(recipe);
      
      // Add the new recipe to state with the generated ID
      final newRecipe = recipe.copyWith(id: recipeId);
      final updatedRecipes = [newRecipe, ...state.recipes];
      
      state = state.copyWith(
        recipes: updatedRecipes,
        error: null,
      );
      
      return recipeId;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> updateUserRecipe(UserRecipe recipe) async {
    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    try {
      await _updateUserRecipeUseCase.execute(recipe);
      
      // Update the recipe in state
      final updatedRecipes = state.recipes.map((r) {
        return r.id == recipe.id ? recipe : r;
      }).toList();
      
      state = state.copyWith(
        recipes: updatedRecipes,
        error: null,
      );
      
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteUserRecipe(String recipeId) async {
    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    try {
      await _deleteUserRecipeUseCase.execute(userId, recipeId);
      
      // Remove the recipe from state
      final updatedRecipes = state.recipes.where((r) => r.id != recipeId).toList();
      
      state = state.copyWith(
        recipes: updatedRecipes,
        error: null,
      );
      
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  UserRecipe? getRecipeById(String recipeId) {
    try {
      return state.recipes.firstWhere((recipe) => recipe.id == recipeId);
    } catch (e) {
      return null;
    }
  }
}

// Main user recipes provider
final userRecipesProvider = StateNotifierProvider<UserRecipesNotifier, UserRecipesState>((ref) {
  final getUserRecipesUseCase = ref.read(getUserRecipesUseCaseProvider);
  final createUserRecipeUseCase = ref.read(createUserRecipeUseCaseProvider);
  final updateUserRecipeUseCase = ref.read(updateUserRecipeUseCaseProvider);
  final deleteUserRecipeUseCase = ref.read(deleteUserRecipeUseCaseProvider);
  final authService = ref.read(authServiceProvider);

  return UserRecipesNotifier(
    getUserRecipesUseCase,
    createUserRecipeUseCase,
    updateUserRecipeUseCase,
    deleteUserRecipeUseCase,
    authService,
  );
});

// Helper provider to get a specific user recipe
final userRecipeProvider = Provider.family<UserRecipe?, String>((ref, recipeId) {
  final userRecipesState = ref.watch(userRecipesProvider);
  return userRecipesState.recipes.cast<UserRecipe?>().firstWhere(
    (recipe) => recipe?.id == recipeId,
    orElse: () => null,
  );
});

// Provider to get user recipes count
final userRecipesCountProvider = Provider<int>((ref) {
  final userRecipesState = ref.watch(userRecipesProvider);
  return userRecipesState.recipes.length;
});