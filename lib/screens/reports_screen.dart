// lib/screens/reports_screen.dart
// Полностью обновлён под новый flat corporate Nest design:
// - убраны старые semi-glass визуальные акценты
// - унифицированы surface / border / text colors через theme.colorScheme
// - упрощён tab/header UI
// - снижена агрессивность жирных шрифтов
// - улучшена читаемость в dark theme

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nest_app/l10n/app_localizations.dart';

import '../main.dart'; // dbRepo
import '../models/reports_model.dart';

// Nest style
import '../widgets/nest/nest_background.dart';

// existing widgets / utils
import '../widgets/expense_analytics.dart';
import '../widgets/report_empty_chart.dart';
import '../widgets/report_legend.dart';
import '../widgets/report_metric_row.dart';
import '../widgets/report_section_card.dart';
import '../widgets/report_stat_card.dart';
import '../widgets/reports_charts.dart';
import '../widgets/sticky_header.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsModel()..loadAll(),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReportsModel>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: NestBackground(
        child: RefreshIndicator.adaptive(
          onRefresh: () => context.read<ReportsModel>().loadAll(),
          child: model.loading
              ? CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: const [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                )
              : const _ReportsBody(),
        ),
      ),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  // ----------------------------------------------------------------------------
  // Helpers: date range iteration
  // ----------------------------------------------------------------------------
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static Iterable<DateTime> _daysInRange(
    DateTime start,
    DateTime endExclusive,
  ) sync* {
    var d = _dateOnly(start);
    final end = _dateOnly(endExclusive);
    while (d.isBefore(end)) {
      yield d;
      d = d.add(const Duration(days: 1));
    }
  }

  // ----------------------------------------------------------------------------
  // Mood scoring (for correlations)
  // ----------------------------------------------------------------------------
  static const Set<String> _moodPositive = {
    '😀',
    '😄',
    '😊',
    '🙂',
    '😌',
    '😁',
    '😍',
    '🤩',
    '😎',
    '🥳',
  };

  static const Set<String> _moodNeutral = {
    '😐',
    '😶',
    '😑',
    '🙂‍↔️',
    '🫤',
  };

  static const Set<String> _moodNegative = {
    '😞',
    '😔',
    '😟',
    '😣',
    '😖',
    '😫',
    '😭',
    '😢',
    '😠',
    '😡',
    '😤',
    '😩',
  };

  static int _moodBucket(String emoji) {
    if (_moodPositive.contains(emoji)) return 1;
    if (_moodNegative.contains(emoji)) return -1;
    if (_moodNeutral.contains(emoji)) return 0;
    return 0;
  }

  // ----------------------------------------------------------------------------
  // Data models for "Связи"
  // ----------------------------------------------------------------------------
  static const double _habitHighThreshold = 0.70;

  static String _dateOnlyStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<Map<DateTime, String>> _loadMoodsByDay(
    DateTime start,
    DateTime endExclusive,
  ) async {
    final client = Supabase.instance.client;

    final res = await client
        .from('moods')
        .select('day, emoji')
        .eq('user_id', dbRepo.uid)
        .gte('day', _dateOnlyStr(start))
        .lt('day', _dateOnlyStr(endExclusive));

    final out = <DateTime, String>{};
    for (final r in (res as List)) {
      final m = Map<String, dynamic>.from(r as Map);
      final dayStr = (m['day'] ?? '').toString();
      final emoji = (m['emoji'] ?? '').toString();
      if (dayStr.isEmpty || emoji.isEmpty) continue;
      final d = DateTime.tryParse(dayStr);
      if (d == null) continue;
      out[_dateOnly(d)] = emoji;
    }
    return out;
  }

  Future<Map<DateTime, double>> _loadHabitCompletionByDay(
    DateTime start,
    DateTime endExclusive,
  ) async {
    final habits = await dbRepo.listHabits();
    final total = habits.length;
    if (total <= 0) return {};

    final out = <DateTime, double>{};

    for (final day in _daysInRange(start, endExclusive)) {
      final entries = await dbRepo.getHabitEntriesForDay(day);

      int done = 0;
      for (final h in habits) {
        final row = entries[h.id];
        final isDone = (row?['done'] as bool?) ?? false;
        if (isDone) done++;
      }
      out[day] = done / total;
    }

    return out;
  }

  Future<Map<DateTime, double>> _loadMentalScoreByDay(
    DateTime start,
    DateTime endExclusive,
  ) async {
    final qs = await dbRepo.listMentalQuestions(onlyActive: true);
    if (qs.isEmpty) return {};

    final out = <DateTime, double>{};

    for (final day in _daysInRange(start, endExclusive)) {
      final a = await dbRepo.getMentalAnswersForDay(day);

      double sum = 0;
      int n = 0;

      for (final q in qs) {
        final row = a[q.id];
        if (row == null) continue;

        final vb = row['value_bool'];
        final vi = row['value_int'];

        if (vb is bool) {
          sum += vb ? 1.0 : 0.0;
          n++;
          continue;
        }
        if (vi is int) {
          final minV = (q.minValue ?? 0).toDouble();
          final maxV = (q.maxValue ?? 10).toDouble();
          if (maxV <= minV) continue;
          final norm = ((vi.toDouble() - minV) / (maxV - minV)).clamp(0.0, 1.0);
          sum += norm;
          n++;
          continue;
        }
      }

      out[day] = (n == 0) ? 0.0 : (sum / n);
    }

    return out;
  }

  // ----------------------------------------------------------------------------
  // Correlation computations
  // ----------------------------------------------------------------------------
  static double _avg(Iterable<double> xs) {
    final list = xs.where((e) => e.isFinite).toList();
    if (list.isEmpty) return 0.0;
    return list.reduce((a, b) => a + b) / list.length;
  }

  static double _safeGet(Map<DateTime, double> m, DateTime d) =>
      m[_dateOnly(d)] ?? 0.0;

  static bool _isHighHabits(double completion) =>
      completion >= _habitHighThreshold;

  static String _fmtHours(double v) => '${v.toStringAsFixed(1)} ч';
  static String _fmtEuro(double v) => '${v.toStringAsFixed(0)} €';
  static String _fmtAvgTime(double v) => '${v.toStringAsFixed(1)} ч';

  FlTitlesData _axisTitles(ColorScheme cs) {
    return FlTitlesData(
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 34,
          getTitlesWidget: (v, _) => Text(
            v.toInt().toString(),
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  FlGridData _grid(ColorScheme cs) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (v) => FlLine(
        strokeWidth: 0.6,
        color: cs.outlineVariant,
      ),
    );
  }

  Widget _centered(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final model = context.watch<ReportsModel>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final goals = model.goalsInRange.toList();
    final doneByBlock = model.doneByBlock;
    final byDayHours = model.hoursByDay;

    final totalHours = model.totalHours;
    final efficiency = model.efficiency;
    final planned = model.plannedHours;
    final completedGoals = goals.where((g) => g.isCompleted).length;

    final rangeStart = _dateOnly(model.range.start);
    final rangeEnd = _dateOnly(model.range.end);

    return DefaultTabController(
      length: 4,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyHeader(
              minExtent: 82,
              maxExtent: 90,
              child: Container(
                color: cs.surface,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: _centered(
                  _HeaderShell(
                    child: _PeriodBar(
                      rangeLabel: model.rangeLabel,
                      period: model.period,
                      onPeriod: (p) => context.read<ReportsModel>().setPeriod(p),
                      onPrev: context.read<ReportsModel>().prev,
                      onNext: context.read<ReportsModel>().next,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabHeaderDelegate(
              child: Container(
                color: cs.surface,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: _centered(
                  _HeaderShell(
                    padding: const EdgeInsets.all(6),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: cs.onSurface,
                      unselectedLabelColor: cs.onSurfaceVariant,
                      labelStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      indicator: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      tabs: const [
                        Tab(text: 'Сводка'),
                        Tab(text: 'Связи'),
                        Tab(text: 'Продуктивность'),
                        Tab(text: 'Расходы'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          children: [
            // TAB 1: СВОДКА
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _centered(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: _KpiStrip(
                        children: [
                          ReportStatCard(
                            title: 'Выполнено задач',
                            value: completedGoals.toString(),
                            icon: Icons.check_circle_outline_rounded,
                          ),
                          ReportStatCard(
                            title: 'Затрачено часов',
                            value: totalHours.toStringAsFixed(1),
                            icon: Icons.timer_outlined,
                          ),
                          ReportStatCard(
                            title: 'Эффективность',
                            value: '${(efficiency * 100).round()}%',
                            icon: Icons.trending_up_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _centered(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                      child: ReportSectionCard(
                        title: 'Эффективность периода',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: efficiency,
                                minHeight: 10,
                                backgroundColor: cs.surfaceContainerHighest,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'План: ${planned.toStringAsFixed(1)} ч • Факт: ${totalHours.toStringAsFixed(1)} ч',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _centered(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                      child: ReportSectionCard(
                        title: 'Дополнительные метрики',
                        child: _extraMetrics(
                          context: context,
                          avgTimePerGoal: model.avgTimePerGoal,
                          percentOnTime: model.percentDoneOnTime,
                          top3: model.top3DaysByHours,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _centered(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                      child: _LatestAiInsightsCard(
                        limit: 5,
                        onOpenAll: null,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
            ),

            // TAB 2: СВЯЗИ
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _centered(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: ReportSectionCard(
                        title: 'Связи между показателями',
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HintPill(
                              text:
                                  'Это не “научная корреляция”, а понятные сравнения по периодам.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 1) Mood -> Productivity
                SliverToBoxAdapter(
                  child: _centered(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                      child: FutureBuilder<Map<DateTime, String>>(
                        future: _loadMoodsByDay(rangeStart, rangeEnd),
                        builder: (context, moodsSnap) {
                          if (moodsSnap.connectionState ==
                              ConnectionState.waiting) {
                            return const ReportSectionCard(
                              title: 'Настроение → Продуктивность',
                              child: SizedBox(
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }

                          final moodsByDay = moodsSnap.data ?? {};
                          if (moodsByDay.isEmpty || byDayHours.isEmpty) {
                            return const ReportSectionCard(
                              title: 'Настроение → Продуктивность',
                              child: ReportEmptyChart(),
                            );
                          }

                          final good = <double>[];
                          final neutral = <double>[];
                          final bad = <double>[];

                          for (final d in moodsByDay.keys) {
                            final h = byDayHours[d] ?? 0.0;
                            final b = _moodBucket(moodsByDay[d] ?? '');
                            if (b == 1) good.add(h);
                            if (b == 0) neutral.add(h);
                            if (b == -1) bad.add(h);
                          }

                          final goodAvg = _avg(good);
                          final neutralAvg = _avg(neutral);
                          final badAvg = _avg(bad);

                          return ReportSectionCard(
                            title: 'Настроение → Продуктивность',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CompareRow(
                                  leftLabel: 'Хорошее',
                                  leftValue: _fmtHours(goodAvg),
                                  rightLabel: 'Плохое',
                                  rightValue: _fmtHours(badAvg),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 190,
                                  child: BarChart(
                                    BarChartData(
                                      gridData: _grid(cs),
                                      titlesData: _axisTitles(cs).copyWith(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 26,
                                            getTitlesWidget: (v, _) {
                                              final idx = v.toInt();
                                              if (idx < 0 || idx > 2) {
                                                return const SizedBox.shrink();
                                              }
                                              final label = switch (idx) {
                                                0 => '😊',
                                                1 => '😐',
                                                _ => '😞',
                                              };
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 6,
                                                ),
                                                child: Text(
                                                  label,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          barRods: [
                                            BarChartRodData(
                                              toY: goodAvg,
                                              width: 24,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: cs.primary,
                                            ),
                                          ],
                                        ),
                                        BarChartGroupData(
                                          x: 1,
                                          barRods: [
                                            BarChartRodData(
                                              toY: neutralAvg,
                                              width: 24,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: cs.secondary,
                                            ),
                                          ],
                                        ),
                                        BarChartGroupData(
                                          x: 2,
                                          barRods: [
                                            BarChartRodData(
                                              toY: badAvg,
                                              width: 24,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: cs.surfaceContainerHighest,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // 2) Habits -> Mood / Productivity
                SliverToBoxAdapter(
                  child: _centered(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                      child: FutureBuilder<_HabitsMoodProductivityPack>(
                        future: () async {
                          final habitsByDay = await _loadHabitCompletionByDay(
                            rangeStart,
                            rangeEnd,
                          );
                          final moodsByDay = await _loadMoodsByDay(
                            rangeStart,
                            rangeEnd,
                          );

                          final moodScore = <DateTime, int>{};
                          for (final e in moodsByDay.entries) {
                            moodScore[e.key] = _moodBucket(e.value);
                          }

                          final highMood = <double>[];
                          final lowMood = <double>[];
                          final highHours = <double>[];
                          final lowHours = <double>[];

                          for (final day in _daysInRange(rangeStart, rangeEnd)) {
                            final completion = _safeGet(habitsByDay, day);
                            final isHigh = _isHighHabits(completion);

                            final ms = moodScore[day];
                            if (ms != null) {
                              (isHigh ? highMood : lowMood).add(ms.toDouble());
                            }

                            final hours = byDayHours[day];
                            if (hours != null) {
                              (isHigh ? highHours : lowHours).add(hours);
                            }
                          }

                          return _HabitsMoodProductivityPack(
                            avgMoodHigh: _avg(highMood),
                            avgMoodLow: _avg(lowMood),
                            avgHoursHigh: _avg(highHours),
                            avgHoursLow: _avg(lowHours),
                          );
                        }(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const ReportSectionCard(
                              title: 'Привычки → Настроение / Продуктивность',
                              child: SizedBox(
                                height: 140,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }

                          final p = snap.data;
                          if (p == null) {
                            return const ReportSectionCard(
                              title: 'Привычки → Настроение / Продуктивность',
                              child: ReportEmptyChart(),
                            );
                          }

                          String moodText(double v) {
                            if (v >= 0.4) return 'скорее 😊';
                            if (v <= -0.4) return 'скорее 😞';
                            return 'скорее 😐';
                          }

                          return ReportSectionCard(
                            title: 'Привычки → Настроение / Продуктивность',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _HintPill(
                                  text:
                                      'Сравнение дней, где выполнено ≥ ${(_habitHighThreshold * 100).round()}% привычек, и остальных дней.',
                                ),
                                const SizedBox(height: 12),
                                _CompareRow(
                                  leftLabel: 'Настроение (high)',
                                  leftValue: moodText(p.avgMoodHigh),
                                  rightLabel: 'Настроение (low)',
                                  rightValue: moodText(p.avgMoodLow),
                                ),
                                const SizedBox(height: 10),
                                _CompareRow(
                                  leftLabel: 'Часы (high)',
                                  leftValue: _fmtHours(p.avgHoursHigh),
                                  rightLabel: 'Часы (low)',
                                  rightValue: _fmtHours(p.avgHoursLow),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 190,
                                  child: BarChart(
                                    BarChartData(
                                      gridData: _grid(cs),
                                      titlesData: _axisTitles(cs).copyWith(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 26,
                                            getTitlesWidget: (v, _) {
                                              final idx = v.toInt();
                                              if (idx < 0 || idx > 1) {
                                                return const SizedBox.shrink();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 6,
                                                ),
                                                child: Text(
                                                  idx == 0
                                                      ? 'habits high'
                                                      : 'habits low',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          barRods: [
                                            BarChartRodData(
                                              toY: p.avgHoursHigh,
                                              width: 24,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: cs.primary,
                                            ),
                                          ],
                                        ),
                                        BarChartGroupData(
                                          x: 1,
                                          barRods: [
                                            BarChartRodData(
                                              toY: p.avgHoursLow,
                                              width: 24,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: cs.surfaceContainerHighest,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // 4) Mental score -> Mood
                SliverToBoxAdapter(
                  child: _centered(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                      child: FutureBuilder<_MentalTrendPack>(
                        future: () async {
                          final mental = await _loadMentalScoreByDay(
                            rangeStart,
                            rangeEnd,
                          );
                          final moods = await _loadMoodsByDay(
                            rangeStart,
                            rangeEnd,
                          );
                          return _MentalTrendPack(mental: mental, moods: moods);
                        }(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const ReportSectionCard(
                              title: 'Ментальное состояние → Настроение',
                              child: SizedBox(
                                height: 140,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }

                          final p = snap.data;
                          if (p == null || p.mental.isEmpty) {
                            return const ReportSectionCard(
                              title: 'Ментальное состояние → Настроение',
                              child: ReportEmptyChart(),
                            );
                          }

                          final keys = p.mental.keys.toList()..sort();
                          final spots = <FlSpot>[];
                          for (var i = 0; i < keys.length; i++) {
                            spots.add(
                              FlSpot(
                                i.toDouble(),
                                (p.mental[keys[i]] ?? 0.0) * 100.0,
                              ),
                            );
                          }

                          return ReportSectionCard(
                            title: 'Ментальное состояние → Настроение',
                            child: SizedBox(
                              height: 230,
                              child: LineChart(
                                LineChartData(
                                  minY: 0,
                                  maxY: 100,
                                  gridData: _grid(cs),
                                  titlesData: _axisTitles(cs).copyWith(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        interval: 1,
                                        getTitlesWidget: (v, _) {
                                          final idx = v.toInt();
                                          if (idx < 0 || idx >= keys.length) {
                                            return const SizedBox.shrink();
                                          }
                                          if (keys.length > 14 && idx.isOdd) {
                                            return const SizedBox.shrink();
                                          }
                                          final d = keys[idx];
                                          final emoji = p.moods[d] ?? '';
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6,
                                            ),
                                            child: Text(
                                              emoji.isEmpty
                                                  ? '${d.day}.${d.month}'
                                                  : emoji,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: cs.onSurfaceVariant,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      barWidth: 3,
                                      color: cs.primary,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter:
                                            (spot, percent, barData, index) =>
                                                FlDotCirclePainter(
                                          radius: 3.2,
                                          color: cs.onSurface,
                                          strokeWidth: 2,
                                          strokeColor: cs.primary,
                                        ),
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: cs.primary.withOpacity(0.12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // 5) Expenses -> Mood
                SliverToBoxAdapter(
                  child: _centered(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                      child: FutureBuilder<_ExpenseMoodPack>(
                        future: () async {
                          final moods = await _loadMoodsByDay(
                            rangeStart,
                            rangeEnd,
                          );
                          final ex = await loadExpenseAnalytics(
                            rangeStart,
                            rangeEnd,
                          );
                          return _ExpenseMoodPack(
                            moods: moods,
                            expensesByDay: ex.byDay,
                          );
                        }(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const ReportSectionCard(
                              title: 'Расходы → Настроение',
                              child: SizedBox(
                                height: 140,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }

                          final p = snap.data;
                          if (p == null ||
                              p.expensesByDay.isEmpty ||
                              p.moods.isEmpty) {
                            return const ReportSectionCard(
                              title: 'Расходы → Настроение',
                              child: ReportEmptyChart(),
                            );
                          }

                          final good = <double>[];
                          final bad = <double>[];

                          for (final d in p.expensesByDay.keys) {
                            final emoji = p.moods[_dateOnly(d)];
                            if (emoji == null) continue;
                            final bucket = _moodBucket(emoji);
                            final val = p.expensesByDay[d] ?? 0.0;
                            if (bucket == 1) good.add(val);
                            if (bucket == -1) bad.add(val);
                          }

                          final goodAvg = _avg(good);
                          final badAvg = _avg(bad);

                          return ReportSectionCard(
                            title: 'Расходы → Настроение',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CompareRow(
                                  leftLabel: '😊 дни',
                                  leftValue: _fmtEuro(goodAvg),
                                  rightLabel: '😞 дни',
                                  rightValue: _fmtEuro(badAvg),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 190,
                                  child: BarChart(
                                    BarChartData(
                                      gridData: _grid(cs),
                                      titlesData: _axisTitles(cs).copyWith(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 26,
                                            getTitlesWidget: (v, _) {
                                              final idx = v.toInt();
                                              if (idx < 0 || idx > 1) {
                                                return const SizedBox.shrink();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 6,
                                                ),
                                                child: Text(
                                                  idx == 0 ? '😊' : '😞',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          barRods: [
                                            BarChartRodData(
                                              toY: goodAvg,
                                              width: 24,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: cs.primary,
                                            ),
                                          ],
                                        ),
                                        BarChartGroupData(
                                          x: 1,
                                          barRods: [
                                            BarChartRodData(
                                              toY: badAvg,
                                              width: 24,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: cs.surfaceContainerHighest,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
            ),

            // TAB 3: ПРОДУКТИВНОСТЬ
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _centered(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: ReportSectionCard(
                        title: 'Выполнено по блокам',
                        child: doneByBlock.isEmpty
                            ? const ReportEmptyChart()
                            : Column(
                                children: [
                                  SizedBox(
                                    height: 220,
                                    child: PieChart(
                                      PieChartData(
                                        startDegreeOffset: -90,
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 46,
                                        pieTouchData:
                                            PieTouchData(enabled: true),
                                        sections: buildPieSectionsInt(
                                          context,
                                          doneByBlock,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _LegendCollapse(
                                    title: 'Показать легенду',
                                    child: ReportLegend(
                                      entries: sortedEntriesInt(doneByBlock),
                                      colors: palette(cs),
                                      valueFormatter: (n) => n.toString(),
                                      total: doneByBlock.values.fold<int>(
                                        0,
                                        (a, b) => a + b,
                                      ).toDouble(),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _centered(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                      child: ReportSectionCard(
                        title: 'Затрачено часов по дням',
                        child: byDayHours.isEmpty
                            ? const ReportEmptyChart()
                            : SizedBox(
                                height: 260,
                                child: BarChart(
                                  BarChartData(
                                    gridData: _grid(cs),
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipColor: (_) =>
                                            cs.surfaceContainerHighest,
                                        getTooltipItem:
                                            (group, groupIndex, rod, rodIndex) {
                                          final keys =
                                              byDayHours.keys.toList()..sort();
                                          final d = keys[group.x.toInt()];
                                          return BarTooltipItem(
                                            '${d.day}.${d.month}.${d.year}\n',
                                            TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: cs.onSurface,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${rod.toY.toStringAsFixed(1)} ч',
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    titlesData: _axisTitles(cs).copyWith(
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 26,
                                          interval: 1,
                                          getTitlesWidget: (v, _) {
                                            final keys =
                                                byDayHours.keys.toList()..sort();
                                            final idx = v.toInt();
                                            if (idx < 0 || idx >= keys.length) {
                                              return const SizedBox.shrink();
                                            }
                                            final d = keys[idx];
                                            if (keys.length > 14 && idx.isOdd) {
                                              return const SizedBox.shrink();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                              ),
                                              child: Text(
                                                '${d.day}.${d.month}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: cs.onSurfaceVariant,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: buildBarGroups(
                                      context,
                                      byDayHours,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // TAB 4: РАСХОДЫ
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _centered(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: ReportSectionCard(
                        title: 'Расходы за период',
                        child: FutureBuilder<ExpenseAnalytics>(
                          future: loadExpenseAnalytics(
                            model.range.start,
                            model.range.end,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 140,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const ReportEmptyChart();
                            }

                            final data = snapshot.data!;
                            if (data.total <= 0 && data.byDay.isEmpty) {
                              return const ReportEmptyChart();
                            }

                            final days = (model.range.end
                                    .difference(model.range.start)
                                    .inDays)
                                .clamp(1, 366);
                            final avgExpense = days == 0
                                ? 0.0
                                : data.total / days;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Всего: ${data.total.toStringAsFixed(2)} €',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Средний расход/день: ${avgExpense.toStringAsFixed(2)} €',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 220,
                                  child: PieChart(
                                    PieChartData(
                                      startDegreeOffset: -90,
                                      sections: buildExpensePieSections(
                                        context,
                                        data.byCategory,
                                      ),
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 46,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _LegendCollapse(
                                  title: 'Показать категории',
                                  child: ReportLegend(
                                    entries: sortedEntriesDouble(
                                      data.byCategory,
                                    ),
                                    colors: palette(cs),
                                    valueFormatter: (n) =>
                                        '${(n as double).toStringAsFixed(0)} €',
                                    total: data.byCategory.values.fold<double>(
                                      0.0,
                                      (a, b) => a + b,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 260,
                                  child: BarChart(
                                    BarChartData(
                                      gridData: _grid(cs),
                                      titlesData: _axisTitles(cs).copyWith(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 26,
                                            getTitlesWidget: (v, _) {
                                              final keys =
                                                  data.byDay.keys.toList()
                                                    ..sort();
                                              final idx = v.toInt();
                                              if (idx < 0 ||
                                                  idx >= keys.length) {
                                                return const SizedBox.shrink();
                                              }
                                              final d = keys[idx];
                                              if (keys.length > 14 &&
                                                  idx.isOdd) {
                                                return const SizedBox.shrink();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 6,
                                                ),
                                                child: Text(
                                                  '${d.day}.${d.month}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      barGroups: buildExpenseBarGroups(
                                        context,
                                        data.byDay,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _extraMetrics({
    required BuildContext context,
    required double avgTimePerGoal,
    required int percentOnTime,
    required List<MapEntry<DateTime, double>> top3,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportMetricRow(
          label: 'Среднее время на задачу',
          value: _fmtAvgTime(avgTimePerGoal),
        ),
        ReportMetricRow(
          label: '«В срок» (условно)',
          value: '$percentOnTime %',
        ),
        const SizedBox(height: 12),
        Text(
          'ТОП-3 продуктивных дня',
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        ...top3.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(
              '• ${e.key.day}.${e.key.month}.${e.key.year}: ${e.value.toStringAsFixed(1)} ч',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ======= Header Shell =======
class _HeaderShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _HeaderShell({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: child,
    );
  }
}

/// ======= Period Bar =======
class _PeriodBar extends StatelessWidget {
  const _PeriodBar({
    required this.rangeLabel,
    required this.period,
    required this.onPeriod,
    required this.onPrev,
    required this.onNext,
  });

  final String rangeLabel;
  final ReportPeriod period;
  final ValueChanged<ReportPeriod> onPeriod;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: SegmentedButton<ReportPeriod>(
            segments: const [
              ButtonSegment(value: ReportPeriod.day, label: Text('День')),
              ButtonSegment(value: ReportPeriod.week, label: Text('Неделя')),
              ButtonSegment(value: ReportPeriod.month, label: Text('Месяц')),
            ],
            selected: {period},
            showSelectedIcon: true,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return cs.surfaceContainerHigh;
                }
                return cs.surfaceContainerLow;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return cs.onSurface;
                }
                return cs.onSurfaceVariant;
              }),
              side: WidgetStateProperty.all(
                BorderSide(color: cs.outlineVariant),
              ),
              textStyle: WidgetStateProperty.all(
                tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
            onSelectionChanged: (s) => onPeriod(s.first),
          ),
        ),
        const SizedBox(width: 8),
        _CircleIconButton(
          tooltip: 'Назад',
          icon: Icons.chevron_left_rounded,
          onTap: onPrev,
        ),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 96),
          child: Text(
            rangeLabel,
            textAlign: TextAlign.center,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 6),
        _CircleIconButton(
          tooltip: 'Вперёд',
          icon: Icons.chevron_right_rounded,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Icon(
            icon,
            color: cs.onSurface,
            size: 22,
          ),
        ),
      ),
    );
  }
}

/// ======= KPI strip =======
class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(width: 210, child: children[i]),
      ),
    );
  }
}

/// ======= Collapsible legend =======
class _LegendCollapse extends StatefulWidget {
  const _LegendCollapse({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  State<_LegendCollapse> createState() => _LegendCollapseState();
}

class _LegendCollapseState extends State<_LegendCollapse> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => setState(() => _open = !_open),
          icon: Icon(
            _open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            color: cs.primary,
          ),
          label: Text(widget.title),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState: _open
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: widget.child,
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// ======= Tab header delegate =======
class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 62;

  @override
  double get maxExtent => 62;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabHeaderDelegate oldDelegate) => false;
}

// ----------------------------------------------------------------------------
// Small UI helpers
// ----------------------------------------------------------------------------

class _HintPill extends StatelessWidget {
  final String text;

  const _HintPill({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        text,
        style: tt.bodySmall?.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  const _CompareRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget cell(String label, String value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        cell(leftLabel, leftValue),
        const SizedBox(width: 10),
        cell(rightLabel, rightValue),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// Latest AI Insights Card
// ----------------------------------------------------------------------------

class _LatestAiInsightsCard extends StatefulWidget {
  final int limit;
  final VoidCallback? onOpenAll;

  const _LatestAiInsightsCard({
    required this.limit,
    this.onOpenAll,
  });

  @override
  State<_LatestAiInsightsCard> createState() => _LatestAiInsightsCardState();
}

class _LatestAiInsightsCardState extends State<_LatestAiInsightsCard> {
  bool _loading = true;
  String? _error;
  List<_AiInsightLite> _items = [];
  DateTime? _createdAt;
  String? _period;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
      _items = [];
      _createdAt = null;
      _period = null;
    });

    try {
      final client = Supabase.instance.client;

      final row = await client
          .from('ai_insights_runs')
          .select('created_at, period, insights')
          .eq('user_id', dbRepo.uid)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (!mounted) return;

      if (row == null) {
        setState(() {
          _loading = false;
          _items = [];
        });
        return;
      }

      final createdAtRaw = row['created_at']?.toString();
      final periodRaw = row['period']?.toString();

      final createdAt = createdAtRaw != null
          ? DateTime.parse(createdAtRaw).toLocal()
          : null;

      final rawInsights = row['insights'];
      final list = (rawInsights is List) ? rawInsights : const <dynamic>[];

      final parsed = list
          .whereType<Map>()
          .map((m) => _AiInsightLite.fromMap(m.cast<String, dynamic>()))
          .where(
            (x) => x.title.trim().isNotEmpty && x.insight.trim().isNotEmpty,
          )
          .take(widget.limit)
          .toList();

      setState(() {
        _createdAt = createdAt;
        _period = periodRaw;
        _items = parsed;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _periodLabel(String? v) => switch ((v ?? '').toLowerCase()) {
        'last_7_days' => 'за 7 дней',
        'last_30_days' => 'за 30 дней',
        'last_90_days' => 'за 90 дней',
        _ => '',
      };

  String _fmtDateTime(BuildContext context, DateTime? dt) {
    if (dt == null) return '';
    final loc = MaterialLocalizations.of(context);
    return '${loc.formatShortDate(dt)} • ${loc.formatTimeOfDay(TimeOfDay.fromDateTime(dt))}';
  }

  IconData _iconForType(String t) {
    switch (t) {
      case 'risk':
        return Icons.warning_amber_rounded;
      case 'emotional':
        return Icons.mood_rounded;
      case 'habit':
        return Icons.autorenew_rounded;
      case 'goal':
        return Icons.flag_rounded;
      default:
        return Icons.insights_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ReportSectionCard(
      title: 'Последние AI-инсайты',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _createdAt == null ? '' : _fmtDateTime(context, _createdAt),
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Обновить',
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh_rounded),
              ),
              if (widget.onOpenAll != null)
                IconButton(
                  tooltip: 'Открыть все',
                  onPressed: widget.onOpenAll,
                  icon: const Icon(Icons.open_in_new_rounded),
                ),
            ],
          ),
          if ((_period ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Text(
                  _periodLabel(_period),
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_loading)
            const SizedBox(
              height: 90,
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.errorContainer.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.error.withOpacity(0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Не удалось загрузить инсайты',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _error!,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onErrorContainer,
                    ),
                  ),
                ],
              ),
            )
          else if (_items.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Пока нет сохранённых инсайтов.',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Открой «AI-инсайты» и запусти анализ — после этого они появятся здесь.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            )
          else ...[
            ..._items.map((it) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Icon(
                          _iconForType(it.type),
                          size: 18,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.title,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              it.insight,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: tt.bodyMedium?.copyWith(
                                height: 1.3,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _AiInsightLite {
  final String type;
  final String title;
  final String insight;

  _AiInsightLite({
    required this.type,
    required this.title,
    required this.insight,
  });

  factory _AiInsightLite.fromMap(Map<String, dynamic> m) {
    return _AiInsightLite(
      type: (m['type'] ?? '').toString(),
      title: (m['title'] ?? '').toString(),
      insight: (m['insight'] ?? '').toString(),
    );
  }
}

// ----------------------------------------------------------------------------
// Packs
// ----------------------------------------------------------------------------

class _HabitsMoodProductivityPack {
  final double avgMoodHigh;
  final double avgMoodLow;
  final double avgHoursHigh;
  final double avgHoursLow;

  _HabitsMoodProductivityPack({
    required this.avgMoodHigh,
    required this.avgMoodLow,
    required this.avgHoursHigh,
    required this.avgHoursLow,
  });
}

class _MentalTrendPack {
  final Map<DateTime, double> mental;
  final Map<DateTime, String> moods;

  _MentalTrendPack({
    required this.mental,
    required this.moods,
  });
}

class _ExpenseMoodPack {
  final Map<DateTime, String> moods;
  final Map<DateTime, double> expensesByDay;

  _ExpenseMoodPack({
    required this.moods,
    required this.expensesByDay,
  });
}