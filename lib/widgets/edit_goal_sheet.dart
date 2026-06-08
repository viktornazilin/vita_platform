// lib/widgets/edit_goal_sheet.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';
import 'package:nest_app/main.dart';
import 'package:nest_app/models/ladna_space.dart';
import 'package:nest_app/models/space_member.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nest_app/core/security/secure_crypto_service.dart';

import '../models/goal.dart';
import 'add_day_goal_sheet.dart';

import 'nest/nest_card.dart';
import 'nest/nest_pill.dart';
import 'nest/nest_section_title.dart';


bool _ladnaSpaceIsActive(LadnaSpace space) {
  final validUntil = space.validUntil;
  if (validUntil == null) return true;

  final today = DateUtils.dateOnly(DateTime.now());
  final until = DateUtils.dateOnly(validUntil);
  return !until.isBefore(today);
}

List<LadnaSpace> _ladnaActiveSpaces(Iterable<LadnaSpace> spaces) {
  return spaces.where(_ladnaSpaceIsActive).toList(growable: false);
}

class EditGoalResult {
  final String title;
  final String description;
  final String lifeBlock;
  final int importance;
  final String emotion;
  final double hours;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final DateTime selectedDate;
  final String? userGoalId;
  final String? spaceId;
  final String? assignedTo;

  const EditGoalResult({
    required this.title,
    required this.description,
    required this.lifeBlock,
    required this.importance,
    required this.emotion,
    required this.hours,
    required this.startTime,
    this.endTime,
    required this.selectedDate,
    this.userGoalId,
    this.spaceId,
    this.assignedTo,
  });
}


class EditGoalSheet extends StatefulWidget {
  final Goal goal;
  final String? fixedLifeBlock;
  final List<String> availableBlocks;

  /// Оставлено для совместимости, но больше не используется
  final List<UserGoalLinkOption> availableUserGoals;
  final String? initialUserGoalId;
  final List<LadnaSpace> availableSpaces;

