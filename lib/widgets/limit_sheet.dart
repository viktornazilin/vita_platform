import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:nest_app/l10n/app_localizations.dart';

Future<double?> showLimitSheet(
  BuildContext context, {
  required String categoryName,
  double? current,
}) {
  final ctrl = TextEditingController(text: current?.toStringAsFixed(0) ?? '');

  return showModalBottomSheet<double?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // ✅ Nest sheet сам рисует фон
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final cs = theme.colorScheme;
      final bottom = MediaQuery.of(ctx).viewInsets.bottom;
      final t = AppLocalizations.of(ctx)!;

      final inputTheme = theme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFFEFF7FF),
        labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.75)),
        hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.45)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFBBD9F7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFBBD9F7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: cs.primary.withOpacity(0.65),
            width: 1.4,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      );

      return Theme(
        data: theme.copyWith(inputDecorationTheme: inputTheme),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: _NestSheet(
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: cs.onSurface.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            _IconBubble(icon: Icons.tune_rounded),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                t.limitSheetTitle(categoryName),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                  color: const Color(0xFF2E4B5A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            t.limitSheetHintNoLimit,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        _NestCard(
                          child: TextField(
                            controller: ctrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: t.limitSheetFieldLabel,
                              hintText: t.limitSheetFieldHint,
                              prefixIcon: const Icon(
                                Icons.currency_ruble_rounded,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _SoftButton(
                                label: t.limitSheetCtaNoLimit,
                                kind: _SoftButtonKind.secondary,
                                onTap: () => Navigator.pop(ctx, null),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SoftButton(
                                label: t.commonSave,
                                kind: _SoftButtonKind.primary,
                                onTap: () {
                                  final s = ctrl.text.trim().replaceAll(
                                    ',',
                                    '.',
                                  );
                                  final v = s.isEmpty
                                      ? null
                                      : double.tryParse(s);
                                  Navigator.pop(ctx, v);
                                },
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
        ),
      );
    },
  );
}

/// ---------------- Nest UI blocks (локально, чтобы файл был самодостаточный) ----------------

class _NestSheet extends StatelessWidget {
  final Widget child;
  const _NestSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: const Color(0xFFD6E6F5)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A2B5B7A),
                  blurRadius: 28,
                  offset: Offset(0, -10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _NestCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _NestCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2B5B7A),
                blurRadius: 26,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  const _IconBubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary.withOpacity(0.95), cs.primary.withOpacity(0.55)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A2B5B7A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
    );
  }
}

enum _SoftButtonKind { primary, secondary }

class _SoftButton extends StatelessWidget {
  final String label;
  final _SoftButtonKind kind;
  final VoidCallback onTap;

  const _SoftButton({
    required this.label,
    required this.kind,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPrimary = kind == _SoftButtonKind.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isPrimary ? null : const Color(0xFFEFF7FF),
          gradient: isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(0.95),
                    cs.primary.withOpacity(0.55),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPrimary
                ? Colors.white.withOpacity(0.10)
                : const Color(0xFFBBD9F7),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A2B5B7A),
              blurRadius: 18,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: isPrimary ? Colors.white : const Color(0xFF2E4B5A),
            ),
          ),
        ),
      ),
    );
  }
}
