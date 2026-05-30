import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/goal.dart';
import '../../models/home_model.dart';
import '../../models/mood.dart';
import '../../models/mood_model.dart';
import '../../models/reports_model.dart';
import '../../services/home_ai_insight_service.dart';
import '../day_goals_screen.dart';


bool get _ladnaDarkMode =>
    WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

Color _ladnaAdaptive(Color light, Color dark) => _ladnaDarkMode ? dark : light;

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final model = ReportsModel();
            model.setPeriod(ReportPeriod.week);
            model.loadAll();
            return model;
          },
        ),
        ChangeNotifierProvider(create: (_) => MoodModel(repo: dbRepo)..load()),
      ],
      child: const _HomeDashboardBody(),
    );
  }
}

class _HomeDashboardBody extends StatefulWidget {
  const _HomeDashboardBody();

  @override
  State<_HomeDashboardBody> createState() => _HomeDashboardBodyState();
}

class _HomeDashboardBodyState extends State<_HomeDashboardBody>
    with AutomaticKeepAliveClientMixin {
  Future<_HabitsSnapshot>? _habitsFuture;
  Future<HomeAiInsightResult>? _aiInsightFuture;
  String? _aiLocale;

  static Color get _primary => const Color(0xFF6B54C0);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _habitsFuture = _loadHabits();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    if (_aiLocale != locale) {
      _aiLocale = locale;
      _aiInsightFuture = _shouldFetchWeeklyAiInsight()
          ? HomeAiInsightService.instance.fetch(locale: locale)
          : null;
    }
  }

  bool _shouldFetchWeeklyAiInsight() {
    return DateTime.now().weekday == DateTime.sunday;
  }

  Future<_HabitsSnapshot> _loadHabits() async {
    final today = DateUtils.dateOnly(DateTime.now());
    try {
      final habits = await dbRepo.listHabits();
      final entries = await dbRepo.getHabitEntriesForDay(today);
      var done = 0;
      for (final h in habits) {
        final id = _readDynamicString(h, 'id');
        final dynamic entry = entries[id];
        if (entry is Map && entry['done'] == true) done++;
      }
      return _HabitsSnapshot(done: done, total: habits.length);
    } catch (_) {
      return const _HabitsSnapshot(done: 0, total: 0);
    }
  }

  String? _readDynamicString(dynamic object, String field) {
    try {
      if (object is Map) return object[field]?.toString();
      final dynamic value = switch (field) {
        'id' => object.id,
        _ => null,
      };
      return value?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _refreshAll(BuildContext context) async {
    await Future.wait([
      context.read<ReportsModel>().loadAll(),
      context.read<MoodModel>().load(),
    ]);
    if (!mounted) return;
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    setState(() {
      _habitsFuture = _loadHabits();
      _aiInsightFuture = _shouldFetchWeeklyAiInsight()
          ? HomeAiInsightService.instance.fetch(locale: locale)
          : null;
    });
  }

  Future<void> _toggleGoal(Goal goal) async {
    try {
      await dbRepo.toggleGoalCompleted(goal.id, value: !goal.isCompleted);
      if (!mounted) return;
      await context.read<ReportsModel>().loadAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _openDayGoals(DateTime date) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DayGoalsScreen(
          date: DateUtils.dateOnly(date),
          lifeBlock: null,
          availableBlocks: const [],
        ),
      ),
    );
  }

  Mood? _todayMood(List<Mood> moods) {
    final today = DateUtils.dateOnly(DateTime.now());
    for (final mood in moods) {
      if (DateUtils.isSameDay(DateUtils.dateOnly(mood.date), today)) return mood;
    }
    return null;
  }

  List<Goal> _todayGoals(List<Goal> goals) {
    final today = DateUtils.dateOnly(DateTime.now());
    final list = goals.where((g) {
      return DateUtils.isSameDay(DateUtils.dateOnly(g.startTime), today) ||
          DateUtils.isSameDay(DateUtils.dateOnly(g.deadline), today);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  double _todayHours(List<Goal> goals) =>
      goals.fold<double>(0, (sum, g) => sum + g.spentHours);

  String _pick(Map<String, String> values) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return values[code] ?? values['en'] ?? values.values.first;
  }

  String _fmt(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  int _weekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  String _shortMonth(int month) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    final ru = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    final en = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (code == 'ru' ? ru : en)[month - 1];
  }

  String _weekRangeLabel() {
    final now = DateTime.now();
    final monday = DateUtils.dateOnly(now).subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return '${monday.day}–${sunday.day} ${_shortMonth(sunday.month)}';
  }


  String _homeTitle() => _pick(const {
        'ru': 'Главная',
        'en': 'Home',
        'de': 'Home',
        'fr': 'Accueil',
        'es': 'Inicio',
        'tr': 'Ana sayfa',
      });

  String _dateLabel() {
    final now = DateTime.now();
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    final weekdays = switch (code) {
      'ru' => ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'],
      'de' => ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
      'fr' => ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'],
      'es' => ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'],
      'tr' => ['pzt', 'sal', 'çar', 'per', 'cum', 'cmt', 'paz'],
      _ => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    };
    final months = switch (code) {
      'ru' => ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'],
      'de' => ['Jan.', 'Feb.', 'März', 'Apr.', 'Mai', 'Juni', 'Juli', 'Aug.', 'Sept.', 'Okt.', 'Nov.', 'Dez.'],
      'fr' => ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'],
      'es' => ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'],
      'tr' => ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'],
      _ => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    };
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  String _weekendAiTeaser() => _pick(const {
        'ru': 'AI-наблюдение — в воскресенье. Сейчас это статистика без запуска AI.',
        'en': 'The AI observation appears on Sunday. For now, this is statistics without running AI.',
        'de': 'Die AI-Beobachtung erscheint am Sonntag. Aktuell ist das Statistik ohne AI-Lauf.',
        'fr': 'L’observation IA apparaît dimanche. Pour l’instant, c’est une statistique sans lancer l’IA.',
        'es': 'La observación de IA aparece el domingo. Por ahora, esto es estadística sin ejecutar IA.',
        'tr': 'AI gözlemi pazar günü görünür. Şimdilik bu, AI çalıştırmadan istatistik.',
      });

  String _localizedGoalTitle(Goal goal) {
    final title = goal.title.trim();
    if (title.isEmpty) {
      return _pick(const {
        'ru': 'одной короткой задачи',
        'en': 'one short task',
        'de': 'einer kurzen Aufgabe',
        'fr': 'une petite tâche',
        'es': 'una tarea corta',
        'tr': 'kısa bir görev',
      });
    }
    return title;
  }

  String _buildStatObservationText({
    required List<Goal> todayGoals,
    required int doneGoals,
    required int totalGoals,
    required int progressPercent,
    required double todayHours,
    required double targetHours,
    required _HabitsSnapshot habits,
  }) {
    final openGoals = todayGoals.where((g) => !g.isCompleted).toList();
    final randomGoal = openGoals.isEmpty ? null : openGoals[math.Random().nextInt(openGoals.length)];
    final variants = <String>[];
    final teaser = _weekendAiTeaser();

    if (totalGoals > 0) {
      variants.add(_pick({
        'ru': 'Пока это статистика: выполнено $doneGoals из $totalGoals задач ($progressPercent%). $teaser',
        'en': 'For now, this is statistics: $doneGoals of $totalGoals tasks completed ($progressPercent%). $teaser',
        'de': 'Aktuell ist das Statistik: $doneGoals von $totalGoals Aufgaben erledigt ($progressPercent%). $teaser',
        'fr': 'Pour l’instant, c’est une statistique : $doneGoals sur $totalGoals tâches terminées ($progressPercent%). $teaser',
        'es': 'Por ahora, esto es estadística: $doneGoals de $totalGoals tareas completadas ($progressPercent%). $teaser',
        'tr': 'Şimdilik bu istatistik: $totalGoals görevden $doneGoals tamamlandı ($progressPercent%). $teaser',
      }));

      if (randomGoal != null) {
        final title = _localizedGoalTitle(randomGoal);
        variants.add(_pick({
          'ru': 'Сегодня лучше сфокусироваться на «$title». Закрой одну важную задачу — и день уже будет ощущаться спокойнее. $teaser',
          'en': 'Today, focus on “$title”. Complete one meaningful task and the day will already feel calmer. $teaser',
          'de': 'Fokussiere dich heute auf „$title“. Eine wichtige Aufgabe reicht, damit der Tag ruhiger wirkt. $teaser',
          'fr': 'Aujourd’hui, concentre-toi sur « $title ». Une tâche importante terminée rendra la journée plus légère. $teaser',
          'es': 'Hoy concéntrate en “$title”. Cerrar una tarea importante hará que el día se sienta más tranquilo. $teaser',
          'tr': 'Bugün “$title” görevine odaklan. Anlamlı bir görevi bitirmek günü daha sakin hissettirecek. $teaser',
        }));
      } else {
        variants.add(_pick({
          'ru': 'Все задачи на сегодня закрыты. Можно не перегружать вечер и просто зафиксировать результат. $teaser',
          'en': 'All tasks for today are done. Keep the evening light and record the result. $teaser',
          'de': 'Alle Aufgaben für heute sind erledigt. Halte den Abend leicht und sichere das Ergebnis. $teaser',
          'fr': 'Toutes les tâches du jour sont terminées. Garde une soirée légère et note le résultat. $teaser',
          'es': 'Todas las tareas de hoy están cerradas. Mantén la tarde ligera y registra el resultado. $teaser',
          'tr': 'Bugünün tüm görevleri tamamlandı. Akşamı hafif tut ve sonucu kaydet. $teaser',
        }));
      }
    } else {
      variants.add(_pick({
        'ru': 'На сегодня задач нет. Добавь одну маленькую задачу или отметь настроение — так недельное AI-наблюдение будет точнее.',
        'en': 'There are no tasks for today. Add one small task or log your mood so the weekly AI observation becomes more accurate.',
        'de': 'Für heute gibt es keine Aufgaben. Füge eine kleine Aufgabe hinzu oder markiere deine Stimmung, damit die wöchentliche AI-Beobachtung genauer wird.',
        'fr': 'Aucune tâche prévue aujourd’hui. Ajoute une petite tâche ou ton humeur pour rendre l’observation IA hebdomadaire plus précise.',
        'es': 'No hay tareas para hoy. Añade una tarea pequeña o registra tu ánimo para que la observación semanal de IA sea más precisa.',
        'tr': 'Bugün için görev yok. Haftalık AI gözlemi daha doğru olsun diye küçük bir görev ekle veya ruh halini kaydet.',
      }));
    }

    if (habits.total > 0) {
      variants.add(_pick({
        'ru': 'По привычкам сегодня ${habits.done}/${habits.total}. Выбери самый лёгкий следующий шаг — регулярность важнее идеального дня. $teaser',
        'en': 'Habits today: ${habits.done}/${habits.total}. Pick the easiest next step — consistency matters more than a perfect day. $teaser',
        'de': 'Gewohnheiten heute: ${habits.done}/${habits.total}. Wähle den einfachsten nächsten Schritt — Regelmäßigkeit zählt mehr als Perfektion. $teaser',
        'fr': 'Habitudes aujourd’hui : ${habits.done}/${habits.total}. Choisis le prochain pas le plus simple — la régularité compte plus que la perfection. $teaser',
        'es': 'Hábitos de hoy: ${habits.done}/${habits.total}. Elige el siguiente paso más fácil: la constancia importa más que un día perfecto. $teaser',
        'tr': 'Bugünkü alışkanlıklar: ${habits.done}/${habits.total}. En kolay sonraki adımı seç — düzenlilik mükemmel günden daha önemlidir. $teaser',
      }));
    }

    if (todayHours > 0) {
      variants.add(_pick({
        'ru': 'Фокус-время сегодня: ${_fmt(todayHours)} из ${_fmt(targetHours)} ч. Хороший момент закрыть одну задачу, пока есть рабочий ритм. $teaser',
        'en': 'Focus time today: ${_fmt(todayHours)} of ${_fmt(targetHours)} h. Good moment to finish one task while the rhythm is there. $teaser',
        'de': 'Fokuszeit heute: ${_fmt(todayHours)} von ${_fmt(targetHours)} Std. Ein guter Moment, eine Aufgabe im Rhythmus abzuschließen. $teaser',
        'fr': 'Temps de focus aujourd’hui : ${_fmt(todayHours)} sur ${_fmt(targetHours)} h. Bon moment pour terminer une tâche pendant que le rythme est là. $teaser',
        'es': 'Tiempo de foco hoy: ${_fmt(todayHours)} de ${_fmt(targetHours)} h. Buen momento para cerrar una tarea mientras hay ritmo. $teaser',
        'tr': 'Bugünkü odak süresi: ${_fmt(todayHours)} / ${_fmt(targetHours)} saat. Ritim varken bir görevi bitirmek için iyi an. $teaser',
      }));
    }

    return variants[math.Random().nextInt(variants.length)];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final reports = context.watch<ReportsModel>();
    final moodModel = context.watch<MoodModel>();

    final todayGoals = _todayGoals(reports.allGoals);
    final doneGoals = todayGoals.where((g) => g.isCompleted).length;
    final totalGoals = todayGoals.length;
    final visibleGoals = todayGoals.take(3).toList();
    final todayHours = _todayHours(todayGoals);
    final targetHours = reports.targetHours <= 0 ? 14.0 : reports.targetHours;
    final progressPercent = totalGoals == 0 ? 0 : ((doneGoals / totalGoals) * 100).round();
    final todayMood = _todayMood(moodModel.moods);

    return RefreshIndicator(
      color: _primary,
      onRefresh: () => _refreshAll(context),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 116),
        children: [
          _HomeHeader(
            title: _homeTitle(),
            date: _dateLabel(),
            onProfileTap: () => context.read<HomeModel>().select(3),
          ),
          const SizedBox(height: 18),
          _SectionLabel(text: _pick(const {
            'ru': 'Фокус сегодня',
            'en': 'Today focus',
            'de': 'Fokus heute',
            'fr': 'Focus du jour',
            'es': 'Foco de hoy',
            'tr': 'Bugünün odağı',
          })),
          const SizedBox(height: 9),
          _FocusCard(
            done: doneGoals,
            total: totalGoals,
            goals: visibleGoals,
            onToggleGoal: _toggleGoal,
            onOpenTasks: () => context.read<HomeModel>().select(1),
          ),
          const SizedBox(height: 18),
          _SectionLabel(text: _pick(const {
            'ru': 'Обзор дня',
            'en': 'Day overview',
            'de': 'Tagesübersicht',
            'fr': 'Aperçu du jour',
            'es': 'Resumen del día',
            'tr': 'Gün özeti',
          })),
          const SizedBox(height: 9),
          FutureBuilder<_HabitsSnapshot>(
            future: _habitsFuture,
            builder: (context, snapshot) {
              final habits = snapshot.data ?? const _HabitsSnapshot(done: 0, total: 0);
              final statObservationText = _buildStatObservationText(
                todayGoals: todayGoals,
                doneGoals: doneGoals,
                totalGoals: totalGoals,
                progressPercent: progressPercent,
                todayHours: todayHours,
                targetHours: targetHours,
                habits: habits,
              );

              return Column(
                children: [
                  _MiniGrid(
                    moodLabel: todayMood?.emoji ?? '😊',
                    moodValue: todayMood == null
                        ? _pick(const {
                            'ru': 'Нет отметки',
                            'en': 'No entry',
                            'de': 'Kein Eintrag',
                            'fr': 'Aucune note',
                            'es': 'Sin registro',
                            'tr': 'Kayıt yok',
                          })
                        : _pick(const {
                            'ru': 'Хорошее',
                            'en': 'Good',
                            'de': 'Gut',
                            'fr': 'Bonne',
                            'es': 'Bueno',
                            'tr': 'İyi',
                          }),
                    taskPercent: progressPercent,
                    doneTasks: doneGoals,
                    totalTasks: totalGoals,
                    habitDone: habits.done,
                    habitTotal: habits.total,
                    hours: todayHours,
                    targetHours: targetHours,
                  ),
                  const SizedBox(height: 12),
                  _WeekCard(
                    weekNumber: _weekNumber(DateTime.now()),
                    range: _weekRangeLabel(),
                    goals: reports.allGoals,
                    onDayTap: _openDayGoals,
                  ),
                  const SizedBox(height: 12),
                  _HomeAiInsightCard(
                    future: _shouldFetchWeeklyAiInsight() ? _aiInsightFuture : null,
                    fallbackText: statObservationText,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}


class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.title,
    required this.date,
    required this.onProfileTap,
  });

  final String title;
  final String date;
  final VoidCallback onProfileTap;

  static Color get _dark => _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF));
  static Color get _muted => _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x4DFFFFFF));
  static Color get _primary => const Color(0xFF6B54C0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _ladnaAdaptive(const Color(0xFFF0EEF8), const Color(0x1F6B54C0)),
            _ladnaAdaptive(const Color(0xFFE6E2F4), const Color(0x1F6B54C0)),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primary.withOpacity(_ladnaDarkMode ? .25 : .15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_ladnaDarkMode ? 0.40 : 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('🏠', style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 21,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 43,
              height: 43,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.16),
                shape: BoxShape.circle,
                border: Border.all(color: _primary.withOpacity(0.25), width: 1.5),
              ),
              child: const Text('👤', style: TextStyle(fontSize: 22)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitsSnapshot {
  const _HabitsSnapshot({required this.done, required this.total});
  final int done;
  final int total;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10.5,
        height: 1,
        fontWeight: FontWeight.w900,
        color: Color(0xFF9090A8),
        letterSpacing: 1.8,
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.done,
    required this.total,
    required this.goals,
    required this.onToggleGoal,
    required this.onOpenTasks,
  });

  final int done;
  final int total;
  final List<Goal> goals;
  final ValueChanged<Goal> onToggleGoal;
  final VoidCallback onOpenTasks;

  static Color get _primary => const Color(0xFF6B54C0);
  static Color get _focusStart => _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFF1E1548));
  static Color get _focusEnd => _ladnaAdaptive(const Color(0xFF2A1C5A), const Color(0xFF2A1C60));
  static Color get _focusDot => _ladnaAdaptive(const Color(0xFF6B54C0), const Color(0xFFD4E040));
  static const Color _mutedOnDark = Color(0xFFB6AED6);

  String _pick(BuildContext context, Map<String, String> values) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return values[code] ?? values['en'] ?? values.values.first;
  }

  @override
  Widget build(BuildContext context) {
    final shownTotal = total == 0 ? 3 : total;
    final rows = goals.isEmpty
        ? <_FocusRowData>[
            _FocusRowData(_pick(context, const {'ru': 'Утренняя пробежка', 'en': 'Morning run'}), true, null),
            _FocusRowData(_pick(context, const {'ru': 'Написать отчёт по проекту', 'en': 'Write project report'}), false, null),
            _FocusRowData(_pick(context, const {'ru': 'Проверить бюджет недели', 'en': 'Check weekly budget'}), false, null),
          ]
        : goals.map((g) {
            final title = g.title.trim().isEmpty ? '—' : g.title.trim();
            return _FocusRowData(title, g.isCompleted, g);
          }).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_focusStart, _focusEnd],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.24), blurRadius: 22, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -60,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [_primary.withOpacity(0.20), Colors.transparent]),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _focusDot,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: _focusDot.withOpacity(0.7), blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    _pick(context, const {
                      'ru': '{done} из {total} выполнено',
                      'en': '{done} of {total} done',
                      'de': '{done} von {total} erledigt',
                      'fr': '{done} sur {total} terminé',
                      'es': '{done} de {total} hecho',
                      'tr': '{done}/{total} tamamlandı',
                    }).replaceAll('{done}', done.toString()).replaceAll('{total}', shownTotal.toString()).toUpperCase(),
                    style: TextStyle(fontSize: 10.5, height: 1, fontWeight: FontWeight.w900, color: _focusDot, letterSpacing: 1.2),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                _pick(context, const {
                  'ru': 'День под контролем',
                  'en': 'Day under control',
                  'de': 'Tag im Griff',
                  'fr': 'Journée maîtrisée',
                  'es': 'Día bajo control',
                  'tr': 'Gün kontrol altında',
                }),
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 23,
                  height: 1.08,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFAF6EE),
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _pick(context, const {
                  'ru': 'Три задачи — это достаточно',
                  'en': 'Three tasks are enough',
                  'de': 'Drei Aufgaben reichen',
                  'fr': 'Trois tâches suffisent',
                  'es': 'Tres tareas son suficientes',
                  'tr': 'Üç görev yeterlidir',
                }),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _mutedOnDark),
              ),
              const SizedBox(height: 18),
              ...rows.take(3).map((row) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FocusTaskRow(
                      title: row.title,
                      done: row.done,
                      dismissKey: row.goal == null ? null : ValueKey('home-focus-${row.goal!.id}-${row.done}'),
                      onTap: row.goal == null ? null : () => onToggleGoal(row.goal!),
                      onSwipeComplete: row.goal == null || row.done ? null : () async {
                        onToggleGoal(row.goal!);
                      },
                    ),
                  )),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onOpenTasks,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    _pick(context, const {
                      'ru': '→ Все задачи',
                      'en': '→ All tasks',
                      'de': '→ Alle Aufgaben',
                      'fr': '→ Toutes les tâches',
                      'es': '→ Todas las tareas',
                      'tr': '→ Tüm görevler',
                    }),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusRowData {
  const _FocusRowData(this.title, this.done, this.goal);
  final String title;
  final bool done;
  final Goal? goal;
}

