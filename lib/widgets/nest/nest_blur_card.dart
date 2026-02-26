import 'dart:ui';
import 'package:flutter/material.dart';

/// Универсальная "Nest" карточка: блюр + стекло + премиальные плотные поверхности.
/// Автоматически адаптируется под light/dark и твою Nest-blue палитру.
/// Совместима с вызовами вида: NestBlurCard(radius: 18, child: ...)
class NestBlurCard extends StatelessWidget {
  final Widget child;

  /// Радиус скругления
  final double radius;

  /// Внутренние отступы
  final EdgeInsets padding;

  /// По желанию — клик
  final VoidCallback? onTap;

  /// Интенсивность "стекла" (0..1). Внутри будет скорректировано под тему.
  final double opacity;

  /// Сила блюра
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

    // "Стекло" должно быть плотным и контрастным:
    // - в light — светлая стеклянная поверхность
    // - в dark — глубокая navy поверхность (не белая!)
    final glassColor = isDark ? scheme.surfaceContainerHigh : scheme.surface;

    // Опасный момент: прозрачность. В dark слишком прозрачное стекло даёт "грязь".
    // Поэтому поджимаем диапазон.
    final o = isDark
        ? opacity.clamp(0.72, 0.92)
        : opacity.clamp(0.55, 0.85);

    // Бордер — только от схемы (никаких хардкодов)
    final borderColor = isDark
        ? scheme.outlineVariant.withOpacity(0.60)
        : scheme.outlineVariant.withOpacity(0.55);

    // Тень:
    // - в light мягкая и чуть синяя
    // - в dark очень деликатная (почти без тени, иначе выглядит "пыльно")
    final shadow = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF004A98).withOpacity(0.10), // deep blue tint
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ];

    final content = Padding(padding: padding, child: child);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            // делаем риппл аккуратным и контрастным
            splashColor: scheme.primary.withOpacity(isDark ? 0.14 : 0.10),
            highlightColor: scheme.primary.withOpacity(isDark ? 0.06 : 0.04),
            child: Container(
              decoration: BoxDecoration(
                color: glassColor.withOpacity(o),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: borderColor, width: 1),
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