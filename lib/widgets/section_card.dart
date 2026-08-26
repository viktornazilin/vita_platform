import 'package:flutter/material.dart';

import 'nest/nest_blur_card.dart';
import 'nest/nest_glass_colors.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = NestGlassColors.of(context);

    return NestBlurCard(
      radius: 26,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: c.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: tt.bodySmall?.copyWith(
              color: c.text.withOpacity(0.65),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}