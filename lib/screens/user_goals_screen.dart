import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/profile_model.dart';
import '../models/user_goal.dart';
import '../models/user_goals_model.dart';
import '../widgets/block_chip.dart';
import '../widgets/nest/nest_background.dart';
import '../widgets/nest/nest_blur_card.dart';
import '../services/onboarding_tour_service.dart';
import '../l10n/app_localizations.dart';


String _localizedLifeBlockLabel(BuildContext context, String key) {
  final l = AppLocalizations.of(context)!;

  switch (key.toLowerCase()) {
    case 'health':
      return l.lifeBlockHealth;
    case 'career':
      return l.lifeBlockCareer;
    case 'family':
      return l.lifeBlockFamily;
    case 'finance':
      return l.lifeBlockFinance;
    case 'education':
      return l.lifeBlockEducation;
    case 'hobbies':
    case 'hobby':
      return l.lifeBlockHobbies;
    case 'general':
      return l.lifeBlockGeneral;
    default:
      return key;
  }
}

String _localizedHorizonLabel(BuildContext context, GoalHorizon horizon) {
  final l = AppLocalizations.of(context)!;

  switch (horizon.name) {
    case 'tactical':
      return l.goalsHorizonTacticalShort;
    case 'mid':
      return l.goalsHorizonMidShort;
    case 'long':
      return l.goalsHorizonLongShort;
    default:
      return horizon.labelRu;
  }
}

class UserGoalsScreen extends StatelessWidget {
  const UserGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileModel(repo: dbRepo)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserGoalsModel(repo: dbRepo)..load(),
        ),
      ],
      child: const _UserGoalsView(),
    );
  }
}

class _UserGoalsView extends StatefulWidget {
  const _UserGoalsView();

  @override
  State<_UserGoalsView> createState() => _UserGoalsViewState();
}

