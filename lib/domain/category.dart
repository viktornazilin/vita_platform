class Category {
  final String id;
  final String name;
  final String kind;
  final double? limitAmount; // лимит расходов, может быть null

  Category({
    required this.id,
    required this.name,
    required this.kind,
    this.limitAmount,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      kind: map['kind'] as String,
      limitAmount: (map['limit_amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'kind': kind,
      'limit_amount': limitAmount,
    };
  }
}
