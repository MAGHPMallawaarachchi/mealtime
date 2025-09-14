import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../../domain/models/recipe.dart';
import '../../domain/usecases/get_recipe_by_id_usecase.dart';
import '../../data/repositories/recipes_repository_impl.dart';
import '../../../meal_planner/domain/models/meal_planner_return_context.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../../core/providers/locale_providers.dart';

enum RecipeTab { ingredients, instructions }

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;
  final MealPlannerReturnContext? returnContext;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    this.returnContext,
  });

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  int currentServings = 4;
  UnitSystem selectedUnitSystem = UnitSystem.cups;
  Set<String> checkedIngredients = {};
  RecipeTab selectedTab = RecipeTab.ingredients;
  bool isDescriptionExpanded = false;
  Recipe? _recipe;
  bool _isLoading = true;
  String? _errorMessage;

  // Dependencies
  late final RecipesRepositoryImpl _recipesRepository;
  late final GetRecipeByIdUseCase _getRecipeByIdUseCase;

  String get localeCode {
    final locale = ref.watch(localeProvider);
    return locale?.languageCode ?? 'en';
  }

  String get localizedTitle {
    return _recipe?.getLocalizedTitle(localeCode) ?? '';
  }

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _loadRecipe();
    _loadFavorites();
  }

  void _loadFavorites() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesProvider.notifier).loadUserFavorites();
    });
  }

  void _initializeDependencies() {
    _recipesRepository = RecipesRepositoryImpl();
    _getRecipeByIdUseCase = GetRecipeByIdUseCase(_recipesRepository);
  }

  Future<void> _loadRecipe() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final recipe = await _getRecipeByIdUseCase.execute(widget.recipeId);

      if (mounted) {
        setState(() {
          _recipe = recipe;
          _isLoading = false;
          if (recipe != null) {
            currentServings = recipe.defaultServings;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _refreshRecipe() async {
    await _loadRecipe();
  }

  void _navigateBack() {
    if (widget.returnContext != null) {
      // Navigate back to meal planner with context preservation
      final context = widget.returnContext!;
      final queryParams = context.toQueryParameters();
      final uri = Uri(path: '/meal-planner', queryParameters: queryParams);
      this.context.go(uri.toString());
    } else {
      // Default back navigation
      this.context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: _refreshRecipe, child: _buildContent());
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: PhosphorIcon(
              PhosphorIcons.arrowLeft(),
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_recipe == null) {
      return _buildNotFoundState();
    }

    return _buildRecipeContent(_recipe!);
  }

  Widget _buildNotFoundState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: PhosphorIcon(
            PhosphorIcons.arrowLeft(),
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.cookingPot(),
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.recipeNotFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.recipeDoesNotExist,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: PhosphorIcon(
            PhosphorIcons.arrowLeft(),
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                PhosphorIcons.warning(),
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.somethingWentWrong,
                style: const TextStyle(
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
                onPressed: _refreshRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: Text(AppLocalizations.of(context)!.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeContent(Recipe recipe) {
    final localizedDescription = recipe.getLocalizedDescription(localeCode);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: PhosphorIcon(
                  PhosphorIcons.arrowLeft(),
                  color: AppColors.textPrimary,
                ),
                onPressed: () => _navigateBack(),
              ),
            ),
            actions: [
              Container(
                height: 40,
                width: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final isFavorited = ref.watch(
                      isFavoriteProvider(widget.recipeId),
                    );

                    return IconButton(
                      icon: PhosphorIcon(
                        size: 22,
                        isFavorited
                            ? PhosphorIconsFill.heart
                            : PhosphorIcons.heart(),
                        color: isFavorited
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fill: isFavorited ? 1.0 : 0.0,
                      ),
                      onPressed: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(widget.recipeId);
                      },
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.background,
                child: Image.network(
                  recipe.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.background,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.background,
                      child: PhosphorIcon(
                        PhosphorIcons.image(),
                        color: AppColors.textSecondary,
                        size: 64,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          localizedTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.clock(),
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recipe.time,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (recipe.description != null)
                    _buildDescription(recipe.description!),
                  const SizedBox(height: 24),
                  _buildNutritionInfo(recipe),
                  const SizedBox(height: 24),
                  _buildTabNavigation(),
                  const SizedBox(height: 16),
                  if (selectedTab == RecipeTab.ingredients) ...[
                    _buildServingsControl(),
                    const SizedBox(height: 16),
                    _buildIngredients(recipe),
                  ] else ...[
                    _buildInstructions(recipe),
                  ],
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: AppLocalizations.of(context)!.addToMealPlan,
                    onPressed: () => _addToMealPlan(recipe),
                    height: 56,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    const maxLines = 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          maxLines: isDescriptionExpanded ? null : maxLines,
          overflow: isDescriptionExpanded
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              isDescriptionExpanded = !isDescriptionExpanded;
            });
          },
          child: Text(
            isDescriptionExpanded ? AppLocalizations.of(context)!.viewLess : AppLocalizations.of(context)!.viewMore,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = RecipeTab.ingredients;
                });
              },
              child: Container(
                height: 40,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selectedTab == RecipeTab.ingredients
                      ? AppColors.textPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.ingredients,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selectedTab == RecipeTab.ingredients
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = RecipeTab.instructions;
                });
              },
              child: Container(
                height: 40,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selectedTab == RecipeTab.instructions
                      ? AppColors.textPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.instructions,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selectedTab == RecipeTab.instructions
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingsControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.servings,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: currentServings > 1
                    ? () {
                        setState(() {
                          currentServings--;
                        });
                      }
                    : null,
                icon: PhosphorIcon(
                  PhosphorIcons.minus(),
                  size: 16,
                  color: currentServings > 1
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: Text(
                  '$currentServings',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: currentServings < 20
                    ? () {
                        setState(() {
                          currentServings++;
                        });
                      }
                    : null,
                icon: PhosphorIcon(
                  PhosphorIcons.plus(),
                  size: 16,
                  color: currentServings < 20
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitToggle() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedUnitSystem = UnitSystem.cups;
              });
            },
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: selectedUnitSystem == UnitSystem.cups
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.cups,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selectedUnitSystem == UnitSystem.cups
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedUnitSystem = UnitSystem.metric;
              });
            },
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: selectedUnitSystem == UnitSystem.metric
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.metric,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selectedUnitSystem == UnitSystem.metric
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo(Recipe recipe) {
    // Per serving nutrition values (no scaling needed)
    final caloriesPerServing = (recipe.calories / recipe.defaultServings)
        .round();
    final proteinPerServing = recipe.macros.protein / recipe.defaultServings;
    final carbsPerServing = recipe.macros.carbs / recipe.defaultServings;
    final fatsPerServing = recipe.macros.fats / recipe.defaultServings;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNutritionCard(
            PhosphorIcons.fire(),
            '$caloriesPerServing',
            AppLocalizations.of(context)!.calories,
          ),
          _buildNutritionCard(
            PhosphorIcons.shrimp(),
            '${proteinPerServing.toStringAsFixed(0)} g',
            AppLocalizations.of(context)!.protein,
          ),
          _buildNutritionCard(
            PhosphorIcons.grains(),
            '${carbsPerServing.toStringAsFixed(0)} g',
            AppLocalizations.of(context)!.carbs,
          ),
          _buildNutritionCard(
            PhosphorIcons.avocado(),
            '${fatsPerServing.toStringAsFixed(1)} g',
            AppLocalizations.of(context)!.fat,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(IconData icon, String value, String label) {
    return Column(
      children: [
        PhosphorIcon(icon, size: 30, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 0),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildIngredientItem({
    required String ingredientId,
    required String displayText,
  }) {
    final isChecked = checkedIngredients.contains(ingredientId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (isChecked) {
                  checkedIngredients.remove(ingredientId);
                } else {
                  checkedIngredients.add(ingredientId);
                }
              });
            },
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(right: 12, top: 2),
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isChecked ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ),
          Expanded(
            child: Text(
              displayText,
              style: TextStyle(
                fontSize: 14,
                color: isChecked
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                height: 1.4,
                decoration: isChecked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients(Recipe recipe) {
    List<Widget> ingredientWidgets = [];

    // Handle sectioned ingredients (preferred format)
    if (recipe.ingredientSections.isNotEmpty) {
      for (final section in recipe.ingredientSections) {
        // Add section header
        ingredientWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                section.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );

        // Add section ingredients
        for (final ingredient in section.ingredients) {
          final scaledIngredient = ingredient.scaledForServings(
            currentServings,
            recipe.defaultServings,
          );

          ingredientWidgets.add(
            _buildIngredientItem(
              ingredientId: ingredient.id,
              displayText: scaledIngredient.getDisplayText(selectedUnitSystem, localeCode),
            ),
          );
        }

        // Add spacing between sections
        if (section != recipe.ingredientSections.last) {
          ingredientWidgets.add(const SizedBox(height: 24));
        }
      }
    } else if (recipe.ingredients.isNotEmpty) {
      // Flat ingredients format (new format with RecipeIngredient objects)
      for (final ingredient in recipe.ingredients) {
        final scaledIngredient = ingredient.scaledForServings(
          currentServings,
          recipe.defaultServings,
        );

        ingredientWidgets.add(
          _buildIngredientItem(
            ingredientId: ingredient.id,
            displayText: scaledIngredient.getDisplayText(selectedUnitSystem, localeCode),
          ),
        );
      }
    } else if (recipe.legacyIngredients.isNotEmpty) {
      // Legacy format with strings
      for (int i = 0; i < recipe.legacyIngredients.length; i++) {
        final ingredient = recipe.legacyIngredients[i];
        final ingredientId = 'legacy_$i';

        ingredientWidgets.add(
          _buildIngredientItem(
            ingredientId: ingredientId,
            displayText: ingredient,
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUnitToggle(),
          SizedBox(height: 16),
          Column(children: ingredientWidgets),
        ],
      ),
    );
  }

  Widget _buildInstructions(Recipe recipe) {
    List<Widget> instructionWidgets = [];

    if (recipe.instructionSections.isNotEmpty) {
      // New format with InstructionSection objects
      for (final section in recipe.instructionSections) {
        // Add section header
        instructionWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              section.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );

        // Add section steps
        final localizedSteps = section.getLocalizedSteps(localeCode);
        for (int i = 0; i < localizedSteps.length; i++) {
          instructionWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      localizedSteps[i],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Add spacing between sections
        if (section != recipe.instructionSections.last) {
          instructionWidgets.add(const SizedBox(height: 24));
        }
      }
    } else if (recipe.legacyInstructions.isNotEmpty) {
      // Legacy format with strings
      for (int i = 0; i < recipe.legacyInstructions.length; i++) {
        instructionWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    recipe.legacyInstructions[i],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: instructionWidgets,
      ),
    );
  }

  void _addToMealPlan(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.calendar(),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.addRecipeToMealPlan(localizedTitle),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.calendar()),
              title: Text(AppLocalizations.of(context)!.goToMealPlanner),
              subtitle: Text(AppLocalizations.of(context)!.chooseSpecificDayAndMeal),
              onTap: () {
                Navigator.pop(context);
                context.go('/meal-planner');
              },
            ),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.clockCounterClockwise()),
              title: Text(AppLocalizations.of(context)!.addToToday),
              subtitle: Text(AppLocalizations.of(context)!.quickAddToTodayMeal),
              onTap: () {
                Navigator.pop(context);
                _addToTodaysMeals(recipe);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addToTodaysMeals(Recipe recipe) {
    // Show a selection dialog for today's meal slots
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addToToday),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.whichMealToAdd(localizedTitle)),
            const SizedBox(height: 16),
            _buildMealTimeOption(AppLocalizations.of(context)!.breakfast, AppLocalizations.of(context)!.breakfastTime),
            _buildMealTimeOption(AppLocalizations.of(context)!.lunch, AppLocalizations.of(context)!.lunchTime),
            _buildMealTimeOption(AppLocalizations.of(context)!.dinner, AppLocalizations.of(context)!.dinnerTime),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTimeOption(String mealType, String time) {
    return ListTile(
      title: Text(mealType),
      subtitle: Text(time),
      onTap: () {
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.checkCircle(),
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.addedToTodayMeal(mealType),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }
}
