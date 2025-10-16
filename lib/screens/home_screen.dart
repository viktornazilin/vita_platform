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

        // чтобы большой FAB не перекрывал нижний контент
        if (isCompact) {
          final bottomSafe = MediaQuery.of(context).padding.bottom;
          content = Padding(
            padding: EdgeInsets.only(bottom: (fabSizeCompact / 2) + bottomSafe + 16),
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
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                  LauncherTile(icon: Icons.flag, label: 'Цели', onTap: () { Navigator.pop(ctx); model.select(0); }),
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
              const SizedBox(height: 6),

              // 🔮 AI-план
              QuickActionTile(
                icon: Icons.auto_awesome,
                color: cs.tertiary,
                title: 'AI-план на неделю/месяц',
                subtitle: 'Анализ целей, опроса и прогресса',
                onTap: () async {
                  final suggestions = await showModalBottomSheet<List<_AiSuggestion>>(
                    context: ctx,
                    useSafeArea: true,
                    isScrollControlled: true,
                    backgroundColor: cs.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => const _AiPlanSheet(),
                  );

                  if (suggestions == null || suggestions.isEmpty) return;

                  // применяем
                  try {
                    for (final s in suggestions) {
                      final start = s.toStartDateTime();
                      final deadline = DateTime(start.year, start.month, start.day, 23, 59);
                      await dbRepo.createGoal(
                        title: s.title,
                        description: s.description ?? '',
                        deadline: deadline,
                        lifeBlock: s.lifeBlock ?? 'general',
                        importance: s.importance ?? 1,
                        emotion: '',
                        spentHours: 0,
                        startTime: start,
                      );
                    }
                    if (context.mounted) {
                      Navigator.pop(ctx); // закрыть лаунчер
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Добавлено целей: ${suggestions.length}')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Не удалось применить AI-план: $e')),
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

/// ─────────────────────────────
/// AI-планировщик (шторка)
/// ─────────────────────────────

enum _AiPeriod { week, month }

class _AiPlanSheet extends StatefulWidget {
  const _AiPlanSheet();

  @override
  State<_AiPlanSheet> createState() => _AiPlanSheetState();
}

class _AiPlanSheetState extends State<_AiPlanSheet> {
  _AiPeriod _period = _AiPeriod.week;
  bool _loading = false;
  String? _error;
  List<_AiSuggestion> _items = [];

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // вызываем Edge Function (рекомендуется)
      final res = await Supabase.instance.client.functions.invoke(
        'ai-plan',
        body: {'period': _period.name},
      );

      // допускаем, что res.data уже Map/List; нормализуем
      final data = res.data is String ? jsonDecode(res.data as String) : res.data;
      final list = (data as List).map((e) => _AiSuggestion.fromJson(e as Map<String, dynamic>, _period)).toList();

      setState(() => _items = list);
    } catch (e) {
      setState(() => _error = 'Ошибка AI: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggle(int i, bool v) {
    setState(() => _items[i] = _items[i].copyWith(selected: v));
  }

  Future<void> _edit(int i) async {
    final s = _items[i];
    final titleCtrl = TextEditingController(text: s.title);
    final descCtrl = TextEditingController(text: s.description ?? '');
    TimeOfDay t = s.time;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Редактировать цель'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Название')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Описание')),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Время:'),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(t.format(ctx)),
                  onPressed: () async {
                    final p = await showTimePicker(context: ctx, initialTime: t);
                    if (p != null) {
                      t = p;
                      // ignore: use_build_context_synchronously
                      (ctx as Element).markNeedsBuild();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Сохранить')),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        _items[i] = s.copyWith(
          title: titleCtrl.text.trim().isEmpty ? s.title : titleCtrl.text.trim(),
          description: descCtrl.text.trim(),
          time: t,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (ctx, controller) => Column(
            children: [
              const SizedBox(height: 8),
              Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('AI-план', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    SegmentedButton<_AiPeriod>(
                      segments: const [
                        ButtonSegment(value: _AiPeriod.week, label: Text('Неделя')),
                        ButtonSegment(value: _AiPeriod.month, label: Text('Месяц')),
                      ],
                      selected: {_period},
                      onSelectionChanged: (s) => setState(() => _period = s.first),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _loading ? null : _load,
                      icon: _loading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.auto_awesome),
                      label: const Text('Сгенерировать'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(_error!, style: TextStyle(color: cs.error)),
                ),
              const SizedBox(height: 4),
              Expanded(
                child: _items.isEmpty && !_loading
                    ? const Center(child: Text('Нажми «Сгенерировать», чтобы получить предложения'))
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final it = _items[i];
                          return _AiSuggestionTile(
                            item: it,
                            onToggle: (v) => _toggle(i, v),
                            onEdit: () => _edit(i),
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Добавить выбранные'),
                      onPressed: _items.any((e) => e.selected)
                          ? () => Navigator.pop(context, _items.where((e) => e.selected).toList())
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiSuggestionTile extends StatelessWidget {
  final _AiSuggestion item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const _AiSuggestionTile({
    required this.item,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final d = item.displayDate;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
    final timeStr = item.time.format(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: item.selected, onChanged: (v) => onToggle(v ?? true)),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: -6,
                    children: [
                      _Chip(icon: Icons.calendar_today, text: dateStr),
                      _Chip(icon: Icons.access_time, text: timeStr),
                      if (item.lifeBlock != null) _Chip(icon: Icons.category_outlined, text: item.lifeBlock!),
                      if (item.hours != null)
                        _Chip(
                          icon: Icons.timer_outlined,
                          text:
                              '${item.hours!.toStringAsFixed(item.hours!.truncateToDouble() == item.hours ? 0 : 1)} ч',
                        ),
                      if ((item.description ?? '').isNotEmpty)
                        Text(item.description!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.labelSmall),
      ]),
    );
  }
}

/// Модель предложения от AI
class _AiSuggestion {
  final String title;
  final String? description;
  final String? lifeBlock;
  final double? hours;
  final int? importance;

  /// либо явная дата (ISO от функции), либо weekday (1=Пн) + базовая неделя
  final DateTime? explicitDate;
  final int? weekday; // 1..7

  final TimeOfDay time;

  final _AiPeriod periodSource; // для вычисления дат по умолчанию
  final bool selected;

  _AiSuggestion({
    required this.title,
    required this.periodSource,
    required this.time,
    this.description,
    this.lifeBlock,
    this.hours,
    this.importance,
    this.explicitDate,
    this.weekday,
    this.selected = true,
  });

  factory _AiSuggestion.fromJson(Map<String, dynamic> m, _AiPeriod p) {
    // time
    TimeOfDay parseTime(dynamic v) {
      if (v is String && RegExp(r'^\d{1,2}:\d{2}$').hasMatch(v)) {
        final hh = int.parse(v.split(':')[0]);
        final mm = int.parse(v.split(':')[1]);
        return TimeOfDay(hour: hh.clamp(0, 23), minute: mm.clamp(0, 59));
      } else {
        return const TimeOfDay(hour: 9, minute: 0);
      }
    }

    DateTime? parseDate(dynamic v) {
      if (v is String && v.isNotEmpty) {
        final d = DateTime.tryParse(v);
        if (d != null) return DateUtils.dateOnly(d);
      }
      return null;
    }

    return _AiSuggestion(
      title: (m['title'] as String?)?.trim().isNotEmpty == true ? m['title'] as String : 'Без названия',
      description: (m['description'] as String?)?.trim(),
      lifeBlock: (m['life_block'] as String?)?.trim().isEmpty == true ? null : m['life_block'] as String?,
      hours: (m['hours'] is num) ? (m['hours'] as num).toDouble() : null,
      importance: (m['importance'] as int?) ?? 1,
      explicitDate: parseDate(m['date']),
      weekday: (m['weekday'] is num) ? (m['weekday'] as num).toInt().clamp(1, 7) : null,
      time: parseTime(m['time']),
      periodSource: p,
    );
  }

  _AiSuggestion copyWith({
    String? title,
    String? description,
    TimeOfDay? time,
    bool? selected,
  }) {
    return _AiSuggestion(
      title: title ?? this.title,
      description: description ?? this.description,
      lifeBlock: lifeBlock,
      hours: hours,
      importance: importance,
      explicitDate: explicitDate,
      weekday: weekday,
      time: time ?? this.time,
      periodSource: periodSource,
      selected: selected ?? this.selected,
    );
  }

  /// Дата для отображения в UI
  DateTime get displayDate => explicitDate ?? _defaultDateByPeriod();

  /// Преобразование в конкретный DateTime начала
  DateTime toStartDateTime() {
    final baseDate = displayDate;
    return DateTime(baseDate.year, baseDate.month, baseDate.day, time.hour, time.minute);
  }

  DateTime _defaultDateByPeriod() {
    final now = DateTime.now();
    if (periodSource == _AiPeriod.week) {
      // след. понедельник
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final nextMonday = monday.add(const Duration(days: 7));
      final wd = (weekday ?? 1).clamp(1, 7);
      return DateUtils.dateOnly(nextMonday.add(Duration(days: wd - 1)));
    } else {
      // следующий месяц, тот же день если есть, иначе 1 число
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      if (weekday != null) {
        final wd = weekday!.clamp(1, 7);
        // первая неделя месяца + offset
        final firstDay = DateTime(nextMonth.year, nextMonth.month, 1);
        final shift = (DateTime.monday - firstDay.weekday) % 7; // до понедельника
        final firstMonday = firstDay.add(Duration(days: shift));
        return DateUtils.dateOnly(firstMonday.add(Duration(days: wd - 1)));
      }
      return DateUtils.dateOnly(nextMonth);
    }
  }
}
