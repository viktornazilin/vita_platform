import 'package:flutter/material.dart';

/// Теперь это не glassmorphism-компонент по умолчанию.
/// Название сохранено ради совместимости, но визуально карточка стала
/// значительно спокойнее и ближе к corporate / editorial style.
class NestBlurCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  /// Сохраняем параметры ради совместимости со старыми вызовами,
  /// но визуально больше не строим карточку вокруг blur/opacity.
  final double opacity;
  final double blur;

  const NestBlurCard({
    super.key,
    required this.child,
    this.radius = 26,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.opacity = 0.70,
    this.blur = 18,
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
              color: const Color(0xFF004A98).withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ];

    final content = Padding(
      padding: padding,
      child: child,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
            boxShadow: shadow,
          ),
          child: content,
        ),
      ),
    );
  }
}