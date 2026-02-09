import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/mood_selector.dart';
import '../widgets/report_section_card.dart';

import '../models/mood_model.dart';
import '../models/mood.dart';

import '../models/habit.dart';
import '../models/mental_question.dart';

import '../main.dart'; // dbRepo

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MoodModel(repo: dbRepo)..load(),
      child: const _MoodView(),
    );
  }
}

class _MoodView extends StatefulWidget {
  const _MoodView();

  @override
  State<_MoodView> createState() => _MoodViewState();
}

class _MoodViewState extends State<_MoodView> {
  String _selectedEmoji = '😊';
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  bool _saving = false;

  static const int _maxLen = 200;

  // --- Week analytics cache ---
  Future<_WeekInsights>? _weekFuture;

  @override
  void initState() {
    super.initState();
    _weekFuture = _loadWeekInsights();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Date helpers
  // ---------------------------------------------------------------------------

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  List<DateTime> _last7Days() {
    final today = _dateOnly(DateTime.now());
    // oldest -> newest
    return List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
  }

  String _weekdayShort(DateTime d) {
    // Без intl — просто 2 буквы
    const names = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
    return names[d.weekday % 7];
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  String _formatDateShort(BuildContext context, DateTime d) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatMediumDate(d);
  }

  String _formatDateHeader(BuildContext context, DateTime d) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatFullDate(d);
  }

  Map<DateTime, List<Mood>> _groupByDay(List<Mood> src) {
    final map = <DateTime, List<Mood>>{};
    for (final m in src) {
      final key = DateUtils.dateOnly(m.date);
      map.putIfAbsent(key, () => []).add(m);
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return {for (final e in entries) e.key: e.value};
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final cs = Theme.of(context).colorScheme;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: cs.copyWith(surface: cs.surface),
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (d != null) setState(() => _selectedDate = DateUtils.dateOnly(d));
  }

  Future<void> _save(BuildContext context) async {
    if (_saving) return;
    final note = _noteController.text.trim();

    setState(() => _saving = true);

    final err = await context.read<MoodModel>().saveMoodForDate(
      date: _selectedDate,
      emoji: _selectedEmoji,
      note: note,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    _noteController.clear();
    setState(() {
      _selectedEmoji = '😊';
      _selectedDate = DateUtils.dateOnly(DateTime.now());
    });

    // обновляем week insights
    setState(() => _weekFuture = _loadWeekInsights());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Настроение сохранено'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refresh() async {
    await context.read<MoodModel>().load();
    setState(() => _weekFuture = _loadWeekInsights());
  }

  Future<void> _editMood(BuildContext context, Mood mood) async {
    final res = await showDialog<_EditMoodResult>(
      context: context,
      builder: (_) => _EditMoodDialog(initial: mood),
    );
    if (res == null) return;

    final m = context.read<MoodModel>();

    if (res.delete) {
      final err = await m.deleteMoodByDate(mood.date);
      if (err != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
        );
      }
      setState(() => _weekFuture = _loadWeekInsights());
      return;
    }

    final err = await m.updateMoodByDate(
      originalDate: mood.date,
      newDate: res.date,
      emoji: res.emoji,
      note: res.note,
    );

    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
      );
    }

