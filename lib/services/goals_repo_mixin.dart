import 'core/base_repo.dart';
import '../models/goal.dart';
import '../models/xp.dart';

mixin GoalsRepoMixin on BaseRepo {
  Future<List<Goal>> fetchGoals({String? lifeBlock}) async {
    var query = client.from('goals').select().eq('user_id', uid);
    if (lifeBlock != null) query = query.eq('life_block', lifeBlock);
    final res = await query.order('created_at', ascending: false);
    return (res as List)
        .map((m) => Goal.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<Goal> createGoal({
    required String title,
    required String description,
    required DateTime deadline,
    required String lifeBlock,
    int importance = 1,
    String emotion = '',
    double spentHours = 0,
    required DateTime startTime,
  }) async {
    final insert = {
      'user_id': uid,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'is_completed': false,
      'life_block': lifeBlock,
      'importance': importance,
      'emotion': emotion,
      'spent_hours': spentHours,
      'start_time': startTime.toIso8601String(),
    };
    final res = await client.from('goals').insert(insert).select().single();
    return Goal.fromMap(res);
  }

  Future<void> updateGoal(Goal goal) async {
    await client
        .from('goals')
        .update({
          'title': goal.title,
          'description': goal.description,
          'deadline': goal.deadline.toIso8601String(),
          'is_completed': goal.isCompleted,
          'life_block': goal.lifeBlock,
          'importance': goal.importance,
          'emotion': goal.emotion,
          'spent_hours': goal.spentHours,
          'start_time': goal.startTime.toIso8601String(),
        })
        .eq('id', goal.id)
        .eq('user_id', uid);
  }

  Future<void> deleteGoal(String id) async {
    await client.from('goals').delete().eq('id', id).eq('user_id', uid);
  }

  Future<List<Goal>> getGoalsByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final res = await client
        .from('goals')
        .select()
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());
    return (res as List)
        .map((m) => Goal.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<void> toggleGoalCompleted(String id, {bool? value}) async {
    final row = await client
        .from('goals')
        .select('is_completed')
        .eq('id', id)
        .eq('user_id', uid)
        .maybeSingle();
    if (row == null) return;

    final newVal = value ?? !(row['is_completed'] as bool? ?? false);

    await client
        .from('goals')
        .update({'is_completed': newVal})
        .eq('id', id)
        .eq('user_id', uid);

    if (newVal) {
      await addXP(10);
      final total = await getTotalHoursSpentOnDate(DateTime.now());
      final target = await getTargetHours();
      if (total >= target) {
        await addXP(20);
      }
    }
  }

  // =========================================================
  // AUTOCOMPLETE: динамические подсказки по истории задач
  // (используется в MassDailyEntrySheet во время ввода)
  // =========================================================

  /// Возвращает список названий задач, которые пользователь вводил ранее,
  /// подходящих под [query]. Результат отсортирован по "самым свежим".
  ///
  /// Реализация: берем последние записи по фильтру ilike и дедуплим локально,
  /// чтобы вернуть уникальные варианты.
  Future<List<String>> searchGoalTitles({
    required String query,
    int limit = 8,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final pattern = '%$q%';

    // Берём побольше, чтобы после дедупа всё равно было из чего выбрать.
    final rows = await client
        .from('goals')
        .select('title, created_at, deadline')
        .eq('user_id', uid)
        .ilike('title', pattern)
        .neq('title', '')
        // created_at может быть null в некоторых схемах, но у тебя он используется в fetchGoals.
        .order('created_at', ascending: false)
        .limit(200);

    final seen = <String>{};
    final out = <String>[];

    for (final r in (rows as List)) {
      final title = (r['title'] as String?)?.trim() ?? '';
      if (title.isEmpty) continue;

      final norm = title.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      if (norm.isEmpty) continue;
      if (seen.contains(norm)) continue;

      seen.add(norm);
      out.add(title);

      if (out.length >= limit) break;
    }

    return out;
  }

  // =========================================================
  // HISTORY: сырой список (если где-то ещё нужен)
  // =========================================================

  /// Возвращает историю задач (title + deadline) за период.
  /// Оставляем метод, но теперь MassDailyEntrySheet может жить без него.
  Future<List<Map<String, dynamic>>> listGoalTitleHistory({
    required DateTime start,
    required DateTime end,
  }) async {
    final res = await client
        .from('goals')
        .select('title, deadline')
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    return (res as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }

  // =========================================================
  // SUGGESTIONS: топ повторяющихся задач (оставляем, может пригодиться)
  // =========================================================

  Future<List<String>> suggestRecurringGoalTitles({
    int lookbackDays = 30,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: lookbackDays));
    final end = today.add(const Duration(days: 1));

    final res = await client
        .from('goals')
        .select('title, deadline')
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    final items = (res as List).cast<dynamic>();

    final Map<String, Set<String>> daysByTitle = {};
    final Map<String, int> totalByTitle = {};

    for (final raw in items) {
      final m = (raw as Map).cast<String, dynamic>();

      final title = (m['title'] ?? '').toString().trim();
      if (title.isEmpty) continue;

      DateTime? d;
      final dv = m['deadline'];
      if (dv is String) d = DateTime.tryParse(dv);
      if (dv is DateTime) d = dv;
      if (d == null) continue;

      final dayKey =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      (daysByTitle[title] ??= <String>{}).add(dayKey);
      totalByTitle[title] = (totalByTitle[title] ?? 0) + 1;
    }

    final candidates = daysByTitle.entries
        .where((e) => e.value.length >= 2)
        .map((e) {
          final title = e.key;
          final daysCount = e.value.length;
          final totalCount = totalByTitle[title] ?? daysCount;
          return _TitleStat(
            title: title,
            daysCount: daysCount,
            totalCount: totalCount,
          );
        })
        .toList();

    candidates.sort((a, b) {
      final byDays = b.daysCount.compareTo(a.daysCount);
      if (byDays != 0) return byDays;
      final byTotal = b.totalCount.compareTo(a.totalCount);
      if (byTotal != 0) return byTotal;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return candidates.take(5).map((e) => e.title).toList();
  }

  // ==== XP “тонкие” ====
  Future<XP> getXP() async {
    final res = await client
        .from('user_xp')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    if (res == null) {
      final created = await client
          .from('user_xp')
          .insert({'user_id': uid})
          .select()
          .single();
      return XP.fromMap(created);
    }
    return XP.fromMap(res);
  }

  Future<XP> addXP(int points) async {
    final current = await getXP();
    final updated = current.addXP(points);
    await client.from('user_xp').upsert(updated.toMap()).select().single();
    return updated;
  }

  // ==== вспомогательные ====
  Future<double> getTargetHours() async {
    final res = await client
        .from('users')
        .select('target_hours')
        .eq('id', uid)
        .maybeSingle();
    if (res == null || res['target_hours'] == null) return 14;
    return (res['target_hours'] as num).toDouble();
  }

  Future<double> getTotalHoursSpentOnDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final res = await client
        .from('goals')
        .select('spent_hours')
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    return (res as List).fold<double>(
      0,
      (sum, item) => sum + ((item['spent_hours'] ?? 0) as num).toDouble(),
    );
  }
}

class _TitleStat {
  final String title;
  final int daysCount;
  final int totalCount;

  const _TitleStat({
    required this.title,
    required this.daysCount,
    required this.totalCount,
  });
}
