import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsModel()..loadSettings(),
      child: Consumer<SettingsModel>(
        builder: (context, model, _) {
          if (model.loading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (model.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              body: Center(
                  child: Text(
                  model.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }


          return Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Приоритеты
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Приоритеты сфер жизни',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Распредели важность по сферам. Чем выше — тем больше XP за задачи в этой сфере.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        ...model.weights.keys.map((block) {
                          final value =
                              (model.weights[block] ?? 0).clamp(0.0, 1.0);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        block,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${(value * 100).toStringAsFixed(0)}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  min: 0,
                                  max: 1,
                                  divisions: 10,
                                  value: value,
                                  label: value.toStringAsFixed(1),
                                  onChanged: (v) =>
                                      model.updateWeight(block, v),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Дневная норма часов
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Дневная норма часов',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Если за день суммарно выполнено задач на эту норму — получаешь бонус XP.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        Slider(
                          min: 1,
                          max: 24,
                          divisions: 23,
                          value: model.targetHours,
                          label: model.targetHours.toStringAsFixed(0),
                          onChanged: (v) => model.updateTargetHours(v),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${model.targetHours.toStringAsFixed(0)} ч',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
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
                    onPressed: () async {
                      final success = await model.saveSettings();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Настройки сохранены'
                                : 'Ошибка сохранения'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Сохранить'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
