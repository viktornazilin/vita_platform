import 'package:flutter/material.dart';
import '../models/goal.dart';
import 'add_day_goal_sheet.dart'; // для AddGoalResult

class EditGoalSheet extends StatefulWidget {
  final Goal goal;
  final String? fixedLifeBlock;
  final List<String> availableBlocks;

  const EditGoalSheet({
    super.key,
    required this.goal,
    required this.fixedLifeBlock,
    required this.availableBlocks,
  });

  @override
  State<EditGoalSheet> createState() => _EditGoalSheetState();
}

class _EditGoalSheetState extends State<EditGoalSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _emotionCtrl;

  late String _lifeBlock;
  late int _importance;   // 1..3
  late double _hours;     // 0.5..14
  late TimeOfDay _start;  // TimeOfDay

  @override
  void initState() {
    super.initState();
    final g = widget.goal;

    _titleCtrl   = TextEditingController(text: g.title);
    _descCtrl    = TextEditingController(text: g.description);
    _emotionCtrl = TextEditingController(text: g.emotion);

    _lifeBlock = widget.fixedLifeBlock
        ?? g.lifeBlock
        ?? (widget.availableBlocks.isNotEmpty ? widget.availableBlocks.first : 'general');

    _importance = g.importance;

    _hours = g.spentHours.clamp(0.5, 14.0);
    _start = TimeOfDay.fromDateTime(g.startTime);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _emotionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _start);
    if (picked != null) setState(() => _start = picked);
  }

  void _submit() {
    final title = _titleCtrl.text.trim().isEmpty ? 'Без названия' : _titleCtrl.text.trim();
    Navigator.pop(
      context,
      AddGoalResult(
        title: title,
        description: _descCtrl.text.trim(),
        lifeBlock: _lifeBlock,
        importance: _importance,
        emotion: _emotionCtrl.text.trim(),
        hours: _hours,
        startTime: _start,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final canEditBlock = widget.fixedLifeBlock == null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (ctx, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 12),
              Text('Редактировать цель', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),

              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _descCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 12),

              if (canEditBlock) ...[
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Сфера/блок'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _lifeBlock,
                      isExpanded: true,
                      items: (widget.availableBlocks.isNotEmpty ? widget.availableBlocks : <String>['general'])
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setState(() => _lifeBlock = v ?? _lifeBlock),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              InputDecorator(
                decoration: const InputDecoration(labelText: 'Важность'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _importance,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Низкая')),
                      DropdownMenuItem(value: 2, child: Text('Средняя')),
                      DropdownMenuItem(value: 3, child: Text('Высокая')),
                    ],
                    onChanged: (v) => setState(() => _importance = v ?? _importance),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _emotionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Эмоция (необязательно)',
                  prefixIcon: Icon(Icons.emoji_emotions_outlined),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Длительность, ч'),
                        Slider(
                          min: 0.5, max: 14, divisions: 27,
                          value: _hours, label: _hours.toStringAsFixed(1),
                          onChanged: (v) => setState(() => _hours = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Начало'),
                      TextButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(_start.format(context)),
                        onPressed: _pickTime,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Сохранить'),
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const SafeArea(top: false, child: SizedBox(height: 0)),
            ],
          ),
        ),
      ),
    );
  }
}
