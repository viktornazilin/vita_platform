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

import 'package:nest_app/l10n/app_localizations.dart';

// ✅ Nest
import '../../../widgets/nest/nest_background.dart';
import '../../../widgets/nest/nest_blur_card.dart';

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

    final l = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(ok ? l.budgetSetupSaved : l.budgetSetupSaveError),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final m = context.watch<BudgetModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (m.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final crossAxisCount = w >= 1200 ? 3 : (w >= 720 ? 2 : 1);
        final hPad = w >= 1200 ? 24.0 : 16.0;

        Widget nestWrap(Widget child) => NestBlurCard(
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        );

        // ——— Секции
        Widget incomeSection() => nestWrap(
          SectionCard(
            title: l.budgetIncomeCategoriesTitle,
            subtitle: l.budgetIncomeCategoriesSubtitle,
            child: ChipsWrap(
              color: cs.primaryContainer,
              items: m.incomeCategories
                  .map(
                    (c) => ChipItem(
                      label: c.name,
                      onTap: () {},
                      menuBuilder: (ctx) => [
                        PopupMenuItem(
                          child: Text(l.commonDelete),
                          onTap: () async {
                            // важно: дать закрыться меню перед showDialog
                            await Future.delayed(Duration.zero);
                            final ok =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    title: Text(l.budgetDeleteCategoryTitle),
                                    content: Text(
                                      l.budgetCategoryLabel(c.name),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(l.commonCancel),
                                      ),
                                      FilledButton.tonal(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(l.commonDelete),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;

                            if (ok) {
                              await m.deleteCategory(c.id);
                              await m.load();
                            }
                          },
                        ),
                      ],
                    ),
                  )
                  .toList(),
              trailing: ActionChip(
                label: Text(l.commonAdd),
                avatar: const Icon(Icons.add),
                onPressed: () async {
                  final name = await showAddCategorySheet(
                    context,
                    income: true,
                  );
                  if (name != null && name.isNotEmpty) {
                    await m.createCategory(name, 'income');
                    await m.load();
                  }
                },
              ),
            ),
          ),
        );

        Widget expenseSection() => nestWrap(
          SectionCard(
            title: l.budgetExpenseCategoriesTitle,
            subtitle: l.budgetExpenseCategoriesSubtitle,
            child: ChipsWrap(
              color: cs.secondaryContainer,
              items: m.expenseCategories
                  .map(
                    (c) => ChipItem(
                      label: c.name,
                      onTap: () async {
                        final limit = await showLimitSheet(
                          context,
                          categoryName: c.name,
                        );
                        await m.setExpenseLimit(
                          categoryId: c.id,
                          limitRub: limit,
                        );
                      },
                      menuBuilder: (ctx) => [
                        PopupMenuItem(
                          child: Text(l.budgetSetOrChangeLimit),
                          onTap: () async {
                            await Future.delayed(Duration.zero);
                            final limit = await showLimitSheet(
                              context,
                              categoryName: c.name,
                            );
                            await m.setExpenseLimit(
                              categoryId: c.id,
                              limitRub: limit,
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: Text(l.commonDelete),
                          onTap: () async {
                            await Future.delayed(Duration.zero);
                            final ok =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    title: Text(l.budgetDeleteCategoryTitle),
                                    content: Text(
                                      l.budgetCategoryLabel(c.name),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(l.commonCancel),
                                      ),
                                      FilledButton.tonal(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(l.commonDelete),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;

                            if (ok) {
                              await m.deleteCategory(c.id);
                              await m.load();
                            }
                          },
                        ),
                      ],
                    ),
                  )
                  .toList(),
              trailing: ActionChip(
                label: Text(l.commonAdd),
                avatar: const Icon(Icons.add),
                onPressed: () async {
                  final name = await showAddCategorySheet(
                    context,
                    income: false,
                  );
                  if (name != null && name.isNotEmpty) {
                    await m.createCategory(name, 'expense');
                    await m.load();
                  }
                },
              ),
            ),
          ),
        );

        Widget jarsSection() => nestWrap(
          SectionCard(
            title: l.budgetJarsTitle,
            subtitle: l.budgetJarsSubtitle,
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
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(l.budgetJarAdded),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(l.budgetJarAddFailed(e.toString())),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l.budgetAddJar),
                  ),
                ),
                const SizedBox(height: 6),
                if (m.jars.isEmpty)
                  EmptyState(
                    icon: Icons.savings_outlined,
                    title: l.budgetNoJarsTitle,
                    subtitle: l.budgetNoJarsSubtitle,
                  )
                else
                  ...m.jars.map((j) {
                    final target = j.targetAmount;
                    final progress = (target == null || target <= 0)
                        ? null
                        : (j.currentAmount / target).clamp(0.0, 1.0);

                    // ✅ FIX: Text() и локализациям нельзя передавать null
                    final targetStr = (target != null)
                        ? target.toStringAsFixed(0)
                        : '—';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {},
                          child: NestBlurCard(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cs.surfaceContainerHighest
                                          .withOpacity(0.35),
                                      border: Border.all(
                                        color: cs.outlineVariant.withOpacity(
                                          0.6,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.savings_outlined,
                                      color: cs.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          j.title,
                                          style: tt.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          l.budgetJarSummary(
                                            j.currentAmount.toStringAsFixed(0),
                                            j.percentOfFree.toStringAsFixed(0),
                                            targetStr, // ✅ всегда String
                                          ),
                                          style: tt.bodySmall?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (progress != null) ...[
                                          const SizedBox(height: 10),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 10,
                                              backgroundColor: cs
                                                  .surfaceContainerHighest
                                                  .withOpacity(0.35),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: l.commonDelete,
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                    ),
                                    onPressed: () async {
                                      final confirm =
                                          await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(22),
                                              ),
                                              title: Text(
                                                l.budgetDeleteJarTitle,
                                              ),
                                              content: Text(
                                                l.budgetJarLabel(j.title),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: Text(l.commonCancel),
                                                ),
                                                FilledButton.tonal(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: Text(l.commonDelete),
                                                ),
                                              ],
                                            ),
                                          ) ??
                                          false;

                                      if (!confirm) return;

                                      try {
                                        await m.deleteJar(j.id);
                                        await m.load();
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            content: Text(l.budgetJarDeleted),
                                          ),
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            content: Text(
                                              l.budgetJarDeleteFailed(
                                                e.toString(),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );

        // Компактный: список
        if (crossAxisCount == 1) {
          return Scaffold(
            body: NestBackground(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(pinned: true, title: Text(l.budgetSetupTitle)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: 12,
                    ),
                    sliver: SliverList.list(
                      children: [
                        incomeSection(),
                        const SizedBox(height: 12),
                        expenseSection(),
                        const SizedBox(height: 12),
                        jarsSection(),
                        const SizedBox(height: 88),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SaveBar(
              saving: _saving,
              onSave: () => _save(m),
            ),
          );
        }

        // Широкий: сетка
        final children = <Widget>[
          incomeSection(),
          expenseSection(),
          jarsSection(),
        ];

        return Scaffold(
          body: NestBackground(
            child: CustomScrollView(
              slivers: [
                SliverAppBar.large(title: Text(l.budgetSetupTitle)),
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
          ),
          bottomNavigationBar: SaveBar(saving: _saving, onSave: () => _save(m)),
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
