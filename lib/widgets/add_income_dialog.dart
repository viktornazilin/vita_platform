// lib/widgets/add_income_dialog.dart
import 'dart:ui';

import 'package:flutter/material.dart';

import '../domain/category.dart' as dm;
import '../l10n/app_localizations.dart';

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
    if (d == null || d <= 0) return l.addIncomeAmountInvalid;
    return null;
  }

  Future<void> _createCategory() async {
    if (_creatingCategory) return;
    final l = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => _LadnaCategoryDialog(
        title: l.addIncomeNewCategoryTitle,
        label: l.addIncomeCategoryNameLabel,
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
      AddIncomeResult(
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: media.size.height * 0.84,
        ),
        child: _LadnaDialogShell(
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
                    icon: Icons.trending_up_rounded,
                    title: isEdit ? l.addIncomeEditTitle : l.addIncomeNewTitle,
                    onClose: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 18),
                  _LadnaTextField(
                    controller: _amountController,
                    label: l.addIncomeAmountLabel,
                    icon: Icons.euro_rounded,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: _validateAmount,
                  ),
                  const SizedBox(height: 10),
                  _CategoryPicker(
                    label: l.addIncomeCategoryLabel,
                    value: _selectedCategoryId,
                    categories: widget.categories,
                    validatorText: l.addIncomeCategoryRequired,
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _creatingCategory ? null : _createCategory,
                      style: TextButton.styleFrom(
                        foregroundColor: _LadnaColors.lime,
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      icon: _creatingCategory
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _LadnaColors.lime,
                              ),
                            )
                          : const Icon(Icons.add_rounded),
                      label: Text(l.addIncomeNewCategoryTitle),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _LadnaTextField(
                    controller: _noteController,
                    label: l.addIncomeNoteLabel,
                    icon: Icons.notes_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: _secondaryButtonStyle(),
                          child: Text(l.commonCancel),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: _primaryButtonStyle(),
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
    );
  }
}


class _LadnaColors {
  static bool get _dark =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

  static Color get surface => _dark ? const Color(0xF21D1732) : const Color(0xF8F4F0FF);
  static Color get field => _dark ? const Color(0xFF211A38) : const Color(0xFFEDE7FF);
  static Color get fieldStrong => _dark ? const Color(0xFF271F42) : const Color(0xFFF7F3FF);
  static Color get border => _dark ? const Color(0x666B54C0) : const Color(0xFFDAD2F1);
  static Color get borderSoft => _dark ? const Color(0x446B54C0) : const Color(0xFFE7DFFC);
  static Color get text => _dark ? const Color(0xFFF4F0FF) : const Color(0xFF160E38);
  static Color get muted => _dark ? const Color(0xB8D7CEF5) : const Color(0xFF7F7A9E);
  static const Color primary = Color(0xFF6B54C0);
  static const Color lime = Color(0xFFD4E040);
  static const Color green = Color(0xFF16B8A8);
  static const Color danger = Color(0xFFFF8A98);

  static List<BoxShadow> get shadow => [
        BoxShadow(
          color: Colors.black.withOpacity(_dark ? 0.34 : 0.16),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ];
}

class _LadnaDialogShell extends StatelessWidget {
  final Widget child;
  const _LadnaDialogShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: _LadnaColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _LadnaColors.border, width: 1.4),
            boxShadow: _LadnaColors.shadow,
          ),
          child: Stack(
            children: [
              Positioned(
                top: -90,
                right: -100,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _LadnaColors.primary.withOpacity(0.24),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -80,
                bottom: -90,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _LadnaColors.lime.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              child,
            ],
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
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _LadnaColors.primary.withOpacity(0.24),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _LadnaColors.border),
          ),
          child: Icon(icon, color: _LadnaColors.lime, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontFamilyFallback: const ['PlayfairDisplay', 'Georgia'],
              fontSize: 24,
              height: 1.02,
              fontWeight: FontWeight.w800,
              color: _LadnaColors.text,
              letterSpacing: -0.4,
            ),
          ),
        ),
        _RoundIconButton(
          icon: Icons.close_rounded,
          onTap: onClose,
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _LadnaColors.field,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _LadnaColors.borderSoft),
          ),
          child: Icon(icon, color: _LadnaColors.muted, size: 21),
        ),
      ),
    );
  }
}

class _LadnaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final IconData? icon;

  const _LadnaTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      cursorColor: _LadnaColors.lime,
      style: TextStyle(
        fontFamily: 'Geologica',
        fontSize: 16,
        height: 1.15,
        fontWeight: FontWeight.w800,
        color: _LadnaColors.text,
      ),
      decoration: _ladnaInput(label: label, icon: icon),
    );
  }
}

InputDecoration _ladnaInput({required String label, IconData? icon}) {
  return InputDecoration(
    labelText: label,
    isDense: true,
    prefixIcon: icon == null ? null : Icon(icon, color: _LadnaColors.muted),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: TextStyle(
      fontFamily: 'Geologica',
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: _LadnaColors.muted,
    ),
    errorStyle: const TextStyle(fontWeight: FontWeight.w700),
    filled: true,
    fillColor: _LadnaColors.field,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: _LadnaColors.borderSoft, width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: _LadnaColors.borderSoft, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _LadnaColors.primary, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: _LadnaColors.danger.withOpacity(0.75), width: 1.3),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: _LadnaColors.danger.withOpacity(0.9), width: 1.5),
    ),
  );
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
      dropdownColor: _LadnaColors.fieldStrong,
      iconEnabledColor: _LadnaColors.muted,
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
      style: TextStyle(
        fontFamily: 'Geologica',
        fontSize: 16,
        height: 1.15,
        fontWeight: FontWeight.w800,
        color: _LadnaColors.text,
      ),
      decoration: _ladnaInput(label: label, icon: Icons.grid_view_rounded),
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: _LadnaDialogShell(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: _LadnaColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  cursorColor: _LadnaColors.lime,
                  style: TextStyle(
                    color: _LadnaColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: _ladnaInput(label: label, icon: Icons.add_rounded),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => Navigator.pop(context, controller.text.trim()),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: _secondaryButtonStyle(),
                        child: Text(cancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, controller.text.trim()),
                        style: _primaryButtonStyle(),
                        child: Text(create),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

ButtonStyle _primaryButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: _LadnaColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  );
}

ButtonStyle _secondaryButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: _LadnaColors.text,
    padding: const EdgeInsets.symmetric(vertical: 14),
    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
    side: BorderSide(color: _LadnaColors.border),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  );
}

