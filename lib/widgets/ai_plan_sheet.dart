// lib/widgets/ai_plan_sheet.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart'; // dbRepo

/// Bottom sheet: AI plan suggestions → user accepts/rejects → apply to goals.
///
/// What this version does:
/// - runs Supabase Edge Function `ai-plan` to generate a fresh weekly/monthly plan
/// - falls back to the latest saved plan from `ai_plans` + `ai_plan_items`
/// - supports several backend response shapes:
///   1) { ok: true, plan: {...}, items: [...] }
///   2) { ok: true, data: { plan: {...}, items: [...] } }
///   3) { ok: true, plan_id: "..." } and then loads items from DB
/// - applies accepted suggestions into `goals` using dbRepo.createGoal(...)
/// - marks accepted/rejected items in `ai_plan_items.state` when possible
class AiPlanSheet extends StatefulWidget {
  const AiPlanSheet({super.key, required this.date, this.lifeBlock});

  final DateTime date;
  final String? lifeBlock;

  static Future<void> open(
    BuildContext context, {
    required DateTime date,
    String? lifeBlock,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AiPlanSheet(date: date, lifeBlock: lifeBlock),
    );
  }

  @override
  State<AiPlanSheet> createState() => _AiPlanSheetState();
}

enum _PlanHorizon { week, month }

class _AiPlanSheetState extends State<AiPlanSheet> {
  bool _loading = true;
  bool _applying = false;
  String? _error;

  List<_PlanItem> _items = [];

  DateTime? _createdAt;
  String? _planId;
  String? _source;
  _PlanHorizon _horizon = _PlanHorizon.week;

  @override
  void initState() {
    super.initState();
    _run(generateFresh: true, showSnack: false);
  }

  String get _horizonValue => _horizon == _PlanHorizon.week ? 'week' : 'month';

  String get _horizonLabel => _horizon == _PlanHorizon.week ? 'Неделя' : 'Месяц';

