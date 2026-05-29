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
    this.radius = 15,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.opacity = 1,
    this.blur = 12,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? (isDark ? const Color(0xFFD4E040) : scheme.primary);

    final backgroundColor = isDark
        ? const Color(0xFF1C1630).withOpacity(opacity.clamp(0.72, 1.0))
        : const Color(0xFFFAFAFE).withOpacity(opacity.clamp(0.72, 1.0));

    final borderColor = isDark
        ? Color.lerp(const Color(0x2E6B54C0), accent, 0.12)!
        : const Color(0xFFE0DCF0);

    final decorated = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: isDark ? 1.1 : 1.0),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.30) : scheme.primary.withOpacity(0.07),
            blurRadius: isDark ? 12 : 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
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
