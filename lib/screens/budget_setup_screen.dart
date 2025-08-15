import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget_model.dart';
import '../main.dart';

class BudgetSetupScreen extends StatelessWidget {
  const BudgetSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BudgetModel(repo: dbRepo)..load(),
      child: const _SetupView(),
    );
  }
}

class _SetupView extends StatelessWidget {
  const _SetupView();

  Future<void> _addCategory(BuildContext context, String kind) async {
    final nameCtrl = TextEditingController();
    final m = context.read<BudgetModel>();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(kind == 'income' ? 'Категория дохода' : 'Категория расхода'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Название'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, nameCtrl.text.trim()), child: const Text('Создать')),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await m.createCategory(name, kind);
      await m.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<BudgetModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Бюджет и копилки')),
      body: m.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ----- Доходные категории (КАК БЫЛО) -----
                Text('Доходные категории', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in m.incomeCategories) Chip(label: Text(c.name)),
                    ActionChip(
                      label: const Text('+ добавить'),
                      onPressed: () => _addCategory(context, 'income'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ----- Расходные категории (КАК БЫЛО: лимит + удаление) -----
                Text('Расходные категории', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in m.expenseCategories)
                      InputChip(
                        label: Text(c.name),
                        onPressed: () async {
                          final ctrl = TextEditingController();
                          final limit = await showDialog<double?>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Лимит для "${c.name}"'),
                              content: TextField(
                                controller: ctrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Максимум ₽ (пусто — без лимита)',
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                                ElevatedButton(
                                  onPressed: () {
                                    final v = ctrl.text.trim();
                                    Navigator.pop(context, v.isEmpty ? null : double.tryParse(v.replaceAll(',', '.')));
                                  },
                                  child: const Text('Сохранить'),
                                ),
                              ],
                            ),
                          );
                          await m.setExpenseLimit(categoryId: c.id, limitRub: limit);
                        },
                        onDeleted: () async {
                          final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Удалить категорию?'),
                                  content: Text('Категория: ${c.name}'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
                                  ],
                                ),
                              ) ??
                              false;
                          if (ok) await m.deleteCategory(c.id);
                        },
                      ),
                    ActionChip(
                      label: const Text('+ добавить'),
                      onPressed: () => _addCategory(context, 'expense'),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // ----- Копилки -----
                Row(
                  children: [
                    Text('Копилки', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить'),
                      onPressed: () async {
                        final model = context.read<BudgetModel>();
                        final res = await showDialog<_NewJarData>(
                          context: context,
                          builder: (_) => const _AddJarDialog(),
                        );

                        if (res == null) return;

                        try {
                          await model.createJar(
                            title: res.title,
                            targetAmount: res.target, // уже обязательно валидируется в диалоге
                            percent: res.percent,
                          );
                          await model.load();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Копилка добавлена')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Не удалось добавить: $e')),
                          );
                        }
                      },
                    ),
                  ],
                ),

                if (m.jars.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Копилок пока нет'),
                  )
                else
                  ...m.jars.map(
                    (j) => ListTile(
                      leading: const Icon(Icons.savings_outlined),
                      title: Text(j.title),
                      subtitle: Text(
                        'Накоплено: ${j.currentAmount.toStringAsFixed(0)} ₽'
                        ' • Процент: ${j.percentOfFree.toStringAsFixed(0)}%'
                        '${j.targetAmount != null ? ' • Цель: ${j.targetAmount!.toStringAsFixed(0)} ₽' : ''}',
                      ),
                      // Удаление копилки
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Удалить',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Удалить копилку?'),
                                  content: Text('Копилка: ${j.title}'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Отмена'),
                                    ),
                                    FilledButton.tonal(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Удалить'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                          if (!confirm) return;

                          try {
                            final model = context.read<BudgetModel>();
                            await model.deleteJar(j.id); // метод в BudgetModel должен вызывать repo.deleteJar
                            await model.load();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Копилка удалена')),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Не удалось удалить: $e')),
                            );
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
class _NewJarData {
  final String title;
  final double? target;
  final double percent;
  const _NewJarData(this.title, this.target, this.percent);
}

class _AddJarDialog extends StatefulWidget {
  const _AddJarDialog();

  @override
  State<_AddJarDialog> createState() => _AddJarDialogState();
}

class _AddJarDialogState extends State<_AddJarDialog> {
  final _title = TextEditingController();
  final _target = TextEditingController();
  final _percent = TextEditingController(text: '0');

  String? _error;

  double? _parseDouble(String s) {
    if (s.trim().isEmpty) return null;
    return double.tryParse(s.replaceAll(',', '.'));
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Укажите название');
      return;
    }
    final percent = _parseDouble(_percent.text) ?? 0;
    if (percent < 0 || percent > 100) {
      setState(() => _error = 'Процент должен быть в диапазоне 0–100');
      return;
    }
    final target = _parseDouble(_target.text);
    if (target == null || target <= 0) {
      setState(() => _error = 'Укажите цель (положительное число)');
      return;
    }

    Navigator.pop(context, _NewJarData(title, target, percent));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новая копилка'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Название')),
          const SizedBox(height: 8),
          TextField(
            controller: _percent,
            decoration: const InputDecoration(labelText: 'Процент от свободных, %'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _target,
            decoration: const InputDecoration(
              labelText: 'Целевая сумма',
              helperText: 'Обязательно',
            ),
            keyboardType: TextInputType.number,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(onPressed: _submit, child: const Text('Создать')),
      ],
    );
  }
}
