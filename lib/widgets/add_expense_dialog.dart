// lib/widgets/add_expense_dialog.dart
import 'package:flutter/material.dart';

import '../domain/category.dart' as dm;
import '../l10n/app_localizations.dart';

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
  bool _creatingCategory = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null
          ? widget.initialAmount!.toStringAsFixed(2)
          : '',
    );
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _selectedCategoryId = widget.initialCategoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? v) {
    final l = AppLocalizations.of(context)!;
    final d = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (d == null || d <= 0) return l.addExpenseAmountInvalid;
    return null;
  }

  Future<void> _createCategory() async {
    if (_creatingCategory) return;
    final l = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => _LadnaCategoryDialog(
        title: l.addExpenseNewCategoryTitle,
        label: l.addExpenseCategoryNameLabel,
        cancel: l.commonCancel,
        create: l.commonCreate,
        controller: ctrl,
      ),
    );
    ctrl.dispose();

    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return;

    setState(() => _creatingCategory = true);
    try {
      final id = await widget.onCreateCategory(trimmed);
      if (mounted) setState(() => _selectedCategoryId = id);
    } finally {
      if (mounted) setState(() => _creatingCategory = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      return;
    }
    final amount = double.parse(_amountController.text.trim().replaceAll(',', '.'));
    Navigator.pop(
      context,
      AddExpenseResult(
        amount: amount,
        categoryId: _selectedCategoryId!,
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);
    final isEdit = widget.initialAmount != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: media.size.height * 0.82,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FA),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE0DCF0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                18,
                16,
                18,
                18 + media.viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DialogHeader(
                      icon: Icons.trending_down_rounded,
                      title: isEdit ? l.addExpenseEditTitle : l.addExpenseNewTitle,
                      onClose: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 18),
                    _LadnaTextField(
                      controller: _amountController,
                      label: l.addExpenseAmountLabel,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: 12),
                    _CategoryPicker(
                      label: l.addExpenseCategoryLabel,
                      value: _selectedCategoryId,
                      categories: widget.categories,
                      validatorText: l.addExpenseCategoryRequired,
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _creatingCategory ? null : _createCategory,
                        icon: _creatingCategory
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.add_rounded),
                        label: Text(l.addExpenseCreateCategoryTooltip),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _LadnaTextField(
                      controller: _noteController,
                      label: l.addExpenseNoteLabel,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l.commonCancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF6B54C0),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(isEdit ? l.commonSave : l.commonAdd),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onClose;

  const _DialogHeader({required this.icon, required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEAE6F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFF6B54C0)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Geologica',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF160E38),
            ),
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded, color: Color(0xFF555268)),
        ),
      ],
    );
  }
}

class _LadnaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _LadnaTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.72),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE0DCF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE0DCF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF6B54C0), width: 1.4),
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final String label;
  final String? value;
  final List<dm.Category> categories;
  final ValueChanged<String?> onChanged;
  final String validatorText;

  const _CategoryPicker({
    required this.label,
    required this.value,
    required this.categories,
    required this.onChanged,
    required this.validatorText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items: categories
          .map(
            (c) => DropdownMenuItem(
              value: c.id,
              child: Text(c.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      selectedItemBuilder: (_) => categories
          .map((c) => Align(
                alignment: Alignment.centerLeft,
                child: Text(c.name, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? validatorText : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.72),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE0DCF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE0DCF0)),
        ),
      ),
    );
  }
}

class _LadnaCategoryDialog extends StatelessWidget {
  final String title;
  final String label;
  final String cancel;
  final String create;
  final TextEditingController controller;

  const _LadnaCategoryDialog({
    required this.title,
    required this.label,
    required this.cancel,
    required this.create,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => Navigator.pop(context, controller.text.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(create)),
      ],
    );
  }
}
