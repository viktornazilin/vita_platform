import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_goal.dart';
import '../core/security/secure_crypto_service.dart';

mixin UserGoalsRepoMixin {
  SupabaseClient get client;

  final SecureCryptoService _crypto = SecureCryptoService();

  Future<String> _requireUserId() async {
    final authId = client.auth.currentUser?.id;

    if (authId == null || authId.isEmpty) {
      throw Exception('Пользователь не авторизован');
    }

    return authId;
  }

  String? _normalizeNullableText(String? value) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  String _formatDateOnly(DateTime date) {
    return DateUtils.dateOnly(date).toIso8601String().split('T').first;
  }

  Future<Map<String, dynamic>> _encryptUserGoalPayload({
    required String title,
    String? description,
  }) async {
    final normalizedTitle = title.trim();
    final normalizedDescription = _normalizeNullableText(description);

    return _crypto.encryptJson({
      'title': normalizedTitle,
      'description': normalizedDescription,
    });
  }

  Future<Map<String, dynamic>> _decryptUserGoalRow(
    Map<String, dynamic> row,
  ) async {
    final encryptedPayload = row['encrypted_payload'];

    if (encryptedPayload == null) {
      return row;
    }

    if (encryptedPayload is! Map) {
      return row;
    }

    try {
      final decrypted = await _crypto.decryptJson(
        Map<String, dynamic>.from(encryptedPayload),
      );

      final decryptedTitle = decrypted['title'];
      final decryptedDescription = decrypted['description'];

      if (decryptedTitle is String && decryptedTitle.trim().isNotEmpty) {
        row['title'] = decryptedTitle.trim();
      }

      if (decryptedDescription is String &&
          decryptedDescription.trim().isNotEmpty) {
        row['description'] = decryptedDescription.trim();
      } else {
        row['description'] = null;
      }

      return row;
    } catch (_) {
      return row;
    }
  }

  Future<List<UserGoal>> getUserGoals({
    String? lifeBlock,
    GoalHorizon? horizon,
    bool includeCompleted = true,
  }) async {
    final userId = await _requireUserId();

    var query = client.from('user_goals').select().eq('user_id', userId);

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

    final decryptedRows = <Map<String, dynamic>>[];

    for (final rawRow in rows as List<dynamic>) {
      final row = Map<String, dynamic>.from(rawRow as Map);
      decryptedRows.add(await _decryptUserGoalRow(row));
    }

    return decryptedRows.map(UserGoal.fromMap).toList();
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

    final normalizedTitle = title.trim();

    if (normalizedTitle.isEmpty) {
      throw Exception('Название цели не может быть пустым');
    }

    final encryptedPayload = await _encryptUserGoalPayload(
      title: normalizedTitle,
      description: description,
    );

    final row = await client
        .from('user_goals')
        .insert({
          'user_id': userId,
          'life_block': lifeBlock,
          'horizon': horizon.dbValue,

          // Technical fallback for DB constraints.
          // Real user text is stored in encrypted_payload.
          'title': '[encrypted]',
          'description': null,

          'encrypted_payload': encryptedPayload,
          'encryption_version': 1,

          'target_date': targetDate == null ? null : _formatDateOnly(targetDate),
          'sort_order': sortOrder,
          'is_completed': isCompleted,
          'completed_at': completedAt?.toIso8601String(),
        })
        .select()
        .single();

    final decryptedRow = await _decryptUserGoalRow(
      Map<String, dynamic>.from(row),
    );

    return UserGoal.fromMap(decryptedRow);
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
    final userId = await _requireUserId();
    final normalizedTitle = title.trim();

    if (normalizedTitle.isEmpty) {
      throw Exception('Название цели не может быть пустым');
    }

    final encryptedPayload = await _encryptUserGoalPayload(
      title: normalizedTitle,
      description: description,
    );

    await client
        .from('user_goals')
        .update({
          'life_block': lifeBlock,
          'horizon': horizon.dbValue,

          // Technical fallback for DB constraints.
          // Real user text is stored in encrypted_payload.
          'title': '[encrypted]',
          'description': null,

          'encrypted_payload': encryptedPayload,
          'encryption_version': 1,

          'target_date': targetDate == null ? null : _formatDateOnly(targetDate),
          'sort_order': sortOrder,
          'is_completed': isCompleted,
          'completed_at': completedAt?.toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> setUserGoalCompleted({
    required String id,
    required bool completed,
  }) async {
    final userId = await _requireUserId();

    await client
        .from('user_goals')
        .update({
          'is_completed': completed,
          'completed_at': completed ? DateTime.now().toIso8601String() : null,
        })
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> deleteUserGoal(String id) async {
    final userId = await _requireUserId();

    await client
        .from('user_goals')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}