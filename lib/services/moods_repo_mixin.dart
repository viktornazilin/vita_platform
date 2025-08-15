import 'core/base_repo.dart';
import '../models/mood.dart';

mixin MoodsRepoMixin on BaseRepo {
  Future<Mood?> getMoodByDate(DateTime date) async {
    final isoDate = DateTime(date.year, date.month, date.day).toIso8601String();
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
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
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

  Future<List<Mood>> fetchMoods({int limit = 30}) async {
    final res = await client
        .from('moods')
        .select()
        .eq('user_id', uid)
        .order('date', ascending: false)
        .limit(limit);
    return (res as List).map((m) => Mood.fromMap(m as Map<String, dynamic>)).toList();
  }
}
