// lib/screens/day_goals_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../main.dart';
import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../widgets/add_day_goal_sheet.dart';
import '../widgets/edit_goal_sheet.dart';
import '../widgets/import_journal.dart';
import '../widgets/day_google_calendar_sync_sheet.dart';
import '../widgets/recurring_goal_sheet.dart';

/// запуск: flutter run -d chrome --dart-define=VISION_API_KEY=xxxxx
const String _kVisionApiKey = String.fromEnvironment(
  'VISION_API_KEY',
  defaultValue: '',
);

class DayGoalsScreen extends StatelessWidget {
  final DateTime date;
  final String? lifeBlock;
  final List<String> availableBlocks;

  const DayGoalsScreen({
    super.key,
    required this.date,
    required this.lifeBlock,
    this.availableBlocks = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DayGoalsModel(
        date: date,
        lifeBlock: lifeBlock,
        availableBlocks: availableBlocks,
      )..load(),
      child: const _DayGoalsView(),
    );
  }
}

class _DayGoalsView extends StatefulWidget {
  const _DayGoalsView();

  @override
  State<_DayGoalsView> createState() => _DayGoalsViewState();
}

class _DayGoalsViewState extends State<_DayGoalsView> {
  final _scroll = ScrollController();
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _summaryKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();

  bool _busy = false;
  bool _hideCompleted = false;
  final Set<_DaySection> _expandedSections = {..._DaySection.values};

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _withBusy(Future<void> Function() fn) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await fn();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openAdd() async {
    final vm = context.read<DayGoalsModel>();

    final res = await showModalBottomSheet<AddGoalResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NestSheet(
        child: AddDayGoalSheet(
          fixedLifeBlock: vm.lifeBlock,
          availableBlocks: vm.availableBlocks,
        ),
      ),
    );

    if (res == null) return;

