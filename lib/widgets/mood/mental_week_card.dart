import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../main.dart'; // dbRepo
import '../../models/week_insights.dart';
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
      List<dynamic> questions, // нам не нужно типизировать здесь строго
    })
  >
  _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant MentalWeekCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // если дни изменились — перегружаем
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
  >
  _load() async {
    final days =
        widget.days
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet()
            .toList()
          ..sort((a, b) => a.compareTo(b));

    final res = await dbRepo.buildWeekMentalStats(days);

    // Приводим к удобному виду для виджета
    return (
      yesNoStats: res.yesNoStats,
      scaleStats: res.scaleStats,
      questions: res.questions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final normDays =
        widget.days
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
          return const ReportSectionCard(
            title: 'Ментальное здоровье',
            child: SizedBox(
              height: 110,
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
          );
        }

        if (snap.hasError) {
          return ReportSectionCard(
            title: 'Ментальное здоровье',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ошибка загрузки: ${snap.error}',
                  style: tt.bodySmall?.copyWith(color: cs.error),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _future = _load()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Повторить'),
                  ),
                ),
              ],
            ),
          );
        }

        final data = snap.data!;
        final yesNoAll = data.yesNoStats.values.toList();
        final scaleAll = data.scaleStats.values.toList();

        // показываем только “полезные”
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
            title: 'Ментальное здоровье',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'За эту неделю нет найденных ответов (для текущего user_id).',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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

        return ReportSectionCard(
          title: 'Ментальное здоровье',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (yesNoShown.isNotEmpty) ...[
                Text(
                  'Да/Нет (неделя)',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                for (final s in yesNoShown) ...[
                  _YesNoBar(stat: s),
                  const SizedBox(height: 10),
                ],
              ],
              if (scaleShown.isNotEmpty) ...[
                if (yesNoShown.isNotEmpty) const SizedBox(height: 4),
                Text(
                  'Шкалы (тренд)',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                for (final s in scaleShown) ...[
                  _ScaleSparkline(
                    stat: _ensureSeriesLength(s, normDays.length),
                    days: normDays,
                    weekdayLabel: widget.weekdayLabel,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
              Text(
                'Показываем только несколько вопросов, чтобы не перегружать экран.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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
}

class _DebugBlock extends StatelessWidget {
  final List<String> lines;
  const _DebugBlock({required this.lines});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
      ),
      child: Text(
        lines.join('\n'),
        style: tt.bodySmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontFamily: 'monospace',
          height: 1.25,
        ),
      ),
    );
  }
}

class _YesNoBar extends StatelessWidget {
  final YesNoStat stat;
  const _YesNoBar({required this.stat});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final label = stat.question.text;
    final ratio = stat.ratio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.35),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: ratio.clamp(0, 1),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.secondary.withOpacity(0.80),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          stat.total == 0 ? 'Нет данных' : 'Да: ${stat.yes}/${stat.total}',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ScaleSparkline extends StatelessWidget {
  final ScaleStat stat;
  final List<DateTime> days;
  final WeekdayLabel weekdayLabel;

  const _ScaleSparkline({
    required this.stat,
    required this.days,
    required this.weekdayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final label = stat.question.text;
    final avg = stat.avg;

    final minV = stat.question.minValue ?? 1;
    final maxV = stat.question.maxValue ?? 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              avg == null ? '—' : avg.toStringAsFixed(1),
              style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.35),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: CustomPaint(
                painter: _SparklinePainter(
                  values: stat.series,
                  min: minV,
                  max: maxV,
                  color: cs.primary.withOpacity(0.9),
                  bgColor: cs.onSurfaceVariant.withOpacity(0.06),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(days.length, (i) {
            return Expanded(
              child: Text(
                weekdayLabel(days[i]),
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int?> values;
  final int min;
  final int max;
  final Color color;
  final Color bgColor;

  _SparklinePainter({
    required this.values,
    required this.min,
    required this.max,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintDot = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(14),
    );
    canvas.drawRRect(r, paintBg);

    final n = values.length;
    if (n < 2) return;

    double norm(int v) {
      if (max == min) return 0.5;
      return (v - min) / (max - min);
    }

    final segments = <List<Offset>>[];
    List<Offset> current = [];

    for (int i = 0; i < n; i++) {
      final v = values[i];
      if (v == null) {
        if (current.length >= 2) segments.add(current);
        current = [];
        continue;
      }
      final x = (i / (n - 1)) * size.width;
      final y = size.height - (norm(v).clamp(0, 1) * size.height);
      current.add(Offset(x, y));
    }
    if (current.length >= 2) segments.add(current);

    if (segments.isEmpty) return;

    for (final points in segments) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paintLine);
      for (final p in points) {
        canvas.drawCircle(p, 2.8, paintDot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.min != min ||
        oldDelegate.max != max ||
        oldDelegate.color != color ||
        oldDelegate.bgColor != bgColor;
  }
}
