import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsModel()..loadSettings(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  bool _saving = false;

  Future<void> _save(SettingsModel model) async {
    if (_saving) return;
    setState(() => _saving = true);
    final ok = await model.saveSettings();
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Настройки сохранены' : 'Ошибка сохранения')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SettingsModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (model.loading) {
      return Scaffold(
        body: CustomScrollView(
          slivers: const [
            SliverAppBar.large(title: Text('Настройки')),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }
    if (model.error != null) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverAppBar.large(title: Text('Настройки')),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(model.error!, style: TextStyle(color: cs.error)),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Настройки'),
            centerTitle: false,
          ),

          // — Приоритеты сфер жизни
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _SectionCard(
                title: 'Приоритеты сфер жизни',
                subtitle:
                    'Распредели важность по сферам. Чем выше — тем больше XP за задачи этой сферы.',
                child: Column(
                  children: [
                    for (final block in model.weights.keys)
                      _WeightRow(
                        label: block,
                        value: (model.weights[block] ?? 0).clamp(0.0, 1.0),
                        onChanged: (v) => model.updateWeight(block, v),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // — Дневная норма часов
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _SectionCard(
                title: 'Дневная норма часов',
                subtitle:
                    'Если за день суммарно выполнено задач на эту норму — получишь бонус XP.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Быстрый выбор пресетов
                    SegmentedButton<int>(
                      style: SegmentedButton.styleFrom(
                        side: BorderSide(color: cs.outlineVariant),
                      ),
                      segments: const [
                        ButtonSegment(value: 6, label: Text('6 ч')),
                        ButtonSegment(value: 8, label: Text('8 ч')),
                        ButtonSegment(value: 10, label: Text('10 ч')),
                      ],
                      selected: {
                        {6, 8, 10}.contains(model.targetHours.round())
                            ? model.targetHours.round()
                            : -1,
                      },
                      onSelectionChanged: (s) {
                        final v = s.first;
                        if (v != -1) model.updateTargetHours(v.toDouble());
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            min: 1,
                            max: 24,
                            divisions: 23,
                            value: model.targetHours.clamp(1, 24),
                            label: model.targetHours.toStringAsFixed(0),
                            onChanged: (v) => model.updateTargetHours(v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Text(
                            '${model.targetHours.toStringAsFixed(0)} ч',
                            style: tt.labelLarge,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // отступ под кнопку
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),

      // Плавающая панель действия «Сохранить»
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _saving ? null : () => _save(model),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Сохранение…' : 'Сохранить'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ————— Внутренние виджеты —————

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _WeightRow extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _WeightRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: tt.labelSmall,
                ),
              ),
            ],
          ),
          Slider(
            min: 0,
            max: 1,
            divisions: 10,
            value: value.clamp(0.0, 1.0),
            label: (value).toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
