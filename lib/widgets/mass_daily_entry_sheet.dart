import 'package:flutter/material.dart';

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

    Navigator.pop(context, MassDailyEntryResult(
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

/// ————— Внутренние виджеты/модели —————

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

/// ————— Результаты, которые вернёт шторка —————

class MassDailyEntryResult {
  final DateTime date;
  final _MoodEntry? mood;
  final List<_ExpenseEntry> expenses;
  final List<_GoalEntry> goals;

  MassDailyEntryResult({required this.date, required this.mood, required this.expenses, required this.goals});
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
