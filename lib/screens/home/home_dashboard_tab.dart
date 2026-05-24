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
import '../mood_screen.dart';

// ✅ new widgets (week cards)
import '../../widgets/mood/mood_week_card.dart';
import '../../widgets/mood/habits_week_card.dart';
import '../../widgets/mood/mental_week_card.dart';
import '../../widgets/home/hobby_tracker_card.dart';
import '../../widgets/home/health_tracker_card.dart';
import '../../widgets/home/shopping_tracker_card.dart';

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

  Future<WeekInsights>? _weekFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _weekFuture = _loadWeekInsights();
      });
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

    setState(() {
      _weekFuture = _loadWeekInsights();
    });
  }

  Mood? _todayMood(List<Mood> moods) {
    final today = DateUtils.dateOnly(DateTime.now());

    for (final m in moods) {
      if (DateUtils.isSameDay(DateUtils.dateOnly(m.date), today)) {
        return m;
      }
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

    setState(() {
      _savingMood = true;
    });

    final today = DateUtils.dateOnly(DateTime.now());
    final note = _noteCtrl.text.trim();

    try {
      await dbRepo.upsertMood(
        date: today,
        emoji: _selectedEmoji,
        note: note,
      );

      if (!mounted) return;

      await context.read<MoodModel>().load();

      if (!mounted) return;

      _noteCtrl.clear();

      setState(() {
        _editingMood = false;
        _selectedEmoji = '😊';
        _savingMood = false;
        _weekFuture = _loadWeekInsights();
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

      setState(() {
        _savingMood = false;
      });

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
      if (best == null || e.value > best!.value) {
        best = e;
      }
    }

    return best;
  }

  MapEntry<DateTime, double>? _peakDay(Map<DateTime, double> byDay) {
    if (byDay.isEmpty) return null;

    MapEntry<DateTime, double>? best;

    for (final e in byDay.entries) {
      if (best == null || e.value > best!.value) {
        best = e;
      }
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
  // Week insights logic
  // ---------------------------------------------------------------------------

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  List<DateTime> _calendarWeekDays({DateTime? anchor}) {
    final a = _dateOnly(anchor ?? DateTime.now());
    final start = a.subtract(Duration(days: a.weekday - DateTime.monday));

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

  bool _isYesNoQuestion(MentalQuestion q) {
    final raw = q.answerType.toString().toLowerCase();

    return raw.contains('yes_no') ||
        raw.contains('yesno') ||
        raw.contains('boolean') ||
        raw.contains('bool');
  }

  bool _isScaleQuestion(MentalQuestion q) {
    final raw = q.answerType.toString().toLowerCase();

    return raw.contains('scale') ||
        raw.contains('rating') ||
        raw.contains('integer') ||
        raw.contains('int');
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

        if (done) {
          habitDoneCount[h.id] = (habitDoneCount[h.id] ?? 0) + 1;
        }
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

    final yesNoQuestions = questions.where(_isYesNoQuestion).toList();
    final scaleQuestions = questions.where(_isScaleQuestion).toList();

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

      yesNoStats[q.id] = YesNoStat(
        question: q,
        yes: yes,
        total: total,
      );
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

      scaleStats[q.id] = ScaleStat(
        question: q,
        series: series,
        avg: avg,
      );
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
        : (reports.range.end.difference(reports.range.start).inDays).clamp(1, 366);

    final hoursPerDay =
        (reports.loading || daysInRange == null || daysInRange == 0)
            ? null
            : (reports.totalHours / daysInRange);

    final efficiency = reports.loading ? null : reports.efficiency;
    final isPhone = mq.size.width < 600;

    final today = DateUtils.dateOnly(DateTime.now());
    final todayGoals = reports.loading
        ? reports.goalsInRange.where((_) => false).toList()
        : reports.goalsInRange
            .where((g) => DateUtils.isSameDay(DateUtils.dateOnly(g.startTime), today))
            .toList();

    final todayIncomplete = todayGoals.where((g) => !g.isCompleted).toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));

    final weekIncomplete = reports.loading
        ? reports.goalsInRange.where((_) => false).toList()
        : (reports.goalsInRange.where((g) => !g.isCompleted).toList()
          ..sort((a, b) => b.importance.compareTo(a.importance)));

    final focusGoals = todayIncomplete.isNotEmpty
        ? todayIncomplete.take(3).toList()
        : weekIncomplete.take(3).toList();

    final todayHours = todayGoals.fold<double>(
      0,
      (sum, g) => sum + (g.spentHours as num).toDouble(),
    );

    final insightText = _buildInsightText(
      context,
      todayMood: todayMood,
      totalTasks: totalTasks ?? 0,
      doneTasks: doneTasks ?? 0,
      taskProgress: taskProgress,
      hoursPerDay: hoursPerDay,
      efficiency: efficiency,
    );

    return RefreshIndicator.adaptive(
      onRefresh: () => _refreshAll(context),
      child: CustomScrollView(
        key: const PageStorageKey('home-dashboard-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.homeTodayAndWeekTitle,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.homeTodayAndWeekSubtitle,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _TodayFocusCard(
                    loading: reports.loading,
                    focusGoals: focusGoals,
                    todayGoalsCount: todayGoals.length,
                    todayDoneCount: todayGoals.where((g) => g.isCompleted).length,
                    todayHours: todayHours,
                    onOpenGoals: () => _go(context, 1),
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
                        progress: taskProgress ?? (reports.loading ? null : 0.0),
                      ),
                      _MetricItem(
                        title: _dashText(context, 'Фокус-часы', 'Focus hours', 'Fokuszeit', 'Heures focus', 'Horas foco', 'Odak saatleri'),
                        value: hoursPerDay == null ? '…' : hoursPerDay.toStringAsFixed(1),
                        subtitle: reports.loading ? l.commonLoading : _rangeLabelShort(reports, context),
                        icon: Icons.timer_outlined,
                        progress: (reports.loading || hoursPerDay == null)
                            ? null
                            : (hoursPerDay / 8).clamp(0.0, 1.0),
                      ),
                      _MetricItem(
                        title: _dashText(context, 'Баланс недели', 'Week balance', 'Wochenbalance', 'Équilibre', 'Balance semanal', 'Hafta dengesi'),
                        value: efficiency == null ? '…' : '${(efficiency * 100).round()}%',
                        subtitle: reports.loading
                            ? l.commonLoading
                            : l.homeEfficiencyPlannedHours(reports.plannedHours.toStringAsFixed(0)),
                        icon: Icons.speed_rounded,
                        progress: efficiency,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AiInsightCard(text: insightText),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: FutureBuilder<WeekInsights>(
                future: _weekFuture,
                builder: (context, snap) {
                  if (_weekFuture == null || snap.connectionState == ConnectionState.waiting) {
                    return const _WeekLoadingCard();
                  }

                  if (snap.hasError || !snap.hasData) {
                    return _WeekErrorCard(
                      onRetry: () {
                        setState(() {
                          _weekFuture = _loadWeekInsights();
                        });
                      },
                    );
                  }

                  final data = snap.data!;
                  return Column(
                    children: [
                      _WeekStateCompactCard(
                        days: data.days,
                        scores: data.moodScores,
                        weekdayLabel: _weekdayShort,
                      ),
                      const SizedBox(height: 10),
                      HabitsWeekCard(
                        days: data.days,
                        habits: data.topHabits.take(2).toList(),
                        entriesByDay: data.habitEntriesByDay,
                        doneCount: data.habitDoneCount,
                        weekdayLabel: _weekdayShort,
                      ),
                      const SizedBox(height: 10),
                      MentalWeekCard(
                        days: data.days,
                        weekdayLabel: _weekdayShort,
                        maxItems: 1,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ReportSectionCard(
                title: l.homeMoodTodayTitle,
                child: moodModel.loading
                    ? const SizedBox(
                        height: 92,
                        child: Center(child: CircularProgressIndicator.adaptive()),
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
                                  color: cs.surfaceContainerHighest.withOpacity(0.55),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
                                ),
                                child: Text(todayMood?.emoji ?? '📝', style: const TextStyle(fontSize: 22)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      todayMood == null
                                          ? l.homeMoodNoTodayEntry
                                          : (todayMood.note.trim().isEmpty ? l.homeMoodEntryNoNote : todayMood.note.trim()),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      todayMood == null ? l.homeMoodQuickHint : l.homeMoodUpdateHint,
                                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant.withOpacity(0.95)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: _editingMood ? l.commonCollapse : l.commonUpdate,
                                onPressed: () => setState(() => _editingMood = !_editingMood),
                                icon: Icon(_editingMood ? Icons.expand_less : Icons.edit_rounded),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: cs.surfaceContainerHighest.withOpacity(0.55),
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
                                          ),
                                          child: MoodSelector(
                                            selectedEmoji: _selectedEmoji,
                                            onSelect: (e) => setState(() => _selectedEmoji = e),
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
                                            prefixIcon: const Icon(Icons.edit_note_rounded),
                                            filled: true,
                                            fillColor: cs.surfaceContainerHighest.withOpacity(0.45),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              borderSide: BorderSide(color: cs.outlineVariant),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.7)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              borderSide: BorderSide(color: cs.primary, width: 1.4),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 52,
                                          width: double.infinity,
                                          child: FilledButton.icon(
                                            onPressed: _savingMood ? null : () => _saveTodayMood(context),
                                            icon: _savingMood
                                                ? SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child: CircularProgressIndicator.adaptive(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                                                    ),
                                                  )
                                                : const Icon(Icons.check_rounded),
                                            label: Text(_savingMood ? l.commonSaving : l.commonSave),
                                            style: FilledButton.styleFrom(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoodScreen()));
                            },
                          ),
                        ],
                      ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: _SectionHeading(
                title: _dashText(context, 'Трекеры', 'Trackers', 'Tracker', 'Trackers', 'Seguidores', 'Takipçiler'),
                subtitle: _dashText(
                  context,
                  'Здоровье, хобби и покупки — ниже, чтобы главный экран не перегружался.',
                  'Health, hobbies and shopping sit below the daily focus.',
                  'Gesundheit, Hobbys und Einkäufe bleiben unter dem Tagesfokus.',
                  'Santé, loisirs et achats restent sous le focus du jour.',
                  'Salud, aficiones y compras quedan bajo el foco diario.',
                  'Sağlık, hobiler ve alışveriş günlük odağın altında.',
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Column(
                children: [
                  HealthTrackerCard(),
                  SizedBox(height: 10),
                  HobbyTrackerCard(),
                  SizedBox(height: 10),
                  ShoppingTrackerCard(),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ReportSectionCard(
                title: l.homeWeekSummaryTitle,
                child: reports.loading
                    ? const SizedBox(
                        height: 92,
                        child: Center(child: CircularProgressIndicator.adaptive()),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _rangeLabelShort(reports, context),
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  String _buildInsightText(
    BuildContext context, {
    required Mood? todayMood,
    required int totalTasks,
    required int doneTasks,
    required double? taskProgress,
    required double? hoursPerDay,
    required double? efficiency,
  }) {
    final lang = Localizations.localeOf(context).languageCode;

    String pick({required String ru, required String en, required String de, required String fr, required String es, required String tr}) {
      switch (lang) {
        case 'de': return de;
        case 'fr': return fr;
        case 'es': return es;
        case 'tr': return tr;
        case 'en': return en;
        default: return ru;
      }
    }

    if (todayMood == null) {
      return pick(
        ru: 'Начни с короткой отметки настроения. Это займёт 10 секунд и сделает недельную аналитику заметно точнее.',
        en: 'Start with a quick mood check. It takes 10 seconds and makes weekly insights much more accurate.',
        de: 'Starte mit einem kurzen Stimmungscheck. Das dauert 10 Sekunden und verbessert die Wochenanalyse deutlich.',
        fr: 'Commence par une note d’humeur rapide. Cela prend 10 secondes et rend l’analyse hebdomadaire plus précise.',
        es: 'Empieza con una nota rápida de ánimo. Toma 10 segundos y mejora mucho el análisis semanal.',
        tr: 'Kısa bir ruh hali kaydıyla başla. 10 saniye sürer ve haftalık analizleri çok daha doğru yapar.',
      );
    }

    if (totalTasks > 8 && doneTasks == 0) {
      return pick(
        ru: 'Задач много, но прогресс пока нулевой. Выбери 3 ключевые задачи и начни с самой важной.',
        en: 'There are many tasks, but progress is still at zero. Pick 3 key tasks and start with the most important one.',
        de: 'Es gibt viele Aufgaben, aber noch keinen Fortschritt. Wähle 3 Kernaufgaben und starte mit der wichtigsten.',
        fr: 'Il y a beaucoup de tâches, mais aucun progrès pour l’instant. Choisis 3 priorités et commence par la plus importante.',
        es: 'Hay muchas tareas, pero el progreso aún está en cero. Elige 3 tareas clave y empieza por la más importante.',
        tr: 'Çok görev var ama ilerleme henüz sıfır. 3 ana görev seç ve en önemlisinden başla.',
      );
    }

    if ((efficiency ?? 0) < 0.35 && totalTasks > 0) {
      return pick(
        ru: 'Неделя выглядит перегруженной. Лучше сократить план и оставить только то, что реально двигает тебя вперёд.',
        en: 'The week looks overloaded. Reduce the plan and keep only what truly moves you forward.',
        de: 'Die Woche wirkt überladen. Reduziere den Plan und behalte nur das, was dich wirklich voranbringt.',
        fr: 'La semaine semble chargée. Réduis le plan et garde seulement ce qui te fait vraiment avancer.',
        es: 'La semana parece sobrecargada. Reduce el plan y deja solo lo que realmente te hace avanzar.',
        tr: 'Hafta biraz yoğun görünüyor. Planı sadeleştir ve seni gerçekten ilerleten şeyleri bırak.',
      );
    }

    if ((hoursPerDay ?? 0) > 6) {
      return pick(
        ru: 'Фокус-часы высокие. Добавь паузы и не планируй день без восстановления.',
        en: 'Focus hours are high. Add breaks and avoid planning without recovery time.',
        de: 'Die Fokuszeit ist hoch. Plane Pausen ein und vergiss Erholung nicht.',
        fr: 'Les heures de focus sont élevées. Ajoute des pauses et garde du temps de récupération.',
        es: 'Las horas de foco son altas. Añade pausas y deja tiempo para recuperarte.',
        tr: 'Odak saatlerin yüksek. Molalar ekle ve toparlanma süresi bırak.',
      );
    }

    return pick(
      ru: 'Хороший момент для спокойного старта: зафиксируй настроение, выбери главный фокус и двигайся маленькими шагами.',
      en: 'A good moment for a calm start: log your mood, choose the main focus, and move in small steps.',
      de: 'Ein guter Moment für einen ruhigen Start: Stimmung festhalten, Fokus wählen und in kleinen Schritten vorangehen.',
      fr: 'Bon moment pour démarrer calmement : note ton humeur, choisis ton focus et avance par petits pas.',
      es: 'Buen momento para empezar con calma: registra tu ánimo, elige el foco principal y avanza paso a paso.',
      tr: 'Sakin bir başlangıç için iyi bir an: ruh halini kaydet, ana odağı seç ve küçük adımlarla ilerle.',
    );
  }
}


// ===================== DASHBOARD helper cards =====================

String _dashText(
  BuildContext context,
  String ru,
  String en,
  String de,
  String fr,
  String es,
  String tr,
) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'de':
      return de;
    case 'fr':
      return fr;
    case 'es':
      return es;
    case 'tr':
      return tr;
    case 'en':
      return en;
    default:
      return ru;
  }
}

class _TodayFocusCard extends StatelessWidget {
  final bool loading;
  final List<dynamic> focusGoals;
  final int todayGoalsCount;
  final int todayDoneCount;
  final double todayHours;
  final VoidCallback onOpenGoals;

  const _TodayFocusCard({
    required this.loading,
    required this.focusGoals,
    required this.todayGoalsCount,
    required this.todayDoneCount,
    required this.todayHours,
    required this.onOpenGoals,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = _dashText(
      context,
      'Фокус сегодня',
      'Today’s focus',
      'Fokus heute',
      'Focus du jour',
      'Foco de hoy',
      'Bugünün odağı',
    );
    final empty = _dashText(
      context,
      'На сегодня нет задач. Создай 1–3 фокус-задачи, чтобы день был управляемым.',
      'No tasks for today. Create 1–3 focus tasks to make the day manageable.',
      'Für heute gibt es keine Aufgaben. Erstelle 1–3 Fokusaufgaben.',
      'Aucune tâche pour aujourd’hui. Crée 1 à 3 tâches focus.',
      'No hay tareas para hoy. Crea 1–3 tareas de foco.',
      'Bugün için görev yok. Günü yönetilebilir yapmak için 1–3 odak görevi oluştur.',
    );
    final cta = _dashText(context, 'Открыть задачи', 'Open tasks', 'Aufgaben öffnen', 'Ouvrir les tâches', 'Abrir tareas', 'Görevleri aç');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Color.lerp(cs.surfaceContainerHigh, cs.primary, 0.12)!,
                  Color.lerp(cs.surfaceContainerHigh, cs.secondary, 0.10)!,
                ]
              : [
                  Color.lerp(cs.surfaceContainerLowest, cs.secondary, 0.34)!,
                  Color.lerp(cs.surfaceContainerLowest, cs.primary, 0.12)!,
                  Color.lerp(cs.surfaceContainerLowest, cs.tertiary, 0.16)!,
                ],
        ),
        border: Border.all(
          color: Color.lerp(cs.outlineVariant, cs.secondary, isDark ? 0.34 : 0.58)!,
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.secondary.withOpacity(isDark ? 0.08 : 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: loading
          ? const SizedBox(
              height: 118,
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withOpacity(isDark ? 0.20 : 0.12),
                        border: Border.all(color: cs.primary.withOpacity(0.28)),
                      ),
                      child: Icon(Icons.track_changes_rounded, color: cs.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$todayDoneCount/$todayGoalsCount · ${todayHours.toStringAsFixed(1)} ч',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (focusGoals.isEmpty)
                  Text(
                    empty,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  )
                else
                  Column(
                    children: [
                      for (final g in focusGoals) ...[
                        _FocusTaskLine(title: '${g.title}', importance: g.importance as int),
                        if (g != focusGoals.last) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onOpenGoals,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(cta),
                  ),
                ),
              ],
            ),
    );
  }
}

class _FocusTaskLine extends StatelessWidget {
  final String title;
  final int importance;

  const _FocusTaskLine({required this.title, required this.importance});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final tone = importance >= 3 ? cs.secondary : (importance == 2 ? cs.primary : cs.tertiary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Color.lerp(cs.surfaceContainerHighest, tone, 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color.lerp(cs.outlineVariant, tone, 0.36)!),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_rounded, color: tone, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiInsightCard extends StatelessWidget {
  final String text;
  const _AiInsightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = _dashText(context, 'AI-наблюдение', 'AI insight', 'AI-Hinweis', 'Insight IA', 'Insight IA', 'AI içgörüsü');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.lerp(cs.surfaceContainerLow, cs.primary, isDark ? 0.06 : 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color.lerp(cs.outlineVariant, cs.primary, 0.34)!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: cs.onPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    height: 1.32,
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

class _WeekStateCompactCard extends StatelessWidget {
  final List<DateTime> days;
  final List<int> scores;
  final String Function(DateTime) weekdayLabel;

  const _WeekStateCompactCard({
    required this.days,
    required this.scores,
    required this.weekdayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final filled = scores.where((v) => v > 0).length;
    final valid = scores.where((v) => v > 0).toList();
    final avg = valid.isEmpty ? null : valid.reduce((a, b) => a + b) / valid.length;

    return ReportSectionCard(
      title: _dashText(context, 'Состояние недели', 'Week state', 'Wochenstatus', 'État de la semaine', 'Estado semanal', 'Hafta durumu'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color.lerp(cs.surfaceContainerHighest, cs.secondary, 0.10),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Color.lerp(cs.outlineVariant, cs.secondary, 0.30)!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(days.length, (i) {
                final v = scores[i].clamp(0, 5);
                final accent = v >= 4 ? cs.secondary : (v >= 3 ? cs.primary : cs.outlineVariant);
                return Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        height: v == 0 ? 8 : 18 + v * 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color.lerp(cs.surfaceContainerHigh, accent, v == 0 ? 0.12 : 0.72),
                          border: Border.all(color: Color.lerp(cs.outlineVariant, accent, v == 0 ? 0.10 : 0.42)!),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        weekdayLabel(days[i]),
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniInfoPill(
                icon: Icons.check_circle_rounded,
                label: _dashText(context, 'Отмечено: $filled/7', 'Marked: $filled/7', 'Erfasst: $filled/7', 'Noté : $filled/7', 'Marcado: $filled/7', 'İşaretlendi: $filled/7'),
              ),
              _MiniInfoPill(
                icon: Icons.auto_graph_rounded,
                label: avg == null
                    ? _dashText(context, 'Среднее: —', 'Average: —', 'Schnitt: —', 'Moyenne : —', 'Media: —', 'Ortalama: —')
                    : _dashText(context, 'Среднее: ${avg.toStringAsFixed(1)}/5', 'Average: ${avg.toStringAsFixed(1)}/5', 'Schnitt: ${avg.toStringAsFixed(1)}/5', 'Moyenne : ${avg.toStringAsFixed(1)}/5', 'Media: ${avg.toStringAsFixed(1)}/5', 'Ortalama: ${avg.toStringAsFixed(1)}/5'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniInfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Color.lerp(cs.surfaceContainerHighest, cs.secondary, 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Color.lerp(cs.outlineVariant, cs.secondary, 0.24)!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.secondary),
          const SizedBox(width: 8),
          Text(label, style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [cs.secondary, cs.primary],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ===================== WEEK helper cards =====================

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

  const _MetricsGrid({
    required this.isPhone,
    required this.items,
  });

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

  Color _accent(ColorScheme cs) {
    if (item.icon == Icons.mood_rounded || item.icon == Icons.timer_outlined) {
      return cs.secondary;
    }
    if (item.icon == Icons.speed_rounded) return cs.tertiary;
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _accent(cs);

    final bg = isDark
        ? Color.lerp(cs.surfaceContainerLow, accent, 0.08)!
        : Color.lerp(cs.surfaceContainerLowest, accent, 0.16)!;
    final border = Color.lerp(cs.outlineVariant, accent, isDark ? 0.32 : 0.56)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border, width: 1.45),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isDark ? 0.08 : 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _MiniRing(progress: item.progress, icon: item.icon, accent: accent),
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
                    fontWeight: FontWeight.w800,
                    color: cs.onSurfaceVariant,
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
  final double? progress;
  final IconData icon;
  final Color accent;

  const _MiniRing({
    required this.progress,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = progress;

    const size = 46.0;
    const stroke = 5.5;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1,
            strokeWidth: stroke,
            valueColor: AlwaysStoppedAnimation<Color>(cs.outlineVariant.withOpacity(0.58)),
          ),
          if (p == null)
            const CircularProgressIndicator.adaptive(strokeWidth: stroke)
          else
            CircularProgressIndicator(
              value: p.clamp(0.0, 1.0),
              strokeWidth: stroke,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              backgroundColor: Colors.transparent,
            ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Color.lerp(cs.surfaceContainerHighest, accent, 0.20),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color.lerp(cs.outlineVariant, accent, 0.38)!,
                width: 1.2,
              ),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
        ],
      ),
    );
  }
}
