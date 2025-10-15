// lib/screens/home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/home_model.dart';
import 'goals_screen.dart';
import 'mood_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'expenses_screen.dart';

// репозиторий
import '../main.dart'; // dbRepo

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось выйти: $e')),
      );
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
              final offsetTween = Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
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
              _FrostedRail(
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

    showModalBottomSheet<_MassDailyEntryResult>(
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
                  _LauncherTile(icon: Icons.flag, label: 'Цели',    onTap: () { Navigator.pop(ctx); model.select(0); }),
                  _LauncherTile(icon: Icons.mood, label: 'Настроение', onTap: () { Navigator.pop(ctx); model.select(1); }),
                  _LauncherTile(icon: Icons.person, label: 'Профиль', onTap: () { Navigator.pop(ctx); model.select(2); }),
                  _LauncherTile(icon: Icons.insights, label: 'Отчёты', onTap: () { Navigator.pop(ctx); model.select(3); }),
                  _LauncherTile(icon: Icons.account_balance_wallet, label: 'Расходы', onTap: () { Navigator.pop(ctx); model.select(4); }),
                ],
              ),
              const SizedBox(height: 16),

              // Быстро
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Быстро', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 6),
              _QuickActionTile(
                icon: Icons.bolt,
                color: cs.primary,
                title: 'Массовое добавление за день',
                subtitle: 'Расходы + Задачи + Настроение',
                onTap: () async {
                  final result = await showModalBottomSheet<_MassDailyEntryResult>(
                    context: ctx,
                    useSafeArea: true,
                    isScrollControlled: true,
                    backgroundColor: cs.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => const _MassDailyEntrySheet(),
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

class _FrostedRail extends StatelessWidget {
  const _FrostedRail({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.85),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 6)),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: scheme.outline),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _LauncherTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _LauncherTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: cs.surfaceContainerHighest,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: cs.primary),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────
/// Массовое добавление за день
/// ─────────────────────────────

class _MassDailyEntrySheet extends StatefulWidget {
  const _MassDailyEntrySheet();

  @override
  State<_MassDailyEntrySheet> createState() => _MassDailyEntrySheetState();
}

class _MassDailyEntrySheetState extends State<_MassDailyEntrySheet> {
  DateTime _date = DateUtils.dateOnly(DateTime.now());

  // mood
  String? _emoji; // null = без настроения
  final _moodNote = TextEditingController();

  // expenses
  final List<_ExpenseRow> _expenses = [ _ExpenseRow() ];

  // goals
  final List<_GoalRow> _goals = [ _GoalRow() ];

  @override
  void dispose() {
    _moodNote.dispose();
    for (final e in _expenses) { e.dispose(); }
    for (final g in _goals) { g.dispose(); }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _date = DateUtils.dateOnly(d));
  }

  void _addExpenseRow() => setState(() => _expenses.add(_ExpenseRow()));
  void _addGoalRow() => setState(() => _goals.add(_GoalRow()));

  void _submit() {
    final mood = _emoji == null ? null : _MoodEntry(emoji: _emoji!, note: _moodNote.text.trim());
    final expenses = _expenses
        .map((r) => r.toEntry())
        .where((e) => e != null && e!.amount > 0 && e!.category.trim().isNotEmpty)
        .cast<_ExpenseEntry>()
        .toList();
    final goals = _goals
        .map((r) => r.toEntry())
        .where((g) => g != null && g!.title.trim().isNotEmpty)
        .cast<_GoalEntry>()
        .toList();

    Navigator.pop(context, _MassDailyEntryResult(
      date: _date,
      mood: mood,
      expenses: expenses,
      goals: goals,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          8,
          8,
          8,
          8 + MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Массовое добавление за день', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(child: Text('Дата: ${_fmtDate(_date)}')),
                    TextButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_month), label: const Text('Выбрать')),
                  ],
                ),
                const SizedBox(height: 8),

                _SectionCard(
                  title: 'Настроение (необязательно)',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EmojiPicker(
                        initial: _emoji,
                        onSelect: (e) => setState(() => _emoji = e),
                        onClear: () => setState(() => _emoji = null),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _moodNote,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Заметка',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                _SectionCard(
                  title: 'Расходы',
                  trailing: IconButton(
                    tooltip: 'Добавить строку',
                    onPressed: _addExpenseRow,
                    icon: const Icon(Icons.add),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < _expenses.length; i++) ...[
                        _expenses[i],
                        if (i != _expenses.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                _SectionCard(
                  title: 'Задачи',
                  trailing: IconButton(
                    tooltip: 'Добавить строку',
                    onPressed: _addGoalRow,
                    icon: const Icon(Icons.add),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < _goals.length; i++) ...[
                        _goals[i],
                        if (i != _goals.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check),
                        label: const Text('Сохранить всё'),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Пустые строки игнорируются. Категорию расходов можно вписать текстом — мы создадим её, если нужно.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(child: Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ]),
      ),
    );
  }
}

class _EmojiPicker extends StatelessWidget {
  final String? initial;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;
  const _EmojiPicker({this.initial, required this.onSelect, required this.onClear});

  static const _emojis = ['😄','🙂','😐','😕','😢','😡','🤩','😴','🤒','🤯'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6, runSpacing: 6,
      children: [
        for (final e in _emojis)
          ChoiceChip(
            label: Text(e, style: const TextStyle(fontSize: 18)),
            selected: initial == e,
            onSelected: (_) => onSelect(e),
          ),
        ActionChip(
          avatar: Icon(Icons.close, size: 16, color: cs.onSurfaceVariant),
          label: const Text('Без настроения'),
          onPressed: onClear,
        ),
      ],
    );
  }
}

