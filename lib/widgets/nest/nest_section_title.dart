import 'package:flutter/material.dart';

class NestSectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  final bool showAccent;
  final Color? accentColor;

  const NestSectionTitle(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(2, 18, 2, 10),
    this.showAccent = true,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = accentColor ?? scheme.secondary;

    final title = Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
            color: scheme.onSurface,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (showAccent) ...[
            Container(
              width: 8,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [accent, scheme.primary],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.34),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(child: title),
        ],
      ),
    );
  }
}