class _UserGoalsViewState extends State<_UserGoalsView> {
  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _filtersKey = GlobalKey();
  final GlobalKey _addKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    OnboardingTourService.activeHomeTab.addListener(_maybeShowUserGoalsOnboarding);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowUserGoalsOnboarding());
  }

  void _maybeShowUserGoalsOnboarding() {
    if (!mounted || OnboardingTourService.activeHomeTab.value != 2) return;

    if (OnboardingTourService.shouldRunFullStep(NestFullOnboardingStep.userGoals)) {
      OnboardingTourService.runFullFlowScreenStep(
        context: context,
        step: NestFullOnboardingStep.userGoals,
        showTour: () => OnboardingTourService.showUserGoalsTour(
          context: context,
          headerKey: _headerKey,
          filtersKey: _filtersKey,
          addKey: _addKey,
          markAsSeen: false,
        ),
      );
      return;
    }

    if (OnboardingTourService.isFullFlowActive) return;

    OnboardingTourService.showUserGoalsTourIfNeeded(
      context: context,
      headerKey: _headerKey,
      filtersKey: _filtersKey,
      addKey: _addKey,
    );
  }

  @override
  void dispose() {
    OnboardingTourService.activeHomeTab.removeListener(_maybeShowUserGoalsOnboarding);
    super.dispose();
  }

  Color _blockColor(String key) {
    switch (key.toLowerCase()) {
      case 'health':
        return const Color(0xFF2E7D32);
      case 'career':
        return const Color(0xFF4D8DFF);
      case 'finance':
        return const Color(0xFFF59D04);
      case 'education':
        return const Color(0xFF45D6D1);
      case 'family':
        return const Color(0xFFB56BFF);
      case 'relations':
        return const Color(0xFFFF4D94);
      case 'hobby':
      case 'hobbies':
        return const Color(0xFF7E57C2);
      default:
        return const Color(0xFF6C8CFF);
    }
  }

  String _horizonLabel(BuildContext context, GoalHorizon h) {
    return _localizedHorizonLabel(context, h);
  }

  String _lifeBlockLabel(BuildContext context, String key) {
    return _localizedLifeBlockLabel(context, key);
  }

  String _formatDate(BuildContext context, DateTime d) {
    return MaterialLocalizations.of(context).formatMediumDate(d);
  }

  Future<void> _openCreateDialog(
    BuildContext context,
    List<String> allowedBlocks,
  ) async {
    final model = context.read<UserGoalsModel>();
    final l = AppLocalizations.of(context)!;

    final result = await showDialog<_GoalFormResult>(
      context: context,
      builder: (_) => _GoalFormDialog(
        allowedBlocks: allowedBlocks,
      ),
    );

    if (result == null) return;

    try {
      await model.createGoal(
        lifeBlock: result.lifeBlock,
        horizon: result.horizon,
        title: result.title,
        description: result.description,
        targetDate: result.targetDate,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.userGoalsCreated),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.userGoalsCreateError('$e')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openEditDialog(
    BuildContext context,
    UserGoal goal,
    List<String> allowedBlocks,
  ) async {
    final model = context.read<UserGoalsModel>();
    final l = AppLocalizations.of(context)!;

    final result = await showDialog<_GoalFormResult>(
      context: context,
      builder: (_) => _GoalFormDialog(
        initial: goal,
        allowedBlocks: allowedBlocks,
      ),
    );

    if (result == null) return;

    try {
      await model.updateGoal(
        id: goal.id,
        lifeBlock: result.lifeBlock,
        horizon: result.horizon,
        title: result.title,
        description: result.description,
        targetDate: result.targetDate,
        sortOrder: goal.sortOrder,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.userGoalsUpdated),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.userGoalsUpdateError('$e')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openDetailsSheet(
    BuildContext context,
    UserGoal goal,
    List<String> allowedBlocks,
  ) async {
    final model = context.read<UserGoalsModel>();
    final l = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<_GoalAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GoalDetailsSheet(
        goal: goal,
        blockColor: _blockColor(goal.lifeBlock),
        horizonLabel: _horizonLabel(context, goal.horizon),
        formattedDate: goal.targetDate == null
            ? null
            : _formatDate(context, goal.targetDate!),
      ),
    );

    if (!context.mounted || action == null) return;

    switch (action) {
      case _GoalAction.edit:
        await _openEditDialog(context, goal, allowedBlocks);
        break;
      case _GoalAction.toggleCompleted:
        try {
          await model.toggleCompleted(goal);
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.userGoalsStatusChangeError('$e')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;
      case _GoalAction.delete:
        final ok =
            await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                title: Text(l.userGoalsDeleteConfirmTitle),
                content: Text(goal.title),
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

        try {
          await model.delete(goal.id);
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.userGoalsDeleteError('$e')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileModel>();
    final goals = context.watch<UserGoalsModel>();
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final allowedBlocks = profile.lifeBlocks
        .where((b) => b.trim().isNotEmpty && b.toLowerCase() != 'general')
        .toList();

    return Scaffold(
      floatingActionButton: allowedBlocks.isEmpty
          ? null
          : FloatingActionButton.extended(
              key: _addKey,
              onPressed: () => _openCreateDialog(context, allowedBlocks),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.userGoalsNewTitle),
            ),
      body: NestBackground(
        child: RefreshIndicator.adaptive(
          onRefresh: () => goals.load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: KeyedSubtree(
                    key: _headerKey,
                    child: NestBlurCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.userGoalsTitle,
                            style: tt.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.userGoalsSubtitle,
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                  ),
                ),
              ),

              // blocks
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _filtersKey,
                  child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: SizedBox(
                    height: 54,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        BlockChip(
                          label: l.userGoalsAllBlocks,
                          selected: goals.selectedBlock == 'all',
                          onTap: () => goals.setSelectedBlock('all'),
                        ),
                        ...allowedBlocks.map(
                          (b) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: BlockChip(
                              label: _lifeBlockLabel(context, b),
                              selected: goals.selectedBlock == b,
                              onTap: () => goals.setSelectedBlock(b),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ),

              // horizons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HorizonChip(
                        label: l.userGoalsAllHorizons,
                        selected: goals.selectedHorizon == null,
                        onTap: () => goals.setSelectedHorizon(null),
                      ),
                      for (final h in GoalHorizon.values)
                        _HorizonChip(
                          label: _horizonLabel(context, h),
                          selected: goals.selectedHorizon == h,
                          onTap: () => goals.setSelectedHorizon(h),
                        ),
                    ],
                  ),
                ),
              ),

              if (goals.loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (goals.error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    emoji: '⚠️',
                    title: l.userGoalsLoadErrorTitle,
                    subtitle: goals.error,
                  ),
                )
              else if (allowedBlocks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    emoji: '🧩',
                    title: l.userGoalsNoActiveBlocksTitle,
                    subtitle: l.userGoalsNoActiveBlocksSubtitle,
                  ),
                )
              else if (goals.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    emoji: '🎯',
                    title: l.userGoalsEmptyTitle,
                    subtitle: l.userGoalsEmptySubtitle,
                    onAdd: () => _openCreateDialog(context, allowedBlocks),
                  ),
                )
              else ...[
                for (final horizon in GoalHorizon.values)
                  _buildSection(
                    context: context,
                    title: _horizonLabel(context, horizon),
                    items: goals.goalsByHorizon(horizon),
                    allowedBlocks: allowedBlocks,
                    blockColor: _blockColor,
                    onTapGoal: (goal) =>
                        _openDetailsSheet(context, goal, allowedBlocks),
                  ),
              ],

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<UserGoal> items,
    required List<String> allowedBlocks,
    required Color Function(String key) blockColor,
    required Future<void> Function(UserGoal goal) onTapGoal,
  }) {
    if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...items.map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GoalCard(
                  goal: goal,
                  blockColor: blockColor(goal.lifeBlock),
                  onTap: () => onTapGoal(goal),
                  subtitle: [
                    goal.description?.trim() ?? '',
                    if (goal.targetDate != null)
                      l.userGoalsDeadline(MaterialLocalizations.of(context).formatMediumDate(goal.targetDate!)),
                  ].where((e) => e.trim().isNotEmpty).join(' • '),
                  trailingIcon: goal.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  trailingColor: goal.isCompleted
                      ? cs.primary
                      : cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _GoalAction { edit, toggleCompleted, delete }

class _GoalDetailsSheet extends StatelessWidget {
  final UserGoal goal;
  final Color blockColor;
  final String horizonLabel;
  final String? formattedDate;

  const _GoalDetailsSheet({
    required this.goal,
    required this.blockColor,
    required this.horizonLabel,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: NestBlurCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: blockColor.withOpacity(0.16),
                ),
                child: Icon(Icons.flag_rounded, color: blockColor),
              ),
              const SizedBox(height: 12),
              Text(
                goal.title,
                textAlign: TextAlign.center,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _MetaPill(label: horizonLabel),
                  _MetaPill(
                    label: goal.isCompleted ? l.userGoalsStatusCompleted : l.userGoalsStatusActive,
                  ),
                  if (formattedDate != null)
                    _MetaPill(label: formattedDate!),
                ],
              ),
              if ((goal.description ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.35),
                    ),
                  ),
                  child: Text(goal.description!.trim()),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => Navigator.pop(context, _GoalAction.edit),
                      icon: const Icon(Icons.edit_rounded),
                      label: Text(l.commonEdit),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => Navigator.pop(
                        context,
                        _GoalAction.toggleCompleted,
                      ),
                      icon: Icon(
                        goal.isCompleted
                            ? Icons.radio_button_unchecked_rounded
                            : Icons.check_circle_outline_rounded,
                      ),
                      label: Text(goal.isCompleted ? l.userGoalsReopen : l.userGoalsComplete),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () => Navigator.pop(context, _GoalAction.delete),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l.commonDelete),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.errorContainer.withOpacity(0.75),
                    foregroundColor: cs.onErrorContainer,
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

