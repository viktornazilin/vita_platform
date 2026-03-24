import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../models/budget_model.dart';
import 'package:nest_app/l10n/app_localizations.dart';

import '../../../widgets/nest/nest_background.dart';
import '../../../widgets/nest/nest_blur_card.dart';

import '../widgets/add_category_sheet.dart';
import '../widgets/add_jar_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/limit_sheet.dart';
import '../widgets/save_bar.dart';

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

  Future<void> _addCategory({
    required BuildContext context,
    required BudgetModel m,
    required bool income,
  }) async {
    final name = await showAddCategorySheet(context, income: income);
    if (name == null || name.trim().isEmpty) return;

    await m.createCategory(name.trim(), income ? 'income' : 'expense');
    await m.load();
  }

  Future<void> _deleteCategory({
    required BuildContext context,
    required BudgetModel m,
    required dynamic category,
  }) async {
    final l = AppLocalizations.of(context)!;

    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(l.budgetDeleteCategoryTitle),
            content: Text(l.budgetCategoryLabel(category.name as String)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.commonCancel),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.commonDelete),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    await m.deleteCategory(category.id as String);
    await m.load();
  }

  Future<void> _editExpenseLimit({
    required BuildContext context,
    required BudgetModel m,
    required dynamic category,
  }) async {
    final limit = await showLimitSheet(
      context,
      categoryName: category.name as String,
    );
    await m.setExpenseLimit(categoryId: category.id as String, limitRub: limit);
    await m.load();
  }

  Future<void> _showIncomeActions({
    required BuildContext context,
    required BudgetModel m,
    required dynamic category,
  }) async {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  category.name as String,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l.budgetIncomeCategoriesSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                _ActionRow(
                  icon: Icons.delete_outline_rounded,
                  title: l.commonDelete,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _deleteCategory(
                      context: context,
                      m: m,
                      category: category,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createJar(BuildContext context, BudgetModel m) async {
    final l = AppLocalizations.of(context)!;
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
  }

  Future<void> _deleteJar(BuildContext context, BudgetModel m, dynamic jar) async {
    final l = AppLocalizations.of(context)!;

    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(l.budgetDeleteJarTitle),
            content: Text(l.budgetJarLabel(jar.title as String)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.commonCancel),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.commonDelete),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      await m.deleteJar(jar.id as String);
      await m.load();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l.budgetJarDeleted),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l.budgetJarDeleteFailed(e.toString())),
        ),
      );
    }
  }

  Widget _buildCategorySection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<dynamic> categories,
    required Color tone,
    required VoidCallback onAdd,
    required Future<void> Function(dynamic category) onTap,
    required Future<void> Function(dynamic category) onMenuDelete,
    String? helper,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return _NestSection(
      icon: icon,
      tone: tone,
      title: title,
      subtitle: subtitle,
      trailing: FilledButton.tonalIcon(
        onPressed: onAdd,
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.of(context)!.commonAdd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (helper != null) ...[
            Text(
              helper,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (categories.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.28),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.45),
                ),
              ),
              child: Text(
                subtitle,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((c) {
                return _CategoryPill(
                  label: c.name as String,
                  tone: tone,
                  onTap: () => onTap(c),
                  onDelete: () => onMenuDelete(c),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildJarsSection(BuildContext context, BudgetModel m) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return _NestSection(
      icon: Icons.savings_outlined,
      tone: cs.tertiaryContainer,
      title: l.budgetJarsTitle,
      subtitle: l.budgetJarsSubtitle,
      trailing: FilledButton.tonalIcon(
        onPressed: () => _createJar(context, m),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.budgetAddJar),
      ),
      child: m.jars.isEmpty
          ? EmptyState(
              icon: Icons.savings_outlined,
              title: l.budgetNoJarsTitle,
              subtitle: l.budgetNoJarsSubtitle,
            )
          : Column(
              children: m.jars.map((j) {
                final target = j.targetAmount as num?;
                final progress = (target == null || target <= 0)
                    ? null
                    : ((j.currentAmount as num) / target).clamp(0.0, 1.0);
                final targetStr = target != null ? target.toStringAsFixed(0) : '—';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NestBlurCard(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: cs.tertiaryContainer.withOpacity(0.55),
                              border: Border.all(
                                color: cs.outlineVariant.withOpacity(0.4),
                              ),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: cs.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  j.title as String,
                                  style: tt.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l.budgetJarSummary(
                                    (j.currentAmount as num).toStringAsFixed(0),
                                    (j.percentOfFree as num).toStringAsFixed(0),
                                    targetStr,
                                  ),
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                if (progress != null) ...[
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: progress.toDouble(),
                                      minHeight: 10,
                                      backgroundColor: cs.surfaceContainerHighest
                                          .withOpacity(0.45),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: l.commonDelete,
                            onPressed: () => _deleteJar(context, m, j),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final m = context.watch<BudgetModel>();
    final cs = Theme.of(context).colorScheme;

    if (m.loading) {
      return Scaffold(
        body: NestBackground(
          child: const Center(child: CircularProgressIndicator.adaptive()),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1180 ? 2 : 1;
        final horizontalPad = width >= 1180 ? 24.0 : 16.0;

        final sections = <Widget>[
          _buildCategorySection(
            context: context,
            title: l.budgetIncomeCategoriesTitle,
            subtitle: l.budgetIncomeCategoriesSubtitle,
            icon: Icons.trending_up_rounded,
            categories: m.incomeCategories,
            tone: cs.primaryContainer,
            helper: 'Доходные категории теперь тоже можно полноценно добавлять и удалять.',
            onAdd: () => _addCategory(context: context, m: m, income: true),
            onTap: (category) => _showIncomeActions(
              context: context,
              m: m,
              category: category,
            ),
            onMenuDelete: (category) => _deleteCategory(
              context: context,
              m: m,
              category: category,
            ),
          ),
          _buildCategorySection(
            context: context,
            title: l.budgetExpenseCategoriesTitle,
            subtitle: l.budgetExpenseCategoriesSubtitle,
            icon: Icons.shopping_bag_outlined,
            categories: m.expenseCategories,
            tone: cs.secondaryContainer,
            helper: 'Нажатие по категории открывает установку лимита.',
            onAdd: () => _addCategory(context: context, m: m, income: false),
            onTap: (category) => _editExpenseLimit(
              context: context,
              m: m,
              category: category,
            ),
            onMenuDelete: (category) => _deleteCategory(
              context: context,
              m: m,
              category: category,
            ),
          ),
          _buildJarsSection(context, m),
        ];

        return Scaffold(
          body: NestBackground(
            child: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  title: Text(l.budgetSetupTitle),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(horizontalPad, 8, horizontalPad, 96),
                  sliver: crossAxisCount == 1
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == sections.length - 1 ? 0 : 14,
                              ),
                              child: sections[index],
                            );
                          }, childCount: sections.length),
                        )
                      : SliverGrid(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            return sections[index];
                          }, childCount: sections.length),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.16,
                          ),
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
      },
    );
  }
}

class _NestSection extends StatelessWidget {
  final IconData icon;
  final Color tone;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  const _NestSection({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return NestBlurCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: tone.withOpacity(0.72),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.35),
                    ),
                  ),
                  child: Icon(icon, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (trailing != null) ...[
              const SizedBox(height: 16),
              trailing!,
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final Color tone;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CategoryPill({
    required this.label,
    required this.tone,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: tone.withOpacity(0.62),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: cs.surfaceContainerHighest.withOpacity(0.28),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Icon(icon, color: cs.onSurface),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

extension BudgetModelSave on BudgetModel {
  Future<bool> save() async {
    try {
      return true;
    } catch (_) {
      return false;
    }
  }
}
