import 'package:flutter/material.dart';

class NestPill extends StatelessWidget {
  final Widget leading;
  final String text;

  const NestPill({
    super.key,
    required this.leading,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? scheme.surfaceContainer
        : scheme.surfaceContainerHighest;

    final borderColor = scheme.outlineVariant;
    final textColor = scheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme(
            data: IconThemeData(
              color: scheme.primary,
              size: 18,
            ),
            child: leading,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }
}