// lib/widgets/add_income_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:nest_app/l10n/app_localizations.dart';

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

  // edit
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

  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  String? _catId;
  bool _creatingCat = false;

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

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String? _validateAmount(String? v) {
    final l = AppLocalizations.of(context)!;
    final d = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (d == null || d <= 0) return l.addIncomeAmountInvalid;
    return null;
  }

  Future<void> _createCategory() async {
    if (_creatingCat) return;

    final name = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _CreateIncomeCategoryDialog(),
    );

    final n = (name ?? '').trim();
    if (n.isEmpty) return;

    setState(() => _creatingCat = true);
    try {
      final id = await widget.onCreateCategory(n);
      if (!mounted) return;
      setState(() => _catId = id);
    } finally {
      if (mounted) setState(() => _creatingCat = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _catId == null) return;
    final amount = double.parse(_amountCtrl.text.trim().replaceAll(',', '.'));
    Navigator.pop(
      context,
      AddIncomeResult(
        amount: amount,
        categoryId: _catId!,
        note: _noteCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isEdit = widget.initialAmount != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _NestDialogCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      _IconBadge(
                        icon: Icons.payments_rounded,
                        accent: cs.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit
                                  ? l.addIncomeEditTitle
                                  : l.addIncomeNewTitle,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2E4B5A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l.addIncomeSubtitle,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l.commonCloseTooltip,
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l.addIncomeAmountLabel,
                            hintText: l.addIncomeAmountHint,
                            prefixIcon: const Icon(
                              Icons.currency_ruble_rounded,
                            ),
                          ),
                          validator: _validateAmount,
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _catId,
                                items: widget.categories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => _catId = v),
                                decoration: InputDecoration(
                                  labelText: l.addIncomeCategoryLabel,
                                  prefixIcon: const Icon(
                                    Icons.category_outlined,
                                  ),
                                ),
                                validator: (v) => v == null
                                    ? l.addIncomeCategoryRequired
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 56,
                              width: 56,
                              child: OutlinedButton(
                                onPressed: _creatingCat
                                    ? null
                                    : _createCategory,
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: _creatingCat
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add_rounded),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _noteCtrl,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: l.addIncomeNoteLabel,
                            hintText: l.addIncomeNoteHint,
                            prefixIcon: const Icon(Icons.notes_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          label: Text(l.commonCancel),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _submit,
                          icon: Icon(
                            isEdit ? Icons.save_rounded : Icons.add_rounded,
                          ),
                          label: Text(isEdit ? l.commonSave : l.commonAdd),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
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

// ============================================================================
// Create category dialog (same design)
// ============================================================================

class _CreateIncomeCategoryDialog extends StatefulWidget {
  const _CreateIncomeCategoryDialog();

  @override
  State<_CreateIncomeCategoryDialog> createState() =>
      _CreateIncomeCategoryDialogState();
}

class _CreateIncomeCategoryDialogState
    extends State<_CreateIncomeCategoryDialog> {
  final _ctrl = TextEditingController();
  String? _err;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _ok() {
    final l = AppLocalizations.of(context)!;
    final v = _ctrl.text.trim();
    if (v.isEmpty) {
      setState(() => _err = l.addIncomeCategoryNameEmpty);
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _NestDialogCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _IconBadge(icon: Icons.add_rounded, accent: cs.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.addIncomeNewCategoryTitle,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2E4B5A),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l.commonCloseTooltip,
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ctrl,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _ok(),
                    decoration: InputDecoration(
                      labelText: l.addIncomeCategoryNameLabel,
                      hintText: l.addIncomeCategoryNameHint,
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                  ),
                  if (_err != null) ...[
                    const SizedBox(height: 10),
                    _ErrorPill(text: _err!),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          label: Text(l.commonCancel),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _ok,
                          icon: const Icon(Icons.check_rounded),
                          label: Text(l.commonCreate),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
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

// ============================================================================
// Shared “Nest” visuals (local, no imports)
// ============================================================================

class _NestDialogCard extends StatelessWidget {
  final Widget child;
  const _NestDialogCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2B5B7A),
                blurRadius: 26,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color accent;
  const _IconBadge({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.20)),
      ),
      child: Center(child: Icon(icon, size: 18, color: accent)),
    );
  }
}

class _ErrorPill extends StatelessWidget {
  final String text;
  const _ErrorPill({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.errorContainer.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.error.withOpacity(0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: cs.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(
                color: cs.onErrorContainer,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