    await _withBusy(() async {
      try {
        await vm.createGoal(
          title: res.title,
          description: res.description,
          lifeBlockValue: res.lifeBlock,
          importance: res.importance,
          emotion: res.emotion,
          hours: res.hours,
          startTime: res.startTime,
          userGoalId: res.userGoalId,
        );

        await vm.load();

        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 120));
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          );
        }
      } catch (e) {
        final l = AppLocalizations.of(context)!;
        _snack(l.dayGoalsAddFailed(e.toString()));
      }
    });
  }



  Future<void> _openRecurring() async {
    final vm = context.read<DayGoalsModel>();

    final plan = await showModalBottomSheet<RecurringGoalPlan>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NestSheet(
        child: const RecurringGoalSheet(),
      ),
    );

    if (plan == null) return;

    final dates = _buildRecurringDates(plan, DateUtils.dateOnly(vm.date));
    if (dates.isEmpty) {
      final l = AppLocalizations.of(context)!;
      _snack(_dgRecurringEmptyMessage(l.localeName));
      return;
    }

    await _withBusy(() async {
      try {
        await dbRepo.createGoalsBulk(
          dates.map((day) {
            final deadline = DateTime.utc(day.year, day.month, day.day);
            final startTime = DateTime.utc(
              day.year,
              day.month,
              day.day,
              plan.time.hour,
              plan.time.minute,
            );

            return <String, dynamic>{
              'title': plan.title,
              'description': '',
              'deadline': deadline,
              'is_completed': false,
              'life_block': plan.lifeBlock,
              'importance': plan.importance,
              'emotion': plan.emotion,
              'spent_hours': plan.plannedHours,
              'start_time': startTime,
              'user_goal_id': plan.userGoalId,
            };
          }).toList(),
        );

        await vm.load();

        if (!mounted) return;
        final l = AppLocalizations.of(context)!;
        _snack(_dgRecurringCreatedMessage(l.localeName, dates.length));
      } catch (e) {
        final l = AppLocalizations.of(context)!;
        _snack(l.dayGoalsAddFailed(e.toString()));
      }
    });
  }

  List<DateTime> _buildRecurringDates(
    RecurringGoalPlan plan,
    DateTime startDate,
  ) {
    final start = DateUtils.dateOnly(startDate);
    final until = DateUtils.dateOnly(plan.until);
    if (until.isBefore(start)) return const [];

    final result = <DateTime>[];

    if (plan.type == RecurrenceType.everyNDays) {
      final step = plan.everyNDays <= 0 ? 1 : plan.everyNDays;
      var current = start;
      while (!current.isAfter(until)) {
        result.add(current);
        current = current.add(Duration(days: step));
      }
      return result;
    }

    var current = start;
    while (!current.isAfter(until)) {
      if (plan.weekdays.contains(current.weekday)) {
        result.add(current);
      }
      current = current.add(const Duration(days: 1));
    }
    return result;
  }

  Future<void> _openEdit(Goal g) async {
    final vm = context.read<DayGoalsModel>();

    final res = await showModalBottomSheet<AddGoalResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NestSheet(
        child: EditGoalSheet(
          goal: g,
          fixedLifeBlock: vm.lifeBlock,
          availableBlocks: vm.availableBlocks,
          initialUserGoalId: g.userGoalId,
        ),
      ),
    );

    if (res == null) return;

    await _withBusy(() async {
      try {
        await vm.updateGoal(
          id: g.id,
          title: res.title,
          description: res.description,
          lifeBlockValue: res.lifeBlock,
          importance: res.importance,
          emotion: res.emotion,
          hours: res.hours,
          startTime: res.startTime,
          userGoalId: res.userGoalId,
        );

        await vm.load();

        final l = AppLocalizations.of(context)!;
        _snack(l.dayGoalsUpdated);
      } catch (e) {
        final l = AppLocalizations.of(context)!;
        _snack(l.dayGoalsUpdateFailed(e.toString()));
      }
    });
  }

  Future<void> _confirmAndDelete(Goal g) async {
    final l = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.dayGoalsDeleteConfirmTitle),
        content: Text('“${g.title}”'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final vm = context.read<DayGoalsModel>();

    await _withBusy(() async {
      try {
        await vm.deleteGoal(g.id);
        final l = AppLocalizations.of(context)!;
        _snack(l.dayGoalsDeleted);
      } catch (e) {
        final l = AppLocalizations.of(context)!;
        _snack(l.dayGoalsDeleteFailed(e.toString()));
      }
    });
  }

  Future<void> _toggleComplete(Goal g) async {
    final vm = context.read<DayGoalsModel>();
    await _withBusy(() async {
      try {
        await vm.toggleComplete(g);
        await vm.load();
      } catch (e) {
        final l = AppLocalizations.of(context)!;
        _snack(l.dayGoalsToggleFailed(e.toString()));
      }
    });
  }

  Future<void> _openGoogleCalendarSync() async {
    final vm = context.read<DayGoalsModel>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _NestSheet(child: DayGoogleCalendarSyncSheet(date: vm.date)),
    );

    await _withBusy(() async {
      try {
        await vm.load();
      } catch (_) {}
    });
  }

  void _onScanPressed() {
    if (_busy) return;
    final vm = context.read<DayGoalsModel>();
    importFromJournal(context, vm, visionApiKey: _kVisionApiKey);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final vm = context.watch<DayGoalsModel>();
    final title = vm.lifeBlock ?? l.dayGoalsAllLifeBlocks;

    final allGoals = [...vm.goals]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final visibleGoals =
        _hideCompleted ? allGoals.where((g) => !g.isCompleted).toList() : allGoals;

    final grouped = _groupGoalsByTimeOfDay(visibleGoals);

    final totalGoals = allGoals.length;
    final completedGoals = allGoals.where((g) => g.isCompleted).length;
    final remainingGoals = totalGoals - completedGoals;
    final remainingHours = allGoals
        .where((g) => !g.isCompleted)
        .fold<double>(0, (sum, g) => sum + g.hours);

    final progress = totalGoals == 0 ? 0.0 : completedGoals / totalGoals;

    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text('${vm.formattedDate}  •  $title'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          floatingActionButton: _MainFab(
            key: _fabKey,
            onAdd: () {
              if (_busy) return;
              _openAdd();
            },
            onRecurring: () {
              if (_busy) return;
              _openRecurring();
            },
            onScan: () {
              if (_busy) return;
              _onScanPressed();
            },
            onCalendar: () {
              if (_busy) return;
              _openGoogleCalendarSync();
            },
          ),
          body: Stack(
            children: [
              const _NestBackground(),
              SafeArea(
                child: vm.loading
                    ? const Center(child: CircularProgressIndicator())
                    : visibleGoals.isEmpty
                        ? _NestEmptyState(
                            message: totalGoals > 0 && _hideCompleted
                                ? 'Все видимые цели скрыты. Отключи фильтр «Скрыть выполненные».'
                                : l.dayGoalsEmpty,
                          )
                        : ListView(
                            controller: _scroll,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 116),
                            children: [
                              _DaySummaryCard(
                                key: _summaryKey,
                                totalGoals: totalGoals,
                                completedGoals: completedGoals,
                                remainingGoals: remainingGoals,
                                remainingHours: remainingHours,
                                progress: progress,
                              ),
                              const SizedBox(height: 12),
                              _HideCompletedToggle(
                                key: _filterKey,
                                value: _hideCompleted,
                                onChanged: (v) {
                                  setState(() => _hideCompleted = v);
                                },
                              ),
                              const SizedBox(height: 18),
                              ..._buildSections(grouped),
                            ],
                          ),
              ),
            ],
          ),
        ),
        if (_busy)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(0.04),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildSections(Map<_DaySection, List<Goal>> grouped) {
    final sections = <Widget>[];

    for (final section in _DaySection.values) {
      final items = grouped[section] ?? const <Goal>[];
      if (items.isEmpty) continue;

      final expanded = _expandedSections.contains(section);
      final openItems = items.where((g) => !g.isCompleted).toList();
      final doneItems = items.where((g) => g.isCompleted).toList();

      sections.add(
        _KanbanDaySection(
          section: section,
          goals: items,
          openGoals: openItems,
          doneGoals: doneItems,
          expanded: expanded,
          onToggleExpanded: () {
            setState(() {
              if (expanded) {
                _expandedSections.remove(section);
              } else {
                _expandedSections.add(section);
              }
            });
          },
          onToggleGoal: _toggleComplete,
          onDelete: _confirmAndDelete,
          onEdit: _openEdit,
          onMoveToDoneState: (goal, done) {
            if (goal.isCompleted == done) return;
            _toggleComplete(goal);
          },
        ),
      );
      sections.add(const SizedBox(height: 14));
    }

    return sections;
  }

  Map<_DaySection, List<Goal>> _groupGoalsByTimeOfDay(List<Goal> goals) {
    final map = <_DaySection, List<Goal>>{
      _DaySection.morning: [],
      _DaySection.day: [],
      _DaySection.evening: [],
    };

    for (final g in goals) {
      final hour = g.startTime.hour;
      if (hour < 12) {
        map[_DaySection.morning]!.add(g);
      } else if (hour < 18) {
        map[_DaySection.day]!.add(g);
      } else {
        map[_DaySection.evening]!.add(g);
      }
    }

    return map;
  }
}