class _FocusTaskRow extends StatelessWidget {
  const _FocusTaskRow({
    required this.title,
    required this.done,
    this.dismissKey,
    this.onTap,
    this.onSwipeComplete,
  });

  final String title;
  final bool done;
  final Key? dismissKey;
  final VoidCallback? onTap;
  final Future<void> Function()? onSwipeComplete;

  String _pick(BuildContext context, Map<String, String> values) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return values[code] ?? values['en'] ?? values.values.first;
  }

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? const Color(0xFF6B54C0) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done ? const Color(0xFF6B54C0) : const Color(0xFFFAF6EE).withOpacity(0.28),
                  width: 1.8,
                ),
              ),
              child: done ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: done ? const Color(0xFFFAF6EE).withOpacity(0.35) : const Color(0xFFFAF6EE).withOpacity(0.90),
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: const Color(0xFFFAF6EE).withOpacity(0.35),
                  decorationThickness: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (dismissKey == null || onSwipeComplete == null) {
      return child;
    }

    return Dismissible(
      key: dismissKey!,
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        await onSwipeComplete!();
        return false;
      },
      background: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: const Color(0xFF34C759).withOpacity(0.24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF34C759).withOpacity(0.30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFFFAF6EE)),
            const SizedBox(width: 8),
            Text(
              _pick(context, const {
                'ru': 'Выполнить',
                'en': 'Complete',
                'de': 'Erledigen',
                'fr': 'Terminer',
                'es': 'Completar',
                'tr': 'Tamamla',
              }),
              style: const TextStyle(
                color: Color(0xFFFAF6EE),
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}

class _MiniGrid extends StatelessWidget {
  const _MiniGrid({
    required this.moodLabel,
    required this.moodValue,
    required this.taskPercent,
    required this.doneTasks,
    required this.totalTasks,
    required this.habitDone,
    required this.habitTotal,
    required this.hours,
    required this.targetHours,
  });

  final String moodLabel;
  final String moodValue;
  final int taskPercent;
  final int doneTasks;
  final int totalTasks;
  final int habitDone;
  final int habitTotal;
  final double hours;
  final double targetHours;

  String _pick(BuildContext context, Map<String, String> values) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return values[code] ?? values['en'] ?? values.values.first;
  }

  String _fmt(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _MiniCard(
        icon: moodLabel,
        label: _pick(context, const {'ru': 'Настроение', 'en': 'Mood', 'de': 'Stimmung', 'fr': 'Humeur', 'es': 'Ánimo', 'tr': 'Ruh hali'}),
        value: moodValue,
        valueIsSerif: false,
        subtitle: _pick(context, const {'ru': 'сегодня', 'en': 'today', 'de': 'heute', 'fr': 'aujourd’hui', 'es': 'hoy', 'tr': 'bugün'}),
      ),
      _MiniCard(
        icon: '✅',
        label: _pick(context, const {'ru': 'Задачи', 'en': 'Tasks', 'de': 'Aufgaben', 'fr': 'Tâches', 'es': 'Tareas', 'tr': 'Görevler'}),
        value: '$taskPercent%',
        subtitle: '$doneTasks ${_pick(context, const {'ru': 'из', 'en': 'of', 'de': 'von', 'fr': 'sur', 'es': 'de', 'tr': '/'})} ${totalTasks == 0 ? 3 : totalTasks}',
      ),
      _MiniCard(
        icon: '🔥',
        label: _pick(context, const {'ru': 'Привычки', 'en': 'Habits', 'de': 'Gewohnheiten', 'fr': 'Habitudes', 'es': 'Hábitos', 'tr': 'Alışkanlıklar'}),
        value: '$habitDone/${habitTotal == 0 ? 5 : habitTotal}',
        subtitle: _pick(context, const {'ru': 'сегодня', 'en': 'today', 'de': 'heute', 'fr': 'aujourd’hui', 'es': 'hoy', 'tr': 'bugün'}),
      ),
      _MiniCard(
        icon: '⏱',
        label: _pick(context, const {'ru': 'Фокус-часы', 'en': 'Focus hours', 'de': 'Fokusstunden', 'fr': 'Heures focus', 'es': 'Horas foco', 'tr': 'Odak saatleri'}),
        value: _fmt(hours),
        subtitle: '${_pick(context, const {'ru': 'из', 'en': 'of', 'de': 'von', 'fr': 'sur', 'es': 'de', 'tr': '/'})} ${_fmt(targetHours)} ч',
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 132,
          child: Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 132,
          child: Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.icon, required this.label, required this.value, required this.subtitle, this.valueIsSerif = true});

  final String icon;
  final String label;
  final String value;
  final String subtitle;
  final bool valueIsSerif;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _ladnaAdaptive(const Color(0xFFFAFAFE), const Color(0xFF1C1630)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ladnaAdaptive(const Color(0xFFE0DCF0), const Color(0x336B54C0)), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(_ladnaDarkMode ? 0.30 : 0.04), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24, height: 1)),
          const Spacer(),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x4DFFFFFF)))),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: valueIsSerif ? 'PlayfairDisplay' : null,
              fontSize: valueIsSerif ? 20 : 14,
              height: 1,
              fontWeight: FontWeight.w900,
              color: _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF)),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, height: 1, fontWeight: FontWeight.w700, color: _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x40FFFFFF)))),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.weekNumber, required this.range, required this.goals, required this.onDayTap});

  final int weekNumber;
  final String range;
  final List<Goal> goals;
  final ValueChanged<DateTime> onDayTap;

  static const List<String> _ruDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  static const List<String> _enDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _pick(BuildContext context, Map<String, String> values) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return values[code] ?? values['en'] ?? values.values.first;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final monday = today.subtract(Duration(days: now.weekday - 1));
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    final labels = code == 'ru' ? _ruDays : _enDays;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _ladnaAdaptive(const Color(0xFFFAFAFE), const Color(0xFF1C1630)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ladnaAdaptive(const Color(0xFFE0DCF0), const Color(0x336B54C0)), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(_ladnaDarkMode ? 0.30 : 0.04), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_pick(context, const {'ru': 'Неделя', 'en': 'Week', 'de': 'Woche', 'fr': 'Semaine', 'es': 'Semana', 'tr': 'Hafta'})} $weekNumber',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF))),
                ),
              ),
              Text(range, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x4DFFFFFF)))),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: List.generate(7, (index) {
              final day = monday.add(Duration(days: index));
              final isToday = DateUtils.isSameDay(day, today);
              final isDone = goals.any((g) =>
                  g.isCompleted &&
                  (DateUtils.isSameDay(DateUtils.dateOnly(g.startTime), day) ||
                      DateUtils.isSameDay(DateUtils.dateOnly(g.deadline), day)));
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onDayTap(day),
                  child: Column(
                    children: [
                      Text(labels[index], style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x40FFFFFF)))),
                      const SizedBox(height: 7),
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFF6B54C0)
                              : isDone
                                  ? const Color(0xFF16B8A8).withOpacity(0.12)
                                  : _ladnaAdaptive(const Color(0xFFEAE6F5), const Color(0x0DFFFFFF)),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isToday
                                ? const Color(0xFF6B54C0)
                                : isDone
                                    ? const Color(0xFF16B8A8).withOpacity(0.45)
                                    : _ladnaAdaptive(const Color(0xFFDCD5F2), const Color(0x336B54C0)),
                            width: 1.5,
                          ),
                          boxShadow: isToday ? [BoxShadow(color: const Color(0xFF6B54C0).withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))] : null,
                        ),
                        child: Text(
                          isDone && !isToday ? '✓' : '${day.day}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isToday
                                ? Colors.white
                                : isDone
                                    ? const Color(0xFF16B8A8)
                                    : _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x4DFFFFFF)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}