  DateTime get _periodStart => DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
      );

  DateTime get _periodEnd {
    if (_horizon == _PlanHorizon.week) {
      return _periodStart.add(const Duration(days: 6));
    }
    return DateTime(_periodStart.year, _periodStart.month + 1, _periodStart.day)
        .subtract(const Duration(days: 1));
  }

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _run({required bool generateFresh, required bool showSnack}) async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
      _items = [];
      _createdAt = null;
      _planId = null;
      _source = null;
    });

    try {
      if (generateFresh) {
        final generated = await _generatePlanViaFunction();
        if (generated) {
          if (!mounted) return;
          setState(() => _loading = false);
          if (showSnack && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('AI-план обновлён')),
            );
          }
          return;
        }
      }

      await _loadLatestSavedPlan();

      if (!mounted) return;
      setState(() => _loading = false);

      if (showSnack && _items.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('План пуст. Проверь Edge Function ai-plan.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<bool> _generatePlanViaFunction() async {
    final client = Supabase.instance.client;

    final response = await client.functions.invoke(
      'ai-plan',
      body: {
        'horizon': _horizonValue,
        'period': _horizonValue,
        'date': _isoDate(widget.date),
        'date_from': _isoDate(_periodStart),
        'date_to': _isoDate(_periodEnd),
        if ((widget.lifeBlock ?? '').trim().isNotEmpty)
          'life_block': widget.lifeBlock!.trim(),
      },
    );

    final raw = response.data;
    if (raw == null) return false;

    final data = _asMap(raw);
    if (data.isEmpty) return false;

    final nested = _asMap(data['data']);
    final root = nested.isNotEmpty ? nested : data;

    final ok = root['ok'];
    if (ok == false) {
      throw Exception((root['error'] ?? 'Edge Function ai-plan returned ok=false').toString());
    }

    final planMap = _asMap(root['plan'] ?? root['ai_plan']);
    final planId = (root['plan_id'] ?? root['planId'] ?? planMap['id'] ?? '').toString();

    final itemsRaw = root['items'] ?? root['plan_items'] ?? root['suggestions'];
    final parsedItems = _parseItems(itemsRaw);

    if (parsedItems.isNotEmpty) {
      _normalizeItems(parsedItems);
      if (!mounted) return true;
      setState(() {
        _planId = planId.isEmpty ? null : planId;
        _createdAt = _parseDateTime(planMap['created_at'] ?? root['created_at']);
        _source = 'generated:${_horizonValue}';
        _items = parsedItems;
      });
      return true;
    }

    if (planId.isNotEmpty) {
      await _loadPlanById(planId);
      return _items.isNotEmpty;
    }

    return false;
  }

  Future<void> _loadLatestSavedPlan() async {
    final client = Supabase.instance.client;

    var query = client
        .from('ai_plans')
        .select('id, created_at, horizon, period, date_from, date_to')
        .eq('user_id', dbRepo.uid);

    // The column may be named horizon or period depending on your schema.
    // We first try without strict filtering to avoid breaking if one column is absent.
    final rows = await query.order('created_at', ascending: false).limit(10);
    final list = (rows is List) ? rows : const <dynamic>[];

    Map<String, dynamic>? selected;
    for (final row in list.whereType<Map>()) {
      final m = Map<String, dynamic>.from(row);
      final h = (m['horizon'] ?? m['period'] ?? '').toString();
      if (h.isEmpty || h == _horizonValue) {
        selected = m;
        break;
      }
    }
    selected ??= list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).firstOrNull;

    if (selected == null) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _planId = null;
        _createdAt = null;
        _source = 'none';
      });
      return;
    }

    final planId = (selected['id'] ?? '').toString();
    await _loadPlanById(planId, planRow: selected);
  }

  Future<void> _loadPlanById(
    String planId, {
    Map<String, dynamic>? planRow,
  }) async {
    if (planId.isEmpty) return;

    final client = Supabase.instance.client;

    final rows = await client
        .from('ai_plan_items')
        .select(
          'id, title, description, life_block, importance, start_time, planned_hours, reason, state, recurring, repeat, created_at, user_goal_id',
        )
        .eq('user_id', dbRepo.uid)
        .eq('plan_id', planId)
        .inFilter('state', ['suggested', 'accepted'])
        .order('start_time', ascending: true);

    final parsed = _parseItems(rows);
    _normalizeItems(parsed);

    if (!mounted) return;
    setState(() {
      _planId = planId;
      _createdAt = _parseDateTime(planRow?['created_at']);
      _source = (planRow?['horizon'] ?? planRow?['period'] ?? _horizonValue).toString();
      _items = parsed;
    });
  }

  Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return <String, dynamic>{};
  }

  List<_PlanItem> _parseItems(dynamic raw) {
    if (raw is! List) return <_PlanItem>[];
    return raw
        .whereType<Map>()
        .map((e) => _PlanItem.fromMap(Map<String, dynamic>.from(e)))
        .where((e) => e.title.trim().isNotEmpty)
        .toList();
  }

  void _normalizeItems(List<_PlanItem> items) {
    for (final it in items) {
      it.lifeBlock = _PlanItem.normalizeLifeBlock(
        it.lifeBlock.isEmpty ? (widget.lifeBlock ?? '') : it.lifeBlock,
      );
      it.hours = it.hours.isFinite ? it.hours : 0.0;
      if (it.importance < 1) it.importance = 1;
      if (it.importance > 5) it.importance = 5;
      it.accepted = true;
    }
  }

  DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString())?.toLocal();
  }

  String _desc(_PlanItem it) {
    final parts = <String>[];
    if (it.lifeBlock.trim().isNotEmpty) parts.add(it.lifeBlock.trim());
    if (it.hours > 0) parts.add('${it.hours.toStringAsFixed(1)} ч');
    parts.add('важность ${it.importance}/5');
    if (it.startTime != null) {
      final d = it.startTime!;
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      parts.add('$dd.$mm');
    }
    if ((it.userGoalId ?? '').trim().isNotEmpty) {
      parts.add('связано с целью');
    }
    if (it.recurring != null && it.recurring!.trim().isNotEmpty) {
      parts.add(it.recurring!.trim());
    }
    return parts.join(' • ');
  }

  Future<void> _applyAccepted() async {
    final accepted = _items.where((x) => x.accepted == true).toList();
    final rejected = _items.where((x) => x.accepted != true).toList();

    if (accepted.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нечего применять — выбери пункты')),
      );
      return;
    }

    setState(() {
      _applying = true;
      _loading = true;
      _error = null;
    });

    try {
      final client = Supabase.instance.client;
      final userId = dbRepo.uid;

      for (final it in accepted) {
        final start = it.startTime ?? widget.date;
        final safeImportance = _safeInt(it.importance, fallback: 3).clamp(1, 5).toInt();
        final safeHours = it.hours.isFinite ? it.hours.clamp(0.0, 24.0).toDouble() : 0.0;
        final safeLifeBlock = _PlanItem.normalizeLifeBlock(
          it.lifeBlock.trim().isEmpty ? (widget.lifeBlock ?? 'other') : it.lifeBlock,
        );
        final safeUserGoalId = (it.userGoalId ?? '').trim();

        final payload = <String, dynamic>{
          'user_id': userId,
          'title': it.title.trim().isEmpty ? 'AI-задача' : it.title.trim(),
          'description': (it.note ?? '').trim(),
          'deadline': start.toUtc().toIso8601String(),
          'life_block': safeLifeBlock.isEmpty ? 'other' : safeLifeBlock,
          'importance': safeImportance,
          'emotion': '',
          'spent_hours': safeHours,
          'start_time': start.toUtc().toIso8601String(),
        };

        if (safeUserGoalId.isNotEmpty) {
          payload['user_goal_id'] = safeUserGoalId;
        }

        await client.from('goals').insert(payload).select('id').maybeSingle();
      }

      await _updateItemStates(accepted, 'accepted');
      await _updateItemStates(rejected, 'rejected');

      if (!mounted) return;

      // Не закрываем bottom sheet автоматически.
      // В Flutter Web/Desktop Navigator иногда находится в состоянии transition lock
      // после async-операций внутри modal bottom sheet, и Navigator.pop() может вызвать
      // assertion: !_debugLocked. Пользователь всё равно может закрыть sheet кнопкой
      // «Закрыть», а мы сразу показываем успешный результат и убираем применённые пункты.
      setState(() {
        _items.removeWhere((x) => x.accepted == true);
        _loading = false;
        _applying = false;
        _error = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Добавлено задач: ${accepted.length}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyApplyError(e);
        _loading = false;
        _applying = false;
      });
    }
  }

  int _safeInt(dynamic value, {required int fallback}) {
    if (value is bool) return value ? 1 : 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? fallback;
  }

  String _friendlyApplyError(Object e) {
    final text = e.toString();
    if (text.contains("type 'bool'") && text.contains("int")) {
      return 'Ошибка типа данных при добавлении задач: одно из полей пришло как true/false вместо числа. Обнови файл ещё раз: в этой версии bool-значения дополнительно приводятся к числам, а поле is_completed больше не отправляется вручную.';
    }
    return text;
  }

  Future<void> _updateItemStates(List<_PlanItem> items, String state) async {
    if (items.isEmpty) return;
    final ids = items
        .map((e) => e.id)
        .where((id) => id.isNotEmpty && !id.startsWith('local_'))
        .toList();
    if (ids.isEmpty) return;

    try {
      await Supabase.instance.client
          .from('ai_plan_items')
          .update({'state': state})
          .eq('user_id', dbRepo.uid)
          .inFilter('id', ids);
    } catch (_) {
      // Applying goals is more important than state sync.
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final acceptedCount = _items.where((x) => x.accepted).length;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI-план на ${_horizon == _PlanHorizon.week ? 'неделю' : 'месяц'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Сгенерировать заново',
                    onPressed: _loading || _applying
                        ? null
                        : () => _run(generateFresh: true, showSnack: true),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<_PlanHorizon>(
                      segments: const [
                        ButtonSegment(
                          value: _PlanHorizon.week,
                          label: Text('Неделя'),
                          icon: Icon(Icons.view_week_rounded),
                        ),
                        ButtonSegment(
                          value: _PlanHorizon.month,
                          label: Text('Месяц'),
                          icon: Icon(Icons.calendar_month_rounded),
                        ),
                      ],
                      selected: {_horizon},
                      onSelectionChanged: _loading || _applying
                          ? null
                          : (v) {
                              setState(() => _horizon = v.first);
                              _run(generateFresh: true, showSnack: false);
                            },
                    ),
                  ),
                ],
              ),

              if (_createdAt != null || (_source ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      if (_createdAt != null)
                        Text(
                          'Обновлено: ${MaterialLocalizations.of(context).formatShortDate(_createdAt!)}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                      if ((_source ?? '').isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Text(
                            _source!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              if (_loading)
                SizedBox(
                  height: 180,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator.adaptive(),
                        const SizedBox(height: 14),
                        Text(_applying ? 'Добавляю задачи...' : 'Генерирую AI-план...'),
                      ],
                    ),
                  ),
                )
              else if (_error != null)
                _ErrorBox(
                  text: _error!,
                  onRetry: () => _run(generateFresh: true, showSnack: true),
                )
              else if (_items.isEmpty)
                _EmptyBox(
                  onGenerate: () => _run(generateFresh: true, showSnack: true),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final it = _items[i];
                      return _PlanCard(
                        item: it,
                        description: _desc(it),
                        onChanged: () => setState(() {}),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      child: const Text('Закрыть'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _loading || _items.isEmpty ? null : _applyAccepted,
                      icon: const Icon(Icons.check_rounded),
                      label: Text('Применить ($acceptedCount)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Card
// -----------------------------------------------------------------------------

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.item,
    required this.description,
    required this.onChanged,
  });

  final _PlanItem item;
  final String description;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safeLifeBlock = _PlanItem.normalizeLifeBlock(item.lifeBlock);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: item.accepted,
                onChanged: (v) {
                  item.accepted = v ?? true;
                  onChanged();
                },
              ),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              IconButton(
                tooltip: item.accepted ? 'Отклонить' : 'Принять',
                onPressed: () {
                  item.accepted = !item.accepted;
                  onChanged();
                },
                icon: Icon(
                  item.accepted
                      ? Icons.thumb_up_alt_rounded
                      : Icons.thumb_down_alt_rounded,
                ),
              ),
            ],
          ),
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 8),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: safeLifeBlock.isEmpty ? null : safeLifeBlock,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Блок',
                    isDense: true,
                  ),
                  items: _PlanItem.lifeBlocks
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) {
                    item.lifeBlock = _PlanItem.normalizeLifeBlock(v ?? '');
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 130,
                child: _HoursField(
                  value: item.hours,
                  onChanged: (v) {
                    item.hours = v;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 135,
                child: DropdownButtonFormField<int>(
                  value: item.importance.clamp(1, 5).toInt(),
                  decoration: const InputDecoration(
                    labelText: 'Важность',
                    isDense: true,
                  ),
                  items: const [1, 2, 3, 4, 5]
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v / 5')))
                      .toList(),
                  onChanged: (v) {
                    item.importance = v ?? 1;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _RecurringControls(item: item, onChanged: onChanged)),
            ],
          ),
          if ((item.note ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.note!.trim(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Helper widgets
// -----------------------------------------------------------------------------

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'План пока пуст',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Нажми кнопку ниже, чтобы сгенерировать план на основе AI-инсайтов, целей, задач, привычек и настроения.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Сгенерировать план'),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.error.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ошибка',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onErrorContainer,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onErrorContainer,
                ),
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Повторить'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoursField extends StatefulWidget {
  const _HoursField({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_HoursField> createState() => _HoursFieldState();
}

class _HoursFieldState extends State<_HoursField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.value == 0 ? '' : widget.value.toStringAsFixed(1),
    );
  }

  @override
  void didUpdateWidget(covariant _HoursField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final next = widget.value == 0 ? '' : widget.value.toStringAsFixed(1);
      if (_ctrl.text != next) _ctrl.text = next;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Часы',
        isDense: true,
        prefixIcon: Icon(Icons.timer_outlined),
      ),
      onChanged: (t) {
        final v = double.tryParse(t.replaceAll(',', '.')) ?? 0.0;
        widget.onChanged(v);
      },
    );
  }
}

