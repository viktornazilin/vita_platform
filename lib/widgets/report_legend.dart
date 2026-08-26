// lib/widgets/report_legend.dart
import 'package:flutter/material.dart';
import 'package:nest_app/controllers/theme_controller.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? ThemeController.kLadnaCardDark : ThemeController.kLadnaCardLight;
    final border = isDark ? ThemeController.kLadnaBorderDark : ThemeController.kLadnaBorderLight;
    final text = isDark ? ThemeController.kLadnaTextDark : ThemeController.kLadnaText;
    final muted = isDark ? const Color(0x99FFFFFF) : ThemeController.kLadnaMuted;

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
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text(
                e.key,
                style: TextStyle(fontSize: 11, color: text, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 7),
              Text(
                '${valueFormatter(e.value)} · ${pct.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ],
          ),
        );
      }),
    );
  }
}