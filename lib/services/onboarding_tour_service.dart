import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

enum NestFullOnboardingStep { home, goals, userGoals, profile, reports, expenses, finished }

/// Central service for interactive Nest onboarding / How-To tours.
/// Put this file into: lib/services/onboarding_tour_service.dart
class OnboardingTourService {
  OnboardingTourService._();

  static const String _mainTourKey = 'nest_onboarding_main_tour_seen_v1';
  static const String _goalsTourKey = 'nest_onboarding_goals_tour_seen_v1';
  static const String _reportsTourKey = 'nest_onboarding_reports_tour_seen_v1';
  static const String _userGoalsTourKey = 'nest_onboarding_user_goals_tour_seen_v1';
  static const String _profileTourKey = 'nest_onboarding_profile_tour_seen_v1';
  static const String _budgetTourKey = 'nest_onboarding_budget_tour_seen_v1';
  static const String _dayGoalsTourKey = 'nest_onboarding_day_goals_tour_seen_v1';
  static const String _questionnaireTourKey = 'nest_onboarding_questionnaire_tour_seen_v1';
  static const String _expensesTourKey = 'nest_onboarding_expenses_tour_seen_v1';
  static const String _fullAppTourKey = 'nest_onboarding_full_app_seen_v1';
  static const String _fullAppStepKey = 'nest_onboarding_full_app_step_v1';

  /// Tracks the currently selected tab in HomeScreen.
  /// 0 = Home, 1 = Goals, 4 = Reports in the current app navigation.
  static final ValueNotifier<int> activeHomeTab = ValueNotifier<int>(0);

  /// Prevents several tours from being shown on top of each other.
  static bool _isTourVisible = false;
  static bool _isFullFlowActive = false;
  static ValueChanged<int>? _fullFlowTabSelector;

  static final ValueNotifier<NestFullOnboardingStep?> fullFlowStep =
      ValueNotifier<NestFullOnboardingStep?>(null);

  static bool get isFullFlowActive => _isFullFlowActive;

  static bool shouldRunFullStep(NestFullOnboardingStep step) {
    return _isFullFlowActive && fullFlowStep.value == step;
  }

  static void setActiveHomeTab(int index) {
    if (activeHomeTab.value != index) {
      activeHomeTab.value = index;
    }
  }


  static Future<void> startFullAppOnboardingIfNeeded({
    required BuildContext context,
    required ValueChanged<int> onSelectTab,
    required GlobalKey launcherKey,
    required GlobalKey helpKey,
    required GlobalKey? navigationKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_fullAppTourKey) ?? false) return;

