import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedRail extends StatelessWidget {
  const FrostedRail({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 22,
    this.blur = 18,
    this.tint,
    this.borderOpacity = 0.14,
    this.shadowOpacity = 0.35,
  });

  final Widget child;

  /// outer spacing вокруг rail
  final EdgeInsets padding;

  /// радиус скругления rail
  final double radius;

  /// сила blur
  final double blur;

  /// если хочешь принудительно задать tint (иначе берём тёмный “glass”)
  final Color? tint;

  /// прозрачность рамки (white-ish)
  final double borderOpacity;

  /// прозрачность тени
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // “Стекло” в твоём стиле: тёмный слой + мягкие блики
    final base = tint ?? const Color(0x8011121A);

    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: const Color(0x22FFFFFF).withOpacity(1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(shadowOpacity),
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                ),
                const BoxShadow(
                  color: Color(0x14FFFFFF),
                  blurRadius: 18,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: cs.onSurface.withOpacity(0.92)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
