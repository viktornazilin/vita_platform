import 'core/base_repo.dart';
import '../models/goal.dart';
import '../models/xp.dart';

mixin GoalsRepoMixin on BaseRepo {
  Future<List<Goal>> fetchGoals({String? lifeBlock}) async {
    var query = client.from('goals').select().eq('user_id', uid);
    if (lifeBlock != null) query = query.eq('life_block', lifeBlock);
    final res = await query.order('created_at', ascending: false);
    return (res as List).map((m) => Goal.fromMap(m as Map<String, dynamic>)).toList();
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
    await client.from('goals').update({
      'title': goal.title,
      'description': goal.description,
      'deadline': goal.deadline.toIso8601String(),
      'is_completed': goal.isCompleted,
      'life_block': goal.lifeBlock,
      'importance': goal.importance,
      'emotion': goal.emotion,
      'spent_hours': goal.spentHours,
      'start_time': goal.startTime.toIso8601String(),
    }).eq('id', goal.id).eq('user_id', uid);
  }

  Future<void> deleteGoal(String id) async {
    await client.from('goals').delete().eq('id', id).eq('user_id', uid);
  }

  Future<List<Goal>> getGoalsByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final res = await client.from('goals').select()
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());
    return (res as List).map((m) => Goal.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<void> toggleGoalCompleted(String id, {bool? value}) async {
    final row = await client.from('goals').select('is_completed')
        .eq('id', id).eq('user_id', uid).maybeSingle();
    if (row == null) return;
    final newVal = value ?? !(row['is_completed'] as bool? ?? false);
    await client.from('goals').update({'is_completed': newVal}).eq('id', id).eq('user_id', uid);

    if (newVal) {
      await addXP(10);
      final total = await getTotalHoursSpentOnDate(DateTime.now());
      final target = await getTargetHours();
      if (total >= target) {
        await addXP(20);
      }
    }
  }

  // ==== XP “тонкие” ====
  Future<XP> getXP() async {
    final res = await client.from('user_xp').select().eq('user_id', uid).maybeSingle();
    if (res == null) {
      final created = await client.from('user_xp').insert({'user_id': uid}).select().single();
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
    final res = await client.from('users').select('target_hours').eq('id', uid).maybeSingle();
    if (res == null || res['target_hours'] == null) return 14;
    return (res['target_hours'] as num).toDouble();
  }

  Future<double> getTotalHoursSpentOnDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final res = await client.from('goals').select('spent_hours')
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());
    return (res as List).fold<double>(0, (sum, item) => sum + ((item['spent_hours'] ?? 0) as num).toDouble());
  }
}
