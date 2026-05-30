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
  final DateTime? selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final String? userGoalId;

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

  const AddDayGoalSheet({
    super.key,
    required this.fixedLifeBlock,
    this.availableBlocks = const [],
    this.availableUserGoals = const [],
    this.initialUserGoalId,
    this.initialDate,
  });

  @override
  State<AddDayGoalSheet> createState() => _AddDayGoalSheetState();
}

class _AddDayGoalSheetState extends State<AddDayGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _supabase = Supabase.instance.client;
  final _startTimeCtrl = TextEditingController(text: '09:00');
  final _endTimeCtrl = TextEditingController(text: '10:00');

  int _importance = 2;
  late String _lifeBlock;
  String? _selectedUserGoalId;
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

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
        // Keep both finance/finances supported. The current LifeBlock enum uses
        // `finances`, while some older app parts may still use `finance`.
        return v == 'finance' ? 'finance' : 'finances';

      case 'family':
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
      case 'отношения':
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
        'family': 'Семья',
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
        'family': 'Family',
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
        'family': 'Familie',
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
        'family': 'Famille',
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
        'family': 'Familia',
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
        'family': 'Aile',
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
          .eq('is_completed', false)
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

      items.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

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

    final options = _lifeBlockOptions;
    final fixed = widget.fixedLifeBlock?.trim();

    if (fixed != null && fixed.isNotEmpty) {
      _lifeBlock = _normalizeBlock(fixed);
    } else {
      _lifeBlock = options.contains('general') ? 'general' : options.first;
    }

    _selectedUserGoalId = widget.initialUserGoalId;
    _selectedDate = DateUtils.dateOnly(widget.initialDate ?? DateTime.now());

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
                              child: Text(
                                l.addDayGoalNoLinkedGoal,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ..._userGoalsForSelectedBlock.map(
                              (g) => DropdownMenuItem<String?>(
                                value: g.id,
                                child: Text(
                                  '${g.title} · ${_horizonLabel(context, g.horizon)}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
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


class _TimeTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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