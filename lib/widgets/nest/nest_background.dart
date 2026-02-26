import 'dart:ui';
import 'package:flutter/material.dart';

class NestBackground extends StatelessWidget {
  final Widget child;
  const NestBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _Bg(),
        SafeArea(child: child),
      ],
    );
  }
}

class _Bg extends StatelessWidget {
  const _Bg();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Базовые цвета бренда (дублируем здесь намеренно, чтобы файл был автономным)
    const deepBlue = Color(0xFF004A98); // из референса
    const blue = Color(0xFF005DBF); // primary
    const accent = Color(0xFF42B8FD); // accent

    // Градиент фона: в light — мягкий голубой, в dark — плотный navy/blue
    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              scheme.surface, // 0xFF06162D из твоей темы
              scheme.surfaceContainer, // чуть светлее
              deepBlue.withOpacity(0.20),
              scheme.surface,
            ]
          : [
              scheme.surface, // 0xFFF2F7FF
              scheme.surfaceContainer, // 0xFFEAF2FF
              scheme.surfaceContainerHigh, // 0xFFE2EEFF
              scheme.surface,
            ],
    );

    return Container(
      decoration: BoxDecoration(gradient: bgGradient),
      child: Stack(
        children: [
          // Блоб сверху слева
          Positioned(
            top: -140,
            left: -120,
            child: _SoftBlob(
              size: 360,
              colors: isDark
                  ? [
                      accent.withOpacity(0.22),
                      blue.withOpacity(0.04),
                    ]
                  : [
                      accent.withOpacity(0.18),
                      blue.withOpacity(0.05),
                    ],
              blur: isDark ? 54 : 48,
            ),
          ),

          // Блоб снизу справа
          Positioned(
            bottom: -180,
            right: -140,
            child: _SoftBlob(
              size: 420,
              colors: isDark
                  ? [
                      blue.withOpacity(0.18),
                      deepBlue.withOpacity(0.04),
                    ]
                  : [
                      blue.withOpacity(0.14),
                      deepBlue.withOpacity(0.03),
                    ],
              blur: isDark ? 58 : 50,
            ),
          ),

          // Маленький блоб справа сверху
          Positioned(
            top: 120,
            right: -90,
            child: _SoftBlob(
              size: 240,
              colors: isDark
                  ? [
                      accent.withOpacity(0.16),
                      deepBlue.withOpacity(0.03),
                    ]
                  : [
                      accent.withOpacity(0.12),
                      deepBlue.withOpacity(0.02),
                    ],
              blur: isDark ? 50 : 44,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final double blur;

  const _SoftBlob({
    required this.size,
    required this.colors,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}