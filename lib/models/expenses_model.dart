import 'dart:async';

import 'package:flutter/foundation.dart';
import '../services/db_repo.dart';

class ExpensesModel extends ChangeNotifier {
  final DbRepo repo;
  ExpensesModel({required this.repo});

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  List<Map<String, dynamic>> _expensesToday = [];
  List<Map<String, dynamic>> get expensesToday => _expensesToday;

  bool _loading = false;
  bool get loading => _loading;

  String? error;

  Future<void> loadFor(DateTime date) async {
    _loading = true;
    notifyListeners();

    _selectedDate = DateTime(date.year, date.month, date.day);
    final data = await repo.fetchExpenses(
      from: _selectedDate,
      to: _selectedDate,
    );

    // fetchExpenses возвращает диапазон inclusive; оставим только точный день
    _expensesToday = data.where((e) {
      final d = e['date'] as DateTime;
      return d.year == _selectedDate.year &&
          d.month == _selectedDate.month &&
          d.day == _selectedDate.day;
    }).toList();

    _loading = false;
    notifyListeners();
  }

  Future<void> setDate(DateTime d) async => loadFor(d);

  double get totalToday =>
      _expensesToday.fold<double>(0.0, (s, e) => s + (e['amount'] as double));

  /// Раньше: await repo.addExpense -> await loadFor(...) — примерно секунда
  /// видимой задержки перед тем, как расход появлялся в списке.
  /// Теперь: расход появляется в списке (и в totalToday) мгновенно, запрос
  /// в БД уходит фоном. При ошибке — запись убирается и появляется `error`.
  Future<void> addExpense({
    required double amount,
    required String category,
    required String note,
  }) async {
    error = null;

    final optimistic = <String, dynamic>{
      'date': _selectedDate,
      'amount': amount,
      'category': category,
      'note': note,
      // Помечаем как временную запись — по этому ключу отличаем её от
      // реальных данных с сервера при откате.
      '_optimistic': true,
    };

    _expensesToday = [..._expensesToday, optimistic];
    notifyListeners();

    unawaited(_addExpenseOnServer(
      optimistic: optimistic,
      amount: amount,
      category: category,
      note: note,
    ));
  }

  Future<void> _addExpenseOnServer({
    required Map<String, dynamic> optimistic,
    required double amount,
    required String category,
    required String note,
  }) async {
    try {
      await repo.addExpense(
        date: _selectedDate,
        amount: amount,
        category: category,
        note: note,
      );
      // Тихая синхронизация с реальными данными сервера, без спиннера —
      // временная запись уже видна пользователю.
      final data = await repo.fetchExpenses(from: _selectedDate, to: _selectedDate);
      _expensesToday = data.where((e) {
        final d = e['date'] as DateTime;
        return d.year == _selectedDate.year &&
            d.month == _selectedDate.month &&
            d.day == _selectedDate.day;
      }).toList();
      notifyListeners();
    } catch (e) {
      _expensesToday = _expensesToday.where((x) => x != optimistic).toList();
      error = 'Не удалось сохранить расход: $e';
      notifyListeners();
    }
  }
}