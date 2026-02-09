// models/goal.dart
class Goal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime deadline;
  final DateTime startTime; // <-- новое поле
  final bool isCompleted;
  final String lifeBlock;
  final int importance;
  final String emotion;
  final double spentHours;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.startTime,
    required this.lifeBlock,
    this.isCompleted = false,
    this.importance = 1,
    this.emotion = '',
    this.spentHours = 0,
  });

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    title: map['title'] as String,
    description: (map['description'] ?? '') as String,
    deadline: DateTime.parse(map['deadline'] as String),
    startTime: DateTime.parse(map['start_time'] as String), // <-- читаем
    isCompleted: (map['is_completed'] ?? false) as bool,
    lifeBlock: (map['life_block'] ?? '') as String,
    importance: (map['importance'] ?? 1) as int,
    emotion: (map['emotion'] ?? '') as String,
    spentHours: (map['spent_hours'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'description': description,
    'deadline': deadline.toIso8601String(),
    'start_time': startTime.toIso8601String(), // <-- сохраняем
    'is_completed': isCompleted,
    'life_block': lifeBlock,
    'importance': importance,
    'emotion': emotion,
    'spent_hours': spentHours,
  };

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? deadline,
    DateTime? startTime,
    bool? isCompleted,
    String? lifeBlock,
    int? importance,
    String? emotion,
    double? spentHours,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      startTime: startTime ?? this.startTime,
      isCompleted: isCompleted ?? this.isCompleted,
      lifeBlock: lifeBlock ?? this.lifeBlock,
      importance: importance ?? this.importance,
      emotion: emotion ?? this.emotion,
      spentHours: spentHours ?? this.spentHours,
    );
  }
}
