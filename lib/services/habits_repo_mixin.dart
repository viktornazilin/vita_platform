import 'core/base_repo.dart';
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
  Future<void> upsertHabitEntries(List<HabitEntryUpsert> entries);

  /// получить отметки за день (удобно для предзаполнения UI)
  Future<Map<String, Map<String, dynamic>>> getHabitEntriesForDay(DateTime day);
}

mixin HabitsRepoMixin on BaseRepo implements HabitsRepo {
  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Future<List<Habit>> listHabits() async {
    final res = await client
        .from('habits')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: true);

    return (res as List)
        .cast<Map<String, dynamic>>()
        .map((m) => Habit.fromMap(m))
        .toList();
  }

  @override
  Future<void> upsertHabitEntries(List<HabitEntryUpsert> entries) async {
    if (entries.isEmpty) return;

    final rows = entries.map((e) {
      final day = DateTime(e.day.year, e.day.month, e.day.day);
      return <String, dynamic>{
        'user_id': uid,
        'habit_id': e.habitId,
        'day': _dateOnly(day), // DATE в Postgres
        'done': e.done,
        'value': e.value < 0 ? 0 : e.value,
        'note': (e.note ?? '').trim(),
      };
    }).toList();

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
        .select('habit_id, done, value, note')
        .eq('user_id', uid)
        .eq('day', _dateOnly(d0));

    final out = <String, Map<String, dynamic>>{};
    for (final r in (res as List)) {
      final m = Map<String, dynamic>.from(r as Map);
      final hid = (m['habit_id'] ?? '').toString();
      if (hid.isEmpty) continue;
      out[hid] = {
        'done': (m['done'] as bool?) ?? false,
        'value': (m['value'] as num?)?.toInt() ?? 0,
        'note': (m['note'] ?? '').toString(),
      };
    }
    return out;
  }
}
