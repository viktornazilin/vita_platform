import 'core/base_repo.dart';
import '../models/goal.dart';
import '../models/xp.dart';

mixin GoalsRepoMixin on BaseRepo {
  // =========================
  // Goals CRUD
  // =========================

  Future<List<Goal>> fetchGoals({String? lifeBlock, String? userGoalId}) async {
    var q = client.from('goals').select().eq('user_id', uid);

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q.order('created_at', ascending: false);
    return (res as List)
        .map((m) => Goal.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<Goal> createGoal({
    required String title,
    String description = '',
    required DateTime deadline,
    required String lifeBlock,
    int importance = 1,
    String emotion = '',
    double spentHours = 1.0,
    required DateTime startTime,
    String? userGoalId,
  }) async {
    final insert = <String, dynamic>{
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
      'user_goal_id': userGoalId,
    };

    final res = await client.from('goals').insert(insert).select().single();
    return Goal.fromMap(res);
  }

  Future<List<Goal>> createGoalsBulk(
    List<Map<String, dynamic>> items,
  ) async {
    if (items.isEmpty) return [];

    final payload = items
        .map(
          (item) => <String, dynamic>{
            'user_id': uid,
            'title': item['title'],
            'description': item['description'] ?? '',
            'deadline': _asIsoString(item['deadline']),
            'is_completed': item['is_completed'] ?? false,
            'life_block': item['life_block'] ?? 'general',
            'importance': item['importance'] ?? 1,
            'emotion': item['emotion'] ?? '',
            'spent_hours': _asDouble(item['spent_hours'] ?? 1.0),
            'start_time': _asIsoString(item['start_time']),
            'user_goal_id': item['user_goal_id'],
          },
        )
        .toList();

    final res = await client.from('goals').insert(payload).select();
    return (res as List)
        .map((m) => Goal.fromMap(m as Map<String, dynamic>))
        .toList();
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
          'user_goal_id': _extractUserGoalId(goal),
        })
        .eq('id', goal.id)
        .eq('user_id', uid);
  }

  Future<void> updateGoalFields({
    required String goalId,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    String? lifeBlock,
    int? importance,
    String? emotion,
    double? spentHours,
    DateTime? startTime,
    Object? userGoalId = _unset,
  }) async {
    final update = <String, dynamic>{};

    if (title != null) update['title'] = title;
    if (description != null) update['description'] = description;
    if (deadline != null) update['deadline'] = deadline.toIso8601String();
    if (isCompleted != null) update['is_completed'] = isCompleted;
    if (lifeBlock != null) update['life_block'] = lifeBlock;
    if (importance != null) update['importance'] = importance;
    if (emotion != null) update['emotion'] = emotion;
    if (spentHours != null) update['spent_hours'] = spentHours;
    if (startTime != null) update['start_time'] = startTime.toIso8601String();

    if (!identical(userGoalId, _unset)) {
      update['user_goal_id'] = userGoalId;
    }

    if (update.isEmpty) return;

    await client.from('goals').update(update).eq('id', goalId).eq('user_id', uid);
  }

  Future<void> deleteGoal(String id) async {
    final dynamic idValue = int.tryParse(id) ?? id;

    final res = await client
        .from('goals')
        .delete()
        .eq('id', idValue)
        .eq('user_id', uid)
        .select('id');

    final deleted = (res as List).cast<Map<String, dynamic>>();
    if (deleted.isEmpty) {
      final still = await client
          .from('goals')
          .select('id,user_id')
          .eq('id', idValue)
          .maybeSingle();

      throw Exception(
        'Delete matched 0 rows. uid=$uid id=$idValue stillExists=${still != null} row=$still',
      );
    }
  }

  Future<List<Goal>> getGoalsByDate(
    DateTime date, {
    String? lifeBlock,
    String? userGoalId,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    var q = client
        .from('goals')
        .select()
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q.order('start_time', ascending: true);

    return (res as List)
        .map((m) => Goal.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<List<Goal>> getGoalsLinkedToUserGoal(String userGoalId) async {
    final res = await client
        .from('goals')
        .select()
        .eq('user_id', uid)
        .eq('user_goal_id', userGoalId)
        .order('start_time', ascending: true);

    return (res as List)
        .map((m) => Goal.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<void> unlinkGoalsFromUserGoal(String userGoalId) async {
    await client
        .from('goals')
        .update({'user_goal_id': null})
        .eq('user_id', uid)
        .eq('user_goal_id', userGoalId);
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

  // =========================
  // Autocomplete / Suggestions
  // =========================

  Future<List<String>> searchGoalTitles({
    required String query,
    int limit = 8,
    String? lifeBlock,
    String? userGoalId,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final pattern = '%$q%';

    var req = client
        .from('goals')
        .select('title, created_at, deadline, life_block, user_goal_id')
        .eq('user_id', uid)
        .ilike('title', pattern)
        .neq('title', '');

    if (lifeBlock != null) {
      req = req.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      req = req.eq('user_goal_id', userGoalId);
    }

    final rows = await req.order('created_at', ascending: false).limit(200);

    final seen = <String>{};
    final out = <String>[];

    for (final r in (rows as List)) {
      final title = (r['title'] as String?)?.trim() ?? '';
      if (title.isEmpty) continue;

      final norm = title.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      if (norm.isEmpty || seen.contains(norm)) continue;

      seen.add(norm);
      out.add(title);

      if (out.length >= limit) break;
    }

    return out;
  }

  Future<List<Map<String, dynamic>>> listGoalTitleHistory({
    required DateTime start,
    required DateTime end,
    String? lifeBlock,
    String? userGoalId,
  }) async {
    var q = client
        .from('goals')
        .select('title, deadline, life_block, user_goal_id')
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q;

    return (res as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }

  Future<List<String>> suggestRecurringGoalTitles({
    int lookbackDays = 30,
    String? lifeBlock,
    String? userGoalId,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: lookbackDays));
    final end = today.add(const Duration(days: 1));

    var q = client
        .from('goals')
        .select('title, deadline, life_block, user_goal_id')
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q;
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
        .map(
          (e) => _TitleStat(
            title: e.key,
            daysCount: e.value.length,
            totalCount: totalByTitle[e.key] ?? e.value.length,
          ),
        )
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

  // =========================
  // XP
  // =========================

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

  // =========================
  // Reports helpers
  // =========================

  Future<double> getTargetHours() async {
    final res = await client
        .from('users')
        .select('target_hours')
        .eq('id', uid)
        .maybeSingle();
    if (res == null || res['target_hours'] == null) return 14;
    return (res['target_hours'] as num).toDouble();
  }

  Future<List<Goal>> fetchGoalsInRange({
    required DateTime start,
    required DateTime end,
    String? lifeBlock,
    String? userGoalId,
  }) async {
    var q = client
        .from('goals')
        .select()
        .eq('user_id', uid)
        .gte('start_time', start.toIso8601String())
        .lt('start_time', end.toIso8601String());

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q.order('start_time', ascending: true);

    return (res as List)
        .map((m) => Goal.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<double> getTotalHoursSpentOnDate(
    DateTime date, {
    String? lifeBlock,
    String? userGoalId,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    var q = client
        .from('goals')
        .select('spent_hours, life_block, user_goal_id')
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q;

    return (res as List).fold<double>(
      0,
      (sum, item) => sum + ((item['spent_hours'] ?? 0) as num).toDouble(),
    );
  }

  // =========================
  // Helpers
  // =========================

  static const Object _unset = Object();

  String _asIsoString(dynamic value) {
    if (value is DateTime) return value.toIso8601String();
    if (value is String) return value;
    throw ArgumentError('Expected DateTime or ISO string, got: $value');
  }

  double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    return 0;
  }

  dynamic _extractUserGoalId(Goal goal) {
    try {
      return (goal as dynamic).userGoalId;
    } catch (_) {
      return null;
    }
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