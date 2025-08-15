import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart';
// === доменные модели (ВАЖНО: алиасы, чтобы не конфликтовало имя Category) ===
import '../domain/category.dart' as dm;
import '../domain/transaction_item.dart';
import '../domain/jar.dart';
import '../domain/jar_allocation.dart';
// === ваши текущие модели/классы — без изменений ===
import '../models/goal.dart';
import '../models/mood.dart';
import '../models/xp.dart';

/// Интерфейс финансового репозитория (бюджет/категории/копилки).
abstract class FinanceRepo {
  Future<List<dm.Category>> listCategories({required String kind}); // 'income' | 'expense'
  Future<String> ensureCategory(String name, String kind); // вернёт id (создаст, если не было)
  Future<void> addTransaction({
    required DateTime ts,
    required String kind, // 'income' | 'expense'
    required String categoryId,
    required double amount,
    String? note,
  });
  Future<List<TransactionItem>> listTransactionsByDay(DateTime date);
  Future<Map<String, double>> sumByMonth({required DateTime monthStart}); // {'income': X, 'expense': Y}
  Future<List<Jar>> listJars();
  Future<String> addJar({required String title, double? targetAmount, required double percentOfFree});
  Future<void> updateJarAmount({required String jarId, required double delta});
  Future<void> addJarAllocation({required String jarId, required DateTime periodMonth, required double amount});
  Future<List<TransactionItem>> listTransactionsBetween(DateTime from, DateTime to);
  Future<void> deleteTransaction(String id);
  Future<void> deleteCategory(String categoryId);
  Future<void> setCategoryLimit({required String categoryId, double? limit});
  Future<Map<dm.Category, double>> monthlyExpenseByCategory({required DateTime monthStart});
  Future<bool> hasAnyJarAllocationForMonth({required DateTime periodMonth});
  Future<List<JarAllocation>> listJarAllocationsForMonth({
    required DateTime periodMonth,
  });

  Future<void> deleteJarAllocationsForMonth({
    required DateTime periodMonth,
  });
  Future<void> deleteJar(String jarId);
}

/// Ваш основной репозиторий. Теперь он реализует ещё и FinanceRepo.
class DbRepo implements FinanceRepo {
  final SupabaseClient _client;

  DbRepo(this._client);

