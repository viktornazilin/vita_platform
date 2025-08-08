import 'package:flutter/material.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _expenses = [];

  void _addExpense() {
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новый расход'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Сумма'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Категория'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Комментарий'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                setState(() {
                  _expenses.add({
                    'date': _selectedDate,
                    'amount': double.tryParse(amountController.text) ?? 0.0,
                    'category': categoryController.text.isEmpty ? 'Прочее' : categoryController.text,
                    'note': noteController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expensesToday = _expenses.where((e) =>
      e['date'].day == _selectedDate.day &&
      e['date'].month == _selectedDate.month &&
      e['date'].year == _selectedDate.year
    ).toList();

    final total = expensesToday.fold<double>(0.0, (sum, e) => sum + e['amount']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расходы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
        ],
      ),
      body: Padding(
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
                            subtitle: Text(exp['note'] ?? ''),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }
}
