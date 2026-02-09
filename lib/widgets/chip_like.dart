import 'dart:ui';
import 'package:flutter/material.dart';

class ChipLike extends StatelessWidget {
  final String label;

  /// Если хочешь точечно сделать чип “акцентнее” (например важность),
  /// можешь передать значение 0..1. По умолчанию нейтрально.
  final double accentStrength;

  /// Если хочешь добавить иконку без ломания стиля.
  final IconData? icon;

  const ChipLike({
    super.key,
    required this.label,
    this.accentStrength = 0.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final baseBg = const Color(0x7011121A);
    final border = Colors.white.withOpacity(0.12);

    final accent = primary.withOpacity(
      0.10 + 0.18 * accentStrength.clamp(0.0, 1.0),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: baseBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent, Colors.transparent],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x14FFFFFF),
                blurRadius: 12,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.78),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: (theme.textTheme.labelMedium ?? const TextStyle())
                    .copyWith(
                      letterSpacing: 0.2,
                      color: theme.colorScheme.onSurface.withOpacity(0.86),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