class _ExpenseRow extends StatefulWidget {
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  _ExpenseEntry? toEntry() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    final category = _categoryCtrl.text.trim();
    final note = _noteCtrl.text.trim();
    if (amount <= 0 || category.isEmpty) return null;
    return _ExpenseEntry(amount: amount, category: category, note: note);
  }

  void dispose() {
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    _noteCtrl.dispose();
  }

  @override
  State<_ExpenseRow> createState() => _ExpenseRowState();
}

class _ExpenseRowState extends State<_ExpenseRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: TextField(
            controller: widget._amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Сумма',
              prefixText: '₽ ',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: widget._categoryCtrl,
            decoration: const InputDecoration(
              labelText: 'Категория',
              hintText: 'Еда, Транспорт…',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: widget._noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Заметка',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalRow extends StatefulWidget {
  final _titleCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '1.0');
  TimeOfDay? _time;

  _GoalEntry? toEntry() {
    final title = _titleCtrl.text.trim();
    final hours = double.tryParse(_hoursCtrl.text.replaceAll(',', '.')) ?? 0;
    if (title.isEmpty) return null;
    return _GoalEntry(title: title, hours: hours <= 0 ? 1 : hours, startTime: _time);
  }

  void dispose() {
    _titleCtrl.dispose();
    _hoursCtrl.dispose();
  }

  @override
  State<_GoalRow> createState() => _GoalRowState();
}

class _GoalRowState extends State<_GoalRow> {
  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: widget._time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => widget._time = t);
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = widget._time == null ? 'Время (опц.)' : widget._time!.format(context);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: widget._titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Название задачи',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 96,
          child: TextField(
            controller: widget._hoursCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Часы',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 132,
          child: OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.access_time),
            label: Text(timeLabel, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}

class _MassDailyEntryResult {
  final DateTime date;
  final _MoodEntry? mood;
  final List<_ExpenseEntry> expenses;
  final List<_GoalEntry> goals;

  _MassDailyEntryResult({
    required this.date,
    required this.mood,
    required this.expenses,
    required this.goals,
  });
}

class _MoodEntry {
  final String emoji;
  final String note;
  _MoodEntry({required this.emoji, required this.note});
}

class _ExpenseEntry {
  final double amount;
  final String category;
  final String note;
  _ExpenseEntry({required this.amount, required this.category, required this.note});
}

class _GoalEntry {
  final String title;
  final double hours;
  final TimeOfDay? startTime;
  _GoalEntry({required this.title, required this.hours, required this.startTime});
}
