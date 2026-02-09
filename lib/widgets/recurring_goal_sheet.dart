import 'package:flutter/material.dart';

enum RecurrenceType { everyNDays, weekly }

class RecurringGoalPlan {
  final String title;
  final String lifeBlock;
  final int importance;
  final String emotion;
  final double plannedHours;
  final DateTime until; // dateOnly
  final TimeOfDay time;
  final RecurrenceType type;

  // every N days
  final int everyNDays;

  // weekly
  final Set<int> weekdays; // DateTime.monday..DateTime.sunday

  const RecurringGoalPlan({
    required this.title,
    required this.lifeBlock,
    required this.importance,
    required this.emotion,
    required this.plannedHours,
    required this.until,
    required this.time,
    required this.type,
    required this.everyNDays,
    required this.weekdays,
  });
}

class RecurringGoalSheet extends StatefulWidget {
  const RecurringGoalSheet({super.key});

  @override
  State<RecurringGoalSheet> createState() => _RecurringGoalSheetState();
}

class _RecurringGoalSheetState extends State<RecurringGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _emotionCtrl = TextEditingController();

  RecurrenceType _type = RecurrenceType.everyNDays;
  int _everyNDays = 2;

  // по умолчанию: пн/ср/пт (можешь поменять)
  Set<int> _weekdays = {DateTime.monday, DateTime.wednesday, DateTime.friday};

  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  DateTime _until = DateUtils.dateOnly(
    DateTime.now().add(const Duration(days: 14)),
  );

  String _lifeBlock = 'health';
  int _importance = 2;
  double _hours = 1.0;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _emotionCtrl.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime d) => DateUtils.dateOnly(d);

  Future<void> _pickUntil() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _until,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (d != null) setState(() => _until = _dateOnly(d));
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  String _fmtDate(DateTime d) =>
      MaterialLocalizations.of(context).formatMediumDate(d);

  String _fmtTime(TimeOfDay t) =>
      MaterialLocalizations.of(context).formatTimeOfDay(t);

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Пн';
      case DateTime.tuesday:
        return 'Вт';
      case DateTime.wednesday:
        return 'Ср';
      case DateTime.thursday:
        return 'Чт';
      case DateTime.friday:
        return 'Пт';
      case DateTime.saturday:
        return 'Сб';
      case DateTime.sunday:
        return 'Вс';
      default:
        return '$weekday';
    }
  }

  List<DateTime> _buildOccurrences({
    required DateTime startDay,
    required DateTime untilDay,
    required TimeOfDay time,
    required RecurrenceType type,
    required int everyNDays,
    required Set<int> weekdays,
  }) {
    final start = _dateOnly(startDay);
    final until = _dateOnly(untilDay);

    DateTime withTime(DateTime day) =>
        DateTime(day.year, day.month, day.day, time.hour, time.minute);

    final out = <DateTime>[];

    if (until.isBefore(start)) return out;

    if (type == RecurrenceType.everyNDays) {
      final step = everyNDays < 1 ? 1 : everyNDays;
      for (
        var day = start;
        !day.isAfter(until);
        day = day.add(Duration(days: step))
      ) {
        out.add(withTime(day));
      }
      return out;
    }

    // weekly
    final wds = weekdays.isEmpty ? {start.weekday} : weekdays;
    for (
      var day = start;
      !day.isAfter(until);
      day = day.add(const Duration(days: 1))
    ) {
      if (wds.contains(day.weekday)) {
        out.add(withTime(day));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final today = DateUtils.dateOnly(DateTime.now());
    final occurrences = _buildOccurrences(
      startDay: today,
      untilDay: _until,
      time: _time,
      type: _type,
      everyNDays: _everyNDays,
      weekdays: _weekdays,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16 +
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Регулярная цель',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Создаст цели с сегодняшнего дня до дедлайна.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 14),

          // Title
          TextField(
            controller: _titleCtrl,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Название цели',
              hintText: 'Например: Тренировка',
              prefixIcon: Icon(Icons.flag_rounded),
            ),
          ),
          const SizedBox(height: 10),

          // Recurrence type
          Text(
            'Регулярность',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Каждые N дней'),
                selected: _type == RecurrenceType.everyNDays,
                onSelected: (_) =>
                    setState(() => _type = RecurrenceType.everyNDays),
              ),
              ChoiceChip(
                label: const Text('По дням недели'),
                selected: _type == RecurrenceType.weekly,
                onSelected: (_) =>
                    setState(() => _type = RecurrenceType.weekly),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (_type == RecurrenceType.everyNDays)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Интервал: каждые $_everyNDays дн.',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                IconButton(
                  onPressed: _everyNDays > 1
                      ? () => setState(() => _everyNDays--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
                IconButton(
                  onPressed: _everyNDays < 14
                      ? () => setState(() => _everyNDays++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final wd in const [
                  DateTime.monday,
                  DateTime.tuesday,
                  DateTime.wednesday,
                  DateTime.thursday,
                  DateTime.friday,
                  DateTime.saturday,
                  DateTime.sunday,
                ])
                  FilterChip(
                    label: Text(_weekdayLabel(wd)),
                    selected: _weekdays.contains(wd),
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _weekdays.add(wd);
                        } else {
                          _weekdays.remove(wd);
                        }
                      });
                    },
                  ),
              ],
            ),

          const SizedBox(height: 12),

          // Time + until
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule_rounded),
                  label: Text('Время: ${_fmtTime(_time)}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickUntil,
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text('До: ${_fmtDate(_until)}'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // extra fields
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _lifeBlock,
                  decoration: const InputDecoration(
                    labelText: 'Блок жизни',
                    prefixIcon: Icon(Icons.grid_view_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'health', child: Text('Здоровье')),
                    DropdownMenuItem(value: 'sport', child: Text('Спорт')),
                    DropdownMenuItem(value: 'business', child: Text('Бизнес')),
                    DropdownMenuItem(
                      value: 'creative',
                      child: Text('Творчество'),
                    ),
                    DropdownMenuItem(value: 'family', child: Text('Семья')),
                    DropdownMenuItem(value: 'general', child: Text('Общее')),
                  ],
                  onChanged: (v) => setState(() => _lifeBlock = v ?? 'general'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _importance,
                  decoration: const InputDecoration(
                    labelText: 'Важность',
                    prefixIcon: Icon(Icons.priority_high_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1')),
                    DropdownMenuItem(value: 2, child: Text('2')),
                    DropdownMenuItem(value: 3, child: Text('3')),
                  ],
                  onChanged: (v) => setState(() => _importance = v ?? 2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          TextField(
            controller: _emotionCtrl,
            decoration: const InputDecoration(
              labelText: 'Эмоция (опционально)',
              hintText: 'Например: 💪 мотивация',
              prefixIcon: Icon(Icons.mood_rounded),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Text(
                  'План часов: ${_hours.toStringAsFixed(_hours.truncateToDouble() == _hours ? 0 : 1)}',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              IconButton(
                onPressed: _hours > 0.5
                    ? () => setState(() => _hours = (_hours - 0.5))
                    : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              IconButton(
                onPressed: _hours < 14
                    ? () => setState(() => _hours = (_hours + 0.5))
                    : null,
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Будет создано целей: ${occurrences.length}',
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Apply
          FilledButton.icon(
            onPressed: () {
              final title = _titleCtrl.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите название цели')),
                );
                return;
              }
              if (_type == RecurrenceType.weekly && _weekdays.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Выберите хотя бы один день недели'),
                  ),
                );
                return;
              }
              Navigator.pop(
                context,
                RecurringGoalPlan(
                  title: title,
                  lifeBlock: _lifeBlock,
                  importance: _importance,
                  emotion: _emotionCtrl.text.trim(),
                  plannedHours: _hours,
                  until: _until,
                  time: _time,
                  type: _type,
                  everyNDays: _everyNDays,
                  weekdays: _weekdays,
                ),
              );
            },
            icon: const Icon(Icons.playlist_add_check_rounded),
            label: const Text('Создать серию целей'),
          ),
        ],
      ),
    );
  }
}
