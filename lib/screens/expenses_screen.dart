import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/budget_model.dart';
import '../domain/category.dart' as dm;
import '../domain/jar.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/add_income_dialog.dart';
import '../main.dart'; // dbRepo

// ✅ Nest
import '../widgets/nest/nest_background.dart';
import '../widgets/nest/nest_blur_card.dart';

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

class _ExpensesView extends StatelessWidget {
  const _ExpensesView();

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

  Future<void> _toggleCommit(BuildContext context) async {
    final m = context.read<BudgetModel>();
    final wasCommitted = m.monthCommitted;
    await m.toggleJarAllocationForMonth();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          wasCommitted ? 'Фиксация отменена' : 'Распределение зафиксировано',
        ),
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

  @override
  Widget build(BuildContext context) {
    final m = context.watch<BudgetModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final loading = m.loading;
    final income = m.incomeMonth;
    final expense = m.expenseMonth;
    final free = (income - expense).clamp(0, double.infinity).toDouble();

    // центрирование контента на широких экранах
    final w = MediaQuery.of(context).size.width;
    const maxContentW = 900.0;
    final sidePad = w > maxContentW ? (w - maxContentW) / 2 : 0.0;

    double dayExpenseSum() => m.dayTx
        .where((t) => t.kind == 'expense')
        .fold<double>(0.0, (s, t) => s + t.amount);

    return Scaffold(
      body: NestBackground(
        child: loading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : RefreshIndicator.adaptive(
                onRefresh: () => m.load(),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      title: const Text('Расходы'),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          tooltip: 'Выбрать дату',
                          onPressed: () => _pickDate(context),
                        ),
                        IconButton(
                          icon: Icon(
                            m.monthCommitted
                                ? Icons.undo
                                : Icons.savings_outlined,
                          ),
                          tooltip: m.monthCommitted
                              ? 'Отменить фиксацию'
                              : 'Зафиксировать распределение по копилкам',
                          onPressed: (m.jars.isNotEmpty &&
                                  (m.monthCommitted ||
                                      m.freeCashFlowMonth > 0))
                              ? () => _toggleCommit(context)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune),
                          tooltip: 'Настройки копилок и категорий',
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/budget'),
                        ),
                      ],
                    ),

