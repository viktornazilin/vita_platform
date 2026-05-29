// lib/screens/goals_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/goal.dart';
import '../models/goals_calendar_model.dart';
import '../models/home_model.dart';
import '../models/profile_model.dart';
import '../models/user_goal.dart';
import '../models/user_goals_model.dart';
import '../widgets/add_day_goal_sheet.dart';

import 'day_goals_screen.dart';


bool get _ladnaDarkMode =>
    WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

Color _ladnaAdaptive(Color light, Color dark) => _ladnaDarkMode ? dark : light;

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoalsCalendarModel()..loadBlocks()),
        ChangeNotifierProvider(create: (_) => ProfileModel(repo: dbRepo)..load()),
        ChangeNotifierProvider(create: (_) => UserGoalsModel(repo: dbRepo)..load()),
      ],
      child: const _GoalsView(),
    );
  }
}

enum _MainTab { tasks, goals }
enum _TaskView { dashboard, week, month, calendar }

class _GoalsView extends StatefulWidget {
  const _GoalsView();

  @override
  State<_GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<_GoalsView> {
  _MainTab _tab = _MainTab.tasks;
  _TaskView _taskView = _TaskView.dashboard;
  GoalHorizon? _horizon;

  DateTime _anchor = DateUtils.dateOnly(DateTime.now());
  bool _loadingWeek = false;
  bool _loadingMonth = false;
  Map<DateTime, List<Goal>> _weekGoals = {};
  Map<DateTime, List<Goal>> _monthGoals = {};

  DateTime get _weekStart {
    final d = DateUtils.dateOnly(_anchor);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  DateTime get _monthStart => DateTime(_anchor.year, _anchor.month, 1);

  int get _daysInMonth => DateUtils.getDaysInMonth(_anchor.year, _anchor.month);

  List<DateTime> get _monthDays =>
      List.generate(_daysInMonth, (i) => DateTime(_anchor.year, _anchor.month, i + 1));

  @override
  void initState() {
    super.initState();
    _loadWeek();
  }

  Future<void> _loadWeek() async {
    setState(() => _loadingWeek = true);
    final next = <DateTime, List<Goal>>{};

    try {
      for (final day in _weekDays) {
        final utc = DateTime.utc(day.year, day.month, day.day);
        final goals = await dbRepo.getGoalsByDate(utc, lifeBlock: null);
        goals.sort((a, b) => a.startTime.compareTo(b.startTime));
        next[DateUtils.dateOnly(day)] = goals;
      }
    } catch (_) {
      // UI remains usable; individual errors are handled by repository screens.
    }

    if (!mounted) return;
    setState(() {
      _weekGoals = next;
      _loadingWeek = false;
    });
  }

  Future<void> _loadMonth() async {
    setState(() => _loadingMonth = true);
    final next = <DateTime, List<Goal>>{};

    try {
      for (final day in _monthDays) {
        final utc = DateTime.utc(day.year, day.month, day.day);
        final goals = await dbRepo.getGoalsByDate(utc, lifeBlock: null);
        goals.sort((a, b) => a.startTime.compareTo(b.startTime));
        next[DateUtils.dateOnly(day)] = goals;
      }
    } catch (_) {
      // The screen should remain usable even if a day fails to load.
    }

    if (!mounted) return;
    setState(() {
      _monthGoals = next;
      _loadingMonth = false;
    });
  }

  void _setTaskView(_TaskView view) {
    if (_taskView == view) return;
    setState(() => _taskView = view);
    if (view == _TaskView.month || view == _TaskView.calendar) {
      _loadMonth();
    }
  }

  void _shiftPeriod(int direction) {
    setState(() {
      if (_taskView == _TaskView.month || _taskView == _TaskView.calendar) {
        _anchor = DateTime(_anchor.year, _anchor.month + direction, 1);
      } else {
        _anchor = _anchor.add(Duration(days: 7 * direction));
      }
    });

    _loadWeek();
    if (_taskView == _TaskView.month || _taskView == _TaskView.calendar) {
      _loadMonth();
    }
  }

  void _handleBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.maybePop();
      return;
    }

    try {
      context.read<HomeModel>().select(0);
    } catch (_) {
      // If this screen is opened without HomeModel above it, do nothing safely.
    }
  }

