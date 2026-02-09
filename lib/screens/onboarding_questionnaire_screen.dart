import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/life_block.dart';
import '../models/onboarding_questionnaire_model.dart';
import '../services/user_service.dart';

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

    // динамические шаги: по одной карточке на выбранную сферу
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
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } else {
      final msg = m.errorText ?? 'Не удалось сохранить ответы';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      appBar: AppBar(title: const Text('Инициация героя'), centerTitle: true),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress, minHeight: 6),
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
              padding: const EdgeInsets.all(8.0),
              child: Text(
                m.errorText!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: m.currentStep == 0 ? null : () => _goPrev(m),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Назад'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: m.isLoading
                          ? null
                          : () => _goNext(m, stepsLen),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: m.currentStep == stepsLen - 1
                            ? const Text('Готово')
                            : const Text('Далее'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- общий контейнер шага ----------
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
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
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
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Имя',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => m.setName(v.trim().isEmpty ? null : v.trim()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Возраст',
              hintText: 'Например: 26',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {
              final t = v.trim();
              if (t.isEmpty) return m.setAge(null);
              final parsed = int.tryParse(t);
              if (parsed == null) return;
              m.setAge(parsed);
            },
          ),
          const SizedBox(height: 8),
          const Opacity(
            opacity: .7,
            child: Text('Имя можно менять позже в профиле.'),
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
        spacing: 8,
        runSpacing: 8,
        children: LifeBlock.values.map((b) {
          final selected = m.selectedBlocks.contains(b);
          return FilterChip(
            label: Text(getBlockLabel(b)),
            selected: selected,
            onSelected: (_) => m.toggleBlock(b),
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
        spacing: 8,
        runSpacing: 8,
        children: OnboardingQuestionnaireScreen.prioritiesOptions.map((p) {
          final selected = m.selectedPriorities.contains(p);
          return FilterChip(
            label: Text(p),
            selected: selected,
            onSelected: (_) => m.togglePriority(p, max: 3),
          );
        }).toList(),
      ),
    );
  }
}

/// ✅ Новый динамический шаг: цели по сфере (тактика / средний срок / долгий срок)
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

    // Подхвати то, что у тебя уже хранится в модели.
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
      subtitle: 'Сделаем фокус: тактика → средний срок → долгий срок',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _longCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Долгосрочная цель (6–24 месяца)',
              hintText: 'Например: выучить немецкий до уровня B2',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => m.setBlockGoalLong(widget.block, v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _midCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Среднесрочная цель (2–6 месяцев)',
              hintText: 'Например: пройти курс A2→B1 и сдать экзамен',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => m.setBlockGoalMid(widget.block, v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tacticalCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Тактическая цель (2–4 недели)',
              hintText:
                  'Например: 12 занятий по 30 минут + 2 разговорных клуба',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => m.setBlockGoalTactical(widget.block, v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _whyCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Почему это важно? (опционально)',
              hintText: 'Мотивация/смысл — поможет удерживать курс',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => m.setBlockWhy(widget.block, v),
          ),
          const SizedBox(height: 6),
          const Opacity(
            opacity: .7,
            child: Text('Можно оставить пустым и нажать «Далее».'),
          ),
        ],
      ),
    );
  }
}
