
import 'package:flutter/material.dart';

import '../../services/home_trackers_repo.dart';
import '../report_section_card.dart';

class HealthTrackerCard extends StatefulWidget {
  const HealthTrackerCard({super.key});

  @override
  State<HealthTrackerCard> createState() => _HealthTrackerCardState();
}

class _HealthTrackerCardState extends State<HealthTrackerCard> {
  final _repo = HomeTrackersRepo();
  bool _loading = true;
  HealthDaySummary? _summary;

  static const _mealLabels = {
    'breakfast': 'Завтрак',
    'lunch': 'Обед',
    'dinner': 'Ужин',
    'snack': 'Перекус',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final summary = await _repo.loadHealthDaySummary(DateTime.now());
      if (!mounted) return;
      setState(() => _summary = summary);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editTarget() async {
    final ctrl = TextEditingController(
      text: (_summary?.dailyTarget ?? 0) <= 0 ? '' : '${_summary!.dailyTarget}',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Норма калорий',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Ккал в день'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final value = int.tryParse(ctrl.text.trim()) ?? 0;
                      await _repo.upsertDailyCalorieTarget(value);
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      await _load();
                    },
                    child: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addMeal() async {
    final formKey = GlobalKey<FormState>();
    final caloriesCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String mealType = 'breakfast';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (ctx, setLocal) => Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Добавить прием пищи',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: mealType,
                      decoration: const InputDecoration(labelText: 'Прием пищи'),
                      items: _mealLabels.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setLocal(() => mealType = v ?? 'breakfast'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: caloriesCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Калории'),
                      validator: (v) =>
                          (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Введите калории' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Что это была за еда',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Добавьте описание'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          if (!(formKey.currentState?.validate() ?? false)) return;
                          await _repo.addMeal(
                            entryDate: DateTime.now(),
                            mealType: mealType,
                            calories: int.parse(caloriesCtrl.text.trim()),
                            description: descCtrl.text.trim(),
                          );
                          if (!mounted) return;
                          Navigator.pop(ctx);
                          await _load();
                        },
                        icon: const Icon(Icons.restaurant_rounded),
                        label: const Text('Сохранить'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addBurn() async {
    final caloriesCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Добавить расход калорий',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: caloriesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Сколько калорий потрачено',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Комментарий'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final value = int.tryParse(caloriesCtrl.text.trim()) ?? 0;
                      if (value <= 0) return;
                      await _repo.addBurn(
                        entryDate: DateTime.now(),
                        caloriesBurned: value,
                        note: noteCtrl.text.trim(),
                      );
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      await _load();
                    },
                    icon: const Icon(Icons.local_fire_department_rounded),
                    label: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editWater() async {
    double current = (_summary?.waterLiters ?? 0).clamp(1.0, 3.0);
    if ((_summary?.waterLiters ?? 0) == 0) current = 1.0;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (ctx, setLocal) => Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Сколько воды выпито сегодня',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '${current.toStringAsFixed(1)} л',
                    style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Slider(
                    value: current,
                    min: 1,
                    max: 3,
                    divisions: 8,
                    label: '${current.toStringAsFixed(1)} л',
                    onChanged: (v) => setLocal(() => current = v),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await _repo.addWater(
                          entryDate: DateTime.now(),
                          liters: double.parse(current.toStringAsFixed(1)),
                        );
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        await _load();
                      },
                      icon: const Icon(Icons.water_drop_rounded),
                      label: const Text('Сохранить воду'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stat(BuildContext context, String title, String value, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Text(
            value,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = _summary;

    return ReportSectionCard(
      title: 'Трекер здоровья',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Норма калорий',
              onPressed: _editTarget,
              icon: const Icon(Icons.edit_note_rounded),
            ),
          ),
          if (_loading)
            const SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (s != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _editTarget,
                  icon: const Icon(Icons.flag_rounded),
                  label: Text(
                    s.dailyTarget > 0 ? 'Норма ${s.dailyTarget} ккал' : 'Указать норму',
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _addMeal,
                  icon: const Icon(Icons.restaurant_rounded),
                  label: const Text('Добавить еду'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _addBurn,
                  icon: const Icon(Icons.directions_run_rounded),
                  label: const Text('Добавить расход'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _editWater,
                  icon: const Icon(Icons.water_drop_rounded),
                  label: Text('Вода ${s.waterLiters.toStringAsFixed(1)} л'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _stat(context, 'Съедено', '${s.consumed} ккал', Icons.fastfood_rounded),
            const SizedBox(height: 8),
            _stat(context, 'Потрачено', '${s.burned} ккал', Icons.local_fire_department_rounded),
            const SizedBox(height: 8),
            _stat(context, 'Баланс', '${s.net} ккал', Icons.balance_rounded),
            const SizedBox(height: 8),
            _stat(
              context,
              'Отклонение от нормы',
              '${s.deltaVsTarget >= 0 ? '+' : ''}${s.deltaVsTarget} ккал',
              Icons.compare_arrows_rounded,
            ),
            const SizedBox(height: 8),
            _stat(context, 'Выпито воды', '${s.waterLiters.toStringAsFixed(1)} л', Icons.water_drop_rounded),
            const SizedBox(height: 14),
            Text(
              'Приемы пищи за сегодня',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            if (s.meals.isEmpty)
              Text(
                'Пока нет записей по еде.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            for (final meal in s.meals) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: cs.primary.withOpacity(0.10),
                  child: Icon(Icons.restaurant_menu_rounded, color: cs.primary),
                ),
                title: Text(_mealLabels[meal.mealType] ?? meal.mealType),
                subtitle: Text('${meal.description}\n${meal.calories} ккал'),
                isThreeLine: true,
                trailing: IconButton(
                  onPressed: () async {
                    await _repo.deleteMeal(meal.id);
                    await _load();
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ),
              const Divider(height: 1),
            ],
            const SizedBox(height: 12),
            Text(
              'Расход калорий',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            if (s.burns.isEmpty)
              Text(
                'Пока нет записей о потраченных калориях.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            for (final burn in s.burns) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: cs.secondary.withOpacity(0.12),
                  child: Icon(Icons.local_fire_department_rounded, color: cs.secondary),
                ),
                title: Text('${burn.caloriesBurned} ккал'),
                subtitle: Text(
                  burn.note.trim().isEmpty ? 'Без комментария' : burn.note,
                ),
                trailing: IconButton(
                  onPressed: () async {
                    await _repo.deleteBurn(burn.id);
                    await _load();
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ),
              const Divider(height: 1),
            ],
          ],
        ],
      ),
    );
  }
}
