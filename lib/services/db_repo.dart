import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/goal.dart';
import '../models/mood.dart';
import '../models/xp.dart';

class DbRepo {
  final SupabaseClient _client;

  DbRepo(this._client);

  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Not authenticated');
    }
    return uid;
  }

  Future<List<String>> getUserLifeBlocks() async {
    final res = await _client
        .from('users')
        .select('life_blocks')
        .eq('id', _uid)
        .maybeSingle();

    if (res == null || res['life_blocks'] == null) return [];
    return List<String>.from(res['life_blocks']);
  }

  // ===== GOALS =====
  Future<List<Goal>> fetchGoals({String? lifeBlock}) async {
    var query = _client.from('goals').select().eq('user_id', _uid);
    if (lifeBlock != null) {
      query = query.eq('life_block', lifeBlock);
    }
    final res = await query.order('created_at', ascending: false);
    return (res as List).map((m) => Goal.fromMap(m)).toList();
  }

  Future<Goal> createGoal({
  required String title,
  required String description,
  required DateTime deadline,
  required String lifeBlock,
  int importance = 1,
  String emotion = '',
  double spentHours = 0,
  required DateTime startTime, // <-- новое поле
}) async {
  final insert = {
    'user_id': _uid,
    'title': title,
    'description': description,
    'deadline': deadline.toIso8601String(),
    'is_completed': false,
    'life_block': lifeBlock,
    'importance': importance,
    'emotion': emotion,
    'spent_hours': spentHours,
    'start_time': startTime.toIso8601String(), // <-- сохраняем в БД
  };

  final res = await _client.from('goals').insert(insert).select().single();
  return Goal.fromMap(res);
}


  Future<void> updateGoal(Goal goal) async {
  await _client
      .from('goals')
      .update({
        'title': goal.title,
        'description': goal.description,
        'deadline': goal.deadline.toIso8601String(),
        'is_completed': goal.isCompleted,
        'life_block': goal.lifeBlock,                 // <-- если редактируешь блок
        'importance': goal.importance,
        'emotion': goal.emotion,
        'spent_hours': goal.spentHours,
        'start_time': goal.startTime.toIso8601String(), // <-- ВАЖНО: пишем время начала
      })
      .eq('id', goal.id)
      .eq('user_id', _uid);
}


  Future<void> deleteGoal(String id) async {
    await _client.from('goals').delete().eq('id', id).eq('user_id', _uid);
  }

  Future<void> completeGoal(String id) async {
    final goal =
        await _client.from('goals').select().eq('id', id).maybeSingle();
    if (goal == null) return;

    await _client.from('goals').update({'is_completed': true}).eq('id', id);

    // XP за выполнение
    await addXP(10);
  }

  Future<List<Goal>> getGoalsByDate(DateTime date) async {
    final res = await _client
        .from('goals')
        .select()
        .eq('user_id', _uid)
        .gte('deadline',
            DateTime(date.year, date.month, date.day).toIso8601String())
        .lt('deadline',
            DateTime(date.year, date.month, date.day + 1).toIso8601String());
    return (res as List).map((m) => Goal.fromMap(m)).toList();
  }

  // ===== Доп. методы для управления задачами =====
  Future<void> toggleGoalCompleted(String id, {bool? value}) async {
    final row = await _client
        .from('goals')
        .select('is_completed')
        .eq('id', id)
        .eq('user_id', _uid)
        .maybeSingle();
    if (row == null) return;

    final newVal = value ?? !(row['is_completed'] as bool? ?? false);

    await _client
        .from('goals')
        .update({'is_completed': newVal})
        .eq('id', id)
        .eq('user_id', _uid);

    if (newVal) {
      await addXP(10);
      final total = await getTotalHoursSpentOnDate(DateTime.now());
      final target = await getTargetHours();
      if (total >= target) {
        await addXP(20);
      }
    }
  }

  Future<void> setGoalSpentHours(String id, double hours) async {
    await _client
        .from('goals')
        .update({'spent_hours': hours})
        .eq('id', id)
        .eq('user_id', _uid);
  }

  Future<void> setGoalEmotion(String id, String emotion) async {
    await _client
        .from('goals')
        .update({'emotion': emotion})
        .eq('id', id)
        .eq('user_id', _uid);
  }

  Future<void> setGoalImportance(String id, int importance) async {
    await _client
        .from('goals')
        .update({'importance': importance})
        .eq('id', id)
        .eq('user_id', _uid);
  }

  // ===== SETTINGS =====
  Future<void> saveUserSettings({
    required Map<String, double> weights,
    required double targetHours,
  }) async {
    await _client.from('users').update({
      'priorities': weights.keys.toList(),
      'weights': weights.values.toList(),
      'target_hours': targetHours,
    }).eq('id', _uid);
  }

  Future<double> getLifeBlockWeight(String block) async {
    final res = await _client
        .from('users')
        .select('priorities, weights')
        .eq('id', _uid)
        .maybeSingle();
    if (res == null || res['priorities'] == null) return 1.0;
    final idx = (res['priorities'] as List).indexOf(block);
    if (idx == -1) return 1.0;
    return (res['weights'][idx] as num).toDouble();
  }

  Future<double> getTargetHours() async {
    final res = await _client
        .from('users')
        .select('target_hours')
        .eq('id', _uid)
        .maybeSingle();
    if (res == null || res['target_hours'] == null) return 14;
    return (res['target_hours'] as num).toDouble();
  }

  Future<double> getTotalHoursSpentOnDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final res = await _client
        .from('goals')
        .select('spent_hours')
        .eq('user_id', _uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    return (res as List).fold<double>(
        0, (sum, item) => sum + ((item['spent_hours'] ?? 0) as num).toDouble());
  }

  // ===== MOODS =====
  Future<Mood?> getMoodByDate(DateTime date) async {
    final isoDate = DateTime(date.year, date.month, date.day).toIso8601String();
    final res = await _client
        .from('moods')
        .select()
        .eq('user_id', _uid)
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
      'user_id': _uid,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'emoji': emoji,
      'note': note,
    };
    final res = await _client
        .from('moods')
        .upsert(data, onConflict: 'user_id,date')
        .select()
        .single();
    return Mood.fromMap(res);
  }

  Future<List<Mood>> fetchMoods({int limit = 30}) async {
    final res = await _client
        .from('moods')
        .select()
        .eq('user_id', _uid)
        .order('date', ascending: false)
        .limit(limit);
    return (res as List).map((m) => Mood.fromMap(m)).toList();
  }

  // ===== XP =====
  Future<XP> getXP() async {
    final res = await _client
        .from('user_xp')
        .select()
        .eq('user_id', _uid)
        .maybeSingle();

    if (res == null) {
      final created =
          await _client.from('user_xp').insert({'user_id': _uid}).select().single();
      return XP.fromMap(created);
    }
    return XP.fromMap(res);
  }

  Future<XP> addXP(int points) async {
    final current = await getXP();
    final updated = current.addXP(points);

    await _client.from('user_xp').upsert(updated.toMap()).select().single();
    return updated;
  }

  Future<Map<String, dynamic>?> getQuestionnaireResults() async {
    final res = await _client
        .from('users')
        .select(
            'has_completed_questionnaire, age, health, goals, dreams, strengths, weaknesses, priorities, life_blocks')
        .eq('id', _uid)
        .maybeSingle();

    if (res == null) return null;
    return Map<String, dynamic>.from(res);
  }

  // ===== EXPENSES =====
  Future<void> addExpense({
    required DateTime date,
    required double amount,
    required String category,
    String note = '',
  }) async {
    // Для колонки DATE передаём YYYY-MM-DD (без времени)
    final d = DateTime(date.year, date.month, date.day);
    final dayStr =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    await _client.from('expenses').insert({
      'user_id': _uid,
      'date': dayStr,
      'amount': amount,
      'category': category.isEmpty ? 'Прочее' : category,
      'note': note,
    });
  }

  Future<void> deleteExpense(String id) async {
    await _client.from('expenses').delete().eq('id', id).eq('user_id', _uid);
  }

  Future<List<Map<String, dynamic>>> fetchExpenses({
  DateTime? from,
  DateTime? to,
}) async {
  // Сразу select(), чтобы получить билдер с фильтрами
  var q = _client
      .from('expenses')
      .select()
      .eq('user_id', _uid);

  // Фильтры по дате (DATE => 'YYYY-MM-DD')
  if (from != null) {
    final s =
        '${from.year.toString().padLeft(4, '0')}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
    q = q.gte('date', s);
  }
  if (to != null) {
    final e =
        '${to.year.toString().padLeft(4, '0')}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}';
    q = q.lte('date', e);
  }

  // Сортировка и лимит — в самом конце
  final res = await q
      .order('date', ascending: false)
      .order('created_at', ascending: false)
      .limit(120);

  // Нормализуем типы
  return (res as List)
      .map<Map<String, dynamic>>((e) => {
            ...Map<String, dynamic>.from(e as Map),
            'date': DateTime.parse(e['date'] as String),
            'amount': (e['amount'] as num).toDouble(),
            'category': (e['category'] ?? 'Прочее') as String,
            'note': (e['note'] ?? '') as String,
          })
      .toList();
}



  Future<double> getTotalExpensesInRange(DateTime start, DateTime end) async {
    final s =
        '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final e =
        '${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

    final res = await _client
        .from('expenses')
        .select('amount, date')
        .eq('user_id', _uid)
        .gte('date', s)
        .lte('date', e);

    return (res as List).fold<double>(
      0.0,
      (sum, row) => sum + ((row['amount'] ?? 0) as num).toDouble(),
    );
  }
}