  // ====================== helpers ======================
  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Not authenticated');
    }
    return uid;
  }

  String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime _monthStart(DateTime d) => DateTime(d.year, d.month, 1);

  // ====================== USERS ======================
  Future<List<String>> getUserLifeBlocks() async {
    final res = await _client
        .from('users')
        .select('life_blocks')
        .eq('id', _uid)
        .maybeSingle();

    if (res == null || res['life_blocks'] == null) return [];
    return List<String>.from(res['life_blocks'] as List);
  }

  // ====================== GOALS ======================
  Future<List<Goal>> fetchGoals({String? lifeBlock}) async {
    var query = _client.from('goals').select().eq('user_id', _uid);
    if (lifeBlock != null) {
      query = query.eq('life_block', lifeBlock);
    }
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
      'user_id': _uid,
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

    final res = await _client.from('goals').insert(insert).select().single();
    return Goal.fromMap(res as Map<String, dynamic>);
  }

  Future<void> updateGoal(Goal goal) async {
    await _client
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
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final res = await _client
        .from('goals')
        .select()
        .eq('user_id', _uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());
    return (res as List).map((m) => Goal.fromMap(m as Map<String, dynamic>)).toList();
  }

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

  // ====================== SETTINGS ======================
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
      0,
      (sum, item) => sum + ((item['spent_hours'] ?? 0) as num).toDouble(),
    );
  }

  // ====================== MOODS ======================
  Future<Mood?> getMoodByDate(DateTime date) async {
    final isoDate = DateTime(date.year, date.month, date.day).toIso8601String();
    final res = await _client
        .from('moods')
        .select()
        .eq('user_id', _uid)
        .eq('date', isoDate)
        .maybeSingle();
    if (res == null) return null;
    return Mood.fromMap(res as Map<String, dynamic>);
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
    return Mood.fromMap(res as Map<String, dynamic>);
  }

  Future<List<Mood>> fetchMoods({int limit = 30}) async {
    final res = await _client
        .from('moods')
        .select()
        .eq('user_id', _uid)
        .order('date', ascending: false)
        .limit(limit);
    return (res as List).map((m) => Mood.fromMap(m as Map<String, dynamic>)).toList();
  }

  // ====================== XP ======================
  Future<XP> getXP() async {
    final res = await _client
        .from('user_xp')
        .select()
        .eq('user_id', _uid)
        .maybeSingle();

    if (res == null) {
      final created =
          await _client.from('user_xp').insert({'user_id': _uid}).select().single();
      return XP.fromMap(created as Map<String, dynamic>);
    }
    return XP.fromMap(res as Map<String, dynamic>);
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
    return Map<String, dynamic>.from(res as Map);
  }

  // ====================== EXPENSES (старый интерфейс — СОХРАНЁН) ======================
  Future<void> addExpense({
    required DateTime date,
    required double amount,
    required String category,
    String note = '',
  }) async {
    final d = DateTime(date.year, date.month, date.day);
    final dayStr = _dateStr(d);

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
    var q = _client.from('expenses').select().eq('user_id', _uid);

    if (from != null) q = q.gte('date', _dateStr(from));
    if (to != null) q = q.lte('date', _dateStr(to));

    final res = await q
        .order('date', ascending: false)
        .order('created_at', ascending: false)
        .limit(120);

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
    final res = await _client
        .from('expenses')
        .select('amount, date')
        .eq('user_id', _uid)
        .gte('date', _dateStr(start))
        .lte('date', _dateStr(end));

    return (res as List).fold<double>(
      0.0,
      (sum, row) => sum + ((row['amount'] ?? 0) as num).toDouble(),
    );
  }

  // ====================== FinanceRepo (новый функционал бюджета) ======================

  /// Категории (income/expense)
  @override
  Future<List<dm.Category>> listCategories({required String kind}) async {
    final res = await _client
        .from('categories')
        .select()
        .eq('user_id', _uid)
        .eq('kind', kind)
        .order('name', ascending: true);
    return (res as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return dm.Category(
        id: map['id'] as String,
        name: map['name'] as String,
        kind: map['kind'] as String,
      );
    }).toList();
  }

  /// Создаёт категорию, если нет; возвращает id.
  @override
  Future<String> ensureCategory(String name, String kind) async {
    // пытаемся найти
    final existing = await _client
        .from('categories')
        .select('id')
        .eq('user_id', _uid)
        .eq('kind', kind)
        .eq('name', name)
        .maybeSingle();

    if (existing != null) {
      return (existing['id'] as String);
    }

    final inserted = await _client
        .from('categories')
        .insert({
          'user_id': _uid,
          'name': name,
          'kind': kind,
        })
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  @override
Future<void> addTransaction({
  required DateTime ts,
  required String kind, // 'income' или 'expense'
  required String categoryId,
  required double amount,
  String? note,
}) async {
  // 1. Проверка лимита для расходной категории
  if (kind == 'expense') {
    final limitRow = await _client
        .from('categories')
        .select('limit_amount')
        .eq('id', categoryId)
        .eq('user_id', _uid)
        .maybeSingle();

    final limit = (limitRow?['limit_amount'] as num?)?.toDouble();

    if (limit != null && limit > 0) {
      final monthStart = DateTime(ts.year, ts.month, 1);
      final nextMonth = DateTime(ts.year, ts.month + 1, 1);

      final spentRes = await _client
          .from('transactions')
          .select('amount')
          .eq('user_id', _uid)
          .eq('category_id', categoryId)
          .gte('ts', monthStart.toIso8601String())
          .lt('ts', nextMonth.toIso8601String());

      final spent = (spentRes as List)
          .fold<double>(0, (sum, r) => sum + (r['amount'] as num).toDouble());

      if (spent + amount > limit) {
        throw Exception('Превышен лимит для категории');
      }
    }
  }

  // 2. Добавление транзакции
  await _client.from('transactions').insert({
    'user_id': _uid,
    'ts': ts.toIso8601String(),
    'kind': kind,
    'category_id': categoryId,
    'amount': amount,
    'note': note ?? '',
  });
}


  /// Транзакции за день
  @override
  Future<List<TransactionItem>> listTransactionsByDay(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final res = await _client
        .from('transactions')
        .select()
        .eq('user_id', _uid)
        .gte('ts', start.toIso8601String())
        .lt('ts', end.toIso8601String())
        .order('ts', ascending: false);

    return (res as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return TransactionItem(
        id: map['id'] as String,
        ts: DateTime.parse(map['ts'] as String),
        kind: map['kind'] as String,
        categoryId: map['category_id'] as String,
        amount: (map['amount'] as num).toDouble(),
        note: (map['note'] as String?)?.toString(),
      );
    }).toList();
  }

  /// Суммы за месяц по типам ('income'/'expense')
  @override
  Future<Map<String, double>> sumByMonth({required DateTime monthStart}) async {
    final start = _monthStart(monthStart);
    final end = DateTime(start.year, start.month + 1, 1);

    // агрегируем на стороне БД
    final res = await _client
        .rpc('sum_transactions_by_kind_for_period', params: {
          'p_user_id': _uid,
          'p_from': start.toIso8601String(),
          'p_to': end.toIso8601String(),
        })
        .select();

    // Функция может вернуть список вроде: [{kind:'income', sum:123.45}, {kind:'expense', sum:67.89}]
    final map = <String, double>{'income': 0.0, 'expense': 0.0};
    if (res is List) {
      for (final row in res) {
        final r = Map<String, dynamic>.from(row as Map);
        map[r['kind'] as String] = (r['sum'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return map;
  }

  /// Список копилок
  Future<List<Jar>> listJars() async {
  final rows = await _client
      .from('jars')
      .select('id, title, target_amount, current_amount, percent_of_free, active, user_id')
      .eq('user_id', _uid)
      .order('title', ascending: true);

  // На всякий случай приведём тип:
  final list = (rows as List).cast<Map<String, dynamic>>();

  return list.map((r) {
    return Jar(
      id: r['id'] as String,
      title: (r['title'] ?? '') as String,
      targetAmount: (r['target_amount'] as num?)?.toDouble(),
      currentAmount: (r['current_amount'] as num?)?.toDouble() ?? 0.0,
      percentOfFree: (r['percent_of_free'] as num?)?.toDouble() ?? 0.0,
      active: (r['active'] as bool?) ?? true,
    );
  }).toList();
}


  /// Создание копилки
  // DbRepo

Future<String> addJar({
  required String title,
  double? targetAmount,
  required double percentOfFree,
}) async {
  final data = {
    'user_id': _uid,                   // обязательно!
    'title': title,
    'target_amount': targetAmount,     // nullable
    'percent_of_free': percentOfFree,  // double
    'current_amount': 0.0,             // стартовое значение
    'active': true,
  };

  final res = await _client
      .from('jars')
      .insert(data)
      .select('id')
      .single();

  return (res['id'] as String);
}
// === В DbRepo ===

// Разбивка расходов по категориям за месяц
Future<Map<dm.Category, double>> monthlyExpenseByCategory({
  required DateTime monthStart,
}) async {
  final nextMonth = DateTime(monthStart.year, monthStart.month + 1, 1);

  final rows = await _client
      .from('transactions')
      .select('category_id, amount')
      .eq('user_id', _uid)
      .eq('kind', 'expense')
      .gte('ts', monthStart.toIso8601String())
      .lt('ts', nextMonth.toIso8601String());

  // Суммируем по category_id
  final Map<String, double> byCat = {};
  for (final r in (rows as List)) {
    final id = r['category_id'] as String?;
    if (id == null) continue;
    byCat[id] = (byCat[id] ?? 0) + (r['amount'] as num).toDouble();
  }

  if (byCat.isEmpty) return {};

  // Получаем категории одним запросом
  final catsRes = await _client
      .from('categories')
      .select()
      .eq('user_id', _uid)
      .inFilter('id', byCat.keys.toList());

  final List<dm.Category> cats = (catsRes as List)
      .map((m) => dm.Category.fromMap(Map<String, dynamic>.from(m)))
      .toList();

  final map = <dm.Category, double>{};
  for (final c in cats) {
    final val = byCat[c.id] ?? 0;
    map[c] = val;
  }
  return map;
}

Future<bool> hasAnyJarAllocationForMonth({required DateTime periodMonth}) async {
  final monthStr = '${periodMonth.year.toString().padLeft(4, '0')}-${periodMonth.month.toString().padLeft(2, '0')}-01';
  final res = await _client
      .from('jar_allocations')
      .select('id')
      .eq('user_id', _uid)
      .eq('period_month', monthStr)
      .limit(1);

  return (res as List).isNotEmpty;
}

// Удалить транзакцию
Future<void> deleteTransaction(String id) async {
  await _client.from('transactions').delete()
      .eq('id', id).eq('user_id', _uid);
}

// Удалить категорию
Future<void> deleteCategory(String categoryId) async {
  await _client.from('categories').delete()
      .eq('id', categoryId).eq('user_id', _uid);
}

// Лимит по расходной категории
Future<void> setCategoryLimit({
  required String categoryId,
  double? limit,
}) async {
  await _client
      .from('categories')
      .update({'limit_amount': limit})
      .eq('id', categoryId)
      .eq('user_id', _uid);
}


  /// Обновить сумму в копилке (+/-)
  @override
Future<void> updateJarAmount({
  required String jarId,
  required double delta,
}) async {
  try {
    // пробуем RPC, если функция есть
    await _client.rpc('increment_jar_amount', params: {
      'p_delta': delta,
      'p_jar_id': jarId,
      'p_user_id': _uid,
    });
    return;
  } on PostgrestException catch (e) {
    final isMissingRpc = e.code == 'PGRST202' ||
        (e.message).toLowerCase().contains('increment_jar_amount');
    if (!isMissingRpc) rethrow;
    // иначе — фолбэк без RPC: read-modify-write
  }

  // 1) читаем текущее значение
  final row = await _client
      .from('jars')
      .select('current_amount')
      .eq('id', jarId)
      .eq('user_id', _uid)
      .maybeSingle();

  final current = (row?['current_amount'] as num?)?.toDouble() ?? 0.0;
  final next = current + delta;

  // 2) пишем новое
  await _client
      .from('jars')
      .update({'current_amount': next})
      .eq('id', jarId)
      .eq('user_id', _uid);
} 
  /// Записать факт распределения за месяц
  @override
Future<void> addJarAllocation({
  required String jarId,
  required DateTime periodMonth,
  required double amount,
}) async {
  final monthStr = _dateStr(DateTime(periodMonth.year, periodMonth.month, 1));

  // 1. Проверка на существующую аллокацию
  final exists = await _client
      .from('jar_allocations')
      .select('id')
      .eq('user_id', _uid)
      .eq('jar_id', jarId)
      .eq('period_month', monthStr)
      .maybeSingle();

  if (exists != null) {
    throw Exception('Аллокация за этот месяц уже есть');
  }

  // 2. Запись аллокации
  await _client.from('jar_allocations').insert({
    'user_id': _uid,
    'jar_id': jarId,
    'period_month': monthStr,
    'amount': amount,
  });
}

  Future<List<TransactionItem>> listTransactionsBetween(DateTime from, DateTime to) async {
  try {
    final res = await _client
        .from('transactions')
        .select()
        .eq('user_id', _uid)
        .gte('ts', from.toIso8601String())
        .lt('ts', to.toIso8601String())
        .order('ts', ascending: false);

    return (res as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return TransactionItem(
        id: map['id'] as String,
        ts: DateTime.parse(map['ts'] as String),
        kind: map['kind'] as String,
        categoryId: (map['category_id'] ?? '') as String,
        amount: (map['amount'] as num).toDouble(),
        note: (map['note'] as String?)?.toString(),
      );
    }).toList();
  } on PostgrestException catch (e) {
    if (e.code == '42703' || e.code == '42501') return [];
    rethrow;
  }
}
@override
Future<List<JarAllocation>> listJarAllocationsForMonth({
  required DateTime periodMonth,
}) async {
  final monthStr =
      '${periodMonth.year.toString().padLeft(4, '0')}-${periodMonth.month.toString().padLeft(2, '0')}-01';

  final rows = await _client
      .from('jar_allocations')
      .select('jar_id, amount')
      .eq('user_id', _uid)
      .eq('period_month', monthStr)
      .order('jar_id');

  final list = (rows as List).cast<Map<String, dynamic>>();
  return list.map((m) => JarAllocation.fromMap(m)).toList();
}

@override
Future<void> deleteJarAllocationsForMonth({
  required DateTime periodMonth,
}) async {
  final monthStr =
      '${periodMonth.year.toString().padLeft(4, '0')}-${periodMonth.month.toString().padLeft(2, '0')}-01';

  await _client
      .from('jar_allocations')
      .delete()
      .eq('user_id', _uid)
      .eq('period_month', monthStr);
}
@override
Future<void> deleteJar(String jarId) async {
  await Supabase.instance.client
      .from('jars')
      .delete()
      .eq('id', jarId);
}

}
