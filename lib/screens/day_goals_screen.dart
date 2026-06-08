// lib/screens/day_goals_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../main.dart';
import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../models/ladna_space.dart';
import '../services/onboarding_tour_service.dart';
import '../widgets/add_day_goal_sheet.dart';
import '../widgets/edit_goal_sheet.dart';
import '../widgets/import_journal.dart';
import '../widgets/day_google_calendar_sync_sheet.dart';
import '../widgets/recurring_goal_sheet.dart' as recurring;

/// запуск: flutter run -d chrome --dart-define=VISION_API_KEY=xxxxx
const String _kVisionApiKey = String.fromEnvironment(
  'VISION_API_KEY',
  defaultValue: '',
);


bool _ladnaSpaceIsActive(LadnaSpace space) {
  final validUntil = space.validUntil;
  if (validUntil == null) return true;

  final today = DateUtils.dateOnly(DateTime.now());
  final until = DateUtils.dateOnly(validUntil);
  return !until.isBefore(today);
}

List<LadnaSpace> _ladnaActiveSpaces(Iterable<LadnaSpace> spaces) {
  return spaces.where(_ladnaSpaceIsActive).toList(growable: false);
}

class DayGoalsScreen extends StatelessWidget {
  final DateTime date;
  final String? lifeBlock;
  final List<String> availableBlocks;
  final List<UserGoalLinkOption> availableUserGoals;
  final String? initialSpaceId;
  final bool initialPersonalOnly;

  const DayGoalsScreen({
    super.key,
    required this.date,
    required this.lifeBlock,
    this.availableBlocks = const [],
    this.availableUserGoals = const [],
    this.initialSpaceId,
    this.initialPersonalOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DayGoalsModel(
        date: date,
        lifeBlock: lifeBlock,
        availableBlocks: availableBlocks,
        spaceId: initialSpaceId,
        personalOnly: initialPersonalOnly,
      )..load(),
      child: _DayGoalsView(
        availableUserGoals: availableUserGoals,
        initialSpaceId: initialSpaceId,
        initialPersonalOnly: initialPersonalOnly,
      ),
    );
  }
}

class _DayGoalsView extends StatefulWidget {
  final List<UserGoalLinkOption> availableUserGoals;
  final String? initialSpaceId;
  final bool initialPersonalOnly;

  const _DayGoalsView({
    required this.availableUserGoals,
    this.initialSpaceId,
    this.initialPersonalOnly = false,
  });

  @override
  State<_DayGoalsView> createState() => _DayGoalsViewState();
}

class _DayGoalsViewState extends State<_DayGoalsView> {
  final _scroll = ScrollController();
  final GlobalKey _summaryTourKey = GlobalKey(debugLabel: 'tour_day_summary');
  final GlobalKey _filterTourKey = GlobalKey(debugLabel: 'tour_day_filter');
  final GlobalKey _fabTourKey = GlobalKey(debugLabel: 'tour_day_fab');
  bool _dayTourQueued = false;

  bool _busy = false;
  bool _hideCompleted = false;
  String _selectedBlock = 'all';
  List<LadnaSpace> _spaces = const [];
  bool _spacesLoading = false;
  String? _selectedSpaceId;
  bool _personalOnly = false;
  final Set<_DaySection> _expandedSections = {..._DaySection.values};

