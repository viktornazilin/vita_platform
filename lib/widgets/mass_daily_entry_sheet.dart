import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/category.dart' as dm;
import '../main.dart';
import '../models/life_block.dart';
import '../models/mental_question.dart';
import '../widgets/add_day_goal_sheet.dart';
import '../widgets/block_chip.dart';

class MassDailyEntrySheet extends StatefulWidget {
  final List<String> availableBlocks;
  const MassDailyEntrySheet({
    super.key,
    required this.availableBlocks,
  });

  @override
  State<MassDailyEntrySheet> createState() => _MassDailyEntrySheetState();
}

class _MassDailyEntrySheetState extends State<MassDailyEntrySheet> {
  DateTime _date = DateUtils.dateOnly(DateTime.now());

  final _pageCtrl = PageController();
  int _step = 0;
  static const int _stepsCount = 4;

  String? _emoji;
  final _moodNote = TextEditingController();

  bool _habitsLoading = false;
  String? _habitsError;
  List<_HabitVm> _habits = [];

  final List<_ExpenseRow> _expenses = [_ExpenseRow()];
  final List<_IncomeRow> _incomes = [_IncomeRow()];
  final List<_GoalRow> _goals = [_GoalRow()];

  bool _mentalLoading = false;
  String? _mentalError;
  List<MentalQuestion> _mentalQuestions = [];
  final Map<String, _MentalAnswerVm> _mentalVm = {};

  bool _expenseCatsLoading = false;
  List<dm.Category> _expenseCats = [];

  bool _incomeCatsLoading = false;
  List<dm.Category> _incomeCats = [];

  static const List<String> _goalEmojis = [
    '😄',
    '🙂',
    '😐',
    '😕',
    '😢',
    '😡',
    '🤩',
    '😴',
    '🤒',
    '🤯',
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenseCategories();
    _loadIncomeCategories();
    _loadHabitsForDay(_date);
    _loadMentalForDay(_date);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _moodNote.dispose();

    for (final h in _habits) {
      h.dispose();
    }
    for (final e in _expenses) {
      e.dispose();
    }
    for (final i in _incomes) {
      i.dispose();
    }
    for (final g in _goals) {
      g.dispose();
    }

    super.dispose();
  }

  List<String> _goalLifeBlocks() {
    final seen = <String>{};
    final blocks = <String>['general'];

    for (final raw in widget.availableBlocks) {
      final value = raw.trim();
      if (value.isEmpty) continue;

      final key = value.toLowerCase();
      if (key == 'general') continue;

      if (seen.add(key)) {
        blocks.add(key);
      }
    }

    return blocks;
  }

  Future<void> _loadExpenseCategories() async {
    setState(() => _expenseCatsLoading = true);
    try {
      final res = await dbRepo.listCategories(kind: 'expense');
      if (!mounted) return;
      setState(() => _expenseCats = res);
    } catch (_) {
      if (!mounted) return;
      setState(() => _expenseCats = []);
    } finally {
      if (mounted) setState(() => _expenseCatsLoading = false);
    }
  }

  Future<void> _loadIncomeCategories() async {
    setState(() => _incomeCatsLoading = true);
    try {
      final res = await dbRepo.listCategories(kind: 'income');
      if (!mounted) return;
      setState(() => _incomeCats = res);
    } catch (_) {
      if (!mounted) return;
      setState(() => _incomeCats = []);
    } finally {
      if (mounted) setState(() => _incomeCatsLoading = false);
    }
  }

  Future<void> _loadHabitsForDay(DateTime day) async {
    for (final h in _habits) {
      h.dispose();
    }

    setState(() {
      _habitsLoading = true;
      _habitsError = null;
      _habits = [];
    });

    try {
      final habits = await dbRepo.listHabits();
      final entriesByHabitId = await dbRepo.getHabitEntriesForDay(day);

      if (!mounted) return;

      final list = habits.map((h) {
        final e = entriesByHabitId[h.id];
        final vm = _HabitVm(
          id: h.id,
          title: h.title,
          isNegative: h.isNegative,
        );

        final done = (e?['done'] as bool?) ?? false;
        final value = (e?['value'] as int?) ?? 0;

        vm.done = done;
        if (value > 0) vm.qtyCtrl.text = value.toString();

        return vm;
      }).toList();

      setState(() {
        _habitsLoading = false;
        _habits = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _habitsLoading = false;
        _habitsError = 'Не удалось загрузить привычки: $e';
        _habits = [];
      });
    }
  }

