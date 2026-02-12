import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/home_model.dart';
import '../../models/reports_model.dart';
import '../../models/mood_model.dart';
import '../../models/mood.dart';
import 'package:nest_app/l10n/app_localizations.dart';

// ✅ week insights types
import '../../models/habit.dart';
import '../../models/mental_question.dart';
import '../../models/week_insights.dart';

// ✅ new widgets (week cards)
import '../../widgets/mood/mood_week_card.dart';
import '../../widgets/mood/habits_week_card.dart';
import '../../widgets/mood/mental_week_card.dart';

import '../../widgets/report_section_card.dart';
import '../../widgets/mood_selector.dart';
import '../../widgets/expense_analytics.dart';

import '../../main.dart'; // dbRepo

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final r = ReportsModel();
            r.setPeriod(ReportPeriod.week);
            r.loadAll();
            return r;
          },
        ),
        ChangeNotifierProvider(create: (_) => MoodModel(repo: dbRepo)..load()),
      ],
      child: const _HomeDashboardBody(),
    );
  }
}

class _HomeDashboardBody extends StatefulWidget {
  const _HomeDashboardBody();

  @override
  State<_HomeDashboardBody> createState() => _HomeDashboardBodyState();
}

class _HomeDashboardBodyState extends State<_HomeDashboardBody>
    with AutomaticKeepAliveClientMixin {
  bool _editingMood = false;
  String _selectedEmoji = '😊';
  final TextEditingController _noteCtrl = TextEditingController();
  bool _savingMood = false;

  // ✅ week insights future for new widgets
  Future<WeekInsights>? _weekFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Safe init (providers are already above in the tree, but this is the most stable way)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _weekFuture = _loadWeekInsights());
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshAll(BuildContext context) async {
    await Future.wait([
      context.read<ReportsModel>().loadAll(),
      context.read<MoodModel>().load(),
    ]);

    if (!mounted) return;
    setState(() => _weekFuture = _loadWeekInsights());
  }

  Mood? _todayMood(List<Mood> moods) {
    final today = DateUtils.dateOnly(DateTime.now());
    for (final m in moods) {
      if (DateUtils.isSameDay(DateUtils.dateOnly(m.date), today)) return m;
    }
    return null;
  }

  String _rangeLabelShort(ReportsModel r, BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final start = loc.formatShortMonthDay(r.range.start);
    final end = loc.formatShortMonthDay(
      r.range.end.subtract(const Duration(days: 1)),
    );
    return '$start – $end';
  }

  Future<void> _saveTodayMood(BuildContext context) async {
    if (_savingMood) return;
    setState(() => _savingMood = true);

    final today = DateUtils.dateOnly(DateTime.now());
    final note = _noteCtrl.text.trim();

    try {
      await dbRepo.upsertMood(date: today, emoji: _selectedEmoji, note: note);
      await context.read<MoodModel>().load();

      if (!mounted) return;

      _noteCtrl.clear();
      setState(() {
        _editingMood = false;
        _selectedEmoji = '😊';
        _savingMood = false;
        _weekFuture = _loadWeekInsights(); // ✅ refresh week insights after save
      });

      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.homeMoodSaved),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _savingMood = false);

      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.homeMoodSaveFailed(e.toString())),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _go(BuildContext context, int index) {
    context.read<HomeModel>().select(index);
  }

  MapEntry<String, double>? _topCategory(Map<String, double> byCategory) {
    if (byCategory.isEmpty) return null;
    MapEntry<String, double>? best;
    for (final e in byCategory.entries) {
      if (best == null || e.value > best!.value) best = e;
    }
    return best;
  }

  MapEntry<DateTime, double>? _peakDay(Map<DateTime, double> byDay) {
    if (byDay.isEmpty) return null;
    MapEntry<DateTime, double>? best;
    for (final e in byDay.entries) {
      if (best == null || e.value > best!.value) best = e;
    }
    return best;
  }

  String _formatDayShort(BuildContext context, DateTime d) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatShortMonthDay(d);
  }

  Widget _cta(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ Week insights logic (for new widgets)
  // ---------------------------------------------------------------------------

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  List<DateTime> _calendarWeekDays({DateTime? anchor}) {
    final a = _dateOnly(anchor ?? DateTime.now());
    final start = a.subtract(Duration(days: a.weekday - DateTime.monday)); // Пн
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  String _weekdayShort(DateTime d) {
    const names = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
    return names[d.weekday % 7];
  }

  int _emojiToScore(String e) {
    switch (e) {
      case '😫':
      case '😭':
      case '😡':
      case '😞':
      case '😢':
        return 1;
      case '😕':
      case '😐':
      case '😟':
        return 2;
      case '🙂':
      case '😊':
        return 3;
      case '😄':
      case '😁':
        return 4;
      case '🤩':
      case '😍':
      case '🥳':
        return 5;
      default:
        return 3;
    }
  }

  Future<WeekInsights> _loadWeekInsights() async {
    final days = _calendarWeekDays();

    // habits
    final habits = await dbRepo.listHabits();

    final habitEntriesByDay = <DateTime, Map<String, Map<String, dynamic>>>{};
    for (final d in days) {
      habitEntriesByDay[d] = await dbRepo.getHabitEntriesForDay(d);
    }

    final habitDoneCount = <String, int>{};
    for (final h in habits) {
      habitDoneCount[h.id] = 0;
    }

    for (final d in days) {
      final map = habitEntriesByDay[d] ?? {};
      for (final h in habits) {
        final e = map[h.id];
        final done = (e?['done'] as bool?) ?? false;
        if (done) habitDoneCount[h.id] = (habitDoneCount[h.id] ?? 0) + 1;
      }
    }

    final topHabits = habits.toList()
      ..sort((a, b) {
        final ca = habitDoneCount[a.id] ?? 0;
        final cb = habitDoneCount[b.id] ?? 0;
        return cb.compareTo(ca);
      });

    // mental questions
    final questions = await dbRepo.listMentalQuestions(onlyActive: true);

    final answersByDay = <DateTime, Map<String, Map<String, dynamic>>>{};
    for (final d in days) {
      answersByDay[d] = await dbRepo.getMentalAnswersForDay(d);
    }

    // moods from MoodModel
    final moods = context.read<MoodModel>().moods;
    final moodByDay = <DateTime, Mood>{};
    for (final m in moods) {
      final k = DateUtils.dateOnly(m.date);
      moodByDay.putIfAbsent(k, () => m);
    }

    final moodScores = days.map((d) {
      final m = moodByDay[d];
      if (m == null) return 0;
      return _emojiToScore(m.emoji);
    }).toList();

    final yesNoQuestions = questions
        .where((q) => q.answerType == 'yes_no')
        .toList();
    final scaleQuestions = questions
        .where((q) => q.answerType == 'scale')
        .toList();

    final yesNoStats = <String, YesNoStat>{};
    for (final q in yesNoQuestions) {
      int yes = 0;
      int total = 0;

      for (final d in days) {
        final map = answersByDay[d] ?? {};
        final a = map[q.id];
        if (a == null) continue;

        final v = a['value_bool'];
        if (v is bool) {
          total++;
          if (v) yes++;
        }
      }

      yesNoStats[q.id] = YesNoStat(question: q, yes: yes, total: total);
    }

    final scaleStats = <String, ScaleStat>{};
    for (final q in scaleQuestions) {
      final series = <int?>[];

      for (final d in days) {
        final map = answersByDay[d] ?? {};
        final a = map[q.id];
        if (a == null) {
          series.add(null);
          continue;
        }
        final v = a['value_int'];
        if (v is int) {
          series.add(v);
        } else if (v is num) {
          series.add(v.toInt());
        } else {
          series.add(null);
        }
      }

      final vals = series.whereType<int>().toList();
      final avg = vals.isEmpty
          ? null
          : (vals.reduce((a, b) => a + b) / vals.length);

      scaleStats[q.id] = ScaleStat(question: q, series: series, avg: avg);
    }

    return WeekInsights(
      days: days,
      moodScores: moodScores,
      habits: habits,
      habitEntriesByDay: habitEntriesByDay,
      habitDoneCount: habitDoneCount,
      questions: questions,
      yesNoStats: yesNoStats,
      scaleStats: scaleStats,
      topHabits: topHabits,
    );
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final l = AppLocalizations.of(context)!;

    final reports = context.watch<ReportsModel>();
    final moodModel = context.watch<MoodModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final mq = MediaQuery.of(context);

    if (reports.period != ReportPeriod.week) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ReportsModel>().setPeriod(ReportPeriod.week);
      });
    }

    final todayMood = _todayMood(moodModel.moods);

    // ---- metrics (same logic as before, just displayed better) ----
    final totalTasks = reports.loading ? null : reports.goalsInRange.length;
    final doneTasks = reports.loading
        ? null
        : reports.goalsInRange.where((g) => g.isCompleted).length;

    final taskProgress =
        (reports.loading || totalTasks == null || totalTasks == 0)
        ? null
        : (doneTasks! / totalTasks).clamp(0.0, 1.0);

    final daysInRange = reports.loading
        ? null
        : (reports.range.end.difference(reports.range.start).inDays).clamp(
            1,
            366,
          );

    final hoursPerDay =
        (reports.loading || daysInRange == null || daysInRange == 0)
        ? null
        : (reports.totalHours / daysInRange);

    final efficiency = reports.loading ? null : reports.efficiency;

    // Responsive layout:
    // phone -> 2x2 grid
    // wide  -> 4 in a row
    final maxWidth = mq.size.width;
    final isPhone = maxWidth < 600;

    return RefreshIndicator.adaptive(
      onRefresh: () => _refreshAll(context),
      child: CustomScrollView(
        key: const PageStorageKey('home-dashboard-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ======= HEADER + CLEAN METRICS GRID =======
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.homeTodayAndWeekTitle,
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.homeTodayAndWeekSubtitle,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  _MetricsGrid(
                    isPhone: isPhone,
                    items: [
                      _MetricItem(
                        title: l.homeMetricMoodTitle,
                        value: todayMood?.emoji ?? '—',
                        subtitle: todayMood == null
                            ? l.homeMoodNoEntry
                            : (todayMood.note.trim().isEmpty
                                  ? l.homeMoodNoNote
                                  : l.homeMoodHasNote),
                        icon: Icons.mood_rounded,
                        progress: todayMood == null ? 0.0 : 1.0,
                      ),
                      _MetricItem(
                        title: l.homeMetricTasksTitle,
                        value: reports.loading
                            ? '…'
                            : (totalTasks == null || totalTasks == 0
                                  ? '0%'
                                  : '${((taskProgress ?? 0) * 100).round()}%'),
                        subtitle: reports.loading
                            ? l.commonLoading
                            : '${doneTasks ?? 0}/${totalTasks ?? 0}',
                        icon: Icons.check_circle_rounded,
                        progress:
                            taskProgress ?? (reports.loading ? null : 0.0),
                      ),
                      _MetricItem(
                        title: l.homeMetricHoursPerDayTitle,
                        value: hoursPerDay == null
                            ? '…'
                            : hoursPerDay.toStringAsFixed(1),
                        subtitle: reports.loading
                            ? l.commonLoading
                            : _rangeLabelShort(reports, context),
                        icon: Icons.timer_outlined,
                        progress: reports.loading ? null : 1.0,
                      ),
                      _MetricItem(
                        title: l.homeMetricEfficiencyTitle,
                        value: efficiency == null
                            ? '…'
                            : '${(efficiency * 100).round()}%',
                        subtitle: reports.loading
                            ? l.commonLoading
                            : l.homeEfficiencyPlannedHours(
                                reports.plannedHours.toStringAsFixed(0),
                              ),
                        icon: Icons.speed_rounded,
                        progress: efficiency,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ✅ NEW: WEEK INSIGHTS (3 cards)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: FutureBuilder<WeekInsights>(
                future: _weekFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const _WeekLoadingCard();
                  }
                  if (!snap.hasData) {
                    return _WeekErrorCard(
                      onRetry: () =>
                          setState(() => _weekFuture = _loadWeekInsights()),
                    );
                  }

                  final data = snap.data!;
                  return Column(
                    children: [
                      MoodWeekCard(
                        days: data.days,
                        scores: data.moodScores,
                        weekdayLabel: _weekdayShort,
                      ),
                      const SizedBox(height: 10),
                      HabitsWeekCard(
                        days: data.days,
                        habits: data.topHabits.take(3).toList(),
                        entriesByDay: data.habitEntriesByDay,
                        doneCount: data.habitDoneCount,
                        weekdayLabel: _weekdayShort,
                      ),
                      const SizedBox(height: 10),
                      MentalWeekCard(
                        days: data.days,
                        weekdayLabel: _weekdayShort,
                        maxItems: 2,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Настроение сегодня (редактор) — логика сохранена
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ReportSectionCard(
                title: l.homeMoodTodayTitle,
                child: moodModel.loading
                    ? const SizedBox(
                        height: 92,
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest.withOpacity(
                                    0.55,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cs.outlineVariant.withOpacity(0.7),
                                  ),
                                ),
                                child: Text(
                                  todayMood?.emoji ?? '📝',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      todayMood == null
                                          ? l.homeMoodNoTodayEntry
                                          : (todayMood.note.trim().isEmpty
                                                ? l.homeMoodEntryNoNote
                                                : todayMood.note.trim()),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: tt.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      todayMood == null
                                          ? l.homeMoodQuickHint
                                          : l.homeMoodUpdateHint,
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant.withOpacity(
                                          0.95,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: _editingMood
                                    ? l.commonCollapse
                                    : l.commonUpdate,
                                onPressed: () => setState(
                                  () => _editingMood = !_editingMood,
                                ),
                                icon: Icon(
                                  _editingMood
                                      ? Icons.expand_less
                                      : Icons.edit_rounded,
                                ),
                              ),
                            ],
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: _editingMood
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: cs.surfaceContainerHighest
                                                .withOpacity(0.55),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: cs.outlineVariant
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                          child: MoodSelector(
                                            selectedEmoji: _selectedEmoji,
                                            onSelect: (e) => setState(
                                              () => _selectedEmoji = e,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: _noteCtrl,
                                          maxLines: 2,
                                          textInputAction: TextInputAction.done,
                                          decoration: InputDecoration(
                                            labelText: l.homeMoodNoteLabel,
                                            hintText: l.homeMoodNoteHint,
                                            prefixIcon: const Icon(
                                              Icons.edit_note_rounded,
                                            ),
                                            filled: true,
                                            fillColor: cs
                                                .surfaceContainerHighest
                                                .withOpacity(0.45),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              borderSide: BorderSide(
                                                color: cs.outlineVariant,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              borderSide: BorderSide(
                                                color: cs.outlineVariant
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              borderSide: BorderSide(
                                                color: cs.primary,
                                                width: 1.4,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 52,
                                          width: double.infinity,
                                          child: FilledButton.icon(
                                            onPressed: _savingMood
                                                ? null
                                                : () => _saveTodayMood(context),
                                            icon: _savingMood
                                                ? SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child: CircularProgressIndicator.adaptive(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(cs.onPrimary),
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.check_rounded,
                                                  ),
                                            label: Text(
                                              _savingMood
                                                  ? l.commonSaving
                                                  : l.commonSave,
                                            ),
                                            style: FilledButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),
                          _cta(
                            context,
                            icon: Icons.open_in_new,
                            label: l.homeOpenMoodHistoryCta,
                            onPressed: () => _go(context, 2),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // Сводка недели — без дублирования метрик (оставляем диапазон + CTA)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ReportSectionCard(
                title: l.homeWeekSummaryTitle,
                child: reports.loading
                    ? const SizedBox(
                        height: 92,
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _rangeLabelShort(reports, context),
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _cta(
                            context,
                            icon: Icons.insights_rounded,
                            label: l.homeOpenReportsCta,
                            onPressed: () => _go(context, 4),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // Расходы недели — без изменений
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: ReportSectionCard(
                title: l.homeWeekExpensesTitle,
                child: reports.loading
                    ? const SizedBox(
                        height: 92,
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    : FutureBuilder<ExpenseAnalytics>(
                        future: loadExpenseAnalytics(
                          reports.range.start,
                          reports.range.end,
                        ),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 92,
                              child: Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                          }

                          final data = snap.data;
                          if (data == null ||
                              (data.total <= 0 && data.byDay.isEmpty)) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.homeNoExpensesThisWeek,
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _cta(
                                  context,
                                  icon: Icons.account_balance_wallet_rounded,
                                  label: l.homeOpenExpensesCta,
                                  onPressed: () => _go(context, 5),
                                ),
                              ],
                            );
                          }

                          final days =
                              (reports.range.end
                                      .difference(reports.range.start)
                                      .inDays)
                                  .clamp(1, 366);
                          final avg = data.total / days;

                          final topCat = _topCategory(data.byCategory);
                          final peak = _peakDay(data.byDay);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.homeExpensesTotal(
                                  data.total.toStringAsFixed(2),
                                ),
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l.homeExpensesAvgPerDay(avg.toStringAsFixed(2)),
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant.withOpacity(0.95),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (topCat != null || peak != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest
                                        .withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: cs.outlineVariant.withOpacity(
                                        0.55,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.homeInsightsTitle,
                                        style: tt.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if (topCat != null)
                                        Text(
                                          l.homeTopCategory(
                                            topCat.key,
                                            topCat.value.toStringAsFixed(2),
                                          ),
                                          style: tt.bodyMedium?.copyWith(
                                            color: cs.onSurfaceVariant
                                                .withOpacity(0.98),
                                          ),
                                        ),
                                      if (peak != null)
                                        Text(
                                          l.homePeakExpense(
                                            _formatDayShort(context, peak.key),
                                            peak.value.toStringAsFixed(2),
                                          ),
                                          style: tt.bodyMedium?.copyWith(
                                            color: cs.onSurfaceVariant
                                                .withOpacity(0.98),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 12),
                              _cta(
                                context,
                                icon: Icons.open_in_new,
                                label: l.homeOpenDetailedExpensesCta,
                                onPressed: () => _go(context, 5),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ===================== WEEK helper cards (loading/error) =====================

class _WeekLoadingCard extends StatelessWidget {
  const _WeekLoadingCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ReportSectionCard(
      title: l.homeWeekCardTitle,
      child: const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}

class _WeekErrorCard extends StatelessWidget {
  final VoidCallback onRetry;
  const _WeekErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ReportSectionCard(
      title: l.homeWeekCardTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.homeWeekLoadFailedTitle,
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            l.homeWeekLoadFailedSubtitle,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l.commonRetry),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== UI: compact, mobile-friendly grid =====================

class _MetricItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final double? progress;

  const _MetricItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.progress,
  });
}

class _MetricsGrid extends StatelessWidget {
  final bool isPhone;
  final List<_MetricItem> items;

  const _MetricsGrid({required this.isPhone, required this.items});

  @override
  Widget build(BuildContext context) {
    final columns = isPhone ? 2 : 4;

    return LayoutBuilder(
      builder: (ctx, c) {
        final gap = 12.0;
        final totalGap = gap * (columns - 1);
        final w = (c.maxWidth - totalGap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final it in items)
              SizedBox(
                width: w,
                child: _MetricTile(item: it),
              ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  final _MetricItem item;
  const _MetricTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
      ),
      child: Row(
        children: [
          _MiniRing(progress: item.progress, icon: item.icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant.withOpacity(0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRing extends StatelessWidget {
  final double? progress; // 0..1, null -> loading
  final IconData icon;

  const _MiniRing({required this.progress, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = progress;

    const size = 44.0;
    const stroke = 5.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1,
            strokeWidth: stroke,
            valueColor: AlwaysStoppedAnimation<Color>(
              cs.outlineVariant.withOpacity(0.30),
            ),
          ),
          if (p == null)
            const CircularProgressIndicator.adaptive(strokeWidth: stroke)
          else
            CircularProgressIndicator(
              value: p.clamp(0.0, 1.0),
              strokeWidth: stroke,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              backgroundColor: Colors.transparent,
            ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.65),
              shape: BoxShape.circle,
              border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
            ),
            child: Icon(icon, size: 16, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
