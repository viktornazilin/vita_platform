import 'package:flutter/material.dart';
import '../domain/category.dart' as dm;

class AddIncomeResult {
  final double amount;
  final String categoryId;
  final String note;

  AddIncomeResult({
    required this.amount,
    required this.categoryId,
    required this.note,
  });
}

class AddIncomeDialog extends StatefulWidget {
  final List<dm.Category> categories;
  final Future<String> Function(String name) onCreateCategory;

  // новые поля для редактирования
  final double? initialAmount;
  final String? initialCategoryId;
  final String? initialNote;

  const AddIncomeDialog({
    super.key,
    required this.categories,
    required this.onCreateCategory,
    this.initialAmount,
    this.initialCategoryId,
    this.initialNote,
  });

  @override
  State<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends State<AddIncomeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  String? _catId;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.initialAmount != null
          ? widget.initialAmount!.toStringAsFixed(2)
          : '',
    );
    _noteCtrl = TextEditingController(text: widget.initialNote ?? '');

    _catId =
        widget.initialCategoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
  }

  Future<void> _createCategory() async {
    final c = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новая категория дохода'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'Название'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, c.text.trim()),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
    if ((name ?? '').isNotEmpty) {
      final id = await widget.onCreateCategory(name!);
      setState(() => _catId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialAmount != null ? 'Редактировать доход' : 'Новый доход',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountCtrl,
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
                      initialValue: _catId,
                      items: widget.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _catId = v),
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
                controller: _noteCtrl,
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
            if (!_formKey.currentState!.validate() || _catId == null) return;
            final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));
            Navigator.pop(
              context,
              AddIncomeResult(
                amount: amount,
                categoryId: _catId!,
                note: _noteCtrl.text.trim(),
              ),
            );
          },
          child: Text(widget.initialAmount != null ? 'Сохранить' : 'Добавить'),
        ),
      ],
    );
  }
}
