import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/mood_selector.dart';
import '../models/mood_model.dart';
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
  bool _saving = false;

  static const int _maxLen = 200;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final note = _noteController.text.trim();
    if (note.isEmpty || _saving) return;

    setState(() => _saving = true);
    final model = context.read<MoodModel>();

    final err = await model.saveMood(emoji: _selectedEmoji, note: note);
    if (!mounted) return;

    setState(() => _saving = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    _noteController
      ..clear()
      ..text = ''; // чтобы counter обновился
    await model.load();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настроение сохранено')),
    );
  }

  Future<void> _refresh() async {
    await context.read<MoodModel>().load();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MoodModel>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final moods = model.moods;
    final loading = model.loading;
    final isNoteEmpty = _noteController.text.trim().isEmpty;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isWide = w >= 900; // десктоп/планшет
        final isCompactBar = w < 480; // компактная шапка для iPhone

        // ============ МОБИЛА / УЗКИЙ ============
        if (!isWide) {
          return Scaffold(
            body: RefreshIndicator.adaptive(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // компактная шапка на телефонах
                  if (isCompactBar)
                    SliverAppBar.medium(
                      title: const Text('Настроение'),
                      centerTitle: false,
                      actions: [
                        IconButton(
                          tooltip: 'Обновить',
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    )
                  else
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

                  // Выбор эмоции (карточка с побольше тач-зоной)
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
                          child: MoodSelector(
                            selectedEmoji: _selectedEmoji,
                            onSelect: (emoji) => setState(() => _selectedEmoji = emoji),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Поле заметки
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 4,
                        maxLength: _maxLen,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText: 'Заметка к настроению',
                          hintText: 'Что повлияло на твоё состояние?',
                          prefixIcon: const Icon(Icons.note_alt_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          counterText: '${_noteController.text.trim().length}/$_maxLen',
                        ),
                      ),
                    ),
                  ),

                  // Кнопка сохранить
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: Text(_saving ? 'Сохранение…' : 'Сохранить настроение'),
                          onPressed: (!isNoteEmpty && !_saving) ? () => _save(context) : null,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(),
                    ),
                  ),

                  // История
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
                        subtitle:
                            'Выбери эмодзи, добавь пару слов и нажми «Сохранить» — так начнём отслеживать динамику.',
                      ),
                    )
                  else
                    SliverList.separated(
                      itemCount: moods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (ctx, index) {
                        final mood = moods[index];
                        final date = mood.date;
                        final dd = date.day.toString().padLeft(2, '0');
                        final mm = date.month.toString().padLeft(2, '0');
                        final yyyy = date.year.toString();

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                          child: Material(
                            color: scheme.surfaceContainerHighest.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              leading:
                                  Text(mood.emoji, style: const TextStyle(fontSize: 28)),
                              title: Text(
                                mood.note.isEmpty ? 'Без заметки' : mood.note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text('$dd.$mm.$yyyy'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: scheme.outlineVariant),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              trailing:
                                  Icon(Icons.chevron_right, color: scheme.outline),
                              onTap: () {
                                // TODO: детальная карточка/редактирование
                              },
                            ),
                          ),
                        );
                      },
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          );
        }

        // ============ ШИРОКИЙ ЭКРАН ============ //
        return Scaffold(
          appBar: AppBar(
            title: const Text('Настроение'),
            actions: [
              IconButton(
                tooltip: 'Обновить',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Row(
            children: [
              // Левая колонка: селектор + заметка + сохранить
              Expanded(
                flex: 5,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 12, 24),
                  children: [
                    Card(
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: scheme.outlineVariant),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: MoodSelector(
                          selectedEmoji: _selectedEmoji,
                          onSelect: (emoji) => setState(() => _selectedEmoji = emoji),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 5,
                      maxLength: _maxLen,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Заметка к настроению',
                        hintText: 'Что повлияло на твоё состояние?',
                        prefixIcon: const Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        counterText: '${_noteController.text.trim().length}/$_maxLen',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        icon: _saving
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(_saving ? 'Сохранение…' : 'Сохранить настроение'),
                        onPressed: (!isNoteEmpty && !_saving) ? () => _save(context) : null,
                      ),
                    ),
                  ],
                ),
              ),

              // Правая колонка: история
              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: scheme.outlineVariant),
                    ),
                  ),
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : (moods.isEmpty
                          ? Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 420),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: _EmptyState(
                                    emoji: '📝',
                                    title: 'Нет записей настроения',
                                    subtitle:
                                        'Выбери эмодзи, добавь пару слов и нажми «Сохранить» — так начнём отслеживать динамику.',
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(12, 16, 24, 24),
                              itemCount: moods.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (ctx, index) {
                                final mood = moods[index];
                                final date = mood.date;
                                final dd = date.day.toString().padLeft(2, '0');
                                final mm = date.month.toString().padLeft(2, '0');
                                final yyyy = date.year.toString();

                                return Material(
                                  color: scheme.surfaceContainerHighest.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListTile(
                                    leading: Text(mood.emoji,
                                        style: const TextStyle(fontSize: 28)),
                                    title: Text(
                                      mood.note.isEmpty
                                          ? 'Без заметки'
                                          : mood.note,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text('$dd.$mm.$yyyy'),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                          color: scheme.outlineVariant),
                                    ),
                                    trailing: Icon(Icons.chevron_right,
                                        color: scheme.outline),
                                    onTap: () {
                                      // TODO: детальная карточка/редактирование
                                    },
                                  ),
                                );
                              },
                            )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
    return Column(
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
    );
  }
}
