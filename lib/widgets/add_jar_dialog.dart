import 'package:flutter/material.dart';

class NewJarData {
  final String title;
  final double? target;
  final double percent;
  const NewJarData(this.title, this.target, this.percent);
}

class AddJarDialog extends StatefulWidget {
  const AddJarDialog({super.key});

  @override
  State<AddJarDialog> createState() => _AddJarDialogState();
}

class _AddJarDialogState extends State<AddJarDialog> {
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
      setState(() => _error = 'Процент должен быть от 0 до 100');
      return;
    }
    final target = _parseDouble(_target.text);
    if (target == null || target <= 0) {
      setState(() => _error = 'Укажите цель (положительное число)');
      return;
    }
    Navigator.pop(context, NewJarData(title, target, percent));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
            Text(_error!, style: TextStyle(color: cs.error)),
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
