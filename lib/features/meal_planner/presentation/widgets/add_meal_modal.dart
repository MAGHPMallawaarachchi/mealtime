import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/optimized_cached_image.dart';
import '../../domain/models/meal_slot.dart';
import '../../data/dummy_meal_plan_service.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../../home/data/dummy_meal_plan_data.dart';
import '../../../explore/data/dummy_explore_data.dart';

class AddMealModal extends StatefulWidget {
  final MealSlot mealSlot;
  final DateTime date;
  final Function(MealSlot)? onMealSelected;

  const AddMealModal({
    super.key,
    required this.mealSlot,
    required this.date,
    this.onMealSelected,
  });

  @override
  State<AddMealModal> createState() => _AddMealModalState();
}

class _AddMealModalState extends State<AddMealModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _customMealController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  List<String> _suggestions = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customMealController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    _allRecipes = [
      ...DummyMealPlanData.getRecipes(),
      ...DummyExploreData.getAllRecipes(),
    ];
    _filteredRecipes = _getRecipesForMealCategory();
    _suggestions = _getSuggestionsForMealCategory();
  }

  List<Recipe> _getRecipesForMealCategory() {
    // Filter recipes by meal type and search query
    var recipes = _allRecipes.where((recipe) {
      if (_searchQuery.isNotEmpty) {
        return recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (recipe.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }
      return true;
    }).toList();

    // Sort by relevance to meal type (this could be more sophisticated)
    recipes.sort((a, b) => a.title.compareTo(b.title));
    return recipes;
  }

  List<String> _getSuggestionsForMealCategory() {
    switch (widget.mealSlot.category) {
      case MealCategory.breakfast:
        return DummyMealPlanService.getBreakfastSuggestions();
      case MealCategory.lunch:
        return DummyMealPlanService.getLunchSuggestions();
      case MealCategory.dinner:
        return DummyMealPlanService.getDinnerSuggestions();
      case MealCategory.snack:
        return ['Quick Snacks', 'Fruits', 'Tea & Biscuits', 'Short Eats'];
      default:
        return ['Custom Meals', 'Quick Options'];
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredRecipes = _getRecipesForMealCategory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecipesTab(),
                _buildSuggestionsTab(),
                _buildLeftoversTab(),
                _buildCustomTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add ${widget.mealSlot.category}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                widget.mealSlot.displayTime,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: PhosphorIcon(
              PhosphorIcons.x(),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search recipes...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: PhosphorIcon(
            PhosphorIcons.magnifyingGlass(),
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Recipes'),
          Tab(text: 'Suggestions'),
          Tab(text: 'Leftovers'),
          Tab(text: 'Custom'),
        ],
      ),
    );
  }

  Widget _buildRecipesTab() {
    if (_filteredRecipes.isEmpty) {
      return _buildEmptyState('No recipes found', 'Try adjusting your search');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _filteredRecipes[index];
        return _buildRecipeCard(recipe);
      },
    );
  }

  Widget _buildSuggestionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return _buildSuggestionCard(suggestion);
      },
    );
  }

  Widget _buildLeftoversTab() {
    final leftovers = DummyMealPlanService.getLeftoverSuggestions();
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: leftovers.length,
      itemBuilder: (context, index) {
        final leftover = leftovers[index];
        return _buildLeftoverCard(leftover);
      },
    );
  }

  Widget _buildCustomTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom Meal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customMealController,
            decoration: InputDecoration(
              hintText: 'Enter meal name...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addCustomMeal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Custom Meal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () => _selectRecipe(recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: OptimizedCachedImage(
                  imageUrl: recipe.imageUrl,
                  fit: BoxFit.cover,
                  preload: false,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            PhosphorIcon(
              PhosphorIcons.plus(),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(String suggestion) {
    return GestureDetector(
      onTap: () => _selectSuggestion(suggestion),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                PhosphorIcons.forkKnife(),
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            PhosphorIcon(
              PhosphorIcons.plus(),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftoverCard(String leftover) {
    return GestureDetector(
      onTap: () => _selectLeftover(leftover),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                PhosphorIcons.recycle(),
                color: AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                leftover,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            PhosphorIcon(
              PhosphorIcons.plus(),
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(
            PhosphorIcons.forkKnife(),
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _selectRecipe(Recipe recipe) {
    final updatedSlot = widget.mealSlot.copyWith(
      recipeId: recipe.id,
      customMealName: null,
      leftoverId: null,
    );
    
    widget.onMealSelected?.call(updatedSlot);
    Navigator.pop(context);
  }

  void _selectSuggestion(String suggestion) {
    // Check if suggestion is a recipe ID
    final recipe = _allRecipes.where((r) => r.id == suggestion).firstOrNull;
    
    final updatedSlot = recipe != null
        ? widget.mealSlot.copyWith(
            recipeId: recipe.id,
            customMealName: null,
            leftoverId: null,
          )
        : widget.mealSlot.copyWith(
            customMealName: suggestion,
            recipeId: null,
            leftoverId: null,
          );
    
    widget.onMealSelected?.call(updatedSlot);
    Navigator.pop(context);
  }

  void _selectLeftover(String leftover) {
    final updatedSlot = widget.mealSlot.copyWith(
      customMealName: leftover.split(' → ').last,
      recipeId: null,
      leftoverId: 'leftover_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    widget.onMealSelected?.call(updatedSlot);
    Navigator.pop(context);
  }

  void _addCustomMeal() {
    final mealName = _customMealController.text.trim();
    if (mealName.isEmpty) return;

    final updatedSlot = widget.mealSlot.copyWith(
      customMealName: mealName,
      recipeId: null,
      leftoverId: null,
    );
    
    widget.onMealSelected?.call(updatedSlot);
    Navigator.pop(context);
  }
}

// Extension for null safety
extension RecipeFirstWhereOrNull on Iterable<Recipe> {
  Recipe? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}