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
        '${liters.toStringAsFixed(1)} / 2.0 л',
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


class HobbyTrackerCard extends StatefulWidget {
  const HobbyTrackerCard({super.key});

  @override
  State<HobbyTrackerCard> createState() => _HobbyTrackerCardState();
}

class _HobbyTrackerCardState extends State<HobbyTrackerCard> {
  final _repo = HomeTrackersRepo();
  bool _loading = true;
  List<HobbySummary> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _repo.listHobbySummariesForWeek(DateTime.now());
      if (!mounted) return;
      setState(() => _items = items);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtMinutes(BuildContext context, int minutesTotal) {
    final l = AppLocalizations.of(context)!;
    final h = minutesTotal ~/ 60;
    final min = minutesTotal % 60;
    if (h == 0) return l.hobbyTrackerMinutesShort(min);
    if (min == 0) return l.hobbyTrackerHoursShort(h);
    return l.hobbyTrackerHoursMinutesShort(h, min);
  }

  Future<void> _showCreateHobbySheet() async {
    final l = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(cs.surfaceContainerLowest, cs.secondary, 0.045)!,
                  Color.lerp(cs.surfaceContainerLow, cs.primary, 0.025)!,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Color.lerp(cs.outlineVariant, cs.secondary, 0.22)!,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.secondary.withOpacity(0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: cs.primary.withOpacity(0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.hobbyTrackerNewHobbyTitle,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: l.hobbyTrackerHobbyNameLabel,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l.hobbyTrackerEnterHobbyValidator
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: targetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l.hobbyTrackerWeeklyGoalMinutesLabel,
                    ),
                    validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                        ? l.hobbyTrackerEnterGoalValidator
                        : null,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) return;
                        await _repo.createHobby(
                          title: titleCtrl.text.trim(),
                          targetMinutesWeek: int.parse(targetCtrl.text.trim()),
                        );
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        await _load();
                      },
                      icon: Icon(Icons.add_rounded),
                      label: Text(l.hobbyTrackerCreateButton),
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

