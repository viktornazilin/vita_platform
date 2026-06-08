// lib/widgets/goals/add_day_goal_sheet.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';
import 'package:nest_app/main.dart';
import 'package:nest_app/models/ladna_space.dart';
import 'package:nest_app/models/space_member.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nest_app/core/security/secure_crypto_service.dart';


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
  final DateTime? selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final String? userGoalId;
  final String? spaceId;
  final String? assignedTo;

  const AddGoalResult({
    required this.title,
    required this.description,
    required this.lifeBlock,
    required this.importance,
    required this.emotion,
    required this.hours,
    this.selectedDate,
    required this.startTime,
    this.endTime,
    this.userGoalId,
    this.spaceId,
    this.assignedTo,
  });
}

class AddDayGoalSheet extends StatefulWidget {
  final String? fixedLifeBlock;
  final List<String> availableBlocks;

  /// Используется как fallback, чтобы показать уже связанную цель,
  /// даже если она не попала в запрос по текущему life_block.
  final List<UserGoalLinkOption> availableUserGoals;

  final String? initialUserGoalId;
  final DateTime? initialDate;
  final List<LadnaSpace> availableSpaces;
  final String? initialSpaceId;
  final String? initialAssignedTo;

  const AddDayGoalSheet({
    super.key,
    required this.fixedLifeBlock,
    this.availableBlocks = const [],
    this.availableUserGoals = const [],
    this.initialUserGoalId,
    this.initialDate,
    this.availableSpaces = const [],
    this.initialSpaceId,
    this.initialAssignedTo,
  });

  @override
  State<AddDayGoalSheet> createState() => _AddDayGoalSheetState();
}