enum _DaySection { morning, day, evening }


Color _dgCardColor(BuildContext context, {double lightOpacity = 0.72}) {
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  if (isDark) {
    return Color.lerp(
      scheme.surfaceContainerLow,
      scheme.primary,
      0.035,
    )!.withOpacity(0.94);
  }

  return Colors.white.withOpacity(lightOpacity);
}

Color _dgInnerCardColor(BuildContext context, {double lightOpacity = 0.72}) {
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  if (isDark) {
    return Color.lerp(
      scheme.surfaceContainer,
      scheme.primary,
      0.04,
    )!.withOpacity(0.96);
  }

  return const Color(0xFFF4FAFF).withOpacity(lightOpacity);
}

Color _dgBorder(BuildContext context, [Color? accent]) {
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Color.lerp(
    scheme.outlineVariant,
    accent ?? scheme.primary,
    isDark ? 0.16 : 0.06,
  )!;
}

Color _dgText(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface;
}

Color _dgMuted(BuildContext context) {
  return Theme.of(context).colorScheme.onSurfaceVariant;
}

Color _dgPrimary(BuildContext context) {
  return Theme.of(context).colorScheme.primary;
}

Color _dgSuccess(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? const Color(0xFF46E08D) : const Color(0xFF22C55E);
}

Color _dgWarning(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? const Color(0xFFFFD166) : const Color(0xFFF59E0B);
}

