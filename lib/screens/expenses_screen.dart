import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../domain/category.dart' as dm;
import '../domain/jar.dart';
import '../main.dart'; // dbRepo
import '../models/budget_model.dart';
import '../services/onboarding_tour_service.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/add_income_dialog.dart';
import '../widgets/nest/nest_background.dart';
import 'budget_setup_screen.dart';

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

class _ExpensesView extends StatefulWidget {
  const _ExpensesView();

  @override
  State<_ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<_ExpensesView> {
  final GlobalKey _controlsKey = GlobalKey();
  final GlobalKey _summaryKey = GlobalKey();
  final GlobalKey _transactionsKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    OnboardingTourService.activeHomeTab.addListener(_maybeShowExpensesOnboarding);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowExpensesOnboarding());
  }

  @override
  void dispose() {
    OnboardingTourService.activeHomeTab.removeListener(_maybeShowExpensesOnboarding);
    super.dispose();
  }

  void _maybeShowExpensesOnboarding() {
    if (!mounted || OnboardingTourService.activeHomeTab.value != 5) return;

    if (OnboardingTourService.shouldRunFullStep(NestFullOnboardingStep.expenses)) {
      OnboardingTourService.runFullFlowScreenStep(
        context: context,
        step: NestFullOnboardingStep.expenses,
        showTour: () => OnboardingTourService.showExpensesTour(
          context: context,
          controlsKey: _controlsKey,
          summaryKey: _summaryKey,
          transactionsKey: _transactionsKey,
          fabKey: _fabKey,
          markAsSeen: false,
        ),
      );
      return;
    }

    if (OnboardingTourService.isFullFlowActive) return;

    OnboardingTourService.showExpensesTourIfNeeded(
      context: context,
      controlsKey: _controlsKey,
      summaryKey: _summaryKey,
      transactionsKey: _transactionsKey,
      fabKey: _fabKey,
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final m = context.read<BudgetModel>();
    final picked = await showDatePicker(
      context: context,
      initialDate: m.selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) await m.setDay(picked);
  }

  Future<void> _shiftDay(BuildContext context, int deltaDays) async {
    final m = context.read<BudgetModel>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = DateTime(m.selectedDay.year, m.selectedDay.month, m.selectedDay.day);
    final target = current.add(Duration(days: deltaDays));

    if (target.isAfter(today)) return;
    await m.setDay(target);
  }

  Future<void> _openBudgetSetup(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BudgetSetupScreen()),
    );

    if (!context.mounted) return;
    await context.read<BudgetModel>().load();
  }

  Future<void> _toggleCommit(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final m = context.read<BudgetModel>();
    final wasCommitted = m.monthCommitted;

    await m.toggleJarAllocationForMonth();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(wasCommitted ? l.expensesCommitUndone : l.expensesCommitDone),
      ),
    );
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
    }
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
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: Text(l.expensesDeleteTxTitle),
        content: Text(l.expensesDeleteTxBody(categoryName, amount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx, false),
            child: Text(l.commonCancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dlgCtx, true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<BudgetModel>().deleteTransaction(txId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final m = context.watch<BudgetModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final income = m.incomeMonth;
    final expense = m.expenseMonth;
    final free = (income - expense).clamp(0, double.infinity).toDouble();
    final dayExpense = _dayExpenseSum(m);

    final screenW = MediaQuery.of(context).size.width;
    const maxContentW = 900.0;
    final sidePad = screenW > maxContentW ? (screenW - maxContentW) / 2 : 0.0;
    final horizontal = 18.0 + sidePad;

    return Scaffold(
      extendBody: true,
      body: NestBackground(
        child: m.loading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : SafeArea(
                bottom: false,
                child: RefreshIndicator.adaptive(
                  onRefresh: () => m.load(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 0),
                        sliver: SliverToBoxAdapter(
                          child: _TopNavigationBar(
                            title: l.expensesMonthSummary,
                            canPop: Navigator.of(context).canPop(),
                            onBack: () => Navigator.of(context).maybePop(),
                            onOpenSetup: () => _openBudgetSetup(context),
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 0),
                        sliver: SliverToBoxAdapter(
                          child: KeyedSubtree(
                            key: _summaryKey,
                            child: _HeroBudgetPanel(
                              selectedDay: m.selectedDay,
                              monthExpense: expense,
                              free: free,
                              dayExpense: dayExpense,
                              title: l.expensesMonthSummary,
                              dayLabel: l.expensesDaySum(dayExpense),
                              freeLabel: l.expensesFreeLegend(free),
                            ),
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 0),
                        sliver: SliverToBoxAdapter(
                          child: KeyedSubtree(
                            key: _controlsKey,
                            child: _DateControlStrip(
                              selectedDay: m.selectedDay,
                              onPrevDay: () => _shiftDay(context, -1),
                              onNextDay: () => _shiftDay(context, 1),
                              onPickDay: () => _pickDate(context),
                            ),
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 0),
                        sliver: SliverToBoxAdapter(
                          child: _BudgetMetricRow(
                            income: income,
                            expense: expense,
                            free: free,
                            incomeLabel: l.expensesIncomeLegend(income),
                            expenseLabel: l.expensesExpenseLegend(expense),
                            freeLabel: l.expensesFreeLegend(free),
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(horizontal, 26, horizontal, 10),
                        sliver: SliverToBoxAdapter(
                          child: _SectionTitle(
                            title: l.expensesDaySum(dayExpense),
                            subtitle: MaterialLocalizations.of(context).formatMediumDate(m.selectedDay),
                          ),
                        ),
                      ),

                      if (m.dayTx.isEmpty)
                        SliverPadding(
                          key: _transactionsKey,
                          padding: EdgeInsets.symmetric(horizontal: horizontal),
                          sliver: SliverToBoxAdapter(
                            child: _EmptyStateCard(text: l.expensesNoTxForDay),
                          ),
                        )
                      else
                        SliverPadding(
                          key: _transactionsKey,
                          padding: EdgeInsets.symmetric(horizontal: horizontal),
                          sliver: SliverList.separated(
                            itemCount: m.dayTx.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final t = m.dayTx[i];
                              final catList = t.kind == 'expense' ? m.expenseCategories : m.incomeCategories;
                              final cat = catList.firstWhere(
                                (c) => c.id == t.categoryId,
                                orElse: () => dm.Category(id: '', name: '—', kind: t.kind),
                              );
                              final isExpense = t.kind == 'expense';
                              final palette = _ExpensePalette.byIndex(context, i, isExpense: isExpense);
                              final time = '${t.ts.hour.toString().padLeft(2, '0')}:${t.ts.minute.toString().padLeft(2, '0')}';
                              final amountText = '${isExpense ? '-' : '+'}${_formatMoney(t.amount)} €';

                              return Dismissible(
                                key: ValueKey(t.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 18),
                                  decoration: BoxDecoration(
                                    color: cs.errorContainer.withOpacity(0.70),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Icon(Icons.delete_rounded, color: cs.onErrorContainer),
                                ),
                                confirmDismiss: (_) async {
                                  final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (dlgCtx) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                                          title: Text(l.expensesDeleteTxTitle),
                                          content: Text(l.expensesDeleteTxBody(cat.name, t.amount)),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(dlgCtx, false),
                                              child: Text(l.commonCancel),
                                            ),
                                            FilledButton.tonal(
                                              onPressed: () => Navigator.pop(dlgCtx, true),
                                              child: Text(l.commonDelete),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;
                                  return confirmed;
                                },
                                onDismissed: (_) => context.read<BudgetModel>().deleteTransaction(t.id),
                                child: _ExpenseStackCard(
                                  color: palette.background,
                                  foreground: palette.foreground,
                                  categoryName: cat.name,
                                  note: (t.note ?? '').trim(),
                                  amount: amountText,
                                  time: time,
                                  icon: isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                  onTap: () async {
                                    final action = await showModalBottomSheet<String>(
                                      context: context,
                                      showDragHandle: true,
                                      backgroundColor: cs.surface,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                                      ),
                                      builder: (ctx) => SafeArea(
                                        top: false,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons.edit_rounded),
                                              title: Text(l.commonEdit),
                                              onTap: () => Navigator.pop(ctx, 'edit'),
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.delete_rounded),
                                              title: Text(l.commonDelete),
                                              onTap: () => Navigator.pop(ctx, 'delete'),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      ),
                                    );

                                    if (action == 'delete') {
                                      if (!context.mounted) return;
                                      await _confirmDeleteTx(
                                        context: context,
                                        categoryName: cat.name,
                                        amount: t.amount,
                                        txId: t.id,
                                      );
                                      return;
                                    }

                                    if (action == 'edit') {
                                      if (t.kind == 'expense') {
                                        final res = await showDialog<AddExpenseResult>(
                                          context: context,
                                          builder: (_) => AddExpenseDialog(
                                            categories: m.expenseCategories,
                                            initialAmount: t.amount,
                                            initialCategoryId: t.categoryId,
                                            initialNote: t.note,
                                            onCreateCategory: (name) => m.createCategory(name, 'expense'),
                                          ),
                                        );
                                        if (res != null) {
                                          await m.deleteTransaction(t.id);
                                          await m.addExpense(
                                            amount: res.amount,
                                            categoryId: res.categoryId,
                                            note: res.note,
                                          );
                                        }
                                      } else {
                                        final res = await showDialog<AddIncomeResult>(
                                          context: context,
                                          builder: (_) => AddIncomeDialog(
                                            categories: m.incomeCategories,
                                            initialAmount: t.amount,
                                            initialCategoryId: t.categoryId,
                                            initialNote: t.note,
                                            onCreateCategory: (name) => m.createCategory(name, 'income'),
                                          ),
                                        );
                                        if (res != null) {
                                          await m.deleteTransaction(t.id);
                                          await m.addIncome(
                                            amount: res.amount,
                                            categoryId: res.categoryId,
                                            note: res.note,
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(horizontal, 28, horizontal, 10),
                        sliver: SliverToBoxAdapter(
                          child: _SectionTitle(
                            title: l.expensesCategoriesMonthTitle,
                            subtitle: l.expensesMonthSummary,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        sliver: SliverToBoxAdapter(
                          child: _CategoryWalletStack(
                            data: m.expenseBreakdownMonth,
                            emptyText: l.expensesNoCategoryData,
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(horizontal, 28, horizontal, 10),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                child: _SectionTitle(
                                  title: l.expensesJarsTitle,
                                  subtitle: l.expensesFreeLegend(free),
                                ),
                              ),
                              if (m.monthCommitted)
                                _SmallPillButton(
                                  label: l.expensesCommitUndoShort,
                                  icon: Icons.undo_rounded,
                                  onTap: () => _toggleCommit(context),
                                )
                              else if (m.jars.isNotEmpty && m.freeCashFlowMonth > 0)
                                _SmallPillButton(
                                  label: l.expensesCommitShort,
                                  icon: Icons.savings_rounded,
                                  onTap: () => _toggleCommit(context),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        sliver: SliverToBoxAdapter(
                          child: _SavingsJarsGrid(
                            jars: m.jars,
                            emptyText: l.expensesNoJars,
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 118)),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: KeyedSubtree(
        key: _fabKey,
        child: _FabMenuNest(
          onAddExpense: () => _addExpense(context),
          onAddIncome: () => _addIncome(context),
          addExpenseTooltip: l.expensesAddExpense,
          addIncomeTooltip: l.expensesAddIncome,
        ),
      ),
    );
  }
}

class _TopNavigationBar extends StatelessWidget {
  final String title;
  final bool canPop;
  final VoidCallback onBack;
  final VoidCallback onOpenSetup;

  const _TopNavigationBar({
    required this.title,
    required this.canPop,
    required this.onBack,
    required this.onOpenSetup,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        if (canPop) ...[
          _GlassIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: cs.onSurface,
            ),
          ),
        ),
        _GlassIconButton(icon: Icons.tune_rounded, onTap: onOpenSetup),
      ],
    );
  }
}

class _HeroBudgetPanel extends StatelessWidget {
  final DateTime selectedDay;
  final double monthExpense;
  final double free;
  final double dayExpense;
  final String title;
  final String dayLabel;
  final String freeLabel;

  const _HeroBudgetPanel({
    required this.selectedDay,
    required this.monthExpense,
    required this.free,
    required this.dayExpense,
    required this.title,
    required this.dayLabel,
    required this.freeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final ml = MaterialLocalizations.of(context);
    final month = ml.formatMonthYear(selectedDay);
    final day = selectedDay.day.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withOpacity(0.92),
            cs.surfaceContainerHighest.withOpacity(0.74),
          ],
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.38)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.headlineSmall?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                    height: 0.98,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              _RoundBadge(
                text: '€',
                background: cs.primary.withOpacity(0.16),
                foreground: cs.onPrimaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _NestWaveBand(expense: monthExpense, free: free),
          const SizedBox(height: 18),
          Text(
            month.toUpperCase(),
            style: tt.labelLarge?.copyWith(
              color: cs.onPrimaryContainer.withOpacity(0.66),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                day,
                style: tt.displayLarge?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontSize: 76,
                  fontWeight: FontWeight.w900,
                  height: 0.88,
                  letterSpacing: -4,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroValue(label: dayLabel, value: '-${_formatMoney(dayExpense)} €'),
                      const SizedBox(height: 8),
                      _HeroValue(label: freeLabel, value: '${_formatMoney(free)} €'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InlineTotalBar(expense: monthExpense, free: free),
        ],
      ),
    );
  }
}

class _HeroValue extends StatelessWidget {
  final String label;
  final String value;

  const _HeroValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: tt.bodySmall?.copyWith(
              color: cs.onPrimaryContainer.withOpacity(0.62),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleMedium?.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateControlStrip extends StatelessWidget {
  final DateTime selectedDay;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;
  final VoidCallback onPickDay;

  const _DateControlStrip({
    required this.selectedDay,
    required this.onPrevDay,
    required this.onNextDay,
    required this.onPickDay,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ml = MaterialLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sel = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final canGoNext = !sel.isAtSameMomentAs(today);

    return Container(
      height: 60,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.68),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          _PillIconButton(icon: Icons.chevron_left_rounded, onTap: onPrevDay),
          const SizedBox(width: 8),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onPickDay,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    ml.formatMediumDate(selectedDay),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.labelLarge?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _PillIconButton(icon: Icons.chevron_right_rounded, onTap: canGoNext ? onNextDay : null),
        ],
      ),
    );
  }
}

class _BudgetMetricRow extends StatelessWidget {
  final double income;
  final double expense;
  final double free;
  final String incomeLabel;
  final String expenseLabel;
  final String freeLabel;

  const _BudgetMetricRow({
    required this.income,
    required this.expense,
    required this.free,
    required this.incomeLabel,
    required this.expenseLabel,
    required this.freeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: _metricTitle(incomeLabel),
            value: _extractMoneyOrFormat(incomeLabel, income),
            icon: Icons.arrow_upward_rounded,
            color: _blueCardColor(context, 2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: _metricTitle(expenseLabel),
            value: _extractMoneyOrFormat(expenseLabel, expense),
            icon: Icons.arrow_downward_rounded,
            color: _blueCardColor(context, 1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: _metricTitle(freeLabel),
            value: _extractMoneyOrFormat(freeLabel, free),
            icon: Icons.account_balance_wallet_rounded,
            color: _blueCardColor(context, 0),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final fg = _bestForegroundFor(color, cs);

    return Container(
      height: 116,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: fg.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg.withOpacity(0.84), size: 22),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelMedium?.copyWith(
              color: fg.withOpacity(0.62),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseStackCard extends StatelessWidget {
  final Color color;
  final Color foreground;
  final String categoryName;
  final String note;
  final String amount;
  final String time;
  final IconData icon;
  final VoidCallback onTap;

  const _ExpenseStackCard({
    required this.color,
    required this.foreground,
    required this.categoryName,
    required this.note,
    required this.amount,
    required this.time,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final effectiveNote = note;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Ink(
          height: 116,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.24),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardIconBubble(icon: icon, foreground: foreground),
                  const Spacer(),
                  if (effectiveNote.isNotEmpty) ...[
                    Text(
                      effectiveNote,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelMedium?.copyWith(
                        color: foreground.withOpacity(0.58),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  SizedBox(
                    width: 170,
                    child: Text(
                      categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: tt.labelMedium?.copyWith(
                      color: foreground.withOpacity(0.48),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    amount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryWalletStack extends StatelessWidget {
  final Map<dm.Category, double> data;
  final String emptyText;

  const _CategoryWalletStack({required this.data, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _EmptyStateCard(text: emptyText);

    final items = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final visibleItems = items.take(8).toList();
    final maxVal = visibleItems.fold<double>(0, (s, e) => e.value > s ? e.value : s);
    final stackHeight = 112.0 + ((visibleItems.length - 1).clamp(0, 10) * 72.0);

    return SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: visibleItems.asMap().entries.map((indexed) {
          final index = indexed.key;
          final entry = indexed.value;
          final progress = maxVal <= 0 ? 0.0 : (entry.value / maxVal).clamp(0.0, 1.0);
          final palette = _ExpensePalette.byIndex(context, index, isExpense: true);

          return Positioned(
            left: 0,
            right: 0,
            top: index * 72.0,
            child: _WalletCategoryCard(
              title: entry.key.name,
              amount: '-${_formatMoney(entry.value)} €',
              progress: progress,
              color: palette.background,
              foreground: palette.foreground,
              icon: _categoryIcon(index),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WalletCategoryCard extends StatelessWidget {
  final String title;
  final String amount;
  final double progress;
  final Color color;
  final Color foreground;
  final IconData icon;

  const _WalletCategoryCard({
    required this.title,
    required this.amount,
    required this.progress,
    required this.color,
    required this.foreground,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      height: 112,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: foreground.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _CardIconBubble(icon: icon, foreground: foreground),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: foreground.withOpacity(0.13),
                    valueColor: AlwaysStoppedAnimation<Color>(foreground.withOpacity(0.72)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsJarsGrid extends StatelessWidget {
  final List<Jar> jars;
  final String emptyText;

  const _SavingsJarsGrid({required this.jars, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (jars.isEmpty) return _EmptyStateCard(text: emptyText);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final maxW = constraints.maxWidth;
        final cols = (maxW / 160).floor().clamp(2, 4).toInt();
        final tileW = (maxW - ((cols - 1) * 10)) / cols;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: jars.asMap().entries.map((indexed) {
            final i = indexed.key;
            final j = indexed.value;
            final target = j.targetAmount ?? (j.currentAmount == 0 ? 1 : j.currentAmount * 2);
            final fill = (j.currentAmount / target).clamp(0.0, 1.0);
            final palette = _ExpensePalette.byIndex(context, i, isExpense: false);

            final subtitle = [
              if (j.targetAmount != null) '${_formatMoney(j.currentAmount)} / ${_formatMoney(j.targetAmount!)} €' else '${_formatMoney(j.currentAmount)} €',
              if (j.percentOfFree > 0) '${j.percentOfFree.toStringAsFixed(0)}%',
            ].join(' • ');

            return SizedBox(
              width: tileW,
              child: _JarTileNest(
                title: j.title,
                subtitle: subtitle,
                fill: fill,
                color: palette.background,
                foreground: palette.foreground,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _JarTileNest extends StatelessWidget {
  final String title;
  final String subtitle;
  final double fill;
  final Color color;
  final Color foreground;

  const _JarTileNest({
    required this.title,
    required this.subtitle,
    required this.fill,
    required this.color,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      height: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 44,
                height: 62,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        border: Border.all(color: foreground.withOpacity(0.36)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    FractionallySizedBox(
                      heightFactor: fill.clamp(0.0, 1.0),
                      widthFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: foreground.withOpacity(0.58),
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tt.bodySmall?.copyWith(
              color: foreground.withOpacity(0.62),
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FabMenuNest extends StatefulWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;
  final String addIncomeTooltip;
  final String addExpenseTooltip;

  const _FabMenuNest({
    required this.onAddIncome,
    required this.onAddExpense,
    required this.addIncomeTooltip,
    required this.addExpenseTooltip,
  });

  @override
  State<_FabMenuNest> createState() => _FabMenuNestState();
}

class _FabMenuNestState extends State<_FabMenuNest> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    Widget mini({
      required IconData icon,
      required VoidCallback onTap,
      required String tooltip,
      required Color color,
    }) {
      return Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Ink(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: _bestForegroundFor(color, Theme.of(context).colorScheme), size: 22),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: !_open
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    mini(
                      icon: Icons.arrow_upward_rounded,
                      tooltip: widget.addIncomeTooltip,
                      color: _blueCardColor(context, 2),
                      onTap: () {
                        setState(() => _open = false);
                        widget.onAddIncome();
                      },
                    ),
                    const SizedBox(height: 10),
                    mini(
                      icon: Icons.arrow_downward_rounded,
                      tooltip: widget.addExpenseTooltip,
                      color: _blueCardColor(context, 1),
                      onTap: () {
                        setState(() => _open = false);
                        widget.onAddExpense();
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
        ),
        FloatingActionButton.large(
          heroTag: 'expensesFab',
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () => setState(() => _open = !_open),
          child: Icon(_open ? Icons.close_rounded : Icons.add_rounded, size: 32),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: tt.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String text;

  const _EmptyStateCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.68),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: tt.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SmallPillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SmallPillButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.primary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: cs.onPrimary, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: tt.labelMedium?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _PillIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: onTap == null
          ? cs.surfaceContainerHighest.withOpacity(0.30)
          : cs.surface.withOpacity(0.72),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            color: onTap == null
                ? cs.onSurfaceVariant.withOpacity(0.35)
                : cs.onSurface,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: cs.surface.withOpacity(0.62),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: cs.onSurface, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundBadge extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const _RoundBadge({
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        text,
        style: tt.titleLarge?.copyWith(color: foreground, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _CardIconBubble extends StatelessWidget {
  final IconData icon;
  final Color foreground;

  const _CardIconBubble({required this.icon, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: foreground, size: 18),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _NestWaveBand extends StatelessWidget {
  final double expense;
  final double free;

  const _NestWaveBand({required this.expense, required this.free});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = (expense + free) <= 0 ? 1.0 : expense + free;
    final expenseW = (expense / total).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        height: 86,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: cs.primary.withOpacity(0.92)),
            Positioned(
              left: -42,
              top: -22,
              child: _DecorCircle(size: 132, color: _blueCardColor(context, 0).withOpacity(0.94)),
            ),
            Positioned(
              right: -42,
              top: -22,
              child: _DecorCircle(size: 132, color: _blueCardColor(context, 2).withOpacity(0.90)),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -22,
              child: Align(
                alignment: Alignment(-0.8 + expenseW * 1.6, 0),
                child: _DecorCircle(size: 132, color: _blueCardColor(context, 4).withOpacity(0.88)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineTotalBar extends StatelessWidget {
  final double expense;
  final double free;

  const _InlineTotalBar({required this.expense, required this.free});

  @override
  Widget build(BuildContext context) {
    final total = (expense + free) <= 0 ? 1.0 : (expense + free);
    final expenseFlex = ((expense / total) * 1000).round().clamp(1, 999).toInt();
    final freeFlex = (1000 - expenseFlex).clamp(1, 999).toInt();

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 13,
        child: Row(
          children: [
            Expanded(flex: expenseFlex, child: Container(color: Theme.of(context).colorScheme.primary)),
            Expanded(flex: freeFlex, child: Container(color: _blueCardColor(context, 3))),
          ],
        ),
      ),
    );
  }
}

class _ExpensePalette {
  final Color background;
  final Color foreground;

  const _ExpensePalette(this.background, this.foreground);

  static _ExpensePalette byIndex(BuildContext context, int index, {required bool isExpense}) {
    final cs = Theme.of(context).colorScheme;
    final bg = _blueCardColor(context, index + (isExpense ? 0 : 2));
    final fg = _bestForegroundFor(bg, cs);
    return _ExpensePalette(bg, fg);
  }
}

Color _blueCardColor(BuildContext context, int index) {
  final cs = Theme.of(context).colorScheme;
  final base = cs.primary;
  final surface = cs.surface;
  final high = cs.surfaceContainerHighest;
  final container = cs.primaryContainer;

  final colors = <Color>[
    base,
    Color.lerp(base, surface, 0.18)!,
    Color.lerp(base, surface, 0.34)!,
    Color.lerp(container, base, 0.16)!,
    Color.lerp(container, high, 0.24)!,
    Color.lerp(base, high, 0.46)!,
    Color.lerp(container, surface, 0.16)!,
    high,
  ];

  return colors[index % colors.length];
}

Color _bestForegroundFor(Color background, ColorScheme cs) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : cs.onSurface;
}

IconData _categoryIcon(int index) {
  const icons = [
    Icons.credit_card_rounded,
    Icons.shopping_bag_rounded,
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.home_rounded,
    Icons.movie_rounded,
    Icons.fitness_center_rounded,
    Icons.more_horiz_rounded,
  ];
  return icons[index % icons.length];
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

String _metricTitle(String localizedLabel) {
  var text = localizedLabel.replaceAll(RegExp(r'[-+]?\d+[\d\s.,]*\s*€'), '').trim();
  text = text.replaceAll(RegExp(r'[:•–—-]+$'), '').trim();
  return text.isEmpty ? localizedLabel : text;
}

String _extractMoneyOrFormat(String localizedLabel, double value) {
  final euroIndex = localizedLabel.indexOf('€');
  if (euroIndex > 0) {
    final before = localizedLabel.substring(0, euroIndex).trim();
    final parts = before.split(RegExp(r'\s+'));
    if (parts.isNotEmpty) return '${parts.last} €';
  }
  return '${_formatMoney(value)} €';
}