class _AddDayGoalSheetState extends State<AddDayGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _supabase = Supabase.instance.client;
  final SecureCryptoService _crypto = SecureCryptoService();
  final _startTimeCtrl = TextEditingController(text: '09:00');
  final _endTimeCtrl = TextEditingController(text: '10:00');

  int _importance = 2;
  String _lifeBlock = 'general';
  String? _selectedUserGoalId;
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

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
        // Keep both finance/finances supported. The current LifeBlock enum uses
        // `finances`, while some older app parts may still use `finance`.
        return v == 'finance' ? 'finance' : 'finances';

      case 'family':
      case 'родные':
      case 'близкие':
      case 'семья':
        return 'family';

      case 'hobbies':
      case 'hobby':
      case 'хобби':
        return 'hobbies';

      case 'spirituality':
      case 'духовность':
        return 'spirituality';

      case 'relationships':
      case 'relationship':
      case 'relations':
      case 'relation':
      case 'love':
      case 'personal-life':
      case 'отношения':
      case 'личная жизнь':
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
    final out = <String>[];

    void addBlock(String raw) {
      final b = raw.trim();
      if (b.isEmpty) return;

      final normalized = _normalizeBlock(b);
      if (normalized.isEmpty || normalized == 'all') return;

      if (seen.add(normalized)) {
        out.add(normalized);
      }
    }

    // Primary source only: LifeBlocks selected by the user in the profile.
    for (final raw in widget.availableBlocks) {
      addBlock(raw);
    }

    // Fixed block is allowed because the parent screen explicitly restricts the
    // sheet to this LifeBlock. Otherwise do not expand the dropdown from goals.
    final fixed = widget.fixedLifeBlock?.trim();
    if (fixed != null && fixed.isNotEmpty) {
      addBlock(fixed);
    }

    // Technical fallback only when the parent passed no selected blocks at all.
    return out.isEmpty ? <String>['general'] : out;
  }

  String _lifeBlockLabel(BuildContext context, String value) {
    final key = _normalizeBlock(value);
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();

    const labels = <String, Map<String, String>>{
      'ru': {
        'general': 'Общее',
        'health': 'Здоровье',
        'career': 'Карьера',
        'finance': 'Финансы',
        'finances': 'Финансы',
        'family': 'Дом и быт',
        'education': 'Образование',
        'hobbies': 'Хобби',
        'spirituality': 'Духовность',
        'relationships': 'Отношения',
        'self': 'Саморазвитие',
        'travel': 'Путешествия',
        'home': 'Дом',
      },
      'en': {
        'general': 'General',
        'health': 'Health',
        'career': 'Career',
        'finance': 'Finance',
        'finances': 'Finance',
        'family': 'Household',
        'education': 'Education',
        'hobbies': 'Hobbies',
        'spirituality': 'Spirituality',
        'relationships': 'Relationships',
        'self': 'Self-development',
        'travel': 'Travel',
        'home': 'Home',
      },
      'de': {
        'general': 'Allgemein',
        'health': 'Gesundheit',
        'career': 'Karriere',
        'finance': 'Finanzen',
        'finances': 'Finanzen',
        'family': 'Haushalt',
        'education': 'Bildung',
        'hobbies': 'Hobbys',
        'spirituality': 'Spiritualität',
        'relationships': 'Beziehungen',
        'self': 'Selbstentwicklung',
        'travel': 'Reisen',
        'home': 'Zuhause',
      },
      'fr': {
        'general': 'Général',
        'health': 'Santé',
        'career': 'Carrière',
        'finance': 'Finances',
        'finances': 'Finances',
        'family': 'Foyer',
        'education': 'Éducation',
        'hobbies': 'Loisirs',
        'spirituality': 'Spiritualité',
        'relationships': 'Relations',
        'self': 'Développement personnel',
        'travel': 'Voyages',
        'home': 'Maison',
      },
      'es': {
        'general': 'General',
        'health': 'Salud',
        'career': 'Carrera',
        'finance': 'Finanzas',
        'finances': 'Finanzas',
        'family': 'Hogar',
        'education': 'Educación',
        'hobbies': 'Aficiones',
        'spirituality': 'Espiritualidad',
        'relationships': 'Relaciones',
        'self': 'Desarrollo personal',
        'travel': 'Viajes',
        'home': 'Hogar',
      },
      'tr': {
        'general': 'Genel',
        'health': 'Sağlık',
        'career': 'Kariyer',
        'finance': 'Finans',
        'finances': 'Finans',
        'family': 'Ev ve yaşam',
        'education': 'Eğitim',
        'hobbies': 'Hobiler',
        'spirituality': 'Maneviyat',
        'relationships': 'İlişkiler',
        'self': 'Kişisel gelişim',
        'travel': 'Seyahat',
        'home': 'Ev',
      },
    };

    return labels[lang]?[key] ?? labels['en']?[key] ?? value;
  }

  String _horizonLabel(BuildContext context, String value) {
    final l = AppLocalizations.of(context)!;

    switch (value.trim().toLowerCase()) {
      case 'tactical':
        return l.addDayGoalHorizonTactical;
      case 'mid':
        return l.addDayGoalHorizonMid;
      case 'long':
        return l.addDayGoalHorizonLong;
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

    final options = _lifeBlockOptions;
    final fixed = widget.fixedLifeBlock?.trim();

    if (fixed != null && fixed.isNotEmpty) {
      _lifeBlock = _normalizeBlock(fixed);
    } else {
      _lifeBlock = options.first;
    }

    _selectedUserGoalId = widget.initialUserGoalId;
    _selectedDate = DateUtils.dateOnly(widget.initialDate ?? DateTime.now());
    _availableSpaces = _ladnaActiveSpaces(widget.availableSpaces);
    _selectedSpaceId = _availableSpaces.any((s) => s.id == widget.initialSpaceId)
        ? widget.initialSpaceId
        : null;
    _selectedAssignedTo = widget.initialAssignedTo;

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

  String _sheetTitle(BuildContext context) => _localized(context, const {
        'ru': 'Добавить задачу',
        'en': 'Add task',
        'de': 'Aufgabe hinzufügen',
        'fr': 'Ajouter une tâche',
        'es': 'Añadir tarea',
        'tr': 'Görev ekle',
      });

  String _titleHint(BuildContext context) => _localized(context, const {
        'ru': 'Тренировка / Работа',
        'en': 'Workout / Work',
        'de': 'Training / Arbeit',
        'fr': 'Sport / Travail',
        'es': 'Entreno / Trabajo',
        'tr': 'Antrenman / İş',
      });

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

  String _dateLabel(BuildContext context) => _localized(context, const {
        'ru': 'Дата',
        'en': 'Date',
        'de': 'Datum',
        'fr': 'Date',
        'es': 'Fecha',
        'tr': 'Tarih',
      });

  String _chooseDateLabel(BuildContext context) => _localized(context, const {
        'ru': 'Выбрать',
        'en': 'Choose',
        'de': 'Wählen',
        'fr': 'Choisir',
        'es': 'Elegir',
        'tr': 'Seç',
      });

  String _formatDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d.$m.${value.year}';
  }

  Future<void> _pickDate() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 2, 1, 1),
      lastDate: DateTime(now.year + 5, 12, 31),
    );

    if (picked != null) {
      setState(() => _selectedDate = DateUtils.dateOnly(picked));
    }
  }

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
    var diff = _minutesOf(_endTime) - _minutesOf(_startTime);
    if (diff <= 0) diff += 24 * 60;
    return (diff / 60).clamp(0.25, 24.0);
  }

  void _onStartTimeChanged(String raw) {
    final parsed = _parseTimeInput(raw);
    if (parsed == null) return;
    setState(() => _startTime = parsed);
  }

  void _onEndTimeChanged(String raw) {
    final parsed = _parseTimeInput(raw);
    if (parsed == null) return;
    setState(() => _endTime = parsed);
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
        emotion: '',
        hours: _calculatedHours,
        selectedDate: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        userGoalId: _selectedUserGoalId,
        spaceId: _selectedSpaceId,
        assignedTo: _selectedSpaceId == null ? null : _selectedAssignedTo,
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
                          _sheetTitle(context),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: scheme.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${_dateLabel(context)}:',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatDate(_selectedDate),
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: scheme.onSurface,
                                ),
                          ),
                        ),
                        _PillButton(
                          text: _chooseDateLabel(context),
                          onTap: _pickDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    child: Column(
                      children: [
                        _PrettyField(
                          controller: _titleCtrl,
                          label: l.addDayGoalFieldTitle,
                          hint: _titleHint(context),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, color: scheme.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l.addDayGoalStartTime,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: scheme.onSurface,
                                    ),
                              ),
                            ),
                            Text(
                              _durationLabel(context, _calculatedHours),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _TimeTextField(
                                controller: _startTimeCtrl,
                                label: l.addDayGoalStartTime,
                                onChanged: _onStartTimeChanged,
                                onEditingComplete: () {
                                  final parsed = _parseTimeInput(_startTimeCtrl.text);
                                  if (parsed == null) {
                                    _startTimeCtrl.text = _formatTime(_startTime);
                                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                                      SnackBar(content: Text(_timeErrorText(context))),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    _startTime = parsed;
                                    _startTimeCtrl.text = _formatTime(parsed);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TimeTextField(
                                controller: _endTimeCtrl,
                                label: _endTimeLabel(context),
                                onChanged: _onEndTimeChanged,
                                onEditingComplete: () {
                                  final parsed = _parseTimeInput(_endTimeCtrl.text);
                                  if (parsed == null) {
                                    _endTimeCtrl.text = _formatTime(_endTime);
                                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                                      SnackBar(content: Text(_timeErrorText(context))),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    _endTime = parsed;
                                    _endTimeCtrl.text = _formatTime(parsed);
                                  });
                                },
                              ),
                            ),
                          ],
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
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
                                        _lifeBlockLabel(context, b),
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
                  if (_availableSpaces.isNotEmpty) ...[
                    _Section(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.groups_2_rounded, color: scheme.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _taskLocationTitle(context),
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: scheme.onSurface,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String?>(
                            value: _selectedSpaceId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark
                                  ? scheme.surfaceContainerHighest.withOpacity(0.36)
                                  : Colors.white.withOpacity(0.78),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.60)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.55)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: scheme.primary, width: 1.4),
                              ),
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(_personalTaskLabel(context), overflow: TextOverflow.ellipsis),
                              ),
                              ..._availableSpaces.map(
                                (space) => DropdownMenuItem<String?>(
                                  value: space.id,
                                  child: Text('${space.icon} ${space.name}', overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ],
                            onChanged: (value) async {
                              setState(() {
                                _selectedSpaceId = value;
                                _selectedAssignedTo = null;
                                _spaceMembers = const [];
                              });
                              await _loadSpaceMembersForSelectedSpace();
                            },
                          ),
                          if (_selectedSpaceId != null) ...[
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String?>(
                              value: _spaceMembers.any((m) => m.userId == _selectedAssignedTo)
                                  ? _selectedAssignedTo
                                  : null,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: _assigneeLabel(context),
                                filled: true,
                                fillColor: isDark
                                    ? scheme.surfaceContainerHighest.withOpacity(0.36)
                                    : Colors.white.withOpacity(0.78),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.60)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.55)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: scheme.primary, width: 1.4),
                                ),
                              ),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(_notAssignedLabel(context), overflow: TextOverflow.ellipsis),
                                ),
                                ..._spaceMembers.map(
                                  (member) => DropdownMenuItem<String?>(
                                    value: member.userId,
                                    child: Text(_spaceMemberLabel(member), overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                              onChanged: _loadingSpaceMembers
                                  ? null
                                  : (value) => setState(() => _selectedAssignedTo = value),
                            ),
                          ],
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
                                l.addDayGoalLinkSectionTitle,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
                          alignment: AlignmentDirectional.centerStart,
                          decoration: InputDecoration(
                            labelText: l.addDayGoalUserGoalLabel,
                            filled: true,
                            fillColor: isDark
                                ? scheme.surfaceContainerHighest.withOpacity(0.36)
                                : Colors.white.withOpacity(0.78),
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
                              borderSide: BorderSide(
                                color: scheme.primary,
                                width: 1.4,
                              ),
                            ),
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  l.addDayGoalNoLinkedGoal,
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
                                  l.addDayGoalNoLinkedGoal,
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
                                  l.addDayGoalLoadingUserGoals(_lifeBlockLabel(context, _lifeBlock)),
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
                            l.addDayGoalNoUserGoalsForBlock(_lifeBlockLabel(context, _lifeBlock)),
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
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
      padding: const EdgeInsets.all(12),
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
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
        hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant.withOpacity(0.70),
            ),
        filled: true,
        fillColor: isDark
            ? scheme.surfaceContainerHighest.withOpacity(0.36)
            : Colors.white.withOpacity(0.78),
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
    );
  }
}



class _TimeTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;

  const _TimeTextField({
    required this.controller,
    required this.label,
    required this.onChanged,
    required this.onEditingComplete,
  });

  @override
  State<_TimeTextField> createState() => __TimeTextFieldState();
}

class __TimeTextFieldState extends State<_TimeTextField> {
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