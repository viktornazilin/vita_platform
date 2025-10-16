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

enum _CalMode { week, month }

class _GoalsView extends StatefulWidget {
  const _GoalsView();

  @override
  State<_GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<_GoalsView> {
  _CalMode _mode = _CalMode.week; // по умолчанию — текущая неделя
  DateTime _anchor = DateTime.now();

  // heatmap: день -> (сфера -> часы выполненных задач)
  Map<DateTime, Map<String, double>> _heat = {};
  double _targetHours = 8; // дневная норма из настроек/БД

  // цвета по сферам (подгони ключи под свои lifeBlock)
  static const Map<String, Color> _blockColors = {
    'health': Color(0xFF2E7D32),
    'career': Color.fromARGB(255, 96, 164, 241),
    'family': Color.fromARGB(255, 205, 108, 232),
    'relations': Color.fromARGB(255, 240, 45, 116),
    'education': Color.fromARGB(255, 99, 232, 218),
    'finance': Color.fromARGB(255, 245, 153, 4),
    'general': Color(0xFF546E7A),
  };

  // ---------- helpers (неделя/месяц) ----------
  DateTime _startOfWeek(DateTime d) {
    final wd = d.weekday; // 1..7 (Mon..Sun)
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
      'Январь','Февраль','Март','Апрель','Май','Июнь',
      'Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь'
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
        final block = (g.lifeBlock ?? 'general').trim().isEmpty ? 'general' : g.lifeBlock!;
        final hours = (g.spentHours is num) ? (g.spentHours as num).toDouble() : 0.0;
        final inner = map.putIfAbsent(DateUtils.dateOnly(day), () => <String, double>{});
        inner[block] = (inner[block] ?? 0) + hours;
      }
    }

    if (!mounted) return;
    setState(() => _heat = map);
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<GoalsCalendarModel>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mq = MediaQuery.of(context);
    final isCompact = mq.size.width < 600;
    const maxContentW = 900.0;
    final sidePad = mq.size.width > maxContentW ? (mq.size.width - maxContentW) / 2 : 0.0;

    final List<DateTime> daysList = _mode == _CalMode.week
        ? _weekDays(_anchor)
        : m.daysInMonth;

    final String headerTitle = _mode == _CalMode.week
        ? _headerWeek(_anchor)
        : _formatModelMonthTitle(m.monthTitle);

