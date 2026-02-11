import 'dart:ui';
import 'package:flutter/material.dart';

/// Универсальная "Nest" карточка: блюр + стекло + мягкая тень.
/// Совместима с вызовами вида: NestBlurCard(radius: 18, child: ...)
class NestBlurCard extends StatelessWidget {
  final Widget child;

  /// Радиус скругления
  final double radius;

  /// Внутренние отступы
  final EdgeInsets padding;

  /// По желанию — клик
  final VoidCallback? onTap;

  /// Прозрачность "стекла"
  final double opacity;

  const NestBlurCard({
    super.key,
    required this.child,
    this.radius = 26,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.opacity = 0.70,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: const Color(0xFFD6E6F5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A2B5B7A),
                    blurRadius: 26,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
