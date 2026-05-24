import 'package:flutter/material.dart';

class NestBlurCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double opacity;
  final double blur;
  final Color? accentColor;

  const NestBlurCard({
    super.key,
    required this.child,
    this.radius = 26,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.opacity = 0.92,
    this.blur = 18,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? scheme.secondary;

    final backgroundColor = isDark
        ? Color.lerp(scheme.surfaceContainerLow, accent, 0.07)!
        : Color.lerp(scheme.surfaceContainerLowest, accent, 0.115)!;

    final borderColor = Color.lerp(
      scheme.outlineVariant,
      accent,
      isDark ? 0.28 : 0.42,
    )!;

    final shadow = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.24),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: scheme.primary.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: accent.withOpacity(0.16),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ];

    final content = Padding(padding: padding, child: child);

    final decorated = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 1.45),
        boxShadow: shadow,
      ),
      child: content,
    );

    if (onTap == null) return decorated;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: decorated,
      ),
    );
  }
}
