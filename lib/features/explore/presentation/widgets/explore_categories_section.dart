import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../recipes/domain/usecases/get_available_categories_usecase.dart';
import '../../../recipes/data/repositories/recipes_repository_impl.dart';

class ExploreCategoriesSection extends StatefulWidget {
  final Function(String?)? onCategorySelected;
  final String? selectedCategory;

  const ExploreCategoriesSection({
    super.key,
    this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  State<ExploreCategoriesSection> createState() =>
      _ExploreCategoriesSectionState();
}

class _ExploreCategoriesSectionState extends State<ExploreCategoriesSection> {
  List<String> categories = ['All'];
  bool _isLoading = true;
  bool _hasError = false;

  // Dependencies
  late final RecipesRepositoryImpl _recipesRepository;
  late final GetAvailableCategoriesUseCase _getAvailableCategoriesUseCase;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _loadCategories();
  }

  void _initializeDependencies() {
    _recipesRepository = RecipesRepositoryImpl();
    _getAvailableCategoriesUseCase = GetAvailableCategoriesUseCase(_recipesRepository);
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final availableCategories = await _getAvailableCategoriesUseCase.execute();
      
      if (mounted) {
        setState(() {
          // Start with 'All' and add available categories
          categories = ['All', ...availableCategories];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('ExploreCategoriesSection: Error loading categories: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          // Fall back to hardcoded categories
          categories = [
            'All',
            'beverages',
            'breakfast',
            'lunch',
            'dinner',
            'snacks',
            'desserts',
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          _buildLoadingState()
        else
          _buildCategoriesList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 12),
        itemCount: 5, // Show 5 skeleton items
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == 4 ? 12 : 8,
            ),
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesList() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = widget.selectedCategory == category ||
              (widget.selectedCategory == null && category == 'All');

          return Padding(
            padding: EdgeInsets.only(
              right: index == categories.length - 1 ? 12 : 8,
            ),
            child: _CategoryButton(
              category: _formatCategoryName(category),
              isSelected: isSelected,
              onTap: () {
                final selectedCategory = category == 'All' ? null : category;
                widget.onCategorySelected?.call(selectedCategory);
              },
            ),
          );
        },
      ),
    );
  }

  String _formatCategoryName(String category) {
    if (category == 'All') return category;
    
    // Capitalize first letter and handle multiple words
    return category
        .split(' ')
        .map((word) => word.isEmpty 
            ? word 
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class _CategoryButton extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}