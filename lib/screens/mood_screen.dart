import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/mood_selector.dart';
import '../models/mood_model.dart';
import '../models/mood.dart';
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
  bool _saving = false;

  static const int _maxLen = 200;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  String _formatDateShort(BuildContext context, DateTime d) {
    // Локализованно и красиво (без intl)
    final loc = MaterialLocalizations.of(context);
    return loc.formatMediumDate(d);
  }

  String _formatDateHeader(BuildContext context, DateTime d) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatFullDate(d);
  }

  Map<DateTime, List<Mood>> _groupByDay(List<Mood> src) {
    final map = <DateTime, List<Mood>>{};
    for (final m in src) {
      final key = DateUtils.dateOnly(m.date);
      map.putIfAbsent(key, () => []).add(m);
    }
    final entries = map.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    return {for (final e in entries) e.key: e.value};
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
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (d != null) setState(() => _selectedDate = DateUtils.dateOnly(d));
}


  Future<void> _save(BuildContext context) async {
    if (_saving) return;
    final note = _noteController.text.trim();

    setState(() => _saving = true);

    final err = await context.read<MoodModel>().saveMoodForDate(
          date: _selectedDate,
          emoji: _selectedEmoji,
          note: note,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    _noteController.clear();
    setState(() {
      _selectedEmoji = '😊';
      _selectedDate = DateUtils.dateOnly(DateTime.now());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Настроение сохранено'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refresh() async {
    await context.read<MoodModel>().load();
  }

  Future<void> _editMood(BuildContext context, Mood mood) async {
    final res = await showDialog<_EditMoodResult>(
      context: context,
      builder: (_) => _EditMoodDialog(initial: mood),
    );
    if (res == null) return;

    final m = context.read<MoodModel>();

    if (res.delete) {
      final err = await m.deleteMoodByDate(mood.date);
      if (err != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
        );
      }
      return;
    }

    final err = await m.updateMoodByDate(
      originalDate: mood.date,
      newDate: res.date,
      emoji: res.emoji,
      note: res.note,
    );

    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MoodModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final moods = model.moods;
    final loading = model.loading;

    final grouped = _groupByDay(moods);

    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              title: const Text('Настроение'),
              centerTitle: false,
              actions: [
                IconButton(
                  tooltip: 'Обновить',
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),

            // --- Composer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: _GlassCard(
                  borderRadius: 22,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top row: date + save
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _ChipButton(
                                    icon: Icons.calendar_month_rounded,
                                    label: _formatDateShort(context, _selectedDate),
                                    onTap: _pickDate,
                                  ),
                                  _ChipInfo(
                                    icon: Icons.auto_awesome_rounded,
                                    label: '1 запись = 1 день',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Text(
                          'Как ты себя чувствуешь?',
                          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),

                        // Emoji selector (your widget)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
                          ),
                          child: MoodSelector(
                            selectedEmoji: _selectedEmoji,
                            onSelect: (emoji) => setState(() => _selectedEmoji = emoji),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Note field
                        TextField(
                          controller: _noteController,
                          maxLines: 3,
                          maxLength: _maxLen,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Заметка (необязательно)',
                            hintText: 'Что повлияло на твоё состояние?',
                            prefixIcon: const Icon(Icons.edit_note_rounded),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withOpacity(0.45),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: cs.outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.7)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: cs.primary, width: 1.4),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Save button
                        SizedBox(
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : () => _save(context),
                            icon: _saving
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                                    ),
                                  )
                                : const Icon(Icons.check_rounded),
                            label: Text(_saving ? 'Сохранение…' : 'Сохранить'),
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

            // --- History header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Row(
                  children: [
                    Text(
                      'История',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    if (!loading && moods.isNotEmpty)
                      Text(
                        '${moods.length}',
                        style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
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
                  title: 'Пока нет записей',
                  subtitle: 'Выбери дату, отметь настроение и сохрани запись.',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // строим список "дата header + items"
                    final entries = grouped.entries.toList();
                    int cursor = 0;

                    for (final entry in entries) {
                      final date = entry.key;
                      final items = entry.value;
                      // 1 строка header + N items
                      final blockLen = 1 + items.length;

                      if (index >= cursor && index < cursor + blockLen) {
                        final innerIndex = index - cursor;

                        if (innerIndex == 0) {
                          // header
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                            child: Text(
                              _formatDateHeader(context, date),
                              style: tt.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        final mood = items[innerIndex - 1];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _MoodHistoryTile(
                            mood: mood,
                            onEdit: () => _editMood(context, mood),
                            onDelete: () async {
                              final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Удалить запись?'),
                                      content: Text(
                                        '${_formatDateShort(context, DateUtils.dateOnly(mood.date))}: '
                                        '${mood.emoji}'
                                        '${mood.note.isEmpty ? '' : '\n\n${mood.note}'}',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Отмена'),
                                        ),
                                        FilledButton.tonal(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Удалить'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;

                              if (!ok) return;

                              final err =
                                  await context.read<MoodModel>().deleteMoodByDate(mood.date);
                              if (err != null && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(err),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      }

                      cursor += blockLen;
                    }

                    return const SizedBox.shrink();
                  },
                  childCount: grouped.entries.fold<int>(
                    0,
                    (sum, e) => sum + 1 + e.value.length, // header + items
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Modern UI pieces
// -----------------------------------------------------------------------------

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  const _GlassCard({required this.child, this.borderRadius = 20});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.55),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.55),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ChipInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _MoodHistoryTile extends StatelessWidget {
  final Mood mood;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  const _MoodHistoryTile({
    required this.mood,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final note = mood.note.trim();
    final title = note.isEmpty ? 'Без заметки' : note;

    return Dismissible(
      key: ValueKey('mood_${DateUtils.dateOnly(mood.date).toIso8601String()}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        // Делаем "свайп" безопасным: подтверждаем
        await onDelete();
        return false; // удаление сделаем через model, а Dismissible не убираем сам
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: cs.errorContainer.withOpacity(0.55),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.delete_rounded, color: cs.onErrorContainer),
      ),
      child: _GlassCard(
        borderRadius: 18,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          leading: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
            ),
            child: Text(mood.emoji, style: const TextStyle(fontSize: 22)),
          ),
          title: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            'Нажми, чтобы редактировать',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing: Icon(Icons.edit_rounded, color: cs.onSurfaceVariant),
          onTap: onEdit,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Dialog (оставил твой, слегка полирнул стили)
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
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text('Редактировать запись'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text('Дата: ${_format(context, _date)}')),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Изменить'),
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
              labelText: 'Заметка',
              filled: true,
              fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
          label: Text('Удалить', style: TextStyle(color: cs.error)),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
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
          child: const Text('Сохранить'),
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
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.55),
                shape: BoxShape.circle,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 34)),
            ),
            const SizedBox(height: 14),
            Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXTENSIONS НА МОДЕЛЬ — как у тебя (без id).
// ─────────────────────────────────────────────────────────────────────────────

extension MoodModelOps on MoodModel {
  Future<String?> saveMoodForDate({
    required DateTime date,
    required String emoji,
    required String note,
  }) async {
    try {
      await repo.upsertMood(
        date: DateUtils.dateOnly(date),
        emoji: emoji,
        note: note,
      );
      await load();
      return null;
    } catch (e) {
      return 'Не удалось сохранить настроение: $e';
    }
  }

  Future<String?> updateMoodByDate({
    required DateTime originalDate,
    required DateTime newDate,
    required String emoji,
    required String note,
  }) async {
    try {
      final orig = DateUtils.dateOnly(originalDate);
      final next = DateUtils.dateOnly(newDate);

      await repo.upsertMood(date: next, emoji: emoji, note: note);
      if (orig != next) {
        await repo.deleteMoodByDate(orig);
      }
      await load();
      return null;
    } catch (e) {
      return 'Не удалось обновить запись: $e';
    }
  }

  Future<String?> deleteMoodByDate(DateTime date) async {
    try {
      await repo.deleteMoodByDate(DateUtils.dateOnly(date));
      await load();
      return null;
    } catch (e) {
      return 'Не удалось удалить запись: $e';
    }
  }
}
