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

class _SetupView extends StatefulWidget {
  const _SetupView();

  @override
  State<_SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<_SetupView> {
  bool _saving = false;

  Future<void> _save(BudgetModel m) async {
    if (_saving) return;
    setState(() => _saving = true);
    final ok = await m.save();
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Настройки сохранены' : 'Ошибка сохранения')),
    );
  }

  // ───────────── Bottom sheets (адаптивные, с maxWidth) ─────────────

  Future<String?> _showAddCategorySheet(BuildContext context, {required bool income}) async {
    final cs = Theme.of(context).colorScheme;
    final ctrl = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(income ? Icons.trending_up : Icons.trending_down, color: cs.primary),
                    title: Text(
                      income ? 'Новая доходная категория' : 'Новая расходная категория',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Название',
                      prefixIcon: const Icon(Icons.label_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onSubmitted: (_) => Navigator.pop(ctx, ctrl.text.trim()),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                      icon: const Icon(Icons.add),
                      label: const Text('Создать'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<double?> _showLimitSheet(BuildContext context, {required String categoryName, double? current}) {
    final ctrl = TextEditingController(text: current?.toStringAsFixed(0) ?? '');
    return showModalBottomSheet<double?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.tune),
                    title: Text(
                      'Лимит для «$categoryName»',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('Пусто — без лимита'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Максимум ₽ в месяц',
                      prefixIcon: const Icon(Icons.currency_ruble),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, null),
                          child: const Text('Без лимита'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final s = ctrl.text.trim().replaceAll(',', '.');
                            final v = s.isEmpty ? null : double.tryParse(s);
                            Navigator.pop(ctx, v);
                          },
                          child: const Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ───────────── UI ─────────────

  @override
  Widget build(BuildContext context) {
    final m = context.watch<BudgetModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (m.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final isPhone = w < 720;
        final crossAxisCount = w >= 1200 ? 3 : (w >= 720 ? 2 : 1);
        final hPad = w >= 1200 ? 24.0 : 16.0;

        // секции как виджеты (чтобы переиспользовать в списке и в гриде)
        Widget incomeSection() => _SectionCard(
              title: 'Доходные категории',
              subtitle: 'Используются при добавлении доходов',
              child: _ChipsWrap(
                color: cs.primaryContainer,
                items: m.incomeCategories.map((c) => _ChipItem(
                  label: c.name,
                  onTap: () {},
                  menuBuilder: (ctx) => [
                    PopupMenuItem(
                      child: const Text('Удалить'),
                      onTap: () async {
                        await Future.delayed(Duration.zero);
                        final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Удалить категорию?'),
                                content: Text('Категория: ${c.name}'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                                  FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
                                ],
                              ),
                            ) ??
                            false;
                        if (ok) await m.deleteCategory(c.id);
                      },
                    ),
                  ],
                )).toList(),
                trailing: ActionChip(
                  label: const Text('Добавить'),
                  avatar: const Icon(Icons.add),
                  onPressed: () async {
                    final name = await _showAddCategorySheet(context, income: true);
                    if (name != null && name.isNotEmpty) {
                      await m.createCategory(name, 'income');
                      await m.load();
                    }
                  },
                ),
              ),
            );

        Widget expenseSection() => _SectionCard(
              title: 'Расходные категории',
              subtitle: 'Лимиты помогают держать траты под контролем',
              child: _ChipsWrap(
                color: cs.secondaryContainer,
                items: m.expenseCategories.map((c) => _ChipItem(
                  label: c.name,
                  onTap: () async {
                    final limit = await _showLimitSheet(context, categoryName: c.name);
                    await m.setExpenseLimit(categoryId: c.id, limitRub: limit);
                  },
                  menuBuilder: (ctx) => [
                    PopupMenuItem(
                      child: const Text('Задать/изменить лимит'),
                      onTap: () async {
                        await Future.delayed(Duration.zero);
                        final limit = await _showLimitSheet(context, categoryName: c.name);
                        await m.setExpenseLimit(categoryId: c.id, limitRub: limit);
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Удалить'),
                      onTap: () async {
                        await Future.delayed(Duration.zero);
                        final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Удалить категорию?'),
                                content: Text('Категория: ${c.name}'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                                  FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
                                ],
                              ),
                            ) ??
                            false;
                        if (ok) await m.deleteCategory(c.id);
                      },
                    ),
                  ],
                )).toList(),
                trailing: ActionChip(
                  label: const Text('Добавить'),
                  avatar: const Icon(Icons.add),
                  onPressed: () async {
                    final name = await _showAddCategorySheet(context, income: false);
                    if (name != null && name.isNotEmpty) {
                      await m.createCategory(name, 'expense');
                      await m.load();
                    }
                  },
                ),
              ),
            );

        Widget jarsSection() => _SectionCard(
              title: 'Копилки',
              subtitle: 'Процент — доля от свободных средств, автоматически пополняемая',
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        final res = await showDialog<_NewJarData>(
                          context: context,
                          builder: (_) => const _AddJarDialog(),
                        );
                        if (res == null) return;
                        try {
                          await m.createJar(title: res.title, targetAmount: res.target, percent: res.percent);
                          await m.load();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Копилка добавлена')));
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось добавить: $e')));
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить копилку'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (m.jars.isEmpty)
                    _EmptyState(
                      icon: Icons.savings_outlined,
                      title: 'Копилок пока нет',
                      subtitle: 'Создай первую цель накопления — мы поможем двигаться к ней.',
                    )
                  else
                    ...m.jars.map((j) {
                      final target = j.targetAmount;
                      final progress = (target == null || target <= 0) ? null : (j.currentAmount / target).clamp(0.0, 1.0);
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: cs.outlineVariant),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.savings_outlined, color: cs.primary),
                          title: Text(j.title, style: tt.titleSmall),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Накоплено: ${j.currentAmount.toStringAsFixed(0)} ₽'
                                ' • Процент: ${j.percentOfFree.toStringAsFixed(0)}%'
                                '${target != null ? ' • Цель: ${target.toStringAsFixed(0)} ₽' : ''}',
                                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                              if (progress != null) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(value: progress, minHeight: 8),
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            tooltip: 'Удалить',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Удалить копилку?'),
                                      content: Text('Копилка: ${j.title}'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                                        FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
                                      ],
                                    ),
                                  ) ??
                                  false;
                              if (!confirm) return;
                              try {
                                await m.deleteJar(j.id);
                                await m.load();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Копилка удалена')));
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось удалить: $e')));
                              }
                            },
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );

        // Компактный: линейный список
        if (crossAxisCount == 1) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                const SliverAppBar(
                  pinned: true,
                  title: Text('Бюджет и копилки'), // compact: маленькая шапка
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                  sliver: SliverList.list(children: [
                    incomeSection(),
                    const SizedBox(height: 12),
                    expenseSection(),
                    const SizedBox(height: 12),
                    jarsSection(),
                    const SizedBox(height: 88),
                  ]),
                ),
              ],
            ),
            bottomNavigationBar: _SaveBar(saving: _saving, onSave: () => _save(m)),
          );
        }

        // Широкие: сетка секций
        final children = <Widget>[
          incomeSection(),
          expenseSection(),
          jarsSection(),
        ];

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text('Бюджет и копилки')),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 96),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate(children),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _SaveBar(saving: _saving, onSave: () => _save(m)),
        );
      },
    );
  }
}

