// lib/screens/home_screen.dart
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

// вынесенные виджеты
import '../widgets/frosted_rail.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/launcher_tile.dart';
import '../widgets/mass_daily_entry_sheet.dart';

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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Выйти')),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось выйти: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeModel>();
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        final content = SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetTween = Tween<Offset>(begin: const Offset(0.02, 0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic));
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: animation.drive(offsetTween), child: child),
              );
            },
            child: PageStorage(
              key: ValueKey(model.selectedIndex),
              bucket: _bucket,
              child: IndexedStack(index: model.selectedIndex, children: HomeScreen._screens),
            ),
          ),
        );

        if (isCompact) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('VitaPlatform'),
              actions: [
                IconButton(
                  tooltip: 'Выйти из аккаунта',
                  icon: const Icon(Icons.logout),
                  onPressed: () => _confirmSignOut(context),
                ),
              ],
            ),
            body: content,
            floatingActionButton: FloatingActionButton(
              heroTag: 'launcher-fab',
              onPressed: () => _showQuickAddSheet(context, model),
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            backgroundColor: theme.colorScheme.surface,
          );
        }

        final extendedRail = constraints.maxWidth >= 1200;
        return Scaffold(
          appBar: AppBar(
            title: const Text('VitaPlatform'),
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
                      child: FloatingActionButton.small(
                        heroTag: 'launcher-fab-rail',
                        onPressed: () => _showQuickAddSheet(context, model),
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: Text('Цели')),
                    NavigationRailDestination(icon: Icon(Icons.mood_outlined), selectedIcon: Icon(Icons.mood), label: Text('Настроение')),
                    NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Профиль')),
                    NavigationRailDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: Text('Отчёты')),
                    NavigationRailDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: Text('Расходы')),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: extendedRail ? 32 : 24, vertical: 12),
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
  DateTime _combine(DateTime day, TimeOfDay t) => DateTime(day.year, day.month, day.day, t.hour, t.minute);

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
            16 + MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom,
          ),
          child: Column(
            children: [
              // Разделы
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Разделы', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .95),
                children: [
                  LauncherTile(icon: Icons.flag, label: 'Цели',    onTap: () { Navigator.pop(ctx); model.select(0); }),
                  LauncherTile(icon: Icons.mood, label: 'Настроение', onTap: () { Navigator.pop(ctx); model.select(1); }),
                  LauncherTile(icon: Icons.person, label: 'Профиль', onTap: () { Navigator.pop(ctx); model.select(2); }),
                  LauncherTile(icon: Icons.insights, label: 'Отчёты', onTap: () { Navigator.pop(ctx); model.select(3); }),
                  LauncherTile(icon: Icons.account_balance_wallet, label: 'Расходы', onTap: () { Navigator.pop(ctx); model.select(4); }),
                ],
              ),
              const SizedBox(height: 16),

              // Быстро
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Быстро', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 6),
              QuickActionTile(
                icon: Icons.bolt,
                color: cs.primary,
                title: 'Массовое добавление за день',
                subtitle: 'Расходы + Задачи + Настроение',
                onTap: () async {
                  final result = await showModalBottomSheet<MassDailyEntryResult>(
                    context: ctx,
                    useSafeArea: true,
                    isScrollControlled: true,
                    backgroundColor: cs.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                        final catId = await dbRepo.ensureCategory(e.category, 'expense');
                        final ts = DateTime(result.date.year, result.date.month, result.date.day, 12, 0);
                        await dbRepo.addTransaction(
                          ts: ts,
                          kind: 'expense',
                          categoryId: catId,
                          amount: e.amount,
                          note: e.note.isEmpty ? null : e.note,
                        );
                      }

                      // 3) Задачи
                      for (final g in result.goals) {
                        final start = _combine(result.date, g.startTime ?? const TimeOfDay(hour: 9, minute: 0));
                        final deadline = DateTime(result.date.year, result.date.month, result.date.day, 23, 59, 0);

                        final desc = g.hours > 0
                            ? 'План: ${g.hours.toStringAsFixed(g.hours.truncateToDouble()==g.hours ? 0 : 1)} ч'
                            : '';

                        await dbRepo.createGoal(
                          title: g.title,
                          description: desc,
                          deadline: deadline,
                          lifeBlock: 'general',
                          importance: 1,
                          emotion: '',
                          spentHours: 0,
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
            ],
          ),
        ),
      ),
    );
  }
}
