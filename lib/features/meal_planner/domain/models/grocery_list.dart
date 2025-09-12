import 'package:equatable/equatable.dart';
import 'grocery_item.dart';

class GroceryList extends Equatable {
  final DateTime weekStart;
  final DateTime weekEnd;
  final Map<String, List<GroceryItem>> categorizedItems;
  final int totalItems;

  const GroceryList({
    required this.weekStart,
    required this.weekEnd,
    required this.categorizedItems,
    required this.totalItems,
  });

  factory GroceryList.create({
    required DateTime weekStart,
    required List<GroceryItem> items,
  }) {
    final categorized = <String, List<GroceryItem>>{};
    
    for (final item in items) {
      categorized.putIfAbsent(item.category, () => []).add(item);
    }

    // Sort items within each category alphabetically
    for (final category in categorized.keys) {
      categorized[category]!.sort((a, b) => a.name.compareTo(b.name));
    }

    return GroceryList(
      weekStart: weekStart,
      weekEnd: weekStart.add(const Duration(days: 6)),
      categorizedItems: categorized,
      totalItems: items.length,
    );
  }

  List<String> get categories => categorizedItems.keys.toList()..sort();

  List<GroceryItem> get allItems {
    final items = <GroceryItem>[];
    for (final categoryItems in categorizedItems.values) {
      items.addAll(categoryItems);
    }
    return items;
  }

  List<GroceryItem> getItemsForCategory(String category) {
    return categorizedItems[category] ?? [];
  }

  bool get isEmpty => totalItems == 0;

  String get dateRange {
    final startStr = '${weekStart.day}/${weekStart.month}';
    final endStr = '${weekEnd.day}/${weekEnd.month}';
    return '$startStr - $endStr';
  }

  GroceryList addItem(GroceryItem item) {
    final newCategorizedItems = Map<String, List<GroceryItem>>.from(categorizedItems);
    newCategorizedItems.putIfAbsent(item.category, () => []).add(item);
    
    // Sort the category after adding
    newCategorizedItems[item.category]!.sort((a, b) => a.name.compareTo(b.name));

    return GroceryList(
      weekStart: weekStart,
      weekEnd: weekEnd,
      categorizedItems: newCategorizedItems,
      totalItems: totalItems + 1,
    );
  }

  GroceryList removeItem(GroceryItem item) {
    final newCategorizedItems = Map<String, List<GroceryItem>>.from(categorizedItems);
    
    newCategorizedItems[item.category]?.remove(item);
    
    // Remove empty categories
    if (newCategorizedItems[item.category]?.isEmpty ?? false) {
      newCategorizedItems.remove(item.category);
    }

    return GroceryList(
      weekStart: weekStart,
      weekEnd: weekEnd,
      categorizedItems: newCategorizedItems,
      totalItems: totalItems - 1,
    );
  }

  GroceryList updateItem(GroceryItem oldItem, GroceryItem newItem) {
    return removeItem(oldItem).addItem(newItem);
  }

  String toFormattedText() {
    if (isEmpty) return 'No items in grocery list';

    final buffer = StringBuffer();
    buffer.writeln('🛒 Grocery List ($dateRange)');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();

    for (final category in categories) {
      final items = getItemsForCategory(category);
      if (items.isEmpty) continue;

      buffer.writeln('📂 ${category.toUpperCase()}');
      for (final item in items) {
        buffer.writeln('  • ${item.formattedQuantity} ${item.name}');
      }
      buffer.writeln();
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Total: $totalItems items');

    return buffer.toString();
  }

  @override
  List<Object?> get props => [weekStart, weekEnd, categorizedItems, totalItems];
}