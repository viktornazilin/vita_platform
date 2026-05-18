// lib/screens/onboarding_questionnaire_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../main.dart'; // dbRepo
import '../models/life_block.dart';
import '../models/onboarding_questionnaire_model.dart';
import '../services/user_service.dart';

import '../widgets/nest/nest_background.dart';
import '../services/onboarding_tour_service.dart';

class OnboardingQuestionnaireScreen extends StatelessWidget {
  final VoidCallback? onCompleted;
  final UserService userService;

  const OnboardingQuestionnaireScreen({
    super.key,
    this.onCompleted,
    required this.userService,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingQuestionnaireModel(
        service: userService,
        goalsRepo: dbRepo,
      ),
      child: _QuestionnaireScaffold(onCompleted: onCompleted),
    );
  }
}

class _QuestionnaireScaffold extends StatefulWidget {
  final VoidCallback? onCompleted;

  const _QuestionnaireScaffold({
    this.onCompleted,
  });

  @override
  State<_QuestionnaireScaffold> createState() => _QuestionnaireScaffoldState();
}

class _QuestionnaireScaffoldState extends State<_QuestionnaireScaffold> {
  final _pageController = PageController();

  final GlobalKey _progressKey = GlobalKey();
  final GlobalKey _stepKey = GlobalKey();
  final GlobalKey _nextKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowQuestionnaireOnboarding();
    });
  }

  void _maybeShowQuestionnaireOnboarding() {
    if (!mounted) return;

    OnboardingTourService.showQuestionnaireTourIfNeeded(
      context: context,
      progressKey: _progressKey,
      stepKey: _stepKey,
      nextKey: _nextKey,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildSteps(
    OnboardingQuestionnaireModel model,
    AppLocalizations l,
  ) {
    final steps = <Widget>[
      const _StepProfileBasics(),
      const _StepLifeBlocks(),
      _StepPriorities(options: _prioritiesOptions(l)),
    ];

    for (final block in model.selectedBlocks) {
      steps.add(_StepBlockGoals(block: block));
    }

    return steps;
  }

  List<String> _prioritiesOptions(AppLocalizations l) {
    return [
      l.onbPriorityHealth,
      l.onbPriorityCareer,
      l.onbPriorityMoney,
      l.onbPriorityFamily,
      l.onbPriorityGrowth,
      l.onbPriorityLove,
      l.onbPriorityCreativity,
      l.onbPriorityBalance,
    ];
  }

  void _goNext(OnboardingQuestionnaireModel model, int stepsLen) {
    if (model.currentStep < stepsLen - 1) {
      _pageController.animateToPage(
        model.currentStep + 1,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    } else {
      _submit(model);
    }
  }

  void _goPrev(OnboardingQuestionnaireModel model) {
    if (model.currentStep > 0) {
      _pageController.animateToPage(
        model.currentStep - 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _submit(OnboardingQuestionnaireModel model) async {
    if (model.isLoading) return;

    final ok = await model.submit();
    if (!mounted) return;

    final l = AppLocalizations.of(context)!;

    if (ok) {
      if (widget.onCompleted != null) {
        widget.onCompleted!.call();
      } else {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } else {
      final msg = model.errorText ?? l.onbErrSaveFailed;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<OnboardingQuestionnaireModel>();
    final steps = _buildSteps(model, l);
    final stepsLen = steps.length;

    if (stepsLen > 0 && model.currentStep > stepsLen - 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final safe = stepsLen - 1;
        _pageController.jumpToPage(safe);
        model.currentStep = safe;
        model.notifyListeners();
      });
    }

    final progress = stepsLen == 0 ? 0.0 : (model.currentStep + 1) / stepsLen;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _QuestionnaireTopBar(
                    title: l.onbTopTitle,
                    stepText: '${model.currentStep + 1}/$stepsLen',
                    onBack: () => Navigator.of(context).maybePop(),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: KeyedSubtree(
                        key: _progressKey,
                        child: _NestProgress(value: progress),
                      ),
                    ),
                  ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const PageScrollPhysics(),
                      onPageChanged: (index) {
                        if (index > model.currentStep) {
                          model.nextStep(maxIndex: stepsLen - 1);
                        } else if (index < model.currentStep) {
                          model.prevStep();
                        }
                      },
                      children: [
                        for (var i = 0; i < steps.length; i++)
                          KeyedSubtree(
                            key: i == model.currentStep
                                ? _stepKey
                                : ValueKey('onboarding_step_$i'),
                            child: steps[i],
                          ),
                      ],
                    ),
                  ),

                  if (model.errorText != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: _GlassCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  model.errorText!,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  _BottomActions(
                    backLabel: l.commonBack,
                    nextLabel: model.currentStep == stepsLen - 1
                        ? l.commonDone
                        : l.commonNext,
                    isFirstStep: model.currentStep == 0,
                    isLoading: model.isLoading,
                    nextKey: _nextKey,
                    onBack: () => _goPrev(model),
                    onNext: () => _goNext(model, stepsLen),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuestionnaireTopBar extends StatelessWidget {
  final String title;
  final String stepText;
  final VoidCallback onBack;

  const _QuestionnaireTopBar({
    required this.title,
    required this.stepText,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Row(
          children: [
            _GlassIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: onBack,
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
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stepText,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark
                    ? cs.surfaceContainerHigh.withOpacity(0.62)
                    : cs.surface.withOpacity(0.76),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(isDark ? 0.32 : 0.62),
                ),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: cs.primary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final String backLabel;
  final String nextLabel;
  final bool isFirstStep;
  final bool isLoading;
  final GlobalKey nextKey;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomActions({
    required this.backLabel,
    required this.nextLabel,
    required this.isFirstStep,
    required this.isLoading,
    required this.nextKey,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 14 + safeBottom),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: isFirstStep ? null : onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(
                      color: cs.primary.withOpacity(0.28),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    backLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KeyedSubtree(
                key: nextKey,
                child: SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: isLoading ? null : onNext,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            nextLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _StepScaffold({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + safeBottom),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              _GlassCard(
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepProfileBasics extends StatefulWidget {
  const _StepProfileBasics();

  @override
  State<_StepProfileBasics> createState() => _StepProfileBasicsState();
}

class _StepProfileBasicsState extends State<_StepProfileBasics> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;

  @override
  void initState() {
    super.initState();

    final model = context.read<OnboardingQuestionnaireModel>();

    _nameCtrl = TextEditingController(text: model.name ?? '');
    _ageCtrl = TextEditingController(
      text: model.age != null ? model.age.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<OnboardingQuestionnaireModel>();

    return _StepScaffold(
      title: l.onbProfileTitle,
      subtitle: l.onbProfileSubtitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NestTextField(
            controller: _nameCtrl,
            labelText: l.onbNameLabel,
            hintText: l.onbNameHint,
            keyboardType: TextInputType.text,
            onChanged: (value) {
              final trimmed = value.trim();
              model.setName(trimmed.isEmpty ? null : trimmed);
            },
          ),
          const SizedBox(height: 14),
          _NestTextField(
            controller: _ageCtrl,
            labelText: l.onbAgeLabel,
            hintText: l.onbAgeHint,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final trimmed = value.trim();

              if (trimmed.isEmpty) {
                model.setAge(null);
                return;
              }

              final parsed = int.tryParse(trimmed);
              if (parsed == null) return;

              model.setAge(parsed);
            },
          ),
          const SizedBox(height: 14),
          _InfoNote(text: l.onbNameNote),
        ],
      ),
    );
  }
}

class _StepLifeBlocks extends StatelessWidget {
  const _StepLifeBlocks();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<OnboardingQuestionnaireModel>();

    return _StepScaffold(
      title: l.onbBlocksTitle,
      subtitle: l.onbBlocksSubtitle,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: LifeBlock.values.map((block) {
          final selected = model.selectedBlocks.contains(block);

          return _NestSelectChip(
            label: getBlockLabel(block),
            selected: selected,
            onTap: () => model.toggleBlock(block),
          );
        }).toList(),
      ),
    );
  }
}

class _StepPriorities extends StatelessWidget {
  final List<String> options;

  const _StepPriorities({
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<OnboardingQuestionnaireModel>();

    return _StepScaffold(
      title: l.onbPrioritiesTitle,
      subtitle: l.onbPrioritiesSubtitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: options.map((priority) {
              final selected = model.selectedPriorities.contains(priority);

              return _NestSelectChip(
                label: priority,
                selected: selected,
                onTap: () => model.togglePriority(priority, max: 3),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StepBlockGoals extends StatefulWidget {
  final LifeBlock block;

  const _StepBlockGoals({
    required this.block,
  });

  @override
  State<_StepBlockGoals> createState() => _StepBlockGoalsState();
}

class _StepBlockGoalsState extends State<_StepBlockGoals> {
  late final TextEditingController _tacticalCtrl;
  late final TextEditingController _midCtrl;
  late final TextEditingController _longCtrl;
  late final TextEditingController _whyCtrl;

  @override
  void initState() {
    super.initState();

    final model = context.read<OnboardingQuestionnaireModel>();

    _tacticalCtrl = TextEditingController(
      text: model.goalsTacticalByBlock?[widget.block.name] ?? '',
    );
    _midCtrl = TextEditingController(
      text: model.goalsMidByBlock?[widget.block.name] ?? '',
    );
    _longCtrl = TextEditingController(
      text: model.goalsLongByBlock?[widget.block.name] ?? '',
    );
    _whyCtrl = TextEditingController(
      text: model.whyByBlock?[widget.block.name] ?? '',
    );
  }

  @override
  void dispose() {
    _tacticalCtrl.dispose();
    _midCtrl.dispose();
    _longCtrl.dispose();
    _whyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<OnboardingQuestionnaireModel>();
    final label = getBlockLabel(widget.block);

    return _StepScaffold(
      title: l.onbGoalsBlockTitle(label),
      subtitle: l.onbGoalsBlockSubtitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NestTextField(
            controller: _longCtrl,
            labelText: l.onbGoalLongLabel,
            hintText: l.onbGoalLongHint,
            maxLines: 2,
            onChanged: (value) {
              model.setBlockGoalLong(widget.block, value);
            },
          ),
          const SizedBox(height: 14),
          _NestTextField(
            controller: _midCtrl,
            labelText: l.onbGoalMidLabel,
            hintText: l.onbGoalMidHint,
            maxLines: 2,
            onChanged: (value) {
              model.setBlockGoalMid(widget.block, value);
            },
          ),
          const SizedBox(height: 14),
          _NestTextField(
            controller: _tacticalCtrl,
            labelText: l.onbGoalTacticalLabel,
            hintText: l.onbGoalTacticalHint,
            maxLines: 2,
            onChanged: (value) {
              model.setBlockGoalTactical(widget.block, value);
            },
          ),
          const SizedBox(height: 14),
          _NestTextField(
            controller: _whyCtrl,
            labelText: l.onbWhyLabel,
            hintText: l.onbWhyHint,
            maxLines: 2,
            onChanged: (value) {
              model.setBlockWhy(widget.block, value);
            },
          ),
          const SizedBox(height: 14),
          _InfoNote(text: l.onbOptionalNote),
        ],
      ),
    );
  }
}

class _NestProgress extends StatelessWidget {
  final double value;

  const _NestProgress({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 9,
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHighest.withOpacity(0.36)
              : cs.surfaceContainerHighest.withOpacity(0.50),
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      cs.primary.withOpacity(0.95),
                      cs.secondary.withOpacity(0.86),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.white.withOpacity(0.18),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? cs.surfaceContainerHigh.withOpacity(0.70)
                : cs.surface.withOpacity(0.80),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(isDark ? 0.34 : 0.60),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.18)
                    : cs.primary.withOpacity(0.07),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? cs.surfaceContainerHigh.withOpacity(0.62)
                  : cs.surface.withOpacity(0.76),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withOpacity(isDark ? 0.32 : 0.62),
              ),
            ),
            child: Icon(
              icon,
              color: cs.onSurface,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  final String text;

  const _InfoNote({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: cs.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NestSelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NestSelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = selected
        ? cs.primary.withOpacity(0.94)
        : isDark
            ? cs.surfaceContainerHighest.withOpacity(0.52)
            : cs.surface.withOpacity(0.76);

    final border = selected
        ? cs.primary.withOpacity(0.44)
        : cs.outlineVariant.withOpacity(isDark ? 0.34 : 0.58);

    final fg = selected ? Colors.white : cs.onSurface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.12)
                        : cs.primary.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: fg,
                        letterSpacing: 0.1,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NestTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const _NestTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        color: cs.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: isDark
            ? cs.surfaceContainerHighest.withOpacity(0.28)
            : cs.surface.withOpacity(0.76),
        labelStyle: TextStyle(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: cs.onSurfaceVariant.withOpacity(0.62),
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: cs.outlineVariant.withOpacity(0.60),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: cs.outlineVariant.withOpacity(isDark ? 0.34 : 0.58),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: cs.primary,
            width: 1.4,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }
}