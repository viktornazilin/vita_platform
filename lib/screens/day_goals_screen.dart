// lib/screens/day_goals_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../widgets/add_day_goal_sheet.dart';
import '../widgets/timeline_row.dart';
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
  bool _busy = false;
  bool _hideCompleted = false;

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
                                totalGoals: totalGoals,
                                completedGoals: completedGoals,
                                remainingGoals: remainingGoals,
                                remainingHours: remainingHours,
                                progress: progress,
                              ),
                              const SizedBox(height: 12),
                              _HideCompletedToggle(
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
    int runningIndex = 0;
    final totalVisible =
        grouped.values.fold<int>(0, (sum, list) => sum + list.length);

    for (final section in _DaySection.values) {
      final items = grouped[section];
      if (items == null || items.isEmpty) continue;

      sections.add(_SectionHeader(section: section));
      sections.add(const SizedBox(height: 8));

      for (final g in items) {
        sections.add(
          TimelineRow(
            key: ValueKey(g.id),
            goal: g,
            index: runningIndex,
            total: totalVisible,
            onToggle: () => _toggleComplete(g),
            onDelete: () => _confirmAndDelete(g),
            onEdit: () => _openEdit(g),
          ),
        );
        runningIndex++;
      }

      sections.add(const SizedBox(height: 12));
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

class _SectionHeader extends StatelessWidget {
  final _DaySection section;

  const _SectionHeader({required this.section});

  @override
  Widget build(BuildContext context) {
    String title;
    IconData icon;
    Color accent;

    switch (section) {
      case _DaySection.morning:
        title = 'Утро';
        icon = Icons.wb_sunny_rounded;
        accent = const Color(0xFFF59E0B);
        break;
      case _DaySection.day:
        title = 'День';
        icon = Icons.light_mode_rounded;
        accent = const Color(0xFF3AA8E6);
        break;
      case _DaySection.evening:
        title = 'Вечер';
        icon = Icons.nights_stay_rounded;
        accent = const Color(0xFF7C83FD);
        break;
    }

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withOpacity(0.18)),
          ),
          child: Icon(icon, color: accent, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E4B5A),
              ),
        ),
      ],
    );
  }
}

class _DaySummaryCard extends StatelessWidget {
  final int totalGoals;
  final int completedGoals;
  final int remainingGoals;
  final double remainingHours;
  final double progress;

  const _DaySummaryCard({
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