    setState(() => _weekFuture = _loadWeekInsights());
  }

  // ---------------------------------------------------------------------------
  // Week insights
  // ---------------------------------------------------------------------------

  Future<_WeekInsights> _loadWeekInsights() async {
    final days = _last7Days();

    // 1) Habits
    final habits = await dbRepo.listHabits();

    // day -> habitId -> entry
    final habitEntriesByDay = <DateTime, Map<String, Map<String, dynamic>>>{};
    for (final d in days) {
      habitEntriesByDay[d] = await dbRepo.getHabitEntriesForDay(d);
    }

    // habitId -> doneCount
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

    // 2) Mental questions
    final questions = await dbRepo.listMentalQuestions(onlyActive: true);

    final answersByDay = <DateTime, Map<String, Map<String, dynamic>>>{};
    for (final d in days) {
      answersByDay[d] = await dbRepo.getMentalAnswersForDay(d);
    }

    // mood bar data (based on moods in MoodModel)
    // We map emoji -> score (1..5) for a simple weekly chart.
    // Это не идеально, но очень user-friendly.
    final moods = context.read<MoodModel>().moods;
    final moodByDay = <DateTime, Mood>{};
    for (final m in moods) {
      final k = DateUtils.dateOnly(m.date);
      // берём первую запись дня
      moodByDay.putIfAbsent(k, () => m);
    }

    final moodScores = days.map((d) {
      final m = moodByDay[d];
      if (m == null) return 0;
      return _emojiToScore(m.emoji);
    }).toList();

    // mental aggregates
    final yesNoQuestions = questions
        .where((q) => q.answerType == 'yes_no')
        .toList();

    final scaleQuestions = questions
        .where((q) => q.answerType == 'scale')
        .toList();

    // yes/no: percent yes
    final yesNoStats = <String, _YesNoStat>{};
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

      yesNoStats[q.id] = _YesNoStat(question: q, yes: yes, total: total);
    }

    // scale: avg + series
    final scaleStats = <String, _ScaleStat>{};
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

      scaleStats[q.id] = _ScaleStat(question: q, series: series, avg: avg);
    }

    return _WeekInsights(
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

  int _emojiToScore(String e) {
    // Простая шкала 1..5 (можно потом улучшить)
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MoodModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final moods = model.moods;
    final loading = model.loading;

    final grouped = _groupByDay(moods);

    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              title: const Text('Настроение'),
              centerTitle: false,
              actions: [
                IconButton(
                  tooltip: 'Обновить',
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),

            // -----------------------------------------------------------------
            // Composer
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: _GlassCard(
                  borderRadius: 22,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _ChipButton(
                                    icon: Icons.calendar_month_rounded,
                                    label: _formatDateShort(
                                      context,
                                      _selectedDate,
                                    ),
                                    onTap: _pickDate,
                                  ),
                                  _ChipInfo(
                                    icon: Icons.auto_awesome_rounded,
                                    label: '1 запись = 1 день',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Как ты себя чувствуешь?',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: cs.outlineVariant.withOpacity(0.6),
                            ),
                          ),
                          child: MoodSelector(
                            selectedEmoji: _selectedEmoji,
                            onSelect: (emoji) =>
                                setState(() => _selectedEmoji = emoji),
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller: _noteController,
                          maxLines: 3,
                          maxLength: _maxLen,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Заметка (необязательно)',
                            hintText: 'Что повлияло на твоё состояние?',
                            prefixIcon: const Icon(Icons.edit_note_rounded),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withOpacity(
                              0.45,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: cs.outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: cs.outlineVariant.withOpacity(0.7),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
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
                          child: FilledButton.icon(
                            onPressed: _saving ? null : () => _save(context),
                            icon: _saving
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        cs.onPrimary,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.check_rounded),
                            label: Text(_saving ? 'Сохранение…' : 'Сохранить'),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // WEEK INSIGHTS (Mood + Habits + Mental)
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: FutureBuilder<_WeekInsights>(
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
                        _MoodWeekCard(
                          days: data.days,
                          scores: data.moodScores,
                          weekdayLabel: _weekdayShort,
                        ),
                        const SizedBox(height: 10),
                        _HabitsWeekCard(
                          days: data.days,
                          habits: data.topHabits.take(3).toList(),
                          entriesByDay: data.habitEntriesByDay,
                          doneCount: data.habitDoneCount,
                          weekdayLabel: _weekdayShort,
                        ),
                        const SizedBox(height: 10),
                        _MentalWeekCard(
                          days: data.days,
                          yesNoStats: data.yesNoStats.values.take(2).toList(),
                          scaleStats: data.scaleStats.values.take(2).toList(),
                          weekdayLabel: _weekdayShort,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // History header
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    Text(
                      'История настроений',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (!loading && moods.isNotEmpty)
                      Text(
                        '${moods.length}',
                        style: tt.labelLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator.adaptive()),
              )
            else if (moods.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  emoji: '📝',
                  title: 'Пока нет записей',
                  subtitle: 'Выбери дату, отметь настроение и сохрани запись.',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entries = grouped.entries.toList();
                    int cursor = 0;

                    for (final entry in entries) {
                      final date = entry.key;
                      final items = entry.value;
                      final blockLen = 1 + items.length;

                      if (index >= cursor && index < cursor + blockLen) {
                        final innerIndex = index - cursor;

                        if (innerIndex == 0) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                            child: Text(
                              _formatDateHeader(context, date),
                              style: tt.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        final mood = items[innerIndex - 1];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _MoodHistoryTile(
                            mood: mood,
                            onEdit: () => _editMood(context, mood),
                            onDelete: () async {
                              final ok =
                                  await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Удалить запись?'),
                                      content: Text(
                                        '${_formatDateShort(context, DateUtils.dateOnly(mood.date))}: '
                                        '${mood.emoji}'
                                        '${mood.note.isEmpty ? '' : '\n\n${mood.note}'}',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Отмена'),
                                        ),
                                        FilledButton.tonal(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Удалить'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;

                              if (!ok) return;

                              final err = await context
                                  .read<MoodModel>()
                                  .deleteMoodByDate(mood.date);
                              if (err != null && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(err),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }

                              setState(() => _weekFuture = _loadWeekInsights());
                            },
                          ),
                        );
                      }

                      cursor += blockLen;
                    }

                    return const SizedBox.shrink();
                  },
                  childCount: grouped.entries.fold<int>(
                    0,
                    (sum, e) => sum + 1 + e.value.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Week insight models
// ============================================================================

class _WeekInsights {
  final List<DateTime> days;

  // mood chart: 0..5
  final List<int> moodScores;

  // habits
  final List<Habit> habits;
  final List<Habit> topHabits;
  final Map<DateTime, Map<String, Map<String, dynamic>>> habitEntriesByDay;
  final Map<String, int> habitDoneCount;

  // mental
  final List<MentalQuestion> questions;
  final Map<String, _YesNoStat> yesNoStats;
  final Map<String, _ScaleStat> scaleStats;

  _WeekInsights({
    required this.days,
    required this.moodScores,
    required this.habits,
    required this.topHabits,
    required this.habitEntriesByDay,
    required this.habitDoneCount,
    required this.questions,
    required this.yesNoStats,
    required this.scaleStats,
  });
}

class _YesNoStat {
  final MentalQuestion question;
  final int yes;
  final int total;

  _YesNoStat({required this.question, required this.yes, required this.total});

  double get ratio => total <= 0 ? 0 : yes / total;
}

class _ScaleStat {
  final MentalQuestion question;
  final List<int?> series; // 7 values
  final double? avg;

  _ScaleStat({required this.question, required this.series, required this.avg});
}

// ============================================================================
// Week insight cards
// ============================================================================

class _WeekLoadingCard extends StatelessWidget {
  const _WeekLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const ReportSectionCard(
      title: 'Неделя',
      child: SizedBox(
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ReportSectionCard(
      title: 'Неделя',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Не удалось загрузить статистику',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Проверь интернет или повтори позже.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Повторить'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodWeekCard extends StatelessWidget {
  final List<DateTime> days;
  final List<int> scores;
  final String Function(DateTime d) weekdayLabel;

  const _MoodWeekCard({
    required this.days,
    required this.scores,
    required this.weekdayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final filled = scores.where((v) => v > 0).length;
    final avg = scores.where((v) => v > 0).isEmpty
        ? null
        : scores.where((v) => v > 0).reduce((a, b) => a + b) /
              scores.where((v) => v > 0).length;

    return ReportSectionCard(
      title: 'Состояние недели',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MoodBars(days: days, scores: scores, weekdayLabel: weekdayLabel),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniPill(
                icon: Icons.check_circle_rounded,
                label: 'Отмечено: $filled/7',
              ),
              _MiniPill(
                icon: Icons.auto_graph_rounded,
                label: avg == null
                    ? 'Среднее: —'
                    : 'Среднее: ${avg.toStringAsFixed(1)}/5',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Это быстрый обзор. Детали ниже — в истории.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _HabitsWeekCard extends StatelessWidget {
  final List<DateTime> days;
  final List<Habit> habits; // already top 3
  final Map<DateTime, Map<String, Map<String, dynamic>>> entriesByDay;
  final Map<String, int> doneCount;
  final String Function(DateTime d) weekdayLabel;

  const _HabitsWeekCard({
    required this.days,
    required this.habits,
    required this.entriesByDay,
    required this.doneCount,
    required this.weekdayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (habits.isEmpty) {
      return ReportSectionCard(
        title: 'Привычки',
        child: Text(
          'Добавь хотя бы одну привычку — и тут появится прогресс.',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    return ReportSectionCard(
      title: 'Привычки (топ недели)',
      child: Column(
        children: [
          for (final h in habits) ...[
            _HabitHeatmapRow(
              habit: h,
              days: days,
              entriesByDay: entriesByDay,
              doneCount: doneCount[h.id] ?? 0,
              weekdayLabel: weekdayLabel,
            ),
            if (h != habits.last) const SizedBox(height: 12),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Показываем самые активные привычки за 7 дней.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // позже можно сделать переход на habits screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Скоро: экран привычек'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Открыть привычки'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentalWeekCard extends StatelessWidget {
  final List<DateTime> days;
  final List<_YesNoStat> yesNoStats;
  final List<_ScaleStat> scaleStats;
  final String Function(DateTime d) weekdayLabel;

  const _MentalWeekCard({
    required this.days,
    required this.yesNoStats,
    required this.scaleStats,
    required this.weekdayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (yesNoStats.isEmpty && scaleStats.isEmpty) {
      return ReportSectionCard(
        title: 'Ментальное здоровье',
        child: Text(
          'Добавь вопросы (или ответы) — и тут появится статистика.',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    return ReportSectionCard(
      title: 'Ментальное здоровье',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (yesNoStats.isNotEmpty) ...[
            Text(
              'Да/Нет (неделя)',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final s in yesNoStats) ...[
              _YesNoBar(stat: s),
              const SizedBox(height: 10),
            ],
          ],
          if (scaleStats.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Шкалы (тренд)',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final s in scaleStats) ...[
              _ScaleSparkline(stat: s, days: days, weekdayLabel: weekdayLabel),
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
  }
}

// ============================================================================
// Charts (pure Flutter, lightweight)
// ============================================================================

class _MoodBars extends StatelessWidget {
  final List<DateTime> days;
  final List<int> scores; // 0..5
  final String Function(DateTime d) weekdayLabel;

  const _MoodBars({
    required this.days,
    required this.scores,
    required this.weekdayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(days.length, (i) {
          final v = scores[i].clamp(0, 5);
          final h = 10 + (v * 10); // 10..60

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: v == 0 ? 8 : h.toDouble(),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: v == 0
                        ? cs.surfaceContainerHighest.withOpacity(0.35)
                        : cs.primary.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  weekdayLabel(days[i]),
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _HabitHeatmapRow extends StatelessWidget {
  final Habit habit;
  final List<DateTime> days;
  final Map<DateTime, Map<String, Map<String, dynamic>>> entriesByDay;
  final int doneCount;
  final String Function(DateTime d) weekdayLabel;

  const _HabitHeatmapRow({
    required this.habit,
    required this.days,
    required this.entriesByDay,
    required this.doneCount,
    required this.weekdayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                habit.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$doneCount/7',
              style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(days.length, (i) {
            final d = days[i];
            final map = entriesByDay[d] ?? {};
            final e = map[habit.id];
            final done = (e?['done'] as bool?) ?? false;

            return Expanded(
              child: Column(
                children: [
                  Container(
                    height: 22,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: done
                          ? cs.tertiary.withOpacity(0.8)
                          : cs.surfaceContainerHighest.withOpacity(0.35),
                      border: Border.all(
                        color: cs.outlineVariant.withOpacity(0.55),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    weekdayLabel(d),
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _YesNoBar extends StatelessWidget {
  final _YesNoStat stat;
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
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: cs.surfaceContainerHighest.withOpacity(0.35),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio.clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: cs.secondary.withOpacity(0.8),
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
  final _ScaleStat stat;
  final List<DateTime> days;
  final String Function(DateTime d) weekdayLabel;

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
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
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
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
          ),
          child: CustomPaint(
            painter: _SparklinePainter(
              values: stat.series,
              min: minV,
              max: maxV,
              color: cs.primary.withOpacity(0.9),
              bgColor: cs.onSurfaceVariant.withOpacity(0.08),
            ),
            child: const SizedBox.expand(),
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

    // background
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(14),
    );
    canvas.drawRRect(r, paintBg);

    final vals = values;
    final n = vals.length;
    if (n < 2) return;

    double norm(int v) {
      if (max == min) return 0.5;
      return (v - min) / (max - min);
    }

    final points = <Offset>[];
    for (int i = 0; i < n; i++) {
      final v = vals[i];
      if (v == null) continue;

      final x = (i / (n - 1)) * size.width;
      final y = size.height - (norm(v).clamp(0, 1) * size.height);
      points.add(Offset(x, y));
    }

    if (points.length < 2) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paintLine);

    for (final p in points) {
      canvas.drawCircle(p, 2.8, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.min != min ||
        oldDelegate.max != max ||
        oldDelegate.color != color;
  }
}

// ============================================================================
// Small UI helpers
// ============================================================================

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Modern UI pieces (твой стиль)
// -----------------------------------------------------------------------------

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  const _GlassCard({required this.child, this.borderRadius = 20});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.55),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.55),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ChipInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _MoodHistoryTile extends StatelessWidget {
  final Mood mood;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  const _MoodHistoryTile({
    required this.mood,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final note = mood.note.trim();
    final title = note.isEmpty ? 'Без заметки' : note;

    return Dismissible(
      key: ValueKey('mood_${DateUtils.dateOnly(mood.date).toIso8601String()}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: cs.errorContainer.withOpacity(0.55),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.delete_rounded, color: cs.onErrorContainer),
      ),
      child: _GlassCard(
        borderRadius: 18,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          leading: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
            ),
            child: Text(mood.emoji, style: const TextStyle(fontSize: 22)),
          ),
          title: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            'Нажми, чтобы редактировать',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing: Icon(Icons.edit_rounded, color: cs.onSurfaceVariant),
          onTap: onEdit,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Dialog
// -----------------------------------------------------------------------------

class _EditMoodResult {
  final bool delete;
  final DateTime date;
  final String emoji;
  final String note;

  _EditMoodResult({
    required this.delete,
    required this.date,
    required this.emoji,
    required this.note,
  });
}

class _EditMoodDialog extends StatefulWidget {
  final Mood initial;
  const _EditMoodDialog({required this.initial});

  @override
  State<_EditMoodDialog> createState() => _EditMoodDialogState();
}

class _EditMoodDialogState extends State<_EditMoodDialog> {
  late DateTime _date;
  late String _emoji;
  late TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _date = DateUtils.dateOnly(widget.initial.date);
    _emoji = widget.initial.emoji;
    _note = TextEditingController(text: widget.initial.note);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String _format(BuildContext context, DateTime d) {
    return MaterialLocalizations.of(context).formatMediumDate(d);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _date = DateUtils.dateOnly(d));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text('Редактировать запись'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text('Дата: ${_format(context, _date)}')),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Изменить'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MoodSelector(
            selectedEmoji: _emoji,
            onSelect: (e) => setState(() => _emoji = e),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Заметка',
              filled: true,
              fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(
            context,
            _EditMoodResult(
              delete: true,
              date: _date,
              emoji: _emoji,
              note: _note.text.trim(),
            ),
          ),
          icon: Icon(Icons.delete_outline_rounded, color: cs.error),
          label: Text('Удалить', style: TextStyle(color: cs.error)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _EditMoodResult(
              delete: false,
              date: _date,
              emoji: _emoji,
              note: _note.text.trim(),
            ),
          ),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Empty state
// -----------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.55),
                shape: BoxShape.circle,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 34)),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXTENSIONS НА МОДЕЛЬ — твой стиль
// ─────────────────────────────────────────────────────────────────────────────

extension MoodModelOps on MoodModel {
  Future<String?> saveMoodForDate({
    required DateTime date,
    required String emoji,
    required String note,
  }) async {
    try {
      await repo.upsertMood(
        date: DateUtils.dateOnly(date),
        emoji: emoji,
        note: note,
      );
      await load();
      return null;
    } catch (e) {
      return 'Не удалось сохранить настроение: $e';
    }
  }

  Future<String?> updateMoodByDate({
    required DateTime originalDate,
    required DateTime newDate,
    required String emoji,
    required String note,
  }) async {
    try {
      final orig = DateUtils.dateOnly(originalDate);
      final next = DateUtils.dateOnly(newDate);

      await repo.upsertMood(date: next, emoji: emoji, note: note);
      if (orig != next) {
        await repo.deleteMoodByDate(orig);
      }
      await load();
      return null;
    } catch (e) {
      return 'Не удалось обновить запись: $e';
    }
  }

  Future<String?> deleteMoodByDate(DateTime date) async {
    try {
      await repo.deleteMoodByDate(DateUtils.dateOnly(date));
      await load();
      return null;
    } catch (e) {
      return 'Не удалось удалить запись: $e';
    }
  }
}
