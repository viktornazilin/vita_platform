import 'package:flutter/material.dart';
import '../services/mood_service.dart';
import '../widgets/mood_selector.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  final MoodService _moodService = MoodService();
  String _selectedEmoji = '😊';
  final _noteController = TextEditingController();

  void _saveMood() {
    if (_noteController.text.isEmpty) return;
    _moodService.addMood(_selectedEmoji, _noteController.text);
    _noteController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final moods = _moodService.moods;

    return Scaffold(
      appBar: AppBar(title: const Text('Mood Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MoodSelector(
              selectedEmoji: _selectedEmoji,
              onSelect: (emoji) {
                setState(() => _selectedEmoji = emoji);
              },
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _saveMood,
              child: const Text('Save Mood'),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: moods.length,
                itemBuilder: (ctx, index) {
                  final mood = moods[index];
                  return ListTile(
                    leading: Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                    title: Text(mood.note),
                    subtitle: Text(
                      '${mood.date.day}/${mood.date.month}/${mood.date.year}',
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
