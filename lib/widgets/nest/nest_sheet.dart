import 'package:flutter/material.dart';

class NestSheet extends StatelessWidget {
  final Widget child;

  const NestSheet({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? scheme.surfaceContainerLow
        : scheme.surfaceContainerLowest;

    final borderColor = scheme.outlineVariant;

    final shadow = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 22,
              offset: const Offset(0, -4),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF004A98).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(color: borderColor),
          left: BorderSide(color: borderColor),
          right: BorderSide(color: borderColor),
        ),
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}