import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteRecipe {
  final String recipeId;
  final DateTime addedAt;

  const FavoriteRecipe({
    required this.recipeId,
    required this.addedAt,
  });

  FavoriteRecipe copyWith({
    String? recipeId,
    DateTime? addedAt,
  }) {
    return FavoriteRecipe(
      recipeId: recipeId ?? this.recipeId,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory FavoriteRecipe.fromJson(Map<String, dynamic> json) {
    return FavoriteRecipe(
      recipeId: json['recipeId'] as String,
      addedAt: (json['addedAt'] as Timestamp).toDate(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteRecipe && other.recipeId == recipeId;
  }

  @override
  int get hashCode => recipeId.hashCode;

  @override
  String toString() {
    return 'FavoriteRecipe(recipeId: $recipeId, addedAt: $addedAt)';
  }
}