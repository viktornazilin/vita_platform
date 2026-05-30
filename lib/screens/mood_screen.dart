import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../main.dart'; // dbRepo
import '../models/mood.dart';
import '../models/mood_model.dart';
import '../models/home_model.dart';
import '../widgets/nest/nest_background.dart';
import '../widgets/home/health_tracker_card.dart';
import '../widgets/home/hobby_tracker_card.dart';
import '../widgets/mood/mental_week_card.dart';


bool get _ladnaDarkMode =>
    WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

Color _ladnaAdaptive(Color light, Color dark) => _ladnaDarkMode ? dark : light;


int _ladnaMoodScore(String emoji) {
  if (emoji.contains('😄') || emoji.contains('😁') || emoji.contains('😍')) return 5;
  if (emoji.contains('🙂') || emoji.contains('😊') || emoji.contains('😌')) return 4;
  if (emoji.contains('😐') || emoji.contains('😶')) return 3;
  if (emoji.contains('🙁') || emoji.contains('😕')) return 2;
  if (emoji.contains('😞') || emoji.contains('😢') || emoji.contains('😡')) return 1;
  return 3;
}

String _ladnaMoodLabel(BuildContext context, int score) {
  final code = Localizations.localeOf(context).languageCode.toLowerCase();
  final values = switch (score) {
    1 => const {
        'ru': 'Очень тяжело',
        'en': 'Very low',
        'de': 'Sehr niedrig',
        'fr': 'Très bas',
        'es': 'Muy bajo',
        'tr': 'Çok düşük',
      },
    2 => const {
        'ru': 'Сложно',
        'en': 'Low',
        'de': 'Niedrig',
        'fr': 'Bas',
        'es': 'Bajo',
        'tr': 'Düşük',
      },
    3 => const {
        'ru': 'Нейтрально',
        'en': 'Neutral',
        'de': 'Neutral',
        'fr': 'Neutre',
        'es': 'Neutral',
        'tr': 'Nötr',
      },
    4 => const {
        'ru': 'Хорошо',
        'en': 'Good',
        'de': 'Gut',
        'fr': 'Bien',
        'es': 'Bien',
        'tr': 'İyi',
      },
    _ => const {
        'ru': 'Отлично',
        'en': 'Great',
        'de': 'Sehr gut',
        'fr': 'Très bien',
        'es': 'Muy bien',
        'tr': 'Harika',
      },
  };
  return values[code] ?? values['en']!;
}

String _ladnaMoodScaleHint(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode.toLowerCase();
  const values = {
    'ru': 'Шкала настроения: 1 — очень тяжело, 3 — нейтрально, 5 — отлично.',
    'en': 'Mood scale: 1 means very low, 3 neutral, 5 great.',
    'de': 'Stimmungsskala: 1 sehr niedrig, 3 neutral, 5 sehr gut.',
    'fr': 'Échelle d’humeur : 1 très bas, 3 neutre, 5 très bien.',
    'es': 'Escala de ánimo: 1 muy bajo, 3 neutral, 5 muy bien.',
    'tr': 'Ruh hali ölçeği: 1 çok düşük, 3 nötr, 5 harika.',
  };
  return values[code] ?? values['en']!;
}

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MoodModel(repo: dbRepo)..load(),
      child: const _PersonalView(),
    );
  }
}

class _PersonalView extends StatefulWidget {
  const _PersonalView();

  @override
  State<_PersonalView> createState() => _PersonalViewState();
}

class _PersonalViewState extends State<_PersonalView> {
  int _tab = 1;
  String _selectedEmoji = '😊';
  final _noteController = TextEditingController();
  bool _saving = false;

  static const _maxLen = 200;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _t(
    BuildContext context, {
    required String ru,
    required String en,
    String? de,
    String? fr,
    String? es,
    String? tr,
  }) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    switch (code) {
      case 'de':
        return de ?? en;
      case 'fr':
        return fr ?? en;
      case 'es':
        return es ?? en;
      case 'tr':
        return tr ?? en;
      case 'ru':
        return ru;
      default:
        return en;
    }
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _dateLabel(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  DateTime _startOfWeek(DateTime date) {
    final d = _dateOnly(date);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  List<DateTime> _currentWeekDays() {
    final start = _startOfWeek(DateTime.now());
    return List.generate(7, (index) => _dateOnly(start.add(Duration(days: index))));
  }

  String _weekdayLabel(BuildContext context, DateTime date) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    final labels = switch (code) {
      'ru' => ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
      'de' => ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
      'fr' => ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'],
      'es' => ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'],
      'tr' => ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pa'],
      _ => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    };
    return labels[date.weekday - 1];
  }

  String _scoreForEmoji(String emoji) => _ladnaMoodScore(emoji).toString();

  void _goBack() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
      return;
    }

