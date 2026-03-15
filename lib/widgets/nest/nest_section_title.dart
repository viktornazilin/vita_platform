import 'package:flutter/material.dart';

class NestSectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsets padding;

  const NestSectionTitle(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(2, 18, 2, 10),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: scheme.onSurface,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}