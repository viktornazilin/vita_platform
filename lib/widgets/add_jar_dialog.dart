// lib/widgets/add_jar_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:nest_app/l10n/app_localizations.dart';

class NewJarData {
  final String title;
  final double? target;
  final double percent;
  const NewJarData(this.title, this.target, this.percent);
}

class AddJarDialog extends StatefulWidget {
  // ✅ для редактирования (если нужно)
  final String? initialTitle;
  final double? initialTarget;
  final double? initialPercent;

  const AddJarDialog({
    super.key,
    this.initialTitle,
    this.initialTarget,
    this.initialPercent,
  });

  @override
  State<AddJarDialog> createState() => _AddJarDialogState();
}

class _AddJarDialogState extends State<AddJarDialog> {
  late final TextEditingController _title;
  late final TextEditingController _target;
  late final TextEditingController _percent;

  String? _error;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialTitle ?? '');
    _target = TextEditingController(
      text: widget.initialTarget != null
          ? widget.initialTarget!.toString()
          : '',
    );
    _percent = TextEditingController(
      text: (widget.initialPercent ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    _percent.dispose();
    super.dispose();
  }

  double? _parseDouble(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll(',', '.'));
  }

  void _setErr(String msg) => setState(() => _error = msg);

  void _submit() {
    final l = AppLocalizations.of(context)!;

    final title = _title.text.trim();
    if (title.isEmpty) {
      _setErr(l.addJarNameRequired);
      return;
    }

    final percent = _parseDouble(_percent.text) ?? 0;
    if (percent < 0 || percent > 100) {
      _setErr(l.addJarPercentRange);
      return;
    }

    final target = _parseDouble(_target.text);
    if (target == null || target <= 0) {
      _setErr(l.addJarTargetRequired);
      return;
    }

    Navigator.pop(context, NewJarData(title, target, percent));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isEdit =
        widget.initialTitle != null ||
        widget.initialTarget != null ||
        widget.initialPercent != null;

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
                      const _IconBadge(icon: Icons.savings_rounded),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? l.addJarEditTitle : l.addJarNewTitle,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2E4B5A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l.addJarSubtitle,
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

                  // Fields
                  TextField(
                    controller: _title,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l.addJarNameLabel,
                      hintText: l.addJarNameHint,
                      prefixIcon: const Icon(Icons.title_rounded),
                    ),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _percent,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l.addJarPercentLabel,
                      hintText: l.addJarPercentHint,
                      prefixIcon: const Icon(Icons.percent_rounded),
                    ),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _target,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: l.addJarTargetLabel,
                      hintText: l.addJarTargetHint,
                      helperText: l.addJarTargetHelper,
                      prefixIcon: const Icon(
                        Icons.account_balance_wallet_rounded,
                      ),
                    ),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    _ErrorPill(text: _error!),
                  ],

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
                          label: Text(isEdit ? l.commonSave : l.commonCreate),
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
// Nest dialog card (локально, без внешних файлов)
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
  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Center(
        child: Icon(icon, size: 18, color: const Color(0xFF3AA8E6)),
      ),
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
