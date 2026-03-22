// lib/widgets/edit_goal_sheet.dart
import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/goal.dart';
import 'add_day_goal_sheet.dart'; // UserGoalLinkOption

import 'nest/nest_card.dart';
import 'nest/nest_pill.dart';
import 'nest/nest_section_title.dart';

class EditGoalResult {
  final String title;
  final String description;
  final String lifeBlock;
  final int importance;
  final String emotion;
  final double hours;
  final TimeOfDay startTime;
  final DateTime date;
  final String? userGoalId;

  const EditGoalResult({
    required this.title,
    required this.description,
    required this.lifeBlock,
    required this.importance,
    required this.emotion,
    required this.hours,
    required this.startTime,
    required this.date,
    this.userGoalId,
  });
}

class EditGoalSheet extends StatefulWidget {
  final Goal goal;
  final String? fixedLifeBlock;
  final List<String> availableBlocks;

  /// Оставлено для совместимости, но больше не используется
  final List<UserGoalLinkOption> availableUserGoals;
  final String? initialUserGoalId;

  const EditGoalSheet({
    super.key,
    required this.goal,
    required this.fixedLifeBlock,
    required this.availableBlocks,
    this.availableUserGoals = const [],
    this.initialUserGoalId,
  });

  @override
  State<EditGoalSheet> createState() => _EditGoalSheetState();
}

