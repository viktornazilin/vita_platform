import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/goal_service.dart';
import '../widgets/goal_path.dart';

class DayGoalsScreen extends StatefulWidget {
  final DateTime date;
  final String? lifeBlock; // null => показать все блоки
  final List<String> availableBlocks;

  const DayGoalsScreen({
    super.key,
    required this.date,
    required this.lifeBlock,
    this.availableBlocks = const [], // <- по умолчанию пусто
  });

  @override
  State<DayGoalsScreen> createState() => _DayGoalsScreenState();
}

class _DayGoalsScreenState extends State<DayGoalsScreen> {
  final _service = GoalService();
  List<Goal> _goals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final allDay = await _service.getGoalsByDate(widget.date);
    final filtered = widget.lifeBlock == null
        ? allDay
        : allDay.where((g) => g.lifeBlock == widget.lifeBlock).toList();

    setState(() {
      _goals = filtered
        ..sort((a, b) => a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1));
      _loading = false;
    });
  }

  Future<void> _toggleComplete(Goal g) async {
    await _service.completeGoal(g.id);
    await _load();
  }

  Future<void> _addGoal() async {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  // локальные стейты формы
  final emotions = ['😊','😐','😢','😎','😤','🤔','😴','😇'];
  String emotion = '😊';
  int importance = 1;
  double hours = 1.0;
  String lifeBlock = widget.lifeBlock ??
      (widget.availableBlocks.isNotEmpty ? widget.availableBlocks.first : 'health');

  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (ctx, setLocal) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Новая цель на день',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  // Название
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Название *',
                      hintText: 'Например: Тренировка 5 км',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Описание (необязательно)
                  TextField(
                    controller: descCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Описание (опционально)',
                      hintText: 'Кратко опиши задачу',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Сфера (если фильтр "все")
                  if (widget.lifeBlock == null)
                    DropdownButtonFormField<String>(
                      value: lifeBlock,
                      decoration: const InputDecoration(labelText: 'Сфера жизни'),
                      items: (widget.availableBlocks.isEmpty
                              ? <String>['health']
                              : widget.availableBlocks)
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setLocal(() => lifeBlock = v ?? lifeBlock),
                    ),
                  if (widget.lifeBlock == null) const SizedBox(height: 12),

                  // Важность
                  Row(
                    children: [
                      const Text('Важность'),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: importance,
                        onChanged: (v) => setLocal(() => importance = v ?? importance),
                        items: List.generate(5, (i) => i + 1)
                            .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                            .toList(),
                      ),
                      const Spacer(),
                      const Text('Эмоция'),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: emotion,
                        onChanged: (v) => setLocal(() => emotion = v ?? emotion),
                        items: emotions
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e, style: const TextStyle(fontSize: 18)),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Часы
                  Row(
                    children: [
                      const Text('Часы'),
                      Expanded(
                        child: Slider(
                          min: 0.5,
                          max: 14.0,
                          divisions: 27,
                          value: hours,
                          label: hours.toStringAsFixed(1),
                          onChanged: (v) => setLocal(() => hours = v),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(hours.toStringAsFixed(1), textAlign: TextAlign.right),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Отмена'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (titleCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Введите название')),
                              );
                              return;
                            }
                            Navigator.pop(ctx, true);
                          },
                          child: const Text('Добавить'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );

  if (ok == true) {
    await _service.createGoal(
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      deadline: DateTime(widget.date.year, widget.date.month, widget.date.day),
      lifeBlock: lifeBlock,
      importance: importance,
      emotion: emotion,
      spentHours: hours,
    );
    await _load();
  }
}


  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final title = widget.lifeBlock == null ? 'Все сферы' : widget.lifeBlock!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${_fmt(widget.date)}  •  $title'),
        actions: [
          IconButton(onPressed: _addGoal, icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
              ? const Center(child: Text('Целей на этот день нет'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GoalPath(
                    goals: _goals,
                    onToggle: _toggleComplete,
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGoal,
        label: const Text('Добавить цель'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
