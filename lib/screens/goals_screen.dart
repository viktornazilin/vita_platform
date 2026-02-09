import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goals_calendar_model.dart';
import '../models/life_block.dart';
import '../widgets/block_chip.dart';
import 'day_goals_screen.dart';

// репозиторий
import '../main.dart'; // dbRepo

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoalsCalendarModel()..loadBlocks(),
      child: const _GoalsView(),
    );
  }
}

enum _ViewMode { dashboard, calendar }

enum _CalMode { week, month }

class _GoalsView extends StatefulWidget {
  const _GoalsView();

  @override
  State<_GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<_GoalsView> {
  _ViewMode _view = _ViewMode.dashboard; // ✅ по умолчанию — дашборд
  _CalMode _calMode = _CalMode.week; // календарь: неделя/месяц

  DateTime _anchor = DateTime.now();

  // heatmap: день -> (сфера -> часы выполненных задач)
  Map<DateTime, Map<String, double>> _heat = {};
  double _targetHours = 8; // дневная норма из настроек/БД

  // цвета по сферам (general НЕ учитываем)
  static const Map<String, Color> _blockColors = {
    'health': Color(0xFF2E7D32),
    'career': Color.fromARGB(255, 96, 164, 241),
    'family': Color.fromARGB(255, 205, 108, 232),
    'relations': Color.fromARGB(255, 240, 45, 116),
    'education': Color.fromARGB(255, 99, 232, 218),
    'finance': Color.fromARGB(255, 245, 153, 4),
  };

  // ---------- helpers (неделя/месяц) ----------
  DateTime _startOfWeek(DateTime d) {
    final wd = d.weekday; // 1..7 (Mon..Sun)
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: wd - 1));
  }

  List<DateTime> _weekDays(DateTime anchor) {
    final start = _startOfWeek(anchor);
    return List.generate(
      7,
      (i) => DateTime(start.year, start.month, start.day + i),
    );
  }

  int _isoWeekNumber(DateTime date) {
    final thursday = date.add(Duration(days: 3 - ((date.weekday + 6) % 7)));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final firstThursdayWeekStart = firstThursday.subtract(
      Duration(days: (firstThursday.weekday + 6) % 7),
    );
    final diff = thursday.difference(firstThursdayWeekStart).inDays;
    return 1 + (diff ~/ 7);
  }

  String _rusMonth(int m) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return months[m - 1];
  }

  String _headerWeek(DateTime anchor) =>
      '${_rusMonth(anchor.month)} ${anchor.year}, неделя ${_isoWeekNumber(anchor)}';

  String _formatModelMonthTitle(String modelTitle) {
    final parts = modelTitle.split(' ');
    if (parts.length == 2) {
      final eng = parts[0].toLowerCase();
      final year = parts[1];
      const map = {
        'january': 'Январь',
        'february': 'Февраль',
        'march': 'Март',
        'april': 'Апрель',
        'may': 'Май',
        'june': 'Июнь',
        'july': 'Июль',
        'august': 'Август',
        'september': 'Сентябрь',
        'october': 'Октябрь',
        'november': 'Ноябрь',
        'december': 'Декабрь',
      };
      final ru = map[eng];
      if (ru != null) return '$ru $year';
    }
    return modelTitle;
  }

  String _weekdayShortRu(int weekday) {
    const map = {
      DateTime.monday: 'Пн',
      DateTime.tuesday: 'Вт',
      DateTime.wednesday: 'Ср',
      DateTime.thursday: 'Чт',
      DateTime.friday: 'Пт',
      DateTime.saturday: 'Сб',
      DateTime.sunday: 'Вс',
    };
    return map[weekday] ?? '';
  }

  void _openDay(BuildContext context, DateTime date) {
    final m = context.read<GoalsCalendarModel>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DayGoalsScreen(
          date: date,
          lifeBlock: m.selectedBlockOrNull,
          availableBlocks: m.lifeBlocks,
        ),
      ),
    );
  }

  // ---------- загрузка дневной нормы и heatmap недели ----------
  @override
  void initState() {
    super.initState();
    _loadTargetHours();
    _loadWeekHeat();
  }

  Future<void> _loadTargetHours() async {
    try {
      final th = await dbRepo.getTargetHours();
      if (!mounted) return;
      setState(() => _targetHours = th <= 0 ? 8 : th);
    } catch (_) {
      // оставим дефолт 8
    }
  }

  Future<void> _loadWeekHeat() async {
    final monday = _startOfWeek(_anchor);
    final Map<DateTime, Map<String, double>> map = {};

    // 7 отдельных запроса под доступный метод getGoalsByDate
    for (int i = 0; i < 7; i++) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      final list = await dbRepo.getGoalsByDate(day);

      for (final g in list) {
        if (g.isCompleted != true) continue;

        // ✅ general НЕ учитываем
        final raw = (g.lifeBlock ?? '').trim().toLowerCase();
        if (raw.isEmpty || raw == 'general') continue;

        final hours = (g.spentHours is num)
            ? (g.spentHours as num).toDouble()
            : 0.0;

        if (hours <= 0) continue;

        final inner = map.putIfAbsent(
          DateUtils.dateOnly(day),
          () => <String, double>{},
        );
        inner[raw] = (inner[raw] ?? 0) + hours;
      }
    }

    if (!mounted) return;
    setState(() => _heat = map);
  }

  // ---------- агрегаты для дашборда ----------
  Map<String, double> _dayHeatFiltered(GoalsCalendarModel m, DateTime day) {
    final src = _heat[DateUtils.dateOnly(day)];
    if (src == null || src.isEmpty) return {};

    // на всякий случай
    final cleaned = Map<String, double>.from(src)..remove('general');

    if (m.selectedBlock != 'all') {
      final v = cleaned[m.selectedBlock] ?? 0.0;
      return v > 0 ? {m.selectedBlock: v} : {};
    }
    return cleaned;
  }

  double _sumHours(Map<String, double> heat) {
    double s = 0.0;
    for (final v in heat.values) {
      s += v;
    }
    return s;
  }

  double _p01(double hours, double target) {
    if (target <= 0) return 0;
    return (hours / target).clamp(0.0, 1.0);
  }

  List<MapEntry<String, double>> _top3(Map<String, double> heat) {
    final list = heat.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<GoalsCalendarModel>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mq = MediaQuery.of(context);
    final isCompact = mq.size.width < 600;
    const maxContentW = 900.0;
    final sidePad = mq.size.width > maxContentW
        ? (mq.size.width - maxContentW) / 2
        : 0.0;

    final weekDays = _weekDays(_anchor);

    final String headerTitle = _view == _ViewMode.dashboard
        ? _headerWeek(_anchor)
        : (_calMode == _CalMode.week
              ? _headerWeek(_anchor)
              : _formatModelMonthTitle(m.monthTitle));

    final List<DateTime> daysList = _calMode == _CalMode.week
        ? weekDays
        : m.daysInMonth;

    final weekCellHeight = isCompact ? 72.0 : 64.0;

    Future<void> goPrev() async {
      if (_view == _ViewMode.dashboard) {
        setState(() => _anchor = _anchor.subtract(const Duration(days: 7)));
        await _loadWeekHeat();
        return;
      }

      // calendar
      if (_calMode == _CalMode.week) {
        setState(() => _anchor = _anchor.subtract(const Duration(days: 7)));
        await _loadWeekHeat();
      } else {
        m.prevMonth();
      }
    }

    Future<void> goNext() async {
      if (_view == _ViewMode.dashboard) {
        setState(() => _anchor = _anchor.add(const Duration(days: 7)));
        await _loadWeekHeat();
        return;
      }

      // calendar
      if (_calMode == _CalMode.week) {
        setState(() => _anchor = _anchor.add(const Duration(days: 7)));
        await _loadWeekHeat();
      } else {
        m.nextMonth();
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // шапка
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            title: const Text('Цели'),
            actions: [
              IconButton(
                tooltip: 'Сегодня',
                onPressed: () async {
                  setState(() => _anchor = DateTime.now());
                  await _loadWeekHeat();
                },
                icon: const Icon(Icons.today),
              ),
            ],
          ),

          // чипы сфер
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeader(
              extent: isCompact ? 64 : 72,
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: isCompact ? 64 : 72,
                    child: ListView(
                      padding: EdgeInsets.only(
                        left: 12 + sidePad,
                        right: 12 + sidePad,
                        top: isCompact ? 10 : 12,
                        bottom: isCompact ? 10 : 12,
                      ),
                      scrollDirection: Axis.horizontal,
                      children: [
                        BlockChip(
                          label: 'Все',
                          selected: m.selectedBlock == 'all',
                          onTap: () => m.setSelectedBlock('all'),
                        ),
                        ...m.lifeBlocks
                            .where((b) => b.toLowerCase() != 'general') // ✅
                            .map(
                              (b) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: BlockChip(
                                  label: getBlockLabel(
                                    LifeBlock.values.firstWhere(
                                      (e) => e.name == b,
                                      orElse: () => LifeBlock.health,
                                    ),
                                  ),
                                  selected: m.selectedBlock == b,
                                  onTap: () => m.setSelectedBlock(b),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // заголовок периода + навигация + переключатели
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12 + sidePad, 8, 12 + sidePad, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: goPrev,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          headerTitle,
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ✅ переключатель вида: Дашборд / Календарь
                        SegmentedButton<_ViewMode>(
                          segments: const [
                            ButtonSegment(
                              value: _ViewMode.dashboard,
                              label: Text('Дашборд'),
                              icon: Icon(Icons.dashboard_outlined),
                            ),
                            ButtonSegment(
                              value: _ViewMode.calendar,
                              label: Text('Календарь'),
                              icon: Icon(Icons.calendar_month),
                            ),
                          ],
                          selected: {_view},
                          onSelectionChanged: (v) async {
                            final next = v.first;
                            setState(() => _view = next);

                            // в календаре неделя использует heat — подгружаем
                            if (next == _ViewMode.calendar &&
                                _calMode == _CalMode.week) {
                              await _loadWeekHeat();
                            }
                          },
                        ),

                        // ✅ неделя/месяц только если календарь
                        if (_view == _ViewMode.calendar) ...[
                          const SizedBox(height: 8),
                          SegmentedButton<_CalMode>(
                            segments: const [
                              ButtonSegment(
                                value: _CalMode.week,
                                label: Text('Неделя'),
                                icon: Icon(Icons.view_week),
                              ),
                              ButtonSegment(
                                value: _CalMode.month,
                                label: Text('Месяц'),
                                icon: Icon(Icons.calendar_month),
                              ),
                            ],
                            selected: {_calMode},
                            onSelectionChanged: (v) async {
                              final newMode = v.first;
                              setState(() => _calMode = newMode);
                              if (newMode == _CalMode.week) {
                                setState(() => _anchor = DateTime.now());
                                await _loadWeekHeat();
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: goNext,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),

          // ===== DASHBOARD VIEW =====
          if (_view == _ViewMode.dashboard) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  12 + sidePad,
                  12,
                  12 + sidePad,
                  10,
                ),
                child: _WeekSummaryCard(
                  days: weekDays,
                  getDayHeat: (d) => _dayHeatFiltered(m, d),
                  targetHours: _targetHours,
                  colorsByBlock: _blockColors,
                ),
              ),
            ),

            SliverList.separated(
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final d = weekDays[i];
                final dayHeat = _dayHeatFiltered(m, d);
                final hours = _sumHours(dayHeat);
                final p = _p01(hours, _targetHours);
                final top = _top3(dayHeat);

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 + sidePad),
                  child: _DayRowCard(
                    date: d,
                    weekday: _weekdayShortRu(d.weekday),
                    isToday: DateUtils.isSameDay(d, DateTime.now()),
                    progress01: p,
                    hours: hours,
                    targetHours: _targetHours,
                    topBlocks: top,
                    colorsByBlock: _blockColors,
                    onTap: () => _openDay(context, d),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],

          // ===== CALENDAR VIEW =====
          if (_view == _ViewMode.calendar) ...[
            // заголовок дней недели
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 + sidePad,
                  vertical: 6,
                ),
                child: Row(
                  children: const [
                    _Weekday('Пн'),
                    _Weekday('Вт'),
                    _Weekday('Ср'),
                    _Weekday('Чт'),
                    _Weekday('Пт'),
                    _Weekday('Сб'),
                    _Weekday('Вс'),
                  ],
                ),
              ),
            ),

            // сетка календаря
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: 12 + sidePad,
                vertical: 8,
              ),
              sliver: SliverGrid.builder(
                gridDelegate: _calMode == _CalMode.week
                    ? SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        mainAxisExtent: weekCellHeight,
                      )
                    : const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                itemCount: daysList.length,
                itemBuilder: (_, i) {
                  final d = daysList[i];

                  final inMonth = _calMode == _CalMode.month
                      ? m.isSameMonth(d)
                      : true;

                  if (_calMode == _CalMode.month && !inMonth) {
                    return const SizedBox.shrink();
                  }

                  final isToday = DateUtils.isSameDay(d, DateTime.now());
                  final isWeekend =
                      d.weekday == DateTime.saturday ||
                      d.weekday == DateTime.sunday;

                  // ✅ в календаре показываем heat только в недельном режиме
                  final rawHeat = _calMode == _CalMode.week
                      ? _heat[DateUtils.dateOnly(d)]
                      : null;

                  // ✅ фильтруем под выбранный блок и выкидываем general
                  Map<String, double>? heat;
                  if (rawHeat != null && rawHeat.isNotEmpty) {
                    final cleaned = Map<String, double>.from(rawHeat)
                      ..remove('general');

                    if (m.selectedBlock != 'all') {
                      final v = cleaned[m.selectedBlock] ?? 0.0;
                      heat = v > 0 ? {m.selectedBlock: v} : <String, double>{};
                    } else {
                      heat = cleaned;
                    }
                  }

                  // ✅ если выбран блок — делаем моно-заливку (без слоёв)
                  final forceMono = (m.selectedBlock != 'all');

                  return _DayCell(
                    date: d,
                    isToday: isToday,
                    isWeekend: isWeekend,
                    inMonth: inMonth,
                    onTap: () => _openDay(context, d),
                    heat: heat,
                    targetHours: _targetHours,
                    colorsByBlock: _blockColors,
                    forceMono: forceMono,
                    monoKey: m.selectedBlock != 'all' ? m.selectedBlock : null,
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        ],
      ),
    );
  }
}

// ---------- DASHBOARD WIDGETS ----------

class _WeekSummaryCard extends StatelessWidget {
  final List<DateTime> days;
  final Map<String, double> Function(DateTime day) getDayHeat;
  final double targetHours;
  final Map<String, Color> colorsByBlock;

  const _WeekSummaryCard({
    required this.days,
    required this.getDayHeat,
    required this.targetHours,
    required this.colorsByBlock,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    double weekHours = 0;
    final totalsByBlock = <String, double>{};

    for (final d in days) {
      final heat = getDayHeat(d);
      for (final e in heat.entries) {
        weekHours += e.value;
        totalsByBlock[e.key] = (totalsByBlock[e.key] ?? 0) + e.value;
      }
    }

    final weekTarget = targetHours * 7;
    final p = weekTarget <= 0 ? 0.0 : (weekHours / weekTarget).clamp(0.0, 1.0);

    final top = totalsByBlock.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = top.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Итог недели',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: p,
              minHeight: 10,
              backgroundColor: cs.surfaceVariant.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${weekHours.toStringAsFixed(1)} ч',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                ' / ${weekTarget.toStringAsFixed(0)} ч',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const Spacer(),
              if (p >= 1)
                Icon(Icons.verified, color: cs.primary, size: 20)
              else
                Icon(Icons.trending_up, color: cs.onSurfaceVariant, size: 20),
            ],
          ),
          if (top3.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: top3.map((e) {
                final c = colorsByBlock[e.key] ?? cs.primary;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${e.key}: ${e.value.toStringAsFixed(1)}ч',
                      style: tt.labelMedium,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayRowCard extends StatelessWidget {
  final DateTime date;
  final String weekday;
  final bool isToday;

  final double progress01;
  final double hours;
  final double targetHours;

  final List<MapEntry<String, double>> topBlocks;
  final Map<String, Color> colorsByBlock;

  final VoidCallback onTap;

  const _DayRowCard({
    required this.date,
    required this.weekday,
    required this.isToday,
    required this.progress01,
    required this.hours,
    required this.targetHours,
    required this.topBlocks,
    required this.colorsByBlock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isToday
                ? cs.primaryContainer.withOpacity(0.45)
                : cs.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 62,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weekday,
                      style: tt.labelLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${date.day}',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress01,
                        minHeight: 10,
                        backgroundColor: cs.surfaceVariant.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${hours.toStringAsFixed(1)}ч',
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' / ${targetHours.toStringAsFixed(0)}ч',
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: topBlocks.map((e) {
                            final c = colorsByBlock[e.key] ?? cs.primary;
                            return Container(
                              margin: const EdgeInsets.only(left: 6),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- CALENDAR WIDGETS ----------

class _Weekday extends StatelessWidget {
  final String s;
  const _Weekday(this.s);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
      child: Center(
        child: Text(
          s,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: color),
        ),
      ),
    );
  }
}

class _DayCell extends StatefulWidget {
  final DateTime date;
  final bool isToday;
  final bool isWeekend;
  final bool inMonth;
  final VoidCallback onTap;

  // heat:
  final Map<String, double>? heat; // сфера -> часы
  final double targetHours;
  final Map<String, Color> colorsByBlock;

  // ✅ если выбран блок — рисуем моно-заливку
  final bool forceMono;
  final String? monoKey;

  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isWeekend,
    required this.inMonth,
    required this.onTap,
    this.heat,
    this.targetHours = 8,
    this.colorsByBlock = const {},
    this.forceMono = false,
    this.monoKey,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final surface = cs.surface;
    final bgBase = widget.isToday
        ? cs.primaryContainer.withOpacity(0.55)
        : surface.withOpacity(0.90);
    final borderColor = widget.isToday
        ? cs.primary.withOpacity(0.6)
        : cs.outlineVariant.withOpacity(0.6);

    final labelColor = !widget.inMonth
        ? cs.onSurfaceVariant.withOpacity(0.5)
        : widget.isWeekend
        ? cs.onSurface.withOpacity(0.85)
        : cs.onSurface;

    final radius = 12.0;

    final heat = widget.heat ?? const <String, double>{};

    // общий прогресс (все выбранные блоки уже отфильтрованы выше)
    double hours = 0;
    for (final v in heat.values) {
      hours += v;
    }
    final frac = widget.targetHours <= 0
        ? 0.0
        : (hours / widget.targetHours).clamp(0.0, 1.0);

    // цвет моно-режима
    Color monoColor = cs.primary;
    if (widget.forceMono && widget.monoKey != null) {
      monoColor = widget.colorsByBlock[widget.monoKey!] ?? cs.primary;
    }

    final hasData = frac > 0;

    return AnimatedScale(
      duration: const Duration(milliseconds: 100),
      scale: _pressed ? 0.98 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () {
            setState(() => _pressed = false);
            widget.onTap();
          },
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: bgBase,
              border: Border.all(color: borderColor),
              boxShadow: [
                if (!widget.isToday)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: CustomPaint(
                painter: _SingleFillPainter(
                  background: bgBase,
                  fraction: frac,
                  fillColor: widget.forceMono ? monoColor : cs.primary,
                  rimColor: widget.isToday
                      ? cs.primaryContainer.withOpacity(0.35)
                      : null,
                ),
                child: Stack(
                  children: [
                    if (widget.isToday)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    if (hasData)
                      Positioned(
                        left: 6,
                        top: 6,
                        child: Icon(
                          Icons.check_circle,
                          size: 14,
                          color: cs.onSurfaceVariant.withOpacity(0.75),
                        ),
                      ),
                    Center(
                      child: Text(
                        '${widget.date.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          height: 1.0,
                          color: labelColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Простой “стакан” без слоёв: один цвет = понятность.
/// В режиме "all" цвет тоже один (primary), а вклад блоков виден в дашборде.
class _SingleFillPainter extends CustomPainter {
  final Color background;
  final double fraction; // 0..1
  final Color fillColor;
  final Color? rimColor;

  const _SingleFillPainter({
    required this.background,
    required this.fraction,
    required this.fillColor,
    this.rimColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );

    // фон
    canvas.drawRRect(rrect, Paint()..color = background);

    // заливка снизу
    final h = (fraction * size.height).clamp(0.0, size.height);
    final top = size.height - h;
    final rect = Rect.fromLTWH(0, top, size.width, h);

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(rect, Paint()..color = fillColor.withOpacity(0.95));
    canvas.restore();

    // блик
    if (rimColor != null) {
      final rim = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [rimColor!.withOpacity(.6), rimColor!.withOpacity(0)],
          stops: const [0, .9],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * .6));
      canvas.drawRRect(rrect, rim);
    }
  }

  @override
  bool shouldRepaint(covariant _SingleFillPainter oldDelegate) {
    return background != oldDelegate.background ||
        fraction != oldDelegate.fraction ||
        fillColor != oldDelegate.fillColor ||
        rimColor != oldDelegate.rimColor;
  }
}

// липкая шапка для SliverPersistentHeader — безопасная версия
class _StickyHeader extends SliverPersistentHeaderDelegate {
  final double extent;
  final Widget child;
  _StickyHeader({required this.extent, required this.child});

  @override
  double get minExtent => extent;
  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox(height: extent, child: child);

  @override
  bool shouldRebuild(covariant _StickyHeader oldDelegate) =>
      extent != oldDelegate.extent || child != oldDelegate.child;
}
