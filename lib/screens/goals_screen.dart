import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/life_block.dart';
import '../services/goal_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _goalService = GoalService();

  List<String> _lifeBlocks = [];
  String? _selectedBlock;
  List<Goal> _goals = [];
  bool _loading = true;

  // форма
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _importance = 1;
  double _spentHours = 1.0;
  String _emotion = '😊';
  DateTime _selectedDate = DateTime.now();

  final List<String> _emotions = ['😊','😐','😢','😎','😤','🤔','😴','😇'];

  @override
  void initState() {
    super.initState();
    _loadBlocksAndGoals();
  }

  Future<void> _loadBlocksAndGoals() async {
    setState(() => _loading = true);
    try {
      _lifeBlocks = await _goalService.getUserLifeBlocks();
      if (_lifeBlocks.isNotEmpty) {
        _selectedBlock = _lifeBlocks.first;
        await _loadGoals();
      }
    } catch (e) {
      _showError('Ошибка загрузки: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadGoals() async {
    if (_selectedBlock == null) return;
    _goals = await _goalService.fetchGoals(lifeBlock: _selectedBlock);
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _addGoal() async {
    if (_titleController.text.trim().isEmpty || _selectedBlock == null) return;

    final created = await _goalService.createGoal(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      deadline: _selectedDate,
      lifeBlock: _selectedBlock!,
      importance: _importance,
      emotion: _emotion,
      spentHours: _spentHours,
    );

    setState(() {
      _goals.insert(0, created);
      _titleController.clear();
      _descController.clear();
      _importance = 1;
      _spentHours = 1.0;
      _emotion = _emotions.first;
      _selectedDate = DateTime.now();
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.teal,
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/images/logo.png', height: 32),
          const SizedBox(width: 10),
          const Text(
            'Goals',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // меню сфер жизни
              Container(
                height: 90,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _lifeBlocks.length,
                  itemBuilder: (context, index) {
                    final block = _lifeBlocks[index];
                    final isSelected = block == _selectedBlock;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedBlock = block);
                        _loadGoals();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.teal : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.teal.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            getBlockLabel(
                              LifeBlock.values.firstWhere(
                                (e) => e.name == block,
                                orElse: () => LifeBlock.health,
                              ),
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // форма
              Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Goal Title *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _descController,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // deadline
                        Row(
                          children: [
                            const Text('Deadline:'),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(_fmtDate(_selectedDate)),
                              onPressed: _pickDate,
                            ),
                          ],
                        ),

                        // hours
                        Row(
                          children: [
                            const Text('Hours spent:'),
                            Expanded(
                              child: Slider(
                                min: 0.5,
                                max: 14.0,
                                divisions: 27,
                                value: _spentHours,
                                label: _spentHours.toStringAsFixed(1),
                                onChanged: (v) => setState(() => _spentHours = v),
                              ),
                            ),
                            SizedBox(
                              width: 48,
                              child: Text(
                                _spentHours.toStringAsFixed(1),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),

                        // emotion
                        Row(
                          children: [
                            const Text('Emotion:'),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _emotion,
                              items: _emotions
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e, style: const TextStyle(fontSize: 18)),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _emotion = val);
                              },
                            ),
                          ],
                        ),

                        // importance
                        Row(
                          children: [
                            const Text('Importance:'),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: _importance,
                              items: List.generate(5, (i) => i + 1)
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text('$e'),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _importance = val);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _addGoal,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Goal'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(),
              Expanded(
                child: _goals.isEmpty
                    ? const Center(child: Text('Нет целей'))
                    : ListView.builder(
                        itemCount: _goals.length,
                        itemBuilder: (ctx, index) {
                          final g = _goals[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(
                                g.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${g.description.isEmpty ? '—' : g.description}\n'
                                'Deadline: ${_fmtDate(g.deadline)}  |  '
                                'Hours: ${g.spentHours.toStringAsFixed(1)}  |  '
                                'Imp: ${g.importance}  |  '
                                'Emotion: ${g.emotion}',
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
  );
}