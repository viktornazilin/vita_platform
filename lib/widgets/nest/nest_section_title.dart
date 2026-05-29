import 'package:flutter/material.dart';

class NestSectionTitle extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets padding;
  final bool showAccent;
  final Color? accentColor;

  const NestSectionTitle(
    this.text, {
    super.key,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.only(left: 4, right: 4, top: 16, bottom: 9),
    this.showAccent = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final accent = accentColor ?? (isDark ? const Color(0xFFD4E040) : scheme.primary);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (showAccent) ...[
            Container(
              width: 7,
              height: 22,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(isDark ? 0.18 : 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              text.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.25) : const Color(0xFF9090A8),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                foregroundColor: accent,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