  const EditGoalSheet({
    super.key,
    required this.goal,
    required this.fixedLifeBlock,
    required this.availableBlocks,
    this.availableUserGoals = const [],
    this.initialUserGoalId,
    this.availableSpaces = const [],
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
  final SecureCryptoService _crypto = SecureCryptoService();

  String _lifeBlock = 'general';
  late int _importance;
  late double _hours;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late DateTime _selectedDate;

  String? _selectedUserGoalId;

  bool _loadingUserGoals = false;
  List<UserGoalLinkOption> _userGoalsForSelectedBlock = const [];

  String? _selectedSpaceId;
  String? _selectedAssignedTo;
  List<LadnaSpace> _availableSpaces = const [];
  bool _loadingSpaceMembers = false;
  List<SpaceMember> _spaceMembers = const [];

  String _normalizeBlock(String value) {
    var v = value.trim().toLowerCase();

    // Support enum/stringified values such as LifeBlock.career or GoalLifeBlock.family.
    if (v.contains('.')) {
      final last = v.split('.').last.trim();
      if (last.isNotEmpty && last != v) {
        v = last;
      }
    }

    v = v
        .replaceAll('_', '-')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

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
      case 'business':
      case 'professional':
      case 'profession':
      case 'work-career':
      case 'карьера':
      case 'работа':
      case 'профессия':
      case 'бизнес':
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
      case 'родные':
      case 'близкие':
      case 'семья':
        return 'family';

      case 'relationships':
      case 'relationship':
      case 'relations':
      case 'relation':
      case 'love':
      case 'personal-life':
      case 'отношения':
      case 'личная жизнь':
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
    final seen = <String>{'general'};
    final out = <String>['general'];

    void addBlock(String raw) {
      final b = raw.trim();
      if (b.isEmpty) return;

      final normalized = _normalizeBlock(b);
      if (normalized.isEmpty || normalized == 'all') return;

      if (seen.add(normalized)) {
        out.add(normalized);
      }
    }

    // Primary source: blocks that the user actually selected/tracks.
    for (final raw in widget.availableBlocks) {
      addBlock(raw);
    }

    // Fallback: keep linked goal blocks visible even when the parent screen
    // passed an incomplete list.
    for (final goal in widget.availableUserGoals) {
      addBlock(goal.lifeBlock);
    }

    // Safety: never let the currently selected value disappear from the dropdown.
    addBlock(_lifeBlock);

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
          ru: 'Дом и быт',
          en: 'Household',
          de: 'Haushalt',
          fr: 'Foyer',
          es: 'Hogar',
          tr: 'Ev ve yaşam',
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

  Future<UserGoalLinkOption?> _mapUserGoalLinkOption(
    Map<String, dynamic> row,
  ) async {
    var title = (row['title'] ?? '').toString().trim();

    final encryptedPayload = row['encrypted_payload'];
    if (encryptedPayload is Map) {
      try {
        final decrypted = await _crypto.decryptJson(
          Map<String, dynamic>.from(encryptedPayload),
        );
        final decryptedTitle = decrypted['title'];
        if (decryptedTitle is String && decryptedTitle.trim().isNotEmpty) {
          title = decryptedTitle.trim();
        }
      } catch (_) {
        // Keep DB fallback below.
      }
    }

    // Do not show technical placeholders in the UI.
    if (title == '[encrypted]') {
      title = '';
    }

    final id = (row['id'] ?? '').toString();
    if (id.isEmpty || title.isEmpty) return null;

    return UserGoalLinkOption(
      id: id,
      title: title,
      lifeBlock: (row['life_block'] ?? '').toString(),
      horizon: (row['horizon'] ?? '').toString(),
    );
  }

  Future<List<UserGoalLinkOption>> _loadUserGoalsViaRepo(String normalizedBlock) async {
    final rawGoals = await dbRepo.getUserGoals(
      lifeBlock: null,
      includeCompleted: false,
    );

    final items = <UserGoalLinkOption>[];

    for (final dynamic g in rawGoals) {
      final id = (g.id ?? '').toString();
      final title = (g.title ?? '').toString().trim();
      final lifeBlock = (g.lifeBlock ?? '').toString();
      final isCompleted = g.isCompleted == true;

      if (id.isEmpty || title.isEmpty || title == '[encrypted]' || isCompleted) {
        continue;
      }

      if (_normalizeBlock(lifeBlock) != normalizedBlock) {
        continue;
      }

      String horizon = '';
      try {
        horizon = (g.horizon.dbValue ?? '').toString();
      } catch (_) {
        horizon = g.horizon.toString().split('.').last;
      }

      items.add(
        UserGoalLinkOption(
          id: id,
          title: title,
          lifeBlock: lifeBlock,
          horizon: horizon,
        ),
      );
    }

    return items;
  }

  Future<List<UserGoalLinkOption>> _loadUserGoalsViaSupabaseFallback(
    String normalizedBlock,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return const [];

    final raw = await _supabase
        .from('user_goals')
        .select('id, title, life_block, horizon, encrypted_payload, is_completed')
        .eq('user_id', userId)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    final items = <UserGoalLinkOption>[];

    for (final rawRow in raw as List<dynamic>) {
      final row = Map<String, dynamic>.from(rawRow as Map);
      if (row['is_completed'] == true) continue;
      if (_normalizeBlock((row['life_block'] ?? '').toString()) != normalizedBlock) {
        continue;
      }

      final option = await _mapUserGoalLinkOption(row);
      if (option != null) items.add(option);
    }

    return items;
  }

  Future<void> _loadUserGoalsForCurrentBlock() async {
    final normalizedBlock = _normalizeBlock(_lifeBlock);

    setState(() {
      _loadingUserGoals = true;
    });

    try {
      final byId = <String, UserGoalLinkOption>{};

      // 1) Use parent-provided goals first, if the parent has them.
      for (final option in widget.availableUserGoals) {
        final title = option.title.trim();
        if (_normalizeBlock(option.lifeBlock) == normalizedBlock &&
            option.id.isNotEmpty &&
            title.isNotEmpty &&
            title != '[encrypted]') {
          byId[option.id] = option;
        }
      }

      // 2) Main path: load through dbRepo. This is important because dbRepo already
      // knows how to decrypt user_goals correctly.
      try {
        final repoItems = await _loadUserGoalsViaRepo(normalizedBlock);
        for (final item in repoItems) {
          byId[item.id] = item;
        }
      } catch (e) {
        debugPrint('Add/Edit goal sheet: repo user_goals load failed: $e');
      }

      // 3) Fallback: direct Supabase load + local decrypt. This keeps the sheet
      // usable even if the repo provider is not available in this route.
      if (byId.isEmpty) {
        try {
          final fallbackItems = await _loadUserGoalsViaSupabaseFallback(normalizedBlock);
          for (final item in fallbackItems) {
            byId[item.id] = item;
          }
        } catch (e) {
          debugPrint('Add/Edit goal sheet: Supabase user_goals fallback failed: $e');
        }
      }

      final items = byId.values.toList()
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

      final selectedId = _selectedUserGoalId;
      final selectedStillVisible =
          selectedId == null || items.any((g) => g.id == selectedId);

      if (!mounted) return;

      setState(() {
        _userGoalsForSelectedBlock = items;
        if (!selectedStillVisible) {
          _selectedUserGoalId = null;
        }
        _loadingUserGoals = false;
      });
    } catch (e) {
      debugPrint('Add/Edit goal sheet: user_goals load failed: $e');
      if (!mounted) return;

      setState(() {
        _userGoalsForSelectedBlock = const [];
        _selectedUserGoalId = null;
        _loadingUserGoals = false;
      });
    }
  }


  String _taskLocationTitle(BuildContext context) => _localized(context, const {
        'ru': 'Где создать задачу',
        'en': 'Where to create the task',
        'de': 'Wo die Aufgabe erstellt wird',
        'fr': 'Où créer la tâche',
        'es': 'Dónde crear la tarea',
        'tr': 'Görev nerede oluşturulsun',
      });

  String _personalTaskLabel(BuildContext context) => _localized(context, const {
        'ru': 'Только мне',
        'en': 'Only me',
        'de': 'Nur für mich',
        'fr': 'Seulement moi',
        'es': 'Solo para mí',
        'tr': 'Sadece ben',
      });

  String _assigneeLabel(BuildContext context) => _localized(context, const {
        'ru': 'Исполнитель',
        'en': 'Assignee',
        'de': 'Verantwortlich',
        'fr': 'Responsable',
        'es': 'Responsable',
        'tr': 'Atanan kişi',
      });

  String _notAssignedLabel(BuildContext context) => _localized(context, const {
        'ru': 'Не назначать',
        'en': 'Not assigned',
        'de': 'Nicht zuweisen',
        'fr': 'Non assigné',
        'es': 'Sin asignar',
        'tr': 'Atanmadı',
      });

  String _spaceMemberLabel(SpaceMember member) {
    final name = member.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = member.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    final id = member.userId.trim();
    return id.length <= 8 ? id : '${id.substring(0, 8)}…';
  }

  Future<void> _loadAvailableSpaces() async {
    try {
      final spaces = _ladnaActiveSpaces(await dbRepo.listSpaces());
      if (!mounted) return;
      final selectedStillExists = _selectedSpaceId == null ||
          spaces.any((space) => space.id == _selectedSpaceId);
      setState(() {
        _availableSpaces = spaces;
        if (!selectedStillExists) {
          _selectedSpaceId = null;
          _selectedAssignedTo = null;
          _spaceMembers = const [];
        }
      });
      if (_selectedSpaceId != null) {
        await _loadSpaceMembersForSelectedSpace();
      }
    } catch (e) {
      debugPrint('Spaces load failed: $e');
    }
  }

  Future<void> _loadSpaceMembersForSelectedSpace() async {
    final spaceId = _selectedSpaceId;
    if (spaceId == null || spaceId.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _spaceMembers = const [];
        _selectedAssignedTo = null;
        _loadingSpaceMembers = false;
      });
      return;
    }

    setState(() => _loadingSpaceMembers = true);

    try {
      final members = await dbRepo.listSpaceMembers(spaceId);
      if (!mounted) return;
      final selectedStillValid = _selectedAssignedTo == null ||
          members.any((member) => member.userId == _selectedAssignedTo);
      setState(() {
        _spaceMembers = members;
        if (!selectedStillValid) _selectedAssignedTo = null;
        _loadingSpaceMembers = false;
      });
    } catch (e) {
      debugPrint('Space members load failed: $e');
      if (!mounted) return;
      setState(() {
        _spaceMembers = const [];
        _selectedAssignedTo = null;
        _loadingSpaceMembers = false;
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
    _availableSpaces = _ladnaActiveSpaces(widget.availableSpaces);
    _selectedSpaceId = _availableSpaces.any((s) => s.id == g.spaceId)
        ? g.spaceId
        : null;
    _selectedAssignedTo = g.assignedTo;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserGoalsForCurrentBlock();
      _loadAvailableSpaces();
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
      EditGoalResult(
        title: title,
        description: _descCtrl.text.trim(),
        lifeBlock: _normalizeBlock(_lifeBlock),
        importance: _importance,
        emotion: '',
        hours: _calculatedHours,
        startTime: _start,
        endTime: _end,
        selectedDate: DateUtils.dateOnly(_selectedDate),
        userGoalId: _selectedUserGoalId,
        spaceId: _selectedSpaceId,
        assignedTo: _selectedSpaceId == null ? null : _selectedAssignedTo,
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
                        isExpanded: true,
                        alignment: AlignmentDirectional.centerStart,
                        decoration: _nestInput(
                          label: t.userGoalLinkFieldLabel,
                          icon: Icons.link_rounded,
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                t.userGoalLinkNone,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          ..._userGoalsForSelectedBlock.map(
                            (g) => DropdownMenuItem<String?>(
                              value: g.id,
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  '${g.title} · ${_horizonLabel(context, g.horizon)}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                        selectedItemBuilder: (context) {
                          return [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                t.userGoalLinkNone,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            ..._userGoalsForSelectedBlock.map(
                              (g) => Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${g.title} · ${_horizonLabel(context, g.horizon)}',
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



class _EditTimeTextField extends StatefulWidget {
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
  State<_EditTimeTextField> createState() => __EditTimeTextFieldState();
}

class __EditTimeTextFieldState extends State<_EditTimeTextField> {
  bool _expanded = false;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final value = _currentValue();
    _hourController = FixedExtentScrollController(initialItem: value.hour);
    _minuteController = FixedExtentScrollController(initialItem: value.minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay _currentValue() {
    final raw = widget.controller.text.trim().replaceAll('.', ':');
    final parts = raw.split(':');

    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null &&
          minute != null &&
          hour >= 0 &&
          hour <= 23 &&
          minute >= 0 &&
          minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 3 || digits.length == 4) {
      final padded = digits.padLeft(4, '0');
      final hour = int.tryParse(padded.substring(0, 2));
      final minute = int.tryParse(padded.substring(2, 4));
      if (hour != null &&
          minute != null &&
          hour >= 0 &&
          hour <= 23 &&
          minute >= 0 &&
          minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    return const TimeOfDay(hour: 9, minute: 0);
  }

  String _format(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  void _setTime({int? hour, int? minute}) {
    final current = _currentValue();
    final nextHour = hour ?? current.hour;
    final nextMinute = minute ?? current.minute;
    final formatted = _format(nextHour, nextMinute);

    widget.controller.text = formatted;
    widget.onChanged(formatted);
    widget.onEditingComplete();
    setState(() {});
  }

  void _syncWheelToCurrentValue() {
    final value = _currentValue();
    if (_hourController.hasClients) {
      _hourController.jumpToItem(value.hour);
    }
    if (_minuteController.hasClients) {
      _minuteController.jumpToItem(value.minute);
    }
  }

  Widget _wheelColumn({
    required BuildContext context,
    required String title,
    required FixedExtentScrollController controller,
    required int itemCount,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: scheme.onSurface,
        );

    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 116,
            child: CupertinoPicker(
              scrollController: controller,
              itemExtent: 34,
              magnification: 1.08,
              squeeze: 1.08,
              useMagnifier: true,
              selectionOverlay: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: scheme.primary.withOpacity(0.18),
                  ),
                ),
              ),
              onSelectedItemChanged: onSelectedItemChanged,
              children: List.generate(
                itemCount,
                (i) => Center(
                  child: Text(
                    i.toString().padLeft(2, '0'),
                    style: textStyle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final value = _currentValue();
    final display = _format(value.hour, value.minute);

    final field = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() => _expanded = !_expanded);
          WidgetsBinding.instance.addPostFrameCallback((_) => _syncWheelToCurrentValue());
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: '09:00',
            prefixIcon: Icon(
              Icons.schedule_rounded,
              size: 18,
              color: scheme.primary,
            ),
            suffixIcon: AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                Icons.expand_more_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: isDark
                ? scheme.surfaceContainerHighest.withOpacity(0.36)
                : Colors.white.withOpacity(0.78),
            labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
            hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant.withOpacity(0.70),
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: scheme.outlineVariant.withOpacity(0.60),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: scheme.outlineVariant.withOpacity(0.55),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: scheme.primary, width: 1.4),
            ),
          ),
          child: Text(
            display,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
          ),
        ),
      ),
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          field,
          if (_expanded) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              decoration: BoxDecoration(
                color: isDark
                    ? scheme.surfaceContainerHighest.withOpacity(0.26)
                    : Colors.white.withOpacity(0.58),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: scheme.outlineVariant.withOpacity(0.45),
                ),
              ),
              child: Row(
                children: [
                  _wheelColumn(
                    context: context,
                    title: 'Часы',
                    controller: _hourController,
                    itemCount: 24,
                    onSelectedItemChanged: (i) => _setTime(hour: i),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: Text(
                      ':',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: scheme.onSurface,
                          ),
                    ),
                  ),
                  _wheelColumn(
                    context: context,
                    title: 'Минуты',
                    controller: _minuteController,
                    itemCount: 60,
                    onSelectedItemChanged: (i) => _setTime(minute: i),
                  ),
                ],
              ),
            ),
          ],
        ],
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