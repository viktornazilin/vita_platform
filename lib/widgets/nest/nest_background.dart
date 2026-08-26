import 'package:flutter/material.dart';

class NestBackground extends StatelessWidget {
  final Widget child;
  final bool useSoftGradient;
  final bool useAccentGlow;

  /// Если false — SafeArea не резервирует отступ снизу. Нужно экранам,
  /// которые сами управляют нижней зоной (например, `Scaffold` с
  /// `extendBody: true` и собственным `bottomNavigationBar`).
  final bool safeAreaBottom;

  const NestBackground({
    super.key,
    required this.child,
    this.useSoftGradient = false,
    this.useAccentGlow = true,
    this.safeAreaBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF100C1E) : const Color(0xFFF6F3FB),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF100C1E),
                  Color(0xFF0A0614),
                  Color(0xFF151026),
                ]
              // "Лавандовый туман" — мягкий, почти белый, с фиолетовым
              // подтоном по всему фону (не уходит в кремовый/мятный, как
              // было раньше).
              : const [
                  Color(0xFFF8F6FC),
                  Color(0xFFF3EFFA),
                  Color(0xFFF6F3FB),
                ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          if (useAccentGlow) ...[
            Positioned(
              top: -130,
              right: -110,
              child: _NestGlowOrb(
                size: 300,
                color: isDark
                    ? const Color(0xFF6B54C0).withOpacity(0.22)
                    : const Color(0xFF6B54C0).withOpacity(0.14),
              ),
            ),
            Positioned(
              top: 160,
              left: -135,
              child: _NestGlowOrb(
                size: 300,
                color: isDark
                    ? const Color(0xFFD4E040).withOpacity(0.08)
                    : const Color(0xFF9A85E0).withOpacity(0.16),
              ),
            ),
            Positioned(
              bottom: -165,
              right: -125,
              child: _NestGlowOrb(
                size: 360,
                color: const Color(0xFF6B54C0).withOpacity(isDark ? 0.16 : 0.12),
              ),
            ),
          ],
          SafeArea(bottom: safeAreaBottom, child: child),
        ],
      ),
    );
  }
}

class _NestGlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _NestGlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0.10),
              color.withOpacity(0.0),
            ],
            stops: const [0.0, 0.48, 1.0],
          ),
        ),
      ),
    );
  }
}