class _RecurringControls extends StatelessWidget {
  const _RecurringControls({required this.item, required this.onChanged});

  final _PlanItem item;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final values = <String?>[null, 'daily', 'weekly', 'weekdays'];

    String label(String? v) {
      switch (v) {
        case null:
          return 'Без повтора';
        case 'daily':
          return 'Каждый день';
        case 'weekdays':
          return 'По будням';
        case 'weekly':
          return 'Раз в неделю';
        default:
          return 'Без повтора';
      }
    }

    return DropdownButtonFormField<String?>(
      value: values.contains(item.recurring) ? item.recurring : null,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Повтор',
        isDense: true,
      ),
      items: values
          .map(
            (v) => DropdownMenuItem<String?>(
              value: v,
              child: Text(label(v)),
            ),
          )
          .toList(),
      onChanged: (v) {
        item.recurring = v;
        onChanged();
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Plan item model
// -----------------------------------------------------------------------------

class _PlanItem {
  _PlanItem({
    required this.id,
    required this.title,
    required this.lifeBlock,
    required this.hours,
    required this.importance,
    required this.accepted,
    this.note,
    this.recurring,
    this.startTime,
    this.userGoalId,
  });

  final String id;
  String title;
  String lifeBlock;
  double hours;
  int importance;
  bool accepted;

  String? note;
  String? recurring;
  DateTime? startTime;
  String? userGoalId;

  static const List<String> lifeBlocks = [
    'health',
    'career',
    'family',
    'finance',
    'education',
    'hobbies',
    'other',
  ];

  static String normalizeLifeBlock(String v) {
    final s = v.trim();
    if (s.isEmpty) return '';

    final aliases = <String, String>{
      'work': 'career',
      'growth': 'education',
      'study': 'education',
      'learning': 'education',
      'sport': 'health',
      'rest': 'health',
      'social': 'family',
      'other': 'other',
    };

    final lower = s.toLowerCase();
    if (aliases.containsKey(lower)) return aliases[lower]!;

    final found = lifeBlocks.firstWhere(
      (x) => x.toLowerCase() == lower,
      orElse: () => '',
    );
    return found.isEmpty ? s : found;
  }

  static double _asDouble(dynamic v) {
    if (v is bool) return v ? 1.0 : 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse('${v ?? ''}'.replaceAll(',', '.')) ?? 0.0;
  }

  static int _asInt(dynamic v) {
    if (v is bool) return v ? 1 : 0;
    if (v is num) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? 1;
  }

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString())?.toLocal();
  }

