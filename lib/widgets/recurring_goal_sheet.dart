// lib/widgets/recurring_goal_sheet.dart
import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'nest/nest_card.dart';
import 'nest/nest_pill.dart';
import 'nest/nest_section_title.dart';

enum RecurrenceType { everyNDays, weekly }

class UserGoalLinkOption {
  final String id;
  final String title;
  final String lifeBlock;
  final String horizon;

  const UserGoalLinkOption({
    required this.id,
    required this.title,
    required this.lifeBlock,
    required this.horizon,
  });
}

class RecurringGoalPlan {
  final String title;
  final String lifeBlock;
  final int importance;
  final String emotion;
  final double plannedHours;
  final DateTime until; // dateOnly
  final TimeOfDay time;
  final RecurrenceType type;

  final int everyNDays;
  final Set<int> weekdays; // DateTime.monday..DateTime.sunday
  final String? userGoalId;

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
    this.userGoalId,
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
  final _supabase = Supabase.instance.client;

  RecurrenceType _type = RecurrenceType.everyNDays;
  int _everyNDays = 2;
  Set<int> _weekdays = {
    DateTime.monday,
    DateTime.wednesday,
    DateTime.friday,
  };

  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  DateTime _until = DateUtils.dateOnly(
    DateTime.now().add(const Duration(days: 14)),
  );

  String _lifeBlock = 'health';
  int _importance = 2;
  double _hours = 1.0;
  String? _selectedUserGoalId;

