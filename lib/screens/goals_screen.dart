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

class _GoalsView extends StatelessWidget {
  const _GoalsView();

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
    final days = m.daysInMonth;

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

          // хедер месяца
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(onPressed: m.prevMonth, icon: const Icon(Icons.chevron_left)),
                Expanded(
                  child: Center(
                    child: Text(
                      m.monthTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                IconButton(onPressed: m.nextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),
          ),

          // дни недели
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: const [
                _Weekday('S'), _Weekday('M'), _Weekday('T'), _Weekday('W'),
                _Weekday('T'), _Weekday('F'), _Weekday('S'),
              ],
            ),
          ),

          // календарь
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8,
              ),
              itemCount: days.length,
              itemBuilder: (_, i) {
                final d = days[i];
                final inMonth = m.isSameMonth(d);
                final now = DateTime.now();
                final isToday = now.year == d.year && now.month == d.month && now.day == d.day;

                if (d.day < 1 || !inMonth) return const SizedBox.shrink();

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

class _Weekday extends StatelessWidget {
  final String s;
  const _Weekday(this.s, {super.key});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(s, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.black54)),
      ),
    );
  }
}
