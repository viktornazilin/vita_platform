// lib/widgets/goals/add_day_goal_sheet.dart
import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class AddGoalResult {
  final String title;
  final String description;
  final String lifeBlock;
  final int importance;
  final String emotion;
  final double hours;
  final TimeOfDay startTime;
  final String? userGoalId;

  const AddGoalResult({
    required this.title,
    required this.description,
    required this.lifeBlock,
    required this.importance,
    required this.emotion,
    required this.hours,
    required this.startTime,
    this.userGoalId,
  });
}

class AddDayGoalSheet extends StatefulWidget {
  final String? fixedLifeBlock;
  final List<String> availableBlocks;

  /// Используется как fallback, чтобы показать уже связанную цель,
  /// даже если она не попала в запрос по текущему life_block.
  final List<UserGoalLinkOption> availableUserGoals;

  final String? initialUserGoalId;

  const AddDayGoalSheet({
    super.key,
    required this.fixedLifeBlock,
    this.availableBlocks = const [],
    this.availableUserGoals = const [],
    this.initialUserGoalId,
  });

  @override
  State<AddDayGoalSheet> createState() => _AddDayGoalSheetState();
}

class _AddDayGoalSheetState extends State<AddDayGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _supabase = Supabase.instance.client;
  final _emotions = const ['😊', '😐', '😢', '😎', '😤', '🤔', '😴', '😇'];

  String _emotion = '😊';
  int _importance = 2;
  double _hours = 1.0;
  late String _lifeBlock;
  String? _selectedUserGoalId;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);

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

  UserGoalLinkOption? _findSelectedGoalFallback() {
    final selectedId = _selectedUserGoalId;
    if (selectedId == null) return null;

    for (final g in widget.availableUserGoals) {
      if (g.id == selectedId) return g;
    }

    return null;
  }

  Future<void> _loadUserGoalsForCurrentBlock() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _userGoalsForSelectedBlock = const [];
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
          .toList();

      final selectedId = _selectedUserGoalId;
      if (selectedId != null && !items.any((g) => g.id == selectedId)) {
        final fallback = _findSelectedGoalFallback();
        if (fallback != null) {
          items.add(fallback);
        }
      }

      items.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

      if (!mounted) return;

      setState(() {
        _userGoalsForSelectedBlock = items;
        _loadingUserGoals = false;
      });
    } catch (_) {
      if (!mounted) return;

      final fallback = _findSelectedGoalFallback();

      setState(() {
        _userGoalsForSelectedBlock =
            fallback == null ? const [] : <UserGoalLinkOption>[fallback];
        _loadingUserGoals = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final options = _lifeBlockOptions;
    final fixed = widget.fixedLifeBlock?.trim();

    if (fixed != null && fixed.isNotEmpty) {
      _lifeBlock = _normalizeBlock(fixed);
    } else {
      _lifeBlock = options.contains('general') ? 'general' : options.first;
    }

    _selectedUserGoalId = widget.initialUserGoalId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserGoalsForCurrentBlock();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  void _submit() {
    final l = AppLocalizations.of(context)!;

    if (_titleCtrl.text.trim().isEmpty) {
      final sm = ScaffoldMessenger.maybeOf(context);
      final scheme = Theme.of(context).colorScheme;
      sm?.showSnackBar(
        SnackBar(
          content: Text(
            l.addDayGoalEnterTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: scheme.surfaceContainerHigh.withOpacity(0.92),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      AddGoalResult(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        lifeBlock: _normalizeBlock(_lifeBlock),
        importance: _importance,
        emotion: _emotion,
        hours: _hours,
        startTime: _startTime,
        userGoalId: _selectedUserGoalId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final sheetSurface =
        (isDark ? scheme.surfaceContainerHigh : scheme.surface)
            .withOpacity(isDark ? 0.90 : 0.92);

    final borderColor = scheme.outlineVariant.withOpacity(isDark ? 0.65 : 0.55);

    final lifeBlockOptions = _lifeBlockOptions;

    final dropdownGoalValue = _userGoalsForSelectedBlock.any(
      (g) => g.id == _selectedUserGoalId,
    )
        ? _selectedUserGoalId
        : null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (ctx, controller) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              decoration: BoxDecoration(
                color: sheetSurface,
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          blurRadius: 30,
                          offset: const Offset(0, -12),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFF004A98).withOpacity(0.12),
                          blurRadius: 30,
                          offset: const Offset(0, -10),
                        ),
                      ],
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: scheme.onSurfaceVariant.withOpacity(
                          isDark ? 0.28 : 0.20,
                        ),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.primary.withOpacity(0.95),
                              scheme.primary.withOpacity(0.55),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.addDayGoalTitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Section(
                    child: Column(
                      children: [
                        _PrettyField(
                          controller: _titleCtrl,
                          label: l.addDayGoalFieldTitle,
                          hint: l.addDayGoalTitleHint,
                          icon: Icons.flag_rounded,
                          minLines: 1,
                          maxLines: 2,
                          maxLen: 60,
                        ),
                        const SizedBox(height: 10),
                        _PrettyField(
                          controller: _descCtrl,
                          label: l.addDayGoalFieldDescription,
                          hint: l.addDayGoalDescriptionHint,
                          icon: Icons.notes_rounded,
                          minLines: 2,
                          maxLines: 4,
                          maxLen: 240,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, color: scheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l.addDayGoalStartTime,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: scheme.onSurface,
                                ),
                          ),
                        ),
                        _PillButton(
                          text: _startTime.format(context),
                          onTap: _pickStartTime,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.fixedLifeBlock == null) ...[
                    _Section(
                      child: Row(
                        children: [
                          Icon(Icons.category_rounded, color: scheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l.addDayGoalLifeBlock,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: scheme.onSurface,
                                  ),
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _lifeBlock,
                              dropdownColor: scheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(14),
                              items: lifeBlockOptions
                                  .map(
                                    (b) => DropdownMenuItem<String>(
                                      value: b,
                                      child: Text(
                                        _lifeBlockLabel(b),
                                        style: TextStyle(color: scheme.onSurface),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) async {
                                final next = _normalizeBlock(v ?? _lifeBlock);
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
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _Section(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.link_rounded, color: scheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Связать с целью',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: scheme.onSurface,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String?>(
                          value: dropdownGoalValue,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Большая цель',
                            filled: true,
                            fillColor: isDark
                                ? scheme.surfaceContainerHighest.withOpacity(0.36)
                                : Colors.white.withOpacity(0.78),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: scheme.outlineVariant.withOpacity(0.60),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: scheme.outlineVariant.withOpacity(0.55),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: scheme.primary,
                                width: 1.4,
                              ),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                'Без связи',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ..._userGoalsForSelectedBlock.map(
                              (g) => DropdownMenuItem<String?>(
                                value: g.id,
                                child: Text(
                                  '${g.title} · ${_horizonLabel(g.horizon)}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                          selectedItemBuilder: (context) {
                            return [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Без связи',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              ..._userGoalsForSelectedBlock.map(
                                (g) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${g.title} · ${_horizonLabel(g.horizon)}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ];
                          },
                          onChanged: _loadingUserGoals
                              ? null
                              : (v) {
                                  setState(() => _selectedUserGoalId = v);
                                },
                        ),
                        if (_loadingUserGoals) ...[
                          const SizedBox(height: 10),
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
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.addDayGoalImportance,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: List.generate(3, (i) {
                            final v = i + 1;
                            final selected = _importance == v;

                            return ChoiceChip(
                              label: Text('$v'),
                              selected: selected,
                              onSelected: (_) => setState(() => _importance = v),
                              selectedColor: scheme.primary.withOpacity(0.18),
                              backgroundColor:
                                  scheme.surfaceContainerHighest.withOpacity(0.75),
                              side: BorderSide(
                                color: selected
                                    ? scheme.primary.withOpacity(0.35)
                                    : scheme.outlineVariant.withOpacity(0.65),
                              ),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface.withOpacity(
                                  selected ? 1 : 0.80,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.addDayGoalEmotion,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: _emotions.map((e) {
                            final selected = _emotion == e;
                            return ChoiceChip(
                              label: Text(
                                e,
                                style: const TextStyle(fontSize: 18),
                              ),
                              selected: selected,
                              onSelected: (_) => setState(() => _emotion = e),
                              selectedColor: scheme.primary.withOpacity(0.18),
                              backgroundColor:
                                  scheme.surfaceContainerHighest.withOpacity(0.75),
                              side: BorderSide(
                                color: selected
                                    ? scheme.primary.withOpacity(0.35)
                                    : scheme.outlineVariant.withOpacity(0.65),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.addDayGoalHours,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: scheme.onSurface,
                                    ),
                              ),
                            ),
                            _Pill(text: _hours.toStringAsFixed(1)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          min: 0.5,
                          max: 14.0,
                          divisions: 27,
                          value: _hours,
                          onChanged: (v) => setState(() => _hours = v),
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
                          child: Text(l.commonCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          child: Text(l.commonAdd),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final Widget child;
  const _Section({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark
        ? scheme.surfaceContainer.withOpacity(0.72)
        : scheme.surfaceContainerHigh.withOpacity(0.85);

    final border = scheme.outlineVariant.withOpacity(isDark ? 0.55 : 0.50);

    final shadow = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF004A98).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}

class _PrettyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int minLines;
  final int maxLines;
  final int? maxLen;

  const _PrettyField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLen,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLen,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isDark
            ? scheme.surfaceContainerHighest.withOpacity(0.36)
            : Colors.white.withOpacity(0.78),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withOpacity(0.60),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withOpacity(0.55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _PillButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: scheme.primary.withOpacity(0.25)),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.primary.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
      ),
    );
  }
}