                    // ===== Верхняя сводка доход/расход/свободно =====
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16 + sidePad,
                        16,
                        16 + sidePad,
                        8,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _BudgetTopCard(
                          income: income,
                          expense: expense,
                          free: free,
                        ),
                      ),
                    ),

                    // ===== Сумма за выбранный день =====
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 + sidePad,
                        vertical: 8,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: NestBlurCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Text(
                              "Сумма за день: ${dayExpenseSum().toStringAsFixed(2)} €",
                              textAlign: TextAlign.center,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ===== Список операций за день =====
                    if (m.dayTx.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16 + sidePad),
                          child: Center(
                            child: Text(
                              'Нет операций за этот день',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16 + sidePad),
                        sliver: SliverList.separated(
                          itemCount: m.dayTx.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final t = m.dayTx[i];
                            final catList = t.kind == 'expense'
                                ? m.expenseCategories
                                : m.incomeCategories;
                            final cat = catList.firstWhere(
                              (c) => c.id == t.categoryId,
                              orElse: () =>
                                  dm.Category(id: '', name: '—', kind: t.kind),
                            );

                            final isExpense = t.kind == 'expense';
                            final kindColor = isExpense
                                ? cs.error
                                : cs.tertiary; // мягче, чем pure green

                            return Dismissible(
                              key: ValueKey(t.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: cs.errorContainer.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  Icons.delete_rounded,
                                  color: cs.onErrorContainer,
                                ),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(22),
                                        ),
                                        title:
                                            const Text('Удалить операцию?'),
                                        content: Text(
                                          "${cat.name} — ${t.amount.toStringAsFixed(2)} €",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Отмена'),
                                          ),
                                          FilledButton.tonal(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Удалить'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;
                              },
                              onDismissed: (_) => context
                                  .read<BudgetModel>()
                                  .deleteTransaction(t.id),
                              child: _TxTileNest(
                                title:
                                    "${cat.name} — ${t.amount.toStringAsFixed(2)} €",
                                subtitle: (t.note ?? '').trim(),
                                time:
                                    "${t.ts.hour.toString().padLeft(2, '0')}:${t.ts.minute.toString().padLeft(2, '0')}",
                                icon: isExpense
                                    ? Icons.remove_circle_rounded
                                    : Icons.add_circle_rounded,
                                iconColor: kindColor,
                                onTap: () async {
                                  final action =
                                      await showModalBottomSheet<String>(
                                    context: context,
                                    showDragHandle: true,
                                    builder: (ctx) => SafeArea(
                                      top: false,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.edit),
                                            title:
                                                const Text('Редактировать'),
                                            onTap: () =>
                                                Navigator.pop(ctx, 'edit'),
                                          ),
                                          ListTile(
                                            leading:
                                                const Icon(Icons.delete_rounded),
                                            title: const Text('Удалить'),
                                            onTap: () =>
                                                Navigator.pop(ctx, 'delete'),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  );

                                  if (action == 'delete') {
                                    final confirm =
                                        await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(22),
                                        ),
                                        title:
                                            const Text('Удалить операцию?'),
                                        content: Text(
                                          "${cat.name} — ${t.amount.toStringAsFixed(2)} €",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Отмена'),
                                          ),
                                          FilledButton.tonal(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Удалить'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      // ignore: use_build_context_synchronously
                                      context
                                          .read<BudgetModel>()
                                          .deleteTransaction(t.id);
                                    }
                                  } else if (action == 'edit') {
                                    if (t.kind == 'expense') {
                                      final res =
                                          await showDialog<AddExpenseResult>(
                                        context: context,
                                        builder: (_) => AddExpenseDialog(
                                          categories: m.expenseCategories,
                                          initialAmount: t.amount,
                                          initialCategoryId: t.categoryId,
                                          initialNote: t.note,
                                          onCreateCategory: (name) =>
                                              m.createCategory(
                                            name,
                                            'expense',
                                          ),
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
                                      final res =
                                          await showDialog<AddIncomeResult>(
                                        context: context,
                                        builder: (_) => AddIncomeDialog(
                                          categories: m.incomeCategories,
                                          initialAmount: t.amount,
                                          initialCategoryId: t.categoryId,
                                          initialNote: t.note,
                                          onCreateCategory: (name) =>
                                              m.createCategory(
                                            name,
                                            'income',
                                          ),
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

                    // ===== «Банки» по категориям расходов за месяц =====
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16 + sidePad,
                        16,
                        16 + sidePad,
                        8,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Категории расходов за месяц',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 8 + sidePad),
                      sliver: SliverToBoxAdapter(
                        child: _CategoryJarsGrid(data: m.expenseBreakdownMonth),
                      ),
                    ),

                    // ===== Копилки =====
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16 + sidePad,
                        16,
                        16 + sidePad,
                        8,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Копилки',
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (m.monthCommitted)
                              TextButton.icon(
                                onPressed: () => _toggleCommit(context),
                                icon: const Icon(Icons.undo),
                                label: const Text('Отменить фиксацию'),
                              )
                            else if (m.jars.isNotEmpty && m.freeCashFlowMonth > 0)
                              TextButton(
                                onPressed: () => _toggleCommit(context),
                                child: const Text('Зафиксировать'),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 8 + sidePad),
                      sliver: SliverToBoxAdapter(
                        child: _SavingsJarsGrid(jars: m.jars),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 92)),
                  ],
                ),
              ),
      ),

      floatingActionButton: _FabMenuNest(
        onAddExpense: () => _addExpense(context),
        onAddIncome: () => _addIncome(context),
      ),
    );
  }
}

/// ============================================================================
/// Nest tiles/cards
/// ============================================================================

class _TxTileNest extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _TxTileNest({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: NestBlurCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.35),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: cs.outlineVariant.withOpacity(0.6)),
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  time,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Верхняя карточка со «стековой» полосой (Nest)
class _BudgetTopCard extends StatelessWidget {
  final double income, expense, free;
  const _BudgetTopCard({
    required this.income,
    required this.expense,
    required this.free,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final totalIncome = income <= 0 ? 1.0 : income;
    final expenseW = (expense / totalIncome).clamp(0.0, 1.0);
    final freeW = (free / totalIncome).clamp(0.0, 1.0);

    final w = MediaQuery.of(context).size.width;
    final barH = w < 400 ? 12.0 : 14.0;

    return NestBlurCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                _legendDot(
                  color: cs.tertiary,
                  text: "Доходы ${income.toStringAsFixed(2)} €",
                ),
                _legendDot(
                  color: cs.error,
                  text: "Расходы ${expense.toStringAsFixed(2)} €",
                ),
                _legendDot(
                  color: cs.primary,
                  text: "Свободно ${free.toStringAsFixed(2)} €",
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: barH,
                child: Row(
                  children: [
                    Expanded(
                      flex: (expenseW * 1000).round(),
                      child: Container(color: cs.error.withOpacity(0.75)),
                    ),
                    Expanded(
                      flex: (freeW * 1000).round(),
                      child: Container(color: cs.primary.withOpacity(0.75)),
                    ),
                    Expanded(
                      flex: (1000 -
                              (expenseW * 1000).round() -
                              (freeW * 1000).round())
                          .clamp(0, 1000),
                      child: Container(
                        color: cs.surfaceContainerHighest.withOpacity(0.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Сводка месяца',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}

/// «Банки» категорий расходов за месяц — адаптивная сетка (Nest)
class _CategoryJarsGrid extends StatelessWidget {
  final Map<dm.Category, double> data;
  const _CategoryJarsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Пока нет данных по категориям',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    }

    final maxVal = data.values.fold<double>(0, (s, v) => v > s ? v : s);

    return LayoutBuilder(
      builder: (ctx, c) {
        final maxW = c.maxWidth;
        const minTile = 150.0;
        const maxTile = 220.0;
        int cols = (maxW / minTile).floor().clamp(1, 6);
        double tileW = (maxW / cols).clamp(minTile, maxTile);

        while (tileW > maxTile && cols < 8) {
          cols += 1;
          tileW = (maxW / cols).clamp(minTile, maxTile);
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: data.entries.map((e) {
            final p = maxVal == 0 ? 0.0 : (e.value / maxVal).clamp(0.0, 1.0);
            return SizedBox(
              width: tileW - 10,
              child: _JarTileNest(
                title: e.key.name,
                subtitle: "${e.value.toStringAsFixed(0)} €",
                fill: p,
                color: cs.secondary, // мягкий “янтарный” в теме — если есть
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Карточка-«банка» (Nest)
class _JarTileNest extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double fill; // 0..1
  final Color color;

  const _JarTileNest({
    required this.title,
    this.subtitle,
    required this.fill,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return NestBlurCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  FractionallySizedBox(
                    heightFactor: fill.clamp(0.0, 1.0),
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            color.withOpacity(0.85),
                            color.withOpacity(0.35),
                            color.withOpacity(0.12),
                          ],
                          stops: const [0.0, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SavingsJarsGrid extends StatelessWidget {
  final List<Jar> jars;
  const _SavingsJarsGrid({required this.jars});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (jars.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Копилок пока нет',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (ctx, c) {
        final maxW = c.maxWidth;
        const minTile = 150.0;
        const maxTile = 220.0;
        int cols = (maxW / minTile).floor().clamp(1, 6);
        double tileW = (maxW / cols).clamp(minTile, maxTile);
        while (tileW > maxTile && cols < 8) {
          cols += 1;
          tileW = (maxW / cols).clamp(minTile, maxTile);
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: jars.map<Widget>((j) {
            final target =
                j.targetAmount ?? (j.currentAmount == 0 ? 1 : j.currentAmount * 2);
            final p = (j.currentAmount / target).clamp(0.0, 1.0);

            final subtitle = [
              if (j.targetAmount != null)
                "цель: ${j.targetAmount!.toStringAsFixed(0)} €",
              "накоплено: ${j.currentAmount.toStringAsFixed(0)} €",
              if (j.percentOfFree > 0)
                "${j.percentOfFree.toStringAsFixed(0)}% от свободных",
            ].join(' • ');

            return SizedBox(
              width: tileW - 10,
              child: _JarTileNest(
                title: j.title,
                subtitle: subtitle,
                fill: p,
                color: cs.primary,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// FAB menu (Nest)
class _FabMenuNest extends StatefulWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  const _FabMenuNest({required this.onAddIncome, required this.onAddExpense});

  @override
  State<_FabMenuNest> createState() => _FabMenuNestState();
}

class _FabMenuNestState extends State<_FabMenuNest> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget mini({
      required String hero,
      required IconData icon,
      required VoidCallback onTap,
      required String tooltip,
    }) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: cs.surface.withOpacity(0.70),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: cs.onSurface, size: 20),
              ),
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
                      hero: 'addIncome',
                      icon: Icons.trending_up_rounded,
                      tooltip: 'Добавить доход',
                      onTap: () {
                        setState(() => _open = false);
                        widget.onAddIncome();
                      },
                    ),
                    const SizedBox(height: 10),
                    mini(
                      hero: 'addExpense',
                      icon: Icons.trending_down_rounded,
                      tooltip: 'Добавить расход',
                      onTap: () {
                        setState(() => _open = false);
                        widget.onAddExpense();
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
        ),
        FloatingActionButton(
          heroTag: 'mainFab',
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          onPressed: () => setState(() => _open = !_open),
          child: Icon(_open ? Icons.close_rounded : Icons.add_rounded),
        ),
      ],
    );
  }
}
