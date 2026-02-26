import 'dart:ui';
import 'package:flutter/material.dart';

class NestCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const NestCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Плотная стеклянная поверхность
    final surfaceColor =
        isDark ? scheme.surfaceContainerHigh : scheme.surface;

    // Контролируем прозрачность (dark нельзя делать слишком прозрачным)
    final opacity = isDark ? 0.85 : 0.75;

    // Бордер от схемы (никаких фиксированных цветов)
    final borderColor = isDark
        ? scheme.outlineVariant.withOpacity(0.55)
        : scheme.outlineVariant.withOpacity(0.50);

    // Тень
    final shadow = isDark
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ]
        : [
            BoxShadow(
              color: const Color(0xFF004A98).withOpacity(0.10),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ];

    final content = Padding(
      padding: padding,
      child: child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: scheme.primary.withOpacity(isDark ? 0.12 : 0.08),
            highlightColor: scheme.primary.withOpacity(isDark ? 0.06 : 0.04),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(opacity),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: borderColor),
                boxShadow: shadow,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}