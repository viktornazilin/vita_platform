import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  static const prioritiesOptions = [
    'Здоровье',
    'Карьера',
    'Деньги',
    'Семья',
    'Развитие',
    'Любовь',
    'Творчество',
    'Баланс',
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingQuestionnaireModel(service: userService),
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

  List<Widget> _buildSteps(OnboardingQuestionnaireModel m) {
    final steps = <Widget>[
      const _StepProfileBasics(),
      const _StepLifeBlocks(),
      const _StepPriorities(),
    ];

    for (final b in m.selectedBlocks) {
      steps.add(_StepBlockGoals(block: b));
    }
    return steps;
  }

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

    if (ok) {
      if (widget.onCompleted != null) {
        widget.onCompleted!.call();
      } else {
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } else {
      final msg = m.errorText ?? 'Не удалось сохранить ответы';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<OnboardingQuestionnaireModel>();
    final steps = _buildSteps(m);
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
                        tooltip: 'Назад',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Инициация героя',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
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
                            Icon(Icons.error_outline_rounded,
                                color: Theme.of(context).colorScheme.error),
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
                              onPressed:
                                  m.currentStep == 0 ? null : () => _goPrev(m),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text('Назад'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: m.isLoading
                                  ? null
                                  : () => _goNext(m, stepsLen),
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: m.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator
                                          .adaptive(strokeWidth: 2),
                                    )
                                  : (m.currentStep == stepsLen - 1
                                      ? const Text('Готово')
                                      : const Text('Далее')),
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
    final m = context.watch<OnboardingQuestionnaireModel>();

    return _StepScaffold(
      title: 'Давай познакомимся',
      subtitle: 'Это нужно для профиля и персонализации',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NestTextField(
            controller: _nameCtrl,
            labelText: 'Имя',
            hintText: 'Например: Виктор',
            keyboardType: TextInputType.text,
            onChanged: (v) => m.setName(v.trim().isEmpty ? null : v.trim()),
          ),
          const SizedBox(height: 12),
          _NestTextField(
            controller: _ageCtrl,
            labelText: 'Возраст',
            hintText: 'Например: 26',
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
              'Имя можно менять позже в профиле.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
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
    final m = context.watch<OnboardingQuestionnaireModel>();

    return _StepScaffold(
      title: 'Какие сферы жизни ты хочешь отслеживать?',
      subtitle: 'Это станет основой твоих целей и квестов',
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

/// шаг: приоритеты
class _StepPriorities extends StatelessWidget {
  const _StepPriorities();

  @override
  Widget build(BuildContext context) {
    final m = context.watch<OnboardingQuestionnaireModel>();

    return _StepScaffold(
      title: 'Что для тебя важнее всего ближайшие 3–6 месяцев?',
      subtitle: 'Выбери до трёх — это влияет на рекомендации',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: OnboardingQuestionnaireScreen.prioritiesOptions.map((p) {
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
    final m = context.watch<OnboardingQuestionnaireModel>();
    final label = getBlockLabel(widget.block);

    return _StepScaffold(
      title: 'Цели в сфере «$label»',
      subtitle: 'Фокус: тактика → средний срок → долгий срок',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NestTextField(
            controller: _longCtrl,
            labelText: 'Долгосрочная цель (6–24 месяца)',
            hintText: 'Например: выучить немецкий до уровня B2',
            maxLines: 2,
            onChanged: (v) => m.setBlockGoalLong(widget.block, v),
          ),
          const SizedBox(height: 12),
          _NestTextField(
            controller: _midCtrl,
            labelText: 'Среднесрочная цель (2–6 месяцев)',
            hintText: 'Например: пройти курс A2→B1 и сдать экзамен',
            maxLines: 2,
            onChanged: (v) => m.setBlockGoalMid(widget.block, v),
          ),
          const SizedBox(height: 12),
          _NestTextField(
            controller: _tacticalCtrl,
            labelText: 'Тактическая цель (2–4 недели)',
            hintText: 'Например: 12 занятий по 30 минут + 2 разговорных клуба',
            maxLines: 2,
            onChanged: (v) => m.setBlockGoalTactical(widget.block, v),
          ),
          const SizedBox(height: 12),
          _NestTextField(
            controller: _whyCtrl,
            labelText: 'Почему это важно? (опционально)',
            hintText: 'Мотивация/смысл — поможет удерживать курс',
            maxLines: 2,
            onChanged: (v) => m.setBlockWhy(widget.block, v),
          ),
          const SizedBox(height: 6),
          Opacity(
            opacity: .75,
            child: Text(
              'Можно оставить пустым и нажать «Далее».',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
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
