// lib/screens/day_goals_screen.dart
import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../main.dart';
import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../models/ladna_space.dart';
import '../services/onboarding_tour_service.dart';
import '../services/notification_service.dart';
import '../services/push_notifications_service.dart';
import '../widgets/add_day_goal_sheet.dart';
import '../widgets/edit_goal_sheet.dart';
import '../widgets/import_journal.dart';
import '../widgets/day_google_calendar_sync_sheet.dart';
import '../widgets/recurring_goal_sheet.dart' as recurring;
import '../widgets/nest/nest_background.dart';
import '../widgets/nest/nest_page_header.dart';
import '../controllers/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

        // createGoal уже оптимистичен и сам тихо синхронизируется с сервером
        // в фоне — раньше здесь стоял `await vm.load()`, который делал
        // повторный сетевой запрос сразу же и мог откатить только что
        // добавленную цель старыми данными (та же гонка, что чинили в
        // _toggleComplete и в expenses_screen.dart). Больше не нужен.

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

    // Показываем один раз за всё время — после того, как человек создал
    // цель со временем начала, самый естественный момент объяснить, зачем
    // нужны уведомления (а не абстрактно при первом запуске приложения).
    unawaited(_maybeShowNotificationSoftAsk());
  }

  static const _notifSoftAskShownKey = 'notif_soft_ask_shown_v1';

  /// Показывает свой экран "зачем нам уведомления" перед системным диалогом
  /// iOS — если сразу дёрнуть системный запрос, отклоняют почти всегда, а
  /// второй раз iOS программно не спросит (только через Настройки). Не
  /// показываем повторно, если уже показывали хоть раз (независимо от
  /// ответа) или если разрешение уже выдано.
  Future<void> _maybeShowNotificationSoftAsk() async {
    if (!mounted) return;
    try {
      if (await NotificationService.instance.hasPermission()) return;

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_notifSoftAskShownKey) == true) return;
      await prefs.setBool(_notifSoftAskShownKey, true);

      if (!mounted) return;
      final wantsEnable = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _LadnaSheet(
          child: _NotificationSoftAskSheet(),
        ),
      );

      if (wantsEnable == true) {
        await NotificationService.instance.requestPermission();
        // На iOS локальные и push-уведомления делят одно системное
        // разрешение, но регистрация в APNs/FCM (получение device-токена)
        // — отдельный шаг, который NotificationService (flutter_local_notifications)
        // не выполняет. Без этого вызова push для активности в пространствах
        // никогда не заработает — токен просто не появится.
        if (!kIsWeb) {
          await PushNotificationsService.instance.requestPermissionAndRegister();
        }
      }
    } catch (_) {
      // Ненавязчивый экран — любой сбой (например, SharedPreferences
      // недоступен в приватном режиме браузера на web) тихо игнорируем,
      // не мешая основному потоку добавления цели.
    }
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
    try {
      // toggleComplete already updates local state immediately and saves
      // to the backend in the background (optimistic UI). Calling
      // vm.load() right after used to re-fetch from the server before that
      // background save had landed, overwriting the fresh local state with
      // stale data — that's why the drag only "took" every second time.
      await vm.toggleComplete(g);
    } catch (e) {
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      _snack(l.dayGoalsToggleFailed(e.toString()));
    }
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
                              NestPageHeader(
                                title: AppLocalizations.of(context)!.dayGoalsHeaderTitle,
                                subtitle: _formatHeaderDate(context, vm.date),
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
                                      ? AppLocalizations.of(context)!.dayGoalsAllHiddenHint
                                      : AppLocalizations.of(context)!.dayGoalsEmptyHint,
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

// Раньше _LadnaColors читал яркость ОС напрямую (WidgetsBinding...platformBrightness),
// поэтому ручной выбор темы в настройках приложения (ThemeController) этот
// экран игнорировал. Теперь резолвится из Theme.of(context), как и везде.
// Палитра этого экрана (bg1/mint/peach/gold и т.д.) сознательно оставлена
// как есть — она отличается от остального приложения (см. отдельный
// комментарий в чате), это не механическая часть исправления.
// Раньше _LadnaColors был отдельной, не связанной с остальным приложением
// палитрой (свои bg1/bg2/bg3, surface, text и т.д.), и вдобавок читал
// яркость ОС напрямую в обход ThemeController. По просьбе пользователя
// экран приведён к общей палитре: базовые токены теперь берутся из
// ThemeController, как и на остальных экранах. Несколько чисто акцентных,
// не мешающих единообразию цветов (mint/peach/gold) сохранены как
// декоративные акценты для секций "утро/день/вечер".
class _LadnaColors {
  static bool _dark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  // bg1 больше не используется для фона экрана (см. _LadnaBackground —
  // теперь NestBackground), но ещё применяется как декоративный тон для
  // иконки "вечер".
  static Color bg1(BuildContext context) =>
      _dark(context) ? ThemeController.kLadnaCardDark : ThemeController.kLadnaTintLight;
  static Color surface(BuildContext context) =>
      _dark(context) ? ThemeController.kLadnaSurfaceDark : ThemeController.kLadnaSurfaceLight;
  static Color surfaceStrong(BuildContext context) =>
      _dark(context) ? ThemeController.kLadnaCardDark : ThemeController.kLadnaCardLight;
  static Color stroke(BuildContext context) =>
      _dark(context) ? ThemeController.kLadnaBorderDark : ThemeController.kLadnaBorderLight;
  static Color strokeSoft(BuildContext context) =>
      _dark(context) ? ThemeController.kLadnaBorderDark : ThemeController.kLadnaBorderLight;
  static Color text(BuildContext context) =>
      _dark(context) ? ThemeController.kLadnaTextDark : ThemeController.kLadnaTextLight;
  static Color muted(BuildContext context) =>
      _dark(context) ? const Color(0x99FFFFFF) : ThemeController.kLadnaMuted;
  static Color purple(BuildContext context) => ThemeController.kLadnaPrimary;
  static Color purpleSoft(BuildContext context) =>
      ThemeController.kLadnaPrimary.withOpacity(_dark(context) ? 0.18 : 0.10);
  static Color mint(BuildContext context) =>
      ThemeController.kLadnaTeal.withOpacity(_dark(context) ? 0.20 : 0.14);
  static Color mintText(BuildContext context) => ThemeController.kLadnaTeal;
  static Color peach(BuildContext context) =>
      ThemeController.kLadnaLime.withOpacity(_dark(context) ? 0.18 : 0.16);
  static Color gold(BuildContext context) => ThemeController.kLadnaLime;
  static Color danger(BuildContext context) =>
      const Color(0xFFE35B5B).withOpacity(_dark(context) ? 0.16 : 0.10);
  static Color dangerText(BuildContext context) => const Color(0xFFE35B5B);
  static Color lane(BuildContext context) =>
      _dark(context) ? ThemeController.kLadnaSurfaceDark : ThemeController.kLadnaSurfaceLight;
  static Color cardWhite(BuildContext context) =>
      _dark(context) ? ThemeController.kLadnaCardDark : ThemeController.kLadnaCardLight;
  static Color softWhite(BuildContext context) =>
      _dark(context) ? ThemeController.kLadnaCardDark.withOpacity(0.62) : Colors.white.withOpacity(0.62);
}


List<BoxShadow> _ladnaShadow(BuildContext context) => [
      BoxShadow(
        color: _LadnaColors.purple(context).withOpacity(0.10),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];

class _LadnaBackground extends StatelessWidget {
  final Widget child;

  const _LadnaBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    // Раньше здесь был свой градиент (bg1/bg2/bg3) и размытые цветные пятна —
    // единственный экран в приложении с таким фоном. Теперь использует тот
    // же NestBackground, что и все остальные экраны.
    return NestBackground(child: child);
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
            color: color ?? _LadnaColors.surface(context),
            borderRadius: BorderRadius.circular(radius),
            border: border ?? Border.all(color: _LadnaColors.stroke(context), width: 1.5),
            boxShadow: _ladnaShadow(context),
          ),
          child: child,
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
            AppLocalizations.of(context)!.dayGoalsSummaryTitle,
            style: TextStyle(
              color: _LadnaColors.muted(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.dayGoalsSummarySubtitle,
            style: TextStyle(
              color: _LadnaColors.text(context),
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
                  label: AppLocalizations.of(context)!.dayGoalsStatTotal,
                  color: _LadnaColors.purpleSoft(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  value: '$completedGoals',
                  label: AppLocalizations.of(context)!.dayGoalsStatDone,
                  color: _LadnaColors.mint(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  value: '$remainingGoals',
                  label: AppLocalizations.of(context)!.dayGoalsStatLeft,
                  color: _LadnaColors.peach(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _LadnaColors.cardWhite(context).withOpacity(0.88),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _LadnaColors.strokeSoft(context)),
            ),
            child: Row(
              children: [
                Text('⏱', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.dayGoalsHoursLeftLabel(remainingHours.toStringAsFixed(remainingHours % 1 == 0 ? 0 : 1)),
                  style: TextStyle(
                    color: _LadnaColors.text(context),
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
        border: Border.all(color: _LadnaColors.strokeSoft(context)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: _LadnaColors.text(context),
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
              color: _LadnaColors.muted(context),
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
        label: AppLocalizations.of(context)!.dayGoalsFilterAll,
        selected: selectedSpaceId == null && !personalOnly,
        onTap: onAll,
      ),
      _SpaceChip(
        label: AppLocalizations.of(context)!.dayGoalsFilterPersonal,
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
          color: selected ? _LadnaColors.purple(context) : (_LadnaColors._dark(context) ? const Color(0xFF2A2144) : Colors.white.withOpacity(0.72)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? Colors.transparent : _LadnaColors.stroke(context)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _LadnaColors.purple(context).withOpacity(0.18),
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
            color: selected ? Colors.white : (_LadnaColors._dark(context) ? const Color(0xFFF4F0FF) : _LadnaColors.muted(context)),
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
                color: active ? _LadnaColors.purple(context) : (_LadnaColors._dark(context) ? const Color(0xFF2A2144) : Colors.white.withOpacity(0.72)),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active ? Colors.transparent : _LadnaColors.stroke(context),
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: _LadnaColors.purple(context).withOpacity(0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                block == 'all' ? AppLocalizations.of(context)!.dayGoalsFilterAllSpheres : _localizedLifeBlock(context, block),
                style: TextStyle(
                  color: active ? Colors.white : (_LadnaColors._dark(context) ? const Color(0xFFF4F0FF) : _LadnaColors.muted(context)),
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
          Icon(Icons.visibility_off_rounded, color: _LadnaColors.muted(context), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.dayGoalsHideCompleted,
              style: TextStyle(
                color: _LadnaColors.text(context),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: _LadnaColors.purple(context),
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
                        color: _LadnaColors.muted(context),
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
                          color: _LadnaColors.text(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    _Cap(text: AppLocalizations.of(context)!.dayGoalsLaneLeftBadge(openGoals.length), color: _LadnaColors._dark(context) ? const Color(0xFF3B2E1C) : const Color(0xFFF7F1E5), textColor: _LadnaColors._dark(context) ? const Color(0xFFFFD87A) : const Color(0xFF8D6A1B)),
                    const SizedBox(width: 8),
                    _Cap(text: AppLocalizations.of(context)!.dayGoalsLaneDoneBadge(doneGoals.length), color: _LadnaColors.mint(context), textColor: _LadnaColors.mintText(context)),
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
                    title: AppLocalizations.of(context)!.dayGoalsLaneInProgress,
                    count: openGoals.length,
                    goals: openGoals,
                    doneLane: false,
                    emptyText: AppLocalizations.of(context)!.dayGoalsLaneInProgressEmpty,
                    onToggleGoal: onToggleGoal,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    spaceLabels: spaceLabels,
                    onMoveToDoneState: onMoveToDoneState,
                  );

                  final doneLane = _TaskLane(
                    title: AppLocalizations.of(context)!.dayGoalsLaneDoneTitle,
                    count: doneGoals.length,
                    goals: doneGoals,
                    doneLane: true,
                    emptyText: AppLocalizations.of(context)!.dayGoalsLaneDoneEmpty,
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
        color: activeDrop ? _LadnaColors.purpleSoft(context).withOpacity(0.95) : _LadnaColors.lane(context),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: activeDrop ? _LadnaColors.purple(context).withOpacity(0.45) : _LadnaColors.strokeSoft(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: _LadnaColors.text(context),
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
                  color: doneLane ? _LadnaColors.mint(context) : (_LadnaColors._dark(context) ? const Color(0xFF3B2E1C) : const Color(0xFFF6EFDF)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: doneLane ? _LadnaColors.mintText(context) : (_LadnaColors._dark(context) ? const Color(0xFFFFD87A) : const Color(0xFF6F5A18)),
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
        color: _LadnaColors.cardWhite(context).withOpacity(0.56),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _LadnaColors._dark(context) ? const Color(0xFF6B54C0).withOpacity(0.72) : const Color(0xFFDDD5EF),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _LadnaColors._dark(context) ? const Color(0xFFC9C1EA) : const Color(0xFFAFA9C3),
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
      // Fixed height: every card in a lane is exactly the same size,
      // no matter how long the title or how many meta pills there are.
      height: 260,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: done ? null : (_LadnaColors._dark(context) ? const Color(0xFF241C3B) : _LadnaColors.cardWhite(context)),
        gradient: done
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _LadnaColors._dark(context) ? [const Color(0xFF153D33), const Color(0xFF211A38)] : [_LadnaColors.mint(context).withOpacity(0.70), _LadnaColors.cardWhite(context)],
              )
            : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _LadnaColors.stroke(context)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6F5DB7).withOpacity(0.08),
            blurRadius: dragging ? 28 : 18,
            offset: Offset(0, dragging ? 14 : 8),
          ),
        ],
      ),
      // ClipRect + OverflowBox: if a card's content is ever taller than the
      // fixed height (e.g. an unusually long title plus many meta pills),
      // it's clipped instead of throwing a layout overflow error, so the
      // card size stays perfectly consistent no matter the content.
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minHeight: 0,
          maxHeight: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                goal.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: TextStyle(
                  color: _LadnaColors.text(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.3,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (goal.spaceId != null)
                    _MetaPill(text: spaceLabels[goal.spaceId!] ?? AppLocalizations.of(context)!.dayGoalsSpaceMetaLabel),
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
                      AppLocalizations.of(context)!.dayGoalsCompletedLabel,
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
        ),
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
        color: _LadnaColors._dark(context) ? const Color(0xFF2A2144) : const Color(0xFFF8F6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _LadnaColors.strokeSoft(context)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _LadnaColors.muted(context),
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
        color: done ? (_LadnaColors._dark(context) ? const Color(0xFF17392F) : const Color(0xFFE5FAF3)) : _LadnaColors.purpleSoft(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 88),
        child: Text(
          _localizedLifeBlock(context, lifeBlock),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
          color: done ? (_LadnaColors._dark(context) ? const Color(0xFFA7F5D9) : const Color(0xFF16745A)) : (_LadnaColors._dark(context) ? const Color(0xFFC9C1EA) : _LadnaColors.purple(context)),
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
            color: danger ? _LadnaColors.danger(context).withOpacity(0.50) : (_LadnaColors._dark(context) ? const Color(0xFF2A2144) : _LadnaColors.cardWhite(context)),
            border: Border.all(
              color: danger ? (_LadnaColors._dark(context) ? const Color(0xFFFF94A7).withOpacity(0.50) : const Color(0xFFF2C5CB)) : _LadnaColors.stroke(context),
            ),
          ),
          child: Icon(
            icon,
            color: danger ? _LadnaColors.dangerText(context) : _LadnaColors.muted(context),
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
              color: _LadnaColors.text(context),
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
            color: _LadnaColors.surfaceStrong(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _NotificationSoftAskSheet extends StatelessWidget {
  const _NotificationSoftAskSheet();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(22, 14, 22, bottom + 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _LadnaColors.stroke(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _LadnaColors.purpleSoft(context),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: _LadnaColors.purple(context),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.dayGoalsNotifSoftAskTitle,
            style: TextStyle(
              color: _LadnaColors.text(context),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.dayGoalsNotifSoftAskBody,
            style: TextStyle(
              color: _LadnaColors.muted(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _LadnaColors.purple(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                AppLocalizations.of(context)!.dayGoalsNotifSoftAskEnable,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                AppLocalizations.of(context)!.dayGoalsNotifSoftAskDismiss,
                style: TextStyle(
                  color: _LadnaColors.muted(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
        backgroundColor: _LadnaColors.purple(context),
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
            color: _LadnaColors.surfaceStrong(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _LadnaColors.stroke(context)),
            boxShadow: _ladnaShadow(context),
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
        color: _LadnaColors.text(context).withOpacity(0.15),
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
                  color: _LadnaColors.purple(context).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _LadnaColors.purple(context), size: 18),
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
                        color: _LadnaColors.text(context),
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
                        color: _LadnaColors.muted(context),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _LadnaColors.muted(context), size: 24),
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
        title: AppLocalizations.of(context)!.dayGoalsPeriodMorning,
        emoji: '☀️',
        iconBg: _LadnaColors.peach(context),
        iconBorder: _LadnaColors.gold(context).withOpacity(0.30),
      );
    case _DaySection.day:
      return _SectionMeta(
        title: AppLocalizations.of(context)!.dayGoalsPeriodDay,
        emoji: '🌤️',
        iconBg: _LadnaColors.purpleSoft(context),
        iconBorder: _LadnaColors.stroke(context),
      );
    case _DaySection.evening:
      return _SectionMeta(
        title: AppLocalizations.of(context)!.dayGoalsPeriodEvening,
        emoji: '🌙',
        iconBg: _LadnaColors.bg1(context).withOpacity(0.75),
        iconBorder: _LadnaColors.strokeSoft(context),
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
      return AppLocalizations.of(context)!.dayGoalsSphereLifePersonal;
    case 'travel':
      return AppLocalizations.of(context)!.dayGoalsSphereTravel;
    case 'home':
      return AppLocalizations.of(context)!.dayGoalsSphereHome;
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
    return AppLocalizations.of(context)!.dayGoalsMinutesShort(minutes);
  }
  final value = hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1);
  return AppLocalizations.of(context)!.dayGoalsHoursShort(value);
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