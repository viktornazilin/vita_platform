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

  // ---------- helpers (неделя/месяц) ----------

  // Понедельник как первый день недели (ISO)
  DateTime _startOfWeek(DateTime d) {
    final wd = d.weekday; // 1..7 (Mon..Sun)
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: wd - 1));
  }

  List<DateTime> _weekDays(DateTime anchor) {
    final start = _startOfWeek(anchor);
    return List.generate(7, (i) => DateTime(start.year, start.month, start.day + i));
  }

  // ISO week number (Григориан)
  int _isoWeekNumber(DateTime date) {
    // четверг-сдвиг
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

  @override
  Widget build(BuildContext context) {
    final m = context.watch<GoalsCalendarModel>();

    // Дни для рендера
    final List<DateTime> daysList = _mode == _CalMode.week
        ? _weekDays(_anchor)
        : m.daysInMonth;

    // Заголовок
    final String headerTitle = _mode == _CalMode.week
        ? _headerWeek(_anchor)
        : _formatModelMonthTitle(m.monthTitle);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 10),
            const Text('Goals'),
          ],
        ),
      ),
      body: Column(
        children: [
          // блоки
          SizedBox(
            height: 84,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              scrollDirection: Axis.horizontal,
              children: [
                BlockChip(
                  label: 'Все',
                  selected: m.selectedBlock == 'all',
                  onTap: () => m.setSelectedBlock('all'),
                ),
                ...m.lifeBlocks.map((b) => BlockChip(
                      label: getBlockLabel(
                        LifeBlock.values.firstWhere(
                          (e) => e.name == b,
                          orElse: () => LifeBlock.health,
                        ),
                      ),
                      selected: m.selectedBlock == b,
                      onTap: () => m.setSelectedBlock(b),
                    )),
              ],
            ),
          ),

          // переключатель режимов + заголовок + стрелки
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // влево
                IconButton(
                  onPressed: () {
                    if (_mode == _CalMode.week) {
                      setState(() => _anchor = _anchor.subtract(const Duration(days: 7)));
                    } else {
                      m.prevMonth(); // модель сама обновит daysInMonth
                    }
                  },
                  icon: const Icon(Icons.chevron_left),
                ),

                // заголовок
                Expanded(
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          headerTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // переключатель
                      SegmentedButton<_CalMode>(
                        segments: const [
                          ButtonSegment(value: _CalMode.week, label: Text('Неделя')),
                          ButtonSegment(value: _CalMode.month, label: Text('Месяц')),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (v) {
                          final newMode = v.first;
                          setState(() {
                            _mode = newMode;
                            // при переходе в неделю — закрепим текущий "якорь" на сегодня
                            if (_mode == _CalMode.week) {
                              _anchor = DateTime.now();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // вправо
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

          // дни недели (Пн..Вс, ISO)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: const [
                _Weekday('Пн'), _Weekday('Вт'), _Weekday('Ср'),
                _Weekday('Чт'), _Weekday('Пт'), _Weekday('Сб'), _Weekday('Вс'),
              ],
            ),
          ),

          // календарь
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                // в недельном режиме делаем повыше ячейку
                childAspectRatio: _mode == _CalMode.week ? 7 / 6 : 1,
              ),
              itemCount: daysList.length,
              itemBuilder: (_, i) {
                final d = daysList[i];

                final inMonth = _mode == _CalMode.month
                    ? m.isSameMonth(d)
                    : true;

                final now = DateTime.now();
                final isToday =
                    now.year == d.year && now.month == d.month && now.day == d.day;

                // в месяце скрываем не-наш месяц (заполнительные дни)
                if (_mode == _CalMode.month && !inMonth) {
                  return const SizedBox.shrink();
                }

                return GestureDetector(
                  onTap: () => _openDay(context, d),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isToday ? Colors.teal.withOpacity(0.12) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Center(
                      child: Text(
                        '${d.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: inMonth ? Colors.black : Colors.black38,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Если модель уже форматирует "September 2025" — заменим на русское
  String _formatModelMonthTitle(String modelTitle) {
    // Попробуем распарсить, иначе просто вернём как есть
    // Ожидаем что-то вроде "September 2025"
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
}

class _Weekday extends StatelessWidget {
  final String s;
  const _Weekday(this.s);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          s,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: Colors.black54),
        ),
      ),
    );
  }
}
