import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/life_block.dart';
import '../models/onboarding_questionnaire_model.dart';
import '../services/user_service.dart';

class OnboardingQuestionnaireScreen extends StatelessWidget {
  /// Опциональный колбэк — если передан, он выполнится вместо дефолтной навигации.
  final VoidCallback? onCompleted;

  /// ВАЖНО: передаём сюда ТОТ ЖЕ инстанс, что создаётся в VitaApp.
  final UserService userService;

  const OnboardingQuestionnaireScreen({
    super.key,
    this.onCompleted,
    required this.userService,
  });

  static const prioritiesOptions = [
    'Здоровье', 'Карьера', 'Деньги', 'Семья',
    'Развитие', 'Любовь', 'Творчество', 'Баланс',
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
      const _StepLifeBlocks(),
      const _StepSleep(),
      const _StepActivity(),
      const _StepEnergy(),
      const _StepStress(),
      const _StepFinance(),
      const _StepPriorities(),
    ];
    // динамические шаги: по одной карточке на выбранную сферу
    for (final b in m.selectedBlocks) {
      steps.add(_StepBlockDreamsGoals(block: b));
    }
    return steps;
  }

  void _goNext(OnboardingQuestionnaireModel m, int stepsLen) {
    if (m.currentStep < stepsLen - 1) {
      // только листаем; индекс шага обновится в onPageChanged
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
      // только листаем; индекс шага обновится в onPageChanged
      _pageController.animateToPage(
        m.currentStep - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit(OnboardingQuestionnaireModel m) async {
    // На всякий случай: блокируем двойные тапы
    if (m.isLoading) return;

    final ok = await m.submit();
    if (!mounted) return;

    if (ok) {
      if (widget.onCompleted != null) {
        widget.onCompleted!.call();
      } else {
        // Дефолт: после опроса уходим на /login и чистим стек
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } else {
      // Покажем ошибку, если она есть
      final msg = m.errorText ?? 'Не удалось сохранить ответы';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<OnboardingQuestionnaireModel>();
    final steps = _buildSteps(m);
    final stepsLen = steps.length;

    // Страховка на случай, если из-за динамики шагов текущий индекс стал вне диапазона
    if (stepsLen > 0 && m.currentStep > stepsLen - 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final safe = stepsLen - 1;
        _pageController.jumpToPage(safe);
        // аккуратно синхронизируем индикатор
        m.currentStep = safe;
        m.notifyListeners();
      });
    }

    final progress = stepsLen == 0 ? 0.0 : (m.currentStep + 1) / stepsLen;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Инициация героя'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress, minHeight: 6),
          Expanded(
            child: PageView(
              controller: _pageController,
              // РАЗРЕШАЕМ свайпы по страницам
              physics: const PageScrollPhysics(), // было NeverScrollableScrollPhysics
              // СИНХРОНИЗИРУЕМ currentStep и автосейв с моделью
              onPageChanged: (i) {
                // дергаем логику модели, чтобы сохранить автосейвы/состояние
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
                      onPressed: m.isLoading ? null : () => _goNext(m, stepsLen),
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

/// ---------- общий контейнер шага (красиво и центрировано) ----------
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

// ---------- шаг 1: выбор сфер жизни ----------
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

// ---------- шаг 2: сон ----------
class _StepSleep extends StatelessWidget {
  const _StepSleep();

  @override
  Widget build(BuildContext context) {
    final m = context.watch<OnboardingQuestionnaireModel>();
    final opts = const [
      ['4-5', '4–5 часов'],
      ['6-7', '6–7 часов'],
      ['8+',  '8+ часов'],
    ];
    return _StepScaffold(
      title: 'Сколько ты обычно спишь?',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: opts.map((o) {
          final v = o[0];
          return RadioListTile<String>(
            value: v,
            groupValue: m.sleep,
            onChanged: (x) => m.setSleep(x!),
            title: Text(o[1]),
          );
        }).toList(),
      ),
    );
  }
}

// ---------- шаг 3: активность ----------
class _StepActivity extends StatelessWidget {
  const _StepActivity();

  @override
  Widget build(BuildContext context) {
    final m = context.watch<OnboardingQuestionnaireModel>();
    final opts = const [
      ['daily', 'Каждый день'],
      ['3-4w',  '3–4 раза в неделю'],
      ['rare',  'Иногда'],
      ['none',  'Почти нет'],
    ];
    return _StepScaffold(
      title: 'Как часто у тебя есть физическая активность?',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: opts.map((o) {
          final v = o[0];
          return RadioListTile<String>(
            value: v,
            groupValue: m.activity,
            onChanged: (x) => m.setActivity(x!),
            title: Text(o[1]),
          );
        }).toList(),
      ),
    );
  }
}

// ---------- шаг 4: энергия ----------
class _StepEnergy extends StatelessWidget {
  const _StepEnergy();

  @override
  Widget build(BuildContext context) {
    final m = context.watch<OnboardingQuestionnaireModel>();
    return _StepScaffold(
      title: 'Сколько у тебя энергии сегодня?',
      subtitle: 'Оцени от 0 до 10',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: m.energy.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: '${m.energy}',
            onChanged: (v) => m.setEnergy(v),
          ),
          const SizedBox(height: 8),
          Text('Энергия: ${m.energy}/10'),
        ],
      ),
    );
  }
}

// ---------- шаг 5: стресс ----------
class _StepStress extends StatelessWidget {
  const _StepStress();

  @override
  Widget build(BuildContext context) {
    final m = context.watch<OnboardingQuestionnaireModel>();
    final opts = const [
      ['daily',     'Почти каждый день'],
      ['sometimes', 'Иногда'],
      ['rare',      'Редко'],
      ['never',     'Почти никогда'],
    ];
    return _StepScaffold(
      title: 'Как часто ты испытываешь стресс?',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: opts.map((o) {
          final v = o[0];
          return RadioListTile<String>(
            value: v,
            groupValue: m.stress,
            onChanged: (x) => m.setStress(x!),
            title: Text(o[1]),
          );
        }).toList(),
      ),
    );
  }
}

// ---------- шаг 6: финансы ----------
class _StepFinance extends StatelessWidget {
  const _StepFinance();

  @override
  Widget build(BuildContext context) {
    final m = context.watch<OnboardingQuestionnaireModel>();
    return _StepScaffold(
      title: 'Насколько ты доволен своей финансовой ситуацией?',
      subtitle: 'От 1 (совсем нет) до 5 (полностью)',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: m.finance.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '${m.finance}',
            onChanged: (v) => m.setFinance(v),
          ),
          const SizedBox(height: 8),
          Text('Оценка: ${m.finance}/5'),
        ],
      ),
    );
  }
}

