import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../widgets/mood_selector.dart';

import '../models/mood_model.dart';
import '../models/mood.dart';

import '../widgets/nest/nest_background.dart';
import '../widgets/nest/nest_blur_card.dart';

import '../main.dart'; // dbRepo

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MoodModel(repo: dbRepo)..load(),
      child: const _MoodView(),
    );
  }
}

class _MoodView extends StatefulWidget {
  const _MoodView();

  @override
  State<_MoodView> createState() => _MoodViewState();
}

class _MoodViewState extends State<_MoodView> {
  String _selectedEmoji = '😊';
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  DateTime _visibleWeekStart = _startOfWeek(DateUtils.dateOnly(DateTime.now()));
  bool _saving = false;

  static const int _maxLen = 200;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Date helpers
  // ---------------------------------------------------------------------------

  static DateTime _startOfWeek(DateTime date) {
    final d = DateUtils.dateOnly(date);
    final weekday = d.weekday; // Mon=1 ... Sun=7
    return d.subtract(Duration(days: weekday - 1));
  }

  List<DateTime> _daysOfWeek(DateTime weekStart) {
    return List.generate(
      7,
      (index) => DateUtils.dateOnly(weekStart.add(Duration(days: index))),
    );
  }

  String _formatDateShort(BuildContext context, DateTime d) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatMediumDate(d);
  }

  String _formatWeekRange(BuildContext context, DateTime weekStart) {
    final loc = MaterialLocalizations.of(context);
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${loc.formatMediumDate(weekStart)} – ${loc.formatMediumDate(weekEnd)}';
  }

  String _weekdayShort(BuildContext context, DateTime date) {
  switch (date.weekday) {
    case DateTime.monday:
      return 'Mon';
    case DateTime.tuesday:
      return 'Tue';
    case DateTime.wednesday:
      return 'Wed';
    case DateTime.thursday:
      return 'Thu';
    case DateTime.friday:
      return 'Fri';
    case DateTime.saturday:
      return 'Sat';
    case DateTime.sunday:
      return 'Sun';
    default:
      return '';
  }
}
  

  Map<DateTime, Mood> _moodMapByDay(List<Mood> moods) {
    final map = <DateTime, Mood>{};
    for (final mood in moods) {
      map[DateUtils.dateOnly(mood.date)] = mood;
    }
    return map;
  }

  bool _isToday(DateTime date) {
    return DateUtils.isSameDay(date, DateTime.now());
  }

  bool _isSelected(DateTime date) {
    return DateUtils.isSameDay(date, _selectedDate);
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final cs = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: cs.copyWith(surface: cs.surface),
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (d != null) {
      final normalized = DateUtils.dateOnly(d);
      setState(() {
        _selectedDate = normalized;
        _visibleWeekStart = _startOfWeek(normalized);
      });
    }
  }

  Future<void> _refresh() async {
    await context.read<MoodModel>().load();
  }

  Future<String?> _saveMood({
    required DateTime date,
    required String emoji,
    required String note,
  }) async {
    try {
      final model = context.read<MoodModel>();
      await model.repo.upsertMood(
        date: DateUtils.dateOnly(date),
        emoji: emoji,
        note: note,
      );
      await model.load();
      return null;
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      return l.moodErrSaveFailed('$e');
    }
  }

  Future<String?> _updateMood({
    required DateTime originalDate,
    required DateTime newDate,
    required String emoji,
    required String note,
  }) async {
    try {
      final model = context.read<MoodModel>();
      final orig = DateUtils.dateOnly(originalDate);
      final next = DateUtils.dateOnly(newDate);

      await model.repo.upsertMood(date: next, emoji: emoji, note: note);
      if (orig != next) {
        await model.repo.deleteMoodByDate(orig);
      }
      await model.load();
      return null;
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      return l.moodErrUpdateFailed('$e');
    }
  }

  Future<String?> _deleteMood(DateTime date) async {
    try {
      final model = context.read<MoodModel>();
      await model.repo.deleteMoodByDate(DateUtils.dateOnly(date));
      await model.load();
      return null;
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      return l.moodErrDeleteFailed('$e');
    }
  }

  Future<void> _save() async {
    if (_saving) return;

    final l = AppLocalizations.of(context)!;
    final note = _noteController.text.trim();

    setState(() => _saving = true);
    final err = await _saveMood(
      date: _selectedDate,
      emoji: _selectedEmoji,
      note: note,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (err != null) {
      _snack(err);
      return;
    }

    _noteController.clear();
    setState(() {
      _selectedEmoji = '😊';
      _selectedDate = DateUtils.dateOnly(DateTime.now());
      _visibleWeekStart = _startOfWeek(_selectedDate);
    });

    _snack(l.moodSaved);
  }

  Future<void> _editMood(Mood mood) async {
    final res = await showDialog<_EditMoodResult>(
      context: context,
      builder: (_) => _EditMoodDialog(initial: mood),
    );
    if (res == null) return;

    final l = AppLocalizations.of(context)!;

    if (res.delete) {
      final err = await _deleteMood(mood.date);
      if (err != null && mounted) _snack(err);
      return;
    }

    final err = await _updateMood(
      originalDate: mood.date,
      newDate: res.date,
      emoji: res.emoji,
      note: res.note,
    );

    if (!mounted) return;

    if (err != null) {
      _snack(err);
    } else {
      setState(() {
        _selectedDate = DateUtils.dateOnly(res.date);
        _visibleWeekStart = _startOfWeek(_selectedDate);
      });
      _snack(l.moodUpdated);
    }
  }

  Future<void> _confirmDeleteMood(Mood mood) async {
    final l = AppLocalizations.of(context)!;

    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Text(l.commonDeleteConfirmTitle),
            content: Text(
              '${_formatDateShort(context, DateUtils.dateOnly(mood.date))}: '
              '${mood.emoji}'
              '${mood.note.trim().isEmpty ? '' : '\n\n${mood.note.trim()}'}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.commonCancel),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.commonDelete),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    final err = await _deleteMood(mood.date);
    if (err != null && mounted) {
      _snack(err);
    }
  }

  Future<void> _openDayPopup(DateTime day, Mood? mood) async {
    if (mood == null) {
      setState(() {
        _selectedDate = DateUtils.dateOnly(day);
      });
      return;
    }

    final action = await showModalBottomSheet<_DayMoodAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DayMoodSheet(
        date: day,
        mood: mood,
        formatDate: (d) => _formatDateShort(context, d),
      ),
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _DayMoodAction.edit:
        await _editMood(mood);
        break;
      case _DayMoodAction.delete:
        await _confirmDeleteMood(mood);
        break;
    }
  }

  void _goToPreviousWeek() {
    setState(() {
      _visibleWeekStart = _visibleWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _goToNextWeek() {
    final next = _visibleWeekStart.add(const Duration(days: 7));
    final currentWeek = _startOfWeek(DateUtils.dateOnly(DateTime.now()));

    if (next.isAfter(currentWeek)) return;

    setState(() {
      _visibleWeekStart = next;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<MoodModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final moods = model.moods;
    final loading = model.loading;
    final moodByDay = _moodMapByDay(moods);
    final weekDays = _daysOfWeek(_visibleWeekStart);
    final currentWeekStart = _startOfWeek(DateUtils.dateOnly(DateTime.now()));
    final canGoNext = !_visibleWeekStart.isAtSameMomentAs(currentWeekStart);

    return Scaffold(
      body: NestBackground(
        child: RefreshIndicator.adaptive(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: NestBlurCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _NestChipButton(
                                icon: Icons.calendar_month_rounded,
                                label: _formatDateShort(context, _selectedDate),
                                onTap: _pickDate,
                              ),
                              _NestChipInfo(
                                icon: Icons.auto_awesome_rounded,
                                label: l.moodOnePerDay,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l.moodHowDoYouFeel,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _NestInset(
                            radius: 18,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              child: MoodSelector(
                                selectedEmoji: _selectedEmoji,
                                onSelect: (emoji) =>
                                    setState(() => _selectedEmoji = emoji),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _NestTextField(
                            controller: _noteController,
                            maxLines: 3,
                            maxLength: _maxLen,
                            labelText: l.moodNoteLabel,
                            hintText: l.moodNoteHint,
                            prefixIcon: Icons.edit_note_rounded,
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator.adaptive(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              cs.onPrimary,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded),
                              label: Text(
                                _saving ? l.commonSaving : l.commonSave,
                              ),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // -----------------------------------------------------------------
              // Weekly calendar header
              // -----------------------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      Text(
                        l.moodHistoryTitle,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      if (!loading && moods.isNotEmpty)
                        Text(
                          '${moods.length}',
                          style: tt.labelLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (moods.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    emoji: '📝',
                    title: null,
                    subtitle: null,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: NestBlurCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _goToPreviousWeek,
                                  icon: const Icon(Icons.chevron_left_rounded),
                                ),
                                Expanded(
                                  child: Text(
                                    _formatWeekRange(context, _visibleWeekStart),
                                    textAlign: TextAlign.center,
                                    style: tt.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: canGoNext ? _goToNextWeek : null,
                                  icon: const Icon(Icons.chevron_right_rounded),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: weekDays
                                  .map(
                                    (day) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: _WeekDayCell(
                                          day: day,
                                          weekdayLabel:
                                              _weekdayShort(context, day),
                                          mood: moodByDay[day],
                                          isToday: _isToday(day),
                                          isSelected: _isSelected(day),
                                          onTap: () => _openDayPopup(
                                            day,
                                            moodByDay[day],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Weekly calendar cell
// ============================================================================

class _WeekDayCell extends StatelessWidget {
  final DateTime day;
  final String weekdayLabel;
  final Mood? mood;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const _WeekDayCell({
    required this.day,
    required this.weekdayLabel,
    required this.mood,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasMood = mood != null;

    Color bgColor;
    Color borderColor;

    if (isSelected) {
      bgColor = cs.primary.withOpacity(0.18);
      borderColor = cs.primary;
    } else if (isToday) {
      bgColor = cs.secondaryContainer.withOpacity(0.45);
      borderColor = cs.secondary.withOpacity(0.75);
    } else {
      bgColor = cs.surfaceContainerHighest.withOpacity(0.22);
      borderColor = cs.outlineVariant.withOpacity(0.40);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: bgColor,
            border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1),
          ),
          child: Column(
            children: [
              Text(
                weekdayLabel,
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${day.day}',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 28,
                child: Center(
                  child: hasMood
                      ? Text(
                          mood!.emoji,
                          style: const TextStyle(fontSize: 22),
                        )
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.outlineVariant.withOpacity(0.55),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Bottom sheet for selected day
// ============================================================================

enum _DayMoodAction { edit, delete }

class _DayMoodSheet extends StatelessWidget {
  final DateTime date;
  final Mood mood;
  final String Function(DateTime d) formatDate;

  const _DayMoodSheet({
    required this.date,
    required this.mood,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final note = mood.note.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: NestBlurCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                mood.emoji,
                style: const TextStyle(fontSize: 42),
              ),
              const SizedBox(height: 8),
              Text(
                formatDate(date),
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: cs.outlineVariant.withOpacity(0.35),
                  ),
                ),
                child: Text(
                  note.isEmpty ? '—' : note,
                  style: tt.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () =>
                          Navigator.pop(context, _DayMoodAction.edit),
                      icon: const Icon(Icons.edit_rounded),
                      label: Text(
                        AppLocalizations.of(context)!.commonEdit,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () =>
                          Navigator.pop(context, _DayMoodAction.delete),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(
                        AppLocalizations.of(context)!.commonDelete,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.errorContainer.withOpacity(0.75),
                        foregroundColor: cs.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Nest small UI helpers
// ============================================================================

class _NestInset extends StatelessWidget {
  final Widget child;
  final double radius;
  const _NestInset({required this.child, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.35),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
          ),
          child: Stack(
            children: [
              child,
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.white.withOpacity(0.18),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NestChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NestChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: _NestInset(
          radius: 999,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NestChipInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NestChipInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return _NestInset(
      radius: 999,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: tt.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NestTextField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLines;
  final int? maxLength;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;

  const _NestTextField({
    required this.controller,
    required this.maxLines,
    required this.maxLength,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withOpacity(0.30),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.65)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cs.primary, width: 1.4),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Dialog
// -----------------------------------------------------------------------------

class _EditMoodResult {
  final bool delete;
  final DateTime date;
  final String emoji;
  final String note;

  _EditMoodResult({
    required this.delete,
    required this.date,
    required this.emoji,
    required this.note,
  });
}

class _EditMoodDialog extends StatefulWidget {
  final Mood initial;
  const _EditMoodDialog({required this.initial});

  @override
  State<_EditMoodDialog> createState() => _EditMoodDialogState();
}

class _EditMoodDialogState extends State<_EditMoodDialog> {
  late DateTime _date;
  late String _emoji;
  late TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _date = DateUtils.dateOnly(widget.initial.date);
    _emoji = widget.initial.emoji;
    _note = TextEditingController(text: widget.initial.note);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String _format(BuildContext context, DateTime d) {
    return MaterialLocalizations.of(context).formatMediumDate(d);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _date = DateUtils.dateOnly(d));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(l.moodEditTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${l.commonDate}: ${_format(context, _date)}'),
              ),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(l.commonChange),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MoodSelector(
            selectedEmoji: _emoji,
            onSelect: (e) => setState(() => _emoji = e),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l.moodNoteLabel,
              filled: true,
              fillColor: cs.surfaceContainerHighest.withOpacity(0.30),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(
            context,
            _EditMoodResult(
              delete: true,
              date: _date,
              emoji: _emoji,
              note: _note.text.trim(),
            ),
          ),
          icon: Icon(Icons.delete_outline_rounded, color: cs.error),
          label: Text(l.commonDelete, style: TextStyle(color: cs.error)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _EditMoodResult(
              delete: false,
              date: _date,
              emoji: _emoji,
              note: _note.text.trim(),
            ),
          ),
          child: Text(l.commonSave),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Empty state
// -----------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final String emoji;
  final String? title;
  final String? subtitle;

  const _EmptyState({required this.emoji, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 72,
                height: 72,
                color: cs.surfaceContainerHighest.withOpacity(0.30),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title ?? l.moodEmptyTitle,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? l.moodEmptySubtitle,
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}