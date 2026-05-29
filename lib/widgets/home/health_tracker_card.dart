import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';

import '../../services/home_trackers_repo.dart';
import '../report_section_card.dart';

bool _ladnaIsDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _ladnaCardBg(BuildContext context) =>
    _ladnaIsDark(context) ? const Color(0xFF1C1630) : const Color(0xFFFAFAFE);

Color _ladnaCardBorder(BuildContext context) =>
    _ladnaIsDark(context) ? const Color(0xFF3A2A63) : const Color(0xFFE0DCF0);

Color _ladnaText(BuildContext context) =>
    _ladnaIsDark(context) ? const Color(0xFFF0EEFF) : const Color(0xFF160E38);

Color _ladnaMuted(BuildContext context) =>
    _ladnaIsDark(context) ? const Color(0x99FFFFFF) : const Color(0xFF9090A8);

Color _ladnaSoftText(BuildContext context) =>
    _ladnaIsDark(context) ? const Color(0xB3FFFFFF) : const Color(0xFF555268);

Color _ladnaSubtleBg(BuildContext context) =>
    _ladnaIsDark(context) ? const Color(0xFF2A2142) : const Color(0xFFEAE6F5);

Color _ladnaSubtleBorder(BuildContext context) =>
    _ladnaIsDark(context) ? const Color(0xFF4A377A) : const Color(0xFFE0DCF0);

Color _ladnaAccent(BuildContext context) =>
    _ladnaIsDark(context) ? const Color(0xFFD4E040) : const Color(0xFF6B54C0);

Color _ladnaPurple(BuildContext context) => const Color(0xFF6B54C0);

class _PersonalText {
  final Locale locale;
  const _PersonalText(this.locale);

  static _PersonalText of(BuildContext context) =>
      _PersonalText(Localizations.localeOf(context));

  String pick(
    String ru,
    String en, {
    String? de,
    String? fr,
    String? es,
    String? tr,
  }) {
    switch (locale.languageCode) {
      case 'de':
        return de ?? en;
      case 'fr':
        return fr ?? en;
      case 'es':
        return es ?? en;
      case 'tr':
        return tr ?? en;
      case 'en':
        return en;
      case 'ru':
      default:
        return ru;
    }
  }

  String get mealsSection => pick(
        'Приёмы пищи',
        'Meals',
        de: 'Mahlzeiten',
        fr: 'Repas',
        es: 'Comidas',
        tr: 'Öğünler',
      );

  String get activitySection => pick(
        'Активность',
        'Activity',
        de: 'Aktivität',
        fr: 'Activité',
        es: 'Actividad',
        tr: 'Aktivite',
      );

  String get consumedKcal => pick(
        'Съедено ккал',
        'Eaten kcal',
        de: 'Gegessene kcal',
        fr: 'Kcal consommées',
        es: 'Kcal consumidas',
        tr: 'Alınan kcal',
      );

  String get burnedKcal => pick(
        'Потрачено ккал',
        'Burned kcal',
        de: 'Verbrannte kcal',
        fr: 'Kcal brûlées',
        es: 'Kcal quemadas',
        tr: 'Yakılan kcal',
      );

  String get balanceKcal => pick(
        'Баланс ккал',
        'Balance kcal',
        de: 'Bilanz kcal',
        fr: 'Solde kcal',
        es: 'Balance kcal',
        tr: 'Denge kcal',
      );

  String get targetNotSet => pick(
        'Норма не задана',
        'Target not set',
        de: 'Ziel nicht gesetzt',
        fr: 'Objectif non défini',
        es: 'Objetivo no definido',
        tr: 'Hedef belirlenmedi',
      );

  String remainingToTarget(int target) => pick(
        'До нормы $target ккал',
        '$target kcal to target',
        de: '$target kcal bis zum Ziel',
        fr: '$target kcal jusqu’à l’objectif',
        es: '$target kcal hasta el objetivo',
        tr: 'Hedefe $target kcal kaldı',
      );

