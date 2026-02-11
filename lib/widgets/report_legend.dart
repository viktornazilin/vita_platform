// lib/widgets/report_legend.dart
import 'dart:ui';

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
    final tt = Theme.of(context).textTheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(entries.length, (i) {
        final e = entries[i];
        final color = colors[i % colors.length];
        final pct = total == 0 ? 0.0 : (e.value / total) * 100.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.70),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD6E6F5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A2B5B7A),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // цветной кружок
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // название
                  Text(
                    e.key,
                    style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E4B5A),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // значение
                  Text(
                    valueFormatter(e.value),
                    style: tt.labelMedium?.copyWith(
                      color: const Color(0xFF2E4B5A).withOpacity(0.70),
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // %
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF7FF),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFBBD9F7)),
                    ),
                    child: Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: tt.labelSmall?.copyWith(
                        color: const Color(0xFF2E4B5A),
                        fontWeight: FontWeight.w900,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
