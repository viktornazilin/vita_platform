import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nest_app/l10n/app_localizations.dart';
import 'package:nest_app/main.dart';
import 'package:nest_app/models/budget_model.dart';
import 'package:nest_app/services/onboarding_tour_service.dart';
import 'package:nest_app/widgets/add_category_sheet.dart';
import 'package:nest_app/widgets/add_jar_dialog.dart';
import 'package:nest_app/widgets/empty_state.dart';
import 'package:nest_app/widgets/limit_sheet.dart';
import 'package:nest_app/widgets/nest/nest_background.dart';


const _pageBackground = Color(0xFFD6D0EC);
const _surface = Color(0xFFF5F3FA);
const _card = Color(0xFFEAE6F5);
const _primary = Color(0xFF6B54C0);
const _primaryDark = Color(0xFF160E38);
const _muted = Color(0xFF9090A8);
const _text = Color(0xFF555268);
const _border = Color(0xFFE0DCF0);
const _lime = Color(0xFFD4E040);
const _teal = Color(0xFF16B8A8);

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
  final GlobalKey _incomeKey = GlobalKey();
  final GlobalKey _expenseKey = GlobalKey();
  final GlobalKey _jarsKey = GlobalKey();
  final GlobalKey _saveKey = GlobalKey();

  bool _saving = false;

  static const _pageBackground = Color(0xFFD6D0EC);
  static const _surface = Color(0xFFF5F3FA);
  static const _card = Color(0xFFEAE6F5);
  static const _primary = Color(0xFF6B54C0);
  static const _primaryDark = Color(0xFF160E38);
  static const _muted = Color(0xFF9090A8);
  static const _text = Color(0xFF555268);
  static const _border = Color(0xFFE0DCF0);
  static const _lime = Color(0xFFD4E040);
  static const _teal = Color(0xFF16B8A8);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybeShowBudgetOnboarding(),
    );
  }

  void _maybeShowBudgetOnboarding() {
    if (!mounted) return;
    OnboardingTourService.showBudgetTourIfNeeded(
      context: context,
      incomeKey: _incomeKey,
      expenseKey: _expenseKey,
      jarsKey: _jarsKey,
      saveKey: _saveKey,
    );
  }

  void _goBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed('/home');
    }
  }

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
              borderRadius: BorderRadius.circular(28),
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

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name as String,
                  style: const TextStyle(
                    color: _primaryDark,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l.budgetIncomeCategoriesSubtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 22),
                _ActionRow(
                  icon: Icons.delete_outline_rounded,
                  title: l.commonDelete,
                  tone: _primary,
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
              borderRadius: BorderRadius.circular(28),
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
    final l = AppLocalizations.of(context)!;

    return _LadnaSection(
      icon: icon,
      tone: tone,
      title: title,
      subtitle: subtitle,
      actionLabel: l.commonAdd,
      onAction: onAdd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (helper != null) ...[
            Text(
              helper,
              style: const TextStyle(
                color: _text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
          ],
          if (categories.isEmpty)
            _EmptySetupBox(text: subtitle, tone: tone)
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

    return _LadnaSection(
      icon: Icons.savings_outlined,
      tone: _lime,
      title: l.budgetJarsTitle,
      subtitle: l.budgetJarsSubtitle,
      actionLabel: l.budgetAddJar,
      onAction: () => _createJar(context, m),
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
                  child: _JarTile(
                    title: j.title as String,
                    summary: l.budgetJarSummary(
                      (j.currentAmount as num).toStringAsFixed(0),
                      (j.percentOfFree as num).toStringAsFixed(0),
                      targetStr,
                    ),
                    progress: progress?.toDouble(),
                    onDelete: () => _deleteJar(context, m, j),
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

    if (m.loading) {
      return const Scaffold(
        body: NestBackground(
          useSoftGradient: true,
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: NestBackground(
        useSoftGradient: true,
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _SetupHeader(
                    title: l.budgetSetupTitle,
                    subtitle: _BudgetSetupText.of(context).setupSubtitle,
                    onBack: _goBack,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                sliver: SliverList.list(
                  children: [
                    KeyedSubtree(
                      key: _incomeKey,
                      child: _buildCategorySection(
                        context: context,
                        title: l.budgetIncomeCategoriesTitle,
                        subtitle: l.budgetIncomeCategoriesSubtitle,
                        icon: Icons.trending_up_rounded,
                        categories: m.incomeCategories,
                        tone: _teal,
                        helper: _BudgetSetupText.of(context).incomeHelper,
                        onAdd: () => _addCategory(
                          context: context,
                          m: m,
                          income: true,
                        ),
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
                    ),
                    const SizedBox(height: 18),
                    KeyedSubtree(
                      key: _expenseKey,
                      child: _buildCategorySection(
                        context: context,
                        title: l.budgetExpenseCategoriesTitle,
                        subtitle: l.budgetExpenseCategoriesSubtitle,
                        icon: Icons.shopping_bag_outlined,
                        categories: m.expenseCategories,
                        tone: _primary,
                        helper: _BudgetSetupText.of(context).expenseHelper,
                        onAdd: () => _addCategory(
                          context: context,
                          m: m,
                          income: false,
                        ),
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
                    ),
                    const SizedBox(height: 18),
                    KeyedSubtree(
                      key: _jarsKey,
                      child: _buildJarsSection(context, m),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: KeyedSubtree(
        key: _saveKey,
        child: _LadnaSaveBar(
          saving: _saving,
          label: l.commonSave,
          onSave: () => _save(m),
        ),
      ),
    );
  }
}


class _BudgetSetupText {
  final Locale locale;

  const _BudgetSetupText(this.locale);

  static _BudgetSetupText of(BuildContext context) => _BudgetSetupText(Localizations.localeOf(context));

  bool get _ru => locale.languageCode == 'ru';
  bool get _de => locale.languageCode == 'de';
  bool get _fr => locale.languageCode == 'fr';
  bool get _es => locale.languageCode == 'es';
  bool get _tr => locale.languageCode == 'tr';

  String get setupSubtitle => _ru
      ? 'Категории, лимиты и копилки'
      : _de
          ? 'Kategorien, Limits und Sparziele'
          : _fr
              ? 'Catégories, limites et cagnottes'
              : _es
                  ? 'Categorías, límites y ahorros'
                  : _tr
                      ? 'Kategoriler, limitler ve kumbaralar'
                      : 'Categories, limits and jars';

  String get incomeHelper => _ru
      ? 'Для зарплаты и других доходов.'
      : _de
          ? 'Für Gehalt und andere Einnahmen.'
          : _fr
              ? 'Pour le salaire et les autres revenus.'
              : _es
                  ? 'Para salario y otros ingresos.'
                  : _tr
                      ? 'Maaş ve diğer gelirler için.'
                      : 'For salary and other income.';

  String get expenseHelper => _ru
      ? 'Нажми на категорию, чтобы настроить лимит.'
      : _de
          ? 'Tippe auf eine Kategorie, um ein Limit festzulegen.'
          : _fr
              ? 'Appuie sur une catégorie pour régler une limite.'
              : _es
                  ? 'Toca una categoría para configurar un límite.'
                  : _tr
                      ? 'Limit ayarlamak için kategoriye dokun.'
                      : 'Tap a category to set a limit.';
}

class _SetupHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _SetupHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_surface, _card]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.chevron_left_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primaryDark,
                    fontSize: 18,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LadnaSection extends StatelessWidget {
  final IconData icon;
  final Color tone;
  final String title;
  final String subtitle;
  final Widget child;
  final String actionLabel;
  final VoidCallback onAction;

  const _LadnaSection({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tone.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tone.withOpacity(0.20)),
                ),
                child: Icon(icon, color: tone, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _primaryDark,
                        fontSize: 17,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11.5,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _PrimaryActionButton(
                label: actionLabel,
                icon: Icons.add_rounded,
                onTap: onAction,
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 38, maxWidth: 230),
          padding: const EdgeInsets.fromLTRB(13, 8, 9, 8),
          decoration: BoxDecoration(
            color: Color.lerp(_card, tone, 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color.lerp(_border, tone, 0.32)!),
            boxShadow: [
              BoxShadow(
                color: tone.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(
                    Icons.close_rounded,
                    size: 17,
                    color: _text,
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

class _JarTile extends StatelessWidget {
  final String title;
  final String summary;
  final double? progress;
  final VoidCallback onDelete;

  const _JarTile({
    required this.title,
    required this.summary,
    required this.progress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _lime.withOpacity(0.20),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, color: _primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _primaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 11.5,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: _card,
                      color: _lime,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: _text),
          ),
        ],
      ),
    );
  }
}

class _EmptySetupBox extends StatelessWidget {
  final String text;
  final Color tone;

  const _EmptySetupBox({required this.text, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color.lerp(_surface, tone, 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Color.lerp(_border, tone, 0.20)!),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _text,
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _card.withOpacity(0.82),
            shape: BoxShape.circle,
            border: Border.all(color: _border),
          ),
          child: Icon(icon, color: _text, size: 25),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color tone;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Color.lerp(_surface, tone, 0.06),
            border: Border.all(color: Color.lerp(_border, tone, 0.28)!),
          ),
          child: Row(
            children: [
              Icon(icon, color: _primaryDark),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _primaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _text),
            ],
          ),
        ),
      ),
    );
  }
}

class _LadnaSaveBar extends StatelessWidget {
  final bool saving;
  final String label;
  final VoidCallback onSave;

  const _LadnaSaveBar({required this.saving, required this.label, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: _surface.withOpacity(0.94),
          border: const Border(top: BorderSide(color: _border)),
          boxShadow: [
            BoxShadow(
              color: _primaryDark.withOpacity(0.12),
              blurRadius: 22,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: saving ? null : onSave,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save_outlined, color: Colors.white, size: 19),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
            ),
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
