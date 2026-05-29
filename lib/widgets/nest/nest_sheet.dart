import 'package:flutter/material.dart';

class NestSheet extends StatelessWidget {
  final Widget child;
  final Color? accentColor;

  const NestSheet({
    super.key,
    required this.child,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? (isDark ? const Color(0xFFD4E040) : const Color(0xFF6B54C0));

    final backgroundColor = isDark ? const Color(0xFF100C1E) : const Color(0xFFF5F3FA);
    final borderColor = isDark ? const Color(0x406B54C0) : const Color(0xFFE0DCF0);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1.2),
          left: BorderSide(color: borderColor, width: 1.2),
          right: BorderSide(color: borderColor, width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.52) : const Color(0xFF6B54C0).withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
          if (isDark)
            BoxShadow(
              color: accent.withOpacity(0.06),
              blurRadius: 26,
              offset: const Offset(0, -10),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.18) : const Color(0xFFD0CCD8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}