  Future<void> _openDay(DateTime date) async {
    final calendar = context.read<GoalsCalendarModel>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DayGoalsScreen(
          date: date,
          lifeBlock: null,
          availableBlocks: calendar.lifeBlocks,
        ),
      ),
    );
    if (mounted) _loadWeek();
  }

  Future<void> _openAddTask([DateTime? date]) async {
    final targetDate = DateUtils.dateOnly(date ?? _anchor);
    final calendar = context.read<GoalsCalendarModel>();
    final userGoals = context.read<UserGoalsModel>();

    final links = userGoals.items
        .where((g) => !g.isCompleted)
        .map(
          (g) => UserGoalLinkOption(
            id: g.id,
            title: g.title,
            lifeBlock: g.lifeBlock,
            horizon: g.horizon.dbValue,
          ),
        )
        .toList();

    final result = await showModalBottomSheet<AddGoalResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddDayGoalSheet(
        fixedLifeBlock: null,
        availableBlocks: calendar.lifeBlocks,
        availableUserGoals: links,
      ),
    );

    if (result == null) return;

    try {
      final start = DateTime.utc(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        result.startTime.hour,
        result.startTime.minute,
      );

      await dbRepo.createGoal(
        title: result.title,
        description: result.description,
        deadline: DateTime.utc(targetDate.year, targetDate.month, targetDate.day),
        lifeBlock: result.lifeBlock,
        importance: result.importance,
        emotion: result.emotion,
        spentHours: result.hours,
        startTime: start,
        userGoalId: result.userGoalId,
      );

      if (mounted) _loadWeek();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _openAddUserGoal() async {
    final model = context.read<UserGoalsModel>();
    final calendar = context.read<GoalsCalendarModel>();

    final result = await showModalBottomSheet<UserGoalUpsert>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserGoalEditorSheet(
        availableBlocks: calendar.lifeBlocks,
      ),
    );

    if (result == null) return;
    final error = await model.upsert(result);
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _editUserGoal(UserGoal goal) async {
    final model = context.read<UserGoalsModel>();
    final calendar = context.read<GoalsCalendarModel>();

    final result = await showModalBottomSheet<UserGoalUpsert>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserGoalEditorSheet(
        availableBlocks: calendar.lifeBlocks,
        initial: goal,
      ),
    );

    if (result == null) return;
    final error = await model.upsert(result);
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }


  Future<void> _deleteUserGoal(UserGoal goal) async {
    final text = _GoalsText.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _LadnaColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(text.deleteGoal, style: _LadnaText.cardTitle.copyWith(fontSize: 18)),
        content: Text(text.deleteGoalQuestion, style: _LadnaText.bodySmall),
        actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(text.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE35B5B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(text.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final model = context.read<UserGoalsModel>();
    final error = await model.delete(goal.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _GoalsText.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _LadnaColors.page,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 112 + bottom),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed([
                        _Header(
                          title: text.goalsAndTasks,
                          subtitle: _periodTitle(context),
                          onBack: _handleBack,
                        ),
                        const SizedBox(height: 14),
                        _Segmented<_MainTab>(
                          value: _tab,
                          items: [
                            _SegmentItem(_MainTab.tasks, text.tasks),
                            _SegmentItem(_MainTab.goals, text.goals),
                          ],
                          onChanged: (v) => setState(() => _tab = v),
                        ),
                        const SizedBox(height: 12),
                        if (_tab == _MainTab.tasks) ..._buildTasks(context),
                        if (_tab == _MainTab.goals) ..._buildGoals(context),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 18,
              // The HomeScreen already owns the persistent bottom navigation.
              // Keep the local action button just above that bar instead of
              // floating in the middle of the content.
              bottom: 28 + bottom,
              child: _Fab(
                label: text.add,
                onTap: _tab == _MainTab.tasks ? () => _openAddTask(_anchor) : _openAddUserGoal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _periodTitle(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final start = _weekStart;
    final end = start.add(const Duration(days: 6));
    return '${loc.formatMonthYear(start)} · ${loc.formatShortMonthDay(start)}–${loc.formatShortMonthDay(end)}';
  }

  List<Widget> _buildTasks(BuildContext context) {
    final text = _GoalsText.of(context);

    return [
      Row(
        children: [
          Expanded(
            child: _Segmented<_TaskView>(
              value: _taskView,
              items: [
                _SegmentItem(_TaskView.dashboard, text.dashboard),
                _SegmentItem(_TaskView.week, text.week),
                _SegmentItem(_TaskView.month, text.month),
                _SegmentItem(_TaskView.calendar, text.calendar),
              ],
              dense: true,
              onChanged: _setTaskView,
            ),
          ),
          const SizedBox(width: 6),
          _ArrowButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => _shiftPeriod(-1),
          ),
          const SizedBox(width: 4),
          _ArrowButton(
            icon: Icons.chevron_right_rounded,
            onTap: () => _shiftPeriod(1),
          ),
        ],
      ),
      const SizedBox(height: 14),
      if (_taskView == _TaskView.dashboard) ..._buildTasksDashboard(context),
      if (_taskView == _TaskView.week) ..._buildTasksWeek(context),
      if (_taskView == _TaskView.month) ..._buildTasksMonth(context),
      if (_taskView == _TaskView.calendar) ..._buildTasksCalendar(context),
      const SizedBox(height: 10),
    ];
  }

  List<Widget> _buildTasksDashboard(BuildContext context) {
    final text = _GoalsText.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final totalGoals = _weekGoals.values.expand((x) => x).toList();
    final done = totalGoals.where((g) => g.isCompleted).length;
    final hours = totalGoals.where((g) => g.isCompleted).fold<double>(0, (s, g) => s + g.spentHours);
    const targetHours = 98.0;

    return [
      _WeekSummaryCard(
        title: text.weekSummary,
        value: '${hours.toStringAsFixed(1)} / ${targetHours.toStringAsFixed(0)} ${text.hoursShort}',
        subtitle: text.completedTasks(done, totalGoals.length),
        progress: targetHours == 0 ? 0.0 : (hours / targetHours).clamp(0.0, 1.0).toDouble(),
      ),
      const SizedBox(height: 14),
      _SectionLabel(text.thisWeek),
      if (_loadingWeek)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        )
      else
        ..._weekDays.map((day) {
          final key = DateUtils.dateOnly(day);
          final goals = _weekGoals[key] ?? const <Goal>[];
          final dayHours = goals.where((g) => g.isCompleted).fold<double>(0, (s, g) => s + g.spentHours);
          final isToday = DateUtils.isSameDay(day, today);
          return _DayRow(
            date: day,
            isToday: isToday,
            hours: dayHours,
            targetHours: 14,
            hasData: goals.isNotEmpty || !day.isAfter(today),
            onTap: () => _openDay(day),
          );
        }),
    ];
  }

  List<Widget> _buildTasksWeek(BuildContext context) {
    final text = _GoalsText.of(context);
    final today = DateUtils.dateOnly(DateTime.now());

    return [
      _SectionLabel(text.weekView),
      if (_loadingWeek)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        )
      else
        ..._weekDays.map((day) {
          final key = DateUtils.dateOnly(day);
          final goals = _weekGoals[key] ?? const <Goal>[];
          return _DayTasksCard(
            date: day,
            goals: goals,
            isToday: DateUtils.isSameDay(day, today),
            onTap: () => _openDay(day),
          );
        }),
    ];
  }

  List<Widget> _buildTasksMonth(BuildContext context) {
    final text = _GoalsText.of(context);
    final goals = _monthGoals.values.expand((x) => x).toList();
    final done = goals.where((g) => g.isCompleted).length;
    final hours = goals.where((g) => g.isCompleted).fold<double>(0, (s, g) => s + g.spentHours);
    final monthTarget = _daysInMonth * 14.0;

    return [
      _WeekSummaryCard(
        title: MaterialLocalizations.of(context).formatMonthYear(_monthStart),
        value: '${hours.toStringAsFixed(1)} / ${monthTarget.toStringAsFixed(0)} ${text.hoursShort}',
        subtitle: text.completedTasks(done, goals.length),
        progress: monthTarget <= 0 ? 0 : (hours / monthTarget).clamp(0.0, 1.0).toDouble(),
      ),
      const SizedBox(height: 14),
      _SectionLabel(text.monthView),
      if (_loadingMonth)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        )
      else
        _MonthList(
          days: _monthDays,
          goalsByDay: _monthGoals,
          onTapDay: _openDay,
        ),
    ];
  }

  List<Widget> _buildTasksCalendar(BuildContext context) {
    final text = _GoalsText.of(context);

    return [
      _SectionLabel('${text.calendar} · ${MaterialLocalizations.of(context).formatMonthYear(_monthStart)}'),
      if (_loadingMonth)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        )
      else
        _CalendarGrid(
          monthStart: _monthStart,
          days: _monthDays,
          goalsByDay: _monthGoals,
          onTapDay: _openDay,
        ),
    ];
  }

  List<Widget> _buildGoals(BuildContext context) {
    final text = _GoalsText.of(context);
    final model = context.watch<UserGoalsModel>();
    final items = model.items.where((g) {
      if (_horizon == null) return true;
      return g.horizon == _horizon;
    }).toList();

    final groupedByBlock = <String, List<UserGoal>>{};
    for (final g in items) {
      groupedByBlock.putIfAbsent(g.lifeBlock, () => []).add(g);
    }

    return [
      _Segmented<GoalHorizon?>(
        value: _horizon,
        items: [
          _SegmentItem<GoalHorizon?>(null, text.all),
          _SegmentItem<GoalHorizon?>(GoalHorizon.tactical, text.upToOneMonth),
          _SegmentItem<GoalHorizon?>(GoalHorizon.mid, text.upToSixMonths),
          _SegmentItem<GoalHorizon?>(GoalHorizon.long, text.yearPlus),
        ],
        dense: true,
        onChanged: (v) => setState(() => _horizon = v),
      ),
      const SizedBox(height: 14),
      if (model.loading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        )
      else ...[
        _SphereGoalsCard(goals: model.items, text: text),
        const SizedBox(height: 12),
        if (items.isEmpty)
          _EmptyCard(
            title: text.noGoalsYet,
            subtitle: text.noGoalsYetSub,
          )
        else
          ...groupedByBlock.entries.expand((entry) {
            final goals = entry.value;
            goals.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
            return [
              _SectionLabel(_lifeBlockLabel(context, entry.key)),
              ...goals.map(
                (g) => _UserGoalTile(
                  goal: g,
                  onTap: () => _editUserGoal(g),
                  onDelete: () => _deleteUserGoal(g),
                  onToggle: () async {
                    final error = await model.toggleCompleted(g);
                    if (!mounted || error == null) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                  },
                ),
              ),
              const SizedBox(height: 6),
            ];
          }),
      ],
    ];
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _LadnaDecor.header,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          _RoundIconButton(icon: Icons.chevron_left_rounded, onTap: onBack),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _LadnaText.serifTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: _LadnaText.caption),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentItem<T> {
  final T value;
  final String label;
  const _SegmentItem(this.value, this.label);
}

class _Segmented<T> extends StatelessWidget {
  final T value;
  final List<_SegmentItem<T>> items;
  final ValueChanged<T> onChanged;
  final bool dense;

  const _Segmented({
    required this.value,
    required this.items,
    required this.onChanged,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _LadnaColors.card,
        borderRadius: BorderRadius.circular(dense ? 12 : 14),
      ),
      child: Row(
        children: items.map((item) {
          final selected = item.value == value;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(item.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: EdgeInsets.symmetric(vertical: dense ? 7 : 9),
                decoration: BoxDecoration(
                  color: selected
                      ? (_ladnaDarkMode ? _LadnaColors.primary : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(dense ? 9 : 11),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _ladnaDarkMode
                                ? _LadnaColors.primary.withOpacity(0.28)
                                : const Color(0x171C1812),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: dense ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? (_ladnaDarkMode ? Colors.white : _LadnaColors.dark)
                        : _LadnaColors.muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WeekSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double progress;

  const _WeekSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: _LadnaText.cardTitle)),
              Text(value, style: _LadnaText.caption.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 9),
          _Progress(value: progress),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(subtitle, style: _LadnaText.caption),
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final double hours;
  final double targetHours;
  final bool hasData;
  final VoidCallback onTap;

  const _DayRow({
    required this.date,
    required this.isToday,
    required this.hours,
    required this.targetHours,
    required this.hasData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final text = _GoalsText.of(context);
    final progress = targetHours <= 0 ? 0.0 : (hours / targetHours).clamp(0.0, 1.0).toDouble();
    final weekday = _weekdayShort(context, date).toUpperCase();

    return Opacity(
      opacity: hasData ? 1 : 0.55,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: isToday ? _LadnaColors.surface : _LadnaColors.surfaceLight,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isToday ? _LadnaColors.primary.withOpacity(0.25) : _LadnaColors.border.withOpacity(0.8),
            ),
            boxShadow: _LadnaDecor.shadow,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? '$weekday · ${text.todayShort}' : weekday,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: isToday ? _LadnaColors.primary : _LadnaColors.muted,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .3,
                      ),
                    ),
                    Text(
                      '${date.day}',
                      style: _LadnaText.serifNumber.copyWith(
                        color: isToday ? _LadnaColors.primary : _LadnaColors.dark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _Progress(value: progress)),
              const SizedBox(width: 10),
              Text(
                hasData
                    ? '${hours.toStringAsFixed(1)} / ${targetHours.toStringAsFixed(0)} ${text.hoursShort}'
                    : '— / ${targetHours.toStringAsFixed(0)} ${text.hoursShort}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isToday ? _LadnaColors.primary : _LadnaColors.muted,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 18, color: _LadnaColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}


class _DayTasksCard extends StatelessWidget {
  final DateTime date;
  final List<Goal> goals;
  final bool isToday;
  final VoidCallback onTap;

  const _DayTasksCard({
    required this.date,
    required this.goals,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = _GoalsText.of(context);
    final done = goals.where((g) => g.isCompleted).length;
    final hours = goals.where((g) => g.isCompleted).fold<double>(0, (sum, g) => sum + g.spentHours);

    return _Card(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isToday ? _LadnaColors.primary : _LadnaColors.card,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isToday ? Colors.white : _LadnaColors.muted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_weekdayShort(context, date), style: _LadnaText.cardTitle),
                      const SizedBox(height: 2),
                      Text(
                        goals.isEmpty
                            ? text.noTasks
                            : '$done/${goals.length} ${text.completed} · ${hours.toStringAsFixed(1)} ${text.hoursShort}',
                        style: _LadnaText.caption,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: _LadnaColors.muted),
              ],
            ),
            if (goals.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...goals.take(3).map((goal) => _TaskPreviewRow(goal: goal)),
              if (goals.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 48),
                  child: Text('+${goals.length - 3}', style: _LadnaText.caption),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TaskPreviewRow extends StatelessWidget {
  final Goal goal;
  const _TaskPreviewRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 48),
      child: Row(
        children: [
          Icon(
            goal.isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 16,
            color: goal.isCompleted ? _LadnaColors.primary : _LadnaColors.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              goal.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: goal.isCompleted ? _LadnaColors.muted : _LadnaColors.dark,
                decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthList extends StatelessWidget {
  final List<DateTime> days;
  final Map<DateTime, List<Goal>> goalsByDay;
  final ValueChanged<DateTime> onTapDay;

  const _MonthList({
    required this.days,
    required this.goalsByDay,
    required this.onTapDay,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    return Column(
      children: days.map((day) {
        final key = DateUtils.dateOnly(day);
        final goals = goalsByDay[key] ?? const <Goal>[];
        final done = goals.where((g) => g.isCompleted).length;
        final hours = goals.where((g) => g.isCompleted).fold<double>(0, (sum, g) => sum + g.spentHours);
        final isToday = DateUtils.isSameDay(day, today);
        return _DayRow(
          date: day,
          isToday: isToday,
          hours: hours,
          targetHours: 14,
          hasData: goals.isNotEmpty || !day.isAfter(today),
          onTap: () => onTapDay(day),
        );
      }).toList(),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime monthStart;
  final List<DateTime> days;
  final Map<DateTime, List<Goal>> goalsByDay;
  final ValueChanged<DateTime> onTapDay;

  const _CalendarGrid({
    required this.monthStart,
    required this.days,
    required this.goalsByDay,
    required this.onTapDay,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final leadingEmpty = monthStart.weekday - 1;
    final cells = <Widget>[
      for (var i = 0; i < leadingEmpty; i++) const SizedBox.shrink(),
      ...days.map((day) {
        final key = DateUtils.dateOnly(day);
        final goals = goalsByDay[key] ?? const <Goal>[];
        final done = goals.where((g) => g.isCompleted).length;
        final isToday = DateUtils.isSameDay(day, today);
        final hasTasks = goals.isNotEmpty;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTapDay(day),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isToday ? _LadnaColors.primary : _LadnaColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isToday ? _LadnaColors.primary : _LadnaColors.border,
              ),
              boxShadow: isToday ? _LadnaDecor.shadow : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isToday ? Colors.white : _LadnaColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                if (hasTasks)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isToday ? Colors.white.withOpacity(.18) : _LadnaColors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$done/${goals.length}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isToday ? Colors.white : _LadnaColors.muted,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isToday ? Colors.white.withOpacity(.6) : _LadnaColors.card,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    ];

    return _Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: List.generate(7, (i) {
              final monday = DateTime(2026, 1, 5 + i);
              return Expanded(
                child: Center(child: Text(_weekdayShort(context, monday), style: _LadnaText.microUpper)),
              );
            }),
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            childAspectRatio: .82,
            children: cells,
          ),
        ],
      ),
    );
  }
}

class _SphereGoalsCard extends StatelessWidget {
  final List<UserGoal> goals;
  final _GoalsText text;

  const _SphereGoalsCard({required this.goals, required this.text});

  @override
  Widget build(BuildContext context) {
    final byBlock = <String, List<UserGoal>>{};
    for (final g in goals.where((g) => !g.isCompleted)) {
      byBlock.putIfAbsent(g.lifeBlock, () => []).add(g);
    }

    if (byBlock.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = byBlock.values.fold<int>(1, (m, list) => list.length > m ? list.length : m);

    return _Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(text.bySpheres, style: _LadnaText.cardTitle)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _LadnaColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(text.hide, style: _LadnaText.caption),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ...byBlock.entries.map((entry) {
            final color = _blockColor(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 9),
                  SizedBox(width: 84, child: Text(_lifeBlockLabel(context, entry.key), style: _LadnaText.bodySmall)),
                  Expanded(child: _Progress(value: entry.value.length / maxCount, color: color)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: _LadnaColors.card, borderRadius: BorderRadius.circular(20)),
                    child: Text(text.goalsCount(entry.value.length), style: _LadnaText.micro),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _UserGoalTile extends StatelessWidget {
  final UserGoal goal;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _UserGoalTile({
    required this.goal,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _blockColor(goal.lifeBlock);
    final text = _GoalsText.of(context);
    final progress = goal.isCompleted ? 1.0 : _fakeProgress(goal);

    return GestureDetector(
      onTap: onTap,
      child: _Card(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggle,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: goal.isCompleted ? _LadnaColors.green : color,
                          shape: BoxShape.circle,
                        ),
                        child: goal.isCompleted
                            ? Icon(Icons.check_rounded, size: 10, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_horizonLabel(text, goal.horizon), style: _LadnaText.microUpper),
                      const SizedBox(height: 2),
                      Text(
                        goal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _LadnaText.bodyTitle.copyWith(
                          decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                          color: goal.isCompleted ? _LadnaColors.muted : _LadnaColors.dark,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onDelete,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE35B5B).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: Color(0xFFE35B5B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded, size: 18, color: _LadnaColors.muted),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(text.progress, style: _LadnaText.caption),
                const Spacer(),
                Text('${(progress * 100).round()}%', style: _LadnaText.caption.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 5),
            _Progress(value: progress, color: color),
          ],
        ),
      ),
    );
  }

  double _fakeProgress(UserGoal goal) {
    if (goal.targetDate == null) return .35;
    final now = DateUtils.dateOnly(DateTime.now());
    final created = DateUtils.dateOnly(goal.createdAt);
    final target = DateUtils.dateOnly(goal.targetDate!);
    final total = target.difference(created).inDays.abs();
    if (total <= 0) return .5;
    final passed = now.difference(created).inDays.clamp(0, total);
    return (passed / total).clamp(0.05, .95).toDouble();
  }
}

class _UserGoalEditorSheet extends StatefulWidget {
  final List<String> availableBlocks;
  final UserGoal? initial;

  const _UserGoalEditorSheet({
    required this.availableBlocks,
    this.initial,
  });

  @override
  State<_UserGoalEditorSheet> createState() => _UserGoalEditorSheetState();
}

class _UserGoalEditorSheetState extends State<_UserGoalEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late String _block;
  late GoalHorizon _horizon;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _description = TextEditingController(text: widget.initial?.description ?? '');
    _block = widget.initial?.lifeBlock ??
        (widget.availableBlocks.isNotEmpty ? widget.availableBlocks.first : 'career');
    _horizon = widget.initial?.horizon ?? GoalHorizon.mid;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) return;

    Navigator.pop(
      context,
      UserGoalUpsert(
        id: widget.initial?.id,
        lifeBlock: _block,
        horizon: _horizon,
        title: title,
        description: _description.text.trim().isEmpty ? null : _description.text.trim(),
        targetDate: widget.initial?.targetDate,
        isCompleted: widget.initial?.isCompleted ?? false,
        completedAt: widget.initial?.completedAt,
        sortOrder: widget.initial?.sortOrder ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = _GoalsText.of(context);
    final blocks = widget.availableBlocks.isEmpty ? const ['career', 'finance', 'education', 'family'] : widget.availableBlocks;

    return _Sheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          Text(widget.initial == null ? text.newGoal : text.editGoal, style: _LadnaText.serifTitle.copyWith(fontSize: 22)),
          const SizedBox(height: 16),
          _Input(controller: _title, label: text.title),
          const SizedBox(height: 10),
          _Input(controller: _description, label: text.description, maxLines: 3),
          const SizedBox(height: 14),
          Text(text.sphere, style: _LadnaText.microUpper),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: blocks.map((b) {
              final selected = b == _block;
              return _Chip(
                label: _lifeBlockLabel(context, b),
                selected: selected,
                onTap: () => setState(() => _block = b),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(text.horizon, style: _LadnaText.microUpper),
          const SizedBox(height: 8),
          _Segmented<GoalHorizon>(
            value: _horizon,
            items: [
              _SegmentItem(GoalHorizon.tactical, text.upToOneMonth),
              _SegmentItem(GoalHorizon.mid, text.upToSixMonths),
              _SegmentItem(GoalHorizon.long, text.yearPlus),
            ],
            dense: true,
            onChanged: (v) => setState(() => _horizon = v),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: _LadnaColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(text.save, style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

enum _BottomItem { home, goals, menu, personal, reports }

class _BottomNav extends StatelessWidget {
  final _BottomItem active;
  const _BottomNav({required this.active});

  @override
  Widget build(BuildContext context) {
    final text = _GoalsText.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 78 + bottom,
      padding: EdgeInsets.only(top: 9, bottom: bottom),
      decoration: BoxDecoration(
        color: _ladnaAdaptive(const Color(0xF7F7F3EC), const Color(0xF7100C1E)),
        border: Border(top: BorderSide(color: _LadnaColors.border.withOpacity(.8))),
        boxShadow: const [BoxShadow(color: Color(0x14160E38), blurRadius: 18, offset: Offset(0, -6))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NavItem(icon: Icons.home_rounded, label: text.home, active: active == _BottomItem.home, onTap: () => Navigator.maybePop(context)),
          _NavItem(icon: Icons.track_changes_rounded, label: text.goals, active: active == _BottomItem.goals, onTap: () {}),
          _CenterMenu(label: text.menu),
          _NavItem(icon: Icons.favorite_rounded, label: text.personal, active: active == _BottomItem.personal, onTap: () {}),
          _NavItem(icon: Icons.bar_chart_rounded, label: text.reports, active: active == _BottomItem.reports, onTap: () {}),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? _LadnaColors.primary : _LadnaColors.muted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 3),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, fontWeight: active ? FontWeight.w800 : FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}

class _CenterMenu extends StatelessWidget {
  final String label;
  const _CenterMenu({required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 46,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_LadnaColors.primary, Color(0xFFE8B854)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x736B54C0), blurRadius: 10, offset: Offset(0, 2))],
            ),
            child: const Center(child: Text('✦', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _LadnaColors.primary)),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: _LadnaColors.card, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: _LadnaColors.mid),
        ),
      );
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _LadnaColors.primary.withOpacity(.12),
            shape: BoxShape.circle,
            border: Border.all(color: _LadnaColors.primary.withOpacity(.2)),
          ),
          child: Icon(icon, size: 20, color: _LadnaColors.mid),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(3, 2, 0, 8),
        child: Text(text.toUpperCase(), style: _LadnaText.microUpper),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const _Card({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        padding: padding,
        decoration: _LadnaDecor.card,
        child: child,
      );
}

class _EmptyCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => _Card(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.track_changes_rounded, color: _LadnaColors.primary, size: 30),
            const SizedBox(height: 8),
            Text(title, style: _LadnaText.cardTitle),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: _LadnaText.caption),
          ],
        ),
      );
}

class _Progress extends StatelessWidget {
  final double value;
  final Color color;

  const _Progress({
    required this.value,
    this.color = const Color(0xFF6B54C0),
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          minHeight: 6,
          value: value.clamp(0.0, 1.0).toDouble(),
          backgroundColor: _LadnaColors.card,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      );
}

class _Fab extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _Fab({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: _LadnaColors.primary,
            borderRadius: BorderRadius.circular(13),
            boxShadow: const [BoxShadow(color: Color(0x736B54C0), blurRadius: 14, offset: Offset(0, 4))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 19),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
}

class _Sheet extends StatelessWidget {
  final Widget child;
  const _Sheet({required this.child});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottom),
      decoration: BoxDecoration(
        color: _LadnaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(child: child),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: _LadnaColors.dark.withOpacity(.15), borderRadius: BorderRadius.circular(99)),
        ),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? _LadnaColors.primary : _LadnaColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? _LadnaColors.primary : _LadnaColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : _LadnaColors.mid),
          ),
        ),
      );
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _Input({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: _LadnaColors.surfaceLight,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _LadnaColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _LadnaColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _LadnaColors.primary, width: 1.4)),
        ),
      );
}

String _weekdayShort(BuildContext context, DateTime date) {
  final l = Localizations.localeOf(context).languageCode;
  const ru = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const de = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  const fr = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  const es = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  const tr = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  final map = {
    'ru': ru,
    'en': en,
    'de': de,
    'fr': fr,
    'es': es,
    'tr': tr,
  };
  return (map[l] ?? en)[date.weekday - 1];
}

String _lifeBlockLabel(BuildContext context, String key) {
  final text = _GoalsText.of(context);
  switch (key.trim().toLowerCase()) {
    case 'health':
      return text.health;
    case 'career':
      return text.career;
    case 'family':
      return text.family;
    case 'finance':
      return text.finance;
    case 'education':
      return text.education;
    case 'hobbies':
    case 'hobby':
      return text.hobbies;
    case 'general':
      return text.general;
    default:
      return key.isEmpty ? text.general : key;
  }
}

String _horizonLabel(_GoalsText text, GoalHorizon horizon) {
  switch (horizon) {
    case GoalHorizon.tactical:
      return text.upToOneMonth;
    case GoalHorizon.mid:
      return text.upToSixMonths;
    case GoalHorizon.long:
      return text.yearPlus;
  }
}

Color _blockColor(String key) {
  switch (key.trim().toLowerCase()) {
    case 'career':
      return _LadnaColors.coral;
    case 'finance':
      return _LadnaColors.green;
    case 'education':
      return _LadnaColors.primary;
    case 'family':
      return _LadnaColors.mid;
    case 'health':
      return const Color(0xFFEB9898);
    case 'hobbies':
    case 'hobby':
      return const Color(0xFF825ABE);
    default:
      return _LadnaColors.primary;
  }
}

class _LadnaColors {
  static Color get page => _ladnaAdaptive(const Color(0xFFD6D0EC), const Color(0xFF100C1E));
  static Color get surface => _ladnaAdaptive(const Color(0xFFF5F3FA), const Color(0xFF100C1E));
  static Color get surfaceLight => _ladnaAdaptive(const Color(0xFFFAFAFE), const Color(0xFF1C1630));
  static Color get card => _ladnaAdaptive(const Color(0xFFEAE6F5), const Color(0xFF1C1630));
  static Color get border => _ladnaAdaptive(const Color(0xFFE0DCF0), const Color(0x2E6B54C0));
  static Color get primary => const Color(0xFF6B54C0);
  static Color get dark => _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF));
  static Color get mid => _ladnaAdaptive(const Color(0xFF555268), const Color(0x99FFFFFF));
  static Color get muted => _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x4DFFFFFF));
  static Color get green => const Color(0xFF16B8A8);
  static Color get coral => const Color(0xFFD4E040);
}

class _LadnaDecor {
  static BoxDecoration get header => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        _ladnaAdaptive(const Color(0xFFF0EEF8), const Color(0x1F6B54C0)),
        _ladnaAdaptive(const Color(0xFFE6E2F4), const Color(0x1F6B54C0)),
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: _LadnaColors.primary.withOpacity(_ladnaDarkMode ? .25 : .15)),
    boxShadow: shadow,
  );

  static BoxDecoration get card => BoxDecoration(
    color: _LadnaColors.surfaceLight,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: _LadnaColors.primary.withOpacity(_ladnaDarkMode ? .18 : .10)),
    boxShadow: shadow,
  );

  static List<BoxShadow> get shadow => [
    BoxShadow(
      color: Colors.black.withOpacity(_ladnaDarkMode ? 0.30 : 0.07),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];
}

class _LadnaText {
  static final serifTitle = TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: _LadnaColors.dark,
    letterSpacing: -.2,
  );

  static final serifNumber = TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: _LadnaColors.dark,
    height: 1,
  );

  static final cardTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: _LadnaColors.dark,
  );

  static final bodyTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: _LadnaColors.dark,
    height: 1.35,
  );

  static final bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: _LadnaColors.mid,
  );

  static final caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: _LadnaColors.muted,
  );

  static final micro = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: _LadnaColors.muted,
  );

  static final microUpper = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: _LadnaColors.muted,
    letterSpacing: 1.1,
  );
}

