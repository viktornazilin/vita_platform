import 'package:flutter/foundation.dart';
import '../domain/category.dart' as dm;
import '../domain/jar.dart';
import '../domain/transaction_item.dart';
import '../services/finance_repo_mixin.dart' show FinanceRepo;

bool _sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

class BudgetModel extends ChangeNotifier {
  final FinanceRepo repo;
  BudgetModel({required this.repo});

  DateTime selectedDay = DateTime.now();
  DateTime _monthAnchor = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  bool loading = true;

  List<dm.Category> incomeCategories = [];
  List<dm.Category> expenseCategories = [];
  List<TransactionItem> dayTx = [];
  List<Jar> jars = [];

  double incomeMonth = 0;
  double expenseMonth = 0;
  Map<dm.Category, double> expenseBreakdownMonth = {};

  bool monthCommitted = false;

  DateTime get monthStart => DateTime(_monthAnchor.year, _monthAnchor.month, 1);

  /// Склеиваем выбранную дату со временем «сейчас», чтобы запись попадала в нужные сутки.
  DateTime _withNowTime(DateTime day) {
    final now = DateTime.now();
    return DateTime(
      day.year,
      day.month,
      day.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();
    _monthAnchor = DateTime(selectedDay.year, selectedDay.month, 1);
    await _loadMonth(force: true);
    await _loadDay();
    loading = false;
    notifyListeners();
  }

  Future<void> setDay(DateTime day) async {
    final prevMonth = _monthAnchor;
    selectedDay = day;
    if (!_sameMonth(day, prevMonth)) {
      _monthAnchor = DateTime(day.year, day.month, 1);
      await _loadMonth();
    }
    await _loadDay();
    notifyListeners();
  }

  double get freeCashFlowMonth =>
      (incomeMonth - expenseMonth).clamp(0, double.infinity);

  Map<String, double> previewJarAllocation() {
    final active = jars.where((j) => j.active && j.percentOfFree > 0).toList();
    final totalPercent = active.fold<double>(0, (s, j) => s + j.percentOfFree);
    if (totalPercent <= 0) return {};
    final free = freeCashFlowMonth;
    return {
      for (final j in active) j.id: free * (j.percentOfFree / totalPercent),
    };
  }

  Future<void> commitJarAllocationForMonth() async {
    // Проверяем факт фиксации по БД
    final already = await repo.hasAnyJarAllocationForMonth(
      periodMonth: monthStart,
    );
    if (already || monthCommitted) {
      monthCommitted = true;
      notifyListeners();
      return;
    }

    final alloc = previewJarAllocation();
    if (alloc.isEmpty) return;

    try {
      for (final e in alloc.entries) {
        await repo.updateJarAmount(jarId: e.key, delta: e.value);
        await repo.addJarAllocation(
          jarId: e.key,
          periodMonth: monthStart,
          amount: e.value,
        );
      }
      monthCommitted = true;
      jars = await repo.listJars();
    } catch (e, st) {
      debugPrint('commitJarAllocationForMonth error: $e\n$st');
    }
    notifyListeners();
  }

  // ===== Операции =====
  Future<void> addIncome({
    required double amount,
    required String categoryId,
    String? note,
  }) async {
    await repo.addTransaction(
      ts: _withNowTime(selectedDay),
      kind: 'income',
      categoryId: categoryId,
      amount: amount,
      note: note,
    );
    await _reloadMonthAndDay();
  }

  Future<void> addExpense({
    required double amount,
    required String categoryId,
    String? note,
  }) async {
    await repo.addTransaction(
      ts: _withNowTime(selectedDay),
      kind: 'expense',
      categoryId: categoryId,
      amount: amount,
      note: note,
    );
    await _reloadMonthAndDay();
  }

  Future<void> deleteTransaction(String id) async {
    await repo.deleteTransaction(id);
    await _reloadMonthAndDay();
  }

  // ===== Категории =====
  Future<String> createCategory(String name, String kind) =>
      repo.ensureCategory(name, kind);

  Future<void> deleteCategory(String categoryId) async {
    await repo.deleteCategory(categoryId);
    await _reloadMonthAndDay();
  }

  Future<void> setExpenseLimit({
    required String categoryId,
    double? limitRub,
  }) async {
    await repo.setCategoryLimit(categoryId: categoryId, limit: limitRub);
    await _loadMonth(force: true);
    notifyListeners();
  }

  // ===== Копилки =====
  Future<String> createJar({
    required String title,
    double? targetAmount,
    required double percent,
  }) => repo.addJar(
    title: title,
    targetAmount: targetAmount,
    percentOfFree: percent,
  );

  // ===== Внутренние =====
  Future<void> _reloadMonthAndDay() async {
    await _loadMonth();
    await _loadDay();
    notifyListeners();
  }

  Future<void> _loadDay() async {
    dayTx = await repo.listTransactionsByDay(selectedDay);
  }

  Future<void> _loadMonth({bool force = false}) async {
    incomeCategories = await repo.listCategories(kind: 'income');
    expenseCategories = await repo.listCategories(kind: 'expense');

    // Грузим месячные сводки и копилки
    final sums = await repo.sumByMonth(monthStart: monthStart);
    incomeMonth = sums['income'] ?? 0;
    expenseMonth = sums['expense'] ?? 0;

    expenseBreakdownMonth = await repo.monthlyExpenseByCategory(
      monthStart: monthStart,
    );

    jars = await repo.listJars();
    monthCommitted = await repo.hasAnyJarAllocationForMonth(
      periodMonth: monthStart,
    );
  }

  /// Переключатель фиксации: зафиксировать / отменить
  Future<void> toggleJarAllocationForMonth() async {
    try {
      if (monthCommitted) {
        // === ОТМЕНА ===
        final allocations = await repo.listJarAllocationsForMonth(
          periodMonth: monthStart,
        );
        for (final a in allocations) {
          await repo.updateJarAmount(jarId: a.jarId, delta: -a.amount);
        }
        await repo.deleteJarAllocationsForMonth(periodMonth: monthStart);

        monthCommitted = false;
        jars = await repo.listJars();
        notifyListeners();
      } else {
        // === ФИКСАЦИЯ ===
        final already = await repo.hasAnyJarAllocationForMonth(
          periodMonth: monthStart,
        );
        if (already) {
          monthCommitted = true;
          notifyListeners();
          return;
        }

        final alloc = previewJarAllocation();
        if (alloc.isEmpty) return;

        for (final e in alloc.entries) {
          await repo.updateJarAmount(jarId: e.key, delta: e.value);
          await repo.addJarAllocation(
            jarId: e.key,
            periodMonth: monthStart,
            amount: e.value,
          );
        }

        monthCommitted = true;
        jars = await repo.listJars();
        notifyListeners();
      }
    } catch (e, st) {
      debugPrint('toggleJarAllocationForMonth error: $e\n$st');
    }
  }

  // в BudgetModel
  Future<void> deleteJar(String jarId) async {
    await repo.deleteJar(jarId);
    await load();
  }
}