// ---------- шаг 7: приоритеты ----------
class _StepPriorities extends StatelessWidget {
  const _StepPriorities();

  @override
  Widget build(BuildContext context) {
    final m = context.watch<OnboardingQuestionnaireModel>();
    return _StepScaffold(
      title: 'Что для тебя важнее всего ближайшие 3–6 месяцев?',
      subtitle: 'Выбери до трёх',
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

// ---------- динамический шаг: мечты/цели по сфере ----------
class _StepBlockDreamsGoals extends StatefulWidget {
  final LifeBlock block;
  const _StepBlockDreamsGoals({required this.block});

  @override
  State<_StepBlockDreamsGoals> createState() => _StepBlockDreamsGoalsState();
}

class _StepBlockDreamsGoalsState extends State<_StepBlockDreamsGoals> {
  late final TextEditingController _dreamsCtrl;
  late final TextEditingController _goalsCtrl;

  @override
  void initState() {
    super.initState();
    final m = context.read<OnboardingQuestionnaireModel>();
    _dreamsCtrl =
        TextEditingController(text: m.dreamsByBlock[widget.block.name] ?? '');
    _goalsCtrl =
        TextEditingController(text: m.goalsByBlock[widget.block.name] ?? '');
  }

  @override
  void dispose() {
    _dreamsCtrl.dispose();
    _goalsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<OnboardingQuestionnaireModel>();
    final label = getBlockLabel(widget.block);

    return _StepScaffold(
      title: 'Мечты и цели в сфере «$label»',
      subtitle: 'Необязательные вопросы — можно пропустить',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _dreamsCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Мечты в этой сфере (опционально)',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => m.setBlockDream(widget.block, v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _goalsCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Цели на 3–6 месяцев (опционально)',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => m.setBlockGoal(widget.block, v),
          ),
          const SizedBox(height: 4),
          const Opacity(
            opacity: .7,
            child: Text('Оставь пустым и нажми «Далее», если пока не готов отвечать.'),
          ),
        ],
      ),
    );
  }
}