    await startFullAppOnboarding(
      context: context,
      onSelectTab: onSelectTab,
      launcherKey: launcherKey,
      helpKey: helpKey,
      navigationKey: navigationKey,
      forceRestart: false,
    );
  }

  static Future<void> startFullAppOnboarding({
    required BuildContext context,
    required ValueChanged<int> onSelectTab,
    required GlobalKey launcherKey,
    required GlobalKey helpKey,
    required GlobalKey? navigationKey,
    bool forceRestart = true,
  }) async {
    if (_isTourVisible || !context.mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (!forceRestart && (prefs.getBool(_fullAppTourKey) ?? false)) return;

    _isFullFlowActive = true;
    _fullFlowTabSelector = onSelectTab;

    await prefs.setString(_fullAppStepKey, NestFullOnboardingStep.home.name);
    _setFullFlowStep(NestFullOnboardingStep.home);

    onSelectTab(0);
    setActiveHomeTab(0);

    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!context.mounted) return;

    await _showWelcomeDialog(context);
    if (!context.mounted || !_isFullFlowActive) return;

    await showMainTour(
      context: context,
      launcherKey: launcherKey,
      helpKey: helpKey,
      navigationKey: navigationKey,
      markAsSeen: false,
    );

    await completeFullFlowStep(NestFullOnboardingStep.home, context: context);
  }

  static Future<void> runFullFlowScreenStep({
    required BuildContext context,
    required NestFullOnboardingStep step,
    required Future<void> Function() showTour,
  }) async {
    if (!context.mounted || !shouldRunFullStep(step)) return;
    if (_isTourVisible) return;

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!context.mounted || !shouldRunFullStep(step)) return;

    await showTour();
    if (!context.mounted || !shouldRunFullStep(step)) return;

    await completeFullFlowStep(step, context: context);
  }

  static Future<void> completeFullFlowStep(
    NestFullOnboardingStep step, {
    BuildContext? context,
  }) async {
    if (!_isFullFlowActive || fullFlowStep.value != step) return;

    switch (step) {
      case NestFullOnboardingStep.home:
        await _moveFullFlowTo(NestFullOnboardingStep.goals, 1);
        break;
      case NestFullOnboardingStep.goals:
        await _moveFullFlowTo(NestFullOnboardingStep.userGoals, 2);
        break;
      case NestFullOnboardingStep.userGoals:
        await _moveFullFlowTo(NestFullOnboardingStep.profile, 3);
        break;
      case NestFullOnboardingStep.profile:
        await _moveFullFlowTo(NestFullOnboardingStep.reports, 4);
        break;
      case NestFullOnboardingStep.reports:
        await _moveFullFlowTo(NestFullOnboardingStep.expenses, 5);
        break;
      case NestFullOnboardingStep.expenses:
        await _finishFullFlow(context);
        break;
      case NestFullOnboardingStep.finished:
        break;
    }
  }

  static Future<void> _moveFullFlowTo(
    NestFullOnboardingStep step,
    int tabIndex,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullAppStepKey, step.name);

    _setFullFlowStep(step);
    _fullFlowTabSelector?.call(tabIndex);
    setActiveHomeTab(tabIndex);
  }

  static void _setFullFlowStep(NestFullOnboardingStep step) {
    if (fullFlowStep.value != step) {
      fullFlowStep.value = step;
    }
  }

  static Future<void> _finishFullFlow(BuildContext? context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fullAppTourKey, true);
    await prefs.remove(_fullAppStepKey);

    _isFullFlowActive = false;
    _setFullFlowStep(NestFullOnboardingStep.finished);

    if (context != null && context.mounted) {
      await _showFinishDialog(context);
    }
  }

  static Future<void> _showWelcomeDialog(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.auto_awesome_rounded, color: cs.primary),
        title: const Text('Добро пожаловать в Nest'),
        content: const Text(
          'Сейчас я быстро покажу главные функции: быстрые действия, задачи, большие цели, профиль, отчёты и финансы.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              _isFullFlowActive = false;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(_fullAppTourKey, true);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Пропустить'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Начать'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showFinishDialog(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.check_circle_rounded, color: cs.primary),
        title: const Text('Готово'),
        content: const Text(
          'Теперь ты знаешь, где находятся основные функции Nest. Обучение можно запустить снова через значок помощи на главном экране.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  static Future<void> showMainTourIfNeeded({
    required BuildContext context,
    required GlobalKey launcherKey,
    required GlobalKey helpKey,
    required GlobalKey? navigationKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_mainTourKey) ?? false) return;

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!context.mounted || activeHomeTab.value != 0) return;

    await showMainTour(
      context: context,
      launcherKey: launcherKey,
      helpKey: helpKey,
      navigationKey: navigationKey,
      markAsSeen: true,
    );
  }

  static Future<void> showMainTour({
    required BuildContext context,
    required GlobalKey launcherKey,
    required GlobalKey helpKey,
    required GlobalKey? navigationKey,
    bool markAsSeen = false,
  }) async {
    final targets = <TargetFocus>[
      _target(
        id: 'launcher',
        key: launcherKey,
        title: 'Быстрые действия',
        text: 'Через эту кнопку ты быстро добавляешь задачи, настроение, расходы, привычки и запускаешь AI-план.',
        align: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
      if (navigationKey != null)
        _target(
          id: 'navigation',
          key: navigationKey,
          title: 'Навигация по Nest',
          text: 'Здесь находятся основные разделы: главная, задачи, большие цели, профиль, отчёты и финансы.',
          align: ContentAlign.right,
          shape: ShapeLightFocus.RRect,
        ),
      _target(
        id: 'help',
        key: helpKey,
        title: 'Инструкцию можно открыть снова',
        text: 'Нажми на этот значок, если захочешь повторить интерактивный How-To позже.',
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.Circle,
      ),
    ];

    await _show(context: context, targets: targets);

    if (markAsSeen) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_mainTourKey, true);
    }
  }

  static Future<void> showGoalsTourIfNeeded({
    required BuildContext context,
    required GlobalKey addKey,
    required GlobalKey modeKey,
    required GlobalKey filterKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_goalsTourKey) ?? false) return;

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!context.mounted || activeHomeTab.value != 1) return;

    await showGoalsTour(
      context: context,
      addKey: addKey,
      modeKey: modeKey,
      filterKey: filterKey,
      markAsSeen: true,
    );
  }

  static Future<void> showGoalsTour({
    required BuildContext context,
    required GlobalKey addKey,
    required GlobalKey modeKey,
    required GlobalKey filterKey,
    bool markAsSeen = false,
  }) async {
    final targets = <TargetFocus>[
      _target(
        id: 'goals_filter',
        key: filterKey,
        title: 'Фильтр по сфере жизни',
        text: 'Выбирай карьеру, здоровье, финансы и другие сферы, чтобы смотреть задачи именно в нужном контексте.',
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      _target(
        id: 'goals_mode',
        key: modeKey,
        title: 'Дашборд или календарь',
        text: 'Дашборд показывает общую картину, а календарь помогает планировать задачи по дням и неделям.',
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      _target(
        id: 'goals_add',
        key: addKey,
        title: 'Добавление действий',
        text: 'Здесь можно быстро добавить задачу, серию задач или заполнить день сразу несколькими записями.',
        align: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
    ];

    await _show(context: context, targets: targets);

    if (markAsSeen) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_goalsTourKey, true);
    }
  }

  static Future<void> showReportsTourIfNeeded({
    required BuildContext context,
    required GlobalKey periodKey,
    required GlobalKey chartKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_reportsTourKey) ?? false) return;

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!context.mounted || activeHomeTab.value != 4) return;

    await showReportsTour(
      context: context,
      periodKey: periodKey,
      chartKey: chartKey,
      markAsSeen: true,
    );
  }

  static Future<void> showReportsTour({
    required BuildContext context,
    required GlobalKey periodKey,
    required GlobalKey chartKey,
    bool markAsSeen = false,
  }) async {
    final targets = <TargetFocus>[
      _target(
        id: 'reports_period',
        key: periodKey,
        title: 'Период анализа',
        text: 'Переключай день, неделю и месяц, чтобы сравнивать динамику целей, настроения, привычек и финансов.',
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      _target(
        id: 'reports_chart',
        key: chartKey,
        title: 'Интерактивные графики',
        text: 'Нажимай на сектора и точки графиков — приложение покажет подробности только по выбранному элементу.',
        align: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
    ];

    await _show(context: context, targets: targets);

    if (markAsSeen) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reportsTourKey, true);
    }
  }


  static Future<void> showUserGoalsTourIfNeeded({required BuildContext context, required GlobalKey headerKey, required GlobalKey filtersKey, required GlobalKey addKey}) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_userGoalsTourKey) ?? false) return;
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!context.mounted || activeHomeTab.value != 2) return;
    await showUserGoalsTour(context: context, headerKey: headerKey, filtersKey: filtersKey, addKey: addKey, markAsSeen: true);
  }

  static Future<void> showUserGoalsTour({required BuildContext context, required GlobalKey headerKey, required GlobalKey filtersKey, required GlobalKey addKey, bool markAsSeen = false}) async {
    final targets = <TargetFocus>[
      _target(id: 'user_goals_header', key: headerKey, title: 'Большие цели', text: 'Здесь хранятся стратегические цели: краткосрочные, среднесрочные и долгосрочные. Потом к ним можно привязывать ежедневные задачи.', align: ContentAlign.bottom, shape: ShapeLightFocus.RRect),
      _target(id: 'user_goals_filters', key: filtersKey, title: 'Фильтры целей', text: 'Фильтруй цели по сфере жизни и горизонту, чтобы быстро сфокусироваться на нужном направлении.', align: ContentAlign.bottom, shape: ShapeLightFocus.RRect),
      _target(id: 'user_goals_add', key: addKey, title: 'Создать большую цель', text: 'Нажми сюда, чтобы добавить цель, выбрать сферу жизни, горизонт и дедлайн.', align: ContentAlign.top, shape: ShapeLightFocus.RRect),
    ];
    await _show(context: context, targets: targets);
    if (markAsSeen) { final prefs = await SharedPreferences.getInstance(); await prefs.setBool(_userGoalsTourKey, true); }
  }

  static Future<void> showProfileTourIfNeeded({
    required BuildContext context,
    required GlobalKey headerKey,
    required GlobalKey profileCardKey,
    required GlobalKey focusKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_profileTourKey) ?? false) return;
    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (!context.mounted || activeHomeTab.value != 3) return;
    await showProfileTour(
      context: context,
      headerKey: headerKey,
      profileCardKey: profileCardKey,
      focusKey: focusKey,
      markAsSeen: true,
    );
  }

  static Future<void> showProfileTour({
    required BuildContext context,
    required GlobalKey headerKey,
    required GlobalKey profileCardKey,
    required GlobalKey focusKey,
    bool markAsSeen = false,
  }) async {
    await _show(context: context, targets: [
      _target(
        id: 'profile_header',
        key: headerKey,
        title: 'Профиль',
        text: 'Это центр персональных настроек Nest: здесь пользователь управляет аккаунтом, фокусом, привычками и параметрами приложения.',
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      _target(
        id: 'profile_card',
        key: profileCardKey,
        title: 'Личные данные',
        text: 'Имя, возраст и базовые параметры используются для персонализации интерфейса и будущих AI-рекомендаций.',
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      _target(
        id: 'profile_focus',
        key: focusKey,
        title: 'Фокус и настройки',
        text: 'Здесь задаются параметры, которые влияют на планирование дня, аналитику и рекомендации в приложении.',
        align: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
    ]);
    if (markAsSeen) { final prefs = await SharedPreferences.getInstance(); await prefs.setBool(_profileTourKey, true); }
  }

  static Future<void> showBudgetTourIfNeeded({required BuildContext context, required GlobalKey incomeKey, required GlobalKey expenseKey, required GlobalKey jarsKey, required GlobalKey saveKey}) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_budgetTourKey) ?? false) return;
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!context.mounted) return;
    await showBudgetTour(context: context, incomeKey: incomeKey, expenseKey: expenseKey, jarsKey: jarsKey, saveKey: saveKey, markAsSeen: true);
  }

  static Future<void> showBudgetTour({required BuildContext context, required GlobalKey incomeKey, required GlobalKey expenseKey, required GlobalKey jarsKey, required GlobalKey saveKey, bool markAsSeen = false}) async {
    final targets = <TargetFocus>[
      _target(id: 'budget_income', key: incomeKey, title: 'Категории доходов', text: 'Добавляй источники дохода, чтобы финансовая аналитика понимала структуру поступлений.', align: ContentAlign.bottom, shape: ShapeLightFocus.RRect),
      _target(id: 'budget_expense', key: expenseKey, title: 'Категории расходов', text: 'Здесь настраиваются категории расходов и лимиты. Это помогает видеть, где бюджет уходит быстрее всего.', align: ContentAlign.bottom, shape: ShapeLightFocus.RRect),
      _target(id: 'budget_jars', key: jarsKey, title: 'Копилки и распределение', text: 'Используй копилки для целей накопления: путешествия, подушка безопасности, инвестиции или крупные покупки.', align: ContentAlign.top, shape: ShapeLightFocus.RRect),
      _target(id: 'budget_save', key: saveKey, title: 'Сохранить настройки', text: 'После изменений не забудь сохранить бюджет — тогда категории и лимиты попадут в базу.', align: ContentAlign.top, shape: ShapeLightFocus.RRect),
    ];
    await _show(context: context, targets: targets);
    if (markAsSeen) { final prefs = await SharedPreferences.getInstance(); await prefs.setBool(_budgetTourKey, true); }
  }

  static Future<void> showDayGoalsTourIfNeeded({required BuildContext context, required GlobalKey summaryKey, required GlobalKey filterKey, required GlobalKey fabKey}) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_dayGoalsTourKey) ?? false) return;
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!context.mounted) return;
    await showDayGoalsTour(context: context, summaryKey: summaryKey, filterKey: filterKey, fabKey: fabKey, markAsSeen: true);
  }

  static Future<void> showDayGoalsTour({required BuildContext context, required GlobalKey summaryKey, required GlobalKey filterKey, required GlobalKey fabKey, bool markAsSeen = false}) async {
    final targets = <TargetFocus>[
      _target(id: 'day_goals_summary', key: summaryKey, title: 'Итог дня', text: 'В этой карточке видно прогресс дня: сколько задач выполнено, сколько осталось и сколько времени ещё запланировано.', align: ContentAlign.bottom, shape: ShapeLightFocus.RRect),
      _target(id: 'day_goals_filter', key: filterKey, title: 'Скрыть выполненные', text: 'Включи фильтр, чтобы оставить на экране только актуальные задачи.', align: ContentAlign.bottom, shape: ShapeLightFocus.RRect),
      _target(id: 'day_goals_fab', key: fabKey, title: 'Добавить активность', text: 'Через эту кнопку можно добавить задачу, распознать запись из ежедневника или синхронизировать Google Calendar.', align: ContentAlign.top, shape: ShapeLightFocus.Circle),
    ];
    await _show(context: context, targets: targets);
    if (markAsSeen) { final prefs = await SharedPreferences.getInstance(); await prefs.setBool(_dayGoalsTourKey, true); }
  }

  static Future<void> showQuestionnaireTourIfNeeded({required BuildContext context, required GlobalKey progressKey, required GlobalKey stepKey, required GlobalKey nextKey}) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_questionnaireTourKey) ?? false) return;
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!context.mounted) return;
    await showQuestionnaireTour(context: context, progressKey: progressKey, stepKey: stepKey, nextKey: nextKey, markAsSeen: true);
  }

  static Future<void> showQuestionnaireTour({required BuildContext context, required GlobalKey progressKey, required GlobalKey stepKey, required GlobalKey nextKey, bool markAsSeen = false}) async {
    // Не подсвечиваем весь PageView/step container: на маленьких экранах такой target
    // выглядит как затемнение всего экрана и уводит карточку вниз. Поэтому оставляем
    // только реальные компактные элементы: прогресс и кнопку перехода дальше.
    final targets = <TargetFocus>[
      _target(
        id: 'questionnaire_progress',
        key: progressKey,
        title: 'Прогресс настройки',
        text: 'Здесь видно, на каком шаге первичной настройки ты сейчас находишься.',
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      _target(
        id: 'questionnaire_next',
        key: nextKey,
        title: 'Переход дальше',
        text: 'После заполнения текущего шага нажми сюда. В конце Nest сохранит профиль, сферы жизни и цели.',
        align: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
    ];
    await _show(context: context, targets: targets);
    if (markAsSeen) { final prefs = await SharedPreferences.getInstance(); await prefs.setBool(_questionnaireTourKey, true); }
  }

  static Future<void> showExpensesTourIfNeeded({
    required BuildContext context,
    required GlobalKey controlsKey,
    required GlobalKey summaryKey,
    required GlobalKey transactionsKey,
    required GlobalKey fabKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_expensesTourKey) ?? false) return;

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!context.mounted || activeHomeTab.value != 5) return;

    await showExpensesTour(
      context: context,
      controlsKey: controlsKey,
      summaryKey: summaryKey,
      transactionsKey: transactionsKey,
      fabKey: fabKey,
      markAsSeen: true,
    );
  }

  static Future<void> showExpensesTour({
    required BuildContext context,
    required GlobalKey controlsKey,
    required GlobalKey summaryKey,
    required GlobalKey transactionsKey,
    required GlobalKey fabKey,
    bool markAsSeen = false,
  }) async {
    final targets = <TargetFocus>[
      _target(
        id: 'expenses_controls',
        key: controlsKey,
        title: 'День и настройки бюджета',
        text: 'Здесь выбирается дата для операций, а также открываются настройки категорий, лимитов и копилок.',
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      _target(
        id: 'expenses_summary',
        key: summaryKey,
        title: 'Финансовая сводка месяца',
        text: 'Карточка показывает доходы, расходы и свободный остаток за месяц — это база для анализа бюджета.',
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      _target(
        id: 'expenses_transactions',
        key: transactionsKey,
        title: 'Операции за выбранный день',
        text: 'Здесь видны доходы и расходы за день. Нажми на операцию, чтобы изменить её, или свайпни влево для удаления.',
        align: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
      _target(
        id: 'expenses_fab',
        key: fabKey,
        title: 'Добавить доход или расход',
        text: 'Нажми на плюс, чтобы открыть меню и быстро добавить новую финансовую операцию.',
        align: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
      ),
    ];

    await _show(context: context, targets: targets);

    if (markAsSeen) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_expensesTourKey, true);
    }
  }

  static Future<void> resetAllTours() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mainTourKey);
    await prefs.remove(_goalsTourKey);
    await prefs.remove(_reportsTourKey);
    await prefs.remove(_userGoalsTourKey);
    await prefs.remove(_profileTourKey);
    await prefs.remove(_budgetTourKey);
    await prefs.remove(_dayGoalsTourKey);
    await prefs.remove(_questionnaireTourKey);
    await prefs.remove(_expensesTourKey);
    await prefs.remove(_fullAppTourKey);
    await prefs.remove(_fullAppStepKey);
    _isFullFlowActive = false;
    _setFullFlowStep(NestFullOnboardingStep.finished);
  }

  static Future<void> _show({
    required BuildContext context,
    required List<TargetFocus> targets,
  }) async {
    if (_isTourVisible || !context.mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!context.mounted) return;

    final visibleTargets = targets.where(_isUsableTarget).toList();
    if (visibleTargets.isEmpty) return;

    _isTourVisible = true;

    final completer = Completer<void>();

    final tutorial = TutorialCoachMark(
      targets: visibleTargets,
      colorShadow: Colors.black,
      opacityShadow: 0.78,
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 350),
      unFocusAnimationDuration: const Duration(milliseconds: 250),
      pulseEnable: true,
      textSkip: 'Пропустить',
      onClickTarget: (_) {},
      onClickOverlay: (_) {},
      onFinish: () {
        _isTourVisible = false;
        if (!completer.isCompleted) completer.complete();
      },
      onSkip: () {
        _isTourVisible = false;
        if (!completer.isCompleted) completer.complete();
        return true;
      },
    );

    tutorial.show(context: context);
    return completer.future;
  }


  static bool _isUsableTarget(TargetFocus target) {
    final context = target.keyTarget?.currentContext;
    if (context == null) return false;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return false;

    final size = renderObject.size;
    if (size.width <= 4 || size.height <= 4) return false;

    final screenSize = MediaQuery.maybeOf(context)?.size;
    if (screenSize == null) return true;

    // Защита от бага: если key случайно стоит на всём экране/большом контейнере,
    // coach mark выглядит как затемнение всего экрана. Такой target пропускаем.
    final coversAlmostWholeWidth = size.width >= screenSize.width * 0.94;
    final coversLargeHeight = size.height >= screenSize.height * 0.50;
    return !(coversAlmostWholeWidth && coversLargeHeight);
  }

  static TargetFocus _target({

    required String id,
    required GlobalKey key,
    required String title,
    required String text,
    required ContentAlign align,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
  }) {
    return TargetFocus(
      identify: id,
      keyTarget: key,
      shape: shape,
      radius: 18,
      contents: [
        TargetContent(
          align: align,
          child: _CoachCard(title: title, text: text),
        ),
      ],
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 330),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.primary.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: cs.primary, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: tt.bodyMedium?.copyWith(
              height: 1.35,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Нажми на экран, чтобы перейти дальше',
            style: tt.labelMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