Color _dgDanger(BuildContext context) {
  return Theme.of(context).colorScheme.error;
}

List<BoxShadow> _dgShadow(BuildContext context, {bool top = false}) {
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return [
    BoxShadow(
      color: isDark ? Colors.black.withOpacity(0.24) : scheme.primary.withOpacity(0.07),
      blurRadius: isDark ? 18 : 24,
      offset: Offset(0, top ? -6 : 12),
    ),
  ];
}


class _KanbanDaySection extends StatelessWidget {
  final _DaySection section;
  final List<Goal> goals;
  final List<Goal> openGoals;
  final List<Goal> doneGoals;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final Future<void> Function(Goal goal) onToggleGoal;
  final Future<void> Function(Goal goal) onDelete;
  final Future<void> Function(Goal goal) onEdit;
  final void Function(Goal goal, bool done) onMoveToDoneState;

  const _KanbanDaySection({
    required this.section,
    required this.goals,
    required this.openGoals,
    required this.doneGoals,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onToggleGoal,
    required this.onDelete,
    required this.onEdit,
    required this.onMoveToDoneState,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _sectionMeta(context, section);

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: _dgCardColor(context, lightOpacity: 0.58),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: _dgBorder(context)),
            boxShadow: _dgShadow(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: onToggleExpanded,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Row(
                      children: [
                        AnimatedRotation(
                          turns: expanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: meta.accent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: meta.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: meta.accent.withOpacity(0.18)),
                          ),
                          child: Icon(meta.icon, color: meta.accent, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${meta.title} (${goals.length})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: _dgText(context),
                                ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _MiniCounter(label: AppLocalizations.of(context)!.dayGoalsKanbanOpenShort, value: openGoals.length, accent: _dgWarning(context)),
                                const SizedBox(width: 6),
                                _MiniCounter(label: AppLocalizations.of(context)!.dayGoalsKanbanDoneShort, value: doneGoals.length, accent: _dgSuccess(context)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                  child: _KanbanBoard(
                    openGoals: openGoals,
                    doneGoals: doneGoals,
                    accent: meta.accent,
                    onToggleGoal: onToggleGoal,
                    onDelete: onDelete,
                    onEdit: onEdit,
                    onMoveToDoneState: onMoveToDoneState,
                  ),
                ),
                crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 220),
                sizeCurve: Curves.easeOutCubic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KanbanBoard extends StatelessWidget {
  final List<Goal> openGoals;
  final List<Goal> doneGoals;
  final Color accent;
  final Future<void> Function(Goal goal) onToggleGoal;
  final Future<void> Function(Goal goal) onDelete;
  final Future<void> Function(Goal goal) onEdit;
  final void Function(Goal goal, bool done) onMoveToDoneState;

  const _KanbanBoard({
    required this.openGoals,
    required this.doneGoals,
    required this.accent,
    required this.onToggleGoal,
    required this.onDelete,
    required this.onEdit,
    required this.onMoveToDoneState,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final openColumn = _KanbanColumn(
          title: l.dayGoalsKanbanOpenTitle,
          subtitle: '${openGoals.length}',
          icon: Icons.bolt_rounded,
          accent: accent,
          goals: openGoals,
          doneColumn: false,
          emptyText: l.dayGoalsKanbanOpenEmpty,
          onToggleGoal: onToggleGoal,
          onDelete: onDelete,
          onEdit: onEdit,
          onMoveToDoneState: onMoveToDoneState,
        );

        final doneColumn = _KanbanColumn(
          title: l.dayGoalsKanbanDoneTitle,
          subtitle: '${doneGoals.length}',
          icon: Icons.check_circle_rounded,
          accent: _dgSuccess(context),
          goals: doneGoals,
          doneColumn: true,
          emptyText: l.dayGoalsKanbanDoneEmpty,
          onToggleGoal: onToggleGoal,
          onDelete: onDelete,
          onEdit: onEdit,
          onMoveToDoneState: onMoveToDoneState,
        );

        if (constraints.maxWidth < 340) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              openColumn,
              const SizedBox(height: 10),
              doneColumn,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: openColumn),
            const SizedBox(width: 8),
            Expanded(child: doneColumn),
          ],
        );
      },
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<Goal> goals;
  final bool doneColumn;
  final String emptyText;
  final Future<void> Function(Goal goal) onToggleGoal;
  final Future<void> Function(Goal goal) onDelete;
  final Future<void> Function(Goal goal) onEdit;
  final void Function(Goal goal, bool done) onMoveToDoneState;

  const _KanbanColumn({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.goals,
    required this.doneColumn,
    required this.emptyText,
    required this.onToggleGoal,
    required this.onDelete,
    required this.onEdit,
    required this.onMoveToDoneState,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Goal>(
      onWillAccept: (goal) => goal != null && goal.isCompleted != doneColumn,
      onAccept: (goal) => onMoveToDoneState(goal, doneColumn),
      builder: (context, candidate, rejected) {
        final isActiveDrop = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minHeight: 132),
          decoration: BoxDecoration(
            color: isActiveDrop ? accent.withOpacity(0.12) : _dgInnerCardColor(context, lightOpacity: 0.72).withOpacity(0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isActiveDrop ? accent.withOpacity(0.42) : _dgBorder(context),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 17, color: accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: _dgText(context),
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: _dgText(context),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (goals.isEmpty)
                _KanbanEmptyHint(text: emptyText)
              else
                ...goals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Draggable<Goal>(
                      data: goal,
                      affinity: Axis.horizontal,
                      dragAnchorStrategy: pointerDragAnchorStrategy,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Transform.scale(
                          scale: 1.03,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 190),
                            child: _KanbanGoalCard(
                              goal: goal,
                              compact: true,
                              dragging: true,
                              onToggle: () {},
                              onEdit: () {},
                              onDelete: () {},
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.28,
                        child: _KanbanGoalCard(
                          goal: goal,
                          onToggle: () => onToggleGoal(goal),
                          onEdit: () => onEdit(goal),
                          onDelete: () => onDelete(goal),
                        ),
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.move,
                        child: _KanbanGoalCard(
                          goal: goal,
                          onToggle: () => onToggleGoal(goal),
                          onEdit: () => onEdit(goal),
                          onDelete: () => onDelete(goal),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _KanbanGoalCard extends StatelessWidget {
  final Goal goal;
  final bool compact;
  final bool dragging;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _KanbanGoalCard({
    required this.goal,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.compact = false,
    this.dragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final time = _formatGoalTime(goal.startTime);
    final isDone = goal.isCompleted;

    return Container(
      padding: EdgeInsets.fromLTRB(10, compact ? 9 : 10, 8, compact ? 9 : 10),
      decoration: BoxDecoration(
        color: _dgCardColor(context, lightOpacity: isDone ? 0.58 : 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dragging
              ? _dgPrimary(context).withOpacity(0.58)
              : isDone
                  ? Color.lerp(_dgBorder(context), _dgSuccess(context), 0.24)!
                  : _dgBorder(context),
        ),
        boxShadow: [
          BoxShadow(
            color: dragging ? _dgPrimary(context).withOpacity(0.18) : (Theme.of(context).brightness == Brightness.dark ? Colors.black.withOpacity(0.18) : _dgPrimary(context).withOpacity(0.06)),
            blurRadius: dragging ? 24 : 14,
            offset: Offset(0, dragging ? 14 : 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 38,
                decoration: BoxDecoration(
                  color: isDone ? _dgSuccess(context) : _dgMuted(context),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: _dgText(context).withOpacity(isDone ? 0.58 : 1),
                      ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(
                    isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 19,
                    color: isDone ? _dgSuccess(context) : _dgMuted(context),
                  ),
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _GoalChip(icon: Icons.schedule_rounded, label: time),
                _GoalChip(icon: Icons.timer_rounded, label: AppLocalizations.of(context)!.dayGoalsHoursShort(goal.hours.toStringAsFixed(1))),
                if (goal.lifeBlock.trim().isNotEmpty)
                  _GoalChip(icon: Icons.grid_view_rounded, label: _localizedLifeBlock(context, goal.lifeBlock)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _CardAction(icon: Icons.edit_rounded, onTap: onEdit),
                const SizedBox(width: 4),
                _CardAction(icon: Icons.delete_outline_rounded, onTap: onDelete, danger: true),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GoalChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _dgInnerCardColor(context, lightOpacity: 0.82).withOpacity(0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _dgBorder(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _dgMuted(context)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _dgMuted(context),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  const _CardAction({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          color: danger ? Color.lerp(_dgCardColor(context), _dgDanger(context), 0.12)! : _dgInnerCardColor(context, lightOpacity: 0.82),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: danger ? Color.lerp(_dgBorder(context), _dgDanger(context), 0.42)! : _dgBorder(context),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: danger ? _dgDanger(context) : _dgMuted(context),
        ),
      ),
    );
  }
}

class _KanbanEmptyHint extends StatelessWidget {
  final String text;

  const _KanbanEmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      decoration: BoxDecoration(
        color: _dgCardColor(context, lightOpacity: 0.52),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _dgBorder(context)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: _dgMuted(context),
            ),
      ),
    );
  }
}

class _MiniCounter extends StatelessWidget {
  final String label;
  final int value;
  final Color accent;

  const _MiniCounter({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: _dgText(context),
            ),
      ),
    );
  }
}

class _SectionMeta {
  final String title;
  final IconData icon;
  final Color accent;

  const _SectionMeta({
    required this.title,
    required this.icon,
    required this.accent,
  });
}

_SectionMeta _sectionMeta(BuildContext context, _DaySection section) {
  final l = AppLocalizations.of(context)!;
  switch (section) {
    case _DaySection.morning:
      return _SectionMeta(
        title: l.dayGoalsSectionMorning,
        icon: Icons.wb_sunny_rounded,
        accent: _dgWarning(context),
      );
    case _DaySection.day:
      return _SectionMeta(
        title: l.dayGoalsSectionDay,
        icon: Icons.light_mode_rounded,
        accent: _dgPrimary(context),
      );
    case _DaySection.evening:
      return _SectionMeta(
        title: l.dayGoalsSectionEvening,
        icon: Icons.nights_stay_rounded,
        accent: Color(0xFF7C83FD),
      );
  }
}

String _formatGoalTime(DateTime dateTime) {
  final h = dateTime.hour.toString().padLeft(2, '0');
  final m = dateTime.minute.toString().padLeft(2, '0');
  return '$h:$m';
}


String _localizedLifeBlock(BuildContext context, String rawKey) {
  final l = AppLocalizations.of(context)!;
  final key = rawKey.trim().toLowerCase();

  switch (key) {
    case 'health':
    case 'здоровье':
      return l.lifeBlockHealth;
    case 'career':
    case 'work':
    case 'карьера':
      return l.lifeBlockCareer;
    case 'family':
    case 'семья':
      return l.lifeBlockFamily;
    case 'relations':
    case 'relationship':
    case 'relationships':
    case 'отношения':
      return l.lifeBlockRelations;
    case 'education':
    case 'study':
    case 'обучение':
    case 'образование':
      return l.lifeBlockEducation;
    case 'finance':
    case 'finances':
    case 'финансы':
      return l.lifeBlockFinance;
    case 'hobby':
    case 'hobbies':
    case 'хобби':
      return l.lifeBlockHobbies;
    case 'spirituality':
    case 'spirit':
    case 'духовность':
      return l.lifeBlockSpirituality;
    case 'general':
      return l.lifeBlockGeneral;
    default:
      return rawKey;
  }
}

class _DaySummaryCard extends StatelessWidget {
  final int totalGoals;
  final int completedGoals;
  final int remainingGoals;
  final double remainingHours;
  final double progress;

  const _DaySummaryCard({
    super.key,
    required this.totalGoals,
    required this.completedGoals,
    required this.remainingGoals,
    required this.remainingHours,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: _dgCardColor(context, lightOpacity: 0.72),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: _dgBorder(context)),
            boxShadow: _dgShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.dayGoalsSummaryTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _dgText(context),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.dayGoalsSummarySubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _dgMuted(context),
                    ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: _dgInnerCardColor(context, lightOpacity: 0.70),
                  valueColor:
                      AlwaysStoppedAnimation(_dgPrimary(context)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _SummaryStat(
                      label: AppLocalizations.of(context)!.dayGoalsSummaryTotal,
                      value: '$totalGoals',
                      accent: _dgPrimary(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryStat(
                      label: AppLocalizations.of(context)!.dayGoalsSummaryDone,
                      value: '$completedGoals',
                      accent: _dgSuccess(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryStat(
                      label: AppLocalizations.of(context)!.dayGoalsSummaryRemaining,
                      value: '$remainingGoals',
                      accent: _dgWarning(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _HoursPill(hours: remainingHours),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.14)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: _dgText(context),
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _dgMuted(context),
                ),
          ),
        ],
      ),
    );
  }
}

class _HoursPill extends StatelessWidget {
  final double hours;

  const _HoursPill({required this.hours});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: _dgInnerCardColor(context, lightOpacity: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _dgBorder(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 18,
            color: _dgPrimary(context),
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.dayGoalsRemainingHours(hours.toStringAsFixed(1)),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _dgText(context),
                ),
          ),
        ],
      ),
    );
  }
}

class _HideCompletedToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _HideCompletedToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _dgCardColor(context, lightOpacity: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _dgBorder(context)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_off_rounded,
            color: Color(0xFF5D7B8F),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.dayGoalsHideCompleted,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _dgText(context),
                  ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: _dgPrimary(context),
          ),
        ],
      ),
    );
  }
}

class _NestBackground extends StatelessWidget {
  const _NestBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = isDark
        ? [
            scheme.surfaceContainerLowest,
            scheme.surface,
            scheme.surfaceContainerLow,
            scheme.surfaceContainerLowest,
          ]
        : const [
            Color(0xFFF7FCFF),
            Color(0xFFEAF6FF),
            Color(0xFFD7EEFF),
            Color(0xFFF2FAFF),
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: const Stack(
        children: [
          Positioned(top: -140, left: -120, child: _SoftBlob(size: 360)),
          Positioned(bottom: -180, right: -140, child: _SoftBlob(size: 420)),
          Positioned(top: 120, right: -90, child: _SoftBlob(size: 240)),
        ],
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  final double size;
  const _SoftBlob({required this.size});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              scheme.primary.withOpacity(isDark ? 0.16 : 0.28),
              scheme.primary.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}


class _NestEmptyState extends StatelessWidget {
  final String message;

  const _NestEmptyState({
    String? message,
  }) : message = message ?? '';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _dgCardColor(context, lightOpacity: 0.70),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _dgBorder(context)),
          boxShadow: _dgShadow(context),
        ),
        child: Text(
          message.trim().isEmpty ? AppLocalizations.of(context)!.dayGoalsEmpty : message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: _dgText(context),
              ),
        ),
      ),
    );
  }
}


String _dgRecurringMenuTitle(String localeName) {
  final lang = localeName.toLowerCase().split('_').first.split('-').first;
  switch (lang) {
    case 'en':
      return 'Recurring task';
    case 'de':
      return 'Wiederkehrende Aufgabe';
    case 'fr':
      return 'Tâche récurrente';
    case 'es':
      return 'Tarea recurrente';
    case 'tr':
      return 'Tekrarlanan görev';
    default:
      return 'Повторяющаяся задача';
  }
}

String _dgRecurringMenuSubtitle(String localeName) {
  final lang = localeName.toLowerCase().split('_').first.split('-').first;
  switch (lang) {
    case 'en':
      return 'Create tasks on schedule';
    case 'de':
      return 'Aufgaben nach Zeitplan erstellen';
    case 'fr':
      return 'Créer selon un planning';
    case 'es':
      return 'Crear tareas programadas';
    case 'tr':
      return 'Programa göre görev oluştur';
    default:
      return 'Создать задачи по расписанию';
  }
}

String _dgRecurringEmptyMessage(String localeName) {
  final lang = localeName.toLowerCase().split('_').first.split('-').first;
  switch (lang) {
    case 'en':
      return 'No dates match this schedule.';
    case 'de':
      return 'Für diesen Plan wurden keine Termine gefunden.';
    case 'fr':
      return 'Aucune date ne correspond à ce planning.';
    case 'es':
      return 'No hay fechas para este calendario.';
    case 'tr':
      return 'Bu programa uygun tarih yok.';
    default:
      return 'Для этого расписания нет подходящих дат.';
  }
}

String _dgRecurringCreatedMessage(String localeName, int count) {
  final lang = localeName.toLowerCase().split('_').first.split('-').first;
  switch (lang) {
    case 'en':
      return 'Created tasks: $count';
    case 'de':
      return 'Aufgaben erstellt: $count';
    case 'fr':
      return 'Tâches créées : $count';
    case 'es':
      return 'Tareas creadas: $count';
    case 'tr':
      return 'Oluşturulan görevler: $count';
    default:
      return 'Создано задач: $count';
  }
}

class _NestSheet extends StatelessWidget {
  final Widget child;
  const _NestSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: _dgCardColor(context, lightOpacity: 0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: _dgBorder(context)),
            boxShadow: _dgShadow(context, top: true),
          ),
          child: child,
        ),
      ),
    );
  }
}