class _HomeAiInsightCard extends StatelessWidget {
  const _HomeAiInsightCard({required this.future, required this.fallbackText});

  final Future<HomeAiInsightResult>? future;
  final String fallbackText;

  String _pick(BuildContext context, Map<String, String> values) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return values[code] ?? values['en'] ?? values.values.first;
  }

  @override
  Widget build(BuildContext context) {
    final loadingText = _pick(context, const {
      'ru': 'AI формирует недельное наблюдение…',
      'en': 'AI is preparing your weekly observation…',
      'de': 'AI erstellt deine Wochenbeobachtung…',
      'fr': 'L’IA prépare ton observation hebdomadaire…',
      'es': 'La IA prepara tu observación semanal…',
      'tr': 'AI haftalık gözlemini hazırlıyor…',
    });

    if (future == null) {
      return _AiCard(text: fallbackText, sourceLabel: 'stats', aiUsed: false);
    }

    return FutureBuilder<HomeAiInsightResult>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _AiCard(text: loadingText, isLoading: true);
        }
        if (snapshot.hasError) {
          return _AiCard(text: fallbackText, sourceLabel: 'offline');
        }
        final result = snapshot.data;
        final text = (result?.insight ?? '').trim();
        return _AiCard(
          text: text.isEmpty ? fallbackText : text,
          sourceLabel: result?.source,
          aiUsed: result?.aiUsed ?? false,
        );
      },
    );
  }
}

