import 'package:flutter/material.dart';

class NestCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius;

  const NestCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.radius = 24,
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF004A98).withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ];

    final body = Padding(
      padding: padding,
      child: child,
    );

    if (onTap == null) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor),
          boxShadow: shadow,
        ),
        child: body,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
            boxShadow: shadow,
          ),
          child: body,
        ),
      ),
    );
  }
}