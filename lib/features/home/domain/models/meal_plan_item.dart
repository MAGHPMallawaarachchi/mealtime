class MealPlanItem {
  final String id;
  final String title;
  final String time;
  final String imageUrl;

  const MealPlanItem({
    required this.id,
    required this.title,
    required this.time,
    required this.imageUrl,
  });

  MealPlanItem copyWith({
    String? id,
    String? title,
    String? time,
    String? imageUrl,
  }) {
    return MealPlanItem(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'imageUrl': imageUrl,
    };
  }

  factory MealPlanItem.fromJson(Map<String, dynamic> json) {
    return MealPlanItem(
      id: json['id'] as String,
      title: json['title'] as String,
      time: json['time'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlanItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MealPlanItem(id: $id, title: $title, time: $time, imageUrl: $imageUrl)';
  }
}