import 'package:flutter/material.dart';

import '../domain/category.dart' as dm;
import '../main.dart'; // dbRepo

class MassDailyEntrySheet extends StatefulWidget {
  const MassDailyEntrySheet({super.key});

  @override
  State<MassDailyEntrySheet> createState() => _MassDailyEntrySheetState();
}

class _MassDailyEntrySheetState extends State<MassDailyEntrySheet> {
  DateTime _date = DateUtils.dateOnly(DateTime.now());

  // mood
  String? _emoji; // null = без настроения
  final _moodNote = TextEditingController();

  // expenses
  final List<_ExpenseRow> _expenses = [_ExpenseRow()];

  // goals
  final List<_GoalRow> _goals = [_GoalRow()];

  // categories (expense)
  bool _catsLoading = false;
  List<dm.Category> _expenseCats = [];

  // goal life blocks
  static const List<String> _lifeBlocks = [
    'health',
    'career',
    'family',
    'relations',
    'education',
    'finance',
    'general',
  ];

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
    '🤯'
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenseCategories();
  }

  Future<void> _loadExpenseCategories() async {
    setState(() => _catsLoading = true);
    try {
      final res = await dbRepo.listCategories(kind: 'expense');
      if (!mounted) return;
      setState(() => _expenseCats = res);
    } catch (_) {
      if (!mounted) return;
      setState(() => _expenseCats = []);
    } finally {
      if (mounted) setState(() => _catsLoading = false);
    }
  }

  @override
  void dispose() {
    _moodNote.dispose();
    for (final e in _expenses) {
      e.dispose();
    }
    for (final g in _goals) {
      g.dispose();
    }
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
    final mood = _emoji == null
        ? null
        : _MoodEntry(
            emoji: _emoji!,
            note: _moodNote.text.trim(),
          );

    final expenses = _expenses
        .map((r) => r.toEntry())
        .where((e) => e != null && e!.amount > 0 && e!.categoryId.isNotEmpty)
        .cast<_ExpenseEntry>()
        .toList();

    final goals = _goals
        .map((r) => r.toEntry())
        .where((g) => g != null && g!.title.trim().isNotEmpty)
        .cast<_GoalEntry>()
        .toList();

    Navigator.pop(
      context,
      MassDailyEntryResult(
        date: _date,
        mood: mood,
        expenses: expenses,
        goals: goals,
      ),
    );
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
          8 +
              MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Массовое добавление за день',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text('Дата: ${_fmtDate(_date)}')),
                    TextButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Выбрать'),
                    ),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_catsLoading)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      IconButton(
                        tooltip: 'Добавить строку',
                        onPressed: _addExpenseRow,
                        icon: const Icon(Icons.add),
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
                        _GoalRowView(
                          row: _goals[i],
                          lifeBlocks: _lifeBlocks,
                          emotions: _goalEmojis,
                        ),
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
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Пустые строки игнорируются.',
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

/// ————— UI helpers —————

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
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

  static const _emojis = ['😄', '🙂', '😐', '😕', '😢', '😡', '🤩', '😴', '🤒', '🤯'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
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

/// ————— Expense row —————

class _ExpenseRow {
  final _amountCtrl = TextEditingController();
  String? _categoryId; // ID категории
  final _noteCtrl = TextEditingController();

  _ExpenseEntry? toEntry() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    final categoryId = (_categoryId ?? '').trim();
    final note = _noteCtrl.text.trim();
    if (amount <= 0 || categoryId.isEmpty) return null;
    return _ExpenseEntry(amount: amount, categoryId: categoryId, note: note);
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
  @override
  Widget build(BuildContext context) {
    final cats = widget.categories;
    final hasCats = cats.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 640;

        final amountField = SizedBox(
          width: 110,
          child: TextField(
            controller: widget.row._amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Сумма',
              prefixText: '€',
              border: OutlineInputBorder(),
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
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList()
              : const [],
          onChanged: hasCats ? (v) => setState(() => widget.row._categoryId = v) : null,
          decoration: InputDecoration(
            labelText: 'Категория',
            border: const OutlineInputBorder(),
            isDense: true,
            hintText: hasCats ? null : 'Нет категорий',
          ),
        );

        final noteField = TextField(
          controller: widget.row._noteCtrl,
          decoration: const InputDecoration(
            labelText: 'Заметка',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        );

        // узкий экран: переносим заметку вниз
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

        // широкий экран: всё в одну строку
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
    );
  }
}

/// ————— Goal row —————

class _GoalRow {
  final _titleCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '1.0');
  TimeOfDay? _time;

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
  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: widget.row._time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => widget.row._time = t);
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
                label: Text(e, style: const TextStyle(fontSize: 20)),
                selected: widget.row._emotion == e,
                onSelected: (_) => Navigator.pop(ctx, e),
              ),
            ActionChip(
              avatar: const Icon(Icons.close, size: 18),
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

  @override
  Widget build(BuildContext context) {
    final timeLabel = widget.row._time == null ? 'Время' : widget.row._time!.format(context);
    final emotionLabel = widget.row._emotion ?? 'Эмоция';

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 720;

        final titleHoursTime = Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: widget.row._titleCtrl,
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
                controller: widget.row._hoursCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Часы',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time),
                label: Text(timeLabel, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        );

        final categoryField = DropdownButtonFormField<String>(
          value: widget.row._lifeBlock,
          isExpanded: true,
          items: widget.lifeBlocks
              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
              .toList(),
          onChanged: (v) => setState(() => widget.row._lifeBlock = v ?? 'general'),
          decoration: const InputDecoration(
            labelText: 'Категория',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        );

        final emotionBtn = SizedBox(
          width: narrow ? double.infinity : 140,
          child: OutlinedButton.icon(
            onPressed: _pickEmotion,
            icon: const Icon(Icons.mood),
            label: Text(emotionLabel, overflow: TextOverflow.ellipsis),
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
            border: OutlineInputBorder(),
            isDense: true,
          ),
        );

        if (narrow) {
          // переносим элементы "Категория / Эмоция / Важность" в две строки
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
          ],
        );
      },
    );
  }
}

/// ————— Result —————

class MassDailyEntryResult {
  final DateTime date;
  final _MoodEntry? mood;
  final List<_ExpenseEntry> expenses;
  final List<_GoalEntry> goals;

  MassDailyEntryResult({
    required this.date,
    required this.mood,
    required this.expenses,
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

class _GoalEntry {
  final String title;
  final double hours;
  final TimeOfDay? startTime;

  final String lifeBlock;
  final String? emotion;
  final int importance;

  _GoalEntry({
    required this.title,
    required this.hours,
    required this.startTime,
    required this.lifeBlock,
    required this.emotion,
    required this.importance,
  });
}
