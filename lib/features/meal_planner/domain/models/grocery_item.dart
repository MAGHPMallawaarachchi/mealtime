import 'package:equatable/equatable.dart';

class GroceryItem extends Equatable {
  final String ingredientName;
  final double quantity;
  final String unit;
  final String category;
  final String? displayName; // For Sri Lankan local names

  const GroceryItem({
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    required this.category,
    this.displayName,
  });

  String get name => displayName ?? ingredientName;

  GroceryItem copyWith({
    String? ingredientName,
    double? quantity,
    String? unit,
    String? category,
    String? displayName,
  }) {
    return GroceryItem(
      ingredientName: ingredientName ?? this.ingredientName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      displayName: displayName ?? this.displayName,
    );
  }

  GroceryItem addQuantity(double additionalQuantity) {
    return copyWith(quantity: quantity + additionalQuantity);
  }

  String get formattedQuantity {
    if (quantity == quantity.toInt()) {
      return '${quantity.toInt()} $unit';
    }
    return '${quantity.toStringAsFixed(1)} $unit';
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientName': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'displayName': displayName,
    };
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      ingredientName: json['ingredientName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      category: json['category'] as String,
      displayName: json['displayName'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        ingredientName,
        quantity,
        unit,
        category,
        displayName,
      ];
}