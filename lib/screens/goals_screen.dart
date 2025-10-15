import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goals_calendar_model.dart';
import '../models/life_block.dart';
import '../widgets/block_chip.dart';
import 'day_goals_screen.dart';

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
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return months[m - 1];
  }

  String _headerWeek(DateTime anchor) {
    return '${_rusMonth(anchor.month)} ${anchor.year}, неделя ${_isoWeekNumber(anchor)}';
  }

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

    // размеры/типографика под компакт/широкий
    final weekdayFont = isCompact ? textTheme.titleSmall : textTheme.titleMedium;
    final gridVSpacing = isCompact ? 10.0 : 8.0;
    final gridHSpacing = isCompact ? 10.0 : 8.0;
    // делаем клетки недели выше (удобные клики)
    final weekCellHeight = isCompact ? 64.0 : 56.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // компактная шапка (меньше, чем large)
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            title: const Text('Цели'),
            actions: [
              IconButton(
                tooltip: 'Сегодня',
                onPressed: () => setState(() => _anchor = DateTime.now()),
                icon: const Icon(Icons.today),
              ),
            ],
          ),

          // --- блоки (чипы) — «прилипают»; высота фиксирована = min = max (без layoutExtent багов)
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

          // --- заголовок периода + стрелки + переключатель
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12 + sidePad, 8, 12 + sidePad, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_mode == _CalMode.week) {
                        setState(() => _anchor = _anchor.subtract(const Duration(days: 7)));
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
                          onSelectionChanged: (v) {
                            final newMode = v.first;
                            setState(() {
                              _mode = newMode;
                              if (_mode == _CalMode.week) _anchor = DateTime.now();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_mode == _CalMode.week) {
                        setState(() => _anchor = _anchor.add(const Duration(days: 7)));
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

          // --- дни недели (Пн..Вс), крупнее и с боковыми полями
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

          // --- календарная сетка (адаптивные интервалы; в неделе — фиксированная высота клетки)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 12 + sidePad, vertical: 8),
            sliver: SliverGrid.builder(
              gridDelegate: _mode == _CalMode.week
                  ? SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: gridVSpacing,
                      crossAxisSpacing: gridHSpacing,
                      mainAxisExtent: weekCellHeight, // делаем кликабельнее
                    )
                  : SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: gridVSpacing,
                      crossAxisSpacing: gridHSpacing,
                      childAspectRatio: 1, // квадраты в месяце
                    ),
              itemCount: daysList.length,
              itemBuilder: (_, i) {
                final d = daysList[i];
                final inMonth = _mode == _CalMode.month ? m.isSameMonth(d) : true;

                final now = DateTime.now();
                final isToday = now.year == d.year && now.month == d.month && now.day == d.day;
                final isWeekend = d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;

                if (_mode == _CalMode.month && !inMonth) {
                  return const SizedBox.shrink();
                }

                return _DayCell(
                  date: d,
                  isToday: isToday,
                  isWeekend: isWeekend,
                  inMonth: inMonth,
                  largeText: isCompact, // крупнее цифры на телефоне
                  onTap: () => _openDay(context, d),
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

  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isWeekend,
    required this.inMonth,
    required this.onTap,
    this.largeText = false,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final surface = scheme.surface;
    final outline = scheme.outlineVariant;
    final onSurface = scheme.onSurface;
    final onSurfaceWeak = scheme.onSurfaceVariant;

    final bgColor = widget.isToday
        ? scheme.primaryContainer.withOpacity(0.55)
        : surface.withOpacity(0.90);

    final borderColor = widget.isToday
        ? scheme.primary.withOpacity(0.6)
        : outline.withOpacity(0.6);

    final labelColor = !widget.inMonth
        ? onSurfaceWeak.withOpacity(0.5)
        : widget.isWeekend
            ? onSurface.withOpacity(0.85)
            : onSurface;

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
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: bgColor,
              border: Border.all(color: borderColor),
              boxShadow: [
                if (!widget.isToday)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor,
                  surface.withOpacity(widget.isToday ? 0.90 : 0.85),
                ],
              ),
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
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
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
    );
  }
}

// «прилипшая» шапка для SliverPersistentHeader — безопасная версия
class _StickyHeader extends SliverPersistentHeaderDelegate {
  final double extent;
  final Widget child;
  _StickyHeader({required this.extent, required this.child});

  @override
  double get minExtent => extent;
  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox(
        height: extent,
        child: child,
      );

  @override
  bool shouldRebuild(covariant _StickyHeader oldDelegate) =>
      extent != oldDelegate.extent || child != oldDelegate.child;
}
