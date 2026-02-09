class Mood {
  final String id;
  final String userId;
  final DateTime
  date; // в БД хранится как DATE, но сюда — DateTime для удобства
  final String emoji;
  final String note;

  Mood({
    required this.id,
    required this.userId,
    required this.date,
    required this.emoji,
    required this.note,
  });

  factory Mood.fromMap(Map<String, dynamic> map) => Mood(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    date: DateTime.parse(map['date'] as String),
    emoji: map['emoji'] as String,
    note: (map['note'] ?? '') as String,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    // нормализуем к дате без времени
    'date': DateTime(date.year, date.month, date.day).toIso8601String(),
    'emoji': emoji,
    'note': note,
  };
}