    // When the screen is opened as a tab inside HomeScreen, there is no route to pop.
    // In that case we return to the main dashboard tab.
    try {
      context.read<HomeModel>().select(0);
    } catch (_) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _refresh() async {
    await context.read<MoodModel>().load();
  }

  Future<void> _saveMood() async {
    if (_saving) return;
    final l = AppLocalizations.of(context)!;

    setState(() => _saving = true);
    try {
      await context.read<MoodModel>().repo.upsertMood(
            date: _dateOnly(DateTime.now()),
            emoji: _selectedEmoji,
            note: _noteController.text.trim(),
          );
      await context.read<MoodModel>().load();
      if (!mounted) return;
      _noteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.moodSaved),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.moodErrSaveFailed('$e')),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: NestBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _LadnaHeader(
                  title: _t(
                    context,
                    ru: 'Личное',
                    en: 'Personal',
                    de: 'Persönlich',
                    fr: 'Personnel',
                    es: 'Personal',
                    tr: 'Kişisel',
                  ),
                  onBack: _goBack,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _LadnaTabs(
                  selectedIndex: _tab,
                  labels: [
                    _t(
                      context,
                      ru: 'Здоровье',
                      en: 'Health',
                      de: 'Gesundheit',
                      fr: 'Santé',
                      es: 'Salud',
                      tr: 'Sağlık',
                    ),
                    _t(
                      context,
                      ru: 'Настроение',
                      en: 'Mood',
                      de: 'Stimmung',
                      fr: 'Humeur',
                      es: 'Ánimo',
                      tr: 'Ruh hali',
                    ),
                    _t(
                      context,
                      ru: 'Хобби',
                      en: 'Hobbies',
                      de: 'Hobbys',
                      fr: 'Loisirs',
                      es: 'Hobbies',
                      tr: 'Hobiler',
                    ),
                  ],
                  onChanged: (index) => setState(() => _tab = index),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: IndexedStack(
                  index: _tab,
                  children: [
                    _TabScroller(
                      onRefresh: _refresh,
                      child: const HealthTrackerCard(),
                    ),
                    _TabScroller(
                      onRefresh: _refresh,
                      child: _MoodTab(
                        selectedEmoji: _selectedEmoji,
                        noteController: _noteController,
                        maxLen: _maxLen,
                        saving: _saving,
                        score: _scoreForEmoji(_selectedEmoji),
                        dateLabel: _dateLabel(context, DateTime.now()),
                        weekDays: _currentWeekDays(),
                        weekdayLabel: (day) => _weekdayLabel(context, day),
                        onEmojiChanged: (emoji) =>
                            setState(() => _selectedEmoji = emoji),
                        onSave: _saveMood,
                      ),
                    ),
                    _TabScroller(
                      onRefresh: _refresh,
                      child: const HobbyTrackerCard(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabScroller extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const _TabScroller({
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
        children: [child],
      ),
    );
  }
}

class _MoodTab extends StatelessWidget {
  final String selectedEmoji;
  final TextEditingController noteController;
  final int maxLen;
  final bool saving;
  final String score;
  final String dateLabel;
  final List<DateTime> weekDays;
  final String Function(DateTime day) weekdayLabel;
  final ValueChanged<String> onEmojiChanged;
  final VoidCallback onSave;

  const _MoodTab({
    required this.selectedEmoji,
    required this.noteController,
    required this.maxLen,
    required this.saving,
    required this.score,
    required this.dateLabel,
    required this.weekDays,
    required this.weekdayLabel,
    required this.onEmojiChanged,
    required this.onSave,
  });

  String _t(
    BuildContext context, {
    required String ru,
    required String en,
    String? de,
    String? fr,
    String? es,
    String? tr,
  }) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    switch (code) {
      case 'de':
        return de ?? en;
      case 'fr':
        return fr ?? en;
      case 'es':
        return es ?? en;
      case 'tr':
        return tr ?? en;
      case 'ru':
        return ru;
      default:
        return en;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<MoodModel>();
    final moods = model.moods;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LadnaCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(
                title: _t(
                  context,
                  ru: 'Как ты сегодня?',
                  en: 'How are you today?',
                  de: 'Wie geht es dir heute?',
                  fr: 'Comment ça va aujourd’hui ?',
                  es: '¿Cómo estás hoy?',
                  tr: 'Bugün nasılsın?',
                ),
                trailing: dateLabel,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['😞', '🙁', '😐', '🙂', '😄']
                    .map(
                      (emoji) => _MoodBubble(
                        emoji: emoji,
                        selected: emoji == selectedEmoji,
                        onTap: () => onEmojiChanged(emoji),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: _ladnaAdaptive(const Color(0xFFEAE6F5), const Color(0xFF1C1630)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$score / 5 · ${_ladnaMoodLabel(context, int.tryParse(score) ?? 3)}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: _ladnaAdaptive(const Color(0xFF6B54C0), const Color(0xFFE9DDFF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _ladnaMoodScaleHint(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x99FFFFFF)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                minLines: 2,
                maxLines: 3,
                maxLength: maxLen,
                decoration: InputDecoration(
                  hintText: _t(
                    context,
                    ru: 'Что повлияло на настроение?',
                    en: 'What affected your mood?',
                    de: 'Was hat deine Stimmung beeinflusst?',
                    fr: 'Qu’est-ce qui a influencé ton humeur ?',
                    es: '¿Qué influyó en tu ánimo?',
                    tr: 'Ruh halini ne etkiledi?',
                  ),
                  counterText: '',
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(saving ? l.commonSaving : l.commonSave),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        MentalWeekCard(
          days: weekDays,
          weekdayLabel: weekdayLabel,
          maxItems: 3,
          debug: false,
        ),
        const SizedBox(height: 14),
        _SectionLabel(
          text: _t(
            context,
            ru: 'Последние записи',
            en: 'Recent entries',
            de: 'Letzte Einträge',
            fr: 'Entrées récentes',
            es: 'Entradas recientes',
            tr: 'Son kayıtlar',
          ),
        ),
        const SizedBox(height: 8),
        if (model.loading)
          const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else if (moods.isEmpty)
          _LadnaCard(
            padding: const EdgeInsets.all(14),
            child: Text(
              _t(
                context,
                ru: 'Пока нет записей. Отметь настроение сегодня.',
                en: 'No entries yet. Save today’s mood.',
                de: 'Noch keine Einträge. Speichere deine Stimmung heute.',
                fr: 'Aucune entrée pour le moment.',
                es: 'Todavía no hay entradas.',
                tr: 'Henüz kayıt yok.',
              ),
              style: TextStyle(
                color: _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x99FFFFFF)),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          _LadnaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final mood in moods.take(5)) ...[
                  _MoodHistoryRow(mood: mood),
                  if (mood != moods.take(5).last)
                    Divider(height: 1, color: _ladnaAdaptive(const Color(0xFFE0DCF0), const Color(0x2E6B54C0))),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _MoodHistoryRow extends StatelessWidget {
  final Mood mood;

  const _MoodHistoryRow({required this.mood});

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context).formatMediumDate(mood.date);
    final note = mood.note.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Text(mood.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x99FFFFFF)),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note.isEmpty ? '—' : note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF)),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: _ladnaAdaptive(const Color(0xFFEAE6F5), const Color(0xFF1C1630)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_ladnaMoodScore(mood.emoji)} / 5',
              style: TextStyle(
                fontSize: 11,
                color: _ladnaAdaptive(const Color(0xFF555268), const Color(0x99FFFFFF)),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LadnaHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _LadnaHeader({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_ladnaAdaptive(const Color(0xFFF5F3FA), const Color(0xFF100C1E)), _ladnaAdaptive(const Color(0xFFE2DDEF), const Color(0x1F6B54C0))],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _ladnaAdaptive(const Color(0xFFE0DCF0), const Color(0x2E6B54C0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_ladnaDarkMode ? 0.30 : 0.045),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _ladnaAdaptive(const Color(0xFFEAE6F5), const Color(0xFF1C1630)),
                shape: BoxShape.circle,
                border: Border.all(color: _ladnaAdaptive(const Color(0xFFE0DCF0), const Color(0x2E6B54C0))),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF555268),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 22,
                height: 1.05,
                fontWeight: FontWeight.w700,
                color: _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF)),
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LadnaTabs extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _LadnaTabs({
    required this.selectedIndex,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _ladnaAdaptive(const Color(0xFFEAE6F5), const Color(0xFF1C1630)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              borderRadius: BorderRadius.circular(11),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? _ladnaAdaptive(Colors.white, const Color(0xFF1C1630)) : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF))
                        : _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x4DFFFFFF)),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LadnaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _LadnaCard({
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _ladnaAdaptive(const Color(0xFFFAFAFE), const Color(0xFF1C1630)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ladnaAdaptive(const Color(0xFFE0DCF0), const Color(0x2E6B54C0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_ladnaDarkMode ? 0.30 : 0.045),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _CardHeader({
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF)),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          trailing,
          style: TextStyle(
            fontSize: 11,
            color: _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x99FFFFFF)),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MoodBubble extends StatelessWidget {
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _MoodBubble({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? _ladnaAdaptive(const Color(0xFFEAE6F5), const Color(0xFF1C1630)) : _ladnaAdaptive(const Color(0xFFEAE6F5), const Color(0xFF1C1630)),
          border: Border.all(
            color: selected ? const Color(0xFF6B54C0) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 21)),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9090A8),
        letterSpacing: 1.2,
      ),
    );
  }
}
