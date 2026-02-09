import 'package:flutter/material.dart';
import '../domain/category.dart' as dm;

class AddExpenseResult {
  final double amount;
  final String categoryId;
  final String note;

  AddExpenseResult({
    required this.amount,
    required this.categoryId,
    required this.note,
  });
}

class AddExpenseDialog extends StatefulWidget {
  final List<dm.Category> categories;
  final Future<String> Function(String name) onCreateCategory;

  // новые параметры для редактирования
  final double? initialAmount;
  final String? initialCategoryId;
  final String? initialNote;

  const AddExpenseDialog({
    super.key,
    required this.categories,
    required this.onCreateCategory,
    this.initialAmount,
    this.initialCategoryId,
    this.initialNote,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null
          ? widget.initialAmount!.toStringAsFixed(2)
          : '',
    );
    _noteController = TextEditingController(text: widget.initialNote ?? '');

    _selectedCategoryId =
        widget.initialCategoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
  }

  Future<void> _createCategory() async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новая категория'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Название'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameCtrl.text.trim()),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      final id = await widget.onCreateCategory(name);
      setState(() => _selectedCategoryId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialAmount != null ? 'Редактировать расход' : 'Новый расход',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Сумма'),
                validator: (v) {
                  final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (d == null || d <= 0) return 'Введите корректную сумму';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      items: widget.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                      decoration: const InputDecoration(labelText: 'Категория'),
                      validator: (v) => v == null ? 'Выберите категорию' : null,
                    ),
                  ),
                  IconButton(
                    onPressed: _createCategory,
                    icon: const Icon(Icons.add),
                    tooltip: 'Создать категорию',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Комментарий'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate() ||
                _selectedCategoryId == null) {
              return;
            }
            final amount = double.parse(
              _amountController.text.replaceAll(',', '.'),
            );
            Navigator.pop(
              context,
              AddExpenseResult(
                amount: amount,
                categoryId: _selectedCategoryId!,
                note: _noteController.text.trim(),
              ),
            );
          },
          child: Text(widget.initialAmount != null ? 'Сохранить' : 'Добавить'),
        ),
      ],
    );
  }
}
