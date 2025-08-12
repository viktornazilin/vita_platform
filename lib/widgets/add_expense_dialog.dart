import 'package:flutter/material.dart';

class AddExpenseResult {
  final double amount;
  final String category;
  final String note;

  AddExpenseResult({
    required this.amount,
    required this.category,
    required this.note,
  });
}

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый расход'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Сумма'),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Категория'),
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Комментарий'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text.trim());
            if (amount == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Введите корректную сумму')),
              );
              return;
            }
            Navigator.pop(
              context,
              AddExpenseResult(
                amount: amount,
                category: _categoryController.text.trim(),
                note: _noteController.text.trim(),
              ),
            );
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}
