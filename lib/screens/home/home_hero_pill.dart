import 'package:flutter/material.dart';

class HomeHeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;

  const HomeHeroPill({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = cs.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(cs.surfaceContainerHighest, accent, isDark ? 0.06 : 0.14)!,
            cs.surfaceContainerHighest.withOpacity(isDark ? 0.58 : 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Color.lerp(cs.outlineVariant, accent, isDark ? 0.18 : 0.30)!,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isDark ? 0.06 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                sublabel,
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
