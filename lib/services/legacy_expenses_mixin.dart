import 'core/base_repo.dart';

mixin LegacyExpensesRepoMixin on BaseRepo {
  Future<void> addExpense({
    required DateTime date,
    required double amount,
    required String category,
    String note = '',
  }) async {
    final dayStr = d(DateTime(date.year, date.month, date.day));
    await client.from('expenses').insert({
      'user_id': uid,
      'date': dayStr,
      'amount': amount,
      'category': category.isEmpty ? 'Прочее' : category,
      'note': note,
    });
  }

  Future<void> deleteExpense(String id) async {
    await client.from('expenses').delete().eq('id', id).eq('user_id', uid);
  }

  Future<List<Map<String, dynamic>>> fetchExpenses({
    DateTime? from,
    DateTime? to,
  }) async {
    var q = client.from('expenses').select().eq('user_id', uid);
    if (from != null) q = q.gte('date', d(from));
    if (to != null) q = q.lte('date', d(to));

    final res = await q
        .order('date', ascending: false)
        .order('created_at', ascending: false)
        .limit(120);

    return (res as List)
        .map<Map<String, dynamic>>(
          (e) => {
            ...Map<String, dynamic>.from(e as Map),
            'date': DateTime.parse(e['date'] as String),
            'amount': (e['amount'] as num).toDouble(),
            'category': (e['category'] ?? 'Прочее') as String,
            'note': (e['note'] ?? '') as String,
          },
        )
        .toList();
  }

  Future<double> getTotalExpensesInRange(DateTime start, DateTime end) async {
    final res = await client
        .from('expenses')
        .select('amount, date')
        .eq('user_id', uid)
        .gte('date', d(start))
        .lte('date', d(end));

    return (res as List).fold<double>(
      0.0,
      (sum, row) => sum + ((row['amount'] ?? 0) as num).toDouble(),
    );
  }
}