  String todayWithDate(String date) => pick(
        'Сегодня · $date',
        'Today · $date',
        de: 'Heute · $date',
        fr: 'Aujourd’hui · $date',
        es: 'Hoy · $date',
        tr: 'Bugün · $date',
      );

  String get water => pick(
        'Вода',
        'Water',
        de: 'Wasser',
        fr: 'Eau',
        es: 'Agua',
        tr: 'Su',
      );

  String waterLiters(double liters) => pick(
        '${liters.toStringAsFixed(1)} / 2,0 л',
        '${liters.toStringAsFixed(1)} / 2.0 L',
        de: '${liters.toStringAsFixed(1)} / 2,0 L',
        fr: '${liters.toStringAsFixed(1)} / 2,0 L',
        es: '${liters.toStringAsFixed(1)} / 2,0 L',
        tr: '${liters.toStringAsFixed(1)} / 2,0 L',
      );

  String get hobbyDirections => pick(
        'Направления',
        'Directions',
        de: 'Bereiche',
        fr: 'Domaines',
        es: 'Áreas',
        tr: 'Alanlar',
      );

  String get today => pick(
        'Сегодня',
        'Today',
        de: 'Heute',
        fr: 'Aujourd’hui',
        es: 'Hoy',
        tr: 'Bugün',
      );

