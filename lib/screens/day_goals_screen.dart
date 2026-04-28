// lib/screens/day_goals_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../widgets/add_day_goal_sheet.dart';
import '../widgets/edit_goal_sheet.dart';
import '../widgets/import_journal.dart';
import '../widgets/day_google_calendar_sync_sheet.dart';

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
    final meta = _sectionMeta(section);

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.58),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x102B5B7A),
                blurRadius: 22,
                offset: Offset(0, 14),
              ),
            ],
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
                                  color: const Color(0xFF2E4B5A),
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
                                _MiniCounter(label: 'Ост.', value: openGoals.length, accent: const Color(0xFFF59E0B)),
                                const SizedBox(width: 6),
                                _MiniCounter(label: 'Гот.', value: doneGoals.length, accent: const Color(0xFF22C55E)),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final openColumn = _KanbanColumn(
          title: 'В работе',
          subtitle: '${openGoals.length}',
          icon: Icons.bolt_rounded,
          accent: accent,
          goals: openGoals,
          doneColumn: false,
          emptyText: 'Нет активных задач',
          onToggleGoal: onToggleGoal,
          onDelete: onDelete,
          onEdit: onEdit,
          onMoveToDoneState: onMoveToDoneState,
        );

        final doneColumn = _KanbanColumn(
          title: 'Готово',
          subtitle: '${doneGoals.length}',
          icon: Icons.check_circle_rounded,
          accent: const Color(0xFF22C55E),
          goals: doneGoals,
          doneColumn: true,
          emptyText: 'Пока пусто',
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
            color: isActiveDrop ? accent.withOpacity(0.12) : const Color(0xFFF4FAFF).withOpacity(0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isActiveDrop ? accent.withOpacity(0.42) : const Color(0xFFD6E6F5),
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
                            color: const Color(0xFF2E4B5A),
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
                            color: const Color(0xFF2E4B5A),
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
                    child: LongPressDraggable<Goal>(
                      data: goal,
                      feedback: Material(
                        color: Colors.transparent,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: _KanbanGoalCard(
                            goal: goal,
                            compact: true,
                            onToggle: () {},
                            onEdit: () {},
                            onDelete: () {},
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.35,
                        child: _KanbanGoalCard(
                          goal: goal,
                          onToggle: () => onToggleGoal(goal),
                          onEdit: () => onEdit(goal),
                          onDelete: () => onDelete(goal),
                        ),
                      ),
                      child: _KanbanGoalCard(
                        goal: goal,
                        onToggle: () => onToggleGoal(goal),
                        onEdit: () => onEdit(goal),
                        onDelete: () => onDelete(goal),
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
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _KanbanGoalCard({
    required this.goal,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final time = _formatGoalTime(goal.startTime);
    final isDone = goal.isCompleted;

    return Container(
      padding: EdgeInsets.fromLTRB(10, compact ? 9 : 10, 8, compact ? 9 : 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDone ? 0.58 : 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone ? const Color(0xFFD8EAD8) : const Color(0xFFD6E6F5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2B5B7A),
            blurRadius: 14,
            offset: Offset(0, 8),
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
                  color: isDone ? const Color(0xFF22C55E) : const Color(0xFF7AAECF),
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
                        color: const Color(0xFF2E4B5A).withOpacity(isDone ? 0.58 : 1),
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
                    color: isDone ? const Color(0xFF22C55E) : const Color(0xFF6A8190),
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
                _GoalChip(icon: Icons.timer_rounded, label: '${goal.hours.toStringAsFixed(1)} ч'),
                if (goal.lifeBlock.trim().isNotEmpty)
                  _GoalChip(icon: Icons.grid_view_rounded, label: goal.lifeBlock),
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
        color: const Color(0xFFEAF6FF).withOpacity(0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF5D7B8F)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5D7B8F),
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
          color: danger ? const Color(0xFFFFEEF0) : const Color(0xFFEAF6FF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: danger ? const Color(0xFFFFCCD2) : const Color(0xFFD6E6F5),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: danger ? const Color(0xFFEF4444) : const Color(0xFF5D7B8F),
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
        color: Colors.white.withOpacity(0.52),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF6A8190),
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
              color: const Color(0xFF2E4B5A),
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

_SectionMeta _sectionMeta(_DaySection section) {
  switch (section) {
    case _DaySection.morning:
      return const _SectionMeta(
        title: 'Утро',
        icon: Icons.wb_sunny_rounded,
        accent: Color(0xFFF59E0B),
      );
    case _DaySection.day:
      return const _SectionMeta(
        title: 'День',
        icon: Icons.light_mode_rounded,
        accent: Color(0xFF3AA8E6),
      );
    case _DaySection.evening:
      return const _SectionMeta(
        title: 'Вечер',
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
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x142B5B7A),
                blurRadius: 24,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сводка дня',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E4B5A),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Держи фокус на главном и не перегружай день.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF587282),
                    ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE8F2FA),
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF3AA8E6)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _SummaryStat(
                      label: 'Всего',
                      value: '$totalGoals',
                      accent: const Color(0xFF3AA8E6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryStat(
                      label: 'Готово',
                      value: '$completedGoals',
                      accent: const Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryStat(
                      label: 'Осталось',
                      value: '$remainingGoals',
                      accent: const Color(0xFFF59E0B),
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
                  color: const Color(0xFF2E4B5A),
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF587282),
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
        color: const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 18,
            color: Color(0xFF3AA8E6),
          ),
          const SizedBox(width: 8),
          Text(
            'Осталось часов: ${hours.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF385262),
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
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.visibility_off_rounded,
            color: Color(0xFF5D7B8F),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Скрыть выполненные',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E4B5A),
                  ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3AA8E6),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7FCFF),
            Color(0xFFEAF6FF),
            Color(0xFFD7EEFF),
            Color(0xFFF2FAFF),
          ],
        ),
      ),
      child: Stack(
        children: const [
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
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color(0x663AA8E6), Color(0x0058B9FF)],
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
  }) : message = message ?? 'На этот день пока нет целей';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.70),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD6E6F5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A2B5B7A),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E4B5A),
              ),
        ),
      ),
    );
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
            color: Colors.white.withOpacity(0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2B5B7A),
                blurRadius: 28,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

enum _FabAction { add, scan, calendar }

class _MainFab extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final VoidCallback onCalendar;

  const _MainFab({
    super.key,
    required this.onAdd,
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
        backgroundColor: const Color(0xFF3AA8E6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2B5B7A),
                blurRadius: 28,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9BC7E6).withOpacity(0.55),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FabMenuButton(
                    icon: Icons.edit_rounded,
                    title: l.dayGoalsFabAddTitle,
                    subtitle: l.dayGoalsFabAddSubtitle,
                    onTap: () => Navigator.pop(context, _FabAction.add),
                  ),
                  const SizedBox(height: 10),
                  _FabMenuButton(
                    icon: Icons.document_scanner_rounded,
                    title: l.dayGoalsFabScanTitle,
                    subtitle: l.dayGoalsFabScanSubtitle,
                    onTap: () => Navigator.pop(context, _FabAction.scan),
                  ),
                  const SizedBox(height: 10),
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
    return Material(
      color: const Color(0xFFF4FAFF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6E6F5)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3AA8E6), Color(0xFF7DD3FC)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x162B5B7A),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2E4B5A),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF2E4B5A).withOpacity(0.65),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF7AAECF)),
            ],
          ),
        ),
      ),
    );
  }
}