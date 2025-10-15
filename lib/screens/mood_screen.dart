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

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    _noteController.clear();
    setState(() {
      _selectedEmoji = '😊';
      _selectedDate = DateUtils.dateOnly(DateTime.now());
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Настроение сохранено')));
  }

  Future<void> _refresh() async {
    await context.read<MoodModel>().load();
  }

  // ——— редактирование/удаление записи (по дате)
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Map<DateTime, List<Mood>> _groupByDay(List<Mood> src) {
    final map = <DateTime, List<Mood>>{};
    for (final m in src) {
      final key = DateUtils.dateOnly(m.date);
      map.putIfAbsent(key, () => []).add(m);
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key)); // последние сверху
    return {for (final e in entries) e.key: e.value};
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd.$mm.$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MoodModel>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),

            // — Ввод: дата + эмоция + заметка
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: scheme.outlineVariant),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // дата + кнопка выбора
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Дата: ${_formatDate(_selectedDate)}',
                                style: textTheme.titleSmall,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_month),
                              label: const Text('Выбрать'),
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.comfortable,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // селектор эмодзи
                        MoodSelector(
                          selectedEmoji: _selectedEmoji,
                          onSelect: (emoji) => setState(() => _selectedEmoji = emoji),
                        ),
                        const SizedBox(height: 12),
                        // заметка
                        TextField(
                          controller: _noteController,
                          maxLines: 3,
                          maxLength: _maxLen,
                          decoration: InputDecoration(
                            labelText: 'Заметка к настроению (необязательно)',
                            hintText: 'Что повлияло на твоё состояние?',
                            prefixIcon: const Icon(Icons.note_alt_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // кнопка сохранить
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: _saving
                                ? const SizedBox(
                                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.save),
                            label: Text(_saving ? 'Сохранение…' : 'Сохранить'),
                            onPressed: _saving ? null : () => _save(context),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
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

            // — История (сгруппировано по датам)
            if (loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (moods.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  emoji: '📝',
                  title: 'Нет записей настроения',
                  subtitle: 'Выберите дату, отметьте эмодзи и нажмите «Сохранить».',
                ),
              )
            else
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 6),
                  ...grouped.entries.map((entry) {
                    final date = entry.key;
                    final items = entry.value;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // заголовок даты
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              _formatDate(date),
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          ...items.map((m) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Dismissible(
                                  key: ValueKey('mood_${DateUtils.dateOnly(m.date).toIso8601String()}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    color: Colors.red.withOpacity(0.15),
                                    child: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                  confirmDismiss: (_) async {
                                    return await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Удалить запись?'),
                                            content: Text(
                                                '${_formatDate(DateUtils.dateOnly(m.date))}: ${m.emoji} ${m.note.isEmpty ? '' : '• ${m.note}'}'),
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
                                  },
                                  onDismissed: (_) async {
                                    final err =
                                        await context.read<MoodModel>().deleteMoodByDate(m.date);
                                    if (err != null && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(err)),
                                      );
                                    }
                                  },
                                  child: Material(
                                    color: scheme.surfaceVariant.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                    child: ListTile(
                                      leading: Text(m.emoji, style: const TextStyle(fontSize: 28)),
                                      title: Text(
                                        m.note.isEmpty ? 'Без заметки' : m.note,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: const Text('Нажмите, чтобы редактировать'),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: scheme.outlineVariant),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      trailing: Icon(Icons.edit_outlined, color: scheme.outline),
                                      onTap: () => _editMood(context, m),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

// ——— Диалог редактирования
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
      title: const Text('Редактировать запись'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // дата
          Row(
            children: [
              Expanded(child: Text('Дата: ${_format(_date)}')),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month),
                label: const Text('Изменить'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // эмодзи
          MoodSelector(
            selectedEmoji: _emoji,
            onSelect: (e) => setState(() => _emoji = e),
          ),
          const SizedBox(height: 8),
          // заметка
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Заметка',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(
            context,
            _EditMoodResult(delete: true, date: _date, emoji: _emoji, note: _note.text.trim()),
          ),
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          label: const Text('Удалить', style: TextStyle(color: Colors.red)),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _EditMoodResult(delete: false, date: _date, emoji: _emoji, note: _note.text.trim()),
          ),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  String _format(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd.$mm.$yyyy';
  }
}

// ——— Пустое состояние
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXTENSIONS НА МОДЕЛЬ — строго по твоим методам репозитория (без id).
// Repo предоставляет: upsertMood(date, emoji, note), deleteMoodByDate(date), fetchMoods(...)
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

  /// Обновление записи:
  /// - если дата не изменилась — обычный upsert на ту же дату;
  /// - если дата изменилась — upsert на новую дату + удаление старой.
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