enum _FabAction { add, recurring, scan, calendar }

class _MainFab extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onRecurring;
  final VoidCallback onScan;
  final VoidCallback onCalendar;

  const _MainFab({
    super.key,
    required this.onAdd,
    required this.onRecurring,
    required this.onScan,
    required this.onCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 62,
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () => _openMenu(context),
        elevation: 10,
        backgroundColor: _dgPrimary(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    final action = await showModalBottomSheet<_FabAction>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FabMenuSheet(),
    );

    if (action == null) return;

    if (action == _FabAction.add) {
      onAdd();
    } else if (action == _FabAction.recurring) {
      onRecurring();
    } else if (action == _FabAction.scan) {
      onScan();
    } else {
      onCalendar();
    }
  }
}

class _FabMenuSheet extends StatelessWidget {
  const _FabMenuSheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottom + 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            color: _dgCardColor(context, lightOpacity: 0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _dgBorder(context)),
            boxShadow: _dgShadow(context, top: true),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _FabSheetHandle(),
                const SizedBox(height: 10),
                _FabMenuButton(
                  icon: Icons.edit_rounded,
                  title: l.dayGoalsFabAddTitle,
                  subtitle: l.dayGoalsFabAddSubtitle,
                  onTap: () => Navigator.pop(context, _FabAction.add),
                ),
                _FabMenuButton(
                  icon: Icons.repeat_rounded,
                  title: _dgRecurringMenuTitle(l.localeName),
                  subtitle: _dgRecurringMenuSubtitle(l.localeName),
                  onTap: () => Navigator.pop(context, _FabAction.recurring),
                ),
                _FabMenuButton(
                  icon: Icons.document_scanner_rounded,
                  title: l.dayGoalsFabScanTitle,
                  subtitle: l.dayGoalsFabScanSubtitle,
                  onTap: () => Navigator.pop(context, _FabAction.scan),
                ),
                _FabMenuButton(
                  icon: Icons.calendar_month_rounded,
                  title: l.dayGoalsFabCalendarTitle,
                  subtitle: l.dayGoalsFabCalendarSubtitle,
                  onTap: () => Navigator.pop(context, _FabAction.calendar),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FabSheetHandle extends StatelessWidget {
  const _FabSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: _dgText(context).withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _FabMenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FabMenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _dgPrimary(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _dgText(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _dgMuted(context),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _dgMuted(context), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
