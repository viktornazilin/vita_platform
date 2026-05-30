// lib/widgets/edit_goal_sheet.dart
import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/goal.dart';
import 'add_day_goal_sheet.dart';

import 'nest/nest_card.dart';
import 'nest/nest_pill.dart';
import 'nest/nest_section_title.dart';

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
  late final TextEditingController _startTimeCtrl;
  late final TextEditingController _endTimeCtrl;

  final _supabase = Supabase.instance.client;

  late String _lifeBlock;
  late int _importance;
  late double _hours;
  late TimeOfDay _start;
  late TimeOfDay _end;
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
      case 'finances':
      case 'финансы':
      case 'money':
      case 'financial':
        return 'finances';

      case 'family':
      case 'семья':
        return 'family';

      case 'relationships':
      case 'relationship':
      case 'relations':
      case 'отношения':
        return 'relationships';

      case 'hobbies':
      case 'hobby':
      case 'хобби':
        return 'hobbies';

      case 'spirituality':
      case 'духовность':
        return 'spirituality';

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

  String _lifeBlockLabel(BuildContext context, String value) {
    final t = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();

    String local({
      required String ru,
      required String en,
      required String de,
      required String fr,
      required String es,
      required String tr,
    }) {
      switch (lang) {
        case 'de':
          return de;
        case 'fr':
          return fr;
        case 'es':
          return es;
        case 'tr':
          return tr;
        case 'en':
          return en;
        case 'ru':
        default:
          return ru;
      }
    }

    switch (_normalizeBlock(value)) {
      case 'general':
        return t.lifeBlockGeneral;
      case 'health':
        return t.lifeBlockHealth;
      case 'career':
        return t.lifeBlockCareer;
      case 'finance':
      case 'finances':
        return t.lifeBlockFinance;
      case 'family':
        return local(
          ru: 'Семья',
          en: 'Family',
          de: 'Familie',
          fr: 'Famille',
          es: 'Familia',
          tr: 'Aile',
        );
      case 'relationships':
        return t.lifeBlockRelations;
      case 'hobbies':
        return local(
          ru: 'Хобби',
          en: 'Hobbies',
          de: 'Hobbys',
          fr: 'Loisirs',
          es: 'Aficiones',
          tr: 'Hobiler',
        );
      case 'spirituality':
        return local(
          ru: 'Духовность',
          en: 'Spirituality',
          de: 'Spiritualität',
          fr: 'Spiritualité',
          es: 'Espiritualidad',
          tr: 'Maneviyat',
        );
      case 'self':
        return t.lifeBlockSelf;
      case 'education':
        return t.lifeBlockEducation;
      case 'travel':
        return t.lifeBlockTravel;
      case 'home':
        return t.lifeBlockHome;
      default:
        return value;
    }
  }

  String _horizonLabel(BuildContext context, String value) {
    final t = AppLocalizations.of(context)!;

    switch (value.trim().toLowerCase()) {
      case 'tactical':
        return t.horizonTactical;
      case 'mid':
        return t.horizonMid;
      case 'long':
        return t.horizonLong;
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
        ..sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );

      if (!mounted) return;

      final stillValid = _selectedUserGoalId != null &&
          items.any((g) => g.id == _selectedUserGoalId);

      setState(() {
        _userGoalsForSelectedBlock = items;
        if (!stillValid) {
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

    final initialBlock = (widget.fixedLifeBlock?.trim().isNotEmpty ?? false)
        ? widget.fixedLifeBlock!.trim()
        : ((g.lifeBlock?.trim().isNotEmpty ?? false)
            ? g.lifeBlock!.trim()
            : 'general');

    _lifeBlock = _normalizeBlock(initialBlock);
    _importance = g.importance.clamp(1, 3);
    _hours = g.spentHours.clamp(0.5, 14.0);
    _start = TimeOfDay.fromDateTime(g.startTime);
    final endDateTime = g.startTime.add(Duration(minutes: (_hours * 60).round()));
    _end = TimeOfDay.fromDateTime(endDateTime);
    _startTimeCtrl = TextEditingController(text: _formatTime(_start));
    _endTimeCtrl = TextEditingController(text: _formatTime(_end));
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
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    super.dispose();
  }

  String _localeCode(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return {'ru', 'en', 'de', 'fr', 'es', 'tr'}.contains(code) ? code : 'en';
  }

  String _localized(BuildContext context, Map<String, String> values) {
    final code = _localeCode(context);
    return values[code] ?? values['en'] ?? values.values.first;
  }

  String _endTimeLabel(BuildContext context) => _localized(context, const {
        'ru': 'Время окончания',
        'en': 'End time',
        'de': 'Endzeit',
        'fr': 'Heure de fin',
        'es': 'Hora de fin',
        'tr': 'Bitiş saati',
      });

  String _durationLabel(BuildContext context, double hours) {
    final value = hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1);
    return _localized(context, {
      'ru': 'Будет записано: $value ч',
      'en': 'Will be saved: ${value}h',
      'de': 'Wird gespeichert: ${value} Std.',
      'fr': 'Sera enregistré : ${value} h',
      'es': 'Se guardará: ${value} h',
      'tr': 'Kaydedilecek: ${value} sa',
    });
  }

  String _timeErrorText(BuildContext context) => _localized(context, const {
        'ru': 'Введите время в формате 09:30 или 930',
        'en': 'Enter time as 09:30 or 930',
        'de': 'Zeit als 09:30 oder 930 eingeben',
        'fr': 'Saisis l’heure comme 09:30 ou 930',
        'es': 'Introduce la hora como 09:30 o 930',
        'tr': 'Saati 09:30 veya 930 olarak gir',
      });

  String _formatTime(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _parseTimeInput(String raw) {
    var v = raw.trim().replaceAll('.', ':').replaceAll(' ', '');
    if (v.isEmpty) return null;

    int? hour;
    int minute = 0;

    if (v.contains(':')) {
      final parts = v.split(':');
      if (parts.isEmpty || parts.length > 2) return null;
      hour = int.tryParse(parts[0]);
      minute = parts.length == 2 && parts[1].isNotEmpty
          ? int.tryParse(parts[1]) ?? -1
          : 0;
    } else {
      final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isEmpty || digits.length > 4) return null;

      if (digits.length <= 2) {
        hour = int.tryParse(digits);
      } else {
        final padded = digits.padLeft(4, '0');
        hour = int.tryParse(padded.substring(0, padded.length - 2));
        minute = int.tryParse(padded.substring(padded.length - 2)) ?? -1;
      }
    }

    if (hour == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  int _minutesOf(TimeOfDay value) => value.hour * 60 + value.minute;

  double get _calculatedHours {
    var diff = _minutesOf(_end) - _minutesOf(_start);
    if (diff <= 0) diff += 24 * 60;
    return (diff / 60).clamp(0.25, 24.0);
  }

  void _onStartTimeChanged(String raw) {
    final parsed = _parseTimeInput(raw);
    if (parsed == null) return;
    setState(() {
      _start = parsed;
      _hours = _calculatedHours;
    });
  }

  void _onEndTimeChanged(String raw) {
    final parsed = _parseTimeInput(raw);
    if (parsed == null) return;
    setState(() {
      _end = parsed;
      _hours = _calculatedHours;
    });
  }

  void _normalizeStartTimeField() {
    final parsed = _parseTimeInput(_startTimeCtrl.text);
    if (parsed == null) {
      _startTimeCtrl.text = _formatTime(_start);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(_timeErrorText(context))),
      );
      return;
    }
    setState(() {
      _start = parsed;
      _hours = _calculatedHours;
      _startTimeCtrl.text = _formatTime(parsed);
    });
  }

  void _normalizeEndTimeField() {
    final parsed = _parseTimeInput(_endTimeCtrl.text);
    if (parsed == null) {
      _endTimeCtrl.text = _formatTime(_end);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(_timeErrorText(context))),
      );
      return;
    }
    setState(() {
      _end = parsed;
      _hours = _calculatedHours;
      _endTimeCtrl.text = _formatTime(parsed);
    });
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

    final title = _titleCtrl.text.trim().isEmpty
        ? t.editGoalUntitled
        : _titleCtrl.text.trim();

    Navigator.pop(
      context,
      AddGoalResult(
        title: title,
        description: _descCtrl.text.trim(),
        lifeBlock: _normalizeBlock(_lifeBlock),
        importance: _importance,
        emotion: '',
        hours: _calculatedHours,
        startTime: _start,
        endTime: _end,
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
                        style: theme.textTheme.titleLarge?.copyWith(
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
                NestSectionTitle(t.editGoalSectionDateTime),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 430;

                      final dateField = InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: _nestInput(
                            label: t.commonDate,
                            icon: Icons.calendar_today_rounded,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _formatDate(_selectedDate),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );

                      final startTimeField = _EditTimeTextField(
                        controller: _startTimeCtrl,
                        label: t.editGoalStartTime,
                        onChanged: _onStartTimeChanged,
                        onEditingComplete: _normalizeStartTimeField,
                      );

                      final endTimeField = _EditTimeTextField(
                        controller: _endTimeCtrl,
                        label: _endTimeLabel(context),
                        onChanged: _onEndTimeChanged,
                        onEditingComplete: _normalizeEndTimeField,
                      );

                      final durationInfo = Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _durationLabel(context, _calculatedHours),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );

                      if (narrow) {
                        return Column(
                          children: [
                            dateField,
                            const SizedBox(height: 12),
                            startTimeField,
                            const SizedBox(height: 12),
                            endTimeField,
                            const SizedBox(height: 10),
                            durationInfo,
                          ],
                        );
                      }

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: dateField),
                              const SizedBox(width: 12),
                              Expanded(child: startTimeField),
                            ],
                          ),
                          const SizedBox(height: 12),
                          endTimeField,
                          const SizedBox(height: 10),
                          durationInfo,
                        ],
                      );
                    },
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
                              child: Text(_lifeBlockLabel(context, b)),
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
                NestSectionTitle(t.editGoalSectionUserGoalLink),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String?>(
                        value: dropdownGoalValue,
                        decoration: _nestInput(
                          label: t.userGoalLinkFieldLabel,
                          icon: Icons.link_rounded,
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(t.userGoalLinkNone),
                          ),
                          ..._userGoalsForSelectedBlock.map(
                            (g) => DropdownMenuItem<String?>(
                              value: g.id,
                              child: Text(
                                '${g.title} · ${_horizonLabel(context, g.horizon)}',
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
                                t.userGoalLinkLoadingForBlock(_lifeBlockLabel(context, _lifeBlock)),
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
                          t.userGoalLinkNoGoalsForBlock(_lifeBlockLabel(context, _lifeBlock)),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 430;

                      final importanceField = DropdownButtonFormField<int>(
                        value: _importance,
                        isExpanded: true,
                        decoration: _nestInput(
                          label: t.editGoalFieldImportanceLabel,
                          icon: Icons.local_fire_department_rounded,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              t.editGoalImportanceLow,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(
                              t.editGoalImportanceMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text(
                              t.editGoalImportanceHigh,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        selectedItemBuilder: (context) {
                          final labels = [
                            t.editGoalImportanceLow,
                            t.editGoalImportanceMedium,
                            t.editGoalImportanceHigh,
                          ];

                          return labels
                              .map(
                                (label) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList();
                        },
                        onChanged: (v) {
                          setState(() => _importance = v ?? _importance);
                        },
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          importanceField,
                        ],
                      );
                    },
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


class _EditTimeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;

  const _EditTimeTextField({
    required this.controller,
    required this.label,
    required this.onChanged,
    required this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: '09:00',
        prefixIcon: Icon(
          Icons.schedule_rounded,
          size: 18,
          color: scheme.primary,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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