class _AiCard extends StatelessWidget {
  const _AiCard({
    required this.text,
    this.isLoading = false,
    this.sourceLabel,
    this.aiUsed = false,
  });

  final String text;
  final bool isLoading;
  final String? sourceLabel;
  final bool aiUsed;

  String _pick(BuildContext context, Map<String, String> values) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return values[code] ?? values['en'] ?? values.values.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _ladnaAdaptive(const Color(0xFFE2DDEF), const Color(0xFF1C1630)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ladnaAdaptive(const Color(0xFFD8CCF0), const Color(0x33D4E040))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(_ladnaDarkMode ? 0.30 : 0.04), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _ladnaAdaptive(const Color(0xFF160E38), const Color(0x26D4E040)), borderRadius: BorderRadius.circular(12), border: Border.all(color: _ladnaAdaptive(Colors.transparent, const Color(0x40D4E040)))),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6B54C0)),
                  )
                : Text('✦', style: TextStyle(fontSize: 22, color: _ladnaAdaptive(const Color(0xFF6B54C0), const Color(0xFFD4E040)))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pick(context, aiUsed
                          ? const {'ru': 'AI-наблюдение недели', 'en': 'Weekly AI observation', 'de': 'Wöchentliche AI-Beobachtung', 'fr': 'Observation IA hebdomadaire', 'es': 'Observación semanal de IA', 'tr': 'Haftalık AI gözlemi'}
                          : const {'ru': 'Статистика дня', 'en': 'Day statistics', 'de': 'Tagesstatistik', 'fr': 'Statistique du jour', 'es': 'Estadística del día', 'tr': 'Gün istatistiği'})
                      .toUpperCase(),
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 1.3, color: _ladnaAdaptive(const Color(0xFF6B54C0), const Color(0xFFD4E040))),
                ),
                const SizedBox(height: 6),
                Text(text, style: TextStyle(fontSize: 13, height: 1.45, fontWeight: FontWeight.w700, color: _ladnaAdaptive(const Color(0xFF555268), const Color(0x99FFFFFF)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
