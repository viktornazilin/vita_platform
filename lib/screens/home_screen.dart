import 'dart:async';
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/habits_repo_mixin.dart' show HabitEntryUpsert;
import '../services/habits_repo_mixin.dart';
import '../services/mental_repo_mixin.dart';

import '../models/home_model.dart';
import '../models/reports_model.dart';
import '../models/mood_model.dart';
import '../models/mood.dart';
import '../models/goals_calendar_model.dart';

import 'goals_screen.dart';
import 'mood_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'expenses_screen.dart';

import '../main.dart'; // dbRepo

// вынесенные виджеты
import '../widgets/frosted_rail.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/launcher_tile.dart';
import '../widgets/mass_daily_entry_sheet.dart';
import '../widgets/recurring_goal_sheet.dart';

// ✅ новые AI виджеты
import '../widgets/ai_plan_sheet.dart';
import '../widgets/ai_insights_sheet.dart';

// ✅ доп. для Home Dashboard
import '../widgets/mood_selector.dart';
import '../widgets/report_section_card.dart';
import '../widgets/report_stat_card.dart';
import '../widgets/expense_analytics.dart'; // loadExpenseAnalytics + ExpenseAnalytics

// ✅ модель для результата ai-plan (если AiPlanSheet возвращает List<AiSuggestion>)
import '../models/ai/ai_suggestion.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _screens = <Widget>[
    const HomeDashboardTab(), // ✅ улучшенный дашборд
    const GoalsScreen(),
    const MoodScreen(),
    const ProfileScreen(),
    const ReportsScreen(),
    const ExpensesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeModel(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  static final PageStorageBucket _bucket = PageStorageBucket();

  final ValueNotifier<bool> _fabVisible = ValueNotifier<bool>(true);

  String _titleFor(int idx) => switch (idx) {
    0 => 'Главная',
    1 => 'Цели',
    2 => 'Настроение',
    3 => 'Профиль',
    4 => 'Отчёты',
    5 => 'Расходы',
    _ => 'MyNEST',
  };

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Текущая сессия будет завершена.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _signOut(context);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось выйти: $e')));
    }
  }

  // helper для склейки даты и TimeOfDay
  DateTime _combine(DateTime day, TimeOfDay t) =>
      DateTime(day.year, day.month, day.day, t.hour, t.minute);

  void _onDashboardScroll(ScrollDirection dir) {
    // скрываем FAB при скролле вниз, показываем при скролле вверх
    if (dir == ScrollDirection.reverse && _fabVisible.value) {
      _fabVisible.value = false;
    } else if (dir == ScrollDirection.forward && !_fabVisible.value) {
      _fabVisible.value = true;
    }
  }

  void _showQuickAddSheet(BuildContext context, HomeModel model) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet<MassDailyEntryResult>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16 +
                MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.of(ctx).padding.bottom,
          ),
          child: Column(
            children: [
              // Разделы
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Разделы',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .95,
                ),
                children: [
                  LauncherTile(
                    icon: Icons.home,
                    label: 'Главная',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(0);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.flag,
                    label: 'Цели',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(1);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.mood,
                    label: 'Настроение',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(2);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.person,
                    label: 'Профиль',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(3);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.insights,
                    label: 'Инсайты',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(4);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.account_balance_wallet,
                    label: 'Отчеты',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(5);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Быстро
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Быстро',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // ✅ Массовое добавление
              QuickActionTile(
                icon: Icons.bolt,
                color: cs.primary,
                title: 'Массовое добавление за день',
                subtitle: 'Расходы + Задачи + Настроение',
                onTap: () async {
                  // 1) подтягиваем блоки жизни для sheet
                  final goalsModel = GoalsCalendarModel();
                  await goalsModel.loadBlocks();

                  // 2) открываем sheet уже с availableBlocks
                  final result =
                      await showModalBottomSheet<MassDailyEntryResult>(
                        context: ctx,
                        useSafeArea: true,
                        isScrollControlled: true,
                        backgroundColor: cs.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => MassDailyEntrySheet(
                          availableBlocks: goalsModel.lifeBlocks,
                        ),
                      );

                  if (result != null && context.mounted) {
                    Navigator.pop(ctx); // закрыть лаунчер

                    try {
                      // 1) Настроение
                      if (result.mood != null) {
                        await dbRepo.upsertMood(
                          date: DateUtils.dateOnly(result.date),
                          emoji: result.mood!.emoji,
                          note: result.mood!.note,
                        );
                      }

                      // 2) Расходы
                      for (final e in result.expenses) {
                        final ts = DateTime(
                          result.date.year,
                          result.date.month,
                          result.date.day,
                          12,
                          0,
                        );

                        await dbRepo.addTransaction(
                          ts: ts,
                          kind: 'expense',
                          categoryId: e.categoryId,
                          amount: e.amount,
                          note: e.note.isEmpty ? null : e.note,
                        );
                      }

                      // 1.5) Привычки
                      if (result.habits.isNotEmpty) {
                        final habitRows = result.habits
                            .map(
                              (h) => HabitEntryUpsert(
                                habitId: h.habitId,
                                day: DateUtils.dateOnly(result.date),
                                done: h.done,
                                value: h.value,
                              ),
                            )
                            .toList();

                        await dbRepo.upsertHabitEntries(habitRows);
                      }

                      // 1.6) Ментальное здоровье
                      if (result.mental.isNotEmpty) {
                        final rows = result.mental.map((a) {
                          if (a.valueBool != null) {
                            return MentalAnswerUpsert.yesNo(
                              questionId: a.questionId,
                              day: DateUtils.dateOnly(result.date),
                              value: a.valueBool!,
                            );
                          }

                          if (a.valueInt != null) {
                            return MentalAnswerUpsert.scale(
                              questionId: a.questionId,
                              day: DateUtils.dateOnly(result.date),
                              value: a.valueInt!,
                            );
                          }

                          return MentalAnswerUpsert.text(
                            questionId: a.questionId,
                            day: DateUtils.dateOnly(result.date),
                            value: (a.valueText ?? '').trim(),
                          );
                        }).toList();

                        await dbRepo.upsertMentalAnswers(rows);
                      }

                      // 2.5) Доходы
                      for (final i in result.incomes) {
                        final ts = DateTime(
                          result.date.year,
                          result.date.month,
                          result.date.day,
                          12,
                          0,
                        );

                        await dbRepo.addTransaction(
                          ts: ts,
                          kind: 'income',
                          categoryId: i.categoryId,
                          amount: i.amount,
                          note: i.note.isEmpty ? null : i.note,
                        );
                      }

                      // 3) Задачи
                      for (final g in result.goals) {
                        final start = _combine(
                          result.date,
                          g.startTime ?? const TimeOfDay(hour: 9, minute: 0),
                        );
                        final deadline = DateTime(
                          result.date.year,
                          result.date.month,
                          result.date.day,
                          23,
                          59,
                          0,
                        );

                        final desc = g.hours > 0
                            ? 'План: ${g.hours.toStringAsFixed(g.hours.truncateToDouble() == g.hours ? 0 : 1)} ч'
                            : '';

                        await dbRepo.createGoal(
                          title: g.title,
                          description: desc,
                          deadline: deadline,
                          lifeBlock: g.lifeBlock,
                          importance: g.importance,
                          emotion: g.emotion ?? '',
                          spentHours: g.hours,
                          startTime: start,
                        );
                      }

                      // 4) Привычки (повторная запись как в твоём коде — оставил)
                      final habitRows = result.habits
                          .map(
                            (h) => HabitEntryUpsert(
                              habitId: h.habitId,
                              day: DateUtils.dateOnly(result.date),
                              done: h.done,
                              value: h.value,
                            ),
                          )
                          .toList();

                      if (habitRows.isNotEmpty) {
                        await dbRepo.upsertHabitEntries(habitRows);
                      }

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Сохранено: '
                            '${result.expenses.length} расход(ов), '
                            '${result.incomes.length} доход(ов), '
                            '${result.goals.length} задач(и), '
                            '${result.habits.length} привыч(ек)'
                            '${result.mood != null ? ', настроение' : ''}',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка сохранения: $e')),
                      );
                    }
                  }
                },
              ),

              const SizedBox(height: 6),

              // 🔮 AI-план
              QuickActionTile(
                icon: Icons.auto_awesome,
                color: cs.tertiary,
                title: 'AI-план на неделю/месяц',
                subtitle: 'Анализ целей, опроса и прогресса',
                onTap: () async {
                  final created = await showModalBottomSheet<int>(
                    context: ctx,
                    useSafeArea: true,
                    isScrollControlled: true,
                    showDragHandle: true,
                    backgroundColor: cs.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => const AiPlanSheet(),
                  );

                  if (created != null && context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Создано целей: $created')),
                    );
                  }
                },
              ),

              const SizedBox(height: 6),

              // 🧠 AI-инсайты
              QuickActionTile(
                icon: Icons.psychology_alt,
                color: cs.secondary,
                title: 'AI-инсайты',
                subtitle: 'Как события влияют на цели и прогресс',
                onTap: () async {
                  await showModalBottomSheet<void>(
                    context: ctx,
                    useSafeArea: true,
                    isScrollControlled: true,
                    backgroundColor: cs.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => const AiInsightsSheet(),
                  );
                },
              ),

              // 🔁 Регулярная цель
              QuickActionTile(
                icon: Icons.event_repeat_rounded,
                color: cs.primaryContainer,
                title: 'Регулярная цель',
                subtitle: 'Планирование на несколько дней вперёд',
                onTap: () async {
                  final plan = await showModalBottomSheet<RecurringGoalPlan>(
                    context: ctx,
                    useSafeArea: true,
                    isScrollControlled: true,
                    showDragHandle: true,
                    backgroundColor: cs.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => const RecurringGoalSheet(),
                  );

                  if (plan == null) return;

                  final today = DateUtils.dateOnly(DateTime.now());

                  DateTime combine(DateTime day, TimeOfDay t) =>
                      DateTime(day.year, day.month, day.day, t.hour, t.minute);

                  List<DateTime> buildOccurrences() {
                    final start = DateUtils.dateOnly(today);
                    final until = DateUtils.dateOnly(plan.until);

                    final out = <DateTime>[];
                    if (until.isBefore(start)) return out;

                    if (plan.type == RecurrenceType.everyNDays) {
                      final step = plan.everyNDays < 1 ? 1 : plan.everyNDays;
                      for (
                        var day = start;
                        !day.isAfter(until);
                        day = day.add(Duration(days: step))
                      ) {
                        out.add(combine(day, plan.time));
                      }
                      return out;
                    }

                    final wds = plan.weekdays.isEmpty
                        ? {start.weekday}
                        : plan.weekdays;
                    for (
                      var day = start;
                      !day.isAfter(until);
                      day = day.add(const Duration(days: 1))
                    ) {
                      if (wds.contains(day.weekday)) {
                        out.add(combine(day, plan.time));
                      }
                    }
                    return out;
                  }

                  final occurrences = buildOccurrences();

                  if (occurrences.isEmpty) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Нет дат для создания (проверь дедлайн/настройки).',
                        ),
                      ),
                    );
                    return;
                  }

                  try {
                    Navigator.pop(ctx); // закрыть лаунчер

                    for (final start in occurrences) {
                      final deadline = DateTime(
                        start.year,
                        start.month,
                        start.day,
                        23,
                        59,
                      );

                      final desc = plan.plannedHours > 0
                          ? 'План: ${plan.plannedHours.toStringAsFixed(plan.plannedHours.truncateToDouble() == plan.plannedHours ? 0 : 1)} ч'
                          : '';

                      await dbRepo.createGoal(
                        title: plan.title,
                        description: desc,
                        deadline: deadline,
                        lifeBlock: plan.lifeBlock,
                        importance: plan.importance,
                        emotion: plan.emotion,
                        spentHours: plan.plannedHours,
                        startTime: start,
                      );
                    }

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Создано целей: ${occurrences.length}'),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Не удалось создать серию целей: $e'),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoFab(
    BuildContext context, {
    required VoidCallback onPressed,
    required String heroTag,
    double size = 110,
    bool small = false,
  }) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        heroTag: heroTag,
        elevation: 6,
        highlightElevation: 10,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        onPressed: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.3),
            child: Image.asset(
              'assets/images/logo.png',
              width: size * 0.9,
              height: size * 0.9,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeModel>();
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        final double fabSizeCompact = 140;
        final double fabSizeRailSmall = 44;

        Widget content = SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetTween = Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(offsetTween),
                  child: child,
                ),
              );
            },
            child: PageStorage(
              key: ValueKey(model.selectedIndex),
              bucket: _bucket,
              child: IndexedStack(
                index: model.selectedIndex,
                children: HomeScreen._screens,
              ),
            ),
          ),
        );

        // padding от FAB: только в compact и только если FAB потенциально виден (визуально будет ок)
        if (isCompact) {
          final bottomSafe = MediaQuery.of(context).padding.bottom;
          content = Padding(
            padding: EdgeInsets.only(
              bottom: (fabSizeCompact / 2) + bottomSafe + 16,
            ),
            child: content,
          );
        }

        final isDashboard = model.selectedIndex == 0;

        // FAB на дашборде: авто-скрытие (scroll down), и меньше размер
        final double fabSize = isCompact
            ? (isDashboard ? 84 : fabSizeCompact)
            : fabSizeRailSmall;

        final fab = ValueListenableBuilder<bool>(
          valueListenable: _fabVisible,
          builder: (context, visible, _) {
            final show = !isDashboard || visible;
            return AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              offset: show ? Offset.zero : const Offset(0, 0.25),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: show ? 1 : 0,
                child: _logoFab(
                  context,
                  heroTag: isCompact ? 'launcher-fab' : 'launcher-fab-rail',
                  size: fabSize,
                  onPressed: () => _showQuickAddSheet(context, model),
                ),
              ),
            );
          },
        );

        if (isCompact) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_titleFor(model.selectedIndex)),
              actions: [
                IconButton(
                  tooltip: 'Выйти из аккаунта',
                  icon: const Icon(Icons.logout),
                  onPressed: () => _confirmSignOut(context),
                ),
              ],
            ),
            body: NotificationListener<UserScrollNotification>(
              onNotification: (n) {
                if (isDashboard) _onDashboardScroll(n.direction);
                return false;
              },
              child: content,
            ),
            floatingActionButton: fab,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            backgroundColor: theme.colorScheme.surface,
          );
        }

        final extendedRail = constraints.maxWidth >= 1200;
        return Scaffold(
          appBar: AppBar(
            title: Text(_titleFor(model.selectedIndex)),
            actions: [
              IconButton(
                tooltip: 'Выйти из аккаунта',
                icon: const Icon(Icons.logout),
                onPressed: () => _confirmSignOut(context),
              ),
            ],
          ),
          body: Row(
            children: [
              FrostedRail(
                child: NavigationRail(
                  selectedIndex: model.selectedIndex,
                  onDestinationSelected: model.select,
                  extended: extendedRail,
                  useIndicator: true,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Tooltip(
                      message: 'Быстрые действия',
                      child: _logoFab(
                        context,
                        heroTag: 'launcher-fab-rail',
                        size: fabSizeRailSmall,
                        small: true,
                        onPressed: () => _showQuickAddSheet(context, model),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Главная'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.flag_outlined),
                      selectedIcon: Icon(Icons.flag),
                      label: Text('Цели'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.mood_outlined),
                      selectedIcon: Icon(Icons.mood),
                      label: Text('Настроение'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Профиль'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights),
                      label: Text('Отчёты'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.account_balance_wallet_outlined),
                      selectedIcon: Icon(Icons.account_balance_wallet),
                      label: Text('Расходы'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: extendedRail ? 32 : 24,
                    vertical: 12,
                  ),
                  child: NotificationListener<UserScrollNotification>(
                    onNotification: (n) {
                      if (isDashboard) _onDashboardScroll(n.direction);
                      return false;
                    },
                    child: content,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.surface,
        );
      },
    );
  }
}

// ============================================================================
// ✅ НАЧАЛЬНЫЙ ЭКРАН (TAB 0): “Главная” — улучшенный UI/UX
// ============================================================================

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final r = ReportsModel();
            r.setPeriod(ReportPeriod.week); // ✅ всегда неделя
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
  // Mood composer
  bool _editingMood = false;
  String _selectedEmoji = '😊';
  final TextEditingController _noteCtrl = TextEditingController();
  bool _savingMood = false;

  @override
  bool get wantKeepAlive => true;

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
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настроение сохранено'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _savingMood = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось сохранить: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _go(BuildContext context, int index) {
    context.read<HomeModel>().select(index);
  }

  // ---------- Expense insights helpers ----------
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

  // ---------- unified CTA ----------
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
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final reports = context.watch<ReportsModel>();
    final moodModel = context.watch<MoodModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // если где-то поменяли period — возвращаем на week
    if (reports.period != ReportPeriod.week) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ReportsModel>().setPeriod(ReportPeriod.week);
      });
    }

    final todayMood = _todayMood(moodModel.moods);

    // hero values
    final heroTasks = reports.loading
        ? null
        : reports.goalsInRange.where((g) => g.isCompleted).length;
    final heroHours = reports.loading ? null : reports.totalHours;
    final heroEff = reports.loading ? null : reports.efficiency;

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
                    'Сегодня и неделя',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Короткий обзор — затем детали ниже',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _HeroPill(
                        icon: Icons.mood_rounded,
                        label: todayMood?.emoji ?? '—',
                        sublabel: 'Настроение',
                      ),
                      _HeroPill(
                        icon: Icons.check_circle_rounded,
                        label: heroTasks == null ? '…' : heroTasks.toString(),
                        sublabel: 'Выполнено',
                      ),
                      _HeroPill(
                        icon: Icons.timer_outlined,
                        label: heroHours == null
                            ? '…'
                            : heroHours.toStringAsFixed(1),
                        sublabel: 'Часов',
                      ),
                      _HeroPill(
                        icon: Icons.speed_rounded,
                        label: heroEff == null
                            ? '…'
                            : '${(heroEff * 100).round()}%',
                        sublabel: 'Эффект.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Настроение сегодня
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ReportSectionCard(
                title: 'Настроение сегодня',
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
                                          ? 'Записи за сегодня нет'
                                          : (todayMood.note.trim().isEmpty
                                                ? 'Запись есть (без заметки)'
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
                                          ? 'Сделай быструю отметку — это 10 секунд'
                                          : 'Можно обновить — запись перезапишется за сегодня',
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
                                tooltip: _editingMood ? 'Свернуть' : 'Обновить',
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
                                            labelText:
                                                'Заметка (необязательно)',
                                            hintText:
                                                'Что повлияло на состояние?',
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
                                                  ? 'Сохранение…'
                                                  : 'Сохранить',
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
                            label: 'Открыть историю настроений',
                            onPressed: () => _go(context, 2),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // Сводка недели
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ReportSectionCard(
                title: 'Сводка недели',
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
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ReportStatCard(
                                title: 'Выполнено задач',
                                value: reports.goalsInRange
                                    .where((g) => g.isCompleted)
                                    .length
                                    .toString(),
                                icon: Icons.check_circle,
                              ),
                              ReportStatCard(
                                title: 'Часы (факт)',
                                value: reports.totalHours.toStringAsFixed(1),
                                icon: Icons.timer_outlined,
                              ),
                              ReportStatCard(
                                title: 'Эффективность',
                                value: '${(reports.efficiency * 100).round()}%',
                                icon: Icons.speed,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'План: ${reports.plannedHours.toStringAsFixed(1)} ч • Факт: ${reports.totalHours.toStringAsFixed(1)} ч',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant.withOpacity(0.95),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _cta(
                            context,
                            icon: Icons.insights_rounded,
                            label: 'Открыть подробные отчёты',
                            onPressed: () => _go(context, 4),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // Расходы недели
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: ReportSectionCard(
                title: 'Расходы недели',
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
                                  'Нет расходов за неделю',
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _cta(
                                  context,
                                  icon: Icons.account_balance_wallet_rounded,
                                  label: 'Открыть расходы',
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
                                'Всего: ${data.total.toStringAsFixed(2)} €',
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Средний расход/день: ${avg.toStringAsFixed(2)} €',
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
                                        'Инсайты',
                                        style: tt.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if (topCat != null)
                                        Text(
                                          '• Топ категория: ${topCat.key} — ${topCat.value.toStringAsFixed(2)} €',
                                          style: tt.bodyMedium?.copyWith(
                                            color: cs.onSurfaceVariant
                                                .withOpacity(0.98),
                                          ),
                                        ),
                                      if (peak != null)
                                        Text(
                                          '• Пик расхода: ${_formatDayShort(context, peak.key)} — ${peak.value.toStringAsFixed(2)} €',
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
                                label: 'Открыть подробные расходы',
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

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;

  const _HeroPill({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                sublabel,
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
