import 'package:flutter/material.dart';
import '../models/mood.dart';
import '../services/db_repo.dart';
import '../widgets/mood_selector.dart';
import '../main.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String _selectedEmoji = '😊';
  final _noteController = TextEditingController();

  List<Mood> _moods = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    setState(() => _loading = true);
    try {
      final items = await dbRepo.fetchMoods(limit: 30);
      setState(() => _moods = items);
    } catch (e) {
      _showError('Не удалось загрузить настроение: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveMood() async {
    if (_noteController.text.trim().isEmpty) return;
    try {
      final saved = await dbRepo.upsertMood(
        date: DateTime.now(),
        emoji: _selectedEmoji,
        note: _noteController.text.trim(),
      );
      // Обновляем список (перезапрашиваем, чтобы не дублировать)
      await _loadMoods();
      _noteController.clear();
    } catch (e) {
      _showError('Не удалось сохранить настроение: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
Widget build(BuildContext context) {
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
                onSelect: (emoji) {
                  setState(() => _selectedEmoji = emoji);
                },
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
              onPressed: _saveMood,
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _moods.isEmpty
                    ? const Center(
                        child: Text(
                          'Нет записей настроения',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _moods.length,
                        itemBuilder: (ctx, index) {
                          final mood = _moods[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Text(
                                mood.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
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

@override
void dispose() {
  _noteController.dispose();
  super.dispose();
}
}