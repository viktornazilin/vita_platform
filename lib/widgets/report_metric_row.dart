// lib/widgets/report_metric_row.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nest_app/controllers/theme_controller.dart';

class ReportMetricRow extends StatelessWidget {
  final String label;
  final String value;

  const ReportMetricRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? ThemeController.kLadnaCardDark : ThemeController.kLadnaTintLight;
    final border = isDark ? ThemeController.kLadnaBorderDark : ThemeController.kLadnaBorderLight;
    final dark = isDark ? ThemeController.kLadnaTextDark : ThemeController.kLadnaTextLight;
    final mid = isDark ? const Color(0x99FFFFFF) : ThemeController.kLadnaText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: mid,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: dark,
                fontSize: 12,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}