  String get hobbyWeek => pick(
        'Хобби за неделю',
        'Hobbies this week',
        de: 'Hobbys diese Woche',
        fr: 'Loisirs cette semaine',
        es: 'Hobbies esta semana',
        tr: 'Bu haftaki hobiler',
      );
}


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
                    prefixIcon: Icon(Icons.local_fire_department_rounded),
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
                    icon: Icon(Icons.check_rounded),
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
                        prefixIcon: Icon(Icons.room_service_rounded),
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
                        prefixIcon: Icon(Icons.local_fire_department_rounded),
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
                        prefixIcon: Icon(Icons.notes_rounded),
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
                        icon: Icon(Icons.restaurant_rounded),
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
                    prefixIcon: Icon(Icons.local_fire_department_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    labelText: l.healthCommentLabel,
                    prefixIcon: Icon(Icons.notes_rounded),
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
                    icon: Icon(Icons.local_fire_department_rounded),
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
                      icon: Icon(Icons.water_drop_rounded),
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
          icon: Icon(Icons.delete_outline_rounded),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = _summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loading)
          const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else if (s != null) ...[
          _HealthHero(
            consumed: s.consumed,
            burned: s.burned,
            net: s.net,
            target: s.dailyTarget,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _ActionButton(
                  label: l.healthAddMealButton,
                  icon: Icons.restaurant_rounded,
                  onTap: _addMeal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: l.healthAddBurnButton,
                  icon: Icons.directions_run_rounded,
                  onTap: _addBurn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _WaterCard(
            liters: s.waterLiters,
            onTap: _editWater,
          ),
          const SizedBox(height: 14),
          _SectionLabel(text: _PersonalText.of(context).mealsSection),
          const SizedBox(height: 8),
          _LadnaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                if (s.meals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      l.healthNoMeals,
                      style: TextStyle(
                        color: _ladnaMuted(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  for (final meal in s.meals) ...[
                    _FoodRow(
                      label: _mealLabel(context, meal.mealType),
                      title: meal.description.trim().isEmpty
                          ? _mealLabel(context, meal.mealType)
                          : meal.description.trim(),
                      value: l.healthKcalValue(meal.calories),
                      onDelete: () async {
                        await _repo.deleteMeal(meal.id);
                        await _load();
                      },
                    ),
                    if (meal != s.meals.last)
                      Divider(height: 1, color: _ladnaCardBorder(context)),
                  ],
                InkWell(
                  onTap: _addMeal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      l.healthAddMealButton,
                      style: TextStyle(
                        color: _ladnaAccent(context),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (s.burns.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SectionLabel(text: _PersonalText.of(context).activitySection),
            const SizedBox(height: 8),
            _LadnaCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final burn in s.burns) ...[
                    _FoodRow(
                      label: _PersonalText.of(context).activitySection,
                      title: burn.note.trim().isEmpty
                          ? l.healthBurnsTitle
                          : burn.note.trim(),
                      value: l.healthKcalValue(burn.caloriesBurned),
                      onDelete: () async {
                        await _repo.deleteBurn(burn.id);
                        await _load();
                      },
                    ),
                    if (burn != s.burns.last)
                      Divider(height: 1, color: _ladnaCardBorder(context)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _HealthHero extends StatelessWidget {
  final int consumed;
  final int burned;
  final int net;
  final int target;

  const _HealthHero({
    required this.consumed,
    required this.burned,
    required this.net,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF160E38), Color(0xFF1E1248)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF160E38).withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -54,
            right: -48,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _ladnaAccent(context).withOpacity(0.16),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _todayLabel(context).toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.42),
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _HeroMetric(
                      value: '$consumed',
                      label: _PersonalText.of(context).consumedKcal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HeroMetric(
                      value: '$burned',
                      label: _PersonalText.of(context).burnedKcal,
                      valueColor: const Color(0xFF4DD8CC),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HeroMetric(
                      value: '$net',
                      label: _PersonalText.of(context).balanceKcal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      target <= 0 ? _PersonalText.of(context).targetNotSet : _PersonalText.of(context).remainingToTarget(target),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.42),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.42),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Colors.white.withOpacity(0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF6B54C0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _todayLabel(BuildContext context) {
    final date = MaterialLocalizations.of(context).formatMediumDate(DateTime.now());
    return _PersonalText.of(context).todayWithDate(date);
  }
}

class _HeroMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _HeroMetric({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFFFAF6EE),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.42),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: _ladnaCardBg(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _ladnaSubtleBorder(context)),
          boxShadow: [
            BoxShadow(
              color: _ladnaIsDark(context) ? Colors.black.withOpacity(0.30) : Colors.black.withOpacity(0.045),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: _ladnaAccent(context)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _ladnaSoftText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  final double liters;
  final VoidCallback onTap;

  const _WaterCard({
    required this.liters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (liters / 2.0).clamp(0.0, 1.0).toDouble();
    final filled = (progress * 8).round().clamp(0, 8);

    return _LadnaCard(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  _PersonalText.of(context).water,
                  style: TextStyle(
                    color: _ladnaText(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  _PersonalText.of(context).waterLiters(liters),
                  style: TextStyle(
                    color: _ladnaSoftText(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: _ladnaSubtleBg(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF6B54C0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                8,
                (index) => Container(
                  width: 28,
                  height: 28,
                  margin: EdgeInsets.only(right: index == 7 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: index < filled
                        ? _ladnaSubtleBg(context)
                        : _ladnaSubtleBg(context).withOpacity(_ladnaIsDark(context) ? 0.45 : 0.55),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: index < filled
                          ? _ladnaAccent(context).withOpacity(0.35)
                          : _ladnaSubtleBorder(context),
                    ),
                  ),
                  child: const Center(child: Text('💧')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  final String label;
  final String title;
  final String value;
  final Future<void> Function() onDelete;

  const _FoodRow({
    required this.label,
    required this.title,
    required this.value,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('$label$title$value'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.redAccent.withOpacity(0.14),
        child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
      ),
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _ladnaMuted(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: _ladnaText(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: _ladnaMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LadnaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _LadnaCard({
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _ladnaCardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ladnaSubtleBorder(context)),
        boxShadow: [
          BoxShadow(
            color: _ladnaIsDark(context) ? Colors.black.withOpacity(0.30) : Colors.black.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: _ladnaMuted(context),
        letterSpacing: 1.2,
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
    final tone = accent ?? _ladnaAccent(context);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: tone.withOpacity(0.12),
            border: Border.all(color: tone.withOpacity(0.24)),
          ),
          child: Icon(icon, color: tone, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w600,
                  color: _ladnaText(context),
                ),
          ),
        ),
      ],
    );
  }
}
