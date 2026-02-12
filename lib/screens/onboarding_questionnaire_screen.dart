// lib/screens/onboarding_questionnaire_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../main.dart'; // dbRepo
import '../models/life_block.dart';
import '../models/onboarding_questionnaire_model.dart';
import '../services/user_service.dart';

// ✅ Nest
import '../widgets/nest/nest_background.dart';
import '../widgets/nest/nest_blur_card.dart';

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
        goalsRepo: dbRepo, // ✅ добавили
      ),
      child: _QuestionnaireScaffold(onCompleted: onCompleted),
    );
  }
}

class _QuestionnaireScaffold extends StatefulWidget {
  final VoidCallback? onCompleted;
  const _QuestionnaireScaffold({this.onCompleted});

  @override
  State<_QuestionnaireScaffold> createState() => _QuestionnaireScaffoldState();
}

class _QuestionnaireScaffoldState extends State<_QuestionnaireScaffold> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildSteps(OnboardingQuestionnaireModel m, AppLocalizations l) {
    final steps = <Widget>[
      const _StepProfileBasics(),
      const _StepLifeBlocks(),
      _StepPriorities(options: _prioritiesOptions(l)),
    ];

    for (final b in m.selectedBlocks) {
      steps.add(_StepBlockGoals(block: b));
    }
    return steps;
  }

  List<String> _prioritiesOptions(AppLocalizations l) => [
    l.onbPriorityHealth,
    l.onbPriorityCareer,
    l.onbPriorityMoney,
    l.onbPriorityFamily,
    l.onbPriorityGrowth,
    l.onbPriorityLove,
    l.onbPriorityCreativity,
    l.onbPriorityBalance,
  ];

  void _goNext(OnboardingQuestionnaireModel m, int stepsLen) {
    if (m.currentStep < stepsLen - 1) {
      _pageController.animateToPage(
        m.currentStep + 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } else {
      _submit(m);
    }
  }

  void _goPrev(OnboardingQuestionnaireModel m) {
    if (m.currentStep > 0) {
      _pageController.animateToPage(
        m.currentStep - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit(OnboardingQuestionnaireModel m) async {
    if (m.isLoading) return;

    final ok = await m.submit();
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
      final msg = m.errorText ?? l.onbErrSaveFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final m = context.watch<OnboardingQuestionnaireModel>();
    final steps = _buildSteps(m, l);
    final stepsLen = steps.length;

    if (stepsLen > 0 && m.currentStep > stepsLen - 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final safe = stepsLen - 1;
        _pageController.jumpToPage(safe);
        m.currentStep = safe;
        m.notifyListeners();
      });
    }

    final progress = stepsLen == 0 ? 0.0 : (m.currentStep + 1) / stepsLen;

    return Scaffold(
      body: NestBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ===== Top bar (Nest) =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: l.commonBack,
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          l.onbTopTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 44), // баланс для центрирования
                    ],
                  ),
                ),
              ),

              // ===== Progress (Nest) =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: NestBlurCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _NestProgress(value: progress),
                    ),
                  ),
                ),
              ),

              // ===== Steps =====
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const PageScrollPhysics(),
                  onPageChanged: (i) {
                    if (i > m.currentStep) {
                      m.nextStep(maxIndex: stepsLen - 1);
                    } else if (i < m.currentStep) {
                      m.prevStep();
                    }
                  },
                  children: steps,
                ),
              ),

              if (m.errorText != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: NestBlurCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                m.errorText!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ===== Bottom actions (Nest) =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: NestBlurCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: m.currentStep == 0
                                  ? null
                                  : () => _goPrev(m),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(l.commonBack),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: m.isLoading
                                  ? null
                                  : () => _goNext(m, stepsLen),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: m.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator.adaptive(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : (m.currentStep == stepsLen - 1
                                        ? Text(l.commonDone)
                                        : Text(l.commonNext)),
                            ),
                          ),
                        ],
                      ),
                    ),
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

/// ---------- общий контейнер шага (Nest) ----------
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: NestBlurCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: child,
                        ),
                      ),
                    ),
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

