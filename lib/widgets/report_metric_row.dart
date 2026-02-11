// lib/widgets/report_metric_row.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class ReportMetricRow extends StatelessWidget {
  final String label;
  final String value;

  const ReportMetricRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(
                color: const Color(0xFF2E4B5A).withOpacity(0.75),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF7FF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFBBD9F7)),
                ),
                child: Text(
                  value,
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2E4B5A),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
