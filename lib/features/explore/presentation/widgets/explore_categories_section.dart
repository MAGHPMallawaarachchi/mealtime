import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

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
  final List<String> categories = [
    'all',
    'beverages',
    'breakfast',
    'lunch',
    'dinner',
    'snacks',
    'desserts',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppLocalizations.of(context)!.categories,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCategoriesList(),
      ],
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
              (widget.selectedCategory == null && category == 'all');

          return Padding(
            padding: EdgeInsets.only(
              right: index == categories.length - 1 ? 12 : 8,
            ),
            child: _CategoryButton(
              category: _getLocalizedCategoryName(context, category),
              isSelected: isSelected,
              onTap: () {
                final selectedCategory = category == 'all' ? null : category;
                widget.onCategorySelected?.call(selectedCategory);
              },
            ),
          );
        },
      ),
    );
  }

  String _getLocalizedCategoryName(BuildContext context, String category) {
    switch (category) {
      case 'all':
        return AppLocalizations.of(context)!.all;
      case 'beverages':
        return AppLocalizations.of(context)!.beverages;
      case 'breakfast':
        return AppLocalizations.of(context)!.breakfast;
      case 'lunch':
        return AppLocalizations.of(context)!.lunch;
      case 'dinner':
        return AppLocalizations.of(context)!.dinner;
      case 'snacks':
        return AppLocalizations.of(context)!.snacks;
      case 'desserts':
        return AppLocalizations.of(context)!.desserts;
      default:
        return category;
    }
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