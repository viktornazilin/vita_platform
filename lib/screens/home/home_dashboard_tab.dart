import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/home_model.dart';
import '../../models/reports_model.dart';
import '../../models/mood_model.dart';
import '../../models/mood.dart';

import '../../widgets/report_section_card.dart';
import '../../widgets/report_stat_card.dart';
import '../../widgets/mood_selector.dart';
import '../../widgets/expense_analytics.dart';

import '../../main.dart'; // dbRepo
import 'home_hero_pill.dart';

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final r = ReportsModel();
            r.setPeriod(ReportPeriod.week);
            r.loadAll();
            return r;
          },
        ),
        ChangeNotifierProvider(create: (_) => MoodModel(repo: dbRepo)..load()),
      ],
      child: const _HomeDashboardBody(),
    );
  }
}

class _HomeDashboardBody extends StatefulWidget {
  const _HomeDashboardBody();

  @override
  State<_HomeDashboardBody> createState() => _HomeDashboardBodyState();
}

class _HomeDashboardBodyState extends State<_HomeDashboardBody>
    with AutomaticKeepAliveClientMixin {
  bool _editingMood = false;
  String _selectedEmoji = '😊';
  final TextEditingController _noteCtrl = TextEditingController();
  bool _savingMood = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshAll(BuildContext context) async {
    await Future.wait([
      context.read<ReportsModel>().loadAll(),
      context.read<MoodModel>().load(),
    ]);
  }

  Mood? _todayMood(List<Mood> moods) {
    final today = DateUtils.dateOnly(DateTime.now());
    for (final m in moods) {
      if (DateUtils.isSameDay(DateUtils.dateOnly(m.date), today)) return m;
    }
    return null;
  }

  String _rangeLabelShort(ReportsModel r, BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final start = loc.formatShortMonthDay(r.range.start);
    final end = loc.formatShortMonthDay(
      r.range.end.subtract(const Duration(days: 1)),
    );
    return '$start – $end';
  }

  Future<void> _saveTodayMood(BuildContext context) async {
    if (_savingMood) return;
    setState(() => _savingMood = true);

    final today = DateUtils.dateOnly(DateTime.now());
    final note = _noteCtrl.text.trim();

    try {
      await dbRepo.upsertMood(date: today, emoji: _selectedEmoji, note: note);
      await context.read<MoodModel>().load();

      if (!mounted) return;

      _noteCtrl.clear();
      setState(() {
        _editingMood = false;
        _selectedEmoji = '😊';
        _savingMood = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настроение сохранено'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _savingMood = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось сохранить: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _go(BuildContext context, int index) {
    context.read<HomeModel>().select(index);
  }

  MapEntry<String, double>? _topCategory(Map<String, double> byCategory) {
    if (byCategory.isEmpty) return null;
    MapEntry<String, double>? best;
    for (final e in byCategory.entries) {
      if (best == null || e.value > best!.value) best = e;
    }
    return best;
  }

  MapEntry<DateTime, double>? _peakDay(Map<DateTime, double> byDay) {
    if (byDay.isEmpty) return null;
    MapEntry<DateTime, double>? best;
    for (final e in byDay.entries) {
      if (best == null || e.value > best!.value) best = e;
    }
    return best;
  }

  String _formatDayShort(BuildContext context, DateTime d) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatShortMonthDay(d);
  }

  Widget _cta(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final reports = context.watch<ReportsModel>();
    final moodModel = context.watch<MoodModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (reports.period != ReportPeriod.week) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ReportsModel>().setPeriod(ReportPeriod.week);
      });
    }

    final todayMood = _todayMood(moodModel.moods);

    final heroTasks = reports.loading
        ? null
        : reports.goalsInRange.where((g) => g.isCompleted).length;
    final heroHours = reports.loading ? null : reports.totalHours;
    final heroEff = reports.loading ? null : reports.efficiency;

    return RefreshIndicator.adaptive(
      onRefresh: () => _refreshAll(context),
      child: CustomScrollView(
        key: const PageStorageKey('home-dashboard-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сегодня и неделя',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Короткий обзор — затем детали ниже',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      HomeHeroPill(
                        icon: Icons.mood_rounded,
                        label: todayMood?.emoji ?? '—',
                        sublabel: 'Настроение',
                      ),
                      HomeHeroPill(
                        icon: Icons.check_circle_rounded,
                        label: heroTasks == null ? '…' : heroTasks.toString(),
                        sublabel: 'Выполнено',
                      ),
                      HomeHeroPill(
                        icon: Icons.timer_outlined,
                        label: heroHours == null
                            ? '…'
                            : heroHours.toStringAsFixed(1),
                        sublabel: 'Часов',
                      ),
                      HomeHeroPill(
                        icon: Icons.speed_rounded,
                        label: heroEff == null
                            ? '…'
                            : '${(heroEff * 100).round()}%',
                        sublabel: 'Эффект.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Настроение сегодня
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ReportSectionCard(
                title: 'Настроение сегодня',
                child: moodModel.loading
                    ? const SizedBox(
                        height: 92,
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest.withOpacity(
                                    0.55,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cs.outlineVariant.withOpacity(0.7),
                                  ),
                                ),
                                child: Text(
                                  todayMood?.emoji ?? '📝',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      todayMood == null
                                          ? 'Записи за сегодня нет'
                                          : (todayMood.note.trim().isEmpty
                                                ? 'Запись есть (без заметки)'
                                                : todayMood.note.trim()),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: tt.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      todayMood == null
                                          ? 'Сделай быструю отметку — это 10 секунд'
                                          : 'Можно обновить — запись перезапишется за сегодня',
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant.withOpacity(
                                          0.95,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: _editingMood ? 'Свернуть' : 'Обновить',
                                onPressed: () => setState(
                                  () => _editingMood = !_editingMood,
                                ),
                                icon: Icon(
                                  _editingMood
                                      ? Icons.expand_less
                                      : Icons.edit_rounded,
                                ),
                              ),
                            ],
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: _editingMood
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: cs.surfaceContainerHighest
                                                .withOpacity(0.55),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: cs.outlineVariant
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                          child: MoodSelector(
                                            selectedEmoji: _selectedEmoji,
                                            onSelect: (e) => setState(
                                              () => _selectedEmoji = e,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: _noteCtrl,
                                          maxLines: 2,
                                          textInputAction: TextInputAction.done,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Заметка (необязательно)',
                                            hintText:
                                                'Что повлияло на состояние?',
                                            prefixIcon: const Icon(
                                              Icons.edit_note_rounded,
                                            ),
                                            filled: true,
                                            fillColor: cs
                                                .surfaceContainerHighest
                                                .withOpacity(0.45),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              borderSide: BorderSide(
                                                color: cs.outlineVariant,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              borderSide: BorderSide(
                                                color: cs.outlineVariant
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              borderSide: BorderSide(
                                                color: cs.primary,
                                                width: 1.4,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 52,
                                          width: double.infinity,
                                          child: FilledButton.icon(
                                            onPressed: _savingMood
                                                ? null
                                                : () => _saveTodayMood(context),
                                            icon: _savingMood
                                                ? SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child: CircularProgressIndicator.adaptive(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(cs.onPrimary),
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.check_rounded,
                                                  ),
                                            label: Text(
                                              _savingMood
                                                  ? 'Сохранение…'
                                                  : 'Сохранить',
                                            ),
                                            style: FilledButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),
                          _cta(
                            context,
                            icon: Icons.open_in_new,
                            label: 'Открыть историю настроений',
                            onPressed: () => _go(context, 2),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // Сводка недели
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ReportSectionCard(
                title: 'Сводка недели',
                child: reports.loading
                    ? const SizedBox(
                        height: 92,
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _rangeLabelShort(reports, context),
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ReportStatCard(
                                title: 'Выполнено задач',
                                value: reports.goalsInRange
                                    .where((g) => g.isCompleted)
                                    .length
                                    .toString(),
                                icon: Icons.check_circle,
                              ),
                              ReportStatCard(
                                title: 'Часы (факт)',
                                value: reports.totalHours.toStringAsFixed(1),
                                icon: Icons.timer_outlined,
                              ),
                              ReportStatCard(
                                title: 'Эффективность',
                                value: '${(reports.efficiency * 100).round()}%',
                                icon: Icons.speed,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'План: ${reports.plannedHours.toStringAsFixed(1)} ч • Факт: ${reports.totalHours.toStringAsFixed(1)} ч',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant.withOpacity(0.95),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _cta(
                            context,
                            icon: Icons.insights_rounded,
                            label: 'Открыть подробные отчёты',
                            onPressed: () => _go(context, 4),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // Расходы недели
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: ReportSectionCard(
                title: 'Расходы недели',
                child: reports.loading
                    ? const SizedBox(
                        height: 92,
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    : FutureBuilder<ExpenseAnalytics>(
                        future: loadExpenseAnalytics(
                          reports.range.start,
                          reports.range.end,
                        ),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 92,
                              child: Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                          }

                          final data = snap.data;
                          if (data == null ||
                              (data.total <= 0 && data.byDay.isEmpty)) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Нет расходов за неделю',
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _cta(
                                  context,
                                  icon: Icons.account_balance_wallet_rounded,
                                  label: 'Открыть расходы',
                                  onPressed: () => _go(context, 5),
                                ),
                              ],
                            );
                          }

                          final days =
                              (reports.range.end
                                      .difference(reports.range.start)
                                      .inDays)
                                  .clamp(1, 366);
                          final avg = data.total / days;

                          final topCat = _topCategory(data.byCategory);
                          final peak = _peakDay(data.byDay);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Всего: ${data.total.toStringAsFixed(2)} €',
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Средний расход/день: ${avg.toStringAsFixed(2)} €',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant.withOpacity(0.95),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (topCat != null || peak != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest
                                        .withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: cs.outlineVariant.withOpacity(
                                        0.55,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Инсайты',
                                        style: tt.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if (topCat != null)
                                        Text(
                                          '• Топ категория: ${topCat.key} — ${topCat.value.toStringAsFixed(2)} €',
                                          style: tt.bodyMedium?.copyWith(
                                            color: cs.onSurfaceVariant
                                                .withOpacity(0.98),
                                          ),
                                        ),
                                      if (peak != null)
                                        Text(
                                          '• Пик расхода: ${_formatDayShort(context, peak.key)} — ${peak.value.toStringAsFixed(2)} €',
                                          style: tt.bodyMedium?.copyWith(
                                            color: cs.onSurfaceVariant
                                                .withOpacity(0.98),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 12),
                              _cta(
                                context,
                                icon: Icons.open_in_new,
                                label: 'Открыть подробные расходы',
                                onPressed: () => _go(context, 5),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
