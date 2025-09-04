import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/user_interaction.dart';
import '../../../../core/models/recommendation_score.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../../pantry/domain/models/pantry_item.dart';
import '../../domain/recommendation_engine.dart';
import '../../data/user_analytics_service.dart';

final recommendationEngineProvider = Provider<RecommendationEngine>((ref) {
  return RecommendationEngine();
});

final userAnalyticsServiceProvider = Provider<UserAnalyticsService>((ref) {
  return UserAnalyticsService.instance;
});

class RecommendationNotifier extends StateNotifier<AsyncValue<RecommendationBatch?>> {
  final RecommendationEngine _engine;
  final UserAnalyticsService _analyticsService;

  RecommendationNotifier(this._engine, this._analyticsService) 
      : super(const AsyncValue.data(null));

  Future<void> generateRecommendations({
    required UserModel user,
    required List<Recipe> allRecipes,
    required List<PantryItem> pantryItems,
    bool forceRefresh = false,
  }) async {
    if (!user.enableRecommendations) {
      state = const AsyncValue.data(null);
      return;
    }

    // Check if we have a recent batch that's still valid
    if (!forceRefresh && state.value != null && !state.value!.isStale) {
      return; // Use existing recommendations
    }

    state = const AsyncValue.loading();

    try {
      final interactionSummary = await _analyticsService.getUserInteractionSummary(user.uid);
      
      final batch = await _engine.generateRecommendations(
        user: user,
        allRecipes: allRecipes,
        pantryItems: pantryItems,
        interactionSummary: interactionSummary,
        context: _buildContext(),
      );

      state = AsyncValue.data(batch);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> recordInteraction(UserInteraction interaction) async {
    await _analyticsService.recordInteraction(interaction);
    
    // If this interaction might affect recommendations, mark for refresh
    if (_shouldTriggerRefresh(interaction.type)) {
      _markForRefresh();
    }
  }

  List<RecommendationScore> getPantryBasedRecommendations() {
    final batch = state.value;
    return batch?.pantryBasedRecommendations ?? [];
  }

  List<RecommendationScore> getPersonalizedRecommendations() {
    final batch = state.value;
    return batch?.contentBasedRecommendations ?? [];
  }

  List<RecommendationScore> getSeasonalRecommendations() {
    final batch = state.value;
    return batch?.seasonalRecommendations ?? [];
  }

  List<RecommendationScore> getQuickMealRecommendations() {
    final batch = state.value;
    return batch?.quickMealRecommendations ?? [];
  }

  List<RecommendationScore> getTopRecommendations({int limit = 10}) {
    final batch = state.value;
    return batch?.topRecommendations.take(limit).toList() ?? [];
  }

  void _markForRefresh() {
    if (state.value != null) {
      // Mark the current batch as stale by setting an old timestamp
      final staleBatch = state.value!.copyWith(
        generatedAt: DateTime.now().subtract(const Duration(hours: 24)),
      );
      state = AsyncValue.data(staleBatch);
    }
  }

  bool _shouldTriggerRefresh(InteractionType type) {
    switch (type) {
      case InteractionType.favorite:
      case InteractionType.unfavorite:
      case InteractionType.completeCooking:
        return true; // These significantly affect user preferences
      case InteractionType.view:
      case InteractionType.addToMealPlan:
        return false; // These are less significant
      default:
        return false;
    }
  }

  Map<String, dynamic> _buildContext() {
    final now = DateTime.now();
    return {
      'currentHour': now.hour,
      'isWeekend': now.weekday > 5,
      'dayOfWeek': now.weekday,
      'timeOfDay': _getTimeOfDay(now.hour),
    };
  }

  String _getTimeOfDay(int hour) {
    if (hour < 6) return 'earlyMorning';
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    if (hour < 21) return 'evening';
    return 'night';
  }
}

final recommendationProvider = StateNotifierProvider<RecommendationNotifier, AsyncValue<RecommendationBatch?>>((ref) {
  final engine = ref.watch(recommendationEngineProvider);
  final analyticsService = ref.watch(userAnalyticsServiceProvider);
  return RecommendationNotifier(engine, analyticsService);
});

// Convenience providers for different types of recommendations
final pantryBasedRecommendationsProvider = Provider<List<RecommendationScore>>((ref) {
  return ref.watch(recommendationProvider.notifier).getPantryBasedRecommendations();
});

final personalizedRecommendationsProvider = Provider<List<RecommendationScore>>((ref) {
  return ref.watch(recommendationProvider.notifier).getPersonalizedRecommendations();
});

final seasonalRecommendationsProvider = Provider<List<RecommendationScore>>((ref) {
  return ref.watch(recommendationProvider.notifier).getSeasonalRecommendations();
});

final quickMealRecommendationsProvider = Provider<List<RecommendationScore>>((ref) {
  return ref.watch(recommendationProvider.notifier).getQuickMealRecommendations();
});

final topRecommendationsProvider = Provider<List<RecommendationScore>>((ref) {
  return ref.watch(recommendationProvider.notifier).getTopRecommendations();
});

// Helper for recording interactions
extension RecommendationInteractionExtension on WidgetRef {
  Future<void> recordRecipeInteraction({
    required String userId,
    required String recipeId,
    required InteractionType type,
    Map<String, dynamic>? metadata,
  }) async {
    final interaction = UserInteraction(
      id: '${DateTime.now().millisecondsSinceEpoch}_${type.name}_$recipeId',
      userId: userId,
      recipeId: recipeId,
      type: type,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    await read(recommendationProvider.notifier).recordInteraction(interaction);
  }

  Future<void> recordSearchInteraction({
    required String userId,
    required String query,
  }) async {
    final interaction = UserInteraction(
      id: '${DateTime.now().millisecondsSinceEpoch}_search',
      userId: userId,
      type: InteractionType.search,
      timestamp: DateTime.now(),
      metadata: {'query': query},
    );

    await read(recommendationProvider.notifier).recordInteraction(interaction);
  }

  Future<void> recordCategoryInteraction({
    required String userId,
    required String category,
  }) async {
    final interaction = UserInteraction(
      id: '${DateTime.now().millisecondsSinceEpoch}_category',
      userId: userId,
      type: InteractionType.categorySelect,
      timestamp: DateTime.now(),
      metadata: {'category': category},
    );

    await read(recommendationProvider.notifier).recordInteraction(interaction);
  }
}