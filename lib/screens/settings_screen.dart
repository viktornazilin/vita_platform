import 'package:flutter/material.dart';
import '../main.dart'; // чтобы достать dbRepo

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, double> _weights = {};
  double _targetHours = 14;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    try {
      final blocks = await dbRepo.getUserLifeBlocks();
      final target = await dbRepo.getTargetHours();

      // Получаем веса
      Map<String, double> weights = {};
      for (var b in blocks) {
        weights[b] = await dbRepo.getLifeBlockWeight(b);
      }

      setState(() {
        _weights = weights;
        _targetHours = target;
      });
    } catch (e) {
      _showError('Ошибка загрузки: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      await dbRepo.saveUserSettings(weights: _weights, targetHours: _targetHours);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Настройки сохранены')),
      );
    } catch (e) {
      _showError('Ошибка сохранения: $e');
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
      title: const Text('Settings'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Приоритеты
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Приоритеты сфер жизни',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        'Распредели важность по сферам. Чем выше — тем больше XP за задачи в этой сфере.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 12),

                      ..._weights.keys.map((block) {
                        final value = (_weights[block] ?? 0).clamp(0.0, 1.0);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(block, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('${(value * 100).toStringAsFixed(0)}%',
                                        style: Theme.of(context).textTheme.labelSmall),
                                  ),
                                ],
                              ),
                              Slider(
                                min: 0,
                                max: 1,
                                divisions: 10,
                                value: value,
                                label: value.toStringAsFixed(1),
                                onChanged: (v) => setState(() => _weights[block] = v),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Дневная норма часов
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Дневная норма часов',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        'Если за день суммарно выполнено задач на эту норму — получаешь бонус XP.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        min: 1,
                        max: 24,
                        divisions: 23,
                        value: _targetHours,
                        label: _targetHours.toStringAsFixed(0),
                        onChanged: (v) => setState(() => _targetHours = v),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('${_targetHours.toStringAsFixed(0)} ч',
                            style: Theme.of(context).textTheme.labelLarge),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Сохранить
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Сохранить'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
  );
}
