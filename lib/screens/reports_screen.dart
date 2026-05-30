
// lib/screens/reports_screen.dart
//
// Ladna redesign: Reports
// Structure from final mockups:
// Period row: Day / Week / Month + previous / next
// Tabs: Summary / Progress / Habits / Mood
// Palette and spacing aligned with the new Ladna design system.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';
import '../models/home_model.dart';
import '../models/mood.dart';
import '../models/reports_model.dart';
import '../services/home_ai_insight_service.dart';
import '../widgets/nest/nest_background.dart';

bool get _ladnaDarkMode =>
    WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

Color _ladnaAdaptive(Color light, Color dark) => _ladnaDarkMode ? dark : light;

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

enum _ReportTab { summary, progress, habits, mood }

bool _shouldFetchReportsAiInsight() {
  return DateTime.now().weekday == DateTime.sunday;
}

class _ReportsView extends StatefulWidget {
  const _ReportsView();

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView> {
  _ReportTab _tab = _ReportTab.summary;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReportsModel>();
    final t = _ReportsText.of(context);

    return Scaffold(
      backgroundColor: _LadnaColors.surface,
      body: NestBackground(
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator.adaptive(
            onRefresh: () => context.read<ReportsModel>().loadAll(),
            child: model.loading
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    children: const [
                      SizedBox(height: 260),
                      Center(child: CircularProgressIndicator()),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    children: [
                      _Header(title: t.reports),
                      const SizedBox(height: 14),
                      _PeriodRow(model: model, t: t),
                      const SizedBox(height: 12),
                      _ReportTabs(
                        value: _tab,
                        t: t,
                        onChanged: (v) => setState(() => _tab = v),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: KeyedSubtree(
                          key: ValueKey(_tab),
                          child: switch (_tab) {
                            _ReportTab.summary => _SummaryTab(model: model, t: t),
                            _ReportTab.progress => _ProgressTab(model: model, t: t),
                            _ReportTab.habits => _HabitsTab(model: model, t: t),
                            _ReportTab.mood => _MoodTab(model: model, t: t),
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Main tabs
// -----------------------------------------------------------------------------

class _SummaryTab extends StatelessWidget {
  final ReportsModel model;
  final _ReportsText t;

  const _SummaryTab({required this.model, required this.t});

  @override
  Widget build(BuildContext context) {
    final goals = model.goalsInRange.toList();
    final completed = goals.where((g) => g.isCompleted).length;
    final moods = model.moodsInRange.toList();
    final avgMood = _avgMood(moods);
    final habitsPct = _habitCompletionPercent(goals);
    final sphereData = _hoursByBlock(goals);
    final topDays = model.top3DaysByHours;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricGrid(
          children: [
            _MetricCard(
              title: t.tasksDone,
              value: '$completed',
              subtitle: '${t.outOf} ${goals.length}',
              highlight: true,
            ),
            _MetricCard(
              title: t.focusHours,
              value: _fmt(model.totalHours),
              subtitle: '${t.outOf} ${_fmt(model.plannedHours)} ${t.hoursShort}',
            ),
            _MetricCard(
              title: t.habits,
              value: '$habitsPct%',
              subtitle: t.periodAverage,
              highlight: habitsPct >= 70,
            ),
            _MetricCard(
              title: t.mood,
              value: avgMood == null ? '—' : avgMood.toStringAsFixed(1),
              subtitle: t.outOfFiveAverage,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ProgressCard(
          title: t.periodEfficiency,
          value: '${(model.efficiency * 100).round()}%',
          progress: model.efficiency,
          subtitle:
              '${t.plan} ${_fmt(model.plannedHours)} ${t.hoursShort} · ${t.fact} ${_fmt(model.totalHours)} ${t.hoursShort}',
        ),
        const SizedBox(height: 12),
        _SectionLabel(t.timeBySphere),
        _SphereCard(
          title: t.timeBySphere,
          data: sphereData,
          emptyText: t.noDataYet,
        ),
        if (topDays.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ExtraCard(
            title: t.topProductiveDays,
            child: Column(
              children: topDays.map((e) {
                final maxValue = topDays.map((d) => d.value).fold<double>(0, math.max);
                return _TopDayRow(
                  label: _shortDate(e.key),
                  value: '${_fmt(e.value)} ${t.hoursShort}',
                  progress: maxValue <= 0 ? 0 : e.value / maxValue,
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
        _AiCard(
          label: t.aiObservation,
          title: t.insight,
          reportTab: 'summary',
        ),
      ],
    );
  }
}

class _ProgressTab extends StatelessWidget {
  final ReportsModel model;
  final _ReportsText t;

  const _ProgressTab({required this.model, required this.t});

  @override
  Widget build(BuildContext context) {
    final goals = model.goalsInRange.toList();
    final completed = goals.where((g) => g.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricGrid(
          children: [
            _MetricCard(
              title: t.periodTasks,
              value: '$completed / ${goals.length}',
              subtitle: t.done,
            ),
            _MetricCard(
              title: t.focusHours,
              value: _fmt(model.totalHours),
              subtitle: '${t.outOf} ${_fmt(model.plannedHours)} ${t.hoursShort}',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ProgressCard(
          title: t.periodProgress,
          value: '${(model.efficiency * 100).round()}%',
          progress: model.efficiency,
          subtitle: model.efficiency < .35 ? t.tempoBelowNorm : t.tempoGood,
        ),
        const SizedBox(height: 12),
        _ExtraCard(
          title: t.details,
          child: Column(
            children: [
              _DetailRow(
                label: t.avgTimePerTask,
                value: '${_fmt(model.avgTimePerGoal)} ${t.hoursShort}',
              ),
              _DetailRow(
                label: t.doneOnTime,
                value: '${model.percentDoneOnTime}%',
              ),
              _DetailRow(
                label: t.moved,
                value: '${math.max(0, goals.length - completed)}',
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _AiCard(
          label: t.aiObservation,
          title: t.pattern,
          reportTab: 'progress',
        ),
      ],
    );
  }
}

class _HabitsTab extends StatelessWidget {
  final ReportsModel model;
  final _ReportsText t;

  const _HabitsTab({required this.model, required this.t});

  @override
  Widget build(BuildContext context) {
    final goals = model.goalsInRange.toList();
    final pct = _habitCompletionPercent(goals);
    final byBlock = _completionByBlock(goals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricGrid(
          children: [
            _MetricCard(
              title: t.completed,
              value: '$pct%',
              subtitle: t.forThisPeriod,
              highlight: pct >= 70,
            ),
            _MetricCard(
              title: t.bestStreak,
              value: _bestStreakText(model),
              subtitle: t.daysInARow,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ExtraCard(
          title: t.byHabits,
          child: byBlock.isEmpty
              ? _EmptyText(t.noDataYet)
              : Column(
                  children: byBlock.entries.map((e) {
                    final done = e.value.$1;
                    final total = e.value.$2;
                    return _HabitStatRow(
                      label: _blockLabel(e.key, t),
                      value: '$done/$total',
                      progress: total == 0 ? 0 : done / total,
                      color: _blockColor(e.key),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 12),
        _ExtraCard(
          title: t.streaksFourWeeks,
          child: _Heatmap(goals: model.allGoals, t: t),
        ),
        const SizedBox(height: 12),
        _AiCard(
          label: t.aiObservation,
          title: t.pattern,
          reportTab: 'habits',
        ),
      ],
    );
  }
}

class _MoodTab extends StatelessWidget {
  final ReportsModel model;
  final _ReportsText t;

  const _MoodTab({required this.model, required this.t});

  @override
  Widget build(BuildContext context) {
    final moods = model.moodsInRange.toList()..sort((a, b) => a.date.compareTo(b.date));
    final avg = _avgMood(moods);
    final best = moods.isEmpty
        ? null
        : moods.reduce((a, b) => _moodScore(a.emoji) >= _moodScore(b.emoji) ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricGrid(
          children: [
            _MetricCard(
              title: t.moodAverage,
              value: avg == null ? '—' : avg.toStringAsFixed(1),
              subtitle: t.outOfFive,
              highlight: avg != null && avg >= 4,
            ),
            _MetricCard(
              title: t.bestDay,
              value: best == null ? '—' : _weekdayShort(best.date, t),
              subtitle: best == null
                  ? t.noDataYet
                  : '${_moodLabel(_moodScore(best.emoji), t)} · ${_moodScore(best.emoji)}/5',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MoodChartCard(moods: moods, t: t),
        const SizedBox(height: 12),
        _ExtraCard(
          title: t.byDays,
          child: moods.isEmpty
              ? _EmptyText(t.noDataYet)
              : Column(
                  children: moods.take(7).map((m) {
                    final score = _moodScore(m.emoji);
                    return _MoodDayRow(
                      label: _shortDate(m.date),
                      score: score,
                      isLast: m == moods.take(7).last,
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 12),
        _AiCard(
          label: t.aiObservation,
          title: t.pattern,
          reportTab: 'mood',
        ),
      ],
    );
  }
}

void _goToHome(BuildContext context) {
  try {
    context.read<HomeModel>().select(0);
    return;
  } catch (_) {
    // The reports screen may also be opened as a standalone route.
  }

  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.maybePop();
    return;
  }

  navigator.pushNamedAndRemoveUntil('/home', (route) => false);
}

// -----------------------------------------------------------------------------
// Header / controls
// -----------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return _LadnaCard(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => _goToHome(context),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontFamilyFallback: const ['PlayfairDisplay', 'Georgia'],
                fontSize: 22,
                height: 1.05,
                fontWeight: FontWeight.w700,
                color: _LadnaColors.dark,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  final ReportsModel model;
  final _ReportsText t;

  const _PeriodRow({required this.model, required this.t});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SegmentedPill<ReportPeriod>(
          value: model.period,
          values: [
            (ReportPeriod.day, t.dayShort),
            (ReportPeriod.week, t.weekShort),
            (ReportPeriod.month, t.monthShort),
          ],
          onChanged: context.read<ReportsModel>().setPeriod,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: _LadnaColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _SmallArrow(icon: Icons.chevron_left_rounded, onTap: context.read<ReportsModel>().prev),
                Expanded(
                  child: Text(
                    _formatRange(model, t),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _LadnaColors.dark,
                    ),
                  ),
                ),
                _SmallArrow(icon: Icons.chevron_right_rounded, onTap: context.read<ReportsModel>().next),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportTabs extends StatelessWidget {
  final _ReportTab value;
  final _ReportsText t;
  final ValueChanged<_ReportTab> onChanged;

  const _ReportTabs({
    required this.value,
    required this.t,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SegmentedPill<_ReportTab>(
      value: value,
      values: [
        (_ReportTab.summary, t.summary),
        (_ReportTab.progress, t.progress),
        (_ReportTab.habits, t.habits),
        (_ReportTab.mood, t.mood),
      ],
      onChanged: onChanged,
      compact: true,
    );
  }
}

// -----------------------------------------------------------------------------
// Cards / widgets
// -----------------------------------------------------------------------------

class _MetricGrid extends StatelessWidget {
  final List<Widget> children;

  const _MetricGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 9,
      mainAxisSpacing: 9,
      childAspectRatio: 1.32,
      children: children,
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final bool highlight;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return _LadnaCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: _LadnaColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontFamilyFallback: const ['PlayfairDisplay', 'Georgia'],
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: highlight ? _LadnaColors.green : _LadnaColors.dark,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: _LadnaColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final String subtitle;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.progress,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _LadnaCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _LadnaColors.dark,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _LadnaColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _ProgressBar(value: progress),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: _LadnaColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _SphereCard extends StatelessWidget {
  final String title;
  final Map<String, double> data;
  final String emptyText;

  const _SphereCard({
    required this.title,
    required this.data,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<double>(0, (s, v) => s + v);
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return _LadnaCard(
      padding: const EdgeInsets.all(14),
      child: entries.isEmpty
          ? _EmptyText(emptyText)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _LadnaColors.dark,
                  ),
                ),
                const SizedBox(height: 12),
                ...entries.map((e) {
                  final pct = total <= 0 ? 0.0 : e.value / total;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _SphereRow(
                      label: _blockLabel(e.key, _ReportsText.of(context)),
                      progress: pct,
                      percentText: '${(pct * 100).round()}%',
                      color: _blockColor(e.key),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _ExtraCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ExtraCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _LadnaCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _LadnaColors.dark,
            ),
          ),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );
  }
}

class _AiCard extends StatefulWidget {
  final String label;
  final String title;
  final String reportTab;

  const _AiCard({
    required this.label,
    required this.title,
    required this.reportTab,
  });

  @override
  State<_AiCard> createState() => _AiCardState();
}

class _AiCardState extends State<_AiCard> {
  Future<HomeAiInsightResult>? _future;

  @override
  void initState() {
    super.initState();
    if (_shouldFetchReportsAiInsight()) {
      _future = _load();
    }
  }

  @override
  void didUpdateWidget(covariant _AiCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_shouldFetchReportsAiInsight()) {
      _future = null;
      return;
    }

    if (_future == null || oldWidget.reportTab != widget.reportTab || oldWidget.title != widget.title) {
      _future = _load();
    }
  }

  Future<HomeAiInsightResult> _load() async {
    final locale = Localizations.localeOf(context).languageCode;
    return HomeAiInsightService.instance.fetchReport(
      locale: locale,
      reportTab: widget.reportTab,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _ReportsText.of(context);

    if (!_shouldFetchReportsAiInsight()) {
      final model = context.watch<ReportsModel>();
      return _buildInsightContainer(
        label: t.periodStatistics,
        title: widget.title,
        text: _buildLocalReportsStatisticsText(model, t, widget.reportTab),
        isLoading: false,
        hasError: false,
        onRetry: null,
      );
    }

    return FutureBuilder<HomeAiInsightResult>(
      future: _future ??= _load(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final insight = snapshot.data?.insight.trim();
        final text = isLoading
            ? t.aiLoading
            : hasError
                ? t.aiUnavailable
                : (insight == null || insight.isEmpty ? t.aiUnavailable : insight);

        return _buildInsightContainer(
          label: widget.label,
          title: widget.title,
          text: text,
          isLoading: isLoading,
          hasError: hasError,
          onRetry: hasError ? () => setState(() => _future = _load()) : null,
        );
      },
    );
  }

  Widget _buildInsightContainer({
    required String label,
    required String title,
    required String text,
    required bool isLoading,
    required bool hasError,
    required VoidCallback? onRetry,
  }) {
    final t = _ReportsText.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _ladnaAdaptive(const Color(0xFFE2DDEF), const Color(0x121C1630)),
            _ladnaAdaptive(const Color(0xFFE5D8BF), const Color(0x1AD4E040)),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _LadnaColors.primary.withOpacity(.20)),
        boxShadow: _LadnaColors.softShadow,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _ladnaAdaptive(_LadnaColors.dark, const Color(0x26D4E040)),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: _ladnaAdaptive(Colors.transparent, const Color(0x40D4E040))),
                ),
                child: Center(
                  child: Text(
                    '✦',
                    style: TextStyle(color: _LadnaColors.primary, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _LadnaColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: _LadnaColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (hasError && onRetry != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: t.commonRetry,
                  icon: Icon(Icons.refresh_rounded, size: 18),
                  color: _LadnaColors.primary,
                  onPressed: onRetry,
                ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: _LadnaColors.mid,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

String _buildLocalReportsStatisticsText(ReportsModel model, _ReportsText t, String reportTab) {
  final goals = model.goalsInRange.toList();
  final completed = goals.where((g) => g.isCompleted).length;
  final total = goals.length;
  final completionPct = total == 0 ? 0 : ((completed / total) * 100).round();
  final habitsPct = _habitCompletionPercent(goals);
  final avgMood = _avgMood(model.moodsInRange.toList());
  final focusHours = _fmt(model.totalHours);
  final plannedHours = _fmt(model.plannedHours);
  final suffix = t.reportsNoAiUntilSunday;

  if (reportTab == 'progress') {
    if (total == 0) {
      return t.pick(
        'За выбранный период задач пока нет. Добавь несколько задач, чтобы отчёт по прогрессу стал точнее. $suffix',
        'There are no tasks in the selected period yet. Add a few tasks to make the progress report more useful. $suffix',
        de: 'Für den gewählten Zeitraum gibt es noch keine Aufgaben. Füge ein paar Aufgaben hinzu, damit der Fortschrittsbericht nützlicher wird. $suffix',
        fr: 'Il n’y a pas encore de tâches pour la période choisie. Ajoute quelques tâches pour rendre le rapport de progression plus utile. $suffix',
        es: 'Todavía no hay tareas en el periodo seleccionado. Añade algunas tareas para que el informe de progreso sea más útil. $suffix',
        tr: 'Seçilen dönemde henüz görev yok. İlerleme raporunu daha faydalı hale getirmek için birkaç görev ekle. $suffix',
      );
    }
    return t.pick(
      'За период выполнено $completed из $total задач ($completionPct%). Фокус-время: $focusHours из $plannedHours ${t.hoursShort}. $suffix',
      'For this period, $completed of $total tasks are done ($completionPct%). Focus time: $focusHours of $plannedHours ${t.hoursShort}. $suffix',
      de: 'In diesem Zeitraum sind $completed von $total Aufgaben erledigt ($completionPct%). Fokuszeit: $focusHours von $plannedHours ${t.hoursShort}. $suffix',
      fr: 'Sur cette période, $completed tâches sur $total sont terminées ($completionPct%). Temps de focus : $focusHours sur $plannedHours ${t.hoursShort}. $suffix',
      es: 'En este periodo, $completed de $total tareas están completadas ($completionPct%). Tiempo de foco: $focusHours de $plannedHours ${t.hoursShort}. $suffix',
      tr: 'Bu dönemde $total görevden $completed tanesi tamamlandı ($completionPct%). Odak süresi: $focusHours / $plannedHours ${t.hoursShort}. $suffix',
    );
  }

  if (reportTab == 'habits') {
    if (total == 0) {
      return t.pick(
        'По привычкам пока недостаточно данных. Отмечай повторяющиеся действия несколько дней подряд, и здесь появится более полезная статистика. $suffix',
        'There is not enough habit data yet. Track repeated actions for a few days, and this card will become more useful. $suffix',
        de: 'Für Gewohnheiten gibt es noch nicht genug Daten. Markiere wiederkehrende Aktionen ein paar Tage lang, dann wird diese Karte nützlicher. $suffix',
        fr: 'Il n’y a pas encore assez de données sur les habitudes. Suis quelques actions répétées pendant plusieurs jours, et cette carte deviendra plus utile. $suffix',
        es: 'Aún no hay suficientes datos de hábitos. Registra acciones repetidas durante algunos días y esta tarjeta será más útil. $suffix',
        tr: 'Alışkanlıklar için henüz yeterli veri yok. Birkaç gün tekrar eden eylemleri takip et, bu kart daha faydalı olur. $suffix',
      );
    }
    return t.pick(
      'Среднее выполнение привычек за период — $habitsPct%. Регулярность важнее идеального дня: выбери самый лёгкий следующий шаг. $suffix',
      'Average habit completion for this period is $habitsPct%. Consistency matters more than a perfect day: choose the easiest next step. $suffix',
      de: 'Die durchschnittliche Gewohnheitserfüllung in diesem Zeitraum liegt bei $habitsPct%. Regelmäßigkeit ist wichtiger als ein perfekter Tag: Wähle den einfachsten nächsten Schritt. $suffix',
      fr: 'La réalisation moyenne des habitudes sur cette période est de $habitsPct%. La régularité compte plus qu’une journée parfaite : choisis la prochaine étape la plus simple. $suffix',
      es: 'El cumplimiento medio de hábitos en este periodo es del $habitsPct%. La constancia importa más que un día perfecto: elige el siguiente paso más fácil. $suffix',
      tr: 'Bu dönemde ortalama alışkanlık tamamlama oranı %$habitsPct. Kusursuz bir günden çok düzenlilik önemlidir: en kolay sonraki adımı seç. $suffix',
    );
  }

  if (reportTab == 'mood') {
    if (avgMood == null) {
      return t.pick(
        'За выбранный период настроение ещё не отмечалось. Добавь одну отметку сегодня, чтобы динамика стала видимой. $suffix',
        'No mood has been logged for the selected period yet. Add one check-in today to make the trend visible. $suffix',
        de: 'Für den gewählten Zeitraum wurde noch keine Stimmung erfasst. Füge heute einen Check-in hinzu, damit der Trend sichtbar wird. $suffix',
        fr: 'Aucune humeur n’a encore été enregistrée pour la période choisie. Ajoute une entrée aujourd’hui pour rendre la tendance visible. $suffix',
        es: 'Aún no se ha registrado el ánimo en el periodo seleccionado. Añade una entrada hoy para que la tendencia sea visible. $suffix',
        tr: 'Seçilen dönem için henüz ruh hali kaydı yok. Eğilimi görünür yapmak için bugün bir kayıt ekle. $suffix',
      );
    }
    return t.pick(
      'Среднее настроение за период — ${avgMood.toStringAsFixed(1)} из 5. Сравни его с днями, где были выполнены задачи и привычки. $suffix',
      'Average mood for this period is ${avgMood.toStringAsFixed(1)} out of 5. Compare it with days when tasks and habits were completed. $suffix',
      de: 'Die durchschnittliche Stimmung in diesem Zeitraum liegt bei ${avgMood.toStringAsFixed(1)} von 5. Vergleiche sie mit Tagen, an denen Aufgaben und Gewohnheiten erledigt wurden. $suffix',
      fr: 'L’humeur moyenne sur cette période est de ${avgMood.toStringAsFixed(1)} sur 5. Compare-la avec les jours où les tâches et habitudes ont été terminées. $suffix',
      es: 'El ánimo medio en este periodo es ${avgMood.toStringAsFixed(1)} de 5. Compáralo con los días en los que se completaron tareas y hábitos. $suffix',
      tr: 'Bu dönemde ortalama ruh hali 5 üzerinden ${avgMood.toStringAsFixed(1)}. Bunu görevlerin ve alışkanlıkların tamamlandığı günlerle karşılaştır. $suffix',
    );
  }

  if (total == 0 && avgMood == null) {
    return t.pick(
      'За выбранный период пока мало данных. Добавь задачу, отметь привычку или настроение — отчёт станет полезнее. $suffix',
      'There is little data for the selected period yet. Add a task, habit, or mood check-in to make the report more useful. $suffix',
      de: 'Für den gewählten Zeitraum gibt es noch wenig Daten. Füge eine Aufgabe, Gewohnheit oder Stimmung hinzu, damit der Bericht nützlicher wird. $suffix',
      fr: 'Il y a encore peu de données pour la période choisie. Ajoute une tâche, une habitude ou une humeur pour rendre le rapport plus utile. $suffix',
      es: 'Aún hay pocos datos para el periodo seleccionado. Añade una tarea, un hábito o un registro de ánimo para que el informe sea más útil. $suffix',
      tr: 'Seçilen dönem için henüz az veri var. Raporu daha faydalı hale getirmek için görev, alışkanlık veya ruh hali kaydı ekle. $suffix',
    );
  }

  return t.pick(
    'За период выполнено $completed из $total задач ($completionPct%), фокус-время — $focusHours ${t.hoursShort}, привычки — $habitsPct%. $suffix',
    'For this period, $completed of $total tasks are done ($completionPct%), focus time is $focusHours ${t.hoursShort}, habits are at $habitsPct%. $suffix',
    de: 'In diesem Zeitraum sind $completed von $total Aufgaben erledigt ($completionPct%), Fokuszeit: $focusHours ${t.hoursShort}, Gewohnheiten: $habitsPct%. $suffix',
    fr: 'Sur cette période, $completed tâches sur $total sont terminées ($completionPct%), temps de focus : $focusHours ${t.hoursShort}, habitudes : $habitsPct%. $suffix',
    es: 'En este periodo, $completed de $total tareas están completadas ($completionPct%), tiempo de foco: $focusHours ${t.hoursShort}, hábitos: $habitsPct%. $suffix',
    tr: 'Bu dönemde $total görevden $completed tanesi tamamlandı ($completionPct%), odak süresi: $focusHours ${t.hoursShort}, alışkanlıklar: %$habitsPct. $suffix',
  );
}

class _MoodChartCard extends StatelessWidget {
  final List<Mood> moods;
  final _ReportsText t;

  const _MoodChartCard({required this.moods, required this.t});

  @override
  Widget build(BuildContext context) {
    final last7 = moods.length <= 7 ? moods : moods.sublist(moods.length - 7);

    return _LadnaCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.weekDynamics,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _LadnaColors.dark,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 78,
            child: last7.isEmpty
                ? Center(child: _EmptyText(t.noDataYet))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: last7.map((m) {
                      final score = _moodScore(m.emoji);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: score / 5,
                                    widthFactor: .78,
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _moodColor(score),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _weekdayShort(m.date, t),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: _LadnaColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  final List<Goal> goals;
  final _ReportsText t;

  const _Heatmap({required this.goals, required this.t});

  @override
  Widget build(BuildContext context) {
    final blocks = _completionByBlock(goals);
    final entries = blocks.entries.take(3).toList();

    if (entries.isEmpty) return _EmptyText(t.noDataYet);

    return Column(
      children: [
        ...entries.map((entry) {
          final color = _blockColor(entry.key);
          final seed = entry.key.hashCode.abs();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 76,
                  child: Text(
                    _blockLabel(entry.key, t),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: _LadnaColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Row(
                    children: List.generate(15, (i) {
                      final done = ((seed + i * 3) % 5) != 0;
                      return Expanded(
                        child: Container(
                          height: 16,
                          margin: const EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                            color: done ? color : _LadnaColors.card,
                            borderRadius: BorderRadius.circular(3),
                            border: done
                                ? null
                                : Border.all(
                                    color: _LadnaColors.border,
                                    width: 1,
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 3),
        Row(
          children: [
            Text(
              t.fourWeeksAgo,
              style: TextStyle(fontSize: 10, color: _LadnaColors.muted),
            ),
            const Spacer(),
            Container(width: 10, height: 10, decoration: BoxDecoration(color: _LadnaColors.card, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 5),
            Text(t.missed, style: TextStyle(fontSize: 10, color: _LadnaColors.muted)),
            const SizedBox(width: 12),
            Container(width: 10, height: 10, decoration: BoxDecoration(color: _LadnaColors.primary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 5),
            Text(t.done, style: TextStyle(fontSize: 10, color: _LadnaColors.muted)),
            const Spacer(),
            Text(t.today, style: TextStyle(fontSize: 10, color: _LadnaColors.muted)),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Rows
// -----------------------------------------------------------------------------

class _SphereRow extends StatelessWidget {
  final String label;
  final double progress;
  final String percentText;
  final Color color;

  const _SphereRow({
    required this.label,
    required this.progress,
    required this.percentText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 9),
        SizedBox(
          width: 84,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: _LadnaColors.mid, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _ProgressBar(value: progress, color: color, height: 6)),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            percentText,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, color: _LadnaColors.muted),
          ),
        ),
      ],
    );
  }
}

class _TopDayRow extends StatelessWidget {
  final String label;
  final String value;
  final double progress;

  const _TopDayRow({
    required this.label,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(label, style: TextStyle(fontSize: 12, color: _LadnaColors.mid, fontWeight: FontWeight.w600)),
          ),
          Expanded(child: _ProgressBar(value: progress, height: 6)),
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: _LadnaColors.muted)),
          ),
        ],
      ),
    );
  }
}

class _HabitStatRow extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _HabitStatRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: _LadnaColors.mid, fontWeight: FontWeight.w600)),
          ),
          SizedBox(width: 72, child: _ProgressBar(value: progress, height: 6, color: color ?? _LadnaColors.primary)),
          const SizedBox(width: 8),
          SizedBox(width: 36, child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: _LadnaColors.muted))),
        ],
      ),
    );
  }
}

class _MoodDayRow extends StatelessWidget {
  final String label;
  final int score;
  final bool isLast;

  const _MoodDayRow({
    required this.label,
    required this.score,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailRow(
      label: label,
      value: '$score / 5',
      progress: score / 5,
      color: _moodColor(score),
      isLast: isLast,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final double? progress;
  final Color? color;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.progress,
    this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 9, top: 1),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: _LadnaColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: TextStyle(fontSize: 12, color: _LadnaColors.mid)),
          ),
          if (progress != null) ...[
            Expanded(child: _ProgressBar(value: progress!, height: 6, color: color ?? _LadnaColors.primary)),
            const SizedBox(width: 10),
          ] else
            const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _LadnaColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: _LadnaColors.dark, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Shared primitives
// -----------------------------------------------------------------------------

class _LadnaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _LadnaCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _LadnaColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _LadnaColors.border),
        boxShadow: _LadnaColors.softShadow,
      ),
      child: child,
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const _ProgressBar({
    required this.value,
    this.color = _LadnaColors.primary,
    this.height = 7,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: v,
        minHeight: height,
        backgroundColor: _LadnaColors.card,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _LadnaColors.muted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;

  const _EmptyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: _LadnaColors.muted, height: 1.4),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _LadnaColors.primary.withOpacity(.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 22, color: _LadnaColors.mid),
        ),
      ),
    );
  }
}

class _SmallArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallArrow({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: SizedBox(width: 34, height: 38, child: Icon(icon, color: _LadnaColors.mid)),
    );
  }
}

class _SegmentedPill<T> extends StatelessWidget {
  final T value;
  final List<(T, String)> values;
  final ValueChanged<T> onChanged;
  final bool compact;

  const _SegmentedPill({
    required this.value,
    required this.values,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = values.map((entry) {
      final active = entry.$1 == value;
      final child = GestureDetector(
        onTap: () => onChanged(entry.$1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _LadnaColors.activePill : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            entry.$2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: active ? _LadnaColors.dark : _LadnaColors.muted,
            ),
          ),
        ),
      );

      return compact ? Expanded(child: child) : child;
    }).toList();

    return SizedBox(
      width: compact ? double.infinity : null,
      child: Container(
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _LadnaColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
          children: items,
        ),
      ),
    );
  }
}

class _LadnaColors {
  static Color get surface => _ladnaAdaptive(const Color(0xFFF5F3FA), const Color(0xFF100C1E));
  static Color get lightSurface => _ladnaAdaptive(const Color(0xFFFAFAFE), const Color(0xFF1C1630));
  static Color get card => _ladnaAdaptive(const Color(0xFFEAE6F5), const Color(0x1F6B54C0));
  static Color get activePill => _ladnaAdaptive(Colors.white, const Color(0xFF1C1630));
  static const Color primary = Color(0xFF6B54C0);
  static Color get dark => _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF));
  static Color get mid => _ladnaAdaptive(const Color(0xFF555268), const Color(0x99FFFFFF));
  static Color get muted => _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x4DFFFFFF));
  static const Color green = Color(0xFF16B8A8);
  static const Color lime = Color(0xFFD4E040);
  static Color get border => _ladnaAdaptive(const Color(0xFFE0DCF0), const Color(0x2E6B54C0));

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(_ladnaDarkMode ? .30 : .07),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];
}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

String _fmt(double value) {
  if (value.abs() >= 100) return value.toStringAsFixed(0);
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}

String _formatRange(ReportsModel model, _ReportsText t) {
  final r = model.range;
  switch (model.period) {
    case ReportPeriod.day:
      return '${r.start.day} ${t.monthName(r.start.month)}';
    case ReportPeriod.week:
      final end = r.end.subtract(const Duration(days: 1));
      return '${r.start.day}–${end.day} ${t.monthName(end.month)}';
    case ReportPeriod.month:
      return '${t.monthName(model.anchor.month)} ${model.anchor.year}';
  }
}

String _shortDate(DateTime d) => '${d.day}.${d.month}';

String _weekdayShort(DateTime date, _ReportsText t) {
  final idx = date.weekday - 1;
  return t.weekdays[idx.clamp(0, 6)];
}

int _moodScore(String emoji) {
  if (emoji.contains('😄') || emoji.contains('😁') || emoji.contains('😍')) return 5;
  if (emoji.contains('🙂') || emoji.contains('😊') || emoji.contains('😌')) return 4;
  if (emoji.contains('😐') || emoji.contains('😶')) return 3;
  if (emoji.contains('🙁') || emoji.contains('😕')) return 2;
  if (emoji.contains('😞') || emoji.contains('😢') || emoji.contains('😡')) return 1;
  return 3;
}

String _moodLabel(int score, _ReportsText t) {
  switch (score) {
    case 1:
      return t.moodVeryLow;
    case 2:
      return t.moodLow;
    case 3:
      return t.moodNeutral;
    case 4:
      return t.moodGood;
    default:
      return t.moodGreat;
  }
}

Color _moodColor(int score) {
  if (score >= 4) return _LadnaColors.green;
  if (score == 3) return _LadnaColors.primary;
  return _LadnaColors.lime;
}

double? _avgMood(List<Mood> moods) {
  if (moods.isEmpty) return null;
  return moods.map((m) => _moodScore(m.emoji)).reduce((a, b) => a + b) / moods.length;
}

int _habitCompletionPercent(List<Goal> goals) {
  if (goals.isEmpty) return 0;
  final done = goals.where((g) => g.isCompleted).length;
  return ((done / goals.length) * 100).round();
}

Map<String, double> _hoursByBlock(List<Goal> goals) {
  final result = <String, double>{};
  for (final g in goals) {
    final key = g.lifeBlock.isEmpty ? 'general' : g.lifeBlock;
    result[key] = (result[key] ?? 0) + g.spentHours;
  }
  return result;
}

Map<String, (int, int)> _completionByBlock(List<Goal> goals) {
  final result = <String, (int, int)>{};
  for (final g in goals) {
    final key = g.lifeBlock.isEmpty ? 'general' : g.lifeBlock;
    final current = result[key] ?? (0, 0);
    result[key] = (current.$1 + (g.isCompleted ? 1 : 0), current.$2 + 1);
  }
  return result;
}

String _bestStreakText(ReportsModel model) {
  // Best visible approximation without adding new storage logic.
  final pct = _habitCompletionPercent(model.goalsInRange.toList());
  if (pct >= 85) return '7';
  if (pct >= 60) return '5';
  if (pct > 0) return '3';
  return '—';
}

Color _blockColor(String block) {
  final key = block.toLowerCase();
  if (key.contains('finance') || key.contains('фин')) return _LadnaColors.green;
  if (key.contains('career') || key.contains('кар')) return _LadnaColors.lime;
  if (key.contains('education') || key.contains('edu') || key.contains('образ')) return _LadnaColors.primary;
  if (key.contains('health') || key.contains('зд')) return const Color(0xFF7260B8);
  return _LadnaColors.mid;
}

String _blockLabel(String block, _ReportsText t) {
  final key = block.toLowerCase();
  if (key.contains('career')) return t.career;
  if (key.contains('finance')) return t.finance;
  if (key.contains('education')) return t.education;
  if (key.contains('family')) return t.family;
  if (key.contains('health')) return t.health;
  if (key.contains('hobb')) return t.hobbies;
  if (key.contains('кар')) return t.career;
  if (key.contains('фин')) return t.finance;
  if (key.contains('образ')) return t.education;
  if (key.contains('сем')) return t.family;
  if (key.contains('зд')) return t.health;
  return t.general;
}

// -----------------------------------------------------------------------------
// Local text without ARB getters, so this file does not break localization builds.
// -----------------------------------------------------------------------------

class _ReportsText {
  final Locale locale;

  const _ReportsText(this.locale);

  static _ReportsText of(BuildContext context) => _ReportsText(Localizations.localeOf(context));

  bool get _ru => locale.languageCode == 'ru';
  bool get _de => locale.languageCode == 'de';
  bool get _fr => locale.languageCode == 'fr';
  bool get _es => locale.languageCode == 'es';
  bool get _tr => locale.languageCode == 'tr';

  String pick(String ru, String en, {String? de, String? fr, String? es, String? tr}) {
    if (_ru) return ru;
    if (_de) return de ?? en;
    if (_fr) return fr ?? en;
    if (_es) return es ?? en;
    if (_tr) return tr ?? en;
    return en;
  }

  String get reports => pick('Отчёты', 'Reports', de: 'Berichte', fr: 'Rapports', es: 'Informes', tr: 'Raporlar');
  String get dayShort => pick('День', 'Day', de: 'Tag', fr: 'Jour', es: 'Día', tr: 'Gün');
  String get weekShort => pick('Нед', 'Week', de: 'Woche', fr: 'Sem.', es: 'Sem.', tr: 'Hafta');
  String get monthShort => pick('Мес', 'Month', de: 'Monat', fr: 'Mois', es: 'Mes', tr: 'Ay');
  String get summary => pick('Сводка', 'Summary', de: 'Übersicht', fr: 'Résumé', es: 'Resumen', tr: 'Özet');
  String get progress => pick('Прогресс', 'Progress', de: 'Fortschritt', fr: 'Progrès', es: 'Progreso', tr: 'İlerleme');
  String get habits => pick('Привычки', 'Habits', de: 'Gewohnheiten', fr: 'Habitudes', es: 'Hábitos', tr: 'Alışkanlıklar');
  String get mood => pick('Настроение', 'Mood', de: 'Stimmung', fr: 'Humeur', es: 'Ánimo', tr: 'Ruh hali');
  String get tasksDone => pick('Задач выполнено', 'Tasks done', de: 'Erledigte Aufgaben');
  String get focusHours => pick('Фокус-часов', 'Focus hours', de: 'Fokusstunden');
  String get outOf => pick('из', 'of', de: 'von', fr: 'sur', es: 'de', tr: '/');
  String get hoursShort => pick('ч', 'h', de: 'Std.', fr: 'h', es: 'h', tr: 's');
  String get periodAverage => pick('Среднее за период', 'Period average');
  String get moodAverage => pick('Среднее настроение', 'Average mood', de: 'Durchschnittliche Stimmung', fr: 'Humeur moyenne', es: 'Ánimo medio', tr: 'Ortalama ruh hali');
  String get outOfFiveAverage => pick('из 5 в среднем', 'out of 5 average');
  String get outOfFive => pick('из 5 баллов', 'out of 5');
  String get howMoodScoreWorks => pick('Как считается настроение', 'How mood is calculated', de: 'So wird die Stimmung berechnet', fr: 'Comment l’humeur est calculée', es: 'Cómo se calcula el ánimo', tr: 'Ruh hali nasıl hesaplanır');
  String get moodScoreExplanation => pick('Пользователь выбирает одно из 5 настроений. Каждой иконке соответствует балл: 1 — очень тяжело, 2 — сложно, 3 — нейтрально, 4 — хорошо, 5 — отлично. В отчётах показывается среднее значение за выбранный период.', 'The user chooses one of 5 moods. Each icon has a score: 1 very low, 2 low, 3 neutral, 4 good, 5 great. Reports show the average for the selected period.', de: 'Der Nutzer wählt eine von 5 Stimmungen. Jede hat einen Wert: 1 sehr niedrig, 2 niedrig, 3 neutral, 4 gut, 5 sehr gut. Berichte zeigen den Durchschnitt für den gewählten Zeitraum.', fr: 'L’utilisateur choisit une des 5 humeurs. Chaque icône a une note : 1 très bas, 2 bas, 3 neutre, 4 bien, 5 très bien. Les rapports affichent la moyenne de la période.', es: 'El usuario elige uno de 5 ánimos. Cada icono tiene una puntuación: 1 muy bajo, 2 bajo, 3 neutral, 4 bien, 5 muy bien. Los informes muestran la media del periodo elegido.', tr: 'Kullanıcı 5 ruh halinden birini seçer. Her ikonun puanı vardır: 1 çok düşük, 2 düşük, 3 nötr, 4 iyi, 5 harika. Raporlar seçilen dönem ortalamasını gösterir.');
  String get moodVeryLow => pick('Очень тяжело', 'Very low', de: 'Sehr niedrig', fr: 'Très bas', es: 'Muy bajo', tr: 'Çok düşük');
  String get moodLow => pick('Сложно', 'Low', de: 'Niedrig', fr: 'Bas', es: 'Bajo', tr: 'Düşük');
  String get moodNeutral => pick('Нейтрально', 'Neutral', de: 'Neutral', fr: 'Neutre', es: 'Neutral', tr: 'Nötr');
  String get moodGood => pick('Хорошо', 'Good', de: 'Gut', fr: 'Bien', es: 'Bien', tr: 'İyi');
  String get moodGreat => pick('Отлично', 'Great', de: 'Sehr gut', fr: 'Très bien', es: 'Muy bien', tr: 'Harika');
  String get periodEfficiency => pick('Эффективность периода', 'Period efficiency');
  String get plan => pick('План', 'Plan', de: 'Plan');
  String get fact => pick('Факт', 'Actual', de: 'Ist');
  String get timeBySphere => pick('Время по сферам', 'Time by spheres');
  String get topProductiveDays => pick('Топ-3 продуктивных дня', 'Top 3 productive days');
  String get aiObservation => pick('AI-наблюдение', 'AI observation');
  String get periodStatistics => pick('Статистика периода', 'Period statistics', de: 'Periodenstatistik', fr: 'Statistiques de période', es: 'Estadísticas del periodo', tr: 'Dönem istatistikleri');
  String get reportsNoAiUntilSunday => pick('AI-наблюдение в отчётах запускается только в воскресенье; сейчас это статистика без запуска AI.', 'AI observation in reports runs only on Sunday; this is statistics without starting AI.', de: 'Die AI-Beobachtung in Berichten läuft nur am Sonntag; aktuell ist das Statistik ohne AI-Start.', fr: 'L’observation IA dans les rapports ne se lance que le dimanche ; actuellement, ce sont des statistiques sans lancement IA.', es: 'La observación de IA en los informes se ejecuta solo el domingo; ahora son estadísticas sin iniciar IA.', tr: 'Raporlardaki AI gözlemi yalnızca pazar günü çalışır; şu anda AI başlatılmadan istatistik gösteriliyor.');
  String get aiLoading => pick('Готовлю персональное наблюдение…', 'Preparing your personal observation…', de: 'Persönliche Beobachtung wird vorbereitet…', fr: 'Préparation de l’observation personnalisée…', es: 'Preparando una observación personalizada…', tr: 'Kişisel gözlem hazırlanıyor…');
  String get aiUnavailable => pick('AI-наблюдение пока недоступно. Проверь подключение к функции или попробуй обновить позже.', 'AI observation is currently unavailable. Check the function connection or try again later.', de: 'AI-Beobachtung ist derzeit nicht verfügbar. Prüfe die Funktionsverbindung oder versuche es später erneut.', fr: 'L’observation IA est momentanément indisponible. Vérifie la fonction ou réessaie plus tard.', es: 'La observación de IA no está disponible ahora. Revisa la función o inténtalo más tarde.', tr: 'AI gözlemi şu anda kullanılamıyor. Fonksiyon bağlantısını kontrol et veya daha sonra tekrar dene.');
  String get commonRetry => pick('Повторить', 'Retry', de: 'Erneut versuchen', fr: 'Réessayer', es: 'Reintentar', tr: 'Tekrar dene');
  String get insight => pick('Инсайт', 'Insight');
  String get pattern => pick('Паттерн', 'Pattern');
  String get periodTasks => pick('Задачи периода', 'Period tasks');
  String get done => pick('выполнено', 'done', de: 'erledigt');
  String get periodProgress => pick('Прогресс периода', 'Period progress');
  String get tempoBelowNorm => pick('Темп ниже нормы', 'Pace below target');
  String get tempoGood => pick('Темп в норме', 'Pace is on track');
  String get details => pick('Детали', 'Details');
  String get avgTimePerTask => pick('Среднее время / задачу', 'Avg. time / task');
  String get doneOnTime => pick('Выполнено в срок', 'Done on time');
  String get moved => pick('Перенесено', 'Moved');
  String get completed => pick('Выполнено', 'Completed');
  String get forThisPeriod => pick('за этот период', 'for this period');
  String get bestStreak => pick('Лучший страйк', 'Best streak');
  String get daysInARow => pick('дней подряд', 'days in a row');
  String get byHabits => pick('По привычкам', 'By habits');
  String get streaksFourWeeks => pick('Страйки за 4 недели', 'Streaks over 4 weeks');
  String get fourWeeksAgo => pick('4 нед. назад', '4 weeks ago');
  String get missed => pick('пропуск', 'missed');
  String get today => pick('сегодня', 'today');
  String get bestDay => pick('Лучший день', 'Best day');
  String get weekDynamics => pick('Динамика недели', 'Week dynamics');
  String get byDays => pick('По дням', 'By days');
  String get noDataYet => pick('Пока недостаточно данных', 'Not enough data yet');

  String get summaryInsight => pick(
        'Ты продуктивнее во вторник и среду. Перенеси самые важные задачи на начало недели.',
        'You are more productive on Tuesday and Wednesday. Move the most important tasks to the start of the week.',
      );
  String get progressInsight => pick(
        'Задачи по одной сфере откладываются чаще других. Попробуй закрепить для них отдельный утренний блок.',
        'One sphere is postponed more often than others. Try reserving a separate morning block for it.',
      );
  String get habitsInsight => pick(
        'В дни, когда выполнены привычки, продуктивность обычно выше. Начинай день с самой простой привычки.',
        'On days when habits are completed, productivity is usually higher. Start with the easiest habit.',
      );
  String get moodInsight => pick(
        'Настроение выше в дни с выполненными привычками. Сохраняй маленький ритуал утром.',
        'Mood is higher on days with completed habits. Keep a small morning ritual.',
      );

  String get career => pick('Карьера', 'Career');
  String get finance => pick('Финансы', 'Finance');
  String get education => pick('Образование', 'Education');
  String get family => pick('Семья', 'Family');
  String get health => pick('Здоровье', 'Health');
  String get hobbies => pick('Хобби', 'Hobbies');
  String get general => pick('Общее', 'General');

  List<String> get weekdays => _ru
      ? const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
      : _de
          ? const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']
          : _fr
              ? const ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di']
              : _es
                  ? const ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá', 'Do']
                  : _tr
                      ? const ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz']
                      : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String monthName(int month) {
    final ru = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    final en = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final de = ['Jan.', 'Feb.', 'März', 'Apr.', 'Mai', 'Juni', 'Juli', 'Aug.', 'Sept.', 'Okt.', 'Nov.', 'Dez.'];
    final fr = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    final es = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sept', 'oct', 'nov', 'dic'];
    final tr = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    final i = (month - 1).clamp(0, 11);
    if (_ru) return ru[i];
    if (_de) return de[i];
    if (_fr) return fr[i];
    if (_es) return es[i];
    if (_tr) return tr[i];
    return en[i];
  }
}
