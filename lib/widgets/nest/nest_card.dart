import 'package:flutter/material.dart';

class NestCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? accentColor;

  const NestCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.radius = 24,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? scheme.secondary;

    final backgroundColor = isDark
        ? Color.lerp(scheme.surfaceContainerLow, accent, 0.065)!
        : Color.lerp(scheme.surfaceContainerLowest, accent, 0.105)!;

    final borderColor = Color.lerp(
      scheme.outlineVariant,
      accent,
      isDark ? 0.26 : 0.38,
    )!;

    final shadow = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: scheme.primary.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: accent.withOpacity(0.13),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ];

    final body = Padding(padding: padding, child: child);

    final decorated = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 1.35),
        boxShadow: shadow,
      ),
      child: body,
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
