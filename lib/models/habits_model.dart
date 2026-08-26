// lib/models/habits_model.dart

import 'dart:async';

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

  /// Раньше: сначала ждали ответ Supabase (~секунда), и только потом
  /// привычка появлялась в списке.
  /// Теперь: привычка появляется в списке сразу (с временным id), а запрос
  /// в Supabase уходит фоном. Когда сервер ответит — временная запись
  /// подменяется на настоящую (с реальным id). При ошибке — запись исчезает
  /// из списка и в `error` появляется причина.
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

    final tempId = 'temp-${DateTime.now().microsecondsSinceEpoch}';
    final optimisticHabit = Habit(
      id: tempId,
      title: normalizedTitle,
      isNegative: isNegative,
      createdAt: DateTime.now(),
    );

    items = [...items, optimisticHabit];
    notifyListeners();

    unawaited(_createOnServer(
      tempId: tempId,
      uid: uid,
      title: normalizedTitle,
      isNegative: isNegative,
    ));

    return null;
  }

  Future<void> _createOnServer({
    required String tempId,
    required String uid,
    required String title,
    required bool isNegative,
  }) async {
    try {
      final encryptedPayload = await _encryptHabitPayload(title: title);

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

      final idx = items.indexWhere((x) => x.id == tempId);
      if (idx != -1) {
        final next = [...items];
        next[idx] = habit;
        items = next;
        notifyListeners();
      }
    } catch (e) {
      items = items.where((x) => x.id != tempId).toList();
      error = 'Не удалось создать привычку: $e';
      notifyListeners();
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

    final idx = items.indexWhere((x) => x.id == id);
    if (idx == -1) return 'Привычка не найдена';

    final previous = items[idx];
    final optimistic = previous.copyWith(
      title: normalizedTitle,
      isNegative: isNegative,
    );

    final next = [...items];
    next[idx] = optimistic;
    items = next;
    notifyListeners();

    unawaited(_updateOnServer(
      id: id,
      uid: uid,
      previous: previous,
      title: normalizedTitle,
      isNegative: isNegative,
    ));

    return null;
  }

  Future<void> _updateOnServer({
    required String id,
    required String uid,
    required Habit previous,
    required String title,
    required bool isNegative,
  }) async {
    try {
      final encryptedPayload = await _encryptHabitPayload(title: title);

      final updated = await _sb
          .from('habits')
          .update({
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
      if (idx != -1) {
        final next = [...items];
        next[idx] = habit;
        items = next;
        notifyListeners();
      }
    } catch (e) {
      final idx = items.indexWhere((x) => x.id == id);
      if (idx != -1) {
        final next = [...items];
        next[idx] = previous;
        items = next;
      }
      error = 'Не удалось обновить привычку: $e';
      notifyListeners();
    }
  }

  Future<String?> delete(String id) async {
    final uid = _uid;

    if (uid == null) return 'Not authenticated';

    error = null;

    final idx = items.indexWhere((x) => x.id == id);
    if (idx == -1) return null;

    final previous = items[idx];
    items = items.where((x) => x.id != id).toList();
    notifyListeners();

    unawaited(_deleteOnServer(id: id, uid: uid, previous: previous, index: idx));

    return null;
  }

  Future<void> _deleteOnServer({
    required String id,
    required String uid,
    required Habit previous,
    required int index,
  }) async {
    try {
      await _sb.from('habits').delete().eq('id', id).eq('user_id', uid);
    } catch (e) {
      final next = [...items];
      final insertAt = index.clamp(0, next.length);
      next.insert(insertAt, previous);
      items = next;
      error = 'Не удалось удалить привычку: $e';
      notifyListeners();
    }
  }
}