import 'package:flutter/material.dart';

enum GoalHorizon { tactical, mid, long }

extension GoalHorizonX on GoalHorizon {
  String get dbValue {
    switch (this) {
      case GoalHorizon.tactical:
        return 'tactical';
      case GoalHorizon.mid:
        return 'mid';
      case GoalHorizon.long:
        return 'long';
    }
  }

  String get labelRu {
    switch (this) {
      case GoalHorizon.tactical:
        return 'Краткосрочные';
      case GoalHorizon.mid:
        return 'Среднесрочные';
      case GoalHorizon.long:
        return 'Долгосрочные';
    }
  }

  static GoalHorizon fromDb(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'tactical':
        return GoalHorizon.tactical;
      case 'mid':
        return GoalHorizon.mid;
      case 'long':
        return GoalHorizon.long;
      default:
        return GoalHorizon.mid;
    }
  }
}

class UserGoal {
  final String id;
  final String userId;
  final String lifeBlock;
  final GoalHorizon horizon;
  final String title;
  final String? description;
  final DateTime? targetDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserGoal({
    required this.id,
    required this.userId,
    required this.lifeBlock,
    required this.horizon,
    required this.title,
    this.description,
    this.targetDate,
    required this.isCompleted,
    this.completedAt,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  UserGoal copyWith({
    String? id,
    String? userId,
    String? lifeBlock,
    GoalHorizon? horizon,
    String? title,
    String? description,
    DateTime? targetDate,
    bool? isCompleted,
    DateTime? completedAt,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lifeBlock: lifeBlock ?? this.lifeBlock,
      horizon: horizon ?? this.horizon,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserGoal.fromMap(Map<String, dynamic> map) {
    return UserGoal(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      lifeBlock: (map['life_block'] as String?)?.trim() ?? '',
      horizon: GoalHorizonX.fromDb((map['horizon'] as String?) ?? 'mid'),
      title: (map['title'] as String?)?.trim() ?? '',
      description: (map['description'] as String?)?.trim(),
      targetDate: map['target_date'] == null
          ? null
          : DateTime.parse(map['target_date'] as String),
      isCompleted: map['is_completed'] as bool? ?? false,
      completedAt: map['completed_at'] == null
          ? null
          : DateTime.parse(map['completed_at'] as String),
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class UserGoalUpsert {
  final String? id;
  final String lifeBlock;
  final GoalHorizon horizon;
  final String title;
  final String? description;
  final DateTime? targetDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final int sortOrder;

  const UserGoalUpsert({
    this.id,
    required this.lifeBlock,
    required this.horizon,
    required this.title,
    this.description,
    this.targetDate,
    this.isCompleted = false,
    this.completedAt,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toInsertMap({required String userId}) {
    return {
      'user_id': userId,
      'life_block': lifeBlock,
      'horizon': horizon.dbValue,
      'title': title.trim(),
      'description':
          (description == null || description!.trim().isEmpty)
              ? null
              : description!.trim(),
      'target_date': targetDate == null
          ? null
          : DateUtils.dateOnly(targetDate!).toIso8601String().split('T').first,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'sort_order': sortOrder,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'life_block': lifeBlock,
      'horizon': horizon.dbValue,
      'title': title.trim(),
      'description':
          (description == null || description!.trim().isEmpty)
              ? null
              : description!.trim(),
      'target_date': targetDate == null
          ? null
          : DateUtils.dateOnly(targetDate!).toIso8601String().split('T').first,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'sort_order': sortOrder,
    };
  }
}