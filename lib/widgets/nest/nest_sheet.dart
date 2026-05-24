import 'package:flutter/material.dart';

class NestSheet extends StatelessWidget {
  final Widget child;
  final Color? accentColor;

  const NestSheet({
    super.key,
    required this.child,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? scheme.secondary;

    final backgroundColor = isDark
        ? Color.lerp(scheme.surfaceContainerLow, accent, 0.055)!
        : Color.lerp(scheme.surfaceContainerLowest, accent, 0.10)!;

    final borderColor = Color.lerp(
      scheme.outlineVariant,
      accent,
      isDark ? 0.28 : 0.42,
    )!;

    final shadow = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 28,
              offset: const Offset(0, -8),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: scheme.primary.withOpacity(0.12),
              blurRadius: 26,
              offset: const Offset(0, -8),
            ),
            BoxShadow(
              color: accent.withOpacity(0.16),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1.25),
          left: BorderSide(color: borderColor, width: 1.25),
          right: BorderSide(color: borderColor, width: 1.25),
        ),
        boxShadow: shadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 5,
            margin: const EdgeInsets.only(top: 0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withOpacity(0.0),
                  accent.withOpacity(isDark ? 0.72 : 0.95),
                  scheme.tertiary.withOpacity(isDark ? 0.52 : 0.78),
                  scheme.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}
