import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/reports_model.dart';

// вынесенные блоки
import '../widgets/sticky_header.dart';
import '../widgets/report_section_card.dart';
import '../widgets/report_stat_card.dart';
import '../widgets/report_empty_chart.dart';
import '../widgets/report_legend.dart';
import '../widgets/reports_charts.dart';
import '../widgets/expense_analytics.dart';
import '../widgets/report_metric_row.dart';

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
    final cs = Theme.of(context).colorScheme;

    if (model.loading) {
      return Scaffold(
        body: CustomScrollView(
          slivers: const [
            SliverAppBar.large(title: Text('Отчёты')),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }

    // данные из модели
    final goals = model.goalsInRange.toList();
    final doneByBlock = model.doneByBlock;
    final byDayHours = model.hoursByDay;
    final moodRatio = model.moodRatio;
    final totalHours = model.totalHours;
    final efficiency = model.efficiency;
    final planned = model.plannedHours;

    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () => context.read<ReportsModel>().loadAll(),
        child: CustomScrollView(
          slivers: [
            const SliverAppBar.large(title: Text('Отчёты'), centerTitle: false),

            // ── Липкий селектор периода и навигация
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeader(
                minExtent: 64,
                maxExtent: 72,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
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
                      IconButton(
                        tooltip: 'Назад',
                        onPressed: context.read<ReportsModel>().prev,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(model.rangeLabel, style: Theme.of(context).textTheme.titleSmall),
                      IconButton(
                        tooltip: 'Вперёд',
                        onPressed: context.read<ReportsModel>().next,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Сводка (карточки)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ReportStatCard(
                      title: 'Выполнено задач',
                      value: goals.where((g) => g.isCompleted).length.toString(),
                      icon: Icons.check_circle,
                    ),
                    ReportStatCard(
                      title: 'Затрачено часов',
                      value: totalHours.toStringAsFixed(1),
                      icon: Icons.timer_outlined,
                    ),
                    ReportStatCard(
                      title: 'Эффективность',
                      value: '${(efficiency * 100).round()}%',
                      icon: Icons.speed,
                    ),
                  ],
                ),
              ),
            ),

            // 1. Выполнено по блокам (Pie + легенда)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ReportSectionCard(
                  title: 'Выполнено по блокам',
                  child: (doneByBlock.isEmpty)
                      ? const ReportEmptyChart()
                      : Column(
                          children: [
                            SizedBox(
                              height: 240,
                              child: PieChart(
                                PieChartData(
                                  startDegreeOffset: -90,
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 44,
                                  pieTouchData: PieTouchData(enabled: true),
                                  sections: buildPieSectionsInt(context, doneByBlock),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ReportLegend(
                              entries: sortedEntriesInt(doneByBlock),
                              colors: palette(cs),
                              valueFormatter: (n) => n.toString(),
                              total: doneByBlock.values.fold<int>(0, (a, b) => a + b).toDouble(),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // 2. Часы по дням (Bar)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ReportSectionCard(
                  title: 'Затрачено часов по дням',
                  child: (byDayHours.isEmpty)
                      ? const ReportEmptyChart()
                      : SizedBox(
                          height: 260,
                          child: BarChart(
                            BarChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) =>
                                    FlLine(strokeWidth: 0.6, color: cs.outlineVariant),
                              ),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    final keys = byDayHours.keys.toList()..sort();
                                    final d = keys[group.x.toInt()];
                                    return BarTooltipItem(
                                      '${d.day}.${d.month}.${d.year}\n',
                                      TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      children: [
                                        TextSpan(text: '${rod.toY.toStringAsFixed(1)} ч'),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 36,
                                    getTitlesWidget: (v, _) => Text(
                                      v.toInt().toString(),
                                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (v, _) {
                                      final keys = byDayHours.keys.toList()..sort();
                                      final idx = v.toInt();
                                      if (idx < 0 || idx >= keys.length) return const SizedBox.shrink();
                                      final d = keys[idx];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          '${d.day}.${d.month}',
                                          style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: buildBarGroups(context, byDayHours),
                            ),
                          ),
                        ),
                ),
              ),
            ),

            // 3. Соотношение настроений (Pie + легенда)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ReportSectionCard(
                  title: 'Настроение по задачам/дням',
                  child: (moodRatio.isEmpty)
                      ? const ReportEmptyChart()
                      : Column(
                          children: [
                            SizedBox(
                              height: 240,
                              child: PieChart(
                                PieChartData(
                                  startDegreeOffset: -90,
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 44,
                                  sections: buildPieSectionsInt(context, moodRatio),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ReportLegend(
                              entries: sortedEntriesInt(moodRatio),
                              colors: palette(cs),
                              valueFormatter: (n) => n.toString(),
                              total: moodRatio.values.fold<int>(0, (a, b) => a + b).toDouble(),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // 4. Прогресс эффективности
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ReportSectionCard(
                  title: 'Эффективность периода',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(value: efficiency, minHeight: 10),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'План: ${planned.toStringAsFixed(1)} ч • Факт: ${totalHours.toStringAsFixed(1)} ч',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Доп. метрики
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ReportSectionCard(
                  title: 'Дополнительные метрики',
                  child: _extraMetrics(
                    context: context,
                    avgTimePerGoal: model.avgTimePerGoal,
                    percentOnTime: model.percentDoneOnTime,
                    top3: model.top3DaysByHours,
                  ),
                ),
              ),
            ),

            // -------------------- РАСХОДЫ --------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: ReportSectionCard(
                  title: 'Расходы за период',
                  child: FutureBuilder<ExpenseAnalytics>(
                    future: loadExpenseAnalytics(model.range.start, model.range.end),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
                      }
                      if (!snapshot.hasData) return const ReportEmptyChart();

                      final data = snapshot.data!;
                      if (data.total <= 0 && data.byDay.isEmpty) return const ReportEmptyChart();

                      final days = (model.range.end.difference(model.range.start).inDays).clamp(1, 366);
                      final avgExpense = days == 0 ? 0.0 : data.total / days;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Всего: ${data.total.toStringAsFixed(2)} €',
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            'Средний расход/день: ${avgExpense.toStringAsFixed(2)} €',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),

                          // Pie по категориям + легенда
                          SizedBox(
                            height: 240,
                            child: PieChart(
                              PieChartData(
                                startDegreeOffset: -90,
                                sections: buildExpensePieSections(context, data.byCategory),
                                sectionsSpace: 2,
                                centerSpaceRadius: 44,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ReportLegend(
                            entries: sortedEntriesDouble(data.byCategory),
                            colors: palette(cs),
                            valueFormatter: (n) => '${(n as double).toStringAsFixed(0)} €',
                            total: data.byCategory.values.fold<double>(0.0, (a, b) => a + b),
                          ),
                          const SizedBox(height: 16),

                          // Bar по дням
                          SizedBox(
                            height: 260,
                            child: BarChart(
                              BarChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (v) =>
                                      FlLine(strokeWidth: 0.6, color: cs.outlineVariant),
                                ),
                                titlesData: FlTitlesData(
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 36,
                                      getTitlesWidget: (v, _) => Text(
                                        v.toInt().toString(),
                                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: (v, _) {
                                        final keys = data.byDay.keys.toList()..sort();
                                        final idx = v.toInt();
                                        if (idx < 0 || idx >= keys.length) return const SizedBox();
                                        final d = keys[idx];
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(
                                            '${d.day}.${d.month}',
                                            style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: buildExpenseBarGroups(context, data.byDay),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            // ------------------ /РАСХОДЫ --------------------

            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        ),
      ),
    );
  }

  // ---------- extra metrics ----------
  Widget _extraMetrics({
    required BuildContext context,
    required double avgTimePerGoal,
    required int percentOnTime,
    required List<MapEntry<DateTime, double>> top3,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportMetricRow(label: 'Среднее время на задачу', value: _fmtAvgTime(avgTimePerGoal)),
        ReportMetricRow(label: '«В срок» (условно)', value: '$percentOnTime %'),
        const SizedBox(height: 8),
        Text('ТОП-3 продуктивных дня', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        ...top3.map((e) => Text(
              '• ${e.key.day}.${e.key.month}.${e.key.year}: ${e.value.toStringAsFixed(1)} ч',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            )),
      ],
    );
  }

  static String _fmtAvgTime(double v) => '${v.toStringAsFixed(1)} ч';
}
