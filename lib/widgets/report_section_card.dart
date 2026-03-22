// lib/widgets/report_section_card.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class ReportSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ReportSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    final cardColor = isDark
        ? cs.surface.withOpacity(0.72)
        : cs.surface.withOpacity(0.88);

    final borderColor = isDark
        ? cs.outlineVariant.withOpacity(0.42)
        : cs.outlineVariant.withOpacity(0.72);

    final shadowColor = isDark
        ? Colors.black.withOpacity(0.22)
        : cs.shadow.withOpacity(0.10);

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TitleRow(title: title),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final String title;
  const _TitleRow({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                cs.primary,
                cs.primary.withOpacity(isDark ? 0.08 : 0.0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(isDark ? 0.35 : 0.20),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}