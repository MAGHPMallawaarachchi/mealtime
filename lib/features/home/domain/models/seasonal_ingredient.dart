class SeasonalIngredient {
  final String id;
  final String name;
  final String imageUrl;
  final String description;

  const SeasonalIngredient({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  SeasonalIngredient copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? description,
  }) {
    return SeasonalIngredient(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  factory SeasonalIngredient.fromJson(Map<String, dynamic> json) {
    return SeasonalIngredient(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeasonalIngredient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SeasonalIngredient(id: $id, name: $name, description: $description)';
  }
}