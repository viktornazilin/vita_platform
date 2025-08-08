import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/goal.dart';
import '../models/mood.dart';
import '../services/goal_service.dart';
import '../main.dart'; // dbRepo

enum ReportPeriod { day, week, month }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _goalService = GoalService();

  ReportPeriod _period = ReportPeriod.month;
  DateTime _anchor = DateTime.now();

  bool _loading = true;
  List<Goal> _allGoals = [];
  List<Mood> _allMoods = [];
  double _targetHours = 14;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final goals = await _goalService.fetchGoals();
      final moods = await dbRepo.fetchMoods(limit: 120);
      final target = await _goalService.getTargetHours();

      setState(() {
        _allGoals = goals;
        _allMoods = moods;
        _targetHours = target;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  
  void _prev() => setState(() {
        switch (_period) {
          case ReportPeriod.day:
            _anchor = _anchor.subtract(const Duration(days: 1));
            break;
          case ReportPeriod.week:
            _anchor = _anchor.subtract(const Duration(days: 7));
            break;
          case ReportPeriod.month:
            _anchor = DateTime(_anchor.year, _anchor.month - 1, 1);
            break;
        }
      });

  void _next() => setState(() {
        switch (_period) {
          case ReportPeriod.day:
            _anchor = _anchor.add(const Duration(days: 1));
            break;
          case ReportPeriod.week:
            _anchor = _anchor.add(const Duration(days: 7));
            break;
          case ReportPeriod.month:
            _anchor = DateTime(_anchor.year, _anchor.month + 1, 1);
            break;
        }
      });

  DateTimeRange _range() {
    switch (_period) {
      case ReportPeriod.day:
        final start = DateTime(_anchor.year, _anchor.month, _anchor.day);
        final end = start.add(const Duration(days: 1));
        return DateTimeRange(start: start, end: end);
      case ReportPeriod.week:
        final start = _anchor.subtract(Duration(days: (_anchor.weekday % 7))); // воскресенье — 0
        final s = DateTime(start.year, start.month, start.day);
        return DateTimeRange(start: s, end: s.add(const Duration(days: 7)));
      case ReportPeriod.month:
        final s = DateTime(_anchor.year, _anchor.month, 1);
        final e = DateTime(_anchor.year, _anchor.month + 1, 1);
        return DateTimeRange(start: s, end: e);
    }
  }

  String _rangeLabel() {
    switch (_period) {
      case ReportPeriod.day:
        return '${_anchor.day.toString().padLeft(2, '0')}.${_anchor.month.toString().padLeft(2, '0')}.${_anchor.year}';
      case ReportPeriod.week:
        final r = _range();
        return '${r.start.day}.${r.start.month} — ${r.end.subtract(const Duration(days: 1)).day}.${r.end.month}';
      case ReportPeriod.month:
        return '${_anchor.year}.${_anchor.month.toString().padLeft(2, '0')}';
    }
  }

  // ---- агрегаты по диапазону
  Iterable<Goal> _goalsInRange() {
    final r = _range();
    return _allGoals.where((g) =>
        g.deadline.isAfter(r.start.subtract(const Duration(microseconds: 1))) &&
        g.deadline.isBefore(r.end));
  }

  Iterable<Mood> _moodsInRange() {
    final r = _range();
    return _allMoods.where((m) =>
        m.date.isAfter(r.start.subtract(const Duration(microseconds: 1))) &&
        m.date.isBefore(r.end));
  }

  @override
  Widget build(BuildContext context) {
    final goals = _goalsInRange().toList();
    final moods = _moodsInRange().toList();

    // 1) Выполнено по блокам
    final doneByBlock = groupBy(
      goals.where((g) => g.isCompleted),
      (Goal g) => g.lifeBlock.isEmpty ? 'unknown' : g.lifeBlock,
    ).map((k, v) => MapEntry(k, v.length));

    // 2) Часы по дням (для барчарта)
    final byDayHours = groupBy(
      goals,
      (Goal g) => DateTime(g.deadline.year, g.deadline.month, g.deadline.day),
    ).map((d, list) => MapEntry(
          d,
          list.fold<double>(0.0, (s, g) => s + g.spentHours),
        ));

    // 3) Соотношение эмоций
    final moodRatio = groupBy(
      moods,
      (Mood m) => m.emoji,
    ).map((k, v) => MapEntry(k, v.length));

    // 4) Эффективность
    final totalHours = goals.fold<double>(0.0, (s, g) => s + g.spentHours);
    final planned = (_period == ReportPeriod.day)
        ? _targetHours
        : (_period == ReportPeriod.week)
            ? _targetHours * 7
            : _targetHours * DateUtils.getDaysInMonth(_anchor.year, _anchor.month);
    final double efficiency = planned == 0 ? 0.0 : (totalHours / planned).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчёты'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Переключатель периода + навигация
                  Row(
                    children: [
                      SegmentedButton<ReportPeriod>(
                        segments: const [
                          ButtonSegment(value: ReportPeriod.day, label: Text('День')),
                          ButtonSegment(value: ReportPeriod.week, label: Text('Неделя')),
                          ButtonSegment(value: ReportPeriod.month, label: Text('Месяц')),
                        ],
                        selected: <ReportPeriod>{_period},
                        onSelectionChanged: (s) => setState(() => _period = s.first),
                      ),
                      const Spacer(),
                      IconButton(onPressed: _prev, icon: const Icon(Icons.chevron_left)),
                      Text(_rangeLabel(), style: const TextStyle(fontWeight: FontWeight.w600)),
                      IconButton(onPressed: _next, icon: const Icon(Icons.chevron_right)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Короткая сводка
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatCard(
                        title: 'Выполнено задач',
                        value: goals.where((g) => g.isCompleted).length.toString(),
                        icon: Icons.check_circle,
                      ),
                      _StatCard(
                        title: 'Затрачено часов',
                        value: totalHours.toStringAsFixed(1),
                        icon: Icons.timer,
                      ),
                      _StatCard(
                        title: 'Эффективность',
                        value: '${(efficiency * 100).round()}%',
                        icon: Icons.speed,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 1. Выполнено по блокам
                  _SectionCard(
                    title: 'Выполнено по блокам',
                    child: (doneByBlock.isEmpty)
                        ? const _EmptyChart()
                        : SizedBox(
                            height: 220,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 36,
                                sections: _buildPieSections(doneByBlock),
                              ),
                            ),
                          ),
                  ),

                  // 2. Часы по дням (bar)
                  _SectionCard(
                    title: 'Затрачено часов по дням',
                    child: (byDayHours.isEmpty)
                        ? const _EmptyChart()
                        : SizedBox(
                            height: 220,
                            child: BarChart(
                              BarChartData(
                                gridData: FlGridData(show: true),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (v, meta) {
                                        final keys = byDayHours.keys.toList()..sort();
                                        final idx = v.toInt();
                                        if (idx < 0 || idx >= keys.length) return const SizedBox();
                                        final d = keys[idx];
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text('${d.day}.${d.month}', style: const TextStyle(fontSize: 10)),
                                        );
                                      },
                                      reservedSize: 28,
                                    ),
                                  ),
                                ),
                                barGroups: _buildBarGroups(byDayHours),
                              ),
                            ),
                          ),
                  ),

                  // 3. Соотношение настроений
                  _SectionCard(
                    title: 'Настроение по задачам/дням',
                    child: (moodRatio.isEmpty)
                        ? const _EmptyChart()
                        : SizedBox(
                            height: 220,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 36,
                                sections: _buildPieSections(moodRatio),
                              ),
                            ),
                          ),
                  ),

                  // 4. Прогресс эффективности
                  _SectionCard(
                    title: 'Эффективность периода',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(value: efficiency),
                        const SizedBox(height: 8),
                        Text(
                          'План: ${planned.toStringAsFixed(1)} ч • Факт: ${totalHours.toStringAsFixed(1)} ч',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Доп. метрики
                  _SectionCard(
                    title: 'Дополнительные метрики',
                    child: _extraMetrics(goals),
                  ),

                  // -------------------- РАСХОДЫ --------------------
                  _SectionCard(
                    title: 'Расходы за период',
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      // Ожидается dbRepo.fetchExpenses()
                      future: dbRepo.fetchExpenses(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const _EmptyChart();
                        }

                        final r = _range();
                        final expenses = snapshot.data!;
                        final inRange = expenses.where((e) {
                          final d = e['date'] as DateTime;
                          return d.isAfter(r.start.subtract(const Duration(microseconds: 1))) &&
                              d.isBefore(r.end);
                        }).toList();

                        if (inRange.isEmpty) return const _EmptyChart();

                        final totalExpense =
                            inRange.fold<double>(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
                        final days = (r.end.difference(r.start).inDays).clamp(1, 365);
                        final avgExpense = totalExpense / days;

                        // по категориям
                        final byCategory = groupBy(inRange, (e) => e['category'] as String)
                            .map((k, v) => MapEntry(
                                  k,
                                  v.fold<double>(0.0, (s, e) => s + (e['amount'] as num).toDouble()),
                                ));

                        // по дням
                        final byDayExpense = groupBy(inRange, (e) {
                          final d = e['date'] as DateTime;
                          return DateTime(d.year, d.month, d.day);
                        }).map((d, list) => MapEntry(
                              d,
                              list.fold<double>(
                                  0.0, (s, e) => s + (e['amount'] as num).toDouble()),
                            ));

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Всего: ${totalExpense.toStringAsFixed(2)} ₽',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Средний расход/день: ${avgExpense.toStringAsFixed(2)} ₽',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),

                            // Pie по категориям
                            SizedBox(
                              height: 220,
                              child: PieChart(
                                PieChartData(
                                  sections: _buildExpensePieSections(byCategory),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 36,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Bar по дням
                            SizedBox(
                              height: 220,
                              child: BarChart(
                                BarChartData(
                                  gridData: FlGridData(show: true),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: true, reservedSize: 36),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (v, meta) {
                                          final keys = byDayExpense.keys.toList()..sort();
                                          final idx = v.toInt();
                                          if (idx < 0 || idx >= keys.length) {
                                            return const SizedBox();
                                          }
                                          final d = keys[idx];
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              '${d.day}.${d.month}',
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                          );
                                        },
                                        reservedSize: 28,
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: _buildExpenseBarGroups(byDayExpense),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // ------------------ /РАСХОДЫ --------------------
                ],
              ),
            ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> data) {
    final total = data.values.fold<int>(0, (s, v) => s + v);
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return List.generate(entries.length, (i) {
      final e = entries[i];
      final pct = total == 0 ? 0.0 : (e.value / total) * 100;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${pct.toStringAsFixed(0)}%',
        radius: 70,
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            e.key,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
        badgePositionPercentageOffset: 1.3,
      );
    });
  }

  List<BarChartGroupData> _buildBarGroups(Map<DateTime, double> data) {
    final keys = data.keys.toList()..sort();
    return List.generate(keys.length, (i) {
      final v = data[keys[i]] ?? 0.0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: v,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    });
  }

  // --------- расходы: помощники для графиков ----------
  List<PieChartSectionData> _buildExpensePieSections(Map<String, double> data) {
    final total = data.values.fold<double>(0.0, (s, v) => s + v);
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return List.generate(entries.length, (i) {
      final e = entries[i];
      final pct = total == 0 ? 0.0 : (e.value / total) * 100.0;
      return PieChartSectionData(
        value: e.value,
        title: '${pct.toStringAsFixed(0)}%',
        radius: 70,
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            e.key,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
        badgePositionPercentageOffset: 1.3,
      );
    });
  }

  List<BarChartGroupData> _buildExpenseBarGroups(Map<DateTime, double> data) {
    final keys = data.keys.toList()..sort();
    return List.generate(keys.length, (i) {
      final v = data[keys[i]] ?? 0.0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: v,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    });
  }
  // --------- /расходы ---------

  Widget _extraMetrics(List<Goal> goals) {
    if (goals.isEmpty) return const _EmptyChart();

    final completed = goals.where((g) => g.isCompleted).toList();
    final avgTime =
        goals.isEmpty ? 0.0 : goals.fold<double>(0, (s, g) => s + g.spentHours) / goals.length;
    final doneOnTime = completed.where((g) {
      // пока считаем «в срок», если deadline >= сегодня (нет фактической даты выполнения)
      return g.deadline.isAfter(DateTime.now());
    }).length;
    final pctOnTime = completed.isEmpty ? 0 : (doneOnTime / completed.length * 100).round();

    // топ-3 дни по часам
    final byDay = groupBy(
      goals,
      (Goal g) => DateTime(g.deadline.year, g.deadline.month, g.deadline.day),
    ).entries
        .map((e) => MapEntry(e.key, e.value.fold<double>(0, (s, g) => s + g.spentHours)))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top3 = byDay.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricRow(label: 'Среднее время на задачу', value: '${avgTime.toStringAsFixed(1)} ч'),
        _MetricRow(label: 'Процент «в срок» (условно)', value: '$pctOnTime %'),
        const SizedBox(height: 6),
        const Text('ТОП-3 продуктивных дня:', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...top3.map((e) => Text(
              '• ${e.key.day}.${e.key.month}: ${e.value.toStringAsFixed(1)} ч',
              style: const TextStyle(color: Colors.black87),
            )),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
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

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(
        child: Text('Недостаточно данных'),
      ),
    );
  }
}
