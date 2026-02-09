import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/category.dart' as dm;
import '../domain/transaction_item.dart';
import '../domain/jar.dart';
import '../domain/jar_allocation.dart';

import 'core/base_repo.dart';

abstract class FinanceRepo {
  Future<List<dm.Category>> listCategories({required String kind});
  Future<String> ensureCategory(String name, String kind);

  Future<void> addTransaction({
    required DateTime ts,
    required String kind, // 'expense' | 'income'
    required String categoryId,
    required double amount,
    String? note,
  });

  Future<List<TransactionItem>> listTransactionsByDay(DateTime date);
  Future<Map<String, double>> sumByMonth({required DateTime monthStart});

  /// Autocomplete: ранее введённые заметки (note) по транзакциям.
  /// kind: 'expense' | 'income'
  Future<List<String>> searchTransactionNotes({
    required String kind,
    required String query,
    int limit = 8,
  });

  Future<List<Jar>> listJars();
  Future<String> addJar({
    required String title,
    double? targetAmount,
    required double percentOfFree,
  });
  Future<void> updateJarAmount({required String jarId, required double delta});
  Future<void> addJarAllocation({
    required String jarId,
    required DateTime periodMonth,
    required double amount,
  });
  Future<List<JarAllocation>> listJarAllocationsForMonth({
    required DateTime periodMonth,
  });
  Future<bool> hasAnyJarAllocationForMonth({required DateTime periodMonth});
  Future<void> deleteJarAllocationsForMonth({required DateTime periodMonth});
  Future<void> deleteJar(String jarId);

  Future<List<TransactionItem>> listTransactionsBetween(
    DateTime from,
    DateTime to,
  );
  Future<void> deleteTransaction(String id);
  Future<void> deleteCategory(String categoryId);
  Future<void> setCategoryLimit({required String categoryId, double? limit});
  Future<Map<dm.Category, double>> monthlyExpenseByCategory({
    required DateTime monthStart,
  });
}