class _GoalCard extends StatelessWidget {
  final UserGoal goal;
  final Color blockColor;
  final VoidCallback onTap;
  final String subtitle;
  final IconData trailingIcon;
  final Color trailingColor;

  const _GoalCard({
    required this.goal,
    required this.blockColor,
    required this.onTap,
    required this.subtitle,
    required this.trailingIcon,
    required this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: NestBlurCard(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: blockColor.withOpacity(0.16),
                  ),
                  child: Icon(
                    goal.isCompleted
                        ? Icons.check_rounded
                        : Icons.flag_rounded,
                    color: blockColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          decoration: goal.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (subtitle.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(trailingIcon, color: trailingColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  const _MetaPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.26),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HorizonChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HorizonChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: cs.primaryContainer.withOpacity(0.85),
      backgroundColor: cs.surfaceContainerHighest.withOpacity(0.26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      labelStyle: TextStyle(
        color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _GoalFormResult {
  final String lifeBlock;
  final GoalHorizon horizon;
  final String title;
  final String? description;
  final DateTime? targetDate;

  _GoalFormResult({
    required this.lifeBlock,
    required this.horizon,
    required this.title,
    this.description,
    this.targetDate,
  });
}

class _GoalFormDialog extends StatefulWidget {
  final UserGoal? initial;
  final List<String> allowedBlocks;

  const _GoalFormDialog({
    this.initial,
    required this.allowedBlocks,
  });

  @override
  State<_GoalFormDialog> createState() => _GoalFormDialogState();
}

class _GoalFormDialogState extends State<_GoalFormDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  late String _lifeBlock;
  late GoalHorizon _horizon;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initial?.title ?? '');
    _descCtrl = TextEditingController(text: widget.initial?.description ?? '');

    _lifeBlock = widget.initial?.lifeBlock ??
        (widget.allowedBlocks.isNotEmpty ? widget.allowedBlocks.first : 'health');

    _horizon = widget.initial?.horizon ?? GoalHorizon.tactical;
    _targetDate = widget.initial?.targetDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 10),
    );
    if (selected != null) {
      setState(() => _targetDate = DateUtils.dateOnly(selected));
    }
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    Navigator.pop(
      context,
      _GoalFormResult(
        lifeBlock: _lifeBlock,
        horizon: _horizon,
        title: title,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        targetDate: _targetDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(isEdit ? l.userGoalsEditTitle : l.userGoalsNewTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _lifeBlock,
              decoration: InputDecoration(
                labelText: l.userGoalsFieldLifeBlock,
              ),
              items: widget.allowedBlocks
                  .map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Text(_localizedLifeBlockLabel(context, b)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _lifeBlock = v);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<GoalHorizon>(
              value: _horizon,
              decoration: InputDecoration(
                labelText: l.userGoalsFieldHorizon,
              ),
              items: GoalHorizon.values
                  .map(
                    (h) => DropdownMenuItem(
                      value: h,
                      child: Text(_localizedHorizonLabel(context, h)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _horizon = v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              maxLength: 120,
              decoration: InputDecoration(
                labelText: l.userGoalsFieldTitle,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l.userGoalsFieldDescription,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                ),
                child: Text(
                  _targetDate == null
                      ? l.userGoalsPickTargetDate
                      : MaterialLocalizations.of(context).formatMediumDate(_targetDate!),
                ),
              ),
            ),
            if (_targetDate != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _targetDate = null),
                  child: Text(l.userGoalsClearDate),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEdit ? l.commonSave : l.commonCreate),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final VoidCallback? onAdd;

  const _EmptyState({
    required this.emoji,
    required this.title,
    this.subtitle,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 76,
                height: 76,
                color: cs.surfaceContainerHighest.withOpacity(0.30),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            if ((subtitle ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
            if (onAdd != null) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: Text(AppLocalizations.of(context)!.userGoalsCreateGoal),
              ),
            ],
          ],
        ),
      ),
    );
  }
}