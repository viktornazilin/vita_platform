// lib/screens/home_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/home_model.dart';
import 'goals_screen.dart';
import 'mood_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'expenses_screen.dart';
import '../main.dart'; // dbRepo

// вынесенные виджеты (у тебя все лежит прямо в widgets/)
import '../widgets/frosted_rail.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/launcher_tile.dart';
import '../widgets/mass_daily_entry_sheet.dart';
import '../widgets/recurring_goal_sheet.dart';
// ✅ новые AI виджеты
import '../widgets/ai_plan_sheet.dart';
import '../widgets/ai_insights_sheet.dart';

// ✅ модель для результата ai-plan (если AiPlanSheet возвращает List<AiSuggestion>)
import '../models/ai/ai_suggestion.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _screens = <Widget>[
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

class _HomeView extends StatelessWidget {
  const _HomeView();

  static final PageStorageBucket _bucket = PageStorageBucket();

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

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeModel>();
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        // размеры FAB: большой в компактном режиме, небольшой в рейле
        final double fabSizeCompact = 140;
        final double fabSizeRailSmall = 44;

        // контент с анимацией
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

        // чтобы большой FAB не перекрывал нижний контент
        if (isCompact) {
          final bottomSafe = MediaQuery.of(context).padding.bottom;
          content = Padding(
            padding: EdgeInsets.only(
              bottom: (fabSizeCompact / 2) + bottomSafe + 16,
            ),
            child: content,
          );
        }

        if (isCompact) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('MyNEST'),
              actions: [
                IconButton(
                  tooltip: 'Выйти из аккаунта',
                  icon: const Icon(Icons.logout),
                  onPressed: () => _confirmSignOut(context),
                ),
              ],
            ),
            body: content,

            // ▼▼ БОЛЬШОЙ FAB С ЛОГОТИПОМ ▼▼
            floatingActionButton: _logoFab(
              context,
              heroTag: 'launcher-fab',
              size: fabSizeCompact,
              onPressed: () => _showQuickAddSheet(context, model),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            backgroundColor: theme.colorScheme.surface,
          );
        }

        final extendedRail = constraints.maxWidth >= 1200;
        return Scaffold(
          appBar: AppBar(
            title: const Text('MyNEST'),
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
                      message: 'Массовое добавление за день',
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
                  child: content,
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.surface,
        );
      },
    );
  }

  // helper для склейки даты и TimeOfDay
  DateTime _combine(DateTime day, TimeOfDay t) =>
      DateTime(day.year, day.month, day.day, t.hour, t.minute);

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
                    icon: Icons.flag,
                    label: 'Цели',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(0);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.mood,
                    label: 'Настроение',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(1);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.person,
                    label: 'Профиль',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(2);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.insights,
                    label: 'Отчёты',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(3);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.account_balance_wallet,
                    label: 'Расходы',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(4);
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
              QuickActionTile(
                icon: Icons.bolt,
                color: cs.primary,
                title: 'Массовое добавление за день',
                subtitle: 'Расходы + Задачи + Настроение',
                onTap: () async {
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
                        builder: (_) => const MassDailyEntrySheet(),
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
                          categoryId: e.categoryId, // ✅ ID из dropdown
                          amount: e.amount,
                          note: e.note.isEmpty ? null : e.note,
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

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Сохранено: '
                            '${result.expenses.length} расход(ов), '
                            '${result.goals.length} задач(и)'
                            '${result.mood != null ? ', настроение' : ''}',
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка сохранения: $e')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 6),

              // 🔮 AI-план (через Supabase Edge Function)
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
                    Navigator.pop(ctx); // закрыть лаунчер
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

                  // --- генерация дат
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

                    // weekly
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
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Нет дат для создания (проверь дедлайн/настройки).',
                          ),
                        ),
                      );
                    }
                    return;
                  }

                  // --- создаём goals
                  try {
                    // можно закрыть sheet сразу, чтобы UI не "висел"
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

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Создано целей: ${occurrences.length}'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Не удалось создать серию целей: $e'),
                        ),
                      );
                    }
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
}
