import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/user_interaction.dart';
import '../../../recommendations/presentation/providers/recommendation_provider.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/usecases/add_to_favorites_usecase.dart';
import '../../domain/usecases/remove_from_favorites_usecase.dart';
import '../../domain/usecases/get_user_favorites_usecase.dart';
import '../../domain/usecases/check_is_favorite_usecase.dart';

// Repository provider
final favoritesRepositoryProvider = Provider<FavoritesRepositoryImpl>((ref) {
  return FavoritesRepositoryImpl();
});

// Use case providers
final addToFavoritesUseCaseProvider = Provider<AddToFavoritesUseCase>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return AddToFavoritesUseCase(repository);
});

final removeFromFavoritesUseCaseProvider = Provider<RemoveFromFavoritesUseCase>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return RemoveFromFavoritesUseCase(repository);
});

final getUserFavoritesUseCaseProvider = Provider<GetUserFavoritesUseCase>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return GetUserFavoritesUseCase(repository);
});

final checkIsFavoriteUseCaseProvider = Provider<CheckIsFavoriteUseCase>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return CheckIsFavoriteUseCase(repository);
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Favorites state
class FavoritesState {
  final Set<String> favoriteRecipeIds;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favoriteRecipeIds = const {},
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    Set<String>? favoriteRecipeIds,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favoriteRecipeIds: favoriteRecipeIds ?? this.favoriteRecipeIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool isFavorite(String recipeId) {
    return favoriteRecipeIds.contains(recipeId);
  }
}

// Favorites state notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final GetUserFavoritesUseCase _getUserFavoritesUseCase;
  final AddToFavoritesUseCase _addToFavoritesUseCase;
  final RemoveFromFavoritesUseCase _removeFromFavoritesUseCase;
  final AuthService _authService;
  final Ref _ref;

  FavoritesNotifier(
    this._getUserFavoritesUseCase,
    this._addToFavoritesUseCase,
    this._removeFromFavoritesUseCase,
    this._authService,
    this._ref,
  ) : super(const FavoritesState());

  String? get _currentUserId => _authService.currentUser?.uid;

  Future<void> loadUserFavorites() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(favoriteRecipeIds: {}, error: null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final favorites = await _getUserFavoritesUseCase.execute(userId);
      final favoriteIds = favorites.map((f) => f.recipeId).toSet();
      
      state = state.copyWith(
        favoriteRecipeIds: favoriteIds,
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

  Future<void> toggleFavorite(String recipeId) async {
    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    final wasAlreadyFavorite = state.isFavorite(recipeId);
    
    // Optimistic update
    final newFavorites = Set<String>.from(state.favoriteRecipeIds);
    if (wasAlreadyFavorite) {
      newFavorites.remove(recipeId);
    } else {
      newFavorites.add(recipeId);
    }
    
    state = state.copyWith(favoriteRecipeIds: newFavorites);

    try {
      if (wasAlreadyFavorite) {
        await _removeFromFavoritesUseCase.execute(userId, recipeId);
        // Record unfavorite interaction
        await _ref.read(recommendationProvider.notifier).recordInteraction(
          UserInteraction(
            id: '${DateTime.now().millisecondsSinceEpoch}_unfavorite_$recipeId',
            userId: userId,
            recipeId: recipeId,
            type: InteractionType.unfavorite,
            timestamp: DateTime.now(),
          ),
        );
      } else {
        await _addToFavoritesUseCase.execute(userId, recipeId);
        // Record favorite interaction
        await _ref.read(recommendationProvider.notifier).recordInteraction(
          UserInteraction(
            id: '${DateTime.now().millisecondsSinceEpoch}_favorite_$recipeId',
            userId: userId,
            recipeId: recipeId,
            type: InteractionType.favorite,
            timestamp: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      
      // Revert optimistic update on error
      state = state.copyWith(favoriteRecipeIds: state.favoriteRecipeIds);
      
      // Show error
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Main favorites provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final getUserFavoritesUseCase = ref.read(getUserFavoritesUseCaseProvider);
  final addToFavoritesUseCase = ref.read(addToFavoritesUseCaseProvider);
  final removeFromFavoritesUseCase = ref.read(removeFromFavoritesUseCaseProvider);
  final authService = ref.read(authServiceProvider);

  return FavoritesNotifier(
    getUserFavoritesUseCase,
    addToFavoritesUseCase,
    removeFromFavoritesUseCase,
    authService,
    ref,
  );
});

// Helper provider to check if a specific recipe is favorited
final isFavoriteProvider = Provider.family<bool, String>((ref, recipeId) {
  final favoritesState = ref.watch(favoritesProvider);
  return favoritesState.isFavorite(recipeId);
});

// Provider to get favorite recipe IDs
final favoriteRecipeIdsProvider = Provider<Set<String>>((ref) {
  final favoritesState = ref.watch(favoritesProvider);
  return favoritesState.favoriteRecipeIds;
});