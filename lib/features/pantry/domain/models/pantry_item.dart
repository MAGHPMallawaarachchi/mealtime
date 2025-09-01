import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum PantryCategory {
  vegetables,
  fruits,
  grains,
  proteins,
  dairy,
  spices,
  condiments,
  oils,
  herbs,
  pantryStaples,
  frozen,
  beverages,
  other,
}

class PantryItem {
  final String id;
  final String name;
  final PantryCategory category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  const PantryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.userId,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  PantryItem copyWith({
    String? id,
    String? name,
    PantryCategory? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: _parsePantryCategory(json['category']),
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] as List)
          : [],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      userId: json['userId'] as String? ?? '',
    );
  }

  static PantryCategory _parsePantryCategory(dynamic categoryValue) {
    if (categoryValue == null) return PantryCategory.other;
    
    final categoryString = categoryValue.toString().toLowerCase();
    
    try {
      return PantryCategory.values.firstWhere(
        (category) => category.name.toLowerCase() == categoryString,
      );
    } catch (e) {
      return PantryCategory.other;
    }
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    // Handle Firestore Timestamp
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    }
    
    // Handle String (ISO format)
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    // Handle DateTime (already parsed)
    if (dateValue is DateTime) {
      return dateValue;
    }
    
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PantryItem && 
           other.id == id &&
           other.name == name &&
           other.category == category &&
           listEquals(other.tags, tags);
  }

  @override
  int get hashCode => Object.hash(id, name, category, tags);

  @override
  String toString() {
    return 'PantryItem(id: $id, name: $name, category: $category, tags: $tags)';
  }
}

// Extension for better category display
extension PantryCategoryExtension on PantryCategory {
  String get displayName {
    switch (this) {
      case PantryCategory.vegetables:
        return 'Vegetables';
      case PantryCategory.fruits:
        return 'Fruits';
      case PantryCategory.grains:
        return 'Grains & Cereals';
      case PantryCategory.proteins:
        return 'Proteins';
      case PantryCategory.dairy:
        return 'Dairy';
      case PantryCategory.spices:
        return 'Spices';
      case PantryCategory.condiments:
        return 'Condiments';
      case PantryCategory.oils:
        return 'Oils & Fats';
      case PantryCategory.herbs:
        return 'Herbs';
      case PantryCategory.pantryStaples:
        return 'Pantry Staples';
      case PantryCategory.frozen:
        return 'Frozen';
      case PantryCategory.beverages:
        return 'Beverages';
      case PantryCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case PantryCategory.vegetables:
        return '🥬';
      case PantryCategory.fruits:
        return '🍎';
      case PantryCategory.grains:
        return '🌾';
      case PantryCategory.proteins:
        return '🥩';
      case PantryCategory.dairy:
        return '🥛';
      case PantryCategory.spices:
        return '🌶️';
      case PantryCategory.condiments:
        return '🍯';
      case PantryCategory.oils:
        return '🫒';
      case PantryCategory.herbs:
        return '🌿';
      case PantryCategory.pantryStaples:
        return '🏺';
      case PantryCategory.frozen:
        return '❄️';
      case PantryCategory.beverages:
        return '🥤';
      case PantryCategory.other:
        return '📦';
    }
  }
}