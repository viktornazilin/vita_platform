import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/budget_model.dart';
import '../domain/category.dart' as dm;
import '../domain/jar.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/add_income_dialog.dart';
import '../main.dart'; // dbRepo

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
    SnackBar(content: Text(wasCommitted ? 'Фиксация отменена' : 'Распределение зафиксировано')),
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

  Future<void> _commit(BuildContext context) async {
    final m = context.read<BudgetModel>();
    await m.commitJarAllocationForMonth();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Распределение зафиксировано')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<BudgetModel>();

    final loading = m.loading;
    final income = m.incomeMonth;
    final expense = m.expenseMonth;
    final free = (income - expense).clamp(0, double.infinity).toDouble();

    final committed = m.monthCommitted;
    final hasJars = m.jars.isNotEmpty;
    final canCommit = !committed && hasJars && m.freeCashFlowMonth > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расходы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _pickDate(context),
          ),
          IconButton(
  icon: Icon(m.monthCommitted ? Icons.undo : Icons.savings_outlined),
  tooltip: m.monthCommitted ? 'Отменить фиксацию' : 'Зафиксировать распределение по копилкам',
  onPressed: m.monthCommitted
      ? () => _toggleCommit(context)              // всегда можно отменить
      : (m.jars.isNotEmpty && m.freeCashFlowMonth > 0
          ? () => _toggleCommit(context)          // можно зафиксировать
          : null),
),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Настройки копилок и категорий',
            onPressed: () => Navigator.of(context).pushNamed('/budget'),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => m.load(),
              child: CustomScrollView(
                slivers: [
                  // ===== Верхний график "Доходы / Расходы / Свободно" =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: _BudgetTopCard(income: income, expense: expense, free: free),
                    ),
                  ),

                  // ===== Сумма за выбранный день =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        "Сумма за день: ${m.dayTx.where((t) => t.kind == 'expense').fold<double>(0.0, (s, t) => s + t.amount).toStringAsFixed(2)} ₽",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),

                  // ===== Список операций за день (с удалением свайпом) =====
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        if (m.dayTx.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(child: Text('Нет операций за этот день')),
                          );
                        }

                        final t = m.dayTx[i];
                        final catList =
                            t.kind == 'expense' ? m.expenseCategories : m.incomeCategories;
                        final cat = catList.firstWhere(
                          (c) => c.id == t.categoryId,
                          orElse: () => dm.Category(id: '', name: '—', kind: t.kind),
                        );
                        final color = t.kind == 'expense' ? Colors.red : Colors.green;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Dismissible(
                            key: ValueKey(t.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              color: Colors.red.withOpacity(0.15),
                              child: const Icon(Icons.delete, color: Colors.red),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Удалить операцию?'),
                                      content: Text("${cat.name} — ${t.amount.toStringAsFixed(2)} ₽"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Отмена'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Удалить'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (_) =>
                                context.read<BudgetModel>().deleteTransaction(t.id),
                            child: Card(
                              child: ListTile(
                                leading: Icon(
                                  t.kind == 'expense'
                                      ? Icons.remove_circle
                                      : Icons.add_circle,
                                  color: color,
                                ),
                                title: Text("${cat.name} — ${t.amount.toStringAsFixed(2)} ₽"),
                                subtitle: Text(t.note ?? ''),
                                trailing: Text(
                                  "${t.ts.hour.toString().padLeft(2, '0')}:${t.ts.minute.toString().padLeft(2, '0')}",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                onTap: () async {
  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Редактировать'),
          onTap: () => Navigator.pop(ctx, 'edit'),
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Удалить'),
          onTap: () => Navigator.pop(ctx, 'delete'),
        ),
      ],
    ),
  );

  if (action == 'delete') {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить операцию?'),
        content: Text("${cat.name} — ${t.amount.toStringAsFixed(2)} ₽"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirm == true) {
      context.read<BudgetModel>().deleteTransaction(t.id);
    }
  } else if (action == 'edit') {
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
        await m.addExpense(amount: res.amount, categoryId: res.categoryId, note: res.note);
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
        await m.addIncome(amount: res.amount, categoryId: res.categoryId, note: res.note);
      }
    }
  }
},

                              ),
                            ),
                          ),
                        );
                      },
                      childCount: m.dayTx.isEmpty ? 1 : m.dayTx.length,
                    ),
                  ),

                  // ===== «Банки» по категориям расходов за месяц =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Категории расходов за месяц',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _CategoryJarsGrid(data: m.expenseBreakdownMonth),
                  ),

                  // ===== Копилки =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Копилки', style: Theme.of(context).textTheme.titleMedium),
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
                  SliverToBoxAdapter(child: _SavingsJarsGrid(jars: m.jars)),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),

      // ===== FAB: добавить доход / расход =====
      floatingActionButton: _FabMenu(
        onAddExpense: () => _addExpense(context),
        onAddIncome: () => _addIncome(context),
      ),
    );
  }
}