  factory _PlanItem.fromMap(Map<String, dynamic> m) {
    final desc = (m['description'] ?? '').toString();
    final reason = (m['reason'] ?? '').toString();
    final note = [desc, reason].where((x) => x.trim().isNotEmpty).join('\n');

    return _PlanItem(
      id: (m['id'] ?? 'local_${UniqueKey()}').toString(),
      title: (m['title'] ?? m['name'] ?? '').toString().trim(),
      lifeBlock: (m['life_block'] ?? m['lifeBlock'] ?? '').toString(),
      hours: _asDouble(m['planned_hours'] ?? m['plannedHours'] ?? m['hours']),
      importance: _asInt(m['importance'] ?? m['priority']),
      accepted: true,
      note: note.trim().isEmpty ? null : note.trim(),
      recurring: (m['recurring'] ?? m['repeat'] ?? '').toString().trim().isEmpty
          ? null
          : (m['recurring'] ?? m['repeat']).toString().trim(),
      startTime: _asDate(m['start_time'] ?? m['startTime'] ?? m['date']),
      userGoalId: (m['user_goal_id'] ?? m['userGoalId'] ?? '').toString().trim().isEmpty
          ? null
          : (m['user_goal_id'] ?? m['userGoalId']).toString().trim(),
    );
  }
}