  @override
  void initState() {
    super.initState();
    _selectedSpaceId = widget.initialSpaceId;
    _personalOnly = widget.initialPersonalOnly;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSpaces();
      _maybeRunDayGoalsTour();
    });
  }

  void _maybeRunDayGoalsTour() {
    if (!mounted || _dayTourQueued) return;
    _dayTourQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await OnboardingTourService.showDayGoalsTourIfNeeded(
        context: context,
        summaryKey: _summaryTourKey,
        filterKey: _filterTourKey,
        fabKey: _fabTourKey,
      );
      if (mounted) _dayTourQueued = false;
    });
  }

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

  Future<void> _loadSpaces() async {
    if (_spacesLoading) return;
    setState(() => _spacesLoading = true);
    var filterInvalid = false;
    try {
      final spaces = _ladnaActiveSpaces(await dbRepo.listSpaces());
      if (!mounted) return;
      setState(() {
        _spaces = spaces;
        if (_selectedSpaceId != null &&
            !_spaces.any((space) => space.id == _selectedSpaceId)) {
          _selectedSpaceId = null;
          _personalOnly = false;
          filterInvalid = true;
        }
      });
      if (filterInvalid && mounted) {
        await context.read<DayGoalsModel>().setSpaceFilter(
              selectedSpaceId: null,
              onlyPersonal: false,
            );
      }
    } catch (e) {
      if (mounted) _snack(e.toString());
    } finally {
      if (mounted) setState(() => _spacesLoading = false);
    }
  }

  Future<void> _setSpaceFilter({String? spaceId, bool personalOnly = false}) async {
    setState(() {
      _selectedSpaceId = spaceId;
      _personalOnly = personalOnly;
    });
    await context.read<DayGoalsModel>().setSpaceFilter(
          selectedSpaceId: spaceId,
          onlyPersonal: personalOnly,
        );
  }

  Future<void> _openAdd() async {
    await _loadSpaces();
    if (!mounted) return;
    final vm = context.read<DayGoalsModel>();

    final res = await showModalBottomSheet<AddGoalResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LadnaSheet(
        child: AddDayGoalSheet(
          fixedLifeBlock: vm.lifeBlock,
          availableBlocks: vm.availableBlocks,
          availableUserGoals: widget.availableUserGoals,
          initialDate: vm.date,
          availableSpaces: _ladnaActiveSpaces(_spaces),
          initialSpaceId: _personalOnly ? null : _selectedSpaceId,
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
          spaceId: _personalOnly ? null : (res.spaceId ?? _selectedSpaceId),
          assignedTo: res.assignedTo,
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
    await _loadSpaces();
    if (!mounted) return;
    final vm = context.read<DayGoalsModel>();

    final plan = await showModalBottomSheet<recurring.RecurringGoalPlan>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LadnaSheet(
        child: recurring.RecurringGoalSheet(
          availableBlocks: vm.availableBlocks,
          availableSpaces: _ladnaActiveSpaces(_spaces),
          initialSpaceId: _personalOnly ? null : _selectedSpaceId,
        ),
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
        final items = dates.map((day) {
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
            'space_id': _personalOnly ? null : (plan.spaceId ?? _selectedSpaceId),
            'assigned_to': plan.assignedTo,
            'visibility': (_personalOnly || (plan.spaceId ?? _selectedSpaceId) == null) ? 'private' : 'space',
            'is_recurring': true,
            'recurring_group_id': plan.recurringGroupId,
            'recurrence_type': plan.type == recurring.RecurrenceType.weekly
                ? 'weekly'
                : 'every_n_days',
            'recurrence_every_n_days': plan.everyNDays,
            'recurrence_weekdays': plan.weekdays.toList()..sort(),
            'recurrence_until': DateTime.utc(
              plan.until.year,
              plan.until.month,
              plan.until.day,
            ).toIso8601String().split('T').first,
          };
        }).toList();

        if (plan.isEditingExisting) {
          await dbRepo.replaceRecurringTaskPlan(
            recurringGroupId: plan.recurringGroupId,
            items: items,
          );
        } else {
          await dbRepo.createRecurringTaskPlan(items);
        }

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
    recurring.RecurringGoalPlan plan,
    DateTime startDate,
  ) {
    final start = DateUtils.dateOnly(startDate);
    final until = DateUtils.dateOnly(plan.until);
    if (until.isBefore(start)) return const [];

    final result = <DateTime>[];

    if (plan.type == recurring.RecurrenceType.everyNDays) {
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
    await _loadSpaces();
    if (!mounted) return;
    final vm = context.read<DayGoalsModel>();

    final res = await showModalBottomSheet<EditGoalResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LadnaSheet(
        child: EditGoalSheet(
          goal: g,
          fixedLifeBlock: vm.lifeBlock,
          availableBlocks: vm.availableBlocks,
          availableUserGoals: widget.availableUserGoals,
          initialUserGoalId: g.userGoalId,
          availableSpaces: _ladnaActiveSpaces(_spaces),
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
          targetDate: res.selectedDate,
          userGoalId: res.userGoalId,
          spaceId: res.spaceId,
          assignedTo: res.assignedTo,
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
      builder: (_) => _LadnaSheet(
        child: DayGoogleCalendarSyncSheet(date: vm.date),
      ),
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
    final vm = context.watch<DayGoalsModel>();

    final fixedBlock = vm.lifeBlock == null ? null : _normalizeBlock(vm.lifeBlock!);
    final activeBlock = fixedBlock ?? _selectedBlock;

    final allGoals = [...vm.goals]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final blockFiltered = activeBlock == 'all'
        ? allGoals
        : allGoals
            .where((g) => _normalizeBlock(g.lifeBlock) == activeBlock)
            .toList();

    final visibleGoals = _hideCompleted
        ? blockFiltered.where((g) => !g.isCompleted).toList()
        : blockFiltered;

    final totalGoals = blockFiltered.length;
    final completedGoals = blockFiltered.where((g) => g.isCompleted).length;
    final remainingGoals = totalGoals - completedGoals;
    final remainingHours = blockFiltered
        .where((g) => !g.isCompleted)
        .fold<double>(0, (sum, g) => sum + g.hours);

    final grouped = _groupGoalsByTimeOfDay(visibleGoals);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: _LadnaBackground(
            child: SafeArea(
              bottom: false,
              child: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                      controller: _scroll,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            18,
                            12,
                            18,
                            126 + MediaQuery.paddingOf(context).bottom,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _TopBar(
                                date: vm.date,
                                onBack: () => Navigator.maybePop(context),
                              ),
                              const SizedBox(height: 16),
                              KeyedSubtree(
                                key: _summaryTourKey,
                                child: _HeroSummaryCard(
                                  totalGoals: totalGoals,
                                  completedGoals: completedGoals,
                                  remainingGoals: remainingGoals,
                                  remainingHours: remainingHours,
                                ),
                              ),
                              const SizedBox(height: 14),
                              KeyedSubtree(
                                key: _filterTourKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SpaceFilterChips(
                                      spaces: _spaces,
                                      loading: _spacesLoading,
                                      selectedSpaceId: _selectedSpaceId,
                                      personalOnly: _personalOnly,
                                      onAll: () => _setSpaceFilter(),
                                      onPersonal: () => _setSpaceFilter(personalOnly: true),
                                      onSpace: (spaceId) => _setSpaceFilter(spaceId: spaceId),
                                    ),
                                    const SizedBox(height: 12),
                                    _BlockChips(
                                      blocks: _chipBlocks(vm.availableBlocks, allGoals),
                                      selected: activeBlock,
                                      fixedBlock: fixedBlock,
                                      onSelected: (block) {
                                        if (fixedBlock != null) return;
                                        setState(() => _selectedBlock = block);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _HideCompletedToolbar(
                                value: _hideCompleted,
                                onChanged: (value) {
                                  setState(() => _hideCompleted = value);
                                },
                              ),
                              const SizedBox(height: 16),
                              if (visibleGoals.isEmpty)
                                _EmptyDayCard(
                                  message: totalGoals > 0 && _hideCompleted
                                      ? _dgPick(context, ru: 'Все видимые задачи скрыты. Отключи фильтр «Скрыть выполненные».', en: 'All visible tasks are hidden. Turn off “Hide completed”.', de: 'Alle sichtbaren Aufgaben sind ausgeblendet. Deaktiviere „Erledigte ausblenden”.', fr: 'Toutes les tâches visibles sont masquées. Désactive “Masquer les terminées”.', es: 'Todas las tareas visibles están ocultas. Desactiva “Ocultar completadas”.', tr: 'Görünen görevler gizli. “Tamamlananları gizle” seçeneğini kapat.')
                                      : _dgPick(context, ru: 'На этот день пока нет задач. Добавь первую задачу через кнопку ниже.', en: 'No tasks for this day yet. Add the first task with the button below.', de: 'Für diesen Tag gibt es noch keine Aufgaben. Füge unten die erste Aufgabe hinzu.', fr: 'Aucune tâche pour cette journée. Ajoute la première avec le bouton ci-dessous.', es: 'Todavía no hay tareas para este día. Añade la primera con el botón de abajo.', tr: 'Bugün için henüz görev yok. Aşağıdaki düğmeyle ilk görevi ekle.'),
                                )
                              else
                                ..._buildSections(grouped),
                            ]),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 14),
            child: KeyedSubtree(
              key: _fabTourKey,
              child: _MainFab(
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
            ),
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
    final spaceLabels = {
      for (final space in _spaces) space.id: '${space.icon} ${space.name}',
    };

    for (final section in _DaySection.values) {
      final items = grouped[section] ?? const <Goal>[];
      if (items.isEmpty) continue;

      final openItems = items.where((g) => !g.isCompleted).toList();
      final doneItems = items.where((g) => g.isCompleted).toList();
      final expanded = _expandedSections.contains(section);

      sections.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _DaySectionCard(
            section: section,
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
            onEdit: _openEdit,
            onDelete: _confirmAndDelete,
            spaceLabels: spaceLabels,
            onMoveToDoneState: (goal, done) {
              if (goal.isCompleted == done) return;
              _toggleComplete(goal);
            },
          ),
        ),
      );
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

class _LadnaColors {
  static bool get _dark =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

  static Color get bg1 => _dark ? const Color(0xFF151126) : const Color(0xFFEDF7FF);
  static Color get bg2 => _dark ? const Color(0xFF0F0B1E) : const Color(0xFFF6F0FF);
  static Color get bg3 => _dark ? const Color(0xFF171329) : const Color(0xFFEEF8FF);
  static Color get surface => _dark ? const Color(0xD91D1732) : const Color(0xC7FFFFFF);
  static Color get surfaceStrong => _dark ? const Color(0xF0211A38) : const Color(0xEBFFFFFF);
  static Color get stroke => _dark ? const Color(0x446B54C0) : const Color(0xFFDAD2F1);
  static Color get strokeSoft => _dark ? const Color(0x336B54C0) : const Color(0xFFECE5FB);
  static Color get text => _dark ? const Color(0xFFF4F0FF) : const Color(0xFF1F1648);
  static Color get muted => _dark ? const Color(0xB8D7CEF5) : const Color(0xFF7F7A9E);
  static Color get purple => const Color(0xFF7356D8);
  static Color get purpleSoft => _dark ? const Color(0xFF2A2144) : const Color(0xFFEDE7FF);
  static Color get mint => _dark ? const Color(0xFF17392F) : const Color(0xFFDFF7EF);
  static Color get mintText => _dark ? const Color(0xFF83E4C1) : const Color(0xFF1B7B62);
  static Color get peach => _dark ? const Color(0xFF3B2E1C) : const Color(0xFFFFF4E6);
  static Color get gold => const Color(0xFFF5B400);
  static Color get danger => _dark ? const Color(0xFF3E2029) : const Color(0xFFF8DFE2);
  static Color get dangerText => _dark ? const Color(0xFFFF94A7) : const Color(0xFFD55467);
  static Color get lane => _dark ? const Color(0xC51A1430) : const Color(0xD1F5F3FF);
  static Color get cardWhite => _dark ? const Color(0xE31D1732) : Colors.white.withOpacity(0.92);
  static Color get softWhite => _dark ? const Color(0xB8201835) : Colors.white.withOpacity(0.62);
}

String _dgPick(
  BuildContext context, {
  required String ru,
  required String en,
  String? de,
  String? fr,
  String? es,
  String? tr,
}) {
  final lang = Localizations.localeOf(context).languageCode.toLowerCase();
  switch (lang) {
    case 'de':
      return de ?? en;
    case 'fr':
      return fr ?? en;
    case 'es':
      return es ?? en;
    case 'tr':
      return tr ?? en;
    case 'ru':
      return ru;
    default:
      return en;
  }
}

List<BoxShadow> get _ladnaShadow => [
      BoxShadow(
        color: _LadnaColors.purple.withOpacity(0.10),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];

class _LadnaBackground extends StatelessWidget {
  final Widget child;

  const _LadnaBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _LadnaColors.bg2,
            _LadnaColors.bg1,
            _LadnaColors.bg3,
          ],
          stops: [0.0, 0.58, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -130,
            left: -120,
            child: _SoftBlob(
              size: 330,
              color: _LadnaColors.cardWhite.withOpacity(0.70),
            ),
          ),
          Positioned(
            top: -110,
            right: -130,
            child: _SoftBlob(
              size: 310,
              color: _LadnaColors.purpleSoft.withOpacity(0.78),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 56, sigmaY: 56),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _LadnaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Border? border;

  const _LadnaCard({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 34,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? _LadnaColors.surface,
            borderRadius: BorderRadius.circular(radius),
            border: border ?? Border.all(color: _LadnaColors.stroke, width: 1.5),
            boxShadow: _ladnaShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final DateTime date;
  final VoidCallback onBack;

  const _TopBar({
    required this.date,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconGlassButton(
          icon: Icons.chevron_left_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              Text(
                _formatHeaderDate(context, date),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _LadnaColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _dgPick(context, ru: 'Задачи на день', en: 'Daily tasks', de: 'Tagesaufgaben', fr: 'Tâches du jour', es: 'Tareas del día', tr: 'Günlük görevler'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _LadnaColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'PlayfairDisplay',
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 52),
      ],
    );
  }
}

class _IconGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconGlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _LadnaColors.softWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _LadnaColors.stroke),
            boxShadow: _ladnaShadow,
          ),
          child: Icon(icon, color: _LadnaColors.text, size: 28),
        ),
      ),
    );
  }
}

class _HeroSummaryCard extends StatelessWidget {
  final int totalGoals;
  final int completedGoals;
  final int remainingGoals;
  final double remainingHours;

  const _HeroSummaryCard({
    required this.totalGoals,
    required this.completedGoals,
    required this.remainingGoals,
    required this.remainingHours,
  });

  @override
  Widget build(BuildContext context) {
    return _LadnaCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _dgPick(context, ru: 'Сводка дня', en: 'Day summary', de: 'Tagesübersicht', fr: 'Résumé du jour', es: 'Resumen del día', tr: 'Gün özeti'),
            style: TextStyle(
              color: _LadnaColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _dgPick(context, ru: 'Спокойный фокус на главном без перегруза.', en: 'Calm focus on what matters without overload.', de: 'Ruhiger Fokus auf das Wichtige ohne Überlastung.', fr: 'Un focus calme sur l’essentiel, sans surcharge.', es: 'Enfoque tranquilo en lo importante sin sobrecarga.', tr: 'Aşırı yük olmadan önemli olana sakin odaklanma.'),
            style: TextStyle(
              color: _LadnaColors.text,
              fontSize: 20,
              height: 1.12,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: '$totalGoals',
                  label: _dgPick(context, ru: 'Всего', en: 'Total', de: 'Gesamt', fr: 'Total', es: 'Total', tr: 'Toplam'),
                  color: _LadnaColors.purpleSoft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  value: '$completedGoals',
                  label: _dgPick(context, ru: 'Готово', en: 'Done', de: 'Erledigt', fr: 'Terminé', es: 'Hecho', tr: 'Bitti'),
                  color: _LadnaColors.mint,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  value: '$remainingGoals',
                  label: _dgPick(context, ru: 'Осталось', en: 'Left', de: 'Offen', fr: 'Restant', es: 'Pendiente', tr: 'Kalan'),
                  color: _LadnaColors.peach,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _LadnaColors.cardWhite.withOpacity(0.88),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _LadnaColors.strokeSoft),
            ),
            child: Row(
              children: [
                Text('⏱', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(
                  _dgPick(context, ru: 'Осталось часов: ${remainingHours.toStringAsFixed(remainingHours % 1 == 0 ? 0 : 1)}', en: 'Hours left: ${remainingHours.toStringAsFixed(remainingHours % 1 == 0 ? 0 : 1)}', de: 'Stunden offen: ${remainingHours.toStringAsFixed(remainingHours % 1 == 0 ? 0 : 1)}', fr: 'Heures restantes : ${remainingHours.toStringAsFixed(remainingHours % 1 == 0 ? 0 : 1)}', es: 'Horas restantes: ${remainingHours.toStringAsFixed(remainingHours % 1 == 0 ? 0 : 1)}', tr: 'Kalan saat: ${remainingHours.toStringAsFixed(remainingHours % 1 == 0 ? 0 : 1)}'),
                  style: TextStyle(
                    color: _LadnaColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _LadnaColors.strokeSoft),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: _LadnaColors.text,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _LadnaColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


class _SpaceFilterChips extends StatelessWidget {
  final List<LadnaSpace> spaces;
  final bool loading;
  final String? selectedSpaceId;
  final bool personalOnly;
  final VoidCallback onAll;
  final VoidCallback onPersonal;
  final ValueChanged<String> onSpace;

  const _SpaceFilterChips({
    required this.spaces,
    required this.loading,
    required this.selectedSpaceId,
    required this.personalOnly,
    required this.onAll,
    required this.onPersonal,
    required this.onSpace,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      _SpaceChip(
        label: _dgPick(context, ru: 'Все', en: 'All', de: 'Alle', fr: 'Tous', es: 'Todo', tr: 'Tümü'),
        selected: selectedSpaceId == null && !personalOnly,
        onTap: onAll,
      ),
      _SpaceChip(
        label: _dgPick(context, ru: 'Личные', en: 'Personal', de: 'Persönlich', fr: 'Personnel', es: 'Personal', tr: 'Kişisel'),
        selected: personalOnly,
        onTap: onPersonal,
      ),
      for (final space in spaces)
        _SpaceChip(
          label: '${space.icon} ${space.name}',
          selected: selectedSpaceId == space.id,
          onTap: () => onSpace(space.id),
        ),
      if (loading)
        const SizedBox(
          width: 34,
          height: 34,
          child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) => items[index],
      ),
    );
  }
}

class _SpaceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SpaceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _LadnaColors.purple : (_LadnaColors._dark ? const Color(0xFF2A2144) : Colors.white.withOpacity(0.72)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? Colors.transparent : _LadnaColors.stroke),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _LadnaColors.purple.withOpacity(0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? Colors.white : (_LadnaColors._dark ? const Color(0xFFF4F0FF) : _LadnaColors.muted),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _BlockChips extends StatelessWidget {
  final List<String> blocks;
  final String selected;
  final String? fixedBlock;
  final ValueChanged<String> onSelected;

  const _BlockChips({
    required this.blocks,
    required this.selected,
    required this.fixedBlock,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: blocks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final block = blocks[index];
          final active = selected == block;
          return GestureDetector(
            onTap: () => onSelected(block),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: active ? _LadnaColors.purple : (_LadnaColors._dark ? const Color(0xFF2A2144) : Colors.white.withOpacity(0.72)),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active ? Colors.transparent : _LadnaColors.stroke,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: _LadnaColors.purple.withOpacity(0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                block == 'all' ? _dgPick(context, ru: 'Все сферы', en: 'All areas', de: 'Alle Bereiche', fr: 'Tous les domaines', es: 'Todas las áreas', tr: 'Tüm alanlar') : _localizedLifeBlock(context, block),
                style: TextStyle(
                  color: active ? Colors.white : (_LadnaColors._dark ? const Color(0xFFF4F0FF) : _LadnaColors.muted),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HideCompletedToolbar extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _HideCompletedToolbar({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _LadnaCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      radius: 26,
      child: Row(
        children: [
          Icon(Icons.visibility_off_rounded, color: _LadnaColors.muted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _dgPick(context, ru: 'Скрыть выполненные', en: 'Hide completed', de: 'Erledigte ausblenden', fr: 'Masquer les terminées', es: 'Ocultar completadas', tr: 'Tamamlananları gizle'),
              style: TextStyle(
                color: _LadnaColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: _LadnaColors.purple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DaySectionCard extends StatelessWidget {
  final _DaySection section;
  final List<Goal> openGoals;
  final List<Goal> doneGoals;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final Future<void> Function(Goal goal) onToggleGoal;
  final Future<void> Function(Goal goal) onEdit;
  final Future<void> Function(Goal goal) onDelete;
  final Map<String, String> spaceLabels;
  final void Function(Goal goal, bool done) onMoveToDoneState;

  const _DaySectionCard({
    required this.section,
    required this.openGoals,
    required this.doneGoals,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onToggleGoal,
    required this.onEdit,
    required this.onDelete,
    required this.spaceLabels,
    required this.onMoveToDoneState,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _sectionMeta(context, section);

    return _LadnaCard(
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onToggleExpanded,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: expanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: _LadnaColors.muted,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: meta.iconBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: meta.iconBorder),
                      ),
                      child: Center(
                        child: Text(meta.emoji, style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        meta.title,
                        style: TextStyle(
                          color: _LadnaColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'PlayfairDisplay',
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    _Cap(text: _dgPick(context, ru: 'Ост. ${openGoals.length}', en: 'Left ${openGoals.length}', de: 'Offen ${openGoals.length}', fr: 'Rest. ${openGoals.length}', es: 'Pend. ${openGoals.length}', tr: 'Kalan ${openGoals.length}'), color: _LadnaColors._dark ? const Color(0xFF3B2E1C) : const Color(0xFFF7F1E5), textColor: _LadnaColors._dark ? const Color(0xFFFFD87A) : const Color(0xFF8D6A1B)),
                    const SizedBox(width: 8),
                    _Cap(text: _dgPick(context, ru: 'Гот. ${doneGoals.length}', en: 'Done ${doneGoals.length}', de: 'Fertig ${doneGoals.length}', fr: 'Fait ${doneGoals.length}', es: 'Hecho ${doneGoals.length}', tr: 'Bitti ${doneGoals.length}'), color: _LadnaColors.mint, textColor: _LadnaColors.mintText),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final openLane = _TaskLane(
                    title: _dgPick(context, ru: '⚡ В работе', en: '⚡ In progress', de: '⚡ In Arbeit', fr: '⚡ En cours', es: '⚡ En progreso', tr: '⚡ Devam ediyor'),
                    count: openGoals.length,
                    goals: openGoals,
                    doneLane: false,
                    emptyText: _dgPick(context, ru: 'Здесь появятся активные задачи этого блока', en: 'Active tasks for this block will appear here', de: 'Aktive Aufgaben dieses Blocks erscheinen hier', fr: 'Les tâches actives de ce bloc apparaîtront ici', es: 'Aquí aparecerán las tareas activas de este bloque', tr: 'Bu bloğun aktif görevleri burada görünecek'),
                    onToggleGoal: onToggleGoal,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    spaceLabels: spaceLabels,
                    onMoveToDoneState: onMoveToDoneState,
                  );

                  final doneLane = _TaskLane(
                    title: _dgPick(context, ru: '✅ Готово', en: '✅ Done', de: '✅ Erledigt', fr: '✅ Terminé', es: '✅ Hecho', tr: '✅ Bitti'),
                    count: doneGoals.length,
                    goals: doneGoals,
                    doneLane: true,
                    emptyText: _dgPick(context, ru: 'Здесь будут завершённые задачи после фокуса-блока', en: 'Completed tasks will appear here after a focus block', de: 'Erledigte Aufgaben erscheinen hier nach dem Fokusblock', fr: 'Les tâches terminées apparaîtront ici après le bloc de focus', es: 'Las tareas completadas aparecerán aquí después del bloque de enfoque', tr: 'Odak bloğundan sonra tamamlanan görevler burada görünecek'),
                    onToggleGoal: onToggleGoal,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    spaceLabels: spaceLabels,
                    onMoveToDoneState: onMoveToDoneState,
                  );

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: openLane),
                      const SizedBox(width: 10),
                      Expanded(child: doneLane),
                    ],
                  );
                },
              ),
            ),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}

class _Cap extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Cap({required this.text, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TaskLane extends StatelessWidget {
  final String title;
  final int count;
  final List<Goal> goals;
  final bool doneLane;
  final String emptyText;
  final Future<void> Function(Goal goal) onToggleGoal;
  final Future<void> Function(Goal goal) onEdit;
  final Future<void> Function(Goal goal) onDelete;
  final Map<String, String> spaceLabels;
  final void Function(Goal goal, bool done) onMoveToDoneState;

  const _TaskLane({
    required this.title,
    required this.count,
    required this.goals,
    required this.doneLane,
    required this.emptyText,
    required this.onToggleGoal,
    required this.onEdit,
    required this.onDelete,
    required this.spaceLabels,
    required this.onMoveToDoneState,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Goal>(
      onWillAccept: (goal) => goal != null && goal.isCompleted != doneLane,
      onAccept: (goal) => onMoveToDoneState(goal, doneLane),
      builder: (context, candidate, rejected) {
        final activeDrop = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(minHeight: 150),
      decoration: BoxDecoration(
        color: activeDrop ? _LadnaColors.purpleSoft.withOpacity(0.95) : _LadnaColors.lane,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: activeDrop ? _LadnaColors.purple.withOpacity(0.45) : _LadnaColors.strokeSoft),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: _LadnaColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 28),
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: doneLane ? _LadnaColors.mint : (_LadnaColors._dark ? const Color(0xFF3B2E1C) : const Color(0xFFF6EFDF)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: doneLane ? _LadnaColors.mintText : (_LadnaColors._dark ? const Color(0xFFFFD87A) : const Color(0xFF6F5A18)),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (goals.isEmpty)
            _LaneEmpty(text: emptyText)
          else
            ...goals.map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Draggable<Goal>(
                  data: goal,
                  affinity: Axis.horizontal,
                  dragAnchorStrategy: pointerDragAnchorStrategy,
                  feedback: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 168,
                      child: _TaskCard(
                        goal: goal,
                        done: doneLane,
                        spaceLabels: spaceLabels,
                        dragging: true,
                        onToggle: () {},
                        onEdit: () {},
                        onDelete: () {},
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.35,
                    child: _TaskCard(
                      goal: goal,
                      done: doneLane,
                      spaceLabels: spaceLabels,
                      onToggle: () => onToggleGoal(goal),
                      onEdit: () => onEdit(goal),
                      onDelete: () => onDelete(goal),
                    ),
                  ),
                  child: _TaskCard(
                    goal: goal,
                    done: doneLane,
                    spaceLabels: spaceLabels,
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

class _LaneEmpty extends StatelessWidget {
  final String text;

  const _LaneEmpty({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: _LadnaColors.cardWhite.withOpacity(0.56),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _LadnaColors._dark ? const Color(0xFF6B54C0).withOpacity(0.72) : const Color(0xFFDDD5EF),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _LadnaColors._dark ? const Color(0xFFC9C1EA) : const Color(0xFFAFA9C3),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Goal goal;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Map<String, String> spaceLabels;
  final bool dragging;

  const _TaskCard({
    required this.goal,
    required this.done,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.spaceLabels = const {},
    this.dragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: done ? null : (_LadnaColors._dark ? const Color(0xFF241C3B) : _LadnaColors.cardWhite),
        gradient: done
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _LadnaColors._dark ? [const Color(0xFF153D33), const Color(0xFF211A38)] : [_LadnaColors.mint.withOpacity(0.70), _LadnaColors.cardWhite],
              )
            : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _LadnaColors.stroke),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6F5DB7).withOpacity(0.08),
            blurRadius: dragging ? 28 : 18,
            offset: Offset(0, dragging ? 14 : 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _LadnaColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.3,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? const Color(0xFF34C78A) : Colors.transparent,
                    border: Border.all(
                      color: done ? const Color(0xFF34C78A) : const Color(0xFFB8B0CF),
                      width: 2,
                    ),
                    boxShadow: done
                        ? const [
                            BoxShadow(
                              color: Colors.white,
                              spreadRadius: -6,
                            ),
                          ]
                        : null,
                  ),
                  child: done
                      ? Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (goal.spaceId != null)
                _MetaPill(text: spaceLabels[goal.spaceId!] ?? _dgPick(context, ru: '👥 Пространство', en: '👥 Space', de: '👥 Bereich', fr: '👥 Espace', es: '👥 Espacio', tr: '👥 Alan')),
              _MetaPill(text: '🕥 ${_formatGoalTime(goal.startTime)}'),
              _MetaPill(text: '⏱ ${_formatHours(context, goal.hours)}'),
              if (goal.description.trim().isNotEmpty)
                _MetaPill(text: '✦ ${goal.description.trim()}'),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _SpherePill(lifeBlock: goal.lifeBlock, done: done),
              if (done)
                Text(
                  _dgPick(context, ru: 'Выполнено', en: 'Completed', de: 'Erledigt', fr: 'Terminé', es: 'Completado', tr: 'Tamamlandı'),
                  style: TextStyle(
                    color: Color(0xFF34A475),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SmallActionButton(icon: Icons.edit_rounded, onTap: onEdit),
                    const SizedBox(width: 6),
                    _SmallActionButton(
                      icon: Icons.delete_outline_rounded,
                      onTap: onDelete,
                      danger: true,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String text;

  const _MetaPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: _LadnaColors._dark ? const Color(0xFF2A2144) : const Color(0xFFF8F6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _LadnaColors.strokeSoft),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _LadnaColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SpherePill extends StatelessWidget {
  final String lifeBlock;
  final bool done;

  const _SpherePill({required this.lifeBlock, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: done ? (_LadnaColors._dark ? const Color(0xFF17392F) : const Color(0xFFE5FAF3)) : _LadnaColors.purpleSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 88),
        child: Text(
          _localizedLifeBlock(context, lifeBlock),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
          color: done ? (_LadnaColors._dark ? const Color(0xFFA7F5D9) : const Color(0xFF16745A)) : (_LadnaColors._dark ? const Color(0xFFC9C1EA) : _LadnaColors.purple),
          fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  const _SmallActionButton({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: danger ? _LadnaColors.danger.withOpacity(0.50) : (_LadnaColors._dark ? const Color(0xFF2A2144) : _LadnaColors.cardWhite),
            border: Border.all(
              color: danger ? (_LadnaColors._dark ? const Color(0xFFFF94A7).withOpacity(0.50) : const Color(0xFFF2C5CB)) : _LadnaColors.stroke,
            ),
          ),
          child: Icon(
            icon,
            color: danger ? _LadnaColors.dangerText : _LadnaColors.muted,
            size: 17,
          ),
        ),
      ),
    );
  }
}

class _EmptyDayCard extends StatelessWidget {
  final String message;

  const _EmptyDayCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return _LadnaCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Text('✨', style: TextStyle(fontSize: 30)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _LadnaColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _LadnaSheet extends StatelessWidget {
  final Widget child;

  const _LadnaSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: _LadnaColors.surfaceStrong,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
    required this.onAdd,
    required this.onRecurring,
    required this.onScan,
    required this.onCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () => _openMenu(context),
        elevation: 16,
        backgroundColor: _LadnaColors.purple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Icon(Icons.add_rounded, size: 46, color: Colors.white),
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
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: _LadnaColors.surfaceStrong,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _LadnaColors.stroke),
            boxShadow: _ladnaShadow,
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
        color: _LadnaColors.text.withOpacity(0.15),
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
                  color: _LadnaColors.purple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _LadnaColors.purple, size: 18),
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
                        color: _LadnaColors.text,
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
                        color: _LadnaColors.muted,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _LadnaColors.muted, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionMeta {
  final String title;
  final String emoji;
  final Color iconBg;
  final Color iconBorder;

  const _SectionMeta({
    required this.title,
    required this.emoji,
    required this.iconBg,
    required this.iconBorder,
  });
}

_SectionMeta _sectionMeta(BuildContext context, _DaySection section) {
  switch (section) {
    case _DaySection.morning:
      return _SectionMeta(
        title: _dgPick(context, ru: 'Утро', en: 'Morning', de: 'Morgen', fr: 'Matin', es: 'Mañana', tr: 'Sabah'),
        emoji: '☀️',
        iconBg: _LadnaColors.peach,
        iconBorder: _LadnaColors.gold.withOpacity(0.30),
      );
    case _DaySection.day:
      return _SectionMeta(
        title: _dgPick(context, ru: 'День', en: 'Day', de: 'Tag', fr: 'Journée', es: 'Día', tr: 'Gün'),
        emoji: '🌤️',
        iconBg: _LadnaColors.purpleSoft,
        iconBorder: _LadnaColors.stroke,
      );
    case _DaySection.evening:
      return _SectionMeta(
        title: _dgPick(context, ru: 'Вечер', en: 'Evening', de: 'Abend', fr: 'Soir', es: 'Noche', tr: 'Akşam'),
        emoji: '🌙',
        iconBg: _LadnaColors.bg1.withOpacity(0.75),
        iconBorder: _LadnaColors.strokeSoft,
      );
  }
}

List<String> _chipBlocks(List<String> availableBlocks, List<Goal> goals) {
  final seen = <String>{'all'};
  final out = <String>['all'];

  for (final raw in availableBlocks) {
    final block = _normalizeBlock(raw);
    if (block.isEmpty || block == 'general') continue;
    if (seen.add(block)) out.add(block);
  }

  for (final g in goals) {
    final block = _normalizeBlock(g.lifeBlock);
    if (block.isEmpty || block == 'general') continue;
    if (seen.add(block)) out.add(block);
  }

  if (out.length == 1) {
    out.addAll(['career', 'health', 'finance', 'personal']);
  }

  return out;
}

String _normalizeBlock(String value) {
  final v = value.trim().toLowerCase();
  switch (v) {
    case '':
      return 'general';
    case 'general':
    case 'общий':
    case 'общее':
    case 'общие':
      return 'general';
    case 'health':
    case 'здоровье':
      return 'health';
    case 'career':
    case 'work':
    case 'job':
    case 'карьера':
    case 'работа':
      return 'career';
    case 'family':
    case 'семья':
      return 'family';
    case 'finance':
    case 'finances':
    case 'финансы':
      return 'finance';
    case 'education':
    case 'study':
    case 'обучение':
    case 'образование':
      return 'education';
    case 'hobby':
    case 'hobbies':
    case 'хобби':
      return 'hobbies';
    case 'relationships':
    case 'relations':
    case 'relationship':
    case 'отношения':
      return 'relationships';
    case 'personal':
    case 'self':
    case 'саморазвитие':
    case 'личное':
      return 'personal';
    case 'spirituality':
    case 'духовность':
      return 'spirituality';
    case 'travel':
    case 'путешествия':
      return 'travel';
    case 'home':
    case 'дом':
      return 'home';
    default:
      return v;
  }
}

String _localizedLifeBlock(BuildContext context, String rawKey) {
  final l = AppLocalizations.of(context)!;
  final key = _normalizeBlock(rawKey);

  switch (key) {
    case 'health':
      return l.lifeBlockHealth;
    case 'career':
      return l.lifeBlockCareer;
    case 'family':
      return l.lifeBlockFamily;
    case 'relationships':
      return l.lifeBlockRelations;
    case 'education':
      return l.lifeBlockEducation;
    case 'finance':
      return l.lifeBlockFinance;
    case 'hobbies':
      return l.lifeBlockHobbies;
    case 'spirituality':
      return l.lifeBlockSpirituality;
    case 'general':
      return l.lifeBlockGeneral;
    case 'personal':
      return _dgPick(context, ru: 'Личное', en: 'Personal', de: 'Persönlich', fr: 'Personnel', es: 'Personal', tr: 'Kişisel');
    case 'travel':
      return _dgPick(context, ru: 'Путешествия', en: 'Travel', de: 'Reisen', fr: 'Voyages', es: 'Viajes', tr: 'Seyahat');
    case 'home':
      return _dgPick(context, ru: 'Дом', en: 'Home', de: 'Zuhause', fr: 'Maison', es: 'Hogar', tr: 'Ev');
    default:
      return rawKey.isEmpty ? l.lifeBlockGeneral : rawKey;
  }
}

String _formatGoalTime(DateTime dateTime) {
  final h = dateTime.hour.toString().padLeft(2, '0');
  final m = dateTime.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _formatHours(BuildContext context, double hours) {
  final minutes = (hours * 60).round();
  if (minutes < 60) {
    return _dgPick(context, ru: '$minutes мин', en: '$minutes min', de: '$minutes Min.', fr: '$minutes min', es: '$minutes min', tr: '$minutes dk');
  }
  final value = hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1);
  return _dgPick(context, ru: '$value ч', en: '${value}h', de: '$value Std.', fr: '$value h', es: '$value h', tr: '$value sa');
}

String _formatHeaderDate(BuildContext context, DateTime date) {
  final lang = Localizations.localeOf(context).languageCode.toLowerCase();
  if (lang == 'ru') {
    const weekdays = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  return MaterialLocalizations.of(context).formatFullDate(date);
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
