import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/budget_model.dart';
import '../../../main.dart';
import '../widgets/save_bar.dart';
import '../widgets/section_card.dart';
import '../widgets/chips_wrap.dart';
import '../widgets/add_category_sheet.dart';
import '../widgets/limit_sheet.dart';
import '../widgets/add_jar_dialog.dart';
import '../widgets/empty_state.dart';

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
        final crossAxisCount = w >= 1200 ? 3 : (w >= 720 ? 2 : 1);
        final hPad = w >= 1200 ? 24.0 : 16.0;

        // ——— Секции
        Widget incomeSection() => SectionCard(
              title: 'Доходные категории',
              subtitle: 'Используются при добавлении доходов',
              child: ChipsWrap(
                color: cs.primaryContainer,
                items: m.incomeCategories
                    .map((c) => ChipItem(
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
                                          TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Отмена')),
                                          FilledButton.tonal(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Удалить')),
                                        ],
                                      ),
                                    ) ??
                                    false;
                                if (ok) await m.deleteCategory(c.id);
                              },
                            ),
                          ],
                        ))
                    .toList(),
                trailing: ActionChip(
                  label: const Text('Добавить'),
                  avatar: const Icon(Icons.add),
                  onPressed: () async {
                    final name = await showAddCategorySheet(context, income: true);
                    if (name != null && name.isNotEmpty) {
                      await m.createCategory(name, 'income');
                      await m.load();
                    }
                  },
                ),
              ),
            );

        Widget expenseSection() => SectionCard(
              title: 'Расходные категории',
              subtitle: 'Лимиты помогают держать траты под контролем',
              child: ChipsWrap(
                color: cs.secondaryContainer,
                items: m.expenseCategories
                    .map((c) => ChipItem(
                          label: c.name,
                          onTap: () async {
                            final limit = await showLimitSheet(context, categoryName: c.name);
                            await m.setExpenseLimit(categoryId: c.id, limitRub: limit);
                          },
                          menuBuilder: (ctx) => [
                            PopupMenuItem(
                              child: const Text('Задать/изменить лимит'),
                              onTap: () async {
                                await Future.delayed(Duration.zero);
                                final limit =
                                    await showLimitSheet(context, categoryName: c.name);
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
                                          TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Отмена')),
                                          FilledButton.tonal(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Удалить')),
                                        ],
                                      ),
                                    ) ??
                                    false;
                                if (ok) await m.deleteCategory(c.id);
                              },
                            ),
                          ],
                        ))
                    .toList(),
                trailing: ActionChip(
                  label: const Text('Добавить'),
                  avatar: const Icon(Icons.add),
                  onPressed: () async {
                    final name = await showAddCategorySheet(context, income: false);
                    if (name != null && name.isNotEmpty) {
                      await m.createCategory(name, 'expense');
                      await m.load();
                    }
                  },
                ),
              ),
            );

        Widget jarsSection() => SectionCard(
              title: 'Копилки',
              subtitle:
                  'Процент — доля от свободных средств, автоматически пополняемая',
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        final res = await showDialog<NewJarData>(
                          context: context,
                          builder: (_) => const AddJarDialog(),
                        );
                        if (res == null) return;
                        try {
                          await m.createJar(
                            title: res.title,
                            targetAmount: res.target,
                            percent: res.percent,
                          );
                          await m.load();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Копилка добавлена')));
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Не удалось добавить: $e')));
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить копилку'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (m.jars.isEmpty)
                    const EmptyState(
                      icon: Icons.savings_outlined,
                      title: 'Копилок пока нет',
                      subtitle:
                          'Создай первую цель накопления — мы поможем двигаться к ней.',
                    )
                  else
                    ...m.jars.map((j) {
                      final target = j.targetAmount;
                      final progress = (target == null || target <= 0)
                          ? null
                          : (j.currentAmount / target).clamp(0.0, 1.0);
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
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              if (progress != null) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                  ),
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
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Отмена')),
                                        FilledButton.tonal(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Удалить')),
                                      ],
                                    ),
                                  ) ??
                                  false;
                              if (!confirm) return;
                              try {
                                await m.deleteJar(j.id);
                                await m.load();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Копилка удалена')));
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Не удалось удалить: $e')));
                              }
                            },
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );

        // Компактный: список
        if (crossAxisCount == 1) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                const SliverAppBar(
                  pinned: true,
                  title: Text('Бюджет и копилки'),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                  sliver: SliverList.list(children: const [
                    SizedBox(height: 0),
                  ]),
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
            bottomNavigationBar:
                SaveBar(saving: _saving, onSave: () => _save(m)),
          );
        }

        // Широкий: сетка
        final children = <Widget>[incomeSection(), expenseSection(), jarsSection()];

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
          bottomNavigationBar:
              SaveBar(saving: _saving, onSave: () => _save(m)),
        );
      },
    );
  }
}

extension BudgetModelSave on BudgetModel {
  Future<bool> save() async {
    try {
      // await saveSettings();
      return true;
    } catch (_) {
      return false;
    }
  }
}
