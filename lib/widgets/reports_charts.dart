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
      radius: 70,
      color: pal[i % pal.length],
      titleStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      badgeWidget: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(e.key, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ),
      badgePositionPercentageOffset: 1.25,
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
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cs.primary.withOpacity(0.95), cs.primary.withOpacity(0.6)],
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
      radius: 70,
      color: pal[i % pal.length],
      titleStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      badgeWidget: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(e.key, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ),
      badgePositionPercentageOffset: 1.25,
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
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cs.secondary.withOpacity(0.95), cs.secondary.withOpacity(0.6)],
          ),
        ),
      ],
    );
  });
}

// палитра/сортировки
List<Color> palette(ColorScheme cs) => [
  cs.primary, cs.secondary, cs.tertiary,
  cs.primaryContainer, cs.secondaryContainer, cs.tertiaryContainer,
];

List<MapEntry<String, int>> sortedEntriesInt(Map<String, int> map) =>
    (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

List<MapEntry<String, double>> sortedEntriesDouble(Map<String, double> map) =>
    (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