  Future<void> _showAddEntrySheet(HobbySummary hobby) async {
    final l = AppLocalizations.of(context)!;
    final minutesCtrl = TextEditingController();
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(cs.surfaceContainerLowest, cs.secondary, 0.045)!,
                  Color.lerp(cs.surfaceContainerLow, cs.primary, 0.025)!,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Color.lerp(cs.outlineVariant, cs.secondary, 0.22)!,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.secondary.withOpacity(0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: cs.primary.withOpacity(0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.hobbyTrackerAddTimeTitle(hobby.hobbyTitle),
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: minutesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.hobbyTrackerMinutesSpentLabel,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    labelText: l.hobbyTrackerNoteLabel,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final minutes = int.tryParse(minutesCtrl.text.trim()) ?? 0;
                      if (minutes <= 0) return;
                      await _repo.addHobbyEntry(
                        hobbyId: hobby.hobbyId,
                        entryDate: DateTime.now(),
                        minutesSpent: minutes,
                        note: noteCtrl.text.trim(),
                      );
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      await _load();
                    },
                    icon: Icon(Icons.timer_rounded),
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

  Future<void> _deleteHobby(HobbySummary hobby) async {
    final l = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.hobbyTrackerDeleteConfirmTitle),
            content: Text(l.hobbyTrackerDeleteConfirmBody(hobby.hobbyTitle)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.commonDelete),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    await _repo.deleteHobby(hobby.hobbyId);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final totalWeek = _items.fold<int>(
      0,
      (sum, item) => sum + item.spentMinutesWeek,
    );
    final totalTarget = _items.fold<int>(
      0,
      (sum, item) => sum + item.targetMinutesWeek,
    );
    final progress = totalTarget <= 0 ? 0.0 : (totalWeek / totalTarget).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HobbyHero(
          total: _fmtMinutes(context, totalWeek),
          target: totalTarget <= 0 ? '—' : _fmtMinutes(context, totalTarget),
          progress: progress,
          onAdd: _showCreateHobbySheet,
        ),
        const SizedBox(height: 14),
        _SectionLabel(text: _PersonalText.of(context).hobbyDirections),
        const SizedBox(height: 8),
        if (_loading)
          const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else if (_items.isEmpty)
          _LadnaCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.hobbyTrackerEmptyText,
                  style: TextStyle(
                    color: _ladnaMuted(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _showCreateHobbySheet,
                  icon: Icon(Icons.add_rounded),
                  label: Text(l.hobbyTrackerCreateHobbyButton),
                ),
              ],
            ),
          )
        else
          _LadnaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final hobby in _items) ...[
                  _HobbyRow(
                    title: hobby.hobbyTitle,
                    today: _fmtMinutes(context, hobby.spentMinutesToday),
                    week: _fmtMinutes(context, hobby.spentMinutesWeek),
                    target: _fmtMinutes(context, hobby.targetMinutesWeek),
                    progress: hobby.weekProgress,
                    onAdd: () => _showAddEntrySheet(hobby),
                    onDelete: () => _deleteHobby(hobby),
                  ),
                  if (hobby != _items.last)
                    Divider(height: 1, color: _ladnaCardBorder(context)),
                ],
              ],
            ),
          ),
        const SizedBox(height: 14),
        _SectionLabel(text: _PersonalText.of(context).today),
        const SizedBox(height: 8),
        _LadnaCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final hobby in _items.where((h) => h.spentMinutesToday > 0)) ...[
                _TodayRow(
                  title: hobby.hobbyTitle,
                  value: _fmtMinutes(context, hobby.spentMinutesToday),
                  onTap: () => _showAddEntrySheet(hobby),
                ),
                if (hobby != _items.where((h) => h.spentMinutesToday > 0).last)
                  Divider(height: 1, color: _ladnaCardBorder(context)),
              ],
              if (_items.where((h) => h.spentMinutesToday > 0).isEmpty)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    l.hobbyTrackerEmptyText,
                    style: TextStyle(
                      color: _ladnaMuted(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              InkWell(
                onTap: _items.isEmpty ? _showCreateHobbySheet : () => _showAddEntrySheet(_items.first),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l.hobbyTrackerAddEntryButton,
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
      ],
    );
  }
}

class _HobbyHero extends StatelessWidget {
  final String total;
  final String target;
  final double progress;
  final VoidCallback onAdd;

  const _HobbyHero({
    required this.total,
    required this.target,
    required this.progress,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return _LadnaCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _PersonalText.of(context).hobbyWeek,
                  style: TextStyle(
                    color: _ladnaText(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _ladnaSubtleBg(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _ladnaSubtleBorder(context)),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: _ladnaAccent(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                total,
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 30,
                  height: 1,
                  color: _ladnaText(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '/ $target',
                  style: TextStyle(
                    color: _ladnaMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
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
        ],
      ),
    );
  }
}

class _HobbyRow extends StatelessWidget {
  final String title;
  final String today;
  final String week;
  final String target;
  final double progress;
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  const _HobbyRow({
    required this.title,
    required this.today,
    required this.week,
    required this.target,
    required this.progress,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(13),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _ladnaAccent(context),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: _ladnaText(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: _ladnaMuted(context),
                ),
              ),
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _ladnaSubtleBg(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '+',
                    style: TextStyle(
                      color: _ladnaAccent(context),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Сегодня $today',
                style: TextStyle(
                  color: _ladnaMuted(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$week / $target',
                style: TextStyle(
                  color: _ladnaMuted(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 6,
              backgroundColor: _ladnaSubtleBg(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.75
                    ? const Color(0xFF16B8A8)
                    : const Color(0xFF6B54C0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _TodayRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Icon(
              Icons.palette_rounded,
              size: 18,
              color: _ladnaAccent(context),
            ),
            const SizedBox(width: 10),
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

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _ladnaSubtleBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _ladnaSubtleBorder(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _ladnaAccent(context)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: _ladnaText(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