/// Верхняя карточка со «стековой» полосой
class _BudgetTopCard extends StatelessWidget {
  final double income, expense, free;
  const _BudgetTopCard({
    required this.income,
    required this.expense,
    required this.free,
  });

  @override
  Widget build(BuildContext context) {
    final totalIncome = income <= 0 ? 1.0 : income;
    final expenseW = (expense / totalIncome).clamp(0.0, 1.0);
    final freeW = (free / totalIncome).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 6,
              children: [
                _legendDot(color: Colors.green, text: "Доходы ${income.toStringAsFixed(2)} ₽"),
                _legendDot(color: Colors.red, text: "Расходы ${expense.toStringAsFixed(2)} ₽"),
                _legendDot(color: Colors.blue, text: "Свободно ${free.toStringAsFixed(2)} ₽"),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 18,
                child: Row(
                  children: [
                    Expanded(
                      flex: (expenseW * 1000).round(),
                      child: Container(color: Colors.red),
                    ),
                    Expanded(
                      flex: (freeW * 1000).round(),
                      child: Container(color: Colors.blue),
                    ),
                    Expanded(
                      flex: (1000 - (expenseW * 1000).round() - (freeW * 1000).round())
                          .clamp(0, 1000),
                      child: Container(color: Colors.grey.shade300),
                    ),
                  ],
                ),
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

/// «Банки» категорий расходов за месяц
class _CategoryJarsGrid extends StatelessWidget {
  final Map<dm.Category, double> data;
  const _CategoryJarsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Пока нет данных по категориям'),
      );
    }

    final maxVal = data.values.fold<double>(0, (s, v) => v > s ? v : s);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: data.entries.map((e) {
          final p = maxVal == 0 ? 0.0 : (e.value / maxVal).clamp(0.0, 1.0);
          return _JarTile(
            title: e.key.name,
            subtitle: "${e.value.toStringAsFixed(0)} ₽",
            fill: p,
            color: Colors.orange,
          );
        }).toList(),
      ),
    );
  }
}

/// Карточка-«банка»
class _JarTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double fill; // 0..1
  final Color color;

  const _JarTile({
    required this.title,
    this.subtitle,
    required this.fill,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    FractionallySizedBox(
                      heightFactor: fill,
                      widthFactor: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.25 + 0.55 * fill),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
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
    if (jars.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Копилок пока нет'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: jars.map<Widget>((j) {
          final target = j.targetAmount ?? (j.currentAmount == 0 ? 1 : j.currentAmount * 2);
          final p = (j.currentAmount / target).clamp(0.0, 1.0);
          final subtitle = [
            if (j.targetAmount != null) "цель: ${j.targetAmount!.toStringAsFixed(0)} ₽",
            "накоплено: ${j.currentAmount.toStringAsFixed(0)} ₽",
            if (j.percentOfFree > 0) "${j.percentOfFree.toStringAsFixed(0)}% от свободных",
          ].join(' • ');
          return _JarTile(title: j.title, subtitle: subtitle, fill: p, color: Colors.blue);
        }).toList(),
      ),
    );
  }
}

class _FabMenu extends StatefulWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  const _FabMenu({
    required this.onAddIncome,
    required this.onAddExpense,
  });

  @override
  State<_FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<_FabMenu> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: !_open
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'addIncome',
                      onPressed: () {
                        setState(() => _open = false);
                        widget.onAddIncome();
                      },
                      tooltip: 'Добавить доход',
                      child: const Icon(Icons.trending_up),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'addExpense',
                      onPressed: () {
                        setState(() => _open = false);
                        widget.onAddExpense();
                      },
                      tooltip: 'Добавить расход',
                      child: const Icon(Icons.trending_down),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
        ),
        FloatingActionButton(
          heroTag: 'mainFab',
          onPressed: () => setState(() => _open = !_open),
          child: Icon(_open ? Icons.close : Icons.add),
        ),
      ],
    );
  }
}
