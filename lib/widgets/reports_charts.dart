// lib/widgets/reports_charts.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

List<PieChartSectionData> buildPieSectionsInt(
  BuildContext context,
  Map<String, int> data,
) {
  final cs = Theme.of(context).colorScheme;
  final pal = palette(cs);
  final total = data.values.fold<int>(0, (s, v) => s + v);
  final entries = sortedEntriesInt(data);

  return List.generate(entries.length, (i) {
    final e = entries[i];
    final pct = total == 0 ? 0.0 : (e.value / total) * 100;

    return PieChartSectionData(
      value: e.value.toDouble(),
      title: '${pct.toStringAsFixed(0)}%',
      radius: 72,
      color: pal[i % pal.length],
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w900,
        color: Colors.white,
        fontSize: 12,
        shadows: [
          Shadow(
            blurRadius: 10,
            offset: Offset(0, 3),
            color: Color(0x66000000),
          ),
        ],
      ),

      // ✅ “glass” badge в стиле Nest
      badgeWidget: _NestChartBadge(text: e.key),
      badgePositionPercentageOffset: 1.18,
    );
  });
}

List<BarChartGroupData> buildBarGroups(
  BuildContext context,
  Map<DateTime, double> data,
) {
  final cs = Theme.of(context).colorScheme;
  final keys = data.keys.toList()..sort();

  return List.generate(keys.length, (i) {
    final v = data[keys[i]] ?? 0.0;

    return BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: v,
          width: 14,
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.primary.withOpacity(0.95),
              cs.primary.withOpacity(0.55),
            ],
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: _maxY(data).clamp(1.0, 999999.0),
            color: cs.surfaceContainerHighest.withOpacity(0.18),
          ),
        ),
      ],
    );
  });
}

List<PieChartSectionData> buildExpensePieSections(
  BuildContext context,
  Map<String, double> data,
) {
  final cs = Theme.of(context).colorScheme;
  final pal = palette(cs);
  final total = data.values.fold<double>(0.0, (s, v) => s + v);
  final entries = sortedEntriesDouble(data);

  return List.generate(entries.length, (i) {
    final e = entries[i];
    final pct = total == 0 ? 0.0 : (e.value / total) * 100.0;

    return PieChartSectionData(
      value: e.value,
      title: '${pct.toStringAsFixed(0)}%',
      radius: 72,
      color: pal[i % pal.length],
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w900,
        color: Colors.white,
        fontSize: 12,
        shadows: [
          Shadow(
            blurRadius: 10,
            offset: Offset(0, 3),
            color: Color(0x66000000),
          ),
        ],
      ),
      badgeWidget: _NestChartBadge(text: e.key),
      badgePositionPercentageOffset: 1.18,
    );
  });
}

List<BarChartGroupData> buildExpenseBarGroups(
  BuildContext context,
  Map<DateTime, double> data,
) {
  final cs = Theme.of(context).colorScheme;
  final keys = data.keys.toList()..sort();

  return List.generate(keys.length, (i) {
    final v = data[keys[i]] ?? 0.0;

    return BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: v,
          width: 14,
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.secondary.withOpacity(0.95),
              cs.secondary.withOpacity(0.55),
            ],
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: _maxY(data).clamp(1.0, 999999.0),
            color: cs.surfaceContainerHighest.withOpacity(0.18),
          ),
        ),
      ],
    );
  });
}

/// ----------------------------------------------------------------------------
/// Nest-style helpers
/// ----------------------------------------------------------------------------

class _NestChartBadge extends StatelessWidget {
  final String text;
  const _NestChartBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2B5B7A),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E4B5A),
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}

double _maxY(Map<DateTime, double> data) {
  if (data.isEmpty) return 1.0;
  var m = 0.0;
  for (final v in data.values) {
    if (v.isFinite && v > m) m = v;
  }
  // небольшой “воздух” сверху, чтобы бары не упирались
  return (m * 1.15).clamp(1.0, 999999.0);
}

// палитра/сортировки
List<Color> palette(ColorScheme cs) => [
  cs.primary,
  cs.secondary,
  cs.tertiary,
  cs.primaryContainer,
  cs.secondaryContainer,
  cs.tertiaryContainer,
];

List<MapEntry<String, int>> sortedEntriesInt(Map<String, int> map) =>
    (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

List<MapEntry<String, double>> sortedEntriesDouble(Map<String, double> map) =>
    (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
