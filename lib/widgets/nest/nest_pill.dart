import 'package:flutter/material.dart';

class NestPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final EdgeInsets padding;
  final Color? accentColor;

  const NestPill({
    super.key,
    String? label,
    String? text,
    this.selected = false,
    this.onTap,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    this.accentColor,
  }) : label = label ?? text ?? '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? (isDark ? const Color(0xFFD4E040) : scheme.primary);

    final bg = selected
        ? (isDark ? accent.withOpacity(0.15) : scheme.primaryContainer)
        : (isDark ? const Color(0xFF1C1630) : const Color(0xFFEAE6F5));
    final fg = selected
        ? (isDark ? accent : scheme.onPrimaryContainer)
        : (isDark ? Colors.white.withOpacity(0.55) : scheme.onSurfaceVariant);
    final border = selected
        ? (isDark ? accent.withOpacity(0.30) : scheme.primary.withOpacity(0.18))
        : (isDark ? const Color(0x2E6B54C0) : const Color(0xFFE0DCF0));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border, width: 1),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withOpacity(isDark ? 0.12 : 0.16),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(color: fg, size: 16),
                  child: leading!,
                ),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