  bool _loadingUserGoals = false;
  List<UserGoalLinkOption> _userGoalsForSelectedBlock = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserGoalsForCurrentBlock();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _emotionCtrl.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime d) => DateUtils.dateOnly(d);

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

  String _lifeBlockLabel(String value) {
    switch (_normalizeBlock(value)) {
      case 'general':
        return 'Общее';
      case 'health':
        return 'Здоровье';
      case 'career':
        return 'Карьера';
      case 'finance':
        return 'Финансы';
      case 'relationships':
        return 'Отношения';
      case 'self':
        return 'Саморазвитие';
      case 'education':
        return 'Образование';
      case 'travel':
        return 'Путешествия';
      case 'home':
        return 'Дом';
      default:
        return value;
    }
  }

  String _horizonLabel(String value) {
    switch (value.trim().toLowerCase()) {
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

  Future<void> _loadUserGoalsForCurrentBlock() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _userGoalsForSelectedBlock = const [];
        _selectedUserGoalId = null;
        _loadingUserGoals = false;
      });
      return;
    }

    final normalizedBlock = _normalizeBlock(_lifeBlock);

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

      final stillValid = _selectedUserGoalId != null &&
          items.any((g) => g.id == _selectedUserGoalId);

      setState(() {
        _userGoalsForSelectedBlock = items;
        if (!stillValid) {
          _selectedUserGoalId = null;
        }
        _loadingUserGoals = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userGoalsForSelectedBlock = const [];
        _selectedUserGoalId = null;
        _loadingUserGoals = false;
      });
    }
  }

  Future<void> _pickUntil() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _until,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (d != null) {
      setState(() => _until = _dateOnly(d));
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (t != null) {
      setState(() => _time = t);
    }
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

  InputDecoration _input({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
    );
  }

  void _submit() {
    final t = AppLocalizations.of(context)!;
    final title = _titleCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.addDayGoalEnterTitle)),
      );
      return;
    }

    if (_type == RecurrenceType.weekly && _weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы один день недели')),
      );
      return;
    }

    Navigator.pop(
      context,
      RecurringGoalPlan(
        title: title,
        lifeBlock: _normalizeBlock(_lifeBlock),
        importance: _importance,
        emotion: _emotionCtrl.text.trim(),
        plannedHours: _hours,
        until: _until,
        time: _time,
        type: _type,
        everyNDays: _everyNDays,
        weekdays: _weekdays,
        userGoalId: _selectedUserGoalId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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

    final dropdownGoalValue = _userGoalsForSelectedBlock.any(
      (g) => g.id == _selectedUserGoalId,
    )
        ? _selectedUserGoalId
        : null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.90,
        minChildSize: 0.62,
        maxChildSize: 0.96,
        builder: (ctx, controller) {
          return SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: scheme.outline.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Icon(
                        Icons.repeat_rounded,
                        color: scheme.onSurface,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Регулярная цель',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Создаст задачи с сегодняшнего дня до выбранной даты.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                NestSectionTitle('Детали'),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: _input(
                          label: 'Название цели',
                          hint: 'Например: Тренировка',
                          icon: Icons.flag_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emotionCtrl,
                        textInputAction: TextInputAction.done,
                        decoration: _input(
                          label: 'Эмоция',
                          hint: 'Например: 💪 мотивация',
                          icon: Icons.emoji_emotions_outlined,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),
                NestSectionTitle('Регулярность'),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Каждые N дней'),
                            selected: _type == RecurrenceType.everyNDays,
                            onSelected: (_) {
                              setState(() => _type = RecurrenceType.everyNDays);
                            },
                          ),
                          ChoiceChip(
                            label: const Text('По дням недели'),
                            selected: _type == RecurrenceType.weekly,
                            onSelected: (_) {
                              setState(() => _type = RecurrenceType.weekly);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_type == RecurrenceType.everyNDays)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Интервал',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _everyNDays > 1
                                  ? () => setState(() => _everyNDays--)
                                  : null,
                              icon: const Icon(Icons.remove_rounded),
                            ),
                            NestPill(
  leading: const Icon(Icons.repeat_rounded, size: 16),
  text: '$_everyNDays дн.',
),
                            IconButton(
                              onPressed: _everyNDays < 14
                                  ? () => setState(() => _everyNDays++)
                                  : null,
                              icon: const Icon(Icons.add_rounded),
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
                                onSelected: (_) {
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
                      const SizedBox(height: 14),
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
                    ],
                  ),
                ),

                const SizedBox(height: 2),
                NestSectionTitle('Параметры'),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _lifeBlock,
                              decoration: _input(
                                label: 'Блок жизни',
                                icon: Icons.grid_view_rounded,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'health',
                                  child: Text('Здоровье'),
                                ),
                                DropdownMenuItem(
                                  value: 'career',
                                  child: Text('Карьера'),
                                ),
                                DropdownMenuItem(
                                  value: 'finance',
                                  child: Text('Финансы'),
                                ),
                                DropdownMenuItem(
                                  value: 'relationships',
                                  child: Text('Отношения'),
                                ),
                                DropdownMenuItem(
                                  value: 'self',
                                  child: Text('Саморазвитие'),
                                ),
                                DropdownMenuItem(
                                  value: 'education',
                                  child: Text('Образование'),
                                ),
                                DropdownMenuItem(
                                  value: 'travel',
                                  child: Text('Путешествия'),
                                ),
                                DropdownMenuItem(
                                  value: 'home',
                                  child: Text('Дом'),
                                ),
                                DropdownMenuItem(
                                  value: 'general',
                                  child: Text('Общее'),
                                ),
                              ],
                              onChanged: (v) async {
                                final next = _normalizeBlock(v ?? 'general');
                                if (next == _lifeBlock) return;

                                setState(() {
                                  _lifeBlock = next;
                                  _selectedUserGoalId = null;
                                  _userGoalsForSelectedBlock = const [];
                                });

                                await _loadUserGoalsForCurrentBlock();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _importance,
                              decoration: _input(
                                label: 'Важность',
                                icon: Icons.local_fire_department_rounded,
                              ),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('1')),
                                DropdownMenuItem(value: 2, child: Text('2')),
                                DropdownMenuItem(value: 3, child: Text('3')),
                              ],
                              onChanged: (v) {
                                setState(() => _importance = v ?? 2);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String?>(
                        value: dropdownGoalValue,
                        decoration: _input(
                          label: 'Большая цель',
                          icon: Icons.link_rounded,
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Без связи'),
                          ),
                          ..._userGoalsForSelectedBlock.map(
                            (g) => DropdownMenuItem<String?>(
                              value: g.id,
                              child: Text(
                                '${g.title} · ${_horizonLabel(g.horizon)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: _loadingUserGoals
                            ? null
                            : (v) {
                                setState(() => _selectedUserGoalId = v);
                              },
                      ),

                      if (_loadingUserGoals) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Загружаю цели для блока "${_lifeBlockLabel(_lifeBlock)}"...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (_userGoalsForSelectedBlock.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Для блока "${_lifeBlockLabel(_lifeBlock)}" пока нет доступных целей.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'План часов',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          NestPill(
  leading: const Icon(Icons.timer_outlined, size: 16),
  text: _hours.toStringAsFixed(
    _hours.truncateToDouble() == _hours ? 0 : 1,
  ),
),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3.5,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 18,
                          ),
                        ),
                        child: Slider(
                          min: 0.5,
                          max: 14,
                          divisions: 27,
                          value: _hours,
                          label: _hours.toStringAsFixed(1),
                          onChanged: (v) => setState(() => _hours = v),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: scheme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Будет создано задач: ${occurrences.length}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(t.commonCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _submit,
                        child: const Text('Создать'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const SafeArea(top: false, child: SizedBox(height: 0)),
              ],
            ),
          );
        },
      ),
    );
  }
}