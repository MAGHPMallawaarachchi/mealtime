import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../recipes/domain/models/recipe.dart';

const int _defaultItemsPerPage = 20;

enum PaginationErrorType {
  network,
  timeout,
  generic,
  rateLimit,
}

class PaginationError {
  final String message;
  final PaginationErrorType type;
  final dynamic originalError;
  
  const PaginationError({
    required this.message,
    required this.type,
    this.originalError,
  });
  
  factory PaginationError.fromException(dynamic error) {
    if (error.toString().contains('network') || error.toString().contains('connection')) {
      return PaginationError(
        message: 'Network connection failed. Please check your internet connection.',
        type: PaginationErrorType.network,
        originalError: error,
      );
    }
    
    if (error.toString().contains('timeout')) {
      return PaginationError(
        message: 'Request timed out. Please try again.',
        type: PaginationErrorType.timeout,
        originalError: error,
      );
    }
    
    if (error.toString().contains('rate limit') || error.toString().contains('429')) {
      return PaginationError(
        message: 'Too many requests. Please wait a moment and try again.',
        type: PaginationErrorType.rateLimit,
        originalError: error,
      );
    }
    
    return PaginationError(
      message: 'Something went wrong. Please try again.',
      type: PaginationErrorType.generic,
      originalError: error,
    );
  }
}

class PaginationState {
  final List<Recipe> displayedRecipes;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final bool isInitialLoading;
  final bool isRefreshing;
  final PaginationError? error;
  final int retryAttempts;

  const PaginationState({
    this.displayedRecipes = const [],
    this.currentPage = 0,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.error,
    this.retryAttempts = 0,
  });

  PaginationState copyWith({
    List<Recipe>? displayedRecipes,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasReachedMax,
    bool? isInitialLoading,
    bool? isRefreshing,
    PaginationError? error,
    int? retryAttempts,
    bool clearError = false,
  }) {
    return PaginationState(
      displayedRecipes: displayedRecipes ?? this.displayedRecipes,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      retryAttempts: retryAttempts ?? this.retryAttempts,
    );
  }

  bool get isLoading => isInitialLoading || isRefreshing;
  bool get canLoadMore => !hasReachedMax && !isLoadingMore && !isLoading && error == null;
  bool get hasError => error != null;
  String? get errorMessage => error?.message;
  bool get canRetry => hasError && retryAttempts < 3;
}

class ExplorePaginationNotifier extends StateNotifier<PaginationState> {
  ExplorePaginationNotifier() : super(const PaginationState());

  List<Recipe> _allFilteredRecipes = [];
  int _itemsPerPage = _defaultItemsPerPage;

  void initializePagination(List<Recipe> allRecipes, {int? itemsPerPage}) {
    _allFilteredRecipes = allRecipes;
    _itemsPerPage = itemsPerPage ?? _defaultItemsPerPage;

    final firstPageRecipes = _getRecipesForPage(0);
    debugPrint('PaginationProvider: Initializing with ${allRecipes.length} total recipes, showing ${firstPageRecipes.length} on first page');

    state = state.copyWith(
      displayedRecipes: firstPageRecipes,
      currentPage: 0,
      hasReachedMax: allRecipes.length <= _itemsPerPage,
      isInitialLoading: false,
      clearError: true,
    );
  }

  Future<void> loadInitialRecipes(List<Recipe> allRecipes, {int? itemsPerPage}) async {
    state = state.copyWith(isInitialLoading: true, clearError: true);
    
    try {
      // Remove artificial delay - initialize immediately
      initializePagination(allRecipes, itemsPerPage: itemsPerPage);
    } catch (error) {
      state = state.copyWith(
        isInitialLoading: false,
        error: PaginationError.fromException(error),
        retryAttempts: state.retryAttempts + 1,
      );
    }
  }

  Future<void> loadNextPage() async {
    if (!state.canLoadMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
      
      final nextPage = state.currentPage + 1;
      final newRecipes = _getRecipesForPage(nextPage);
      final updatedDisplayedRecipes = [...state.displayedRecipes, ...newRecipes];
      
      state = state.copyWith(
        displayedRecipes: updatedDisplayedRecipes,
        currentPage: nextPage,
        isLoadingMore: false,
        hasReachedMax: updatedDisplayedRecipes.length >= _allFilteredRecipes.length,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        error: PaginationError.fromException(error),
        retryAttempts: state.retryAttempts + 1,
      );
    }
  }

  Future<void> refreshRecipes(List<Recipe> newAllRecipes) async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      initializePagination(newAllRecipes);
    } catch (error) {
      state = state.copyWith(
        isRefreshing: false,
        error: PaginationError.fromException(error),
        retryAttempts: state.retryAttempts + 1,
      );
    }
  }

  void updateFilteredRecipes(List<Recipe> filteredRecipes) {
    // When search or category filter changes, restart pagination and clear errors
    state = state.copyWith(clearError: true, retryAttempts: 0);
    initializePagination(filteredRecipes);
  }

  Future<void> retryLastOperation() async {
    if (!state.canRetry) return;
    
    state = state.copyWith(clearError: true);
    
    if (state.displayedRecipes.isEmpty) {
      // Retry initial load
      await loadInitialRecipes(_allFilteredRecipes);
    } else {
      // Retry loading next page
      await loadNextPage();
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true, retryAttempts: 0);
  }

  void clearRecipes() {
    _allFilteredRecipes = [];
    state = const PaginationState(
      displayedRecipes: [],
      currentPage: 0,
      hasReachedMax: true,
      isInitialLoading: false,
      isLoadingMore: false,
      isRefreshing: false,
      error: null,
      retryAttempts: 0,
    );
  }

  List<Recipe> _getRecipesForPage(int page) {
    final startIndex = page * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _allFilteredRecipes.length);
    
    if (startIndex >= _allFilteredRecipes.length) {
      return [];
    }
    
    return _allFilteredRecipes.sublist(startIndex, endIndex);
  }
}

final explorePaginationProvider = StateNotifierProvider<ExplorePaginationNotifier, PaginationState>((ref) {
  return ExplorePaginationNotifier();
});

// Convenience providers for specific UI states
final canLoadMoreProvider = Provider<bool>((ref) {
  final paginationState = ref.watch(explorePaginationProvider);
  return paginationState.canLoadMore;
});

final isLoadingMoreProvider = Provider<bool>((ref) {
  final paginationState = ref.watch(explorePaginationProvider);
  return paginationState.isLoadingMore;
});

final displayedRecipesProvider = Provider<List<Recipe>>((ref) {
  final paginationState = ref.watch(explorePaginationProvider);
  return paginationState.displayedRecipes;
});