    final weekdayFont = isCompact ? textTheme.titleSmall : textTheme.titleMedium;
    final weekCellHeight = isCompact ? 72.0 : 64.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // компактная шапка
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            title: const Text('Цели'),
            actions: [
              IconButton(
                tooltip: 'Сегодня',
                onPressed: () async {
                  setState(() => _anchor = DateTime.now());
                  if (_mode == _CalMode.week) await _loadWeekHeat();
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
                        ...m.lifeBlocks.map((b) => Padding(
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
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // заголовок периода + переключатель
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12 + sidePad, 8, 12 + sidePad, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      if (_mode == _CalMode.week) {
                        setState(() => _anchor = _anchor.subtract(const Duration(days: 7)));
                        await _loadWeekHeat();
                      } else {
                        m.prevMonth();
                      }
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          headerTitle,
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        SegmentedButton<_CalMode>(
                          segments: const [
                            ButtonSegment(value: _CalMode.week, label: Text('Неделя'), icon: Icon(Icons.view_week)),
                            ButtonSegment(value: _CalMode.month, label: Text('Месяц'), icon: Icon(Icons.calendar_month)),
                          ],
                          selected: {_mode},
                          onSelectionChanged: (v) async {
                            final newMode = v.first;
                            setState(() => _mode = newMode);
                            if (newMode == _CalMode.week) {
                              setState(() => _anchor = DateTime.now());
                              await _loadWeekHeat();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (_mode == _CalMode.week) {
                        setState(() => _anchor = _anchor.add(const Duration(days: 7)));
                        await _loadWeekHeat();
                      } else {
                        m.nextMonth();
                      }
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),

          // заголовок дней недели
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12 + sidePad, vertical: 6),
              child: Row(
                children: [
                  _Weekday('Пн', style: weekdayFont),
                  _Weekday('Вт', style: weekdayFont),
                  _Weekday('Ср', style: weekdayFont),
                  _Weekday('Чт', style: weekdayFont),
                  _Weekday('Пт', style: weekdayFont),
                  _Weekday('Сб', style: weekdayFont),
                  _Weekday('Вс', style: weekdayFont),
                ],
              ),
            ),
          ),

          // сетка календаря
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 12 + sidePad, vertical: 8),
            sliver: SliverGrid.builder(
              gridDelegate: _mode == _CalMode.week
                  ? SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: weekCellHeight,
                    )
                  : SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
              itemCount: (_mode == _CalMode.week ? _weekDays(_anchor) : daysList).length,
              itemBuilder: (_, i) {
                final d = _mode == _CalMode.week ? _weekDays(_anchor)[i] : daysList[i];
                final inMonth = _mode == _CalMode.month ? m.isSameMonth(d) : true;

                final now = DateTime.now();
                final isToday = now.year == d.year && now.month == d.month && now.day == d.day;
                final isWeekend = d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;

                if (_mode == _CalMode.month && !inMonth) return const SizedBox.shrink();

                final heat = _mode == _CalMode.week ? _heat[DateUtils.dateOnly(d)] : null;

                return _DayCell(
                  date: d,
                  isToday: isToday,
                  isWeekend: isWeekend,
                  inMonth: inMonth,
                  largeText: isCompact,
                  onTap: () => _openDay(context, d),

                  // heat
                  heat: heat,
                  targetHours: _targetHours,
                  colorsByBlock: _blockColors,
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
        ],
      ),
    );
  }
}

// ---------- Вспомогательные виджеты ----------

class _Weekday extends StatelessWidget {
  final String s;
  final TextStyle? style;
  const _Weekday(this.s, {this.style});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
      child: Center(
        child: Text(
          s,
          style: (style ?? Theme.of(context).textTheme.labelMedium)?.copyWith(color: color),
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
  final bool largeText;
  final VoidCallback onTap;

  // heat:
  final Map<String, double>? heat; // сфера -> часы
  final double targetHours;
  final Map<String, Color> colorsByBlock;

  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isWeekend,
    required this.inMonth,
    required this.onTap,
    this.largeText = false,
    this.heat,
    this.targetHours = 8,
    this.colorsByBlock = const {},
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _pressed = false;

  List<_FillSegment> _segmentsFromHeat(
    Map<String, double>? heat,
    double target,
    Map<String, Color> colorsByBlock,
    Color fallback,
  ) {
    if (heat == null || heat.isEmpty || target <= 0) return const [];

    // сортируем по убыванию часов, чтобы крупные куски были снизу
    final entries = heat.entries
        .where((e) => (e.value) > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<_FillSegment> out = [];
    double remaining = 1.0; // доля «стакана», которую можно заполнить

    for (final e in entries) {
      if (remaining <= 0) break;
      final color = colorsByBlock[e.key] ?? fallback;
      final frac = (e.value / target).clamp(0.0, remaining);
      if (frac > 0) {
        out.add(_FillSegment(color: color, fraction: frac));
        remaining -= frac;
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final surface = cs.surface;
    final bgBase = widget.isToday ? cs.primaryContainer.withOpacity(0.55) : surface.withOpacity(0.90);
    final borderColor = widget.isToday ? cs.primary.withOpacity(0.6) : cs.outlineVariant.withOpacity(0.6);

    final labelColor = !widget.inMonth
        ? cs.onSurfaceVariant.withOpacity(0.5)
        : widget.isWeekend
            ? cs.onSurface.withOpacity(0.85)
            : cs.onSurface;

    final radius = 12.0;

    // готовим «слои» заливки как стакан
    final segments = _segmentsFromHeat(
      widget.heat,
      widget.targetHours,
      widget.colorsByBlock,
      cs.primary,
    );

    final hasData = segments.isNotEmpty;

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
                painter: _GlassFillPainter(
                  background: bgBase,
                  rimColor: widget.isToday ? cs.primaryContainer.withOpacity(0.35) : null,
                  segments: segments,
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
                        child: Icon(Icons.water_drop, size: 12, color: cs.onSurfaceVariant.withOpacity(0.7)),
                      ),
                    Center(
                      child: Text(
                        '${widget.date.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: widget.largeText ? 18 : 16,
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

class _FillSegment {
  final Color color;
  final double fraction; // 0..1 — доля высоты плитки
  const _FillSegment({required this.color, required this.fraction});
}

/// Рисует «стакан» дня: фон + сегменты снизу вверх без смешивания цветов.
class _GlassFillPainter extends CustomPainter {
  final Color background;
  final Color? rimColor; // лёгкий верхний отблеск для «стекла»
  final List<_FillSegment> segments;

  const _GlassFillPainter({
    required this.background,
    required this.segments,
    this.rimColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // фон
    final bg = Paint()..color = background;
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12));
    canvas.drawRRect(rrect, bg);

    // заполняем снизу вверх, сегменты идут последовательными блоками
    double filled = 0.0;
    for (final s in segments) {
      if (s.fraction <= 0) continue;
      final h = (s.fraction * size.height).clamp(0.0, size.height - filled);
      final top = size.height - filled - h;
      final rect = Rect.fromLTWH(0, top, size.width, h);
      final paint = Paint()..color = s.color;
      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawRect(rect, paint);

      // тонкая разделительная линия между сегментами (как слой жидкости)
      final divider = Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(0, top), Offset(size.width, top), divider);

      canvas.restore();
      filled += h;
      if (filled >= size.height) break;
    }

    // лёгкий «блик» у кромки (визуально как стекло)
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
  bool shouldRepaint(covariant _GlassFillPainter oldDelegate) {
    if (background != oldDelegate.background || rimColor != oldDelegate.rimColor) return true;
    if (segments.length != oldDelegate.segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      if (segments[i].color != oldDelegate.segments[i].color ||
          segments[i].fraction != oldDelegate.segments[i].fraction) {
        return true;
      }
    }
    return false;
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox(height: extent, child: child);

  @override
  bool shouldRebuild(covariant _StickyHeader oldDelegate) =>
      extent != oldDelegate.extent || child != oldDelegate.child;
}
