// lib/widgets/budget/add_category_sheet.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:nest_app/l10n/app_localizations.dart';

Future<String?> showAddCategorySheet(
  BuildContext context, {
  required bool income,
}) {
  final ctrl = TextEditingController();

  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false, // рисуем свой handle
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.35),
    elevation: 0,
    builder: (ctx) {
      final l = AppLocalizations.of(ctx)!;
      final cs = Theme.of(ctx).colorScheme;
      final tt = Theme.of(ctx).textTheme;

      final bottom =
          MediaQuery.of(ctx).viewInsets.bottom +
          MediaQuery.of(ctx).padding.bottom;

      final title = income
          ? l.budgetNewIncomeCategory
          : l.budgetNewExpenseCategory;
      final icon = income
          ? Icons.trending_up_rounded
          : Icons.trending_down_rounded;

      void submit() {
        final v = ctrl.text.trim();
        Navigator.pop(ctx, v.isEmpty ? null : v);
      }

      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, bottom + 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: _NestSheetCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.onSurfaceVariant.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // header
                      Row(
                        children: [
                          _IconBadge(icon: icon, accent: cs.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2E4B5A),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: l.commonClose,
                            onPressed: () => Navigator.pop(ctx, null),
                            icon: Icon(
                              Icons.close_rounded,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: ctrl,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: l.commonTitle,
                          hintText: l.budgetCategoryNameHint,
                          prefixIcon: const Icon(Icons.label_outline_rounded),
                        ),
                        onSubmitted: (_) => submit(),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: submit,
                          icon: const Icon(Icons.add_rounded),
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
                ),
              ),
            ),
          ),
        ),
      );
    },
  ).whenComplete(() => ctrl.dispose());
}

// ============================================================================
// Shared “Nest” visuals (локально, без импорта)
// ============================================================================

class _NestSheetCard extends StatelessWidget {
  final Widget child;
  const _NestSheetCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.86),
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
