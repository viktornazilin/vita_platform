import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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


  String get calorieHistoryTitle => pick(
        'История внесений',
        'Entry history',
        de: 'Eintragshistorie',
        fr: 'Historique des saisies',
        es: 'Historial de registros',
        tr: 'Giriş geçmişi',
      );

  String get calorieHistoryPlaceholder => pick(
        'Сегодня пока нет внесений по калориям.',
        'No calorie entries yet today.',
        de: 'Heute gibt es noch keine Kalorieneinträge.',
        fr: 'Aucune saisie de calories aujourd’hui.',
        es: 'Aún no hay registros de calorías hoy.',
        tr: 'Bugün henüz kalori girişi yok.',
      );

  String get calorieNormHint => pick(
        'Нажми на эту плашку, чтобы изменить норму и посмотреть историю внесений.',
        'Tap this card to change the target and view entry history.',
        de: 'Tippe auf diese Karte, um das Ziel zu ändern und die Historie zu sehen.',
        fr: 'Touchez cette carte pour modifier l’objectif et voir l’historique.',
        es: 'Toca esta tarjeta para cambiar el objetivo y ver el historial.',
        tr: 'Hedefi değiştirmek ve geçmişi görmek için bu karta dokun.',
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

  String waterLiters(double liters, double target) {
    final value = liters.toStringAsFixed(1);
    final targetValue = target.toStringAsFixed(1);
    return pick(
      '$value / $targetValue л',
      '$value / $targetValue L',
      de: '$value / $targetValue L',
      fr: '$value / $targetValue L',
      es: '$value / $targetValue L',
      tr: '$value / $targetValue L',
    );
  }

  String get waterSettingsTitle => pick(
        'Вода за сегодня',
        'Water today',
        de: 'Wasser heute',
        fr: 'Eau aujourd’hui',
        es: 'Agua de hoy',
        tr: 'Bugünkü su',
      );

  String get waterTargetTitle => pick(
        'Норма воды',
        'Water target',
        de: 'Wasserziel',
        fr: 'Objectif d’eau',
        es: 'Objetivo de agua',
        tr: 'Su hedefi',
      );

  String get waterTargetLabel => pick(
        'Норма, л',
        'Target, L',
        de: 'Ziel, L',
        fr: 'Objectif, L',
        es: 'Objetivo, L',
        tr: 'Hedef, L',
      );

  String get waterEditTarget => pick(
        'Изменить норму',
        'Edit target',
        de: 'Ziel ändern',
        fr: 'Modifier l’objectif',
        es: 'Cambiar objetivo',
        tr: 'Hedefi değiştir',
      );

  String get waterHistoryTitle => pick(
        'История',
        'History',
        de: 'Historie',
        fr: 'Historique',
        es: 'Historial',
        tr: 'Geçmiş',
      );

  String get waterHistoryPlaceholder => pick(
        'Сегодня добавлений воды пока нет.',
        'No water additions yet today.',
        de: 'Heute wurde noch kein Wasser hinzugefügt.',
        fr: 'Aucun ajout d’eau aujourd’hui.',
        es: 'Todavía no se ha añadido agua hoy.',
        tr: 'Bugün henüz su eklenmedi.',
      );

  String get waterAddTitle => pick(
        'Добавить воду',
        'Add water',
        de: 'Wasser hinzufügen',
        fr: 'Ajouter de l’eau',
        es: 'Añadir agua',
        tr: 'Su ekle',
      );

  String get waterCup250 => pick(
        'Чашка · 250 мл',
        'Cup · 250 ml',
        de: 'Tasse · 250 ml',
        fr: 'Tasse · 250 ml',
        es: 'Taza · 250 ml',
        tr: 'Fincan · 250 ml',
      );

  String get waterGlass200 => pick(
        'Стакан · 200 мл',
        'Glass · 200 ml',
        de: 'Glas · 200 ml',
        fr: 'Verre · 200 ml',
        es: 'Vaso · 200 ml',
        tr: 'Bardak · 200 ml',
      );

  String get waterCustomOption => pick(
        'Свой вариант',
        'Custom amount',
        de: 'Eigene Menge',
        fr: 'Quantité libre',
        es: 'Cantidad propia',
        tr: 'Özel miktar',
      );

  String get waterCustomMlLabel => pick(
        'Количество, мл',
        'Amount, ml',
        de: 'Menge, ml',
        fr: 'Quantité, ml',
        es: 'Cantidad, ml',
        tr: 'Miktar, ml',
      );

  String waterAddedMl(int ml) => pick(
        '+$ml мл',
        '+$ml ml',
        de: '+$ml ml',
        fr: '+$ml ml',
        es: '+$ml ml',
        tr: '+$ml ml',
      );

  String waterTotalToday(double liters) => pick(
        'Сегодня выпито ${liters.toStringAsFixed(1)} л',
        '${liters.toStringAsFixed(1)} L today',
        de: 'Heute ${liters.toStringAsFixed(1)} L',
        fr: '${liters.toStringAsFixed(1)} L aujourd’hui',
        es: '${liters.toStringAsFixed(1)} L hoy',
        tr: 'Bugün ${liters.toStringAsFixed(1)} L',
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
  double _waterTargetLiters = 2.0;

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
    _loadWaterTarget();
    _load();
  }

  Future<void> _loadWaterTarget() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _waterTargetLiters = prefs.getDouble('health_water_target_liters') ?? 2.0;
    });
  }

  Future<void> _saveWaterTarget(double value) async {
    final normalized = value.clamp(0.5, 5.0).toDouble();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('health_water_target_liters', normalized);
    if (!mounted) return;
    setState(() => _waterTargetLiters = normalized);
  }

  String _waterHistoryKey([DateTime? date]) {
    final d = date ?? DateTime.now();
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return 'health_water_history_${d.year}$month$day';
  }

  Future<List<String>> _loadWaterHistoryRows(BuildContext ctx) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_waterHistoryKey()) ?? const <String>[];
    final t = _PersonalText.of(ctx);

    final rows = <String>[];
    for (final item in raw.reversed) {
      final parts = item.split('|');
      if (parts.length != 2) continue;
      final timestamp = int.tryParse(parts[0]);
      final ml = int.tryParse(parts[1]);
      if (timestamp == null || ml == null || ml <= 0) continue;
      final time = TimeOfDay.fromDateTime(
        DateTime.fromMillisecondsSinceEpoch(timestamp),
      ).format(ctx);
      rows.add('$time · ${t.waterAddedMl(ml)}');
    }
    return rows;
  }

  Future<void> _appendWaterHistoryMl(int ml) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _waterHistoryKey();
    final rows = prefs.getStringList(key) ?? <String>[];
    rows.add('${DateTime.now().millisecondsSinceEpoch}|$ml');
    await prefs.setStringList(key, rows);
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
        final t = _PersonalText.of(ctx);
        final s = _summary;
        final historyRows = <String>[
          if (s != null)
            for (final meal in s.meals)
              '${_mealLabel(ctx, meal.mealType)} · ${meal.description.trim().isEmpty ? l.healthKcalValue(meal.calories) : '${meal.description.trim()} · ${l.healthKcalValue(meal.calories)}'}',
          if (s != null)
            for (final burn in s.burns)
              '${t.activitySection} · ${burn.note.trim().isEmpty ? l.healthKcalValue(burn.caloriesBurned) : '${burn.note.trim()} · ${l.healthKcalValue(burn.caloriesBurned)}'}',
        ];

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: _sheetDecoration(ctx),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _sheetHandle(ctx)),
                _SheetTitle(
                  icon: Icons.flag_rounded,
                  title: l.healthCalorieTargetTitle,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ladnaText(ctx),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: l.healthDailyCaloriesLabel,
                    prefixIcon: const Icon(Icons.local_fire_department_rounded, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  ),
                ),
                const SizedBox(height: 12),
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
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(l.commonSave),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  t.calorieHistoryTitle,
                  style: TextStyle(
                    color: _ladnaText(ctx),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _ladnaSubtleBg(ctx).withOpacity(_ladnaIsDark(ctx) ? 0.55 : 0.75),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _ladnaSubtleBorder(ctx)),
                  ),
                  child: historyRows.isEmpty
                      ? Text(
                          t.calorieHistoryPlaceholder,
                          style: TextStyle(
                            color: _ladnaSoftText(ctx),
                            fontSize: 11.5,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: historyRows
                              .take(6)
                              .map(
                                (row) => Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    row,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _ladnaSoftText(ctx),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
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

  Future<void> _openWaterOverview() async {
    final targetCtrl = TextEditingController(
      text: _waterTargetLiters.toStringAsFixed(1),
    );
    final historyRows = await _loadWaterHistoryRows(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final t = _PersonalText.of(ctx);
        return StatefulBuilder(
          builder: (ctx, setLocal) => Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: _sheetDecoration(ctx),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _sheetHandle(ctx)),
                  _SheetTitle(
                    icon: Icons.water_drop_rounded,
                    title: t.waterSettingsTitle,
                    accent: Theme.of(ctx).colorScheme.tertiary,
                  ),
                  const SizedBox(height: 14),
                  _WaterSummaryLine(
                    title: t.waterTotalToday(_summary?.waterLiters ?? 0),
                    value: t.waterLiters(_summary?.waterLiters ?? 0, _waterTargetLiters),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    t.waterTargetTitle,
                    style: TextStyle(
                      color: _ladnaText(ctx),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: targetCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _ladnaText(ctx),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: t.waterTargetLabel,
                      prefixIcon: const Icon(Icons.flag_rounded, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    ),
                    onSubmitted: (_) async {
                      final parsed = double.tryParse(
                        targetCtrl.text.trim().replaceAll(',', '.'),
                      );
                      if (parsed == null || parsed <= 0) return;
                      await _saveWaterTarget(parsed);
                      setLocal(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final parsed = double.tryParse(
                          targetCtrl.text.trim().replaceAll(',', '.'),
                        );
                        if (parsed == null || parsed <= 0) return;
                        await _saveWaterTarget(parsed);
                        if (!mounted) return;
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(AppLocalizations.of(ctx)!.commonSave),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    t.waterHistoryTitle,
                    style: TextStyle(
                      color: _ladnaText(ctx),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _ladnaSubtleBg(ctx).withOpacity(_ladnaIsDark(ctx) ? 0.55 : 0.75),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _ladnaSubtleBorder(ctx)),
                    ),
                    child: historyRows.isEmpty
                        ? Text(
                            t.waterHistoryPlaceholder,
                            style: TextStyle(
                              color: _ladnaSoftText(ctx),
                              fontSize: 11.5,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: historyRows
                                .map(
                                  (row) => Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      row,
                                      style: TextStyle(
                                        color: _ladnaSoftText(ctx),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
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

  Future<void> _addWaterAmount() async {
    final customCtrl = TextEditingController();

    Future<void> saveMl(BuildContext ctx, int ml) async {
      if (ml <= 0) return;
      final current = _summary?.waterLiters ?? 0;
      final next = (current + ml / 1000.0).clamp(0.0, 10.0).toDouble();
      await _appendWaterHistoryMl(ml);
      await _repo.addWater(
        entryDate: DateTime.now(),
        liters: double.parse(next.toStringAsFixed(2)),
      );
      if (!mounted) return;
      Navigator.pop(ctx);
      await _load();
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final t = _PersonalText.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: _sheetDecoration(ctx),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(ctx),
                _SheetTitle(
                  icon: Icons.add_rounded,
                  title: t.waterAddTitle,
                  accent: Theme.of(ctx).colorScheme.tertiary,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _WaterAmountButton(
                        label: t.waterCup250,
                        onTap: () => saveMl(ctx, 250),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _WaterAmountButton(
                        label: t.waterGlass200,
                        onTap: () => saveMl(ctx, 200),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: customCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ladnaText(ctx),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: t.waterCustomMlLabel,
                    prefixIcon: const Icon(Icons.edit_rounded, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final ml = int.tryParse(customCtrl.text.trim()) ?? 0;
                      await saveMl(ctx, ml);
                    },
                    icon: const Icon(Icons.water_drop_rounded, size: 18),
                    label: Text(t.waterCustomOption),
                  ),
                ),
              ],
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
            onTap: _editTarget,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
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
            targetLiters: _waterTargetLiters,
            onTap: _openWaterOverview,
            onAddTap: _addWaterAmount,
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
  final VoidCallback onTap;

  const _HealthHero({
    required this.consumed,
    required this.burned,
    required this.net,
    required this.target,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0).toDouble();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
      clipBehavior: Clip.antiAlias,
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
              fontFamily: 'PlayfairDisplay',
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
                  fontSize: 11.2,
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
  final double targetLiters;
  final VoidCallback onTap;
  final VoidCallback onAddTap;

  const _WaterCard({
    required this.liters,
    required this.targetLiters,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final safeTarget = targetLiters <= 0 ? 2.0 : targetLiters;
    final progress = (liters / safeTarget).clamp(0.0, 1.0).toDouble();

    return _LadnaCard(
      padding: const EdgeInsets.all(12),
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
                    fontSize: 12.5,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    child: Text(
                      _PersonalText.of(context).waterLiters(liters, safeTarget),
                      style: TextStyle(
                        color: _ladnaSoftText(context),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Tooltip(
                  message: _PersonalText.of(context).waterEditTarget,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _ladnaSubtleBg(context),
                        border: Border.all(
                          color: _ladnaAccent(context).withOpacity(_ladnaIsDark(context) ? 0.30 : 0.22),
                        ),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: _ladnaAccent(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onAddTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _ladnaAccent(context).withOpacity(_ladnaIsDark(context) ? 0.18 : 0.14),
                      border: Border.all(
                        color: _ladnaAccent(context).withOpacity(_ladnaIsDark(context) ? 0.38 : 0.28),
                      ),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 17,
                      color: _ladnaAccent(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final thumbLeft = (width - 24) * progress;
                return SizedBox(
                  height: 28,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: _ladnaSubtleBg(context),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6B54C0),
                          ),
                        ),
                      ),
                      Positioned(
                        left: thumbLeft,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _ladnaCardBg(context),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _ladnaAccent(context).withOpacity(0.45),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _ladnaAccent(context).withOpacity(0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('💧', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterAmountButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WaterAmountButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: _ladnaSubtleBg(context).withOpacity(_ladnaIsDark(context) ? 0.55 : 0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _ladnaSubtleBorder(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop_rounded, size: 17, color: _ladnaAccent(context)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _ladnaText(context),
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

class _WaterSummaryLine extends StatelessWidget {
  final String title;
  final String value;

  const _WaterSummaryLine({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _ladnaSubtleBg(context).withOpacity(_ladnaIsDark(context) ? 0.55 : 0.75),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _ladnaSubtleBorder(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _ladnaText(context),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: _ladnaSoftText(context),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: tone.withOpacity(0.12),
            border: Border.all(color: tone.withOpacity(0.24)),
          ),
          child: Icon(icon, color: tone, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w600,
                  color: _ladnaText(context),
                ),
          ),
        ),
      ],
    );
  }
}
