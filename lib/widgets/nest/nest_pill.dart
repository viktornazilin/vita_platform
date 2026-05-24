import 'package:flutter/material.dart';

class NestPill extends StatelessWidget {
  final Widget leading;
  final String text;
  final Color? accentColor;

  const NestPill({
    super.key,
    required this.leading,
    required this.text,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? scheme.secondary;

    final backgroundColor = isDark
        ? Color.lerp(scheme.surfaceContainer, accent, 0.20)!
        : Color.lerp(scheme.surfaceContainerHighest, accent, 0.32)!;

    final borderColor = Color.lerp(
      scheme.outlineVariant,
      accent,
      isDark ? 0.40 : 0.54,
    )!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1.25),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isDark ? 0.08 : 0.14),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme(
            data: IconThemeData(color: accent, size: 18),
            child: leading,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
