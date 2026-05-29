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
      _aiInsightFuture = HomeAiInsightService.instance.fetch(locale: locale);
    }
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
      _aiInsightFuture = HomeAiInsightService.instance.fetch(locale: locale);
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
              return _MiniGrid(
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
              );
            },
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
            future: _aiInsightFuture,
            fallbackText: _pick(const {
              'ru': 'AI-наблюдение скоро появится здесь. Пока добавь задачи, настроение или привычки — так инсайты станут точнее.',
              'en': 'AI observations will appear here soon. Add tasks, mood, or habits to make insights more accurate.',
              'de': 'AI-Beobachtungen erscheinen bald hier. Füge Aufgaben, Stimmung oder Gewohnheiten hinzu, damit Insights genauer werden.',
              'fr': 'Les observations IA apparaîtront bientôt ici. Ajoute des tâches, ton humeur ou des habitudes pour les rendre plus précises.',
              'es': 'Las observaciones de IA aparecerán aquí pronto. Añade tareas, estado de ánimo o hábitos para mejorar los insights.',
              'tr': 'AI gözlemleri yakında burada görünecek. İçgörüleri iyileştirmek için görev, ruh hali veya alışkanlık ekle.',
            }),
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
                    fontFamily: 'Playfair Display',
                    fontSize: 25,
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
                    fontSize: 16,
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
        fontSize: 12,
        height: 1,
        fontWeight: FontWeight.w900,
        color: Color(0xFF9090A8),
        letterSpacing: 2.2,
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
                    style: TextStyle(fontSize: 12, height: 1, fontWeight: FontWeight.w900, color: _focusDot, letterSpacing: 1.4),
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
                  fontFamily: 'Playfair Display',
                  fontSize: 28,
                  height: 1.05,
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
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _mutedOnDark),
              ),
              const SizedBox(height: 18),
              ...rows.take(3).map((row) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FocusTaskRow(
                      title: row.title,
                      done: row.done,
                      onTap: row.goal == null ? null : () => onToggleGoal(row.goal!),
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
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
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
  const _FocusTaskRow({required this.title, required this.done, this.onTap});
  final String title;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
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
                  fontSize: 16,
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
          Text(icon, style: const TextStyle(fontSize: 27, height: 1)),
          const Spacer(),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x4DFFFFFF)))),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: valueIsSerif ? 'Playfair Display' : null,
              fontSize: valueIsSerif ? 24 : 16,
              height: 1,
              fontWeight: FontWeight.w900,
              color: _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF)),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, height: 1, fontWeight: FontWeight.w700, color: _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x40FFFFFF)))),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF))),
                ),
              ),
              Text(range, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x4DFFFFFF)))),
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
                      Text(labels[index], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x40FFFFFF)))),
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
                            fontSize: 13,
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
      'ru': 'AI анализирует твой день…',
      'en': 'AI is analyzing your day…',
      'de': 'AI analysiert deinen Tag…',
      'fr': 'L’IA analyse ta journée…',
      'es': 'La IA analiza tu día…',
      'tr': 'AI gününü analiz ediyor…',
    });

    if (future == null) return _AiCard(text: fallbackText);

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
                  _pick(context, const {'ru': 'AI-наблюдение', 'en': 'AI observation', 'de': 'AI-Beobachtung', 'fr': 'Observation IA', 'es': 'Observación IA', 'tr': 'AI gözlemi'}).toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.6, color: _ladnaAdaptive(const Color(0xFF6B54C0), const Color(0xFFD4E040))),
                ),
                const SizedBox(height: 6),
                Text(text, style: TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w700, color: _ladnaAdaptive(const Color(0xFF555268), const Color(0x99FFFFFF)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