  Future<void> _loadMentalForDay(DateTime day) async {
    setState(() {
      _mentalLoading = true;
      _mentalError = null;
      _mentalQuestions = [];
      _mentalVm.clear();
    });

    try {
      final qs = await dbRepo.listMentalQuestions(onlyActive: true);
      final answers = await dbRepo.getMentalAnswersForDay(day);

      if (!mounted) return;

      for (final q in qs) {
        final a = answers[q.id];
        _mentalVm[q.id] = _MentalAnswerVm(
          boolVal: a?['value_bool'] as bool?,
          intVal: a?['value_int'] as int?,
          textVal: (a?['value_text'] ?? '').toString(),
        );
      }

      setState(() {
        _mentalQuestions = qs;
        _mentalLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mentalLoading = false;
        _mentalError = 'Не удалось загрузить вопросы: $e';
      });
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) {
        final t = Theme.of(ctx);
        return Theme(
          data: t.copyWith(
            colorScheme: t.colorScheme.copyWith(
              primary: t.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (d != null) {
      final day = DateUtils.dateOnly(d);
      setState(() => _date = day);
      await _loadHabitsForDay(day);
      await _loadMentalForDay(day);
    }
  }

  void _addExpenseRow() => setState(() => _expenses.add(_ExpenseRow()));
  void _addIncomeRow() => setState(() => _incomes.add(_IncomeRow()));
  void _addGoalRow() => setState(() => _goals.add(_GoalRow()));

  Future<void> _goNext() async {
    if (_step >= _stepsCount - 1) return;
    setState(() => _step += 1);
    await _pageCtrl.animateToPage(
      _step,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _goPrev() async {
    if (_step <= 0) return;
    setState(() => _step -= 1);
    await _pageCtrl.animateToPage(
      _step,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _submit() {
    final mood = _emoji == null
        ? null
        : _MoodEntry(
            emoji: _emoji!,
            note: _moodNote.text.trim(),
          );

    final habitEntries = _habits
        .map((h) => h.toEntry())
        .whereType<_HabitEntry>()
        .toList();

    final expenses = _expenses
        .map((r) => r.toEntry())
        .where((e) => e != null && e!.amount > 0 && e.categoryId.isNotEmpty)
        .cast<_ExpenseEntry>()
        .toList();

    final incomes = _incomes
        .map((r) => r.toEntry())
        .where((e) => e != null && e!.amount > 0 && e.categoryId.isNotEmpty)
        .cast<_IncomeEntry>()
        .toList();

    final goals = _goals
        .map((r) => r.toEntry())
        .where((g) => g != null && g!.title.trim().isNotEmpty)
        .cast<_GoalEntry>()
        .toList();

    final mental = <_MentalAnswerEntry>[];

    for (final q in _mentalQuestions) {
      final vm = _mentalVm[q.id];
      if (vm == null) continue;

      final has = vm.boolVal != null ||
          vm.intVal != null ||
          ((vm.textVal ?? '').trim().isNotEmpty);

      if (!has) continue;

      mental.add(
        _MentalAnswerEntry(
          questionId: q.id,
          valueBool: vm.boolVal,
          valueInt: vm.intVal,
          valueText: (vm.textVal ?? '').trim(),
        ),
      );
    }

    Navigator.pop(
      context,
      MassDailyEntryResult(
        date: _date,
        mood: mood,
        habits: habitEntries,
        mental: mental,
        expenses: expenses,
        incomes: incomes,
        goals: goals,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final canGoBack = _step > 0;
    final isLast = _step == _stepsCount - 1;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          12 +
              MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TopHeader(
                  title: 'Массовое добавление за день',
                  step: _step + 1,
                  totalSteps: _stepsCount,
                ),
                const SizedBox(height: 10),
                _SubHeader(
                  dateLabel: _fmtDate(_date),
                  onPickDate: _pickDate,
                ),
                const SizedBox(height: 12),
                _ProgressRail(
                  currentStep: _step,
                  totalSteps: _stepsCount,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStepMoodHabits(context),
                      _buildStepMental(context),
                      _buildStepFinance(context),
                      _buildStepGoals(context),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: canGoBack
                            ? _goPrev
                            : () => Navigator.pop(context),
                        icon: Icon(
                          canGoBack
                              ? Icons.arrow_back_rounded
                              : Icons.close_rounded,
                        ),
                        label: Text(canGoBack ? 'Назад' : 'Отмена'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isLast ? _submit : _goNext,
                        icon: Icon(
                          isLast
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                        label: Text(isLast ? 'Сохранить всё' : 'Далее'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Пустые строки игнорируются.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepMoodHabits(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: 6),
      children: [
        _SectionCard(
          title: 'Настроение',
          subtitle: 'Необязательная запись о том, как прошёл день.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EmojiPicker(
                initial: _emoji,
                onSelect: (e) => setState(() => _emoji = e),
                onClear: () => setState(() => _emoji = null),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _moodNote,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Заметка',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Привычки',
          subtitle: 'Отметь выполнение и при необходимости укажи количество.',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_habitsLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              _InlineIconButton(
                tooltip: 'Обновить',
                onTap: () => _loadHabitsForDay(_date),
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_habitsError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _habitsError!,
                    style: tt.bodySmall?.copyWith(color: cs.error),
                  ),
                ),
              if (_habits.isEmpty && !_habitsLoading)
                Text(
                  'Пока нет привычек. Добавь их в профиле.',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              for (final h in _habits) ...[
                _HabitTile(
                  vm: h,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepMental(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: 6),
      children: [
        _SectionCard(
          title: 'Ментальное здоровье',
          subtitle:
              'Короткая ежедневная фиксация состояния для дальнейшей аналитики.',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_mentalLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              _InlineIconButton(
                tooltip: 'Обновить',
                onTap: () => _loadMentalForDay(_date),
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ответь на несколько вопросов — это поможет отслеживать состояние.',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              if (_mentalError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _mentalError!,
                    style: tt.bodySmall?.copyWith(color: cs.error),
                  ),
                ),
              if (_mentalQuestions.isEmpty && !_mentalLoading)
                Text(
                  'Пока нет вопросов. Добавь их в таблицу mental_questions.',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              for (final q in _mentalQuestions) ...[
                _MentalQuestionTile(
                  q: q,
                  vm: _mentalVm[q.id]!,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepFinance(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 6),
      children: [
        _SectionCard(
          title: 'Расходы',
          subtitle: 'Добавь траты за выбранный день.',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_expenseCatsLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              _InlineIconButton(
                tooltip: 'Добавить строку',
                onTap: _addExpenseRow,
                icon: Icons.add_rounded,
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < _expenses.length; i++) ...[
                _ExpenseRowView(
                  row: _expenses[i],
                  categories: _expenseCats,
                ),
                if (i != _expenses.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Доходы',
          subtitle: 'Добавь поступления за выбранный день.',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_incomeCatsLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              _InlineIconButton(
                tooltip: 'Добавить строку',
                onTap: _addIncomeRow,
                icon: Icons.add_rounded,
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < _incomes.length; i++) ...[
                _IncomeRowView(
                  row: _incomes[i],
                  categories: _incomeCats,
                ),
                if (i != _incomes.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepGoals(BuildContext context) {
    final lifeBlocks = _goalLifeBlocks();

    return ListView(
      padding: const EdgeInsets.only(bottom: 6),
      children: [
        _SectionCard(
          title: 'Задачи',
          subtitle:
              'Зафиксируй, над чем ты работал в этот день, и сколько времени это заняло.',
          trailing: _InlineIconButton(
            tooltip: 'Добавить строку',
            onTap: _addGoalRow,
            icon: Icons.add_rounded,
          ),
          child: Column(
            children: [
              for (int i = 0; i < _goals.length; i++) ...[
                _GoalRowView(
                  row: _goals[i],
                  lifeBlocks: lifeBlocks,
                  emotions: _goalEmojis,
                ),
                if (i != _goals.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }
}

class _Debouncer {
  _Debouncer(this.delay);

  final Duration delay;
  Timer? _t;

  void run(VoidCallback fn) {
    _t?.cancel();
    _t = Timer(delay, fn);
  }

  void dispose() => _t?.cancel();
}

class _TopHeader extends StatelessWidget {
  final String title;
  final int step;
  final int totalSteps;

  const _TopHeader({
    required this.title,
    required this.step,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                height: 1.05,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Text(
              '$step/$totalSteps',
              style: tt.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String dateLabel;
  final VoidCallback onPickDate;

  const _SubHeader({
    required this.dateLabel,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                children: [
                  TextSpan(
                    text: 'Дата: ',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  TextSpan(
                    text: dateLabel,
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_month_rounded),
            label: const Text('Выбрать'),
          ),
        ],
      ),
    );
  }
}

class _ProgressRail extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressRail({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(totalSteps, (index) {
        final active = index <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index == totalSteps - 1 ? 0 : 8,
            ),
            height: 6,
            decoration: BoxDecoration(
              color: active ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class _InlineIconButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onTap;
  final IconData icon;

  const _InlineIconButton({
    required this.tooltip,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Icon(
            icon,
            size: 18,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  subtitle == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmojiPicker extends StatelessWidget {
  final String? initial;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  const _EmojiPicker({
    this.initial,
    required this.onSelect,
    required this.onClear,
  });

  static const _emojis = [
    '😄',
    '🙂',
    '😐',
    '😕',
    '😢',
    '😡',
    '🤩',
    '😴',
    '🤒',
    '🤯',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in _emojis)
          ChoiceChip(
            label: Text(
              e,
              style: const TextStyle(fontSize: 18),
            ),
            selected: initial == e,
            onSelected: (_) => onSelect(e),
          ),
        ActionChip(
          avatar: Icon(
            Icons.close_rounded,
            size: 16,
            color: cs.onSurfaceVariant,
          ),
          label: const Text('Без настроения'),
          onPressed: onClear,
        ),
      ],
    );
  }
}

class _HabitVm {
  final String id;
  final String title;
  final bool isNegative;

  bool done = false;
  final TextEditingController qtyCtrl = TextEditingController();

  _HabitVm({
    required this.id,
    required this.title,
    required this.isNegative,
  });

  int _parseQty() {
    final raw = qtyCtrl.text.trim();
    if (raw.isEmpty) return 0;
    return int.tryParse(raw.replaceAll(',', '.').split('.').first) ?? 0;
  }

  _HabitEntry? toEntry() {
    final qty = _parseQty();
    if (!done && qty <= 0) return null;
    final value = qty > 0 ? qty : (done ? 1 : 0);
    return _HabitEntry(
      habitId: id,
      done: done,
      value: value,
    );
  }

  void dispose() => qtyCtrl.dispose();
}

class _HabitTile extends StatelessWidget {
  final _HabitVm vm;
  final VoidCallback onChanged;

  const _HabitTile({
    required this.vm,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final showQty = vm.isNegative || vm.done;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  vm.title,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              _TypePill(isNegative: vm.isNegative),
              const SizedBox(width: 10),
              Switch(
                value: vm.done,
                onChanged: (v) {
                  vm.done = v;
                  onChanged();
                },
              ),
            ],
          ),
          if (showQty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    vm.isNegative
                        ? 'Количество (например, сигареты)'
                        : 'Количество (необязательно)',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 116,
                  child: TextField(
                    controller: vm.qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Кол-во',
                      isDense: true,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final bool isNegative;

  const _TypePill({required this.isNegative});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final bg = isNegative ? cs.errorContainer : cs.surfaceContainerHigh;
    final fg = isNegative ? cs.onErrorContainer : cs.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        isNegative ? 'Негативная' : 'Позитивная',
        style: tt.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MentalQuestionTile extends StatelessWidget {
  final MentalQuestion q;
  final _MentalAnswerVm vm;
  final VoidCallback onChanged;

  const _MentalQuestionTile({
    required this.q,
    required this.vm,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    Widget body;

    switch (q.answerType) {
      case MentalAnswerType.yesNo:
        body = Row(
          children: [
            Expanded(
              child: Text(
                q.text,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            Switch(
              value: vm.boolVal ?? false,
              onChanged: (v) {
                vm.boolVal = v;
                onChanged();
              },
            ),
          ],
        );
        break;

      case MentalAnswerType.scale1to10:
      case MentalAnswerType.scale1to5:
        final min = q.minValue ?? 1;
        final max =
            q.maxValue ??
            (q.answerType == MentalAnswerType.scale1to10 ? 10 : 5);
        final current = (vm.intVal ?? min).clamp(min, max);

        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.text,
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '$min',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: current.toDouble(),
                    min: min.toDouble(),
                    max: max.toDouble(),
                    divisions: max - min,
                    label: current.toString(),
                    onChanged: (v) {
                      vm.intVal = v.round();
                      onChanged();
                    },
                  ),
                ),
                Text(
                  '$max',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    border: Border.all(color: cs.outlineVariant),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    current.toString(),
                    style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
        break;

      case MentalAnswerType.text:
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.text,
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: vm.textVal ?? '',
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Ответ',
              ),
              onChanged: (v) {
                vm.textVal = v;
                onChanged();
              },
            ),
          ],
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(18),
      ),
      child: body,
    );
  }
}

class _ExpenseRow {
  final _amountCtrl = TextEditingController();
  String? _categoryId;
  final _noteCtrl = TextEditingController();

  _ExpenseEntry? toEntry() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    final categoryId = (_categoryId ?? '').trim();
    final note = _noteCtrl.text.trim();
    if (amount <= 0 || categoryId.isEmpty) return null;
    return _ExpenseEntry(
      amount: amount,
      categoryId: categoryId,
      note: note,
    );
  }

  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
  }
}

class _ExpenseRowView extends StatefulWidget {
  final _ExpenseRow row;
  final List<dm.Category> categories;

  const _ExpenseRowView({
    required this.row,
    required this.categories,
  });

  @override
  State<_ExpenseRowView> createState() => _ExpenseRowViewState();
}

class _ExpenseRowViewState extends State<_ExpenseRowView> {
  final _debouncer = _Debouncer(const Duration(milliseconds: 250));
  bool _noteSugLoading = false;
  List<String> _noteSuggestions = [];
  int _reqId = 0;

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _searchNotes(String q) async {
    final myReq = ++_reqId;
    final query = q.trim();
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _noteSugLoading = false;
        _noteSuggestions = [];
      });
      return;
    }

    if (!mounted) return;
    setState(() => _noteSugLoading = true);

    try {
      final res = await dbRepo.searchTransactionNotes(
        kind: 'expense',
        query: query,
        limit: 8,
      );
      if (!mounted || myReq != _reqId) return;
      setState(() {
        _noteSuggestions = res;
        _noteSugLoading = false;
      });
    } catch (_) {
      if (!mounted || myReq != _reqId) return;
      setState(() {
        _noteSuggestions = [];
        _noteSugLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.categories;
    final hasCats = cats.isNotEmpty;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 640;

          final amountField = SizedBox(
            width: 116,
            child: TextField(
              controller: widget.row._amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Сумма',
                prefixText: '€',
                isDense: true,
              ),
            ),
          );

          final categoryField = DropdownButtonFormField<String>(
            value: widget.row._categoryId,
            isExpanded: true,
            items: hasCats
                ? cats
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          c.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList()
                : const [],
            onChanged: hasCats
                ? (v) => setState(() => widget.row._categoryId = v)
                : null,
            decoration: InputDecoration(
              labelText: 'Категория',
              isDense: true,
              hintText: hasCats ? null : 'Нет категорий',
            ),
          );

          final noteField = Autocomplete<String>(
            optionsBuilder: (TextEditingValue v) {
              final q = v.text.trim();
              if (q.isEmpty) return const Iterable<String>.empty();
              return _noteSuggestions.take(8);
            },
            onSelected: (val) {
              widget.row._noteCtrl.text = val;
              widget.row._noteCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: val.length),
              );
            },
            fieldViewBuilder:
                (context, textCtrl, focusNode, onFieldSubmitted) {
              if (textCtrl.text != widget.row._noteCtrl.text) {
                textCtrl.text = widget.row._noteCtrl.text;
                textCtrl.selection = widget.row._noteCtrl.selection;
              }

              return TextField(
                controller: textCtrl,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Заметка',
                  isDense: true,
                  suffixIcon: _noteSugLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : (_noteSuggestions.isNotEmpty
                          ? const Icon(Icons.history_rounded)
                          : null),
                ),
                onChanged: (v) {
                  widget.row._noteCtrl.value = textCtrl.value;
                  _debouncer.run(() => _searchNotes(v));
                },
                onSubmitted: (_) => onFieldSubmitted(),
              );
            },
          );

          if (narrow) {
            return Column(
              children: [
                Row(
                  children: [
                    amountField,
                    const SizedBox(width: 8),
                    Expanded(child: categoryField),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: noteField),
              ],
            );
          }

          return Row(
            children: [
              amountField,
              const SizedBox(width: 8),
              Expanded(flex: 2, child: categoryField),
              const SizedBox(width: 8),
              Expanded(flex: 3, child: noteField),
            ],
          );
        },
      ),
    );
  }
}

class _IncomeRow {
  final _amountCtrl = TextEditingController();
  String? _categoryId;
  final _noteCtrl = TextEditingController();

  _IncomeEntry? toEntry() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    final categoryId = (_categoryId ?? '').trim();
    final note = _noteCtrl.text.trim();
    if (amount <= 0 || categoryId.isEmpty) return null;
    return _IncomeEntry(
      amount: amount,
      categoryId: categoryId,
      note: note,
    );
  }

  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
  }
}

class _IncomeRowView extends StatefulWidget {
  final _IncomeRow row;
  final List<dm.Category> categories;

  const _IncomeRowView({
    required this.row,
    required this.categories,
  });

  @override
  State<_IncomeRowView> createState() => _IncomeRowViewState();
}

class _IncomeRowViewState extends State<_IncomeRowView> {
  final _debouncer = _Debouncer(const Duration(milliseconds: 250));
  bool _noteSugLoading = false;
  List<String> _noteSuggestions = [];
  int _reqId = 0;

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _searchNotes(String q) async {
    final myReq = ++_reqId;
    final query = q.trim();
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _noteSugLoading = false;
        _noteSuggestions = [];
      });
      return;
    }

    if (!mounted) return;
    setState(() => _noteSugLoading = true);

    try {
      final res = await dbRepo.searchTransactionNotes(
        kind: 'income',
        query: query,
        limit: 8,
      );
      if (!mounted || myReq != _reqId) return;
      setState(() {
        _noteSuggestions = res;
        _noteSugLoading = false;
      });
    } catch (_) {
      if (!mounted || myReq != _reqId) return;
      setState(() {
        _noteSuggestions = [];
        _noteSugLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.categories;
    final hasCats = cats.isNotEmpty;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 640;

          final amountField = SizedBox(
            width: 116,
            child: TextField(
              controller: widget.row._amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Сумма',
                prefixText: '€',
                isDense: true,
              ),
            ),
          );

          final categoryField = DropdownButtonFormField<String>(
            value: widget.row._categoryId,
            isExpanded: true,
            items: hasCats
                ? cats
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          c.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList()
                : const [],
            onChanged: hasCats
                ? (v) => setState(() => widget.row._categoryId = v)
                : null,
            decoration: InputDecoration(
              labelText: 'Категория',
              isDense: true,
              hintText: hasCats ? null : 'Нет категорий',
            ),
          );

          final noteField = Autocomplete<String>(
            optionsBuilder: (TextEditingValue v) {
              final q = v.text.trim();
              if (q.isEmpty) return const Iterable<String>.empty();
              return _noteSuggestions.take(8);
            },
            onSelected: (val) {
              widget.row._noteCtrl.text = val;
              widget.row._noteCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: val.length),
              );
            },
            fieldViewBuilder:
                (context, textCtrl, focusNode, onFieldSubmitted) {
              if (textCtrl.text != widget.row._noteCtrl.text) {
                textCtrl.text = widget.row._noteCtrl.text;
                textCtrl.selection = widget.row._noteCtrl.selection;
              }

              return TextField(
                controller: textCtrl,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Заметка',
                  isDense: true,
                  suffixIcon: _noteSugLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : (_noteSuggestions.isNotEmpty
                          ? const Icon(Icons.history_rounded)
                          : null),
                ),
                onChanged: (v) {
                  widget.row._noteCtrl.value = textCtrl.value;
                  _debouncer.run(() => _searchNotes(v));
                },
                onSubmitted: (_) => onFieldSubmitted(),
              );
            },
          );

          if (narrow) {
            return Column(
              children: [
                Row(
                  children: [
                    amountField,
                    const SizedBox(width: 8),
                    Expanded(child: categoryField),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: noteField),
              ],
            );
          }

          return Row(
            children: [
              amountField,
              const SizedBox(width: 8),
              Expanded(flex: 2, child: categoryField),
              const SizedBox(width: 8),
              Expanded(flex: 3, child: noteField),
            ],
          );
        },
      ),
    );
  }
}

class _GoalRow {
  final _titleCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '1.0');
  TimeOfDay? _time;

  String? _userGoalId;
  String _lifeBlock = 'general';
  String? _emotion;
  int _importance = 1;

  _GoalEntry? toEntry() {
    final title = _titleCtrl.text.trim();
    final hours = double.tryParse(_hoursCtrl.text.replaceAll(',', '.')) ?? 0;
    if (title.isEmpty) return null;

    return _GoalEntry(
      title: title,
      hours: hours <= 0 ? 1 : hours,
      startTime: _time,
      lifeBlock: _lifeBlock,
      emotion: _emotion,
      importance: _importance,
      userGoalId: _userGoalId,
    );
  }

  void dispose() {
    _titleCtrl.dispose();
    _hoursCtrl.dispose();
  }
}

class _GoalRowView extends StatefulWidget {
  final _GoalRow row;
  final List<String> lifeBlocks;
  final List<String> emotions;

  const _GoalRowView({
    required this.row,
    required this.lifeBlocks,
    required this.emotions,
  });

  @override
  State<_GoalRowView> createState() => _GoalRowViewState();
}

class _GoalRowViewState extends State<_GoalRowView> {
  final _debouncer = _Debouncer(const Duration(milliseconds: 250));
  final _supabase = Supabase.instance.client;

  bool _titleSugLoading = false;
  List<String> _titleSuggestions = [];
  int _reqId = 0;

  bool _loadingUserGoals = false;
  List<UserGoalLinkOption> _userGoalsForSelectedBlock = const [];

  String _normalizeBlock(String value) {
    final v = value.trim().toLowerCase();

    switch (v) {
      case '':
        return 'general';

      case 'general':
      case 'общий':
      case 'общее':
      case 'общие':
      case 'без категории':
        return 'general';

      case 'health':
      case 'здоровье':
      case 'healthcare':
      case 'wellbeing':
      case 'well-being':
      case 'sport':
      case 'спорт':
        return 'health';

      case 'career':
      case 'карьера':
      case 'работа':
      case 'job':
      case 'work':
      case 'business':
      case 'бизнес':
        return 'career';

      case 'finance':
      case 'финансы':
      case 'money':
      case 'financial':
        return 'finance';

      case 'relationships':
      case 'relationship':
      case 'relations':
      case 'отношения':
      case 'семья':
      case 'family':
        return 'relationships';

      case 'self':
      case 'selfdevelopment':
      case 'self-development':
      case 'personal':
      case 'personal growth':
      case 'личное':
      case 'саморазвитие':
      case 'creative':
      case 'творчество':
        return 'self';

      case 'education':
      case 'learning':
      case 'study':
      case 'учеба':
      case 'учёба':
      case 'образование':
        return 'education';

      case 'travel':
      case 'путешествия':
      case 'traveling':
        return 'travel';

      case 'home':
      case 'house':
      case 'дом':
        return 'home';

      default:
        return v;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.row._lifeBlock = _normalizeBlock(widget.row._lifeBlock);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserGoalsForCurrentBlock();
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _searchTitles(String q) async {
    final myReq = ++_reqId;
    final query = q.trim();
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _titleSugLoading = false;
        _titleSuggestions = [];
      });
      return;
    }

    if (!mounted) return;
    setState(() => _titleSugLoading = true);

    try {
      final res = await dbRepo.searchGoalTitles(query: query, limit: 8);
      if (!mounted || myReq != _reqId) return;
      setState(() {
        _titleSuggestions = res;
        _titleSugLoading = false;
      });
    } catch (_) {
      if (!mounted || myReq != _reqId) return;
      setState(() {
        _titleSuggestions = [];
        _titleSugLoading = false;
      });
    }
  }

  Future<void> _loadUserGoalsForCurrentBlock() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _userGoalsForSelectedBlock = const [];
        widget.row._userGoalId = null;
        _loadingUserGoals = false;
      });
      return;
    }

    final normalizedBlock = _normalizeBlock(widget.row._lifeBlock);

    setState(() {
      _loadingUserGoals = true;
    });

    try {
      final raw = await _supabase
          .from('user_goals')
          .select('id, title, life_block, horizon')
          .eq('user_id', userId)
          .eq('life_block', normalizedBlock)
          .order('title');

      final items = (raw as List)
          .map(
            (e) => UserGoalLinkOption(
              id: (e['id'] ?? '').toString(),
              title: (e['title'] ?? '').toString(),
              lifeBlock: (e['life_block'] ?? '').toString(),
              horizon: (e['horizon'] ?? '').toString(),
            ),
          )
          .where((e) => e.id.isNotEmpty && e.title.trim().isNotEmpty)
          .toList()
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

      if (!mounted) return;

      final stillValid = widget.row._userGoalId != null &&
          items.any((g) => g.id == widget.row._userGoalId);

      setState(() {
        _userGoalsForSelectedBlock = items;
        if (!stillValid) {
          widget.row._userGoalId = null;
        }
        _loadingUserGoals = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userGoalsForSelectedBlock = const [];
        widget.row._userGoalId = null;
        _loadingUserGoals = false;
      });
    }
  }

  String _horizonLabel(String value) {
    switch (value) {
      case 'tactical':
        return 'Тактическая';
      case 'mid':
        return 'Среднесрочная';
      case 'long':
        return 'Долгосрочная';
      default:
        return value;
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: widget.row._time ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) {
        final t = Theme.of(ctx);
        return Theme(
          data: t.copyWith(
            colorScheme: t.colorScheme.copyWith(
              primary: t.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (t != null) {
      setState(() => widget.row._time = t);
    }
  }

  Future<void> _pickEmotion() async {
    final cs = Theme.of(context).colorScheme;
    final chosen = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: cs.surface,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in widget.emotions)
              ChoiceChip(
                label: Text(
                  e,
                  style: const TextStyle(fontSize: 20),
                ),
                selected: widget.row._emotion == e,
                onSelected: (_) => Navigator.pop(ctx, e),
              ),
            ActionChip(
              avatar: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Без эмоции'),
              onPressed: () => Navigator.pop(ctx, ''),
            ),
          ],
        ),
      ),
    );

    if (chosen == null) return;
    setState(() => widget.row._emotion = chosen.isEmpty ? null : chosen);
  }

  String _labelForBlock(String b) {
    final key = b.trim().toLowerCase();
    if (key == 'general') return 'Общее';

    final lb = LifeBlock.values.firstWhere(
      (e) => e.name == key,
      orElse: () => LifeBlock.health,
    );
    return getBlockLabel(lb);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timeLabel = widget.row._time == null
        ? 'Время'
        : widget.row._time!.format(context);
    final emotionLabel = widget.row._emotion ?? 'Эмоция';

    final goals = _userGoalsForSelectedBlock;
    final dropdownGoalValue =
        goals.any((g) => g.id == widget.row._userGoalId)
            ? widget.row._userGoalId
            : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 720;

          final titleField = Autocomplete<String>(
            optionsBuilder: (TextEditingValue v) {
              final q = v.text.trim();
              if (q.isEmpty) return const Iterable<String>.empty();
              return _titleSuggestions.take(8);
            },
            onSelected: (val) {
              widget.row._titleCtrl.text = val;
              widget.row._titleCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: val.length),
              );
            },
            fieldViewBuilder:
                (context, textCtrl, focusNode, onFieldSubmitted) {
              if (textCtrl.text != widget.row._titleCtrl.text) {
                textCtrl.text = widget.row._titleCtrl.text;
                textCtrl.selection = widget.row._titleCtrl.selection;
              }

              return TextField(
                controller: textCtrl,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Название задачи',
                  isDense: true,
                  suffixIcon: _titleSugLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : (_titleSuggestions.isNotEmpty
                          ? const Icon(Icons.history_rounded)
                          : null),
                ),
                onChanged: (v) {
                  widget.row._titleCtrl.value = textCtrl.value;
                  _debouncer.run(() => _searchTitles(v));
                },
                onSubmitted: (_) => onFieldSubmitted(),
              );
            },
          );

          final titleHoursTime = Row(
            children: [
              Expanded(flex: 2, child: titleField),
              const SizedBox(width: 8),
              SizedBox(
                width: 96,
                child: TextField(
                  controller: widget.row._hoursCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Часы',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 128,
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time_rounded),
                  label: Text(
                    timeLabel,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );

          final categoryField = DropdownButtonFormField<String>(
            value: widget.row._lifeBlock,
            isExpanded: true,
            items: widget.lifeBlocks
                .map(
                  (b) => DropdownMenuItem(
                    value: b,
                    child: Text(
                      _labelForBlock(b),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) async {
              final next = _normalizeBlock(v ?? 'general');
              if (next == widget.row._lifeBlock) return;

              setState(() {
                widget.row._lifeBlock = next;
                widget.row._userGoalId = null;
                _userGoalsForSelectedBlock = const [];
              });

              await _loadUserGoalsForCurrentBlock();
            },
            decoration: const InputDecoration(
              labelText: 'Категория',
              isDense: true,
            ),
          );

          final emotionBtn = SizedBox(
            width: narrow ? double.infinity : 148,
            child: OutlinedButton.icon(
              onPressed: _pickEmotion,
              icon: const Icon(Icons.mood_rounded),
              label: Text(
                emotionLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );

          final importanceField = DropdownButtonFormField<int>(
            value: widget.row._importance,
            items: const [
              DropdownMenuItem(value: 1, child: Text('1')),
              DropdownMenuItem(value: 2, child: Text('2')),
              DropdownMenuItem(value: 3, child: Text('3')),
            ],
            onChanged: (v) => setState(() => widget.row._importance = v ?? 1),
            decoration: const InputDecoration(
              labelText: 'Важность',
              isDense: true,
            ),
          );

          final userGoalField = DropdownButtonFormField<String?>(
            value: dropdownGoalValue,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Большая цель',
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Без связи'),
              ),
              ...goals.map(
                (g) => DropdownMenuItem<String?>(
                  value: g.id,
                  child: Text(
                    '${g.title} · ${_horizonLabel(g.horizon)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: (v) {
              setState(() => widget.row._userGoalId = v);
            },
          );

          if (narrow) {
            return Column(
              children: [
                titleHoursTime,
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: categoryField),
                    const SizedBox(width: 8),
                    SizedBox(width: 140, child: importanceField),
                  ],
                ),
                const SizedBox(height: 8),
                emotionBtn,
                const SizedBox(height: 8),
                userGoalField,
                if (_loadingUserGoals) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Загружаю большие цели...',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!_loadingUserGoals && goals.isEmpty) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Для этой категории пока нет больших целей.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ],
            );
          }

          return Column(
            children: [
              titleHoursTime,
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: categoryField),
                  const SizedBox(width: 8),
                  emotionBtn,
                  const SizedBox(width: 8),
                  SizedBox(width: 120, child: importanceField),
                ],
              ),
              const SizedBox(height: 8),
              userGoalField,
              if (_loadingUserGoals) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Загружаю большие цели...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!_loadingUserGoals && goals.isEmpty) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Для этой категории пока нет больших целей.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class MassDailyEntryResult {
  final DateTime date;
  final _MoodEntry? mood;
  final List<_HabitEntry> habits;
  final List<_MentalAnswerEntry> mental;
  final List<_ExpenseEntry> expenses;
  final List<_IncomeEntry> incomes;
  final List<_GoalEntry> goals;

  MassDailyEntryResult({
    required this.date,
    required this.mood,
    required this.habits,
    required this.mental,
    required this.expenses,
    required this.incomes,
    required this.goals,
  });
}

class _MoodEntry {
  final String emoji;
  final String note;

  _MoodEntry({
    required this.emoji,
    required this.note,
  });
}

class _HabitEntry {
  final String habitId;
  final bool done;
  final int value;

  _HabitEntry({
    required this.habitId,
    required this.done,
    required this.value,
  });
}

class _ExpenseEntry {
  final double amount;
  final String categoryId;
  final String note;

  _ExpenseEntry({
    required this.amount,
    required this.categoryId,
    required this.note,
  });
}

class _IncomeEntry {
  final double amount;
  final String categoryId;
  final String note;

  _IncomeEntry({
    required this.amount,
    required this.categoryId,
    required this.note,
  });
}

class _MentalAnswerVm {
  bool? boolVal;
  int? intVal;
  String? textVal;

  _MentalAnswerVm({
    this.boolVal,
    this.intVal,
    this.textVal,
  });
}

class _MentalAnswerEntry {
  final String questionId;
  final bool? valueBool;
  final int? valueInt;
  final String? valueText;

  _MentalAnswerEntry({
    required this.questionId,
    this.valueBool,
    this.valueInt,
    this.valueText,
  });
}

class _GoalEntry {
  final String title;
  final double hours;
  final TimeOfDay? startTime;
  final String lifeBlock;
  final String? emotion;
  final int importance;
  final String? userGoalId;

  _GoalEntry({
    required this.title,
    required this.hours,
    required this.startTime,
    required this.lifeBlock,
    required this.emotion,
    required this.importance,
    required this.userGoalId,
  });
}