class _GoalsText {
  final String code;
  const _GoalsText(this.code);

  static _GoalsText of(BuildContext context) =>
      _GoalsText(Localizations.localeOf(context).languageCode);

  String pick(Map<String, String> values) => values[code] ?? values['en'] ?? values.values.first;

  String get goalsAndTasks => pick({'ru':'Цели и задачи','en':'Goals & Tasks','de':'Ziele & Aufgaben','fr':'Objectifs et tâches','es':'Metas y tareas','tr':'Hedefler ve görevler'});
  String get tasks => pick({'ru':'Задачи','en':'Tasks','de':'Aufgaben','fr':'Tâches','es':'Tareas','tr':'Görevler'});
  String get goals => pick({'ru':'Цели','en':'Goals','de':'Ziele','fr':'Objectifs','es':'Metas','tr':'Hedefler'});
  String get dashboard => pick({'ru':'Дашборд','en':'Dashboard','de':'Dashboard','fr':'Tableau','es':'Panel','tr':'Panel'});
  String get week => pick({'ru':'Неделя','en':'Week','de':'Woche','fr':'Semaine','es':'Semana','tr':'Hafta'});
  String get month => pick({'ru':'Месяц','en':'Month','de':'Monat','fr':'Mois','es':'Mes','tr':'Ay'});
  String get calendar => pick({'ru':'Календарь','en':'Calendar','de':'Kalender','fr':'Calendrier','es':'Calendario','tr':'Takvim'});
  String get weekView => pick({'ru':'Неделя','en':'Week view','de':'Wochenansicht','fr':'Vue semaine','es':'Vista semanal','tr':'Hafta görünümü'});
  String get monthView => pick({'ru':'Дни месяца','en':'Month days','de':'Monatstage','fr':'Jours du mois','es':'Días del mes','tr':'Ay günleri'});
  String get noTasks => pick({'ru':'Нет задач','en':'No tasks','de':'Keine Aufgaben','fr':'Aucune tâche','es':'Sin tareas','tr':'Görev yok'});
  String get completed => pick({'ru':'выполнено','en':'completed','de':'erledigt','fr':'terminé','es':'completado','tr':'tamamlandı'});
  String get weekSummary => pick({'ru':'Итог недели','en':'Week summary','de':'Wochenbilanz','fr':'Bilan de la semaine','es':'Resumen semanal','tr':'Hafta özeti'});
  String get hoursShort => pick({'ru':'ч','en':'h','de':'Std.','fr':'h','es':'h','tr':'s'});
  String get thisWeek => pick({'ru':'Эта неделя','en':'This week','de':'Diese Woche','fr':'Cette semaine','es':'Esta semana','tr':'Bu hafta'});
  String get todayShort => pick({'ru':'сег','en':'today','de':'heute','fr':'auj.','es':'hoy','tr':'bugün'});
  String get all => pick({'ru':'Все','en':'All','de':'Alle','fr':'Tous','es':'Todo','tr':'Tümü'});
  String get upToOneMonth => pick({'ru':'До 1 мес','en':'Up to 1 mo','de':'Bis 1 Mon.','fr':'Jusq. 1 mois','es':'Hasta 1 mes','tr':'1 aya kadar'});
  String get upToSixMonths => pick({'ru':'До 6 мес','en':'Up to 6 mo','de':'Bis 6 Mon.','fr':'Jusq. 6 mois','es':'Hasta 6 meses','tr':'6 aya kadar'});
  String get yearPlus => pick({'ru':'На год+','en':'Year+','de':'1 Jahr+','fr':'1 an+','es':'Año+','tr':'1 yıl+'});
  String get bySpheres => pick({'ru':'По сферам','en':'By spheres','de':'Nach Bereichen','fr':'Par domaines','es':'Por áreas','tr':'Alanlara göre'});
  String get hide => pick({'ru':'Скрыть','en':'Hide','de':'Ausblenden','fr':'Masquer','es':'Ocultar','tr':'Gizle'});
  String get progress => pick({'ru':'Прогресс','en':'Progress','de':'Fortschritt','fr':'Progrès','es':'Progreso','tr':'İlerleme'});
  String get add => pick({'ru':'Добавить','en':'Add','de':'Hinzufügen','fr':'Ajouter','es':'Añadir','tr':'Ekle'});
  String get home => pick({'ru':'Главная','en':'Home','de':'Start','fr':'Accueil','es':'Inicio','tr':'Ana'});
  String get menu => pick({'ru':'Меню','en':'Menu','de':'Menü','fr':'Menu','es':'Menú','tr':'Menü'});
  String get personal => pick({'ru':'Личное','en':'Personal','de':'Persönlich','fr':'Personnel','es':'Personal','tr':'Kişisel'});
  String get reports => pick({'ru':'Отчёты','en':'Reports','de':'Berichte','fr':'Rapports','es':'Informes','tr':'Raporlar'});
  String get health => pick({'ru':'Здоровье','en':'Health','de':'Gesundheit','fr':'Santé','es':'Salud','tr':'Sağlık'});
  String get career => pick({'ru':'Карьера','en':'Career','de':'Karriere','fr':'Carrière','es':'Carrera','tr':'Kariyer'});
  String get family => pick({'ru':'Семья','en':'Family','de':'Familie','fr':'Famille','es':'Familia','tr':'Aile'});
  String get finance => pick({'ru':'Финансы','en':'Finance','de':'Finanzen','fr':'Finance','es':'Finanzas','tr':'Finans'});
  String get education => pick({'ru':'Образование','en':'Education','de':'Bildung','fr':'Éducation','es':'Educación','tr':'Eğitim'});
  String get hobbies => pick({'ru':'Хобби','en':'Hobbies','de':'Hobbys','fr':'Loisirs','es':'Aficiones','tr':'Hobiler'});
  String get general => pick({'ru':'Общее','en':'General','de':'Allgemein','fr':'Général','es':'General','tr':'Genel'});
  String get noGoalsYet => pick({'ru':'Целей пока нет','en':'No goals yet','de':'Noch keine Ziele','fr':'Aucun objectif','es':'Sin metas todavía','tr':'Henüz hedef yok'});
  String get noGoalsYetSub => pick({'ru':'Добавь первую цель через кнопку ниже.','en':'Add your first goal with the button below.','de':'Füge unten dein erstes Ziel hinzu.','fr':'Ajoute ton premier objectif avec le bouton ci-dessous.','es':'Añade tu primera meta con el botón inferior.','tr':'Aşağıdaki düğmeyle ilk hedefini ekle.'});
  String get newGoal => pick({'ru':'Новая цель','en':'New goal','de':'Neues Ziel','fr':'Nouvel objectif','es':'Nueva meta','tr':'Yeni hedef'});
  String get editGoal => pick({'ru':'Редактировать цель','en':'Edit goal','de':'Ziel bearbeiten','fr':'Modifier l’objectif','es':'Editar meta','tr':'Hedefi düzenle'});
  String get title => pick({'ru':'Название','en':'Title','de':'Titel','fr':'Titre','es':'Título','tr':'Başlık'});
  String get description => pick({'ru':'Описание','en':'Description','de':'Beschreibung','fr':'Description','es':'Descripción','tr':'Açıklama'});
  String get sphere => pick({'ru':'Сфера','en':'Sphere','de':'Bereich','fr':'Domaine','es':'Área','tr':'Alan'});
  String get horizon => pick({'ru':'Горизонт','en':'Horizon','de':'Horizont','fr':'Horizon','es':'Horizonte','tr':'Ufuk'});
  String get save => pick({'ru':'Сохранить','en':'Save','de':'Speichern','fr':'Enregistrer','es':'Guardar','tr':'Kaydet'});
  String get deleteGoal => pick({'ru':'Удалить цель','en':'Delete goal','de':'Ziel löschen','fr':'Supprimer l’objectif','es':'Eliminar meta','tr':'Hedefi sil'});
  String get deleteGoalQuestion => pick({'ru':'Эта цель будет удалена. Связанные ежедневные задачи останутся без связи с большой целью.','en':'This goal will be deleted. Related daily tasks will stay, but without a big-goal link.','de':'Dieses Ziel wird gelöscht. Verknüpfte Tagesaufgaben bleiben ohne Ziel-Verknüpfung erhalten.','fr':'Cet objectif sera supprimé. Les tâches quotidiennes liées resteront sans lien avec un grand objectif.','es':'Esta meta se eliminará. Las tareas diarias relacionadas quedarán sin vínculo con una meta grande.','tr':'Bu hedef silinecek. İlgili günlük görevler kalır, ancak büyük hedef bağlantısı olmadan.'});
  String get cancel => pick({'ru':'Отмена','en':'Cancel','de':'Abbrechen','fr':'Annuler','es':'Cancelar','tr':'İptal'});
  String get delete => pick({'ru':'Удалить','en':'Delete','de':'Löschen','fr':'Supprimer','es':'Eliminar','tr':'Sil'});

  String completedTasks(int done, int total) => pick({
    'ru':'$done задач выполнено из $total',
    'en':'$done tasks completed out of $total',
    'de':'$done von $total Aufgaben erledigt',
    'fr':'$done tâches terminées sur $total',
    'es':'$done tareas completadas de $total',
    'tr':'$total görevden $done tamamlandı',
  });

  String goalsCount(int n) => pick({
    'ru':'$n цели',
    'en':'$n goals',
    'de':'$n Ziele',
    'fr':'$n objectifs',
    'es':'$n metas',
    'tr':'$n hedef',
  });
}
