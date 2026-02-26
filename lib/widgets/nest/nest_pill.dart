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

    // Плотный фон пилла
    final backgroundColor = isDark
        ? scheme.surfaceContainerHigh.withOpacity(0.90)
        : scheme.surfaceContainerHigh.withOpacity(0.95);

    // Бордер
    final borderColor = isDark
        ? scheme.outlineVariant.withOpacity(0.60)
        : scheme.outlineVariant.withOpacity(0.55);

    // Цвет текста — всегда контрастный
    final textColor = scheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme(
            data: IconThemeData(
              color: scheme.primary, // аккуратный акцент
              size: 18,
            ),
            child: leading,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }
}