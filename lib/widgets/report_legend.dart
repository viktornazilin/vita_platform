// lib/widgets/report_legend.dart
import 'package:flutter/material.dart';

class ReportLegend extends StatelessWidget {
  final List<MapEntry<String, num>> entries;
  final List<Color> colors;
  final String Function(num) valueFormatter;
  final double total;

  const ReportLegend({
    super.key,
    required this.entries,
    required this.colors,
    required this.valueFormatter,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(entries.length, (i) {
        final e = entries[i];
        final color = colors[i % colors.length];
        final pct = total == 0 ? 0.0 : (e.value / total) * 100.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0DCF0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text(
                e.key,
                style: const TextStyle(fontSize: 11, color: Color(0xFF555268), fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 7),
              Text(
                '${valueFormatter(e.value)} · ${pct.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 11, color: Color(0xFF9090A8)),
              ),
            ],
          ),
        );
      }),
    );
  }
}
