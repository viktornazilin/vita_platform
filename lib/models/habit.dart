// lib/models/habit.dart
class Habit {
  final String id; // uuid as string
  final String title;
  final bool isNegative;
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.title,
    required this.isNegative,
    required this.createdAt,
  });

  factory Habit.fromMap(Map<String, dynamic> m) {
    return Habit(
      id: (m['id'] ?? '').toString(),
      title: (m['title'] ?? '').toString(),
      isNegative: (m['is_negative'] ?? false) as bool,
      createdAt:
          DateTime.tryParse((m['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'title': title,
    'is_negative': isNegative,
  };

  Map<String, dynamic> toUpdateMap() => {
    'title': title,
    'is_negative': isNegative,
  };

  Habit copyWith({String? title, bool? isNegative}) {
    return Habit(
      id: id,
      title: title ?? this.title,
      isNegative: isNegative ?? this.isNegative,
      createdAt: createdAt,
    );
  }
}
