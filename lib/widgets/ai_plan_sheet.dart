import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart'; // dbRepo

class AiPlanSheet extends StatefulWidget {
  const AiPlanSheet({super.key});

  @override
  State<AiPlanSheet> createState() => _AiPlanSheetState();
}

class _AiPlanSheetState extends State<AiPlanSheet> {
  String _horizon = 'week';
  bool _loading = true;
  String? _error;

  String? _planId;
  List<_PlanItem> _items = [];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() {
      _loading = true;
      _error = null;
      _planId = null;
      _items = [];
    });

    try {
      final res = await Supabase.instance.client.functions.invoke(
        'ai-plan',
        body: {'horizon': _horizon},
      );

      final data = (res.data as Map).cast<String, dynamic>();
      final planId = data['plan_id'] as String?;
      final raw = (data['items'] as List?) ?? [];

      if (planId == null) throw Exception('ai-plan: missing plan_id');

      final items = raw
          .map((e) => _PlanItem.fromMap((e as Map).cast<String, dynamic>()))
          .toList();

      // по умолчанию всё принято
      for (final it in items) {
        it.accepted = true;
      }

      if (!mounted) return;
      setState(() {
        _planId = planId;
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _apply() async {
    if (_planId == null) return;
    final planId = _planId!; // ✅ локальная non-null переменная

    final accepted = _items.where((x) => x.accepted).toList();
    final rejected = _items.where((x) => !x.accepted).toList();

    if (accepted.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выбери хотя бы одну цель.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      int created = 0;

      // 1) создаём goals (включая регулярные)
      for (final it in accepted) {
        // на всякий случай нормализуем перед созданием
        it.lifeBlock = _PlanItem.normalizeLifeBlock(it.lifeBlock);

        if (it.isRecurring) {
          final occ = _buildOccurrences(
            startDay: DateUtils.dateOnly(DateTime.now()),
            until: DateUtils.dateOnly(it.until!),
            time: it.time!,
            weekdays: it.weekdays,
          );

          for (final start in occ) {
            final deadline = DateTime(
              start.year,
              start.month,
              start.day,
              23,
              59,
            );
            await dbRepo.createGoal(
              title: it.title,
              description: _desc(it),
              deadline: deadline,
              lifeBlock: it.lifeBlock,
              importance: it.importance,
              emotion: '',
              spentHours: it.plannedHours,
              startTime: start,
            );
            created++;
          }
        } else {
          final start = it.startTime.toLocal();
          final deadline = DateTime(start.year, start.month, start.day, 23, 59);

          await dbRepo.createGoal(
            title: it.title,
            description: _desc(it),
            deadline: deadline,
            lifeBlock: it.lifeBlock,
            importance: it.importance,
            emotion: '',
            spentHours: it.plannedHours,
            startTime: start,
          );
          created++;
        }
      }

      // 2) обновляем статусы ai_plan_items
      final supa = Supabase.instance.client;

      if (accepted.isNotEmpty) {
        await supa
            .from('ai_plan_items')
            .update({'state': 'applied'})
            .inFilter('id', accepted.map((e) => e.id).toList());
      }

      if (rejected.isNotEmpty) {
        await supa
            .from('ai_plan_items')
            .update({'state': 'rejected'})
            .inFilter('id', rejected.map((e) => e.id).toList());
      }

      // 3) статус плана
      await supa
          .from('ai_plans')
          .update({'status': 'applied'})
          .eq('id', planId);

      if (!mounted) return;
      Navigator.pop(context, created);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось применить: $e')));
    }
  }

  String _desc(_PlanItem it) {
    final h = it.plannedHours;
    final hh = h <= 0
        ? ''
        : 'План: ${h.toStringAsFixed(h.truncateToDouble() == h ? 0 : 1)} ч';
    final why = (it.reason ?? '').trim();
    if (why.isEmpty) return hh;
    if (hh.isEmpty) return why;
    return '$hh\n$why';
  }

  // -------- Recurrence helpers --------
  List<DateTime> _buildOccurrences({
    required DateTime startDay,
    required DateTime until,
    required TimeOfDay time,
    required Set<int> weekdays, // 1..7
  }) {
    DateTime combine(DateTime day, TimeOfDay t) =>
        DateTime(day.year, day.month, day.day, t.hour, t.minute);

    final out = <DateTime>[];
    final wds = weekdays.isEmpty ? {startDay.weekday} : weekdays;

    for (
      var day = startDay;
      !day.isAfter(until);
      day = day.add(const Duration(days: 1))
    ) {
      if (wds.contains(day.weekday)) out.add(combine(day, time));
    }
    return out;
  }

  // -------- UI --------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
            Row(
              children: [
                Text(
                  'AI-план',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Обновить',
                  onPressed: _loading ? null : _run,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // horizon chips
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Неделя'),
                  selected: _horizon == 'week',
                  onSelected: _loading
                      ? null
                      : (v) {
                          if (!v) return;
                          setState(() => _horizon = 'week');
                          _run();
                        },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Месяц'),
                  selected: _horizon == 'month',
                  onSelected: _loading
                      ? null
                      : (v) {
                          if (!v) return;
                          setState(() => _horizon = 'month');
                          _run();
                        },
                ),
                const Spacer(),
                if (_planId != null)
                  Text(
                    'ID: ${_planId!.substring(0, 6)}…',
                    style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator.adaptive()),
              )
            else if (_error != null)
              _ErrorBox(text: _error!, onRetry: _run)
            else if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'План пустой. Попробуй ещё раз или добавь больше данных.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _PlanCard(
                    item: _items[i],
                    onChanged: () => setState(() {}),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                TextButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  child: const Text('Закрыть'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _loading ? null : _apply,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    'Применить (${_items.where((x) => x.accepted).length})',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card with per-item controls
// ─────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final _PlanItem item;
  final VoidCallback onChanged;

  const _PlanCard({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // ✅ важно: value dropdown должен точно быть в списке items
    final safeLifeBlock = _PlanItem.normalizeLifeBlock(item.lifeBlock);
    item.lifeBlock = safeLifeBlock;

    return Material(
      color: cs.surfaceContainerHighest.withOpacity(0.35),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: item.accepted,
                  onChanged: (v) {
                    item.accepted = v ?? false;
                    onChanged();
                  },
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _whenText(context, item.startTime.toLocal()),
                        style: tt.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if ((item.reason ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          item.reason!,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // duration + life block
            Row(
              children: [
                Expanded(
                  child: _HoursField(
                    initial: item.plannedHours,
                    onChanged: (v) {
                      item.plannedHours = v;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: safeLifeBlock,
                    decoration: const InputDecoration(
                      labelText: 'Сфера жизни',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'general',
                        child: Text('general'),
                      ),
                      DropdownMenuItem(value: 'sport', child: Text('sport')),
                      DropdownMenuItem(value: 'health', child: Text('health')),
                      DropdownMenuItem(
                        value: 'business',
                        child: Text('business'),
                      ),
                      DropdownMenuItem(
                        value: 'creative',
                        child: Text('creative'),
                      ),
                      DropdownMenuItem(value: 'family', child: Text('family')),
                      DropdownMenuItem(value: 'travel', child: Text('travel')),
                      DropdownMenuItem(
                        value: 'science',
                        child: Text('science'),
                      ),
                    ],
                    onChanged: (v) {
                      item.lifeBlock = _PlanItem.normalizeLifeBlock(v);
                      onChanged();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // recurring toggle
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: item.isRecurring,
              onChanged: (v) {
                item.isRecurring = v;
                if (v) {
                  item.time ??= TimeOfDay.fromDateTime(
                    item.startTime.toLocal(),
                  );
                  item.until ??= DateUtils.dateOnly(
                    DateTime.now(),
                  ).add(const Duration(days: 14));
                  item.weekdays = {item.startTime.toLocal().weekday};
                }
                onChanged();
              },
              title: const Text('Сделать регулярной'),
              subtitle: const Text('Дни недели + время + до какого числа'),
            ),

            if (item.isRecurring) ...[
              const SizedBox(height: 8),
              _RecurringControls(item: item, onChanged: onChanged),
            ],
          ],
        ),
      ),
    );
  }

  // ✅ одна единственная версия _whenText
  String _whenText(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    return '${loc.formatMediumDate(dt)} • ${loc.formatTimeOfDay(TimeOfDay.fromDateTime(dt))}';
  }
}

class _RecurringControls extends StatelessWidget {
  final _PlanItem item;
  final VoidCallback onChanged;

  const _RecurringControls({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Future<void> pickTime() async {
      final t = await showTimePicker(
        context: context,
        initialTime: item.time ?? const TimeOfDay(hour: 9, minute: 0),
      );
      if (t != null) {
        item.time = t;
        onChanged();
      }
    }

    Future<void> pickUntil() async {
      final d = await showDatePicker(
        context: context,
        initialDate: item.until ?? DateTime.now().add(const Duration(days: 14)),
        firstDate: DateUtils.dateOnly(DateTime.now()),
        lastDate: DateUtils.dateOnly(
          DateTime.now(),
        ).add(const Duration(days: 365)),
      );
      if (d != null) {
        item.until = DateUtils.dateOnly(d);
        onChanged();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Дни недели',
          style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (i) {
            final wd = i + 1; // 1..7
            final selected = item.weekdays.contains(wd);
            final label = _wdLabel(wd);

            return FilterChip(
              label: Text(label),
              selected: selected,
              onSelected: (v) {
                if (v) {
                  item.weekdays.add(wd);
                } else {
                  item.weekdays.remove(wd);
                }
                onChanged();
              },
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: pickTime,
                icon: const Icon(Icons.schedule_rounded),
                label: Text('Время: ${_timeStr(item.time)}'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: pickUntil,
                icon: const Icon(Icons.event_rounded),
                label: Text('До: ${_dateStr(context, item.until)}'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Будет создано по выбранным дням недели до указанной даты.',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  String _wdLabel(int wd) {
    switch (wd) {
      case 1:
        return 'Пн';
      case 2:
        return 'Вт';
      case 3:
        return 'Ср';
      case 4:
        return 'Чт';
      case 5:
        return 'Пт';
      case 6:
        return 'Сб';
      case 7:
        return 'Вс';
      default:
        return '$wd';
    }
  }

  String _timeStr(TimeOfDay? t) {
    if (t == null) return '—';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  String _dateStr(BuildContext context, DateTime? d) {
    if (d == null) return '—';
    return MaterialLocalizations.of(context).formatMediumDate(d);
  }
}

class _HoursField extends StatefulWidget {
  final double initial;
  final ValueChanged<double> onChanged;

  const _HoursField({required this.initial, required this.onChanged});

  @override
  State<_HoursField> createState() => _HoursFieldState();
}

class _HoursFieldState extends State<_HoursField> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(
      text: widget.initial.toStringAsFixed(
        widget.initial == widget.initial.roundToDouble() ? 0 : 1,
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Длительность (ч)',
        border: OutlineInputBorder(),
      ),
      onChanged: (v) {
        final x = double.tryParse(v.replaceAll(',', '.'));
        if (x != null) widget.onChanged(x);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────

class _PlanItem {
  final String id;
  final String title;
  String? description;
  String lifeBlock;
  int importance;
  DateTime startTime;
  double plannedHours;
  String? reason;

  bool accepted;

  // recurring options
  bool isRecurring;
  Set<int> weekdays; // 1..7
  TimeOfDay? time;
  DateTime? until;

  _PlanItem({
    required this.id,
    required this.title,
    required this.lifeBlock,
    required this.importance,
    required this.startTime,
    required this.plannedHours,
    this.description,
    this.reason,
    this.accepted = true,
    this.isRecurring = false,
    Set<int>? weekdays,
    this.time,
    this.until,
  }) : weekdays = weekdays ?? <int>{};

  // ✅ допустимые значения dropdown
  static const Set<String> allowedLifeBlocks = {
    'general',
    'sport',
    'health',
    'business',
    'creative',
    'family',
    'travel',
    'science',
  };

  // ✅ нормализация значений, которые может вернуть LLM
  static String normalizeLifeBlock(String? raw) {
    final v = (raw ?? '').trim().toLowerCase();

    if (v == 'career') return 'business';
    if (v == 'work') return 'business';
    if (v == 'finance') return 'business';
    if (v == 'wellbeing') return 'health';
    if (v == 'fitness') return 'sport';

    if (allowedLifeBlocks.contains(v)) return v;
    return 'general';
  }

  factory _PlanItem.fromMap(Map<String, dynamic> m) {
    return _PlanItem(
      id: m['id'] as String,
      title: (m['title'] ?? '').toString(),
      description: (m['description'] ?? '').toString(),
      lifeBlock: normalizeLifeBlock(m['life_block']?.toString()),
      importance: (m['importance'] ?? 1) as int,
      startTime: DateTime.parse(m['start_time'] as String),
      plannedHours: (m['planned_hours'] is num)
          ? (m['planned_hours'] as num).toDouble()
          : 0,
      reason: (m['reason'] ?? '').toString(),
      accepted: true,
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;

  const _ErrorBox({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.error.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ошибка',
            style: TextStyle(
              color: cs.onErrorContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(text, style: TextStyle(color: cs.onErrorContainer)),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ),
        ],
      ),
    );
  }
}
