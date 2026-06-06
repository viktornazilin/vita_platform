// lib/widgets/mood/mental_week_card.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../../main.dart'; // dbRepo
import '../../models/week_insights.dart';
import '../../utils/mental_question_l10n.dart';
import '../../widgets/report_section_card.dart';

class MentalWeekCard extends StatefulWidget {
  final List<DateTime> days;
  final WeekdayLabel weekdayLabel;

  /// сколько вопросов максимум показывать (чтобы не перегружать экран)
  final int maxItems;

  /// показать debug-инфо прямо на карточке
  final bool debug;

  const MentalWeekCard({
    super.key,
    required this.days,
    required this.weekdayLabel,
    this.maxItems = 3,
    this.debug = kDebugMode,
  });

  @override
  State<MentalWeekCard> createState() => _MentalWeekCardState();
}

class _MentalWeekCardState extends State<MentalWeekCard> {
  late Future<
    ({
      Map<String, YesNoStat> yesNoStats,
      Map<String, ScaleStat> scaleStats,
      List<dynamic> questions,
    })
  > _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant MentalWeekCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameDays(oldWidget.days, widget.days)) {
      _future = _load();
    }
  }

  bool _sameDays(List<DateTime> a, List<DateTime> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      final da = DateTime(a[i].year, a[i].month, a[i].day);
      final db = DateTime(b[i].year, b[i].month, b[i].day);
      if (da != db) return false;
    }
    return true;
  }

  Future<
    ({
      Map<String, YesNoStat> yesNoStats,
      Map<String, ScaleStat> scaleStats,
      List<dynamic> questions,
    })
  > _load() async {
    final days = widget.days
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    final res = await dbRepo.buildWeekMentalStats(days);

    return (
      yesNoStats: res.yesNoStats,
      scaleStats: res.scaleStats,
      questions: res.questions,
    );
  }

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = _isDark(context);

    final normDays = widget.days
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    return FutureBuilder<
      ({
        Map<String, YesNoStat> yesNoStats,
        Map<String, ScaleStat> scaleStats,
        List<dynamic> questions,
      })
    >(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return ReportSectionCard(
            title: l.mentalWeekTitle,
            child: const SizedBox(
              height: 110,
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
          );
        }

        if (snap.hasError) {
          return ReportSectionCard(
            title: l.mentalWeekTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.mentalWeekLoadError('${snap.error}'),
                  style: tt.bodySmall?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _future = _load()),
                    icon: const Icon(Icons.refresh),
                    label: Text(l.commonRetry),
                  ),
                ),
              ],
            ),
          );
        }

        final data = snap.data!;
        final yesNoAll = data.yesNoStats.values.toList();
        final scaleAll = data.scaleStats.values.toList();

        final yesNoShown =
            (yesNoAll.where((s) => s.total > 0).toList()
                  ..sort((a, b) => b.total.compareTo(a.total)))
                .take(widget.maxItems)
                .toList();

        final scaleShown =
            (scaleAll.where((s) => s.series.any((v) => v != null)).toList()
                  ..sort((a, b) => (b.avg ?? -1).compareTo(a.avg ?? -1)))
                .take(widget.maxItems)
                .toList();

        final hasAny = yesNoShown.isNotEmpty || scaleShown.isNotEmpty;

        if (!hasAny) {
          return ReportSectionCard(
            title: l.mentalWeekTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.mentalWeekNoAnswers,
                  style: tt.bodyMedium?.copyWith(
                    color: isDark ? const Color(0x99FFFFFF) : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.debug) ...[
                  const SizedBox(height: 10),
                  _DebugBlock(
                    lines: [
                      'days=${normDays.map(_d).join(", ")}',
                      'yesNoStats=${data.yesNoStats.length}',
                      'scaleStats=${data.scaleStats.length}',
                      'questions=${data.questions.length}',
                    ],
                  ),
                ],
              ],
            ),
          );
        }

        final answeredYesNo = yesNoShown.fold<int>(0, (sum, s) => sum + s.total);
        final yesCount = yesNoShown.fold<int>(0, (sum, s) => sum + s.yes);
        final avgScale = _avgScale(scaleShown);
        final latestScale = _latestScaleValue(scaleShown);

        return ReportSectionCard(
          title: l.mentalWeekTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MentalSummaryRow(
                yesCount: yesCount,
                yesTotal: answeredYesNo,
                avgScale: avgScale,
                latestScale: latestScale,
              ),
              if (yesNoShown.isNotEmpty) ...[
                const SizedBox(height: 14),
                _BlockTitle(
                  title: l.mentalWeekYesNoHeader,
                  icon: Icons.check_circle_rounded,
                ),
                const SizedBox(height: 8),
                for (final s in yesNoShown) ...[
                  _YesNoStatCard(stat: s),
                  const SizedBox(height: 8),
                ],
              ],
              if (scaleShown.isNotEmpty) ...[
                const SizedBox(height: 6),
                _BlockTitle(
                  title: l.mentalWeekScalesHeader,
                  icon: Icons.show_chart_rounded,
                ),
                const SizedBox(height: 8),
                for (final s in scaleShown) ...[
                  _ScaleStatCard(
                    stat: _ensureSeriesLength(s, normDays.length),
                    days: normDays,
                    weekdayLabel: widget.weekdayLabel,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
              const SizedBox(height: 2),
              Text(
                l.mentalWeekFooterHint,
                style: tt.bodySmall?.copyWith(
                  color: isDark ? const Color(0x99FFFFFF) : cs.onSurfaceVariant,
                  fontSize: 11.5,
                  height: 1.22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _d(DateTime d) =>
      '${d.year.toString().padLeft(4, "0")}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}';

  static ScaleStat _ensureSeriesLength(ScaleStat s, int len) {
    final series = List<int?>.from(s.series);
    if (series.length == len) return s;
    if (series.length > len) {
      return ScaleStat(
        question: s.question,
        series: series.sublist(0, len),
        avg: s.avg,
      );
    }
    while (series.length < len) {
      series.add(null);
    }
    return ScaleStat(question: s.question, series: series, avg: s.avg);
  }

  static double? _avgScale(List<ScaleStat> stats) {
    final values = stats.map((s) => s.avg).whereType<double>().toList();
    if (values.isEmpty) return null;
    return values.fold<double>(0, (sum, v) => sum + v) / values.length;
  }

  static double? _latestScaleValue(List<ScaleStat> stats) {
    final values = <int>[];
    for (final s in stats) {
      for (final v in s.series.reversed) {
        if (v != null) {
          values.add(v);
          break;
        }
      }
    }
    if (values.isEmpty) return null;
    return values.fold<double>(0, (sum, v) => sum + v) / values.length;
  }
}

class _MentalSummaryRow extends StatelessWidget {
  final int yesCount;
  final int yesTotal;
  final double? avgScale;
  final double? latestScale;

  const _MentalSummaryRow({
    required this.yesCount,
    required this.yesTotal,
    required this.avgScale,
    required this.latestScale,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final yesPercent = yesTotal == 0 ? null : yesCount / yesTotal;

    return Row(
      children: [
        Expanded(
          child: _MiniStatTile(
            icon: Icons.done_all_rounded,
            label: _t(
              context,
              ru: 'Да-ответы',
              en: 'Yes answers',
              de: 'Ja-Antworten',
              fr: 'Réponses oui',
              es: 'Respuestas sí',
              tr: 'Evet yanıtları',
            ),
            value: yesPercent == null ? '—' : '${(yesPercent * 100).round()}%',
            accent: cs.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatTile(
            icon: Icons.insights_rounded,
            label: _t(
              context,
              ru: 'Среднее',
              en: 'Average',
              de: 'Durchschnitt',
              fr: 'Moyenne',
              es: 'Promedio',
              tr: 'Ortalama',
            ),
            value: avgScale == null ? '—' : avgScale!.toStringAsFixed(1),
            accent: const Color(0xFF16B8A8),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatTile(
            icon: Icons.today_rounded,
            label: _t(
              context,
              ru: 'Последнее',
              en: 'Latest',
              de: 'Aktuell',
              fr: 'Dernier',
              es: 'Último',
              tr: 'Son',
            ),
            value: latestScale == null ? '—' : latestScale!.toStringAsFixed(1),
            accent: const Color(0xFFD4E040),
          ),
        ),
      ],
    );
  }
}

class _MiniStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _MiniStatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF221A38) : accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(isDark ? 0.22 : 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleMedium?.copyWith(
              fontSize: 18,
              height: 1,
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodySmall?.copyWith(
              fontSize: 10.5,
              height: 1.05,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _BlockTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 15, color: cs.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleSmall?.copyWith(
              fontSize: 14,
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _DebugBlock extends StatelessWidget {
  final List<String> lines;
  const _DebugBlock({required this.lines});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF221A38)
            : cs.surfaceContainerHighest.withOpacity(0.82),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(isDark ? 0.55 : 0.72),
        ),
      ),
      child: Text(
        lines.join('\n'),
        style: tt.bodySmall?.copyWith(
          color: isDark ? const Color(0x99FFFFFF) : cs.onSurfaceVariant,
          fontFamily: 'monospace',
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _YesNoStatCard extends StatelessWidget {
  final YesNoStat stat;
  const _YesNoStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final label = localizedMentalQuestionText(context, stat.question);
    final ratio = stat.ratio.clamp(0.0, 1.0).toDouble();
    final percent = (ratio * 100).round();

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1630) : cs.surfaceContainerHigh.withOpacity(0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(isDark ? 0.45 : 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(
                    fontSize: 13,
                    height: 1.18,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _ValuePill(text: '$percent%'),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.08)
                  : cs.primary.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            stat.total == 0
                ? l.mentalWeekNoData
                : l.mentalWeekYesCount(stat.yes, stat.total),
            style: tt.bodySmall?.copyWith(
              fontSize: 11,
              height: 1.15,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleStatCard extends StatelessWidget {
  final ScaleStat stat;
  final List<DateTime> days;
  final WeekdayLabel weekdayLabel;

  const _ScaleStatCard({
    required this.stat,
    required this.days,
    required this.weekdayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final label = localizedMentalQuestionText(context, stat.question);
    final avg = stat.avg;
    final minV = stat.question.minValue ?? 1;
    final maxV = stat.question.maxValue ?? 5;
    final latest = _latestValue(stat.series);
    final first = _firstValue(stat.series);
    final trend = (latest == null || first == null) ? 0 : latest - first;
    final trendText = trend == 0 ? '→' : trend > 0 ? '+$trend' : '$trend';

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1630) : cs.surfaceContainerHigh.withOpacity(0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(isDark ? 0.45 : 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(
                    fontSize: 13,
                    height: 1.18,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ValuePill(text: avg == null ? l.commonDash : avg.toStringAsFixed(1)),
              const SizedBox(width: 6),
              _TrendPill(text: trendText, positive: trend >= 0),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 74,
            child: CustomPaint(
              painter: _SoftChartPainter(
                values: stat.series,
                min: minV,
                max: maxV,
                color: cs.primary,
                gridColor: isDark
                    ? Colors.white.withOpacity(0.07)
                    : cs.primary.withOpacity(0.08),
                fillColor: cs.primary.withOpacity(isDark ? 0.16 : 0.12),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: List.generate(days.length, (i) {
              return Expanded(
                child: Text(
                  weekdayLabel(days[i]),
                  textAlign: TextAlign.center,
                  style: tt.bodySmall?.copyWith(
                    fontSize: 10.5,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  int? _latestValue(List<int?> values) {
    for (final v in values.reversed) {
      if (v != null) return v;
    }
    return null;
  }

  int? _firstValue(List<int?> values) {
    for (final v in values) {
      if (v != null) return v;
    }
    return null;
  }
}

class _ValuePill extends StatelessWidget {
  final String text;
  const _ValuePill({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withOpacity(0.20)),
      ),
      child: Text(
        text,
        style: tt.labelMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: cs.onSurface,
        ),
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  final String text;
  final bool positive;
  const _TrendPill({required this.text, required this.positive});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = positive ? const Color(0xFF16B8A8) : const Color(0xFFE35B5B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Text(
        text,
        style: tt.labelMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _SoftChartPainter extends CustomPainter {
  final List<int?> values;
  final int min;
  final int max;
  final Color color;
  final Color gridColor;
  final Color fillColor;

  _SoftChartPainter({
    required this.values,
    required this.min,
    required this.max,
    required this.color,
    required this.gridColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.fill;

    final bg = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    canvas.drawRRect(bg, bgPaint);

    final inner = Rect.fromLTWH(10, 8, size.width - 20, size.height - 16);
    if (values.isEmpty || inner.width <= 0 || inner.height <= 0) return;

    final gridPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..strokeWidth = 1;

    for (final factor in const [0.25, 0.5, 0.75]) {
      final y = inner.top + inner.height * factor;
      canvas.drawLine(Offset(inner.left, y), Offset(inner.right, y), gridPaint);
    }

    final points = <Offset>[];
    final n = values.length;

    double norm(int v) {
      if (max == min) return 0.5;
      return (v - min) / (max - min);
    }

    for (int i = 0; i < n; i++) {
      final v = values[i];
      if (v == null) continue;
      final x = n <= 1 ? inner.center.dx : inner.left + (i / (n - 1)) * inner.width;
      final y = inner.bottom - (norm(v).clamp(0.0, 1.0) * inner.height);
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      final dot = Paint()..color = color;
      canvas.drawCircle(points.first, 4, dot);
      return;
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final p = points[i];
      final midX = (prev.dx + p.dx) / 2;
      linePath.cubicTo(midX, prev.dy, midX, p.dy, p.dx, p.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, inner.bottom)
      ..lineTo(points.first.dx, inner.bottom)
      ..close();

    canvas.drawPath(fillPath, Paint()..color = fillColor);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = color;
    final dotStroke = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 4, dotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _SoftChartPainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        oldDelegate.min != min ||
        oldDelegate.max != max ||
        oldDelegate.color != color ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.fillColor != fillColor;
  }
}

String _t(
  BuildContext context, {
  required String ru,
  required String en,
  String? de,
  String? fr,
  String? es,
  String? tr,
}) {
  final code = Localizations.localeOf(context).languageCode.toLowerCase();
  switch (code) {
    case 'ru':
      return ru;
    case 'de':
      return de ?? en;
    case 'fr':
      return fr ?? en;
    case 'es':
      return es ?? en;
    case 'tr':
      return tr ?? en;
    default:
      return en;
  }
}
