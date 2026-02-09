import 'core/base_repo.dart';
import '../models/mood.dart';

mixin MoodsRepoMixin on BaseRepo {
  String _isoDateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String();

  Future<Mood?> getMoodByDate(DateTime date) async {
    final isoDate = _isoDateOnly(date);
    final res = await client
        .from('moods')
        .select()
        .eq('user_id', uid)
        .eq('date', isoDate)
        .maybeSingle();
    if (res == null) return null;
    return Mood.fromMap(res);
  }

  Future<Mood> upsertMood({
    required DateTime date,
    required String emoji,
    String note = '',
  }) async {
    final data = {
      'user_id': uid,
      'date': _isoDateOnly(date),
      'emoji': emoji,
      'note': note,
    };
    final res = await client
        .from('moods')
        .upsert(data, onConflict: 'user_id,date')
        .select()
        .single();
    return Mood.fromMap(res);
  }

  Future<void> deleteMoodByDate(DateTime date) async {
    final isoDate = _isoDateOnly(date);
    await client.from('moods').delete().eq('user_id', uid).eq('date', isoDate);
  }

  Future<List<Mood>> fetchMoods({int limit = 30}) async {
    final res = await client
        .from('moods')
        .select()
        .eq('user_id', uid)
        .order('date', ascending: false)
        .limit(limit);
    return (res as List)
        .map((m) => Mood.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  /// Для выборки по календарю: [from; to], включительно
  Future<List<Mood>> fetchMoodsRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final res = await client
        .from('moods')
        .select()
        .eq('user_id', uid)
        .gte('date', _isoDateOnly(from))
        .lte('date', _isoDateOnly(to))
        .order('date', ascending: false);
    return (res as List)
        .map((m) => Mood.fromMap(m as Map<String, dynamic>))
        .toList();
  }
}
