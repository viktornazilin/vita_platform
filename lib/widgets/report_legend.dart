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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: List.generate(entries.length, (i) {
        final e = entries[i];
        final color = colors[i % colors.length];
        final pct = total == 0 ? 0 : (e.value / total * 100);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(e.key, style: tt.labelMedium),
              const SizedBox(width: 6),
              Text(
                '• ${valueFormatter(e.value)}',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: 6),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        );
      }),
    );
  }
}
