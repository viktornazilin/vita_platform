class LadnaSpace {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final String? color;
  final String ownerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? validUntil;

  const LadnaSpace({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.validUntil,
  });

  bool get hasDeadline => validUntil != null;

  bool get isExpired {
    final until = validUntil;
    if (until == null) return false;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final untilOnly = DateTime(until.year, until.month, until.day);
    return untilOnly.isBefore(todayOnly);
  }

  bool get isActive => !isExpired;

  factory LadnaSpace.fromMap(Map<String, dynamic> map) {
    return LadnaSpace(
      id: map['id'] as String,
      name: (map['name'] ?? '') as String,
      description: map['description'] as String?,
      icon: (map['icon'] ?? '🏠') as String,
      color: map['color'] as String?,
      ownerId: map['owner_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
      validUntil: map['valid_until'] == null
          ? null
          : DateTime.parse(map['valid_until'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'owner_id': ownerId,
      'valid_until': _dateOnlyIso(validUntil),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'valid_until': _dateOnlyIso(validUntil),
    };
  }

  LadnaSpace copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? validUntil,
    bool clearValidUntil = false,
  }) {
    return LadnaSpace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      validUntil: clearValidUntil ? null : (validUntil ?? this.validUntil),
    );
  }

  static String? _dateOnlyIso(DateTime? value) {
    if (value == null) return null;
    final normalized = DateTime(value.year, value.month, value.day);
    return normalized.toIso8601String().split('T').first;
  }
}
