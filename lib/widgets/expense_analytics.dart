import 'package:flutter/material.dart';
import '../main.dart'; // dbRepo

class ExpenseAnalytics {
  final double total;
  final Map<String, double> byCategory; // имя категории -> сумма
  final Map<DateTime, double> byDay; // день -> сумма

  ExpenseAnalytics({
    required this.total,
    required this.byCategory,
    required this.byDay,
  });
}

Future<ExpenseAnalytics> loadExpenseAnalytics(
  DateTime from,
  DateTime to,
) async {
  final txs = await dbRepo.listTransactionsBetween(from, to);
  final expenses = txs.where((t) => t.kind == 'expense');

  final expCats = await dbRepo.listCategories(kind: 'expense');
  final catNameById = {for (final c in expCats) c.id: c.name};

  double total = 0;
  final Map<String, double> byCategory = {};
  final Map<DateTime, double> byDay = {};

  for (final t in expenses) {
    total += t.amount;

    final catName = catNameById[t.categoryId] ?? 'Прочее';
    byCategory[catName] = (byCategory[catName] ?? 0) + t.amount;

    final d = DateTime(t.ts.year, t.ts.month, t.ts.day);
    byDay[d] = (byDay[d] ?? 0) + t.amount;
  }

  return ExpenseAnalytics(total: total, byCategory: byCategory, byDay: byDay);
}
