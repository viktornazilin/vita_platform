import 'package:flutter/material.dart';

class NestSectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsets padding;

  const NestSectionTitle(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(2, 14, 2, 8),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // В dark чуть светлее для контраста
    final titleColor = isDark
        ? scheme.onSurface
        : scheme.onSurface;

    return Padding(
      padding: padding,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: titleColor,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}