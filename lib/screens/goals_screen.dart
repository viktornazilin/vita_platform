import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goals_calendar_model.dart';
import '../models/life_block.dart';
import '../widgets/block_chip.dart';
import 'day_goals_screen.dart';

// ✅ Nest style widgets
import '../widgets/nest/nest_background.dart';
import '../widgets/nest/nest_blur_card.dart';

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
  _ViewMode _view = _ViewMode.dashboard;
  _CalMode _calMode = _CalMode.week;

  DateTime _anchor = DateTime.now();

  // heat: day -> (lifeBlock -> hours)
  Map<DateTime, Map<String, double>> _heat = {};
  double _targetHours = 8;

  static const Map<String, Color> _blockColors = {
    'health': Color(0xFF2E7D32),
    'career': Color.fromARGB(255, 96, 164, 241),
    'family': Color.fromARGB(255, 205, 108, 232),
    'relations': Color.fromARGB(255, 240, 45, 116),
    'education': Color.fromARGB(255, 99, 232, 218),
    'finance': Color.fromARGB(255, 245, 153, 4),
  };

  // ---------- helpers ----------
  DateTime _startOfWeek(DateTime d) {
    final wd = d.weekday; // 1..7
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: wd - 1));
  }

  List<DateTime> _weekDays(DateTime anchor) {
    final start = _startOfWeek(anchor);
    return List.generate(7, (i) => DateTime(start.year, start.month, start.day + i));
  }

  int _isoWeekNumber(DateTime date) {
    final thursday = date.add(Duration(days: 3 - ((date.weekday + 6) % 7)));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final firstThursdayWeekStart =
        firstThursday.subtract(Duration(days: (firstThursday.weekday + 6) % 7));
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

  // ---------- init ----------
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
    } catch (_) {}
  }

  Future<void> _loadWeekHeat() async {
    final monday = _startOfWeek(_anchor);
    final Map<DateTime, Map<String, double>> map = {};

    for (int i = 0; i < 7; i++) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      final list = await dbRepo.getGoalsByDate(day);

      for (final g in list) {
        if (g.isCompleted != true) continue;

        final raw = (g.lifeBlock ?? '').trim().toLowerCase();
        if (raw.isEmpty || raw == 'general') continue;

        final hours = (g.spentHours is num) ? (g.spentHours as num).toDouble() : 0.0;
        if (hours <= 0) continue;

        final key = DateUtils.dateOnly(day);
        final inner = map.putIfAbsent(key, () => <String, double>{});
        inner[raw] = (inner[raw] ?? 0) + hours;
      }
    }

    if (!mounted) return;
    setState(() => _heat = map);
  }

  Future<void> _loadMonthHeat(int year, int month) async {
    final Map<DateTime, Map<String, double>> map = {};
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int dayNum = 1; dayNum <= daysInMonth; dayNum++) {
      final day = DateTime(year, month, dayNum);
      final list = await dbRepo.getGoalsByDate(day);

      for (final g in list) {
        if (g.isCompleted != true) continue;

        final raw = (g.lifeBlock ?? '').trim().toLowerCase();
        if (raw.isEmpty || raw == 'general') continue;

        final hours = (g.spentHours is num) ? (g.spentHours as num).toDouble() : 0.0;
        if (hours <= 0) continue;

        final key = DateUtils.dateOnly(day);
        final inner = map.putIfAbsent(key, () => <String, double>{});
        inner[raw] = (inner[raw] ?? 0) + hours;
      }
    }

    if (!mounted) return;
    setState(() => _heat = map);
  }

  Future<void> _reloadHeat(GoalsCalendarModel m) async {
    if (_view != _ViewMode.calendar) {
      await _loadWeekHeat();
      return;
    }
    if (_calMode == _CalMode.week) {
      await _loadWeekHeat();
    } else {
      await _loadMonthHeat(_anchor.year, _anchor.month);
    }
  }

  // ---------- dashboard helpers ----------
  Map<String, double> _dayHeatFiltered(GoalsCalendarModel m, DateTime day) {
    final src = _heat[DateUtils.dateOnly(day)];
    if (src == null || src.isEmpty) return {};

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
    final textTheme = Theme.of(context).textTheme;

    final mq = MediaQuery.of(context);
    final isCompact = mq.size.width < 600;
    const maxContentW = 900.0;
    final sidePad = mq.size.width > maxContentW ? (mq.size.width - maxContentW) / 2 : 0.0;

    final weekDays = _weekDays(_anchor);

    final String headerTitle = _view == _ViewMode.dashboard
        ? _headerWeek(_anchor)
        : (_calMode == _CalMode.week ? _headerWeek(_anchor) : _formatModelMonthTitle(m.monthTitle));

    final List<DateTime> daysList = _calMode == _CalMode.week ? weekDays : m.daysInMonth;
    final weekCellHeight = isCompact ? 72.0 : 64.0;

    Future<void> goPrev() async {
      if (_view == _ViewMode.dashboard) {
        setState(() => _anchor = _anchor.subtract(const Duration(days: 7)));
        await _loadWeekHeat();
        return;
      }

      if (_calMode == _CalMode.week) {
        setState(() => _anchor = _anchor.subtract(const Duration(days: 7)));
        await _loadWeekHeat();
      } else {
        m.prevMonth();
        // синхронизируем anchor на предыдущий месяц
        setState(() => _anchor = DateTime(_anchor.year, _anchor.month - 1, 1));
        await _loadMonthHeat(_anchor.year, _anchor.month);
      }
    }

    Future<void> goNext() async {
      if (_view == _ViewMode.dashboard) {
        setState(() => _anchor = _anchor.add(const Duration(days: 7)));
        await _loadWeekHeat();
        return;
      }

      if (_calMode == _CalMode.week) {
        setState(() => _anchor = _anchor.add(const Duration(days: 7)));
        await _loadWeekHeat();
      } else {
        m.nextMonth();
        setState(() => _anchor = DateTime(_anchor.year, _anchor.month + 1, 1));
        await _loadMonthHeat(_anchor.year, _anchor.month);
      }
    }

    return Scaffold(
      body: NestBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              centerTitle: false,
              title: const Text('Цели'),
              actions: [
                IconButton(
                  tooltip: 'Сегодня',
                  onPressed: () async {
                    setState(() => _anchor = DateTime.now());
                    if (_view == _ViewMode.calendar && _calMode == _CalMode.month) {
                      await _loadMonthHeat(_anchor.year, _anchor.month);
                    } else {
                      await _loadWeekHeat();
                    }
                  },
                  icon: const Icon(Icons.today),
                ),
              ],
            ),

            // категории (НЕ pinned)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12 + sidePad, 8, 12 + sidePad, 0),
                child: SizedBox(
                  height: isCompact ? 56 : 62,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    children: [
                      BlockChip(
                        label: 'Все',
                        selected: m.selectedBlock == 'all',
                        onTap: () => m.setSelectedBlock('all'),
                      ),
                      ...m.lifeBlocks
                          .where((b) => b.toLowerCase() != 'general')
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

            // заголовок + переключатели
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12 + sidePad, 8, 12 + sidePad, 0),
                child: Row(
                  children: [
                    IconButton(onPressed: goPrev, icon: const Icon(Icons.chevron_left)),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            headerTitle,
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),

                          // ✅ ВАЖНО: меняем _view
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
                              setState(() => _view = v.first);
                              await _reloadHeat(m);
                            },
                          ),

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
                                  await _loadWeekHeat();
                                } else {
                                  // sync anchor to current "shown" month (просто текущий anchor)
                                  setState(() => _anchor = DateTime(_anchor.year, _anchor.month, 1));
                                  await _loadMonthHeat(_anchor.year, _anchor.month);
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(onPressed: goNext, icon: const Icon(Icons.chevron_right)),
                  ],
                ),
              ),
            ),

            // ===== DASHBOARD VIEW =====
            if (_view == _ViewMode.dashboard) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12 + sidePad, 12, 12 + sidePad, 10),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 + sidePad, vertical: 6),
                  child: const Row(
                    children: [
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

              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 12 + sidePad, vertical: 8),
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

                    final inMonth = _calMode == _CalMode.month ? m.isSameMonth(d) : true;
                    if (_calMode == _CalMode.month && !inMonth) {
                      return const SizedBox.shrink();
                    }

                    final isToday = DateUtils.isSameDay(d, DateTime.now());
                    final isWeekend =
                        d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;

                    // ✅ FIX: heat показываем и в week, и в month
                    final rawHeat = _heat[DateUtils.dateOnly(d)];

                    Map<String, double>? heat;
                    if (rawHeat != null && rawHeat.isNotEmpty) {
                      final cleaned = Map<String, double>.from(rawHeat)..remove('general');

                      if (m.selectedBlock != 'all') {
                        final v = cleaned[m.selectedBlock] ?? 0.0;
                        heat = v > 0 ? {m.selectedBlock: v} : <String, double>{};
                      } else {
                        heat = cleaned;
                      }
                    }

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

    return NestBlurCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Итог недели', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
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
                Text('${weekHours.toStringAsFixed(1)} ч',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text(' / ${weekTarget.toStringAsFixed(0)} ч',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                const Spacer(),
                Icon(
                  p >= 1 ? Icons.verified : Icons.trending_up,
                  color: p >= 1 ? cs.primary : cs.onSurfaceVariant,
                  size: 20,
                ),
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
                      Container(width: 10, height: 10,
                          decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('${e.key}: ${e.value.toStringAsFixed(1)}ч', style: tt.labelMedium),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
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
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: NestBlurCard(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                SizedBox(
                  width: 62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(weekday, style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text('${date.day}',
                          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
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
                          Text('${hours.toStringAsFixed(1)}ч',
                              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                          Text(' / ${targetHours.toStringAsFixed(0)}ч',
                              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                          const Spacer(),
                          Row(
                            children: topBlocks.map((e) {
                              final c = colorsByBlock[e.key] ?? cs.primary;
                              return Container(
                                margin: const EdgeInsets.only(left: 6),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
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
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
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

  final Map<String, double>? heat;
  final double targetHours;
  final Map<String, Color> colorsByBlock;

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

    final bgBase = widget.isToday
        ? cs.primaryContainer.withOpacity(0.55)
        : cs.surface.withOpacity(0.90);

    final labelColor = !widget.inMonth
        ? cs.onSurfaceVariant.withOpacity(0.5)
        : widget.isWeekend
            ? cs.onSurface.withOpacity(0.85)
            : cs.onSurface;

    const radius = 12.0;

    final heat = widget.heat ?? const <String, double>{};

    double hours = 0;
    for (final v in heat.values) {
      hours += v;
    }

    final frac = widget.targetHours <= 0 ? 0.0 : (hours / widget.targetHours).clamp(0.0, 1.0);

    Color fillColor = cs.primary;
    if (widget.forceMono && widget.monoKey != null) {
      fillColor = widget.colorsByBlock[widget.monoKey!] ?? cs.primary;
    }

    final hasData = frac > 0.0;

    return AnimatedScale(
      duration: const Duration(milliseconds: 110),
      scale: _pressed ? 0.985 : 1.0,
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
          child: NestBlurCard(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                children: [
                  // фон на всю ячейку
                  Positioned.fill(child: ColoredBox(color: bgBase)),

                  // ✅ ЗАЛИВКА НА ВСЮ ЯЧЕЙКУ (не “середина”)
                  if (hasData)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          heightFactor: frac, // <-- вот это растягивает по всей ячейке
                          alignment: Alignment.bottomCenter,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  fillColor.withOpacity(0.95),
                                  fillColor.withOpacity(0.55),
                                  fillColor.withOpacity(0.18),
                                ],
                                stops: const [0.0, 0.75, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // sheen
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.white.withOpacity(0.20),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (widget.isToday)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                        ),
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
    );
  }
}