class _EditGoalSheetState extends State<EditGoalSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _emotionCtrl;

  final _supabase = Supabase.instance.client;

  late String _lifeBlock;
  late int _importance;
  late double _hours;
  late TimeOfDay _start;
  late DateTime _selectedDate;

  String? _selectedUserGoalId;

  bool _loadingUserGoals = false;
  List<UserGoalLinkOption> _userGoalsForSelectedBlock = const [];

  String _normalizeBlock(String value) {
    final v = value.trim().toLowerCase();

    switch (v) {
      case '':
        return 'general';

      case 'general':
      case 'general ':
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
        return 'health';

      case 'career':
      case 'карьера':
      case 'работа':
      case 'job':
      case 'work':
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
        return 'relationships';

      case 'self':
      case 'selfdevelopment':
      case 'self-development':
      case 'personal':
      case 'personal growth':
      case 'личное':
      case 'саморазвитие':
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

  List<String> get _lifeBlockOptions {
    final seen = <String>{};
    final out = <String>['general'];

    for (final raw in widget.availableBlocks) {
      final b = raw.trim();
      if (b.isEmpty) continue;

      final normalized = _normalizeBlock(b);
      if (seen.add(normalized)) {
        if (normalized == 'general') continue;
        out.add(normalized);
      }
    }

    final current = _normalizeBlock(_lifeBlock);
    if (!out.contains(current)) {
      out.add(current);
    }

    return out;
  }

  String _lifeBlockLabel(String value) {
    switch (_normalizeBlock(value)) {
      case 'general':
        return 'General';
      case 'health':
        return 'Health';
      case 'career':
        return 'Career';
      case 'finance':
        return 'Finance';
      case 'relationships':
        return 'Relationships';
      case 'self':
        return 'Self';
      case 'education':
        return 'Education';
      case 'travel':
        return 'Travel';
      case 'home':
        return 'Home';
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

  String _formatDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}';
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

  @override
  void initState() {
    super.initState();
    final g = widget.goal;

    _titleCtrl = TextEditingController(text: g.title);
    _descCtrl = TextEditingController(text: g.description);
    _emotionCtrl = TextEditingController(text: g.emotion);

    final initialBlock = (widget.fixedLifeBlock?.trim().isNotEmpty ?? false)
        ? widget.fixedLifeBlock!.trim()
        : ((g.lifeBlock?.trim().isNotEmpty ?? false)
            ? g.lifeBlock!.trim()
            : 'general');

    _lifeBlock = _normalizeBlock(initialBlock);
    _importance = g.importance.clamp(1, 3);
    _hours = g.spentHours.clamp(0.5, 14.0);
    _start = TimeOfDay.fromDateTime(g.startTime);
    _selectedDate = DateUtils.dateOnly(g.startTime);

    _selectedUserGoalId = widget.initialUserGoalId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserGoalsForCurrentBlock();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _emotionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _start,
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

    if (picked != null) {
      setState(() => _start = picked);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
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

    if (picked != null) {
      setState(() {
        _selectedDate = DateUtils.dateOnly(picked);
      });
    }
  }

  void _submit() {
    final t = AppLocalizations.of(context)!;

    final title =
        _titleCtrl.text.trim().isEmpty ? t.editGoalUntitled : _titleCtrl.text.trim();

    Navigator.pop(
      context,
      EditGoalResult(
        title: title,
        description: _descCtrl.text.trim(),
        lifeBlock: _normalizeBlock(_lifeBlock),
        importance: _importance,
        emotion: _emotionCtrl.text.trim(),
        hours: _hours,
        startTime: _start,
        date: _selectedDate,
        userGoalId: _selectedUserGoalId,
      ),
    );
  }

  InputDecoration _nestInput({
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final canEditBlock = widget.fixedLifeBlock == null;

    final blocks = _lifeBlockOptions;
    final dropdownValue = blocks.contains(_lifeBlock) ? _lifeBlock : 'general';

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
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const _IconBubble(icon: Icons.edit_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.editGoalTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                NestSectionTitle(t.editGoalSectionDetails),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: _nestInput(
                          label: t.editGoalFieldTitleLabel,
                          hint: t.editGoalFieldTitleHint,
                          icon: Icons.flag_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descCtrl,
                        minLines: 2,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: _nestInput(
                          label: t.editGoalFieldDescLabel,
                          hint: t.editGoalFieldDescHint,
                          icon: Icons.notes_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                NestSectionTitle('Дата и время'),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _pickDate,
                              child: InputDecorator(
                                decoration: _nestInput(
                                  label: 'Дата',
                                  icon: Icons.calendar_today_rounded,
                                ),
                                child: Text(
                                  _formatDate(_selectedDate),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _pickTime,
                              child: InputDecorator(
                                decoration: _nestInput(
                                  label: 'Время',
                                  icon: Icons.schedule_rounded,
                                ),
                                child: Text(
                                  _start.format(context),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canEditBlock) ...[
                  const SizedBox(height: 2),
                  NestSectionTitle(t.editGoalSectionLifeBlock),
                  NestCard(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      value: dropdownValue,
                      decoration: _nestInput(
                        label: t.editGoalFieldLifeBlockLabel,
                        icon: Icons.grid_view_rounded,
                      ),
                      items: blocks
                          .map(
                            (b) => DropdownMenuItem<String>(
                              value: b,
                              child: Text(_lifeBlockLabel(b)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) async {
                        if (v == null) return;

                        final next = _normalizeBlock(v);
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
                ],
                const SizedBox(height: 2),
                NestSectionTitle('Связь с большой целью'),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String?>(
                        value: dropdownGoalValue,
                        decoration: _nestInput(
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
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                NestSectionTitle(t.editGoalSectionParams),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _importance,
                              decoration: _nestInput(
                                label: t.editGoalFieldImportanceLabel,
                                icon: Icons.local_fire_department_rounded,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(t.editGoalImportanceLow),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text(t.editGoalImportanceMedium),
                                ),
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text(t.editGoalImportanceHigh),
                                ),
                              ],
                              onChanged: (v) {
                                setState(() => _importance = v ?? _importance);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _emotionCtrl,
                              textInputAction: TextInputAction.done,
                              decoration: _nestInput(
                                label: t.editGoalFieldEmotionLabel,
                                hint: t.editGoalFieldEmotionHint,
                                icon: Icons.emoji_emotions_outlined,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Icon(
                            Icons.timelapse_rounded,
                            size: 18,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Часы: ${_hours.toStringAsFixed(1)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          NestPill(
                            leading: const Icon(Icons.schedule_rounded, size: 16),
                            text: '${_hours.toStringAsFixed(1)} ч',
                          ),
                        ],
                      ),
                      Slider(
                        value: _hours,
                        min: 0.5,
                        max: 14,
                        divisions: 27,
                        label: _hours.toStringAsFixed(1),
                        onChanged: (v) {
                          setState(() => _hours = v);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
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
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(t.commonSave),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;

  const _IconBubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.primary.withOpacity(0.18),
        ),
      ),
      child: Icon(
        icon,
        color: scheme.primary,
      ),
    );
  }
}