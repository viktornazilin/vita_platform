import 'package:flutter/material.dart';

class AddGoalResult {
  final String title;
  final String description;
  final String lifeBlock;
  final int importance;
  final String emotion;
  final double hours;

  AddGoalResult({
    required this.title,
    required this.description,
    required this.lifeBlock,
    required this.importance,
    required this.emotion,
    required this.hours,
  });
}

class AddDayGoalSheet extends StatefulWidget {
  final String? fixedLifeBlock;
  final List<String> availableBlocks;

  const AddDayGoalSheet({
    super.key,
    required this.fixedLifeBlock,
    this.availableBlocks = const [],
  });

  @override
  State<AddDayGoalSheet> createState() => _AddDayGoalSheetState();
}

class _AddDayGoalSheetState extends State<AddDayGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _emotions = const ['😊','😐','😢','😎','😤','🤔','😴','😇'];
  String _emotion = '😊';
  int _importance = 1;
  double _hours = 1.0;
  late String _lifeBlock;

  @override
  void initState() {
    super.initState();
    _lifeBlock = widget.fixedLifeBlock ??
        (widget.availableBlocks.isNotEmpty ? widget.availableBlocks.first : 'health');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Новая цель на день',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Название *',
                hintText: 'Например: Тренировка 5 км',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Описание (опционально)',
                hintText: 'Кратко опиши задачу',
              ),
            ),
            const SizedBox(height: 12),
            if (widget.fixedLifeBlock == null) ...[
              DropdownButtonFormField<String>(
                value: _lifeBlock,
                decoration: const InputDecoration(labelText: 'Сфера жизни'),
                items: (widget.availableBlocks.isEmpty ? <String>['health'] : widget.availableBlocks)
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setState(() => _lifeBlock = v ?? _lifeBlock),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                const Text('Важность'),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _importance,
                  onChanged: (v) => setState(() => _importance = v ?? _importance),
                  items: List.generate(5, (i) => i + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                ),
                const Spacer(),
                const Text('Эмоция'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _emotion,
                  onChanged: (v) => setState(() => _emotion = v ?? _emotion),
                  items: _emotions
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: const TextStyle(fontSize: 18)),
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Часы'),
                Expanded(
                  child: Slider(
                    min: 0.5, max: 14.0, divisions: 27,
                    value: _hours,
                    label: _hours.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _hours = v),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(_hours.toStringAsFixed(1), textAlign: TextAlign.right),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_titleCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Введите название')),
                        );
                        return;
                      }
                      Navigator.pop(
                        context,
                        AddGoalResult(
                          title: _titleCtrl.text,
                          description: _descCtrl.text,
                          lifeBlock: _lifeBlock,
                          importance: _importance,
                          emotion: _emotion,
                          hours: _hours,
                        ),
                      );
                    },
                    child: const Text('Добавить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
