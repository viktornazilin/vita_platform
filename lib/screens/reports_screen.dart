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
              delegate: _StickyHeader(
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
                    _StatCard(
                      title: 'Выполнено задач',
                      value: goals.where((g) => g.isCompleted).length.toString(),
                      icon: Icons.check_circle,
                    ),
                    _StatCard(
                      title: 'Затрачено часов',
                      value: totalHours.toStringAsFixed(1),
                      icon: Icons.timer_outlined,
                    ),
                    _StatCard(
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
                child: _SectionCard(
                  title: 'Выполнено по блокам',
                  child: (doneByBlock.isEmpty)
                      ? const _EmptyChart()
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
                                  sections: _buildPieSectionsInt(context, doneByBlock),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _Legend(
                              entries: _sortedEntriesInt(doneByBlock),
                              colors: _palette(cs),
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
                child: _SectionCard(
                  title: 'Затрачено часов по дням',
                  child: (byDayHours.isEmpty)
                      ? const _EmptyChart()
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
                              barGroups: _buildBarGroups(context, byDayHours),
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
                child: _SectionCard(
                  title: 'Настроение по задачам/дням',
                  child: (moodRatio.isEmpty)
                      ? const _EmptyChart()
                      : Column(
                          children: [
                            SizedBox(
                              height: 240,
                              child: PieChart(
                                PieChartData(
                                  startDegreeOffset: -90,
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 44,
                                  sections: _buildPieSectionsInt(context, moodRatio),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _Legend(
                              entries: _sortedEntriesInt(moodRatio),
                              colors: _palette(cs),
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
                child: _SectionCard(
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
                child: _SectionCard(
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
                child: _SectionCard(
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
                          Text('Всего: ${data.total.toStringAsFixed(2)} ₽',
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            'Средний расход/день: ${avgExpense.toStringAsFixed(2)} ₽',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),

                          // Pie по категориям + легенда
                          SizedBox(
                            height: 240,
                            child: PieChart(
                              PieChartData(
                                startDegreeOffset: -90,
                                sections: _buildExpensePieSections(context, data.byCategory),
                                sectionsSpace: 2,
                                centerSpaceRadius: 44,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Legend(
                            entries: _sortedEntriesDouble(data.byCategory),
                            colors: _palette(cs),
                            valueFormatter: (n) => '${(n as double).toStringAsFixed(0)} ₽',
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
                                barGroups: _buildExpenseBarGroups(context, data.byDay),
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

  /// Грузим расходы за период
  Future<_ExpenseAnalytics> _loadExpenseAnalytics(DateTime from, DateTime to) async {
    final txs = await dbRepo.listTransactionsBetween(from, to);
    final expenses = txs.where((t) => t.kind == 'expense');

    final expCats = await dbRepo.listCategories(kind: 'expense');
    final catNameById = {for (final c in expCats) c.id: c.name};

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

  // ---------- helpers: PIE (int map) ----------
  List<PieChartSectionData> _buildPieSectionsInt(
      BuildContext context, Map<String, int> data) {
    final cs = Theme.of(context).colorScheme;
    final palette = _palette(cs);
    final total = data.values.fold<int>(0, (s, v) => s + v);
    final entries = _sortedEntriesInt(data);

    return List.generate(entries.length, (i) {
      final e = entries[i];
      final pct = total == 0 ? 0.0 : (e.value / total) * 100;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${pct.toStringAsFixed(0)}%',
        radius: 70,
        color: palette[i % palette.length],
        titleStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        badgeWidget: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(e.key,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurface)),
        ),
        badgePositionPercentageOffset: 1.25,
      );
    });
  }

  // ---------- helpers: BAR ----------
  List<BarChartGroupData> _buildBarGroups(
      BuildContext context, Map<DateTime, double> data) {
    final cs = Theme.of(context).colorScheme;
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
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.primary.withOpacity(0.95), cs.primary.withOpacity(0.6)],
            ),
          ),
        ],
      );
    });
  }

  // ---------- расходы: PIE & BAR ----------
  List<PieChartSectionData> _buildExpensePieSections(
      BuildContext context, Map<String, double> data) {
    final cs = Theme.of(context).colorScheme;
    final palette = _palette(cs);
    final total = data.values.fold<double>(0.0, (s, v) => s + v);
    final entries = _sortedEntriesDouble(data);

    return List.generate(entries.length, (i) {
      final e = entries[i];
      final pct = total == 0 ? 0.0 : (e.value / total) * 100.0;
      return PieChartSectionData(
        value: e.value,
        title: '${pct.toStringAsFixed(0)}%',
        radius: 70,
        color: palette[i % palette.length],
        titleStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        badgeWidget: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(e.key,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurface)),
        ),
        badgePositionPercentageOffset: 1.25,
      );
    });
  }

  List<BarChartGroupData> _buildExpenseBarGroups(
      BuildContext context, Map<DateTime, double> data) {
    final cs = Theme.of(context).colorScheme;
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
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.secondary.withOpacity(0.95), cs.secondary.withOpacity(0.6)],
            ),
          ),
        ],
      );
    });
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
        _MetricRow(label: 'Среднее время на задачу', value: '${avgTimePerGoal.toStringAsFixed(1)} ч'),
        _MetricRow(label: '«В срок» (условно)', value: '$percentOnTime %'),
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

  // палитра из темы
  List<Color> _palette(ColorScheme cs) => [
        cs.primary,
        cs.secondary,
        cs.tertiary,
        cs.primaryContainer,
        cs.secondaryContainer,
        cs.tertiaryContainer,
      ];

  // сортировки и общая легенда
  List<MapEntry<String, int>> _sortedEntriesInt(Map<String, int> map) =>
      (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

  List<MapEntry<String, double>> _sortedEntriesDouble(Map<String, double> map) =>
      (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
}

// ───────── building blocks ─────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return SizedBox(
      width: 170,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(title, style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights_outlined, color: cs.onSurfaceVariant),
            const SizedBox(height: 6),
            Text('Недостаточно данных', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// компактная легенда для Pie
class _Legend extends StatelessWidget {
  final List<MapEntry<String, num>> entries;
  final List<Color> colors;
  final String Function(num) valueFormatter;
  final double total;

  const _Legend({
    required this.entries,
    required this.colors,
    required this.valueFormatter,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: List.generate(entries.length, (i) {
        final e = entries[i];
        final color = colors[i % colors.length];
        final pct = total == 0 ? 0 : (e.value / total * 100);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(e.key, style: tt.labelMedium),
            const SizedBox(width: 6),
            Text('• ${valueFormatter(e.value)}',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(width: 6),
            Text('${pct.toStringAsFixed(0)}%',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ]),
        );
      }),
    );
  }
}

// липкий заголовок
// липкий заголовок (фикс: принудительно задаём высоту = maxExtent)
class _StickyHeader extends SliverPersistentHeaderDelegate {
  final double _min;
  final double _max;
  final Widget child;

  _StickyHeader({
    required double minExtent,
    required double maxExtent,
    required this.child,
  })  : _min = minExtent,
        _max = maxExtent;

  @override
  double get minExtent => _min;

  @override
  double get maxExtent => _max;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // важное: SizedBox(height: maxExtent) — чтобы paintExtent == layoutExtent
    return SizedBox(
      height: maxExtent,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeader oldDelegate) =>
      _min != oldDelegate._min ||
      _max != oldDelegate._max ||
      child != oldDelegate.child;
}


/// Внутренняя структура для секции «Расходы»
class _ExpenseAnalytics {
  final double total;
  final Map<String, double> byCategory; // имя категории -> сумма
  final Map<DateTime, double> byDay;    // день -> сумма

  _ExpenseAnalytics({required this.total, required this.byCategory, required this.byDay});
}
