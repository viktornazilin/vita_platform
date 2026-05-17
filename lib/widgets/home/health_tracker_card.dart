
import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';

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

  String _mealLabel(BuildContext context, String type) {
    final l = AppLocalizations.of(context)!;
    switch (type) {
      case 'breakfast':
        return l.healthMealBreakfast;
      case 'lunch':
        return l.healthMealLunch;
      case 'dinner':
        return l.healthMealDinner;
      case 'snack':
        return l.healthMealSnack;
      default:
        return type;
    }
  }

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
        final l = AppLocalizations.of(ctx)!;
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
                  l.healthCalorieTargetTitle,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l.healthDailyCaloriesLabel),
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
                    child: Text(l.commonSave),
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
        final l = AppLocalizations.of(ctx)!;
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
                      l.healthAddMealTitle,
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: mealType,
                      decoration: InputDecoration(labelText: l.healthMealTypeLabel),
                      items: const ['breakfast', 'lunch', 'dinner', 'snack']
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(_mealLabel(ctx, e)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setLocal(() => mealType = v ?? 'breakfast'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: caloriesCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l.healthCaloriesLabel),
                      validator: (v) =>
                          (int.tryParse(v ?? '') ?? 0) <= 0 ? l.healthEnterCalories : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        labelText: l.healthMealDescriptionLabel,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l.healthAddDescription
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
                        label: Text(l.commonSave),
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
        final l = AppLocalizations.of(ctx)!;
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
                  l.healthAddBurnTitle,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: caloriesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.healthCaloriesBurnedLabel,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(labelText: l.healthCommentLabel),
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
                    label: Text(l.commonSave),
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
        final l = AppLocalizations.of(ctx)!;
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
                    l.healthWaterTodayTitle,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l.healthLitersValue(current.toStringAsFixed(1)),
                    style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Slider(
                    value: current,
                    min: 1,
                    max: 3,
                    divisions: 8,
                    label: l.healthLitersValue(current.toStringAsFixed(1)),
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
                      label: Text(l.healthSaveWater),
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
    final l = AppLocalizations.of(context)!;

    return ReportSectionCard(
      title: l.healthTrackerTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: l.healthCalorieTargetTitle,
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
                    s.dailyTarget > 0 ? l.healthTargetCalories(s.dailyTarget) : l.healthSetTarget,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _addMeal,
                  icon: const Icon(Icons.restaurant_rounded),
                  label: Text(l.healthAddMealButton),
                ),
                FilledButton.tonalIcon(
                  onPressed: _addBurn,
                  icon: const Icon(Icons.directions_run_rounded),
                  label: Text(l.healthAddBurnButton),
                ),
                FilledButton.tonalIcon(
                  onPressed: _editWater,
                  icon: const Icon(Icons.water_drop_rounded),
                  label: Text(l.healthWaterButton(s.waterLiters.toStringAsFixed(1))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _stat(context, l.healthConsumed, l.healthKcalValue(s.consumed), Icons.fastfood_rounded),
            const SizedBox(height: 8),
            _stat(context, l.healthBurned, l.healthKcalValue(s.burned), Icons.local_fire_department_rounded),
            const SizedBox(height: 8),
            _stat(context, l.healthBalance, l.healthKcalValue(s.net), Icons.balance_rounded),
            const SizedBox(height: 8),
            _stat(
              context,
              l.healthDeltaVsTarget,
              l.healthKcalValueWithSign(s.deltaVsTarget >= 0 ? '+${s.deltaVsTarget}' : '${s.deltaVsTarget}'),
              Icons.compare_arrows_rounded,
            ),
            const SizedBox(height: 8),
            _stat(context, l.healthWaterDrunk, l.healthLitersValue(s.waterLiters.toStringAsFixed(1)), Icons.water_drop_rounded),
            const SizedBox(height: 14),
            Text(
              l.healthMealsTodayTitle,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            if (s.meals.isEmpty)
              Text(
                l.healthNoMeals,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            for (final meal in s.meals) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: cs.primary.withOpacity(0.10),
                  child: Icon(Icons.restaurant_menu_rounded, color: cs.primary),
                ),
                title: Text(_mealLabel(context, meal.mealType)),
                subtitle: Text('${meal.description}\n${l.healthKcalValue(meal.calories)}'),
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
              l.healthBurnsTitle,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            if (s.burns.isEmpty)
              Text(
                l.healthNoBurns,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            for (final burn in s.burns) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: cs.secondary.withOpacity(0.12),
                  child: Icon(Icons.local_fire_department_rounded, color: cs.secondary),
                ),
                title: Text(l.healthKcalValue(burn.caloriesBurned)),
                subtitle: Text(
                  burn.note.trim().isEmpty ? l.healthNoComment : burn.note,
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
