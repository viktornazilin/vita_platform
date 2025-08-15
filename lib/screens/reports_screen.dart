import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/reports_model.dart';
import '../main.dart'; // dbRepo

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsModel()..loadAll(),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReportsModel>();

    if (model.loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Отчёты')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // данные из модели
    final goals = model.goalsInRange.toList();
    final moods = model.moodsInRange.toList();
    final doneByBlock = model.doneByBlock;
    final byDayHours = model.hoursByDay;
    final moodRatio = model.moodRatio;
    final totalHours = model.totalHours;
    final efficiency = model.efficiency;
    final planned = model.plannedHours;

    return Scaffold(
      appBar: AppBar(title: const Text('Отчёты')),
      body: RefreshIndicator(
        onRefresh: () => context.read<ReportsModel>().loadAll(),
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
                  selected: {model.period},
                  onSelectionChanged: (s) => context.read<ReportsModel>().setPeriod(s.first),
                ),
                const Spacer(),
                IconButton(onPressed: context.read<ReportsModel>().prev, icon: const Icon(Icons.chevron_left)),
                Text(model.rangeLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                IconButton(onPressed: context.read<ReportsModel>().next, icon: const Icon(Icons.chevron_right)),
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
                          sections: _buildPieSectionsInt(doneByBlock),
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
                          sections: _buildPieSectionsInt(moodRatio),
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
              child: _extraMetrics(
                avgTimePerGoal: model.avgTimePerGoal,
                percentOnTime: model.percentDoneOnTime,
                top3: model.top3DaysByHours,
              ),
            ),

            // -------------------- РАСХОДЫ (новая логика) --------------------
            _SectionCard(
              title: 'Расходы за период',
              child: FutureBuilder<_ExpenseAnalytics>(
                future: _loadExpenseAnalytics(model.range.start, model.range.end),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
                  }
                  if (!snapshot.hasData) return const _EmptyChart();

                  final data = snapshot.data!;
                  if (data.total <= 0 && data.byDay.isEmpty) return const _EmptyChart();

                  final days = (model.range.end.difference(model.range.start).inDays).clamp(1, 366);
                  final avgExpense = days == 0 ? 0.0 : data.total / days;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Всего: ${data.total.toStringAsFixed(2)} ₽',
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
                            sections: _buildExpensePieSections(data.byCategory),
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
                                sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, meta) {
                                    final keys = data.byDay.keys.toList()..sort();
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
                            borderData: FlBorderData(show: false),
                            barGroups: _buildExpenseBarGroups(data.byDay),
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

  /// Грузим расходы за период из новой модели (transactions + categories).
  Future<_ExpenseAnalytics> _loadExpenseAnalytics(DateTime from, DateTime to) async {
    // 1) транзакции в периоде (эксклюзивная верхняя граница)
    final txs = await dbRepo.listTransactionsBetween(from, to);
    final expenses = txs.where((t) => t.kind == 'expense');

    // 2) словарь категорий id->name (только расходные)
    final expCats = await dbRepo.listCategories(kind: 'expense');
    final catNameById = {for (final c in expCats) c.id: c.name};

    // 3) агрегаты
    double total = 0;
    final Map<String, double> byCategory = {};
    final Map<DateTime, double> byDay = {};

    for (final t in expenses) {
      total += t.amount;

      final catName = catNameById[t.categoryId] ?? 'Прочее';
      byCategory[catName] = (byCategory[catName] ?? 0) + t.amount;

      final d = DateTime(t.ts.year, t.ts.month, t.ts.day);
      byDay[d] = (byDay[d] ?? 0) + t.amount;
    }

    return _ExpenseAnalytics(total: total, byCategory: byCategory, byDay: byDay);
  }

  // ---------- UI helpers (перенесены из исходника, без изменений логики) ----------
  List<PieChartSectionData> _buildPieSectionsInt(Map<String, int> data) {
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
          child: Text(e.key, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
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
        barRods: [BarChartRodData(toY: v, width: 14, borderRadius: BorderRadius.circular(4))],
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
          child: Text(e.key, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
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
        barRods: [BarChartRodData(toY: v, width: 14, borderRadius: BorderRadius.circular(4))],
      );
    });
  }
  // --------- /расходы ----------

  Widget _extraMetrics({
    required double avgTimePerGoal,
    required int percentOnTime,
    required List<MapEntry<DateTime, double>> top3,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricRow(label: 'Среднее время на задачу', value: '${avgTimePerGoal.toStringAsFixed(1)} ч'),
        _MetricRow(label: 'Процент «в срок» (условно)', value: '$percentOnTime %'),
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

// ---- UI building blocks (как в исходнике) ----
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
      child: Center(child: Text('Недостаточно данных')),
    );
  }
}

/// Внутренняя структура для секции «Расходы»
class _ExpenseAnalytics {
  final double total;
  final Map<String, double> byCategory; // имя категории -> сумма
  final Map<DateTime, double> byDay;    // день -> сумма

  _ExpenseAnalytics({
    required this.total,
    required this.byCategory,
    required this.byDay,
  });
}
