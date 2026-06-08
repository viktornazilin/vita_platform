class Goal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime deadline;
  final DateTime startTime;
  final bool isCompleted;
  final String lifeBlock;
  final int importance;
  final String emotion;
  final double spentHours;
  final String? userGoalId;

  // Spaces / shared tasks
  final String? spaceId;
  final String? assignedTo;
  final String visibility;
  final String? completedBy;
  final DateTime? completedAt;

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
    this.userGoalId,
    this.spaceId,
    this.assignedTo,
    this.visibility = 'private',
    this.completedBy,
    this.completedAt,
  });

  double get hours => spentHours;

  bool get isSpaceGoal => spaceId != null && spaceId!.trim().isNotEmpty;
  bool get isPrivateGoal => !isSpaceGoal;
  bool get hasAssignee => assignedTo != null && assignedTo!.trim().isNotEmpty;

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        title: (map['title'] ?? '') as String,
        description: (map['description'] ?? '') as String,
        deadline: DateTime.parse(map['deadline'] as String),
        startTime: DateTime.parse(map['start_time'] as String),
        isCompleted: (map['is_completed'] ?? false) as bool,
        lifeBlock: (map['life_block'] ?? '') as String,
        importance: (map['importance'] ?? 1) as int,
        emotion: (map['emotion'] ?? '') as String,
        spentHours: (map['spent_hours'] ?? 0).toDouble(),
        userGoalId: map['user_goal_id'] as String?,
        spaceId: map['space_id'] as String?,
        assignedTo: map['assigned_to'] as String?,
        visibility: (map['visibility'] ?? 'private') as String,
        completedBy: map['completed_by'] as String?,
        completedAt: map['completed_at'] == null
            ? null
            : DateTime.parse(map['completed_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'start_time': startTime.toIso8601String(),
        'is_completed': isCompleted,
        'life_block': lifeBlock,
        'importance': importance,
        'emotion': emotion,
        'spent_hours': spentHours,
        'user_goal_id': userGoalId,
        'space_id': spaceId,
        'assigned_to': assignedTo,
        'visibility': visibility,
        'completed_by': completedBy,
        'completed_at': completedAt?.toIso8601String(),
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
    String? userGoalId,
    String? spaceId,
    String? assignedTo,
    String? visibility,
    String? completedBy,
    DateTime? completedAt,
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
      userGoalId: userGoalId ?? this.userGoalId,
      spaceId: spaceId ?? this.spaceId,
      assignedTo: assignedTo ?? this.assignedTo,
      visibility: visibility ?? this.visibility,
      completedBy: completedBy ?? this.completedBy,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
