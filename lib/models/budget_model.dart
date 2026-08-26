import 'dart:async';

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

  /// Ошибка последней фоновой операции (например, если сеть отвалилась
  /// после того, как мы уже показали изменение пользователю). UI может
  /// показать это ненавязчиво (snackbar), не блокируя экран.
  String? error;

  List<dm.Category> incomeCategories = [];
  List<dm.Category> expenseCategories = [];
  List<TransactionItem> dayTx = [];
  List<Jar> jars = [];

  double incomeMonth = 0;
  double expenseMonth = 0;
  Map<dm.Category, double> expenseBreakdownMonth = {};

  bool monthCommitted = false;

  /// Точные суммы последней зафиксированной раскладки по копилкам — чтобы
  /// при отмене фиксации можно было мгновенно откатить суммы локально, не
  /// дожидаясь похода в сеть за списком аллокаций.
  Map<String, double>? _lastAllocation;

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

  /// Оставлен для обратной совместимости с местами, где вызывается напрямую
  /// (не через toggleJarAllocationForMonth). Логика та же, что и в toggle.
  Future<void> commitJarAllocationForMonth() async {
    if (monthCommitted) return;

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

    _applyAllocationLocally(alloc);
    monthCommitted = true;
    _lastAllocation = alloc;
    notifyListeners();

    unawaited(_commitAllocationOnServer(alloc));
  }

  void _applyAllocationLocally(Map<String, double> alloc) {
    jars = jars.map((j) {
      final delta = alloc[j.id];
      if (delta == null) return j;
      return j.copyWith(currentAmount: j.currentAmount + delta);
    }).toList();
  }

  Future<void> _commitAllocationOnServer(Map<String, double> alloc) async {
    try {
      for (final e in alloc.entries) {
        await repo.updateJarAmount(jarId: e.key, delta: e.value);
        await repo.addJarAllocation(
          jarId: e.key,
          periodMonth: monthStart,
          amount: e.value,
        );
      }
      jars = await repo.listJars();
      notifyListeners();
    } catch (e, st) {
      debugPrint('commitJarAllocationForMonth error: $e\n$st');
      error = 'Не удалось зафиксировать распределение: $e';
      notifyListeners();
    }
  }

  // ===== Операции =====

  /// Раньше: await addTransaction -> await _reloadMonthAndDay() (и функция
  /// не возвращалась, пока сервер не ответит) — доход появлялся в списке
  /// примерно через секунду, форма добавления "зависала" перед закрытием.
  /// Теперь: строка транзакции и сумма месяца обновляются мгновенно,
  /// функция сразу же возвращает управление, а запрос уходит в фон.
  Future<void> addIncome({
    required double amount,
    required String categoryId,
    String? note,
  }) async {
    error = null;
    final ts = _withNowTime(selectedDay);
    final tempId = 'temp-${DateTime.now().microsecondsSinceEpoch}';
    final optimisticTx = TransactionItem(
      id: tempId,
      ts: ts,
      kind: 'income',
      categoryId: categoryId,
      amount: amount,
      note: note,
    );

    dayTx = [...dayTx, optimisticTx]..sort((a, b) => a.ts.compareTo(b.ts));
    final isCurrentMonth = _sameMonth(selectedDay, _monthAnchor);
    if (isCurrentMonth) incomeMonth += amount;
    notifyListeners();

    unawaited(_addTransactionInBackground(
      tempId: tempId,
      ts: ts,
      kind: 'income',
      categoryId: categoryId,
      amount: amount,
      note: note,
      isCurrentMonth: isCurrentMonth,
    ));
  }

  Future<void> addExpense({
    required double amount,
    required String categoryId,
    String? note,
  }) async {
    error = null;
    final ts = _withNowTime(selectedDay);
    final tempId = 'temp-${DateTime.now().microsecondsSinceEpoch}';
    final optimisticTx = TransactionItem(
      id: tempId,
      ts: ts,
      kind: 'expense',
      categoryId: categoryId,
      amount: amount,
      note: note,
    );

    dayTx = [...dayTx, optimisticTx]..sort((a, b) => a.ts.compareTo(b.ts));
    final isCurrentMonth = _sameMonth(selectedDay, _monthAnchor);
    if (isCurrentMonth) expenseMonth += amount;
    notifyListeners();

    unawaited(_addTransactionInBackground(
      tempId: tempId,
      ts: ts,
      kind: 'expense',
      categoryId: categoryId,
      amount: amount,
      note: note,
      isCurrentMonth: isCurrentMonth,
    ));
  }

  Future<void> _addTransactionInBackground({
    required String tempId,
    required DateTime ts,
    required String kind,
    required String categoryId,
    required double amount,
    String? note,
    required bool isCurrentMonth,
  }) async {
    try {
      await repo.addTransaction(
        ts: ts,
        kind: kind,
        categoryId: categoryId,
        amount: amount,
        note: note,
      );
      await _loadMonth();
      await _loadDay();
      notifyListeners();
    } catch (e) {
      dayTx = dayTx.where((t) => t.id != tempId).toList();
      if (isCurrentMonth) {
        if (kind == 'income') {
          incomeMonth -= amount;
        } else {
          expenseMonth -= amount;
        }
      }
      error = kind == 'income'
          ? 'Не удалось сохранить доход: $e'
          : 'Не удалось сохранить расход: $e';
      notifyListeners();
    }
  }

  /// Полностью оптимистично: сама транзакция уже загружена в dayTx, поэтому
  /// можно убрать её из списка мгновенно и вернуть обратно при ошибке.
  Future<void> deleteTransaction(String id) async {
    error = null;
    final idx = dayTx.indexWhere((t) => t.id == id);
    if (idx == -1) {
      unawaited(_deleteTransactionOnServer(id: id, previous: null));
      return;
    }

    final previous = dayTx[idx];
    final wasIncome = previous.kind == 'income';
    dayTx = dayTx.where((t) => t.id != id).toList();
    if (wasIncome) {
      incomeMonth -= previous.amount;
    } else {
      expenseMonth -= previous.amount;
    }
    notifyListeners();

    unawaited(_deleteTransactionOnServer(id: id, previous: previous));
  }

  Future<void> _deleteTransactionOnServer({
    required String id,
    required TransactionItem? previous,
  }) async {
    try {
      await repo.deleteTransaction(id);
      await _loadMonth();
      await _loadDay();
      notifyListeners();
    } catch (e) {
      if (previous != null) {
        final restored = [...dayTx, previous]
          ..sort((a, b) => a.ts.compareTo(b.ts));
        dayTx = restored;
        if (previous.kind == 'income') {
          incomeMonth += previous.amount;
        } else {
          expenseMonth += previous.amount;
        }
      }
      error = 'Не удалось удалить операцию: $e';
      notifyListeners();
    }
  }

  // ===== Категории =====
  Future<String> createCategory(String name, String kind) =>
      repo.ensureCategory(name, kind);

  /// Оптимистично: категория уже есть в incomeCategories/expenseCategories,
  /// убираем её сразу, восстанавливаем при ошибке.
  Future<void> deleteCategory(String categoryId) async {
    error = null;
    final incomeIdx = incomeCategories.indexWhere((c) => c.id == categoryId);
    final expenseIdx = incomeIdx == -1
        ? expenseCategories.indexWhere((c) => c.id == categoryId)
        : -1;

    dm.Category? previous;
    final wasIncome = incomeIdx != -1;
    if (incomeIdx != -1) {
      previous = incomeCategories[incomeIdx];
      incomeCategories = incomeCategories.where((c) => c.id != categoryId).toList();
    } else if (expenseIdx != -1) {
      previous = expenseCategories[expenseIdx];
      expenseCategories = expenseCategories.where((c) => c.id != categoryId).toList();
    }
    if (previous != null) notifyListeners();

    unawaited(_deleteCategoryOnServer(
      categoryId: categoryId,
      previous: previous,
      wasIncome: wasIncome,
    ));
  }

  Future<void> _deleteCategoryOnServer({
    required String categoryId,
    required dm.Category? previous,
    required bool wasIncome,
  }) async {
    try {
      await repo.deleteCategory(categoryId);
      await _loadMonth();
      await _loadDay();
      notifyListeners();
    } catch (e) {
      if (previous != null) {
        if (wasIncome) {
          incomeCategories = [...incomeCategories, previous];
        } else {
          expenseCategories = [...expenseCategories, previous];
        }
      }
      error = 'Не удалось удалить категорию: $e';
      notifyListeners();
    }
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

  /// Переключатель фиксации: зафиксировать / отменить.
  /// Раньше обе ветки ждали полный цикл запросов к серверу, прежде чем
  /// пользователь видел хоть какое-то изменение (флаг, суммы по копилкам).
  /// Теперь флаг и суммы по копилкам меняются мгновенно (для отмены — на
  /// основе точных сумм последней фиксации, без похода в сеть), а запросы
  /// уходят в фон.
  Future<void> toggleJarAllocationForMonth() async {
    error = null;
    final previousCommitted = monthCommitted;
    final previousJars = jars;

    if (!previousCommitted) {
      final alloc = previewJarAllocation();
      if (alloc.isEmpty) return;

      _applyAllocationLocally(alloc);
      monthCommitted = true;
      _lastAllocation = alloc;
      notifyListeners();

      unawaited(_commitToggleOnServer(alloc: alloc, previousJars: previousJars));
    } else {
      final knownAlloc = _lastAllocation;
      if (knownAlloc != null) {
        jars = jars.map((j) {
          final delta = knownAlloc[j.id];
          if (delta == null) return j;
          return j.copyWith(currentAmount: j.currentAmount - delta);
        }).toList();
      }
      monthCommitted = false;
      notifyListeners();

      unawaited(_cancelToggleOnServer(previousJars: previousJars));
    }
  }

  Future<void> _commitToggleOnServer({
    required Map<String, double> alloc,
    required List<Jar> previousJars,
  }) async {
    try {
      final already = await repo.hasAnyJarAllocationForMonth(
        periodMonth: monthStart,
      );
      if (!already) {
        for (final e in alloc.entries) {
          await repo.updateJarAmount(jarId: e.key, delta: e.value);
          await repo.addJarAllocation(
            jarId: e.key,
            periodMonth: monthStart,
            amount: e.value,
          );
        }
      }
      jars = await repo.listJars();
      notifyListeners();
    } catch (e, st) {
      debugPrint('toggleJarAllocationForMonth (commit) error: $e\n$st');
      jars = previousJars;
      monthCommitted = false;
      _lastAllocation = null;
      error = 'Не удалось сохранить: $e';
      notifyListeners();
    }
  }

  Future<void> _cancelToggleOnServer({required List<Jar> previousJars}) async {
    try {
      final allocations = await repo.listJarAllocationsForMonth(
        periodMonth: monthStart,
      );
      for (final a in allocations) {
        await repo.updateJarAmount(jarId: a.jarId, delta: -a.amount);
      }
      await repo.deleteJarAllocationsForMonth(periodMonth: monthStart);
      _lastAllocation = null;
      jars = await repo.listJars();
      notifyListeners();
    } catch (e, st) {
      debugPrint('toggleJarAllocationForMonth (cancel) error: $e\n$st');
      jars = previousJars;
      monthCommitted = true;
      error = 'Не удалось отменить: $e';
      notifyListeners();
    }
  }

  /// Оптимистично: сама копилка уже загружена в jars, убираем её сразу.
  Future<void> deleteJar(String jarId) async {
    error = null;
    final idx = jars.indexWhere((j) => j.id == jarId);
    final previous = idx != -1 ? jars[idx] : null;

    if (previous != null) {
      jars = jars.where((j) => j.id != jarId).toList();
      notifyListeners();
    }

    unawaited(_deleteJarOnServer(jarId: jarId, previous: previous));
  }

  Future<void> _deleteJarOnServer({
    required String jarId,
    required Jar? previous,
  }) async {
    try {
      await repo.deleteJar(jarId);
      await _loadMonth(force: true);
      await _loadDay();
      notifyListeners();
    } catch (e) {
      if (previous != null) {
        jars = [...jars, previous];
      }
      error = 'Не удалось удалить копилку: $e';
      notifyListeners();
    }
  }
}