// lib/widgets/report_metric_row.dart
import 'package:flutter/material.dart';

class ReportMetricRow extends StatelessWidget {
  final String label;
  final String value;
  const ReportMetricRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}
