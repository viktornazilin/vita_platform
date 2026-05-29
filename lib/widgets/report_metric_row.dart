// lib/widgets/report_metric_row.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class ReportMetricRow extends StatelessWidget {
  final String label;
  final String value;

  const ReportMetricRow({
    super.key,
    required this.label,
    required this.value,
  });

  static const _card = Color(0xFFEAE6F5);
  static const _border = Color(0xFFE0DCF0);
  static const _dark = Color(0xFF160E38);
  static const _mid = Color(0xFF555268);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _mid,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _dark,
                fontSize: 12,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