mixin FinanceRepoMixin on BaseRepo implements FinanceRepo {
  @override
  Future<List<dm.Category>> listCategories({required String kind}) async {
    final res = await client
        .from('categories')
        .select()
        .eq('user_id', uid)
        .eq('kind', kind)
        .order('name', ascending: true);

    return (res as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return dm.Category(
        id: map['id'] as String,
        name: (map['name'] ?? '') as String,
        kind: (map['kind'] ?? '') as String,
      );
    }).toList();
  }

  @override
  Future<String> ensureCategory(String name, String kind) async {
    final existing = await client
        .from('categories')
        .select('id')
        .eq('user_id', uid)
        .eq('kind', kind)
        .eq('name', name)
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    final inserted = await client
        .from('categories')
        .insert({'user_id': uid, 'name': name, 'kind': kind})
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  @override
  Future<void> addTransaction({
    required DateTime ts,
    required String kind,
    required String categoryId,
    required double amount,
    String? note,
  }) async {
    if (kind == 'expense') {
      final limitRow = await client
          .from('categories')
          .select('limit_amount')
          .eq('id', categoryId)
          .eq('user_id', uid)
          .maybeSingle();

      final limit = (limitRow?['limit_amount'] as num?)?.toDouble();
      if (limit != null && limit > 0) {
        final start = monthStart(ts);
        final end = nextMonth(ts);
        final spentRes = await client
            .from('transactions')
            .select('amount')
            .eq('user_id', uid)
            .eq('category_id', categoryId)
            .gte('ts', start.toIso8601String())
            .lt('ts', end.toIso8601String());
        final spent = (spentRes as List).fold<double>(
          0,
          (sum, r) => sum + (r['amount'] as num).toDouble(),
        );
        if (spent + amount > limit)
          throw Exception('Превышен лимит для категории');
      }
    }

    await client.from('transactions').insert({
      'user_id': uid,
      'ts': ts.toIso8601String(),
      'kind': kind,
      'category_id': categoryId,
      'amount': amount,
      'note': note ?? '',
    });
  }

  @override
  Future<List<TransactionItem>> listTransactionsByDay(DateTime date) async {
    final start = dayStart(date);
    final end = start.add(const Duration(days: 1));

    final res = await client
        .from('transactions')
        .select()
        .eq('user_id', uid)
        .gte('ts', start.toIso8601String())
        .lt('ts', end.toIso8601String())
        .order('ts', ascending: false);

    return (res as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return TransactionItem(
        id: map['id'] as String,
        ts: DateTime.parse(map['ts'] as String),
        kind: (map['kind'] ?? '') as String,
        categoryId: (map['category_id'] ?? '') as String,
        amount: (map['amount'] as num).toDouble(),
        note: (map['note'] as String?)?.toString(),
      );
    }).toList();
  }

  @override
  Future<Map<String, double>> sumByMonth({required DateTime monthStart}) async {
    final start = this.monthStart(monthStart);
    final end = nextMonth(start);

    final res = await client
        .rpc(
          'sum_transactions_by_kind_for_period',
          params: {
            'p_user_id': uid,
            'p_from': start.toIso8601String(),
            'p_to': end.toIso8601String(),
          },
        )
        .select();

    final out = <String, double>{'income': 0.0, 'expense': 0.0};
    for (final row in res) {
      final r = Map<String, dynamic>.from(row as Map);
      out[r['kind'] as String] = (r['sum'] as num?)?.toDouble() ?? 0.0;
    }
    return out;
  }

  @override
  Future<List<String>> searchTransactionNotes({
    required String kind,
    required String query,
    int limit = 8,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    // PostgREST ilike: %pattern%
    final pattern = '%$q%';

    // Берём побольше строк и дедуплим локально, чтобы получить уникальные подсказки.
    final rows = await client
        .from('transactions')
        .select('note, ts')
        .eq('user_id', uid)
        .eq('kind', kind)
        .ilike('note', pattern)
        .neq('note', '')
        .order('ts', ascending: false)
        .limit(200);

    final seen = <String>{};
    final out = <String>[];

    for (final r in (rows as List)) {
      final note = (r['note'] as String?)?.trim() ?? '';
      if (note.isEmpty) continue;

      final norm = note.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      if (norm.isEmpty) continue;
      if (seen.contains(norm)) continue;

      seen.add(norm);
      out.add(note);

      if (out.length >= limit) break;
    }

    return out;
  }

  @override
  Future<List<Jar>> listJars() async {
    final rows = await client
        .from('jars')
        .select(
          'id, title, target_amount, current_amount, percent_of_free, active',
        )
        .eq('user_id', uid)
        .order('title', ascending: true);

    return (rows as List).map((r) {
      final m = Map<String, dynamic>.from(r as Map);
      return Jar(
        id: m['id'] as String,
        title: (m['title'] ?? '') as String,
        targetAmount: (m['target_amount'] as num?)?.toDouble(),
        currentAmount: (m['current_amount'] as num?)?.toDouble() ?? 0.0,
        percentOfFree: (m['percent_of_free'] as num?)?.toDouble() ?? 0.0,
        active: (m['active'] as bool?) ?? true,
      );
    }).toList();
  }

  @override
  Future<String> addJar({
    required String title,
    double? targetAmount,
    required double percentOfFree,
  }) async {
    final res = await client
        .from('jars')
        .insert({
          'user_id': uid,
          'title': title,
          'target_amount': targetAmount,
          'percent_of_free': percentOfFree,
          'current_amount': 0.0,
          'active': true,
        })
        .select('id')
        .single();

    return res['id'] as String;
  }

  @override
  Future<void> updateJarAmount({
    required String jarId,
    required double delta,
  }) async {
    try {
      await client.rpc(
        'increment_jar_amount',
        params: {'p_delta': delta, 'p_jar_id': jarId, 'p_user_id': uid},
      );
      return;
    } on PostgrestException catch (e) {
      final isMissingRpc =
          e.code == 'PGRST202' ||
          (e.message).toLowerCase().contains('increment_jar_amount');
      if (!isMissingRpc) rethrow;
    }

    final row = await client
        .from('jars')
        .select('current_amount')
        .eq('id', jarId)
        .eq('user_id', uid)
        .maybeSingle();

    final current = (row?['current_amount'] as num?)?.toDouble() ?? 0.0;
    final next = current + delta;

    await client
        .from('jars')
        .update({'current_amount': next})
        .eq('id', jarId)
        .eq('user_id', uid);
  }

  @override
  Future<void> addJarAllocation({
    required String jarId,
    required DateTime periodMonth,
    required double amount,
  }) async {
    final monthStr = d(DateTime(periodMonth.year, periodMonth.month, 1));
    final exists = await client
        .from('jar_allocations')
        .select('id')
        .eq('user_id', uid)
        .eq('jar_id', jarId)
        .eq('period_month', monthStr)
        .maybeSingle();

    if (exists != null) throw Exception('Аллокация за этот месяц уже есть');

    await client.from('jar_allocations').insert({
      'user_id': uid,
      'jar_id': jarId,
      'period_month': monthStr,
      'amount': amount,
    });
  }

  @override
  Future<List<TransactionItem>> listTransactionsBetween(
    DateTime from,
    DateTime to,
  ) async {
    final res = await client
        .from('transactions')
        .select()
        .eq('user_id', uid)
        .gte('ts', from.toIso8601String())
        .lt('ts', to.toIso8601String())
        .order('ts', ascending: false);

    return (res as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return TransactionItem(
        id: map['id'] as String,
        ts: DateTime.parse(map['ts'] as String),
        kind: (map['kind'] ?? '') as String,
        categoryId: (map['category_id'] ?? '') as String,
        amount: (map['amount'] as num).toDouble(),
        note: (map['note'] as String?)?.toString(),
      );
    }).toList();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await client.from('transactions').delete().eq('id', id).eq('user_id', uid);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await client
        .from('categories')
        .delete()
        .eq('id', categoryId)
        .eq('user_id', uid);
  }

  @override
  Future<void> setCategoryLimit({
    required String categoryId,
    double? limit,
  }) async {
    await client
        .from('categories')
        .update({'limit_amount': limit})
        .eq('id', categoryId)
        .eq('user_id', uid);
  }

  @override
  Future<Map<dm.Category, double>> monthlyExpenseByCategory({
    required DateTime monthStart,
  }) async {
    final start = this.monthStart(monthStart);
    final end = nextMonth(start);

    final rows = await client
        .from('transactions')
        .select('category_id, amount')
        .eq('user_id', uid)
        .eq('kind', 'expense')
        .gte('ts', start.toIso8601String())
        .lt('ts', end.toIso8601String());

    final byCat = <String, double>{};
    for (final r in (rows as List)) {
      final id = r['category_id'] as String?;
      if (id == null) continue;
      byCat[id] = (byCat[id] ?? 0) + (r['amount'] as num).toDouble();
    }
    if (byCat.isEmpty) return {};

    final catsRes = await client
        .from('categories')
        .select()
        .eq('user_id', uid)
        .inFilter('id', byCat.keys.toList());

    final cats = (catsRes as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return dm.Category(
        id: map['id'] as String,
        name: (map['name'] ?? '') as String,
        kind: (map['kind'] ?? '') as String,
      );
    }).toList();

    final out = <dm.Category, double>{};
    for (final c in cats) {
      out[c] = byCat[c.id] ?? 0.0;
    }
    return out;
  }

  @override
  Future<bool> hasAnyJarAllocationForMonth({
    required DateTime periodMonth,
  }) async {
    final monthStr =
        '${periodMonth.year.toString().padLeft(4, '0')}-${periodMonth.month.toString().padLeft(2, '0')}-01';

    final res = await client
        .from('jar_allocations')
        .select('id')
        .eq('user_id', uid)
        .eq('period_month', monthStr)
        .limit(1);

    return (res as List).isNotEmpty;
  }

  @override
  Future<List<JarAllocation>> listJarAllocationsForMonth({
    required DateTime periodMonth,
  }) async {
    final monthStr =
        '${periodMonth.year.toString().padLeft(4, '0')}-${periodMonth.month.toString().padLeft(2, '0')}-01';

    final rows = await client
        .from('jar_allocations')
        .select('jar_id, amount')
        .eq('user_id', uid)
        .eq('period_month', monthStr)
        .order('jar_id');

    return (rows as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return JarAllocation(
        jarId: (map['jar_id'] ?? '') as String,
        amount: (map['amount'] as num).toDouble(),
      );
    }).toList();
  }

  @override
  Future<void> deleteJarAllocationsForMonth({
    required DateTime periodMonth,
  }) async {
    final monthStr =
        '${periodMonth.year.toString().padLeft(4, '0')}-${periodMonth.month.toString().padLeft(2, '0')}-01';

    await client
        .from('jar_allocations')
        .delete()
        .eq('user_id', uid)
        .eq('period_month', monthStr);
  }

  @override
  Future<void> deleteJar(String jarId) async {
    await client.from('jars').delete().eq('id', jarId).eq('user_id', uid);
  }
}
