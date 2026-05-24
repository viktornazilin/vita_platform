import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';

import '../../services/home_trackers_repo.dart';
import '../report_section_card.dart';

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
                      icon: const Icon(Icons.add_rounded),
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
                    icon: const Icon(Icons.timer_rounded),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ReportSectionCard(
      title: l.hobbyTrackerTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: l.hobbyTrackerAddHobbyTooltip,
              style: IconButton.styleFrom(
                backgroundColor: Color.lerp(
                  cs.surfaceContainerHighest,
                  cs.secondary,
                  isDark ? 0.12 : 0.18,
                ),
                foregroundColor: cs.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _showCreateHobbySheet,
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ),
          if (_loading)
            const SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (_items.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.hobbyTrackerEmptyText,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _showCreateHobbySheet,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l.hobbyTrackerCreateHobbyButton),
                ),
              ],
            )
          else
            Column(
              children: [
                for (final hobby in _items) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(
                            cs.surfaceContainerLowest,
                            cs.secondary,
                            isDark ? 0.045 : 0.070,
                          )!,
                          Color.lerp(
                            cs.surfaceContainerLow,
                            cs.primary,
                            isDark ? 0.030 : 0.040,
                          )!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Color.lerp(
                          cs.outlineVariant,
                          cs.secondary,
                          isDark ? 0.16 : 0.22,
                        )!,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.secondary.withOpacity(isDark ? 0.04 : 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                hobby.hobbyTitle,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteHobby(hobby),
                              icon: const Icon(Icons.delete_outline_rounded),
                              tooltip: l.hobbyTrackerDeleteHobbyTooltip,
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () => _showAddEntrySheet(hobby),
                              icon: const Icon(Icons.add_rounded),
                              label: Text(l.hobbyTrackerAddEntryButton),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoPill(
                              icon: Icons.today_rounded,
                              text: l.hobbyTrackerToday(
                                _fmtMinutes(context, hobby.spentMinutesToday),
                              ),
                            ),
                            _InfoPill(
                              icon: Icons.date_range_rounded,
                              text: l.hobbyTrackerWeek(
                                _fmtMinutes(context, hobby.spentMinutesWeek),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: hobby.weekProgress,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(999),
                          backgroundColor: cs.surfaceContainerHighest
                              .withOpacity(isDark ? 0.28 : 0.50),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            hobby.weekProgress >= 0.75 ? cs.secondary : cs.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.hobbyTrackerGoal(
                            _fmtMinutes(context, hobby.targetMinutesWeek),
                          ),
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
        ],
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = cs.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Color.lerp(
          cs.surfaceContainerHighest,
          accent,
          isDark ? 0.10 : 0.16,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Color.lerp(cs.outlineVariant, accent, isDark ? 0.18 : 0.26)!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
