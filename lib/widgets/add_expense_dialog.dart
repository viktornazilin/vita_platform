// lib/widgets/add_expense_dialog.dart
import 'package:flutter/material.dart';

import 'package:nest_app/l10n/app_localizations.dart';

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

  // edit params
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
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
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

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    final l = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: Text(l.addExpenseNewCategoryTitle),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: l.addExpenseCategoryNameLabel),
          onSubmitted: (_) => Navigator.pop(dctx, nameCtrl.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: Text(l.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dctx, nameCtrl.text.trim()),
            child: Text(l.commonCreate),
          ),
        ],
      ),
    );

    nameCtrl.dispose();

    if (!mounted) return;
    if (name != null && name.trim().isNotEmpty) {
      final id = await widget.onCreateCategory(name.trim());
      if (!mounted) return;
      setState(() => _selectedCategoryId = id);
    }
  }

  String? _validateAmount(String? v) {
    final l = AppLocalizations.of(context)!;
    final d = double.tryParse((v ?? '').replaceAll(',', '.'));
    if (d == null || d <= 0) return l.addExpenseAmountInvalid;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final isEdit = widget.initialAmount != null;

    return AlertDialog(
      title: Text(isEdit ? l.addExpenseEditTitle : l.addExpenseNewTitle),
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
                decoration: InputDecoration(labelText: l.addExpenseAmountLabel),
                validator: _validateAmount,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      items: widget.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                      decoration: InputDecoration(
                        labelText: l.addExpenseCategoryLabel,
                      ),
                      validator: (v) =>
                          v == null ? l.addExpenseCategoryRequired : null,
                    ),
                  ),
                  IconButton(
                    onPressed: _createCategory,
                    icon: const Icon(Icons.add),
                    tooltip: l.addExpenseCreateCategoryTooltip,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: l.addExpenseNoteLabel),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.commonCancel),
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
          child: Text(isEdit ? l.commonSave : l.commonAdd),
        ),
      ],
    );
  }
}
