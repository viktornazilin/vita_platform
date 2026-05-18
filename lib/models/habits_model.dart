// lib/models/habits_model.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/security/secure_crypto_service.dart';
import 'habit.dart';

class HabitsModel extends ChangeNotifier {
  final _sb = Supabase.instance.client;
  final SecureCryptoService _crypto = SecureCryptoService();

  bool loading = false;
  String? error;
  List<Habit> items = [];

  String? get _uid => _sb.auth.currentUser?.id;

  String _normalizeTitle(String value) => value.trim();

  Future<Map<String, dynamic>> _encryptHabitPayload({
    required String title,
  }) {
    return _crypto.encryptJson({
      'title': _normalizeTitle(title),
    });
  }

  Future<Map<String, dynamic>> _decryptHabitRow(
    Map<String, dynamic> row,
  ) async {
    final encryptedPayload = row['encrypted_payload'];

    if (encryptedPayload == null || encryptedPayload is! Map) {
      return row;
    }

    try {
      final decryptedPayload = await _crypto.decryptJson(
        Map<String, dynamic>.from(encryptedPayload),
      );

      final decryptedTitle = decryptedPayload['title'];

      if (decryptedTitle is String && decryptedTitle.trim().isNotEmpty) {
        row['title'] = decryptedTitle.trim();
      }

      return row;
    } catch (_) {
      // Старые записи или записи, зашифрованные другим локальным ключом,
      // оставляем как есть, чтобы экран не падал.
      return row;
    }
  }

  Future<List<Habit>> _mapHabitRows(dynamic res) async {
    final habits = <Habit>[];

    for (final raw in res as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final decryptedRow = await _decryptHabitRow(row);
      habits.add(Habit.fromMap(decryptedRow));
    }

    return habits;
  }

  Future<void> load() async {
    error = null;

    final uid = _uid;

    if (uid == null) {
      items = [];
      error = 'Not authenticated';
      notifyListeners();
      return;
    }

    loading = true;
    notifyListeners();

    try {
      final res = await _sb
          .from('habits')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: true);

      items = await _mapHabitRows(res);
    } catch (e) {
      error = 'Не удалось загрузить привычки: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> create({
    required String title,
    required bool isNegative,
  }) async {
    final uid = _uid;

    if (uid == null) return 'Not authenticated';

    final normalizedTitle = _normalizeTitle(title);

    if (normalizedTitle.isEmpty) {
      return 'Название привычки не может быть пустым';
    }

    error = null;
    notifyListeners();

    try {
      final encryptedPayload = await _encryptHabitPayload(
        title: normalizedTitle,
      );

      final inserted = await _sb
          .from('habits')
          .insert({
            'user_id': uid,

            // Technical fallback. Real title is stored in encrypted_payload.
            'title': '[encrypted]',

            'is_negative': isNegative,
            'encrypted_payload': encryptedPayload,
            'encryption_version': 1,
          })
          .select()
          .single();

      final row = Map<String, dynamic>.from(inserted as Map);
      final decryptedRow = await _decryptHabitRow(row);
      final habit = Habit.fromMap(decryptedRow);

      items = [...items, habit];
      notifyListeners();

      return null;
    } catch (e) {
      return 'Не удалось создать привычку: $e';
    }
  }

  Future<String?> update(
    String id, {
    required String title,
    required bool isNegative,
  }) async {
    final uid = _uid;

    if (uid == null) return 'Not authenticated';

    final normalizedTitle = _normalizeTitle(title);

    if (normalizedTitle.isEmpty) {
      return 'Название привычки не может быть пустым';
    }

    error = null;
    notifyListeners();

    try {
      final encryptedPayload = await _encryptHabitPayload(
        title: normalizedTitle,
      );

      final updated = await _sb
          .from('habits')
          .update({
            // Technical fallback. Real title is stored in encrypted_payload.
            'title': '[encrypted]',

            'is_negative': isNegative,
            'encrypted_payload': encryptedPayload,
            'encryption_version': 1,
          })
          .eq('id', id)
          .eq('user_id', uid)
          .select()
          .single();

      final row = Map<String, dynamic>.from(updated as Map);
      final decryptedRow = await _decryptHabitRow(row);
      final habit = Habit.fromMap(decryptedRow);

      final idx = items.indexWhere((x) => x.id == id);

      if (idx >= 0) {
        final next = [...items];
        next[idx] = habit;
        items = next;
      } else {
        items = [...items, habit];
      }

      notifyListeners();

      return null;
    } catch (e) {
      return 'Не удалось обновить привычку: $e';
    }
  }

  Future<String?> delete(String id) async {
    final uid = _uid;

    if (uid == null) return 'Not authenticated';

    error = null;
    notifyListeners();

    try {
      await _sb.from('habits').delete().eq('id', id).eq('user_id', uid);

      items = items.where((x) => x.id != id).toList();
      notifyListeners();

      return null;
    } catch (e) {
      return 'Не удалось удалить привычку: $e';
    }
  }
}