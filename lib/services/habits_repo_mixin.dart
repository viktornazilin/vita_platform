// lib/services/habits_repo_mixin.dart

import 'core/base_repo.dart';
import '../core/security/secure_crypto_service.dart';
import '../models/habit.dart';

/// DTO для апсерта дневных отметок привычек
class HabitEntryUpsert {
  final String habitId;
  final DateTime day; // приводим к DateOnly
  final bool done;
  final int value;
  final String? note;

  HabitEntryUpsert({
    required this.habitId,
    required this.day,
    required this.done,
    this.value = 0,
    this.note,
  });
}

abstract class HabitsRepo {
  Future<List<Habit>> listHabits();

  /// Upsert пачки дневных записей привычек (по уникальности user_id+day+habit_id)
  /// ✅ Если запись уже существует и значений не меняли — запись в БД не делаем.
  Future<void> upsertHabitEntries(List<HabitEntryUpsert> entries);

  /// получить отметки за день (удобно для предзаполнения UI)
  Future<Map<String, Map<String, dynamic>>> getHabitEntriesForDay(DateTime day);
}

mixin HabitsRepoMixin on BaseRepo implements HabitsRepo {
  final SecureCryptoService _crypto = SecureCryptoService();

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _normNote(String? s) => (s ?? '').trim();

  String? _normOrNull(String? s) {
    final value = _normNote(s);
    return value.isEmpty ? null : value;
  }

  Future<Map<String, dynamic>> _encryptHabitEntryPayload({
    required String note,
  }) {
    return _crypto.encryptJson({
      'note': _normOrNull(note),
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

  Future<Map<String, dynamic>> _decryptHabitEntryRow(
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

      final decryptedNote = decryptedPayload['note'];

      row['note'] = decryptedNote is String ? decryptedNote.trim() : '';

      return row;
    } catch (_) {
      // Старые записи или записи, зашифрованные другим локальным ключом,
      // оставляем как есть, чтобы экран не падал.
      return row;
    }
  }

  @override
  Future<List<Habit>> listHabits() async {
    final res = await client
        .from('habits')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: true);

    final habits = <Habit>[];

    for (final raw in res as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final decryptedRow = await _decryptHabitRow(row);
      habits.add(Habit.fromMap(decryptedRow));
    }

    return habits;
  }

  @override
  Future<void> upsertHabitEntries(List<HabitEntryUpsert> entries) async {
    if (entries.isEmpty) return;

    // 1) нормализуем вход и собираем уникальные day/habit_id
    final normalized = <Map<String, dynamic>>[];
    final days = <String>{};
    final habitIds = <String>{};

    for (final e in entries) {
      final day = DateTime(e.day.year, e.day.month, e.day.day);
      final dayKey = _dateOnly(day);
      final value = e.value < 0 ? 0 : e.value;
      final note = _normNote(e.note);

      days.add(dayKey);
      habitIds.add(e.habitId);

      normalized.add({
        'day': dayKey,
        'habit_id': e.habitId,
        'done': e.done,
        'value': value,
        'note': note,
      });
    }

    // 2) читаем существующие записи для затронутых day+habit_id
    final existingRes = await client
        .from('habit_entries')
        .select('day, habit_id, done, value, note, encrypted_payload')
        .eq('user_id', uid)
        .inFilter('day', days.toList())
        .inFilter('habit_id', habitIds.toList());

    // key: "$day|$habitId"
    final existing = <String, Map<String, dynamic>>{};

    for (final raw in existingRes as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final decryptedRow = await _decryptHabitEntryRow(row);

      final dayKey = (decryptedRow['day'] ?? '').toString().trim();
      final hid = (decryptedRow['habit_id'] ?? '').toString();

      if (dayKey.isEmpty || hid.isEmpty) continue;

      existing['$dayKey|$hid'] = {
        'done': (decryptedRow['done'] as bool?) ?? false,
        'value': (decryptedRow['value'] as num?)?.toInt() ?? 0,
        'note': _normNote(decryptedRow['note']?.toString()),
      };
    }

    // 3) в upsert отправляем только новые/изменённые
    final rows = <Map<String, dynamic>>[];

    for (final e in normalized) {
      final dayKey = e['day'] as String;
      final hid = e['habit_id'] as String;
      final key = '$dayKey|$hid';

      final old = existing[key];

      final newDone = e['done'] as bool;
      final newValue = e['value'] as int;
      final newNote = e['note'] as String;

      final isSame = old != null &&
          (old['done'] as bool) == newDone &&
          (old['value'] as int) == newValue &&
          (old['note'] as String) == newNote;

      if (isSame) continue;

      final encryptedPayload = await _encryptHabitEntryPayload(note: newNote);

      rows.add({
        'user_id': uid,
        'habit_id': hid,
        'day': dayKey,
        'done': newDone,
        'value': newValue,

        // Technical fallback. Real note is stored in encrypted_payload.
        'note': newNote.isEmpty ? '' : '[encrypted]',

        'encrypted_payload': encryptedPayload,
        'encryption_version': 1,
      });
    }

    if (rows.isEmpty) return;

    await client
        .from('habit_entries')
        .upsert(rows, onConflict: 'user_id,day,habit_id');
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getHabitEntriesForDay(
    DateTime day,
  ) async {
    final d0 = DateTime(day.year, day.month, day.day);

    final res = await client
        .from('habit_entries')
        .select('habit_id, done, value, note, encrypted_payload')
        .eq('user_id', uid)
        .eq('day', _dateOnly(d0));

    final out = <String, Map<String, dynamic>>{};

    for (final raw in res as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final decryptedRow = await _decryptHabitEntryRow(row);

      final hid = (decryptedRow['habit_id'] ?? '').toString();

      if (hid.isEmpty) continue;

      out[hid] = {
        'done': (decryptedRow['done'] as bool?) ?? false,
        'value': (decryptedRow['value'] as num?)?.toInt() ?? 0,
        'note': (decryptedRow['note'] ?? '').toString(),
      };
    }

    return out;
  }
}