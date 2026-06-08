// lib/widgets/recurring_goal_sheet.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';
import 'package:nest_app/main.dart';
import 'package:nest_app/models/ladna_space.dart';
import 'package:nest_app/models/space_member.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final String? spaceId;
  final String? assignedTo;
  final String recurringGroupId;
  final bool isEditingExisting;

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
    this.spaceId,
    this.assignedTo,
    required this.recurringGroupId,
    this.isEditingExisting = false,
  });
}

class RecurringGoalSheet extends StatefulWidget {
  final List<String> availableBlocks;
  final List<LadnaSpace> availableSpaces;
  final String? initialSpaceId;

  const RecurringGoalSheet({
    super.key,
    this.availableBlocks = const [],
    this.availableSpaces = const [],
    this.initialSpaceId,
  });

  @override
  State<RecurringGoalSheet> createState() => _RecurringGoalSheetState();
}



String _rtPick(
  BuildContext context, {
  required String ru,
  required String en,
  String? de,
  String? fr,
  String? es,
  String? tr,
}) {
  final lang = Localizations.localeOf(context).languageCode.toLowerCase();
  switch (lang) {
    case 'de': return de ?? en;
    case 'fr': return fr ?? en;
    case 'es': return es ?? en;
    case 'tr': return tr ?? en;
    case 'ru': return ru;
    default: return en;
  }
}

class _RegularTaskTile extends StatelessWidget {
  final _ExistingRecurringTask task;
  final String lifeBlockLabel;
  final VoidCallback onTap;
  final bool isActive;

  const _RegularTaskTile({
    required this.task,
    required this.lifeBlockLabel,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final typeText = task.type == RecurrenceType.weekly
        ? _rtPick(context, ru: 'по дням недели', en: 'by weekdays', de: 'nach Wochentagen', fr: 'par jours de semaine', es: 'por días de semana', tr: 'hafta günlerine göre')
        : _rtPick(context, ru: 'каждые ${task.everyNDays} дн.', en: 'every ${task.everyNDays} days', de: 'alle ${task.everyNDays} Tage', fr: 'tous les ${task.everyNDays} jours', es: 'cada ${task.everyNDays} días', tr: 'her ${task.everyNDays} günde bir');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? scheme.primaryContainer.withOpacity(0.45) : scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isActive ? scheme.primary.withOpacity(0.55) : scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.repeat_rounded, color: isActive ? scheme.primary : scheme.onSurfaceVariant, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                    const SizedBox(height: 3),
                    Text('$lifeBlockLabel · $typeText · ${task.instances}×', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.edit_rounded, color: scheme.onSurfaceVariant, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExistingRecurringTask {
  final String groupId;
  final String title;
  final String lifeBlock;
  final int importance;
  final String emotion;
  final double plannedHours;
  final DateTime until;
  final TimeOfDay time;
  final RecurrenceType type;
  final int everyNDays;
  final Set<int> weekdays;
  final String? userGoalId;
  final int instances;

  const _ExistingRecurringTask({
    required this.groupId,
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
    required this.instances,
  });
}

class _RecurringGoalSheetState extends State<RecurringGoalSheet> {
  List<LadnaSpace> get _availableSpaces => _ladnaActiveSpaces(widget.availableSpaces);
  final _titleCtrl = TextEditingController();
  final _emotionCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '09:00');
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
  String? _selectedSpaceId;
  String? _selectedAssignedTo;
  bool _loadingSpaceMembers = false;
  List<SpaceMember> _spaceMembers = const [];
  String? _editingRecurringGroupId;

  bool _regularLoading = false;
  List<_ExistingRecurringTask> _regularTasks = const [];

  bool _loadingUserGoals = false;
  List<UserGoalLinkOption> _userGoalsForSelectedBlock = const [];


  String _taskLocationTitle(BuildContext context) => _rtPick(context, ru: 'Где создать задачу', en: 'Where to create the task', de: 'Wo die Aufgabe erstellt wird', fr: 'Où créer la tâche', es: 'Dónde crear la tarea', tr: 'Görev nerede oluşturulsun');
  String _personalTaskLabel(BuildContext context) => _rtPick(context, ru: 'Только мне', en: 'Only me', de: 'Nur für mich', fr: 'Seulement moi', es: 'Solo para mí', tr: 'Sadece ben');
  String _assigneeLabel(BuildContext context) => _rtPick(context, ru: 'Исполнитель', en: 'Assignee', de: 'Verantwortlich', fr: 'Responsable', es: 'Responsable', tr: 'Atanan kişi');
  String _notAssignedLabel(BuildContext context) => _rtPick(context, ru: 'Не назначать', en: 'Not assigned', de: 'Nicht zuweisen', fr: 'Non assigné', es: 'Sin asignar', tr: 'Atanmadı');

  String _spaceMemberLabel(SpaceMember member) {
    final name = member.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = member.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    final id = member.userId.trim();
    return id.length <= 8 ? id : '${id.substring(0, 8)}…';
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
      final selectedStillValid = _selectedAssignedTo == null || members.any((m) => m.userId == _selectedAssignedTo);
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
    _selectedSpaceId = _availableSpaces.any((s) => s.id == widget.initialSpaceId)
        ? widget.initialSpaceId
        : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRegularTasks();
      _loadUserGoalsForCurrentBlock();
      _loadSpaceMembersForSelectedSpace();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _emotionCtrl.dispose();
    _timeCtrl.dispose();
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
      case 'finances':
      case 'финансы':
      case 'money':
      case 'financial':
        return 'finances';

      case 'family':
      case 'семья':
      case 'родные':
      case 'близкие':
        return 'family';

      case 'relationships':
      case 'relationship':
      case 'relations':
      case 'отношения':
      case 'личная жизнь':
        return 'relationships';

      case 'hobbies':
      case 'hobby':
      case 'хобби':
        return 'hobbies';

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

  String _lifeBlockLabel(BuildContext context, String value) {
    switch (_normalizeBlock(value)) {
      case 'general':
        return _rtPick(context, ru: 'Общее', en: 'General', de: 'Allgemein', fr: 'Général', es: 'General', tr: 'Genel');
      case 'health':
        return _rtPick(context, ru: 'Здоровье', en: 'Health', de: 'Gesundheit', fr: 'Santé', es: 'Salud', tr: 'Sağlık');
      case 'career':
        return _rtPick(context, ru: 'Карьера', en: 'Career', de: 'Karriere', fr: 'Carrière', es: 'Carrera', tr: 'Kariyer');
      case 'finance':
      case 'finances':
        return _rtPick(context, ru: 'Финансы', en: 'Finance', de: 'Finanzen', fr: 'Finances', es: 'Finanzas', tr: 'Finans');
      case 'family':
        return _rtPick(context, ru: 'Дом и быт', en: 'Household', de: 'Haushalt', fr: 'Foyer', es: 'Hogar', tr: 'Ev ve yaşam');
      case 'relationships':
        return _rtPick(context, ru: 'Отношения', en: 'Relationships', de: 'Beziehungen', fr: 'Relations', es: 'Relaciones', tr: 'İlişkiler');
      case 'hobbies':
        return _rtPick(context, ru: 'Хобби', en: 'Hobbies', de: 'Hobbys', fr: 'Loisirs', es: 'Aficiones', tr: 'Hobiler');
      case 'self':
        return _rtPick(context, ru: 'Саморазвитие', en: 'Self-development', de: 'Selbstentwicklung', fr: 'Développement personnel', es: 'Desarrollo personal', tr: 'Kişisel gelişim');
      case 'education':
        return _rtPick(context, ru: 'Образование', en: 'Education', de: 'Bildung', fr: 'Éducation', es: 'Educación', tr: 'Eğitim');
      case 'travel':
        return _rtPick(context, ru: 'Путешествия', en: 'Travel', de: 'Reisen', fr: 'Voyages', es: 'Viajes', tr: 'Seyahat');
      case 'home':
        return _rtPick(context, ru: 'Дом', en: 'Home', de: 'Zuhause', fr: 'Maison', es: 'Hogar', tr: 'Ev');
      default:
        return value;
    }
  }

  String _horizonLabel(BuildContext context, String value) {
    final t = AppLocalizations.of(context)!;

    switch (value.trim().toLowerCase()) {
      case 'tactical':
        return t.recurringGoalHorizonTactical;
      case 'mid':
        return t.recurringGoalHorizonMid;
      case 'long':
        return t.recurringGoalHorizonLong;
      default:
        return value;
    }
  }


  String _newRecurringGroupId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'rec_$now';
  }

  List<String> get _lifeBlockOptions {
    final seen = <String>{};
    final out = <String>[];

    for (final raw in widget.availableBlocks) {
      final normalized = _normalizeBlock(raw);
      if (normalized.isEmpty || normalized == 'all') continue;
      if (seen.add(normalized)) out.add(normalized);
    }

    if (out.isEmpty) {
      out.addAll(const ['health', 'career', 'family', 'education', 'hobbies', 'relationships']);
    }

    if (!out.contains(_lifeBlock)) out.insert(0, _lifeBlock);
    return out;
  }

  TimeOfDay _timeFromDynamic(dynamic value) {
    if (value is DateTime) return TimeOfDay(hour: value.hour, minute: value.minute);
    final raw = (value ?? '').toString();
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
    if (match == null) return _time;
    final h = int.tryParse(match.group(1) ?? '') ?? 9;
    final m = int.tryParse(match.group(2) ?? '') ?? 0;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  DateTime _dateFromDynamic(dynamic value, DateTime fallback) {
    if (value is DateTime) return _dateOnly(value);
    final parsed = DateTime.tryParse((value ?? '').toString());
    return parsed == null ? _dateOnly(fallback) : _dateOnly(parsed);
  }

  Set<int> _weekdaysFromDynamic(dynamic value) {
    if (value is List) {
      final set = value.map((e) => int.tryParse(e.toString()) ?? 0).where((e) => e >= 1 && e <= 7).toSet();
      return set.isEmpty ? {_dateOnly(DateTime.now()).weekday} : set;
    }
    return {_dateOnly(DateTime.now()).weekday};
  }

  Future<void> _loadRegularTasks() async {
    setState(() => _regularLoading = true);

    try {
      final raw = await dbRepo.listRecurringTaskPlans();

      final tasks = raw.map((row) {
        final recurrenceType = (row['recurrence_type'] ?? '').toString();
        final groupId = (row['recurring_group_id'] ?? '').toString().trim();
        final title = (row['title'] ?? '').toString().trim();

        if (groupId.isEmpty || title.isEmpty) return null;

        return _ExistingRecurringTask(
          groupId: groupId,
          title: title,
          lifeBlock: _normalizeBlock((row['life_block'] ?? 'general').toString()),
          importance: int.tryParse((row['importance'] ?? 2).toString()) ?? 2,
          emotion: (row['emotion'] ?? '').toString(),
          plannedHours: double.tryParse((row['spent_hours'] ?? 1).toString()) ?? 1.0,
          until: _dateFromDynamic(row['recurrence_until'], DateTime.now().add(const Duration(days: 14))),
          time: _timeFromDynamic(row['start_time']),
          type: recurrenceType == 'weekly' ? RecurrenceType.weekly : RecurrenceType.everyNDays,
          everyNDays: int.tryParse((row['recurrence_every_n_days'] ?? 2).toString()) ?? 2,
          weekdays: _weekdaysFromDynamic(row['recurrence_weekdays']),
          userGoalId: (row['user_goal_id'] ?? '').toString().trim().isEmpty
              ? null
              : (row['user_goal_id'] ?? '').toString(),
          instances: int.tryParse((row['instances'] ?? 0).toString()) ?? 0,
        );
      }).whereType<_ExistingRecurringTask>().toList()
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

      if (!mounted) return;
      setState(() {
        _regularTasks = tasks;
        _regularLoading = false;
      });
    } catch (e) {
      debugPrint('Recurring task templates load failed: $e');
      if (!mounted) return;
      setState(() {
        _regularTasks = const [];
        _regularLoading = false;
      });
    }
  }

  Future<void> _loadExisting(_ExistingRecurringTask task) async {
    setState(() {
      _editingRecurringGroupId = task.groupId;
      _titleCtrl.text = task.title;
      _emotionCtrl.text = task.emotion;
      _lifeBlock = task.lifeBlock;
      _importance = task.importance.clamp(1, 3);
      _hours = task.plannedHours.clamp(0.25, 24.0);
      _until = task.until;
      _time = task.time;
      _timeCtrl.text = _formatTime(task.time);
      _type = task.type;
      _everyNDays = task.everyNDays.clamp(1, 14);
      _weekdays = {...task.weekdays};
      _selectedUserGoalId = task.userGoalId;
      _userGoalsForSelectedBlock = const [];
    });
    await _loadUserGoalsForCurrentBlock();
  }

  void _clearEditing() {
    setState(() {
      _editingRecurringGroupId = null;
      _titleCtrl.clear();
      _emotionCtrl.clear();
      _type = RecurrenceType.everyNDays;
      _everyNDays = 2;
      _weekdays = {DateTime.monday, DateTime.wednesday, DateTime.friday};
      _time = const TimeOfDay(hour: 9, minute: 0);
      _timeCtrl.text = '09:00';
      _until = _dateOnly(DateTime.now().add(const Duration(days: 14)));
      _lifeBlock = _lifeBlockOptions.first;
      _importance = 2;
      _hours = 1.0;
      _selectedUserGoalId = null;
      _userGoalsForSelectedBlock = const [];
    });
    _loadUserGoalsForCurrentBlock();
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

  void _onTimeChanged(String raw) {
    final parsed = _parseTimeInput(raw);
    if (parsed == null) return;
    setState(() => _time = parsed);
  }

  void _commitTimeInput() {
    final parsed = _parseTimeInput(_timeCtrl.text);
    if (parsed == null) {
      _timeCtrl.text = _formatTime(_time);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(_timeErrorText(context))),
      );
      return;
    }

    setState(() {
      _time = parsed;
      _timeCtrl.text = _formatTime(parsed);
    });
  }

  String _timeErrorText(BuildContext context) => _rtPick(
        context,
        ru: 'Введите время в формате 09:30 или 930',
        en: 'Enter time as 09:30 or 930',
        de: 'Zeit als 09:30 oder 930 eingeben',
        fr: 'Saisis l’heure comme 09:30 ou 930',
        es: 'Introduce la hora como 09:30 o 930',
        tr: 'Saati 09:30 veya 930 olarak gir',
      );

  String _fmtDate(DateTime d) =>
      MaterialLocalizations.of(context).formatMediumDate(d);

  String _fmtTime(TimeOfDay t) => _formatTime(t);

  String _weekdayLabel(BuildContext context, int weekday) {
    final t = AppLocalizations.of(context)!;

    switch (weekday) {
      case DateTime.monday:
        return t.recurringGoalWeekdayMon;
      case DateTime.tuesday:
        return t.recurringGoalWeekdayTue;
      case DateTime.wednesday:
        return t.recurringGoalWeekdayWed;
      case DateTime.thursday:
        return t.recurringGoalWeekdayThu;
      case DateTime.friday:
        return t.recurringGoalWeekdayFri;
      case DateTime.saturday:
        return t.recurringGoalWeekdaySat;
      case DateTime.sunday:
        return t.recurringGoalWeekdaySun;
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
        SnackBar(content: Text(t.recurringGoalSelectAtLeastOneWeekday)),
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
        spaceId: _selectedSpaceId,
        assignedTo: _selectedSpaceId == null ? null : _selectedAssignedTo,
        recurringGroupId: _editingRecurringGroupId ?? _newRecurringGroupId(),
        isEditingExisting: _editingRecurringGroupId != null,
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
                        _rtPick(context, ru: 'Регулярная задача', en: 'Recurring task', de: 'Regelmäßige Aufgabe', fr: 'Tâche régulière', es: 'Tarea recurrente', tr: 'Tekrarlanan görev'),
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
                  _rtPick(context, ru: 'Настрой регулярную задачу. Это не цель, а повторяющаяся задача в дневной раскладке.', en: 'Set up a recurring task. This is not a goal, but a repeated task in the daily layout.', de: 'Richte eine regelmäßige Aufgabe ein. Das ist kein Ziel, sondern eine wiederkehrende Aufgabe in der Tagesplanung.', fr: 'Configure une tâche régulière. Ce n’est pas un objectif, mais une tâche répétée dans la journée.', es: 'Configura una tarea recurrente. No es un objetivo, sino una tarea repetida en la planificación diaria.', tr: 'Tekrarlanan bir görev ayarla. Bu bir hedef değil, günlük plandaki tekrar eden bir görevdir.'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                NestSectionTitle(_rtPick(context, ru: 'Мои регулярные задачи', en: 'My recurring tasks', de: 'Meine regelmäßigen Aufgaben', fr: 'Mes tâches régulières', es: 'Mis tareas recurrentes', tr: 'Tekrarlanan görevlerim')),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: _regularLoading
                      ? const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()))
                      : _regularTasks.isEmpty
                          ? Text(
                              _rtPick(context, ru: 'Пока нет регулярных задач. Создай первую ниже.', en: 'No recurring tasks yet. Create the first one below.', de: 'Noch keine regelmäßigen Aufgaben. Erstelle unten die erste.', fr: 'Aucune tâche régulière pour le moment. Crée la première ci-dessous.', es: 'Aún no hay tareas recurrentes. Crea la primera abajo.', tr: 'Henüz tekrarlanan görev yok. İlkini aşağıda oluştur.'),
                              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                            )
                          : Column(
                              children: [
                                for (final task in _regularTasks) ...[
                                  _RegularTaskTile(
                                    task: task,
                                    lifeBlockLabel: _lifeBlockLabel(context, task.lifeBlock),
                                    onTap: () => _loadExisting(task),
                                    isActive: task.groupId == _editingRecurringGroupId,
                                  ),
                                  if (task != _regularTasks.last) const SizedBox(height: 8),
                                ],
                                if (_editingRecurringGroupId != null) ...[
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: _clearEditing,
                                      icon: const Icon(Icons.add_rounded),
                                      label: Text(_rtPick(context, ru: 'Создать новую регулярную задачу', en: 'Create a new recurring task', de: 'Neue regelmäßige Aufgabe erstellen', fr: 'Créer une nouvelle tâche régulière', es: 'Crear una nueva tarea recurrente', tr: 'Yeni tekrarlanan görev oluştur')),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                ),
                const SizedBox(height: 12),

                NestSectionTitle(_editingRecurringGroupId == null
                    ? _rtPick(context, ru: 'Добавить регулярную задачу', en: 'Add recurring task', de: 'Regelmäßige Aufgabe hinzufügen', fr: 'Ajouter une tâche régulière', es: 'Añadir tarea recurrente', tr: 'Tekrarlanan görev ekle')
                    : _rtPick(context, ru: 'Редактировать регулярную задачу', en: 'Edit recurring task', de: 'Regelmäßige Aufgabe bearbeiten', fr: 'Modifier la tâche régulière', es: 'Editar tarea recurrente', tr: 'Tekrarlanan görevi düzenle')),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: _input(
                          label: _rtPick(context, ru: 'Название задачи', en: 'Task title', de: 'Aufgabentitel', fr: 'Titre de la tâche', es: 'Título de la tarea', tr: 'Görev başlığı'),
                          hint: _rtPick(context, ru: 'Например: приготовление еды', en: 'For example: meal prep', de: 'Zum Beispiel: Essen vorbereiten', fr: 'Par exemple : préparer le repas', es: 'Por ejemplo: preparar comida', tr: 'Örneğin: yemek hazırlama'),
                          icon: Icons.flag_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emotionCtrl,
                        textInputAction: TextInputAction.done,
                        decoration: _input(
                          label: t.recurringGoalEmotionLabel,
                          hint: t.recurringGoalEmotionHint,
                          icon: Icons.emoji_emotions_outlined,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),
                NestSectionTitle(t.recurringGoalRegularitySection),
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
                            label: Text(t.recurringGoalEveryNDays),
                            selected: _type == RecurrenceType.everyNDays,
                            onSelected: (_) {
                              setState(() => _type = RecurrenceType.everyNDays);
                            },
                          ),
                          ChoiceChip(
                            label: Text(t.recurringGoalByWeekdays),
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
                                t.recurringGoalIntervalLabel,
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
  text: t.recurringGoalEveryNDaysShort(_everyNDays),
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
                                label: Text(_weekdayLabel(context, wd)),
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
                            child: _TimeTextField(
                              controller: _timeCtrl,
                              label: _rtPick(
                                context,
                                ru: 'Время',
                                en: 'Time',
                                de: 'Zeit',
                                fr: 'Heure',
                                es: 'Hora',
                                tr: 'Saat',
                              ),
                              onChanged: _onTimeChanged,
                              onEditingComplete: _commitTimeInput,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickUntil,
                              icon: const Icon(Icons.calendar_month_rounded),
                              label: Text(t.recurringGoalUntilButton(_fmtDate(_until))),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),
                NestSectionTitle(t.recurringGoalParametersSection),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final narrow = constraints.maxWidth < 430;

                          final lifeBlockField = DropdownButtonFormField<String>(
                            value: _lifeBlock,
                            isExpanded: true,
                            decoration: _input(
                              label: t.recurringGoalLifeBlockLabel,
                              icon: Icons.grid_view_rounded,
                            ),
                            items: _lifeBlockOptions
                                .map(
                                  (block) => DropdownMenuItem(
                                    value: block,
                                    child: Text(
                                      _lifeBlockLabel(context, block),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
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
                          );

                          final importanceField = DropdownButtonFormField<int>(
                            value: _importance,
                            isExpanded: true,
                            decoration: _input(
                              label: t.recurringGoalImportanceLabel,
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
                          );

                          if (narrow) {
                            return Column(
                              children: [
                                lifeBlockField,
                                const SizedBox(height: 12),
                                importanceField,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: lifeBlockField),
                              const SizedBox(width: 12),
                              Expanded(child: importanceField),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String?>(
                        value: dropdownGoalValue,
                        decoration: _input(
                          label: t.recurringGoalUserGoalLabel,
                          icon: Icons.link_rounded,
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(t.recurringGoalNoLink),
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
                                t.recurringGoalLoadingUserGoals(_lifeBlockLabel(context, _lifeBlock)),
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
                          t.recurringGoalNoUserGoalsForBlock(_lifeBlockLabel(context, _lifeBlock)),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],

                      if (_availableSpaces.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        NestSectionTitle(_taskLocationTitle(context)),
                        const SizedBox(height: 8),
                        NestCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              DropdownButtonFormField<String?>(
                                value: _selectedSpaceId,
                                isExpanded: true,
                                decoration: _input(
                                  label: _taskLocationTitle(context),
                                  icon: Icons.groups_2_rounded,
                                ),
                                items: [
                                  DropdownMenuItem<String?>(value: null, child: Text(_personalTaskLabel(context), overflow: TextOverflow.ellipsis)),
                                  ..._availableSpaces.map((space) => DropdownMenuItem<String?>(value: space.id, child: Text('${space.icon} ${space.name}', overflow: TextOverflow.ellipsis))),
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
                                  value: _spaceMembers.any((m) => m.userId == _selectedAssignedTo) ? _selectedAssignedTo : null,
                                  isExpanded: true,
                                  decoration: _input(
                                    label: _assigneeLabel(context),
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  items: [
                                    DropdownMenuItem<String?>(value: null, child: Text(_notAssignedLabel(context), overflow: TextOverflow.ellipsis)),
                                    ..._spaceMembers.map((m) => DropdownMenuItem<String?>(value: m.userId, child: Text(_spaceMemberLabel(m), overflow: TextOverflow.ellipsis))),
                                  ],
                                  onChanged: _loadingSpaceMembers ? null : (value) => setState(() => _selectedAssignedTo = value),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.recurringGoalPlannedHoursLabel,
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
                                t.recurringGoalOccurrencesCount(occurrences.length),
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
                        child: Text(
                          _editingRecurringGroupId == null
                              ? _rtPick(context, ru: 'Создать задачу', en: 'Create task', de: 'Aufgabe erstellen', fr: 'Créer la tâche', es: 'Crear tarea', tr: 'Görev oluştur')
                              : _rtPick(context, ru: 'Сохранить изменения', en: 'Save changes', de: 'Änderungen speichern', fr: 'Enregistrer', es: 'Guardar cambios', tr: 'Değişiklikleri kaydet'),
                        ),
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

  String _wheelLabel(BuildContext context, {required bool hours}) {
    if (hours) {
      return _rtPick(
        context,
        ru: 'Часы',
        en: 'Hours',
        de: 'Stunden',
        fr: 'Heures',
        es: 'Horas',
        tr: 'Saat',
      );
    }

    return _rtPick(
      context,
      ru: 'Минуты',
      en: 'Minutes',
      de: 'Minuten',
      fr: 'Minutes',
      es: 'Minutos',
      tr: 'Dakika',
    );
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
                    title: _wheelLabel(context, hours: true),
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
                    title: _wheelLabel(context, hours: false),
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
