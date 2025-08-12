// lib/screens/expenses_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expenses_model.dart';
import '../widgets/add_expense_dialog.dart';
import '../main.dart'; // dbRepo

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpensesModel(repo: dbRepo)..loadFor(DateTime.now()),
      child: const _ExpensesView(),
    );
  }
}

class _ExpensesView extends StatelessWidget {
  const _ExpensesView();

  Future<void> _pickDate(BuildContext context) async {
    final model = context.read<ExpensesModel>();
    final picked = await showDatePicker(
      context: context,
      initialDate: model.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) await model.setDate(picked);
  }

  Future<void> _addExpense(BuildContext context) async {
    final res = await showDialog<AddExpenseResult>(
      context: context,
      builder: (_) => const AddExpenseDialog(),
    );
    if (res != null) {
      await context.read<ExpensesModel>().addExpense(
            amount: res.amount,
            category: res.category,
            note: res.note,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExpensesModel>();
    final expensesToday = model.expensesToday;
    final total = model.totalToday;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расходы'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDate(context)),
        ],
      ),
      body: model.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Сумма за день: ${total.toStringAsFixed(2)} ₽',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Expanded(
                    child: expensesToday.isEmpty
                        ? const Center(child: Text('Нет расходов за этот день'))
                        : ListView.builder(
                            itemCount: expensesToday.length,
                            itemBuilder: (_, i) {
                              final exp = expensesToday[i];
                              return Card(
                                child: ListTile(
                                  title: Text('${exp['category']} — ${exp['amount']} ₽'),
                                  subtitle: Text((exp['note'] ?? '') as String),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addExpense(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
