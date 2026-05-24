import 'package:flutter/material.dart';

class NestBackground extends StatelessWidget {
  final Widget child;
  final bool useSoftGradient;
  final bool useAccentGlow;

  const NestBackground({
    super.key,
    required this.child,
    this.useSoftGradient = false,
    this.useAccentGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                scheme.surface,
                scheme.surfaceContainerLow,
                Color.lerp(scheme.surfaceContainer, scheme.primary, 0.12)!,
              ]
            : [
                const Color(0xFFF7F2E6),
                const Color(0xFFEFF6F7),
                const Color(0xFFEAF3FF),
              ],
        stops: const [0.0, 0.48, 1.0],
      ),
    );

    return Container(
      decoration: decoration,
      child: Stack(
        children: [
          if (useAccentGlow) ...[
            Positioned(
              top: -125,
              right: -95,
              child: _NestGlowOrb(
                size: 300,
                color: scheme.secondary.withOpacity(isDark ? 0.24 : 0.36),
              ),
            ),
            Positioned(
              top: 185,
              left: -135,
              child: _NestGlowOrb(
                size: 300,
                color: scheme.tertiary.withOpacity(isDark ? 0.18 : 0.28),
              ),
            ),
            Positioned(
              bottom: -165,
              right: -120,
              child: _NestGlowOrb(
                size: 340,
                color: scheme.primary.withOpacity(isDark ? 0.16 : 0.22),
              ),
            ),
          ],
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _NestGlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _NestGlowOrb({
    required this.size,
    required this.color,
  });

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
