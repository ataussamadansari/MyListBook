class GroceryList {
  int? id;
  String title;
  String description;
  DateTime createdAt;
  DateTime updatedAt;

  GroceryList({
    this.id,
    required this.title,
    this.description = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GroceryList.fromMap(Map<String, dynamic> map) {
    return GroceryList(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  GroceryList copyWith({
    String? title,
    String? description,
    DateTime? updatedAt,
  }) {
    return GroceryList(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}