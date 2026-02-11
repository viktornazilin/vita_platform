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
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E4B5A),
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}
