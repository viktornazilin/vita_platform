import 'dart:ui';

import 'package:flutter/material.dart';
import 'nest/nest_glass_colors.dart';

class ProfileFieldCard extends StatelessWidget {
  final String label;
  final dynamic value; // int, List, String, null

  const ProfileFieldCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    final tt = Theme.of(context).textTheme;
    final c = NestGlassColors.of(context);

    Widget body;
    if (value is List) {
      final list = value.cast<dynamic>();
      if (list.isEmpty) return const SizedBox.shrink();

      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final v in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(
                    child: Text(
                      v.toString(),
                      style: tt.bodyMedium?.copyWith(
                        color: c.text.withOpacity(0.75),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    } else {
      body = Text(
        value.toString(),
        style: tt.bodyMedium?.copyWith(
          color: c.text.withOpacity(0.75),
          height: 1.25,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.cardFill.withOpacity(0.72),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: c.border),
              boxShadow: [
                BoxShadow(
                  color: c.shadow,
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 10),
                body,
              ],
            ),
          ),
        ),
      ),
    );
  }
}