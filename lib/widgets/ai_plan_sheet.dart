// lib/widgets/ai_plan_sheet.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nest_app/l10n/app_localizations.dart';

import '../main.dart'; // dbRepo

/// Bottom sheet: AI plan suggestions → user accepts/rejects → apply to goals.
///
/// ✅ Fixed compilation issues:
/// - adds missing `_planId`
/// - aligns `_run()` with your DB schema (`ai_plans` + `ai_plan_items`)
/// - removes invalid `plannedHours` usage (we use `hours`)
/// - parses `planned_hours` → `hours`, `description`/`reason` → `note`
/// - keeps `_items` strictly typed List<_PlanItem>
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

class _AiPlanSheetState extends State<AiPlanSheet> {
  bool _loading = true;
  String? _error;

  // ✅ typed
  List<_PlanItem> _items = [];

  // Optional meta
  DateTime? _createdAt;
  String? _sourcePeriod;

  // ✅ needed (was missing)
  String? _planId;

  @override
  void initState() {
    super.initState();
    _run(requireConfirm: false);
  }

  Future<void> _run({required bool requireConfirm}) async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
      _items = [];
      _createdAt = null;
      _sourcePeriod = null; // horizon/period from ai_plans
      _planId = null;
    });

    try {
      final client = Supabase.instance.client;

      // 1) Latest plan from ai_plans
      final planRow = await client
          .from('ai_plans')
          .select('id, created_at, horizon')
          .eq('user_id', dbRepo.uid)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (!mounted) return;

      if (planRow == null) {
        setState(() {
          _loading = false;
          _items = [];
        });

        if (requireConfirm) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Пока нет AI-планов. Сначала запусти генерацию.'),
            ),
          );
        }
        return;
      }

      final planId = (planRow['id'] ?? '').toString();
      final createdAt = DateTime.tryParse(
        (planRow['created_at'] ?? '').toString(),
      )?.toLocal();
      final horizon = (planRow['horizon'] ?? '').toString();

      // 2) Suggested items for this plan
      final rows = await client
          .from('ai_plan_items')
          .select(
            'id, title, description, life_block, importance, start_time, planned_hours, reason, state, created_at',
          )
          .eq('user_id', dbRepo.uid)
          .eq('plan_id', planId)
          .eq('state', 'suggested')
          .order('start_time', ascending: true);

      if (!mounted) return;

      final list = (rows is List) ? rows : const <dynamic>[];

      final parsed = list
          .whereType<Map>()
          .map((e) => _PlanItem.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      // normalize + defaults
      for (final it in parsed) {
        it.lifeBlock = _PlanItem.normalizeLifeBlock(it.lifeBlock);
        it.hours = it.hours.isFinite ? it.hours : 0.0;
        it.accepted = true;
      }

      setState(() {
        _planId = planId;
        _createdAt = createdAt;
        _sourcePeriod = horizon.isEmpty ? null : horizon;
        _items = parsed;
        _loading = false;
      });

      if (requireConfirm && parsed.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('План пуст — попробуй ещё раз')),
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

  String _desc(_PlanItem it) {
    final parts = <String>[];
    if (it.lifeBlock.trim().isNotEmpty) parts.add(it.lifeBlock.trim());
    if (it.hours > 0) parts.add('${it.hours.toStringAsFixed(1)} ч');
    if (it.recurring != null && it.recurring!.trim().isNotEmpty) {
      parts.add(it.recurring!.trim());
    }
    return parts.join(' • ');
  }

  Future<void> _applyAccepted() async {
    final accepted = _items.where((x) => x.accepted).toList();
    if (accepted.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нечего применять — выбери пункты')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      for (final it in accepted) {
        await dbRepo.createGoal(
          title: it.title,
          description: it.note ?? '',
          deadline: widget.date,
          lifeBlock: it.lifeBlock.isEmpty
              ? (widget.lifeBlock ?? '')
              : it.lifeBlock,
          importance: it.importance,
          emotion: '',
          spentHours: it.hours,
          startTime: widget.date,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Добавлено задач: ${accepted.length}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
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
              // header row
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI-план на ${MaterialLocalizations.of(context).formatShortDate(widget.date)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Обновить',
                    onPressed: _loading
                        ? null
                        : () => _run(requireConfirm: true),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),

              if (_createdAt != null || (_sourcePeriod ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 10),
                  child: Row(
                    children: [
                      if (_createdAt != null)
                        Text(
                          'Обновлено: ${MaterialLocalizations.of(context).formatShortDate(_createdAt!)}',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      if ((_sourcePeriod ?? '').isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Text(
                            _sourcePeriod!,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
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
                const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (_error != null)
                _ErrorBox(
                  text: _error!,
                  onRetry: () => _run(requireConfirm: true),
                )
              else if (_items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text('Пока нет рекомендаций. Нажми “Обновить”.'),
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
                      onPressed: _loading ? null : _applyAccepted,
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),

          // editable controls
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

          _RecurringControls(item: item, onChanged: onChanged),

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
// Missing widgets restored
// -----------------------------------------------------------------------------

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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onErrorContainer),
            maxLines: 6,
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
      _ctrl.text = widget.value == 0 ? '' : widget.value.toStringAsFixed(1);
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
    final cs = Theme.of(context).colorScheme;

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

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
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
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.20),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
          ),
          child: Text(
            item.accepted ? 'принято' : 'в списке',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Plan item model (aligned with your DB schema ai_plan_items)
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
  });

  final String id;
  String title;
  String lifeBlock;
  double hours; // <- mapped from planned_hours
  int importance;
  bool accepted;

  String? note; // <- description/reason
  String? recurring;

  static const List<String> lifeBlocks = [
    'Work',
    'Health',
    'Family',
    'Finance',
    'Growth',
    'Social',
    'Rest',
    'Other',
  ];

  static String normalizeLifeBlock(String v) {
    final s = v.trim();
    if (s.isEmpty) return '';
    final found = lifeBlocks.firstWhere(
      (x) => x.toLowerCase() == s.toLowerCase(),
      orElse: () => '',
    );
    return found.isEmpty ? s : found;
  }

  static double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('${v ?? ''}'.replaceAll(',', '.')) ?? 0.0;
  }

  static int _asInt(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? 1;
  }

  factory _PlanItem.fromMap(Map<String, dynamic> m) {
    // DB schema:
    // title, description, life_block, importance, planned_hours, reason, state
    final desc = (m['description'] ?? '').toString();
    final reason = (m['reason'] ?? '').toString();
    final note = [desc, reason].where((x) => x.trim().isNotEmpty).join('\n');

    return _PlanItem(
      id: (m['id'] ?? UniqueKey().toString()).toString(),
      title: (m['title'] ?? '').toString().trim(),
      lifeBlock: (m['life_block'] ?? m['lifeBlock'] ?? '').toString(),
      hours: _asDouble(m['planned_hours'] ?? m['hours']),
      importance: _asInt(m['importance']),
      accepted: true,
      note: note.trim().isEmpty ? null : note.trim(),
      recurring: (m['recurring'] ?? m['repeat'] ?? '').toString().trim().isEmpty
          ? null
          : (m['recurring'] ?? m['repeat']).toString().trim(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'life_block': lifeBlock,
    'planned_hours': hours,
    'importance': importance,
    'accepted': accepted,
    'note': note,
    'recurring': recurring,
  };
}

// Optional helper if later want to save back
extension _PlanListX on List<_PlanItem> {
  List<Map<String, dynamic>> toJsonList() => map((e) => e.toMap()).toList();
}
