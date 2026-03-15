import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_goal.dart';

mixin UserGoalsRepoMixin {
  SupabaseClient get client;

  Future<String> _requireUserId() async {
  final authId = client.auth.currentUser?.id;
  if (authId == null || authId.isEmpty) {
    throw Exception('Пользователь не авторизован');
  }

  return authId;
}

  Future<List<UserGoal>> getUserGoals({
  String? lifeBlock,
  GoalHorizon? horizon,
  bool includeCompleted = true,
}) async {
    final userId = await _requireUserId();

    var query = client
        .from('user_goals')
        .select()
        .eq('user_id', userId);

    if (lifeBlock != null && lifeBlock != 'all') {
      query = query.eq('life_block', lifeBlock);
    }

    if (horizon != null) {
      query = query.eq('horizon', horizon.dbValue);
    }

    if (!includeCompleted) {
      query = query.eq('is_completed', false);
    }

    final rows = await query
        .order('is_completed', ascending: true)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((e) => UserGoal.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

 Future<UserGoal> createUserGoal({
  required String lifeBlock,
  required GoalHorizon horizon,
  required String title,
  String? description,
  DateTime? targetDate,
  int sortOrder = 0,
  bool isCompleted = false,
  DateTime? completedAt,
}) async {
  final userId = await _requireUserId();

  final row = await client
      .from('user_goals')
      .insert({
        'user_id': userId,
        'life_block': lifeBlock,
        'horizon': horizon.dbValue,
        'title': title.trim(),
        'description': description?.trim().isEmpty == true ? null : description?.trim(),
        'target_date': targetDate == null
            ? null
            : DateUtils.dateOnly(targetDate).toIso8601String().split('T').first,
        'sort_order': sortOrder,
        'is_completed': isCompleted,
        'completed_at': completedAt?.toIso8601String(),
      })
      .select()
      .single();

  return UserGoal.fromMap(Map<String, dynamic>.from(row));
}

  Future<void> updateUserGoal({
  required String id,
  required String lifeBlock,
  required GoalHorizon horizon,
  required String title,
  String? description,
  DateTime? targetDate,
  required int sortOrder,
  bool isCompleted = false,
  DateTime? completedAt,
}) async {
  await client.from('user_goals').update({
    'life_block': lifeBlock,
    'horizon': horizon.dbValue,
    'title': title.trim(),
    'description': description?.trim().isEmpty == true ? null : description?.trim(),
    'target_date': targetDate == null
        ? null
        : DateUtils.dateOnly(targetDate).toIso8601String().split('T').first,
    'sort_order': sortOrder,
    'is_completed': isCompleted,
    'completed_at': completedAt?.toIso8601String(),
  }).eq('id', id);
}

  Future<void> setUserGoalCompleted({
    required String id,
    required bool completed,
  }) async {
    await client.from('user_goals').update({
      'is_completed': completed,
      'completed_at': completed ? DateTime.now().toIso8601String() : null,
    }).eq('id', id);
  }

  Future<void> deleteUserGoal(String id) async {
    await client.from('user_goals').delete().eq('id', id);
  }
}