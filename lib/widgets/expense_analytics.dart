import 'package:flutter/material.dart';
import '../main.dart'; // dbRepo

import 'package:nest_app/l10n/app_localizations.dart';

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

/// ✅ FIX: чтобы не ломать существующие вызовы (где передают только 2 аргумента),
/// делаем context ОПЦИОНАЛЬНЫМ.
/// Если context не передан — используем запасную строку "Other".
Future<ExpenseAnalytics> loadExpenseAnalytics(
  DateTime from,
  DateTime to, [
  BuildContext? context,
]) async {
  final otherLabel = (context != null)
      ? AppLocalizations.of(context)!.expenseCategoryOther
      : 'Other';

  final txs = await dbRepo.listTransactionsBetween(from, to);
  final expenses = txs.where((t) => t.kind == 'expense');

  final expCats = await dbRepo.listCategories(kind: 'expense');
  final catNameById = {for (final c in expCats) c.id: c.name};

  double total = 0;
  final Map<String, double> byCategory = {};
  final Map<DateTime, double> byDay = {};

  for (final tx in expenses) {
    total += tx.amount;

    final catName = catNameById[tx.categoryId] ?? otherLabel;
    byCategory[catName] = (byCategory[catName] ?? 0) + tx.amount;

    final d = DateTime(tx.ts.year, tx.ts.month, tx.ts.day);
    byDay[d] = (byDay[d] ?? 0) + tx.amount;
  }

  return ExpenseAnalytics(total: total, byCategory: byCategory, byDay: byDay);
}
