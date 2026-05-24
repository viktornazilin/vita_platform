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

  BoxDecoration _sheetDecoration(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = cs.secondary;

    return BoxDecoration(
      color: Color.lerp(
        cs.surface,
        accent,
        isDark ? 0.035 : 0.055,
      )!,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: Color.lerp(cs.outlineVariant, accent, isDark ? 0.18 : 0.22)!,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.24)
              : cs.primary.withOpacity(0.08),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: accent.withOpacity(isDark ? 0.05 : 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _sheetHandle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 5,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(0.32),
            cs.secondary.withOpacity(0.70),
            cs.tertiary.withOpacity(0.34),
          ],
        ),
      ),
    );
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
            decoration: _sheetDecoration(ctx),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(ctx),
                _SheetTitle(
                  icon: Icons.flag_rounded,
                  title: l.healthCalorieTargetTitle,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.healthDailyCaloriesLabel,
                    prefixIcon: const Icon(Icons.local_fire_department_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final value = int.tryParse(ctrl.text.trim()) ?? 0;
                      await _repo.upsertDailyCalorieTarget(value);
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      await _load();
                    },
                    icon: const Icon(Icons.check_rounded),
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
              decoration: _sheetDecoration(ctx),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sheetHandle(ctx),
                    _SheetTitle(
                      icon: Icons.restaurant_rounded,
                      title: l.healthAddMealTitle,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: mealType,
                      decoration: InputDecoration(
                        labelText: l.healthMealTypeLabel,
                        prefixIcon: const Icon(Icons.room_service_rounded),
                      ),
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
                      decoration: InputDecoration(
                        labelText: l.healthCaloriesLabel,
                        prefixIcon: const Icon(Icons.local_fire_department_rounded),
                      ),
                      validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                          ? l.healthEnterCalories
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        labelText: l.healthMealDescriptionLabel,
                        prefixIcon: const Icon(Icons.notes_rounded),
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
            decoration: _sheetDecoration(ctx),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(ctx),
                _SheetTitle(
                  icon: Icons.directions_run_rounded,
                  title: l.healthAddBurnTitle,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: caloriesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.healthCaloriesBurnedLabel,
                    prefixIcon: const Icon(Icons.local_fire_department_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    labelText: l.healthCommentLabel,
                    prefixIcon: const Icon(Icons.notes_rounded),
                  ),
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
              decoration: _sheetDecoration(ctx),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sheetHandle(ctx),
                  _SheetTitle(
                    icon: Icons.water_drop_rounded,
                    title: l.healthWaterTodayTitle,
                    accent: cs.tertiary,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l.healthLitersValue(current.toStringAsFixed(1)),
                    style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.primary,
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

  Widget _stat(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    Color? accent,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = accent ?? cs.secondary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.lerp(
          cs.surfaceContainerLowest,
          tone,
          isDark ? 0.055 : 0.070,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Color.lerp(cs.outlineVariant, tone, isDark ? 0.20 : 0.24)!,
        ),
        boxShadow: [
          BoxShadow(
            color: tone.withOpacity(isDark ? 0.04 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tone.withOpacity(isDark ? 0.16 : 0.14),
              border: Border.all(color: tone.withOpacity(isDark ? 0.26 : 0.22)),
            ),
            child: Icon(icon, color: tone, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    Color? accent,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = accent ?? cs.secondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Color.lerp(
              cs.surfaceContainerHighest,
              tone,
              isDark ? 0.10 : 0.14,
            ),
            border: Border.all(
              color: Color.lerp(cs.outlineVariant, tone, isDark ? 0.24 : 0.28)!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: tone),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon, Color accent) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 8,
          height: 24,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.22),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 19, color: accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _activityTile({
    required BuildContext context,
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
    required VoidCallback onDelete,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color.lerp(
          cs.surfaceContainerLowest,
          accent,
          isDark ? 0.045 : 0.055,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Color.lerp(cs.outlineVariant, accent, isDark ? 0.16 : 0.18)!,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
        leading: CircleAvatar(
          backgroundColor: accent.withOpacity(isDark ? 0.16 : 0.14),
          child: Icon(icon, color: accent),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        subtitle: Text(subtitle),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = _summary;
    final l = AppLocalizations.of(context)!;
    final gold = cs.secondary;
    final aqua = cs.tertiary;
    final primary = cs.primary;

    return ReportSectionCard(
      title: l.healthTrackerTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: l.healthCalorieTargetTitle,
              style: IconButton.styleFrom(
                backgroundColor: gold.withOpacity(0.12),
                foregroundColor: gold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
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
                _actionButton(
                  context: context,
                  onPressed: _editTarget,
                  icon: Icons.flag_rounded,
                  label: s.dailyTarget > 0
                      ? l.healthTargetCalories(s.dailyTarget)
                      : l.healthSetTarget,
                  accent: gold,
                ),
                _actionButton(
                  context: context,
                  onPressed: _addMeal,
                  icon: Icons.restaurant_rounded,
                  label: l.healthAddMealButton,
                  accent: primary,
                ),
                _actionButton(
                  context: context,
                  onPressed: _addBurn,
                  icon: Icons.directions_run_rounded,
                  label: l.healthAddBurnButton,
                  accent: gold,
                ),
                _actionButton(
                  context: context,
                  onPressed: _editWater,
                  icon: Icons.water_drop_rounded,
                  label: l.healthWaterButton(s.waterLiters.toStringAsFixed(1)),
                  accent: aqua,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _stat(
              context,
              l.healthConsumed,
              l.healthKcalValue(s.consumed),
              Icons.fastfood_rounded,
              accent: primary,
            ),
            const SizedBox(height: 8),
            _stat(
              context,
              l.healthBurned,
              l.healthKcalValue(s.burned),
              Icons.local_fire_department_rounded,
              accent: gold,
            ),
            const SizedBox(height: 8),
            _stat(
              context,
              l.healthBalance,
              l.healthKcalValue(s.net),
              Icons.balance_rounded,
              accent: aqua,
            ),
            const SizedBox(height: 8),
            _stat(
              context,
              l.healthDeltaVsTarget,
              l.healthKcalValueWithSign(
                s.deltaVsTarget >= 0 ? '+${s.deltaVsTarget}' : '${s.deltaVsTarget}',
              ),
              Icons.compare_arrows_rounded,
              accent: gold,
            ),
            const SizedBox(height: 8),
            _stat(
              context,
              l.healthWaterDrunk,
              l.healthLitersValue(s.waterLiters.toStringAsFixed(1)),
              Icons.water_drop_rounded,
              accent: aqua,
            ),
            const SizedBox(height: 16),
            _sectionHeader(context, l.healthMealsTodayTitle, Icons.restaurant_rounded, primary),
            const SizedBox(height: 10),
            if (s.meals.isEmpty)
              Text(
                l.healthNoMeals,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            for (final meal in s.meals)
              _activityTile(
                context: context,
                icon: Icons.restaurant_menu_rounded,
                accent: primary,
                title: _mealLabel(context, meal.mealType),
                subtitle: '${meal.description}\n${l.healthKcalValue(meal.calories)}',
                onDelete: () async {
                  await _repo.deleteMeal(meal.id);
                  await _load();
                },
              ),
            const SizedBox(height: 14),
            _sectionHeader(
              context,
              l.healthBurnsTitle,
              Icons.local_fire_department_rounded,
              gold,
            ),
            const SizedBox(height: 10),
            if (s.burns.isEmpty)
              Text(
                l.healthNoBurns,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            for (final burn in s.burns)
              _activityTile(
                context: context,
                icon: Icons.local_fire_department_rounded,
                accent: gold,
                title: l.healthKcalValue(burn.caloriesBurned),
                subtitle: burn.note.trim().isEmpty ? l.healthNoComment : burn.note,
                onDelete: () async {
                  await _repo.deleteBurn(burn.id);
                  await _load();
                },
              ),
          ],
        ],
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? accent;

  const _SheetTitle({
    required this.icon,
    required this.title,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final tone = accent ?? cs.secondary;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary.withOpacity(0.92),
                tone.withOpacity(0.82),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: tone.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: cs.onPrimary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}