// ───────────── Внутренние виджеты ─────────────

class _SaveBar extends StatelessWidget {
  final bool saving;
  final VoidCallback onSave;
  const _SaveBar({required this.saving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: Text(saving ? 'Сохранение…' : 'Сохранить'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _SectionCard({required this.title, required this.subtitle, required this.child});

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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }
}

typedef PopupBuilder = List<PopupMenuEntry<void>> Function(BuildContext);

class _ChipItem {
  final String label;
  final VoidCallback onTap;
  final PopupBuilder? menuBuilder;
  _ChipItem({required this.label, required this.onTap, this.menuBuilder});
}

/// Обёртка над Wrap, чтобы переиспользовать отрисовку чипов и trailing-кнопку
class _ChipsWrap extends StatelessWidget {
  final Color color;
  final List<_ChipItem> items;
  final Widget trailing;

  const _ChipsWrap({
    required this.color,
    required this.items,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final it in items)
          Material(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: it.onTap,
              onLongPress: it.menuBuilder == null
                  ? null
                  : () {
                      final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
                      final box = context.findRenderObject() as RenderBox?;
                      final offset = box?.localToGlobal(Offset.zero) ?? Offset.zero;
                      final size = box?.size ?? const Size(0, 0);
                      showMenu<void>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          offset.dx, offset.dy + size.height, overlay?.size.width ?? 0, 0,
                        ),
                        items: it.menuBuilder!(context),
                      );
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.label_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(it.label, style: TextStyle(color: cs.onSurface)),
                ]),
              ),
            ),
          ),
        trailing,
      ],
    );
  }
}

// ——— Диалог новой копилки (с валидацией)

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
      setState(() => _error = 'Процент должен быть от 0 до 100');
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

extension on BudgetModel {
  Future<bool> save() async {
    try {
      // если есть свой метод сохранения — вызови его
      // await saveSettings();
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 28, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$title\n$subtitle',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          )
        ],
      ),
    );
  }
}
