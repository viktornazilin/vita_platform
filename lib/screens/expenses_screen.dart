
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../domain/category.dart' as dm;
import '../domain/jar.dart';
import '../main.dart';
import '../models/budget_model.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/add_income_dialog.dart';
import '../widgets/add_jar_dialog.dart';
import '../widgets/nest/nest_background.dart';
import 'shopping_tracker_card.dart';
import 'budget_setup_screen.dart';


bool get _ladnaDarkMode =>
    WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

Color _ladnaAdaptive(Color light, Color dark) => _ladnaDarkMode ? dark : light;

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BudgetModel(repo: dbRepo)..load(),
      child: const _ExpensesView(),
    );
  }
}

enum _BudgetTab { overview, jars, lists }
enum _BudgetPeriod { week, month, year }

class _ExpensesView extends StatefulWidget {
  const _ExpensesView();

  @override
  State<_ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<_ExpensesView> {
  _BudgetTab _tab = _BudgetTab.overview;
  _BudgetPeriod _period = _BudgetPeriod.month;

  String _periodDataKey = '';
  bool _periodLoading = false;
  List<dynamic> _periodTransactions = const [];
  Map<dm.Category, double> _periodBreakdown = const {};
  double _periodIncome = 0;
  double _periodExpense = 0;

  void _invalidatePeriodData() {
    _periodDataKey = '';
    if (mounted) setState(() {});
  }

  DateTimeRange _rangeForPeriod(DateTime selectedDay) {
    final day = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    switch (_period) {
      case _BudgetPeriod.week:
        final start = day.subtract(Duration(days: day.weekday - 1));
        return DateTimeRange(start: start, end: start.add(const Duration(days: 7)));
      case _BudgetPeriod.month:
        final start = DateTime(day.year, day.month, 1);
        return DateTimeRange(start: start, end: DateTime(day.year, day.month + 1, 1));
      case _BudgetPeriod.year:
        final start = DateTime(day.year, 1, 1);
        return DateTimeRange(start: start, end: DateTime(day.year + 1, 1, 1));
    }
  }

  String _keyFor(DateTimeRange range) => '${_period.name}:${range.start.toIso8601String()}:${range.end.toIso8601String()}';

  void _ensurePeriodData(BudgetModel model) {
    final range = _rangeForPeriod(model.selectedDay);
    final nextKey = _keyFor(range);
    if (nextKey == _periodDataKey || _periodLoading) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPeriodData(model, nextKey, range);
    });
  }

  Future<void> _loadPeriodData(
    BudgetModel model,
    String key,
    DateTimeRange range,
  ) async {
    setState(() => _periodLoading = true);

    try {
      final txs = await dbRepo.listTransactionsBetween(range.start, range.end);

      double income = 0;
      double expense = 0;
      final breakdown = <dm.Category, double>{};

      for (final tx in txs) {
        if (tx.kind == 'income') {
          income += tx.amount;
          continue;
        }

        if (tx.kind == 'expense') {
          expense += tx.amount;
          final category = model.expenseCategories.firstWhere(
            (c) => c.id == tx.categoryId,
            orElse: () => dm.Category(id: tx.categoryId, name: '—', kind: 'expense'),
          );
          breakdown[category] = (breakdown[category] ?? 0) + tx.amount;
        }
      }

      if (!mounted) return;
      setState(() {
        _periodDataKey = key;
        _periodTransactions = txs;
        _periodBreakdown = breakdown;
        _periodIncome = income;
        _periodExpense = expense;
        _periodLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _periodDataKey = key;
        _periodTransactions = const [];
        _periodBreakdown = const {};
        _periodIncome = 0;
        _periodExpense = 0;
        _periodLoading = false;
      });
    }
  }

  Future<void> _shiftDay(BuildContext context, int deltaDays) async {
    final m = context.read<BudgetModel>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = DateTime(m.selectedDay.year, m.selectedDay.month, m.selectedDay.day);
    final target = current.add(Duration(days: deltaDays));
    if (target.isAfter(today)) return;
    await m.setDay(target);
    _invalidatePeriodData();
  }

  Future<void> _shiftPeriod(BuildContext context, int delta) async {
    final m = context.read<BudgetModel>();
    final d = m.selectedDay;

    DateTime target;
    switch (_period) {
      case _BudgetPeriod.week:
        target = d.add(Duration(days: 7 * delta));
        break;
      case _BudgetPeriod.month:
        target = DateTime(d.year, d.month + delta, d.day);
        break;
      case _BudgetPeriod.year:
        target = DateTime(d.year + delta, d.month, d.day);
        break;
    }

    final now = DateTime.now();
    if (target.isAfter(now)) target = now;
    await m.setDay(target);
    _invalidatePeriodData();
  }

  Future<void> _openBudgetSetup(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BudgetSetupScreen()),
    );
    if (!context.mounted) return;
    await context.read<BudgetModel>().load();
    _invalidatePeriodData();
  }

  Future<void> _addExpense(BuildContext context) async {
    final m = context.read<BudgetModel>();
    final res = await showDialog<AddExpenseResult>(
      context: context,
      builder: (_) => AddExpenseDialog(
        categories: m.expenseCategories,
        onCreateCategory: (name) => m.createCategory(name, 'expense'),
      ),
    );

    if (res != null) {
      await m.addExpense(
        amount: res.amount,
        categoryId: res.categoryId,
        note: res.note,
      );
      _invalidatePeriodData();
    }
  }

  Future<void> _addIncome(BuildContext context) async {
    final m = context.read<BudgetModel>();
    final res = await showDialog<AddIncomeResult>(
      context: context,
      builder: (_) => AddIncomeDialog(
        categories: m.incomeCategories,
        onCreateCategory: (name) => m.createCategory(name, 'income'),
      ),
    );

    if (res != null) {
      await m.addIncome(
        amount: res.amount,
        categoryId: res.categoryId,
        note: res.note,
      );
      _invalidatePeriodData();
    }
  }

  Future<void> _addJar(BuildContext context) async {
    final m = context.read<BudgetModel>();
    final res = await showDialog<NewJarData>(
      context: context,
      builder: (_) => const AddJarDialog(),
    );
    if (res == null) return;

    await m.createJar(
      title: res.title,
      targetAmount: res.target,
      percent: res.percent,
    );
    await m.load();
    _invalidatePeriodData();
  }

  Future<void> _showAddMenu(BuildContext context) async {
    final t = _BudgetText.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            14,
            0,
            14,
            MediaQuery.of(ctx).padding.bottom + 14,
          ),
          child: _SheetCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 10),
                _ActionRow(
                  icon: Icons.trending_down_rounded,
                  title: t.addExpense,
                  subtitle: t.addExpenseSub,
                  onTap: () => Navigator.pop(ctx, 'expense'),
                ),
                _ActionRow(
                  icon: Icons.trending_up_rounded,
                  title: t.addIncome,
                  subtitle: t.addIncomeSub,
                  onTap: () => Navigator.pop(ctx, 'income'),
                ),
                _ActionRow(
                  icon: Icons.savings_rounded,
                  title: t.addJar,
                  subtitle: t.addJarSub,
                  onTap: () => Navigator.pop(ctx, 'jar'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted || action == null) return;
    if (action == 'expense') await _addExpense(context);
    if (action == 'income') await _addIncome(context);
    if (action == 'jar') await _addJar(context);
  }

  double _dayExpenseSum(BudgetModel m) {
    return m.dayTx
        .where((t) => t.kind == 'expense')
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> _confirmDeleteTx({
    required BuildContext context,
    required String categoryName,
    required double amount,
    required String txId,
  }) async {
    final t = _BudgetText.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(t.deleteTransaction),
        content: Text(t.deleteTransactionBody(categoryName, amount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dlgCtx, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<BudgetModel>().deleteTransaction(txId);
      _invalidatePeriodData();
    }
  }

  Future<void> _openTxActions(BuildContext context, dynamic tx, String categoryName) async {
    final t = _BudgetText.of(context);
    final m = context.read<BudgetModel>();

    final action = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(14, 0, 14, MediaQuery.of(ctx).padding.bottom + 14),
        child: _SheetCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 10),
              _ActionRow(
                icon: Icons.edit_rounded,
                title: t.edit,
                subtitle: categoryName,
                onTap: () => Navigator.pop(ctx, 'edit'),
              ),
              _ActionRow(
                icon: Icons.delete_rounded,
                title: t.delete,
                subtitle: t.deleteTransaction,
                danger: true,
                onTap: () => Navigator.pop(ctx, 'delete'),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || action == null) return;

    if (action == 'delete') {
      await _confirmDeleteTx(
        context: context,
        categoryName: categoryName,
        amount: tx.amount,
        txId: tx.id,
      );
      return;
    }

    if (action == 'edit') {
      if (tx.kind == 'expense') {
        final res = await showDialog<AddExpenseResult>(
          context: context,
          builder: (_) => AddExpenseDialog(
            categories: m.expenseCategories,
            initialAmount: tx.amount,
            initialCategoryId: tx.categoryId,
            initialNote: tx.note,
            onCreateCategory: (name) => m.createCategory(name, 'expense'),
          ),
        );

        if (res != null) {
          await m.deleteTransaction(tx.id);
          await m.addExpense(
            amount: res.amount,
            categoryId: res.categoryId,
            note: res.note,
          );
          _invalidatePeriodData();
        }
      } else {
        final res = await showDialog<AddIncomeResult>(
          context: context,
          builder: (_) => AddIncomeDialog(
            categories: m.incomeCategories,
            initialAmount: tx.amount,
            initialCategoryId: tx.categoryId,
            initialNote: tx.note,
            onCreateCategory: (name) => m.createCategory(name, 'income'),
          ),
        );

        if (res != null) {
          await m.deleteTransaction(tx.id);
          await m.addIncome(
            amount: res.amount,
            categoryId: res.categoryId,
            note: res.note,
          );
          _invalidatePeriodData();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<BudgetModel>();
    final t = _BudgetText.of(context);
    _ensurePeriodData(m);

    final income = _periodDataKey.isEmpty ? m.incomeMonth : _periodIncome;
    final expense = _periodDataKey.isEmpty ? m.expenseMonth : _periodExpense;
    final free = (income - expense).clamp(0, double.infinity).toDouble();
    final dayExpense = _dayExpenseSum(m);
    final periodTransactions = _periodDataKey.isEmpty ? m.dayTx : _periodTransactions;
    final periodBreakdown = _periodDataKey.isEmpty ? m.expenseBreakdownMonth : _periodBreakdown;
    final periodLabel = _periodLabel(context, _period, m.selectedDay);

    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBody: true,
      body: NestBackground(
        child: m.loading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : SafeArea(
                bottom: false,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: RefreshIndicator.adaptive(
                        onRefresh: () async {
                          await m.load();
                          _invalidatePeriodData();
                        },
                        child: ListView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: EdgeInsets.fromLTRB(
                          16,
                          10,
                          16,
                          112 + bottom,
                        ),
                        children: [
                          _LadnaHeader(
                            title: t.budget,
                            canPop: Navigator.of(context).canPop(),
                            onBack: () => Navigator.of(context).maybePop(),
                            onSettings: () => _openBudgetSetup(context),
                          ),
                          const SizedBox(height: 14),
                          _PeriodRow(
                            period: _period,
                            selectedDay: m.selectedDay,
                            onPeriodChanged: (v) {
                              setState(() => _period = v);
                              _invalidatePeriodData();
                            },
                            onPrev: () => _shiftPeriod(context, -1),
                            onNext: () => _shiftPeriod(context, 1),
                          ),
                          const SizedBox(height: 12),
                          _BudgetTabs(
                            tab: _tab,
                            onChanged: (v) => setState(() => _tab = v),
                          ),
                          const SizedBox(height: 14),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: switch (_tab) {
                              _BudgetTab.overview => _OverviewTab(
                                  key: ValueKey('overview-${_period.name}-$periodLabel'),
                                  period: _period,
                                  periodLabel: periodLabel,
                                  periodLoading: _periodLoading,
                                  income: income,
                                  expense: expense,
                                  free: free,
                                  dayExpense: dayExpense,
                                  selectedDay: m.selectedDay,
                                  dayTx: periodTransactions,
                                  expenseCategories: m.expenseCategories,
                                  incomeCategories: m.incomeCategories,
                                  breakdown: periodBreakdown,
                                  onPrevPeriod: () => _shiftPeriod(context, -1),
                                  onNextPeriod: () => _shiftPeriod(context, 1),
                                  onTxTap: (tx, categoryName) => _openTxActions(context, tx, categoryName),
                                ),
                              _BudgetTab.jars => _JarsTab(
                                  key: const ValueKey('jars'),
                                  income: income,
                                  expense: expense,
                                  free: free,
                                  selectedDay: m.selectedDay,
                                  jars: m.jars,
                                ),
                              _BudgetTab.lists => const _ListsTab(
                                  key: ValueKey('lists'),
                                ),
                            },
                          ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 18,
                      bottom: bottom - 90,
                      child: _Fab(
                        label: t.add,
                        onTap: () => _showAddMenu(context),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}


class _Fab extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _Fab({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: _LadnaColors.primary,
            borderRadius: BorderRadius.circular(13),
            boxShadow: const [
              BoxShadow(
                color: Color(0x736B54C0),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 19),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
}

class _OverviewTab extends StatelessWidget {
  final _BudgetPeriod period;
  final String periodLabel;
  final bool periodLoading;
  final double income;
  final double expense;
  final double free;
  final double dayExpense;
  final DateTime selectedDay;
  final List<dynamic> dayTx;
  final List<dm.Category> expenseCategories;
  final List<dm.Category> incomeCategories;
  final Map<dynamic, double> breakdown;
  final VoidCallback onPrevPeriod;
  final VoidCallback onNextPeriod;
  final void Function(dynamic tx, String categoryName) onTxTap;

  const _OverviewTab({
    super.key,
    required this.period,
    required this.periodLabel,
    required this.periodLoading,
    required this.income,
    required this.expense,
    required this.free,
    required this.dayExpense,
    required this.selectedDay,
    required this.dayTx,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.breakdown,
    required this.onPrevPeriod,
    required this.onNextPeriod,
    required this.onTxTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = _BudgetText.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BalanceHero(
          label: _freeLabelForPeriod(t, period),
          month: periodLabel,
          free: free,
          income: income,
          expense: expense,
        ),
        const SizedBox(height: 12),
        _PeriodNav(
          label: periodLabel,
          loading: periodLoading,
          onPrev: onPrevPeriod,
          onNext: onNextPeriod,
        ),
        const SizedBox(height: 10),
        _TransactionList(
          transactions: dayTx,
          expenseCategories: expenseCategories,
          incomeCategories: incomeCategories,
          onTxTap: onTxTap,
        ),
        const SizedBox(height: 18),
        _SectionLabel(_categoriesLabelForPeriod(t, period)),
        const SizedBox(height: 8),
        _CategoryBars(
          data: breakdown,
          emptyText: t.noCategoryData,
        ),
      ],
    );
  }
}

class _JarsTab extends StatelessWidget {
  final double income;
  final double expense;
  final double free;
  final DateTime selectedDay;
  final List<Jar> jars;

  const _JarsTab({
    super.key,
    required this.income,
    required this.expense,
    required this.free,
    required this.selectedDay,
    required this.jars,
  });

  @override
  Widget build(BuildContext context) {
    final t = _BudgetText.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CompactBalance(
          month: _monthLabel(context, selectedDay),
          free: free,
          income: income,
          expense: expense,
        ),
        const SizedBox(height: 18),
        _SectionLabel(t.jars),
        const SizedBox(height: 8),
        _JarList(jars: jars),
      ],
    );
  }
}

class _ListsTab extends StatelessWidget {
  const _ListsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShoppingTrackerCard();
  }
}

class _LadnaHeader extends StatelessWidget {
  final String title;
  final bool canPop;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const _LadnaHeader({
    required this.title,
    required this.canPop,
    required this.onBack,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_LadnaColors.surface, _LadnaColors.card],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _LadnaColors.border),
        boxShadow: _LadnaShadows.card,
      ),
      child: Row(
        children: [
          if (canPop) ...[
            _CircleButton(
              icon: Icons.chevron_left_rounded,
              onTap: onBack,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 22,
                height: 1.05,
                fontWeight: FontWeight.w700,
                color: _LadnaColors.dark,
                letterSpacing: -0.3,
              ),
            ),
          ),
          _CircleButton(
            icon: Icons.tune_rounded,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  final _BudgetPeriod period;
  final DateTime selectedDay;
  final ValueChanged<_BudgetPeriod> onPeriodChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PeriodRow({
    required this.period,
    required this.selectedDay,
    required this.onPeriodChanged,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final t = _BudgetText.of(context);

    return Row(
      children: [
        _SegmentedPill(
          children: [
            _SegmentItem(
              label: t.weekShort,
              active: period == _BudgetPeriod.week,
              onTap: () => onPeriodChanged(_BudgetPeriod.week),
            ),
            _SegmentItem(
              label: t.monthShort,
              active: period == _BudgetPeriod.month,
              onTap: () => onPeriodChanged(_BudgetPeriod.month),
            ),
            _SegmentItem(
              label: t.yearShort,
              active: period == _BudgetPeriod.year,
              onTap: () => onPeriodChanged(_BudgetPeriod.year),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _LadnaColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _SmallChevron(icon: Icons.chevron_left_rounded, onTap: onPrev),
                Expanded(
                  child: Text(
                    _periodLabel(context, period, selectedDay),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _LadnaColors.dark,
                    ),
                  ),
                ),
                _SmallChevron(icon: Icons.chevron_right_rounded, onTap: onNext),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetTabs extends StatelessWidget {
  final _BudgetTab tab;
  final ValueChanged<_BudgetTab> onChanged;

  const _BudgetTabs({
    required this.tab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = _BudgetText.of(context);

    return _SegmentedPill(
      fillWidth: true,
      children: [
        _SegmentItem(
          label: t.overview,
          active: tab == _BudgetTab.overview,
          onTap: () => onChanged(_BudgetTab.overview),
        ),
        _SegmentItem(
          label: t.jars,
          active: tab == _BudgetTab.jars,
          onTap: () => onChanged(_BudgetTab.jars),
        ),
        _SegmentItem(
          label: t.lists,
          active: tab == _BudgetTab.lists,
          onTap: () => onChanged(_BudgetTab.lists),
        ),
      ],
    );
  }
}

class _SegmentedPill extends StatelessWidget {
  final List<Widget> children;
  final bool fillWidth;

  const _SegmentedPill({required this.children, this.fillWidth = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _LadnaColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: fillWidth ? MainAxisSize.max : MainAxisSize.min,
        children: fillWidth ? children.map((child) => Expanded(child: child)).toList() : children,
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SegmentItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          constraints: const BoxConstraints(minWidth: 54),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? _LadnaColors.dark : _LadnaColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceHero extends StatelessWidget {
  final String label;
  final String month;
  final double free;
  final double income;
  final double expense;

  const _BalanceHero({
    required this.label,
    required this.month,
    required this.free,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final t = _BudgetText.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_LadnaColors.dark, Color(0xFF1E1248)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _LadnaColors.dark.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -56,
            right: -42,
            child: _GlowCircle(size: 150),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                month.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.42),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_formatMoney(free)} €',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: Colors.white,
                  fontSize: 38,
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.48),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DarkMetric(
                      label: t.income,
                      value: '${_formatMoney(income)} €',
                      valueColor: const Color(0xFF4DD8CC),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DarkMetric(
                      label: t.expense,
                      value: '${_formatMoney(expense)} €',
                      valueColor: const Color(0xFFEB9898),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactBalance extends StatelessWidget {
  final String month;
  final double free;
  final double income;
  final double expense;

  const _CompactBalance({
    required this.month,
    required this.free,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final t = _BudgetText.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_LadnaColors.dark, Color(0xFF1E1248)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t.free} · $month'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.42),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_formatMoney(free)} €',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    color: Colors.white,
                    fontSize: 26,
                    height: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _CompactDarkMetric(label: t.income, value: '${_formatMoney(income)} €', color: const Color(0xFF4DD8CC)),
          const SizedBox(width: 16),
          _CompactDarkMetric(label: t.expense, value: '${_formatMoney(expense)} €', color: const Color(0xFFEB9898)),
        ],
      ),
    );
  }
}

class _DarkMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DarkMetric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.42), fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactDarkMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CompactDarkMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.42), fontSize: 10)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
      ],
    );
  }
}


class _PeriodNav extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PeriodNav({
    required this.label,
    required this.loading,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SquareButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _LadnaColors.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _LadnaColors.dark,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        _SquareButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _DayNav extends StatelessWidget {
  final DateTime selectedDay;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DayNav({
    required this.selectedDay,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SquareButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _LadnaColors.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              MaterialLocalizations.of(context).formatFullDate(selectedDay),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _LadnaColors.dark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _SquareButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<dynamic> transactions;
  final List<dm.Category> expenseCategories;
  final List<dm.Category> incomeCategories;
  final void Function(dynamic tx, String categoryName) onTxTap;

  const _TransactionList({
    required this.transactions,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.onTxTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = _BudgetText.of(context);

    if (transactions.isEmpty) {
      return _EmptyCard(text: t.noTransactions);
    }

    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < transactions.length; i++) ...[
            Builder(
              builder: (context) {
                final tx = transactions[i];
                final isExpense = tx.kind == 'expense';
                final cats = isExpense ? expenseCategories : incomeCategories;
                final cat = cats.firstWhere(
                  (c) => c.id == tx.categoryId,
                  orElse: () => dm.Category(id: '', name: '—', kind: tx.kind),
                );
                final note = (tx.note ?? '').toString().trim();
                return _TransactionRow(
                  icon: isExpense ? _expenseIcon(i) : Icons.payments_rounded,
                  iconBackground: isExpense ? _softColor(i) : const Color(0x1F16B8A8),
                  title: note.isNotEmpty ? note : cat.name,
                  subtitle: cat.name,
                  amount: '${isExpense ? '−' : '+'}${_formatMoney(tx.amount)} €',
                  amountColor: isExpense ? _LadnaColors.coral : _LadnaColors.green,
                  onTap: () => onTxTap(tx, cat.name),
                );
              },
            ),
            if (i != transactions.length - 1) const _SoftDivider(),
          ],
        ],
      ),
    );
  }
}

class _CategoryBars extends StatelessWidget {
  final Map<dynamic, double> data;
  final String emptyText;

  const _CategoryBars({
    required this.data,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final t = _BudgetText.of(context);

    if (data.isEmpty) return _EmptyCard(text: emptyText);

    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = entries.first.value <= 0 ? 1.0 : entries.first.value;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.moneyGoesTo,
            style: TextStyle(
              color: _LadnaColors.dark,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 13),
          for (var i = 0; i < entries.take(6).length; i++) ...[
            _CategoryBarRow(
              name: _categoryName(entries[i].key),
              amount: entries[i].value,
              value: (entries[i].value / max).clamp(0.0, 1.0),
              color: _accentColor(i),
            ),
            if (i != entries.take(6).length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _CategoryBarRow extends StatelessWidget {
  final String name;
  final double amount;
  final double value;
  final Color color;

  const _CategoryBarRow({
    required this.name,
    required this.amount,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _LadnaColors.text,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: value,
              backgroundColor: _LadnaColors.card,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 62,
          child: Text(
            '${_formatMoney(amount)} €',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _LadnaColors.dark,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _JarList extends StatelessWidget {
  final List<Jar> jars;

  const _JarList({required this.jars});

  @override
  Widget build(BuildContext context) {
    final t = _BudgetText.of(context);

    if (jars.isEmpty) return _EmptyCard(text: t.noJars);

    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < jars.length; i++) ...[
            _JarRow(jar: jars[i], color: _accentColor(i)),
            if (i != jars.length - 1) const _SoftDivider(),
          ],
        ],
      ),
    );
  }
}

class _JarRow extends StatelessWidget {
  final Jar jar;
  final Color color;

  const _JarRow({
    required this.jar,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final target = jar.targetAmount ?? (jar.currentAmount <= 0 ? 1 : jar.currentAmount * 2);
    final progress = target <= 0 ? 0.0 : (jar.currentAmount / target).clamp(0.0, 1.0);
    final subtitle = jar.targetAmount == null
        ? '${_formatMoney(jar.currentAmount)} €'
        : '${_formatMoney(jar.currentAmount)} / ${_formatMoney(jar.targetAmount!)} €';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _LadnaColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('✦', style: TextStyle(color: _LadnaColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jar.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _LadnaColors.dark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _LadnaColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 84,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: _LadnaColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    value: progress,
                    backgroundColor: _LadnaColors.card,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final VoidCallback onTap;

  const _TransactionRow({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: _LadnaColors.dark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? subtitle : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _LadnaColors.dark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _LadnaColors.muted,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                amount,
                style: TextStyle(
                  color: amountColor,
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _LadnaColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _LadnaColors.border),
        boxShadow: _LadnaShadows.card,
      ),
      child: child,
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _LadnaColors.muted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool danger;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFE07272) : _LadnaColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: _LadnaColors.dark, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 1),
                    Text(subtitle, style: TextStyle(color: _LadnaColors.muted, fontWeight: FontWeight.w500, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _LadnaColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetCard extends StatelessWidget {
  final Widget child;

  const _SheetCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _LadnaColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _LadnaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: child,
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: _LadnaColors.dark.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: _LadnaColors.muted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: _LadnaColors.border);
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _LadnaColors.primary.withOpacity(0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, color: _LadnaColors.text, size: 20),
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _LadnaColors.card,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, color: _LadnaColors.text, size: 20),
        ),
      ),
    );
  }
}

class _SmallChevron extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallChevron({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, color: _LadnaColors.text, size: 20),
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;

  const _GlowCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _LadnaColors.primary.withOpacity(0.18),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _LadnaColors {
  static Color get surface => _ladnaAdaptive(const Color(0xFFF5F3FA), const Color(0xFF100C1E));
  static Color get surfaceLight => _ladnaAdaptive(const Color(0xFFFAFAFE), const Color(0xFF1C1630));
  static Color get card => _ladnaAdaptive(const Color(0xFFEAE6F5), const Color(0xFF1C1630));
  static Color get border => _ladnaAdaptive(const Color(0xFFE0DCF0), const Color(0x2E6B54C0));
  static Color get primary => const Color(0xFF6B54C0);
  static Color get dark => _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF));
  static Color get text => _ladnaAdaptive(const Color(0xFF555268), const Color(0x99FFFFFF));
  static Color get muted => _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x4DFFFFFF));
  static Color get green => const Color(0xFF16B8A8);
  static Color get coral => const Color(0xFFD4E040);
}

class _LadnaShadows {
  static final card = [
    BoxShadow(
      color: Colors.black.withOpacity(_ladnaDarkMode ? 0.30 : 0.07),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];
}

class _BudgetText {
  final Locale locale;

  const _BudgetText(this.locale);

  static _BudgetText of(BuildContext context) => _BudgetText(Localizations.localeOf(context));

  bool get _ru => locale.languageCode == 'ru';
  bool get _de => locale.languageCode == 'de';
  bool get _fr => locale.languageCode == 'fr';
  bool get _es => locale.languageCode == 'es';
  bool get _tr => locale.languageCode == 'tr';

  String get budget => _ru ? 'Бюджет' : _de ? 'Budget' : _fr ? 'Budget' : _es ? 'Presupuesto' : _tr ? 'Bütçe' : 'Budget';
  String get weekShort => _ru ? 'Нед' : _de ? 'Wo' : _fr ? 'Sem' : _es ? 'Sem' : _tr ? 'Haf' : 'Week';
  String get monthShort => _ru ? 'Мес' : _de ? 'Mon' : _fr ? 'Mois' : _es ? 'Mes' : _tr ? 'Ay' : 'Month';
  String get yearShort => _ru ? 'Год' : _de ? 'Jahr' : _fr ? 'An' : _es ? 'Año' : _tr ? 'Yıl' : 'Year';
  String get overview => _ru ? 'Обзор' : _de ? 'Übersicht' : _fr ? 'Aperçu' : _es ? 'Resumen' : _tr ? 'Özet' : 'Overview';
  String get jars => _ru ? 'Копилки' : _de ? 'Sparen' : _fr ? 'Cagnottes' : _es ? 'Ahorros' : _tr ? 'Kumbaralar' : 'Jars';
  String get lists => _ru ? 'Списки' : _de ? 'Listen' : _fr ? 'Listes' : _es ? 'Listas' : _tr ? 'Listeler' : 'Lists';
  String get freeThisWeek => _ru ? 'Свободно за неделю' : _de ? 'Frei diese Woche' : _fr ? 'Disponible cette semaine' : _es ? 'Disponible esta semana' : _tr ? 'Bu hafta serbest' : 'Free this week';
  String get freeThisMonth => _ru ? 'Свободно в этом месяце' : _de ? 'Frei in diesem Monat' : _fr ? 'Disponible ce mois-ci' : _es ? 'Disponible este mes' : _tr ? 'Bu ay serbest' : 'Free this month';
  String get freeThisYear => _ru ? 'Свободно за год' : _de ? 'Frei dieses Jahr' : _fr ? 'Disponible cette année' : _es ? 'Disponible este año' : _tr ? 'Bu yıl serbest' : 'Free this year';
  String get free => _ru ? 'Свободно' : _de ? 'Frei' : _fr ? 'Disponible' : _es ? 'Libre' : _tr ? 'Serbest' : 'Free';
  String get income => _ru ? 'Доходы' : _de ? 'Einnahmen' : _fr ? 'Revenus' : _es ? 'Ingresos' : _tr ? 'Gelir' : 'Income';
  String get expense => _ru ? 'Расходы' : _de ? 'Ausgaben' : _fr ? 'Dépenses' : _es ? 'Gastos' : _tr ? 'Gider' : 'Expenses';
  String get weekCategories => _ru ? 'Категории недели' : _de ? 'Kategorien der Woche' : _fr ? 'Catégories de la semaine' : _es ? 'Categorías de la semana' : _tr ? 'Hafta kategorileri' : 'Week categories';
  String get monthCategories => _ru ? 'Категории месяца' : _de ? 'Kategorien des Monats' : _fr ? 'Catégories du mois' : _es ? 'Categorías del mes' : _tr ? 'Ay kategorileri' : 'Month categories';
  String get yearCategories => _ru ? 'Категории года' : _de ? 'Kategorien des Jahres' : _fr ? 'Catégories de l’année' : _es ? 'Categorías del año' : _tr ? 'Yıl kategorileri' : 'Year categories';
  String get moneyGoesTo => _ru ? 'Куда уходят деньги' : _de ? 'Wohin das Geld geht' : _fr ? 'Où va l’argent' : _es ? 'A dónde va el dinero' : _tr ? 'Para nereye gidiyor' : 'Where the money goes';
  String get noCategoryData => _ru ? 'Пока нет данных по категориям' : _de ? 'Noch keine Kategoriedaten' : _fr ? 'Aucune donnée par catégorie' : _es ? 'Aún no hay datos por categoría' : _tr ? 'Henüz kategori verisi yok' : 'No category data yet';
  String get noTransactions => _ru ? 'За этот день операций нет' : _de ? 'Keine Transaktionen an diesem Tag' : _fr ? 'Aucune transaction ce jour-là' : _es ? 'No hay transacciones este día' : _tr ? 'Bu gün işlem yok' : 'No transactions for this day';
  String get noJars => _ru ? 'Копилки пока не созданы' : _de ? 'Noch keine Sparziele' : _fr ? 'Aucune cagnotte pour le moment' : _es ? 'Aún no hay ahorros' : _tr ? 'Henüz kumbara yok' : 'No jars yet';
  String get add => _ru ? 'Добавить' : _de ? 'Hinzufügen' : _fr ? 'Ajouter' : _es ? 'Añadir' : _tr ? 'Ekle' : 'Add';
  String get addExpense => _ru ? 'Добавить расход' : _de ? 'Ausgabe hinzufügen' : _fr ? 'Ajouter une dépense' : _es ? 'Añadir gasto' : _tr ? 'Gider ekle' : 'Add expense';
  String get addIncome => _ru ? 'Добавить доход' : _de ? 'Einnahme hinzufügen' : _fr ? 'Ajouter un revenu' : _es ? 'Añadir ingreso' : _tr ? 'Gelir ekle' : 'Add income';
  String get addJar => _ru ? 'Добавить копилку' : _de ? 'Sparziel hinzufügen' : _fr ? 'Ajouter une cagnotte' : _es ? 'Añadir ahorro' : _tr ? 'Kumbara ekle' : 'Add jar';
  String get addExpenseSub => _ru ? 'Покупка, подписка или счёт' : _de ? 'Kauf, Abo oder Rechnung' : _fr ? 'Achat, abonnement ou facture' : _es ? 'Compra, suscripción o factura' : _tr ? 'Satın alma, abonelik veya fatura' : 'Purchase, subscription or bill';
  String get addIncomeSub => _ru ? 'Зарплата или другой доход' : _de ? 'Gehalt oder andere Einnahme' : _fr ? 'Salaire ou autre revenu' : _es ? 'Salario u otro ingreso' : _tr ? 'Maaş veya başka gelir' : 'Salary or other income';
  String get addJarSub => _ru ? 'Цель накопления и процент' : _de ? 'Sparziel und Prozent' : _fr ? 'Objectif et pourcentage' : _es ? 'Objetivo y porcentaje' : _tr ? 'Hedef ve yüzde' : 'Target and percentage';
  String get edit => _ru ? 'Редактировать' : _de ? 'Bearbeiten' : _fr ? 'Modifier' : _es ? 'Editar' : _tr ? 'Düzenle' : 'Edit';
  String get delete => _ru ? 'Удалить' : _de ? 'Löschen' : _fr ? 'Supprimer' : _es ? 'Eliminar' : _tr ? 'Sil' : 'Delete';
  String get cancel => _ru ? 'Отмена' : _de ? 'Abbrechen' : _fr ? 'Annuler' : _es ? 'Cancelar' : _tr ? 'İptal' : 'Cancel';
  String get deleteTransaction => _ru ? 'Удалить операцию?' : _de ? 'Transaktion löschen?' : _fr ? 'Supprimer la transaction ?' : _es ? '¿Eliminar transacción?' : _tr ? 'İşlem silinsin mi?' : 'Delete transaction?';

  String deleteTransactionBody(String category, double amount) {
    final value = '${_formatMoney(amount)} €';
    if (_ru) return 'Удалить операцию "$category" на сумму $value?';
    if (_de) return 'Transaktion "$category" über $value löschen?';
    if (_fr) return 'Supprimer "$category" pour $value ?';
    if (_es) return '¿Eliminar "$category" por $value?';
    if (_tr) return '"$category" için $value tutarındaki işlem silinsin mi?';
    return 'Delete "$category" for $value?';
  }
}


String _freeLabelForPeriod(_BudgetText t, _BudgetPeriod period) {
  switch (period) {
    case _BudgetPeriod.week:
      return t.freeThisWeek;
    case _BudgetPeriod.month:
      return t.freeThisMonth;
    case _BudgetPeriod.year:
      return t.freeThisYear;
  }
}

String _categoriesLabelForPeriod(_BudgetText t, _BudgetPeriod period) {
  switch (period) {
    case _BudgetPeriod.week:
      return t.weekCategories;
    case _BudgetPeriod.month:
      return t.monthCategories;
    case _BudgetPeriod.year:
      return t.yearCategories;
  }
}

String _periodLabel(BuildContext context, _BudgetPeriod period, DateTime date) {
  final ml = MaterialLocalizations.of(context);
  switch (period) {
    case _BudgetPeriod.week:
      final start = date.subtract(Duration(days: date.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return '${start.day}–${end.day} ${ml.formatMonthYear(end).split(' ').first}';
    case _BudgetPeriod.month:
      return ml.formatMonthYear(date);
    case _BudgetPeriod.year:
      return '${date.year}';
  }
}

String _monthLabel(BuildContext context, DateTime date) {
  return MaterialLocalizations.of(context).formatMonthYear(date);
}

String _formatMoney(double value) {
  final fixed = value.abs().toStringAsFixed(value.abs() >= 100 ? 0 : 2);
  final parts = fixed.split('.');
  final intPart = parts.first;
  final buffer = StringBuffer();

  for (var i = 0; i < intPart.length; i++) {
    final fromEnd = intPart.length - i;
    buffer.write(intPart[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(' ');
  }

  if (parts.length > 1 && parts.last != '00') {
    buffer.write(',${parts.last}');
  }

  return buffer.toString();
}

String _categoryName(dynamic key) {
  if (key is dm.Category) return key.name;
  final value = key?.toString() ?? '—';
  return value.isEmpty ? '—' : value;
}

Color _accentColor(int index) {
  final colors = [
    _LadnaColors.coral,
    _LadnaColors.primary,
    _LadnaColors.green,
    _LadnaColors.text,
    _LadnaColors.muted,
  ];
  return colors[index % colors.length];
}

Color _softColor(int index) {
  final colors = [
    Color(0x1FD4E040),
    Color(0x1F6B54C0),
    Color(0x1F16B8A8),
    Color(0x1F825ABE),
  ];
  return colors[index % colors.length];
}

IconData _expenseIcon(int index) {
  const icons = [
    Icons.shopping_bag_rounded,
    Icons.restaurant_rounded,
    Icons.directions_transit_rounded,
    Icons.subscriptions_rounded,
    Icons.home_rounded,
    Icons.more_horiz_rounded,
  ];
  return icons[index % icons.length];
}
