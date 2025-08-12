import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mood.dart';
import '../services/db_repo.dart';
import '../widgets/mood_selector.dart';
import '../models/mood_model.dart';
import '../main.dart'; // берём dbRepo, как и раньше

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // пробрасываем репозиторий из твоего singletons из main.dart
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

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;

    final model = context.read<MoodModel>();
    final err = await model.saveMood(emoji: _selectedEmoji, note: note);
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    if (mounted) _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MoodModel>();
    final moods = model.moods;
    final loading = model.loading;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 10),
            const Text('Mood', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFF7F9FB),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Выбор эмоции
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MoodSelector(
                  selectedEmoji: _selectedEmoji,
                  onSelect: (emoji) => setState(() => _selectedEmoji = emoji),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Заметка
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Добавьте заметку...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Кнопка сохранить
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Сохранить настроение'),
                onPressed: () => _save(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),

            // История настроений
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : moods.isEmpty
                      ? const Center(
                          child: Text('Нет записей настроения', style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          itemCount: moods.length,
                          itemBuilder: (ctx, index) {
                            final mood = moods[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: Text(mood.emoji, style: const TextStyle(fontSize: 28)),
                                title: Text(mood.note.isEmpty ? 'Без заметки' : mood.note),
                                subtitle: Text(
                                  '${mood.date.day.toString().padLeft(2, '0')}/'
                                  '${mood.date.month.toString().padLeft(2, '0')}/'
                                  '${mood.date.year}',
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