/// ✅ Новый шаг: базовые данные профиля
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
    final m = context.read<OnboardingQuestionnaireModel>();
    _nameCtrl = TextEditingController(text: m.name ?? '');
    _ageCtrl = TextEditingController(
      text: m.age != null ? m.age.toString() : '',
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
    final m = context.watch<OnboardingQuestionnaireModel>();

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
            onChanged: (v) => m.setName(v.trim().isEmpty ? null : v.trim()),
          ),
          const SizedBox(height: 12),
          _NestTextField(
            controller: _ageCtrl,
            labelText: l.onbAgeLabel,
            hintText: l.onbAgeHint,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final t = v.trim();
              if (t.isEmpty) return m.setAge(null);
              final parsed = int.tryParse(t);
              if (parsed == null) return;
              m.setAge(parsed);
            },
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: .75,
            child: Text(
              l.onbNameNote,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// шаг: выбор сфер жизни
class _StepLifeBlocks extends StatelessWidget {
  const _StepLifeBlocks();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final m = context.watch<OnboardingQuestionnaireModel>();

    return _StepScaffold(
      title: l.onbBlocksTitle,
      subtitle: l.onbBlocksSubtitle,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: LifeBlock.values.map((b) {
          final selected = m.selectedBlocks.contains(b);
          return _NestSelectChip(
            label: getBlockLabel(b),
            selected: selected,
            onTap: () => m.toggleBlock(b),
          );
        }).toList(),
      ),
    );
  }
}

/// шаг: приоритеты (options передаём извне, чтобы строки не были “ключами”)
class _StepPriorities extends StatelessWidget {
  final List<String> options;
  const _StepPriorities({required this.options});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final m = context.watch<OnboardingQuestionnaireModel>();

    return _StepScaffold(
      title: l.onbPrioritiesTitle,
      subtitle: l.onbPrioritiesSubtitle,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: options.map((p) {
          final selected = m.selectedPriorities.contains(p);
          return _NestSelectChip(
            label: p,
            selected: selected,
            onTap: () => m.togglePriority(p, max: 3),
          );
        }).toList(),
      ),
    );
  }
}

/// ✅ Новый динамический шаг: цели по сфере
class _StepBlockGoals extends StatefulWidget {
  final LifeBlock block;
  const _StepBlockGoals({required this.block});

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
    final m = context.read<OnboardingQuestionnaireModel>();

    _tacticalCtrl = TextEditingController(
      text: m.goalsTacticalByBlock?[widget.block.name] ?? '',
    );
    _midCtrl = TextEditingController(
      text: m.goalsMidByBlock?[widget.block.name] ?? '',
    );
    _longCtrl = TextEditingController(
      text: m.goalsLongByBlock?[widget.block.name] ?? '',
    );
    _whyCtrl = TextEditingController(
      text: m.whyByBlock?[widget.block.name] ?? '',
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
    final m = context.watch<OnboardingQuestionnaireModel>();
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
            onChanged: (v) => m.setBlockGoalLong(widget.block, v),
          ),
          const SizedBox(height: 12),
          _NestTextField(
            controller: _midCtrl,
            labelText: l.onbGoalMidLabel,
            hintText: l.onbGoalMidHint,
            maxLines: 2,
            onChanged: (v) => m.setBlockGoalMid(widget.block, v),
          ),
          const SizedBox(height: 12),
          _NestTextField(
            controller: _tacticalCtrl,
            labelText: l.onbGoalTacticalLabel,
            hintText: l.onbGoalTacticalHint,
            maxLines: 2,
            onChanged: (v) => m.setBlockGoalTactical(widget.block, v),
          ),
          const SizedBox(height: 12),
          _NestTextField(
            controller: _whyCtrl,
            labelText: l.onbWhyLabel,
            hintText: l.onbWhyHint,
            maxLines: 2,
            onChanged: (v) => m.setBlockWhy(widget.block, v),
          ),
          const SizedBox(height: 6),
          Opacity(
            opacity: .75,
            child: Text(
              l.onbOptionalNote,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Nest UI bits
// ============================================================================

class _NestProgress extends StatelessWidget {
  final double value;
  const _NestProgress({required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 10,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: cs.surfaceContainerHighest.withOpacity(0.35),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      cs.primary.withOpacity(0.95),
                      cs.primary.withOpacity(0.55),
                    ],
                  ),
                ),
              ),
            ),
            // light sheen
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

    final bg = selected
        ? cs.primary.withOpacity(0.92)
        : cs.surface.withOpacity(0.70);

    final border = selected
        ? cs.primary.withOpacity(0.35)
        : cs.outlineVariant.withOpacity(0.55);

    final fg = selected ? Colors.white : cs.onSurface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: bg,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: fg,
                  letterSpacing: 0.15,
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

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: cs.surfaceContainerHighest.withOpacity(0.30),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.65)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cs.primary, width: 1.4),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
