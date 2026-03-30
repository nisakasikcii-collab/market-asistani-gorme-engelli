class ShoppingListItem {
  const ShoppingListItem({
    required this.id,
    required this.label,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final String label;
  final bool isCompleted;
  final DateTime createdAt;

  ShoppingListItem copyWith({
    String? id,
    String? label,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      label: label ?? this.label,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "label": label,
      "isCompleted": isCompleted,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  static ShoppingListItem fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: (json["id"] ?? "").toString(),
      label: (json["label"] ?? "").toString(),
      isCompleted: (json["isCompleted"] ?? false) == true,
      createdAt: DateTime.tryParse((json["createdAt"] ?? "").toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
