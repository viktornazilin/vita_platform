// lib/widgets/recurring_goal_sheet.dart
import 'dart:ui';

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

  // по умолчанию: пн/ср/пт
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

  // -----------------------------
  // UI helpers (Nest style)
  // -----------------------------
  InputDecoration _dec({required String label, String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final today = DateUtils.dateOnly(DateTime.now());
    final occurrences = _buildOccurrences(
      startDay: today,
      untilDay: _until,
      time: _time,
      type: _type,
      everyNDays: _everyNDays,
      weekdays: _weekdays,
    );

    final inputTheme = theme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: Colors.white.withOpacity(0.72),
      labelStyle: TextStyle(color: const Color(0xFF2E4B5A).withOpacity(0.80)),
      hintStyle: TextStyle(color: const Color(0xFF2E4B5A).withOpacity(0.55)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD6E6F5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD6E6F5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF3AA8E6), width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );

    return Theme(
      data: theme.copyWith(inputDecorationTheme: inputTheme),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.90,
          minChildSize: 0.62,
          maxChildSize: 0.96,
          builder: (ctx, controller) => SingleChildScrollView(
            controller: controller,
            padding: EdgeInsets.fromLTRB(
              14,
              10,
              14,
              14 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9BC7E6).withOpacity(0.55),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    const _IconBubble(icon: Icons.repeat_rounded),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Регулярная цель',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          color: const Color(0xFF2E4B5A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Создаст цели с сегодняшнего дня до дедлайна.',
                  style: tt.bodyMedium?.copyWith(
                    color: const Color(0xFF2E4B5A).withOpacity(0.70),
                  ),
                ),
                const SizedBox(height: 14),

                // DETAILS
                const _SectionTitle('Детали'),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: _dec(
                          label: 'Название цели',
                          hint: 'Например: Тренировка',
                          icon: Icons.flag_rounded,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emotionCtrl,
                        decoration: _dec(
                          label: 'Эмоция (опционально)',
                          hint: 'Например: 💪 мотивация',
                          icon: Icons.mood_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // RECURRENCE
                const _SectionTitle('Регулярность'),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ChoicePill(
                            label: 'Каждые N дней',
                            icon: Icons.calendar_view_day_rounded,
                            selected: _type == RecurrenceType.everyNDays,
                            onTap: () => setState(
                              () => _type = RecurrenceType.everyNDays,
                            ),
                          ),
                          _ChoicePill(
                            label: 'По дням недели',
                            icon: Icons.view_week_rounded,
                            selected: _type == RecurrenceType.weekly,
                            onTap: () =>
                                setState(() => _type = RecurrenceType.weekly),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_type == RecurrenceType.everyNDays)
                        _StepperRow(
                          label: 'Интервал',
                          valueText: 'каждые $_everyNDays дн.',
                          onMinus: _everyNDays > 1
                              ? () => setState(() => _everyNDays--)
                              : null,
                          onPlus: _everyNDays < 14
                              ? () => setState(() => _everyNDays++)
                              : null,
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
                              _DayChip(
                                label: _weekdayLabel(wd),
                                selected: _weekdays.contains(wd),
                                onTap: () {
                                  setState(() {
                                    if (_weekdays.contains(wd)) {
                                      _weekdays.remove(wd);
                                    } else {
                                      _weekdays.add(wd);
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _PillButton(
                              icon: Icons.schedule_rounded,
                              label: 'Время: ${_fmtTime(_time)}',
                              onTap: _pickTime,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PillButton(
                              icon: Icons.calendar_month_rounded,
                              label: 'До: ${_fmtDate(_until)}',
                              onTap: _pickUntil,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // PARAMETERS
                const _SectionTitle('Параметры'),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _lifeBlock,
                              decoration: _dec(
                                label: 'Блок жизни',
                                icon: Icons.grid_view_rounded,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'health',
                                  child: Text('Здоровье'),
                                ),
                                DropdownMenuItem(
                                  value: 'sport',
                                  child: Text('Спорт'),
                                ),
                                DropdownMenuItem(
                                  value: 'business',
                                  child: Text('Бизнес'),
                                ),
                                DropdownMenuItem(
                                  value: 'creative',
                                  child: Text('Творчество'),
                                ),
                                DropdownMenuItem(
                                  value: 'family',
                                  child: Text('Семья'),
                                ),
                                DropdownMenuItem(
                                  value: 'general',
                                  child: Text('Общее'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _lifeBlock = v ?? 'general'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _importance,
                              decoration: _dec(
                                label: 'Важность',
                                icon: Icons.local_fire_department_rounded,
                              ),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('1')),
                                DropdownMenuItem(value: 2, child: Text('2')),
                                DropdownMenuItem(value: 3, child: Text('3')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _importance = v ?? 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _StepperRow(
                        label: 'План часов',
                        valueText:
                            '${_hours.toStringAsFixed(_hours.truncateToDouble() == _hours ? 0 : 1)} ч',
                        onMinus: _hours > 0.5
                            ? () => setState(() => _hours = _hours - 0.5)
                            : null,
                        onPlus: _hours < 14
                            ? () => setState(() => _hours = _hours + 0.5)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _PreviewPill(count: occurrences.length),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ACTIONS
                Row(
                  children: [
                    Expanded(
                      child: _SoftButton(
                        label: 'Отмена',
                        kind: _SoftButtonKind.secondary,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SoftButton(
                        label: 'Создать',
                        kind: _SoftButtonKind.primary,
                        onTap: () {
                          final title = _titleCtrl.text.trim();
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Введите название цели'),
                              ),
                            );
                            return;
                          }
                          if (_type == RecurrenceType.weekly &&
                              _weekdays.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Выберите хотя бы один день недели',
                                ),
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
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const SafeArea(top: false, child: SizedBox(height: 0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Small Nest-style pieces (local, so file is drop-in)
// ============================================================================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
      child: Text(
        text,
        style: tt.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: const Color(0xFF2E4B5A),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2B5B7A),
                blurRadius: 26,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  const _IconBubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3AA8E6), Color(0xFF7DD3FC)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x162B5B7A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ChoicePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF3AA8E6).withOpacity(0.18)
              : const Color(0xFFEFF7FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF3AA8E6) : const Color(0xFFBBD9F7),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? const Color(0xFF2E4B5A)
                  : const Color(0xFF2E4B5A),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: tt.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E4B5A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF3AA8E6).withOpacity(0.18)
              : const Color(0xFFEFF7FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF3AA8E6) : const Color(0xFFBBD9F7),
          ),
        ),
        child: Text(
          label,
          style: tt.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2E4B5A),
          ),
        ),
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  final int count;
  const _PreviewPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBBD9F7)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3AA8E6), Color(0xFF7DD3FC)],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Будет создано целей: $count',
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E4B5A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final String valueText;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const _StepperRow({
    required this.label,
    required this.valueText,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E4B5A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valueText,
                style: tt.bodyMedium?.copyWith(
                  color: const Color(0xFF2E4B5A).withOpacity(0.70),
                ),
              ),
            ],
          ),
        ),
        _MiniIconButton(icon: Icons.remove_rounded, onTap: onMinus),
        const SizedBox(width: 6),
        _MiniIconButton(icon: Icons.add_rounded, onTap: onPlus),
      ],
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _MiniIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF7FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBBD9F7)),
          ),
          child: Icon(icon, color: const Color(0xFF2E4B5A)),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD6E6F5)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFF2E4B5A)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E4B5A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _SoftButtonKind { primary, secondary }

class _SoftButton extends StatelessWidget {
  final String label;
  final _SoftButtonKind kind;
  final VoidCallback onTap;

  const _SoftButton({
    required this.label,
    required this.kind,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isPrimary = kind == _SoftButtonKind.primary;

    final bg = isPrimary ? null : Colors.white.withOpacity(0.72);

    final gradient = isPrimary
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3AA8E6), Color(0xFF7DD3FC)],
          )
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: bg,
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPrimary
                ? const Color(0x663AA8E6)
                : const Color(0xFFD6E6F5),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A2B5B7A),
              blurRadius: 20,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: isPrimary ? Colors.white : const Color(0xFF2E4B5A),
            ),
          ),
        ),
      ),
    );
  }
}
