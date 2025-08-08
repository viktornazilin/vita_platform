import 'package:flutter/material.dart';
import '../services/goal_service.dart';
import '../models/life_block.dart';
import 'day_goals_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _goalService = GoalService();

  List<String> _lifeBlocks = [];
  String _selectedBlock = 'all'; // 'all' = показать все
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  Future<void> _loadBlocks() async {
    final blocks = await _goalService.getUserLifeBlocks();
    setState(() {
      _lifeBlocks = blocks;
    });
  }

  void _prevMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month + 1);
    });
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysCount = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = (first.weekday % 7); // делаем так, что воскресенье = 0
    final total = leadingEmpty + daysCount;
    final rows = (total / 7.0).ceil() * 7;

    return List.generate(rows, (i) {
      final dayOffset = i - leadingEmpty + 1;
      return DateTime(month.year, month.month, dayOffset);
    });
  }

  bool _isSameMonth(DateTime d) => d.month == _month.month && d.year == _month.year;

  void _openDay(DateTime date) {
    Navigator.of(context).push(
       MaterialPageRoute(
         builder: (_) => DayGoalsScreen(
           date: date,
           lifeBlock: _selectedBlock == 'all' ? null : _selectedBlock,
           availableBlocks: _lifeBlocks, // << добавь это
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(_month);
    final monthTitle = '${_month.year}, ${_month.month.toString().padLeft(2, '0')}';

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
          // Верхние чипы: блоки + "Все"
          SizedBox(
            height: 84,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              scrollDirection: Axis.horizontal,
              children: [
                _BlockChip(
                  label: 'Все',
                  selected: _selectedBlock == 'all',
                  onTap: () => setState(() => _selectedBlock = 'all'),
                ),
                ..._lifeBlocks.map((b) => _BlockChip(
                      label: getBlockLabel(
                        LifeBlock.values.firstWhere(
                          (e) => e.name == b,
                          orElse: () => LifeBlock.health,
                        ),
                      ),
                      selected: _selectedBlock == b,
                      onTap: () => setState(() => _selectedBlock = b),
                    )),
              ],
            ),
          ),

          // Хедер месяца
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                Expanded(
                  child: Center(
                    child: Text(
                      monthTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),
          ),

          // Дни недели
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: const [
                _Weekday('S'), _Weekday('M'), _Weekday('T'), _Weekday('W'),
                _Weekday('T'), _Weekday('F'), _Weekday('S'),
              ],
            ),
          ),

          // Календарь
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: days.length,
              itemBuilder: (_, i) {
                final d = days[i];
                final inMonth = _isSameMonth(d);
                final isToday = DateTime.now().year == d.year &&
                    DateTime.now().month == d.month &&
                    DateTime.now().day == d.day;

                if (d.day < 1 || !inMonth) {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  onTap: () => _openDay(d),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isToday ? Colors.teal.withOpacity(0.12) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Center(
                      child: Text(
                        d.day.toString(),
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
}

class _BlockChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _BlockChip({required this.label, required this.selected, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.teal,
        labelStyle: TextStyle(color: selected ? Colors.white : null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _Weekday extends StatelessWidget {
  final String s;
  const _Weekday(this.s, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(s, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.black54)),
      ),
    );
  }
}
