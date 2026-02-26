import 'dart:ui';
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

    // Поверхность листа
    final surfaceColor =
        isDark ? scheme.surfaceContainerHigh : scheme.surface;

    // Контролируем прозрачность
    final opacity = isDark ? 0.90 : 0.82;

    // Бордер
    final borderColor = isDark
        ? scheme.outlineVariant.withOpacity(0.65)
        : scheme.outlineVariant.withOpacity(0.55);

    // Тень (лист "поднимается" вверх)
    final shadow = isDark
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 30,
              offset: const Offset(0, -12),
            ),
          ]
        : [
            BoxShadow(
              color: const Color(0xFF004A98).withOpacity(0.12),
              blurRadius: 28,
              offset: const Offset(0, -10),
            ),
          ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor.withOpacity(opacity),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: borderColor),
              boxShadow: shadow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}