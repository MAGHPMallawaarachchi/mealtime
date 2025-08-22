import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/meal_plan_shimmer_card.dart';
import '../../domain/models/meal_plan_item.dart';
import 'meal_plan_card.dart';
import '../../../meal_planner/domain/models/meal_slot.dart';
import '../../../meal_planner/presentation/providers/meal_plan_providers.dart';
import '../../../recipes/data/repositories/recipes_repository_impl.dart';
import '../../../recipes/domain/models/recipe.dart';

class TodaysMealPlanSection extends ConsumerStatefulWidget {
  const TodaysMealPlanSection({super.key});

  @override
  ConsumerState<TodaysMealPlanSection> createState() => _TodaysMealPlanSectionState();
}

class _TodaysMealPlanSectionState extends ConsumerState<TodaysMealPlanSection> {
  late final RecipesRepositoryImpl _recipesRepository;
  final Map<String, Recipe> _recipeCache = {};

  @override
  void initState() {
    super.initState();
    _recipesRepository = RecipesRepositoryImpl();
  }

  @override
  Widget build(BuildContext context) {
    final todaysMealPlanAsync = ref.watch(todaysMealPlanProvider);
    final String todayDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Meal Plan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    todayDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  context.push('/meal-planner');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: todaysMealPlanAsync.when(
            data: (todaysMeals) {
              if (todaysMeals.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 12),
                itemCount: todaysMeals.length,
                itemBuilder: (context, index) {
                  final mealSlot = todaysMeals[index] as MealSlot;
                  return FutureBuilder<MealPlanItem>(
                    future: _convertMealSlotToMealPlanItem(mealSlot),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: 170,
                          margin: const EdgeInsets.only(right: 12, bottom: 12),
                          child: const MealPlanShimmerCard(),
                        );
                      }
                      
                      final mealPlanItem = snapshot.data ?? _createFallbackMealPlanItem(mealSlot);
                      return MealPlanCard(mealPlan: mealPlanItem);
                    },
                  );
                },
              );
            },
            loading: () => const MealPlanShimmerSection(itemCount: 3),
            error: (error, stack) => _buildEmptyState(), // Silent failure
          ),
        ),
      ],
    );
  }

  Future<MealPlanItem> _convertMealSlotToMealPlanItem(MealSlot mealSlot) async {
    String title = mealSlot.customMealName ?? mealSlot.category;
    String imageUrl = _getFallbackImageForMealType(mealSlot.category);

    // If there's a recipe ID, try to fetch the recipe
    if (mealSlot.recipeId != null) {
      try {
        // Check cache first
        Recipe? recipe = _recipeCache[mealSlot.recipeId!];
        
        // If not in cache, fetch from repository
        if (recipe == null) {
          recipe = await _recipesRepository.getRecipe(mealSlot.recipeId!);
          if (recipe != null) {
            _recipeCache[mealSlot.recipeId!] = recipe;
          }
        }
        
        if (recipe != null) {
          title = recipe.title;
          if (recipe.imageUrl.isNotEmpty) {
            imageUrl = recipe.imageUrl;
          }
        }
      } catch (e) {
        // If recipe fetching fails, use custom meal name or category as fallback
        debugPrint('Failed to fetch recipe ${mealSlot.recipeId}: $e');
      }
    }

    return MealPlanItem(
      id: mealSlot.id,
      title: title,
      time: mealSlot.displayTime,
      imageUrl: imageUrl,
      recipeId: mealSlot.recipeId,
    );
  }

  MealPlanItem _createFallbackMealPlanItem(MealSlot mealSlot) {
    return MealPlanItem(
      id: mealSlot.id,
      title: mealSlot.customMealName ?? mealSlot.category,
      time: mealSlot.displayTime,
      imageUrl: _getFallbackImageForMealType(mealSlot.category),
      recipeId: mealSlot.recipeId,
    );
  }

  String _getFallbackImageForMealType(String category) {
    switch (category) {
      case MealCategory.breakfast:
        return 'https://images.unsplash.com/photo-1551782450-a2132b4ba21d?w=800&h=600&fit=crop'; // Breakfast pancakes
      case MealCategory.lunch:
        return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&h=600&fit=crop'; // Healthy salad
      case MealCategory.dinner:
        return 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=800&h=600&fit=crop'; // Dinner plate
      case MealCategory.snack:
        return 'https://images.unsplash.com/photo-1549490349-8643362247b5?w=800&h=600&fit=crop'; // Healthy snack
      case MealCategory.brunch:
        return 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=800&h=600&fit=crop'; // Brunch spread
      case MealCategory.lateNight:
        return 'https://images.unsplash.com/photo-1551782450-a2132b4ba21d?w=800&h=600&fit=crop'; // Light meal
      default:
        return 'https://images.unsplash.com/photo-1547573854-74d2a71d0826?w=800&h=600&fit=crop'; // Generic food
    }
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(
            PhosphorIcons.forkKnife(),
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            'No meals planned yet',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap "See All" to start planning your meals',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
