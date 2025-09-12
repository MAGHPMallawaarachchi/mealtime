import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/pantry_item.dart';
import 'pantry_item_card.dart';

class PantryCategorySection extends StatelessWidget {
  final PantryCategory category;
  final List<PantryItem> items;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final Function(PantryItem) onEditItem;
  final Function(PantryItem) onDeleteItem;

  const PantryCategorySection({
    super.key,
    required this.category,
    required this.items,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onEditItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Category header
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
                bottom: Radius.circular(0),
              ),
              onTap: onToggleExpanded,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                    bottom: Radius.circular(0),
                  ),
                ),
                child: Row(
                  children: [
                    // Category emoji and name
                    Text(category.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Expand/collapse icon
                    PhosphorIcon(
                      isExpanded
                          ? PhosphorIcons.caretUp()
                          : PhosphorIcons.caretDown(),
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Category items
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: items.map((item) {
                  return PantryItemCard(
                    item: item,
                    onEdit: () => onEditItem(item),
                    onDelete: () => onDeleteItem(item),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
