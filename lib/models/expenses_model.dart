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

  Future<void> addExpense({
    required double amount,
    required String category,
    required String note,
  }) async {
    await repo.addExpense(
      date: _selectedDate,
      amount: amount,
      category: category,
      note: note,
    );
    await loadFor(_selectedDate);
  }
}
