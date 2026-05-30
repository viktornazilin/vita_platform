import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

enum NestFullOnboardingStep {
  home,
  goals,
  userGoals,
  profile,
  reports,
  expenses,
  finished,
}

/// Drop-in onboarding / coach-mark service for Ladna/Nest.
///
/// Put this file into:
/// lib/services/onboarding_tour_service.dart
///
/// The public method names are kept compatible with the old service, so existing
/// screen calls should continue to compile. Texts are localized inside this file
/// for RU / EN / DE / FR / ES / TR and do not require adding new ARB keys.
class OnboardingTourService {
  OnboardingTourService._();

  static const String _mainTourKey = 'ladna_tour_main_seen_v2';
  static const String _goalsTourKey = 'ladna_tour_goals_seen_v2';
  static const String _reportsTourKey = 'ladna_tour_reports_seen_v2';
  static const String _userGoalsTourKey = 'ladna_tour_user_goals_seen_v2';
  static const String _profileTourKey = 'ladna_tour_profile_seen_v2';
  static const String _budgetTourKey = 'ladna_tour_budget_seen_v2';
  static const String _dayGoalsTourKey = 'ladna_tour_day_goals_seen_v2';
  static const String _questionnaireTourKey = 'ladna_tour_questionnaire_seen_v2';
  static const String _expensesTourKey = 'ladna_tour_expenses_seen_v2';
  static const String _fullAppTourKey = 'ladna_tour_full_app_seen_v2';
  static const String _fullAppStepKey = 'ladna_tour_full_app_step_v2';

  /// Current tab index inside the main shell.
  /// Keep indexes synchronized with your bottom navigation.
  static final ValueNotifier<int> activeHomeTab = ValueNotifier<int>(0);

  static final ValueNotifier<NestFullOnboardingStep?> fullFlowStep =
      ValueNotifier<NestFullOnboardingStep?>(null);

  static bool _isTourVisible = false;
  static bool _isFullFlowActive = false;
  static ValueChanged<int>? _fullFlowTabSelector;

  static bool get isFullFlowActive => _isFullFlowActive;

  static void setActiveHomeTab(int index) {
    if (activeHomeTab.value != index) activeHomeTab.value = index;
  }

  static bool shouldRunFullStep(NestFullOnboardingStep step) {
    return _isFullFlowActive && fullFlowStep.value == step;
  }

  // ---------------------------------------------------------------------------
  // Full app flow
  // ---------------------------------------------------------------------------

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
    if (!context.mounted || !_isFullFlowActive) return;

    final copy = _TourCopy.of(context);
    final start = await _showIntroDialog(context, copy);
    if (!start || !context.mounted || !_isFullFlowActive) return;

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
    if (!context.mounted || !shouldRunFullStep(step) || _isTourVisible) return;

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!context.mounted || !shouldRunFullStep(step) || _isTourVisible) return;

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
    if (fullFlowStep.value != step) fullFlowStep.value = step;
  }

  static Future<void> _finishFullFlow(BuildContext? context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fullAppTourKey, true);
    await prefs.remove(_fullAppStepKey);

    _isFullFlowActive = false;
    _setFullFlowStep(NestFullOnboardingStep.finished);

    if (context != null && context.mounted) {
      await _showFinishDialog(context, _TourCopy.of(context));
    }
  }

  // ---------------------------------------------------------------------------
  // Main screen
  // ---------------------------------------------------------------------------

  static Future<void> showMainTourIfNeeded({
    required BuildContext context,
    required GlobalKey launcherKey,
    required GlobalKey helpKey,
    required GlobalKey? navigationKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _mainTourKey,
      requiredTab: 0,
      delay: const Duration(milliseconds: 450),
      show: () => showMainTour(
        context: context,
        launcherKey: launcherKey,
        helpKey: helpKey,
        navigationKey: navigationKey,
      ),
    );
  }

  static Future<void> showMainTour({
    required BuildContext context,
    required GlobalKey launcherKey,
    required GlobalKey helpKey,
    required GlobalKey? navigationKey,
    bool markAsSeen = false,
  }) async {
    final c = _TourCopy.of(context);
    final targets = <TargetFocus>[
      _target(
        id: 'main_launcher',
        key: launcherKey,
        title: c.mainMenuTitle,
        text: c.mainMenuText,
        align: ContentAlign.bottom,
        icon: Icons.auto_awesome_rounded,
      ),
      if (navigationKey != null)
        _target(
          id: 'main_navigation',
          key: navigationKey,
          title: c.mainNavigationTitle,
          text: c.mainNavigationText,
          align: ContentAlign.top,
          icon: Icons.swipe_rounded,
        ),
      _target(
        id: 'main_help',
        key: helpKey,
        title: c.mainHelpTitle,
        text: c.mainHelpText,
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.Circle,
        icon: Icons.help_outline_rounded,
      ),
    ];

    await _show(context: context, targets: targets);
    if (markAsSeen) await _markSeen(_mainTourKey);
  }

  // ---------------------------------------------------------------------------
  // Goals
  // ---------------------------------------------------------------------------

  static Future<void> showGoalsTourIfNeeded({
    required BuildContext context,
    required GlobalKey addKey,
    required GlobalKey modeKey,
    required GlobalKey filterKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _goalsTourKey,
      requiredTab: 1,
      delay: const Duration(milliseconds: 650),
      show: () => showGoalsTour(
        context: context,
        addKey: addKey,
        modeKey: modeKey,
        filterKey: filterKey,
      ),
    );
  }

  static Future<void> showGoalsTour({
    required BuildContext context,
    required GlobalKey addKey,
    required GlobalKey modeKey,
    required GlobalKey filterKey,
    bool markAsSeen = false,
  }) async {
    final c = _TourCopy.of(context);
    await _show(context: context, targets: [
      _target(
        id: 'goals_mode',
        key: modeKey,
        title: c.goalsModeTitle,
        text: c.goalsModeText,
        align: ContentAlign.bottom,
        icon: Icons.view_week_rounded,
      ),
      _target(
        id: 'goals_filter',
        key: filterKey,
        title: c.goalsFilterTitle,
        text: c.goalsFilterText,
        align: ContentAlign.bottom,
        icon: Icons.tune_rounded,
      ),
      _target(
        id: 'goals_add',
        key: addKey,
        title: c.goalsAddTitle,
        text: c.goalsAddText,
        align: ContentAlign.top,
        icon: Icons.add_rounded,
      ),
    ]);
    if (markAsSeen) await _markSeen(_goalsTourKey);
  }

  // ---------------------------------------------------------------------------
  // User goals
  // ---------------------------------------------------------------------------

  static Future<void> showUserGoalsTourIfNeeded({
    required BuildContext context,
    required GlobalKey headerKey,
    required GlobalKey filtersKey,
    required GlobalKey addKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _userGoalsTourKey,
      requiredTab: 2,
      delay: const Duration(milliseconds: 650),
      show: () => showUserGoalsTour(
        context: context,
        headerKey: headerKey,
        filtersKey: filtersKey,
        addKey: addKey,
      ),
    );
  }

  static Future<void> showUserGoalsTour({
    required BuildContext context,
    required GlobalKey headerKey,
    required GlobalKey filtersKey,
    required GlobalKey addKey,
    bool markAsSeen = false,
  }) async {
    final c = _TourCopy.of(context);
    await _show(context: context, targets: [
      _target(
        id: 'user_goals_header',
        key: headerKey,
        title: c.userGoalsHeaderTitle,
        text: c.userGoalsHeaderText,
        align: ContentAlign.bottom,
        icon: Icons.flag_rounded,
      ),
      _target(
        id: 'user_goals_filters',
        key: filtersKey,
        title: c.userGoalsFiltersTitle,
        text: c.userGoalsFiltersText,
        align: ContentAlign.bottom,
        icon: Icons.filter_alt_rounded,
      ),
      _target(
        id: 'user_goals_add',
        key: addKey,
        title: c.userGoalsAddTitle,
        text: c.userGoalsAddText,
        align: ContentAlign.top,
        icon: Icons.add_rounded,
      ),
    ]);
    if (markAsSeen) await _markSeen(_userGoalsTourKey);
  }

  // ---------------------------------------------------------------------------
  // Profile / personal
  // ---------------------------------------------------------------------------

  static Future<void> showProfileTourIfNeeded({
    required BuildContext context,
    required GlobalKey headerKey,
    required GlobalKey profileCardKey,
    required GlobalKey focusKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _profileTourKey,
      requiredTab: 3,
      delay: const Duration(milliseconds: 750),
      show: () => showProfileTour(
        context: context,
        headerKey: headerKey,
        profileCardKey: profileCardKey,
        focusKey: focusKey,
      ),
    );
  }

  static Future<void> showProfileTour({
    required BuildContext context,
    required GlobalKey headerKey,
    required GlobalKey profileCardKey,
    required GlobalKey focusKey,
    bool markAsSeen = false,
  }) async {
    final c = _TourCopy.of(context);
    await _show(context: context, targets: [
      _target(
        id: 'profile_header',
        key: headerKey,
        title: c.profileHeaderTitle,
        text: c.profileHeaderText,
        align: ContentAlign.bottom,
        icon: Icons.favorite_rounded,
      ),
      _target(
        id: 'profile_card',
        key: profileCardKey,
        title: c.profileCardTitle,
        text: c.profileCardText,
        align: ContentAlign.bottom,
        icon: Icons.person_rounded,
      ),
      _target(
        id: 'profile_focus',
        key: focusKey,
        title: c.profileFocusTitle,
        text: c.profileFocusText,
        align: ContentAlign.top,
        icon: Icons.checklist_rounded,
      ),
    ]);
    if (markAsSeen) await _markSeen(_profileTourKey);
  }

  // ---------------------------------------------------------------------------
  // Reports
  // ---------------------------------------------------------------------------

  static Future<void> showReportsTourIfNeeded({
    required BuildContext context,
    required GlobalKey periodKey,
    required GlobalKey chartKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _reportsTourKey,
      requiredTab: 4,
      delay: const Duration(milliseconds: 650),
      show: () => showReportsTour(
        context: context,
        periodKey: periodKey,
        chartKey: chartKey,
      ),
    );
  }

  static Future<void> showReportsTour({
    required BuildContext context,
    required GlobalKey periodKey,
    required GlobalKey chartKey,
    bool markAsSeen = false,
  }) async {
    final c = _TourCopy.of(context);
    await _show(context: context, targets: [
      _target(
        id: 'reports_period',
        key: periodKey,
        title: c.reportsPeriodTitle,
        text: c.reportsPeriodText,
        align: ContentAlign.bottom,
        icon: Icons.date_range_rounded,
      ),
      _target(
        id: 'reports_chart',
        key: chartKey,
        title: c.reportsChartTitle,
        text: c.reportsChartText,
        align: ContentAlign.top,
        icon: Icons.insights_rounded,
      ),
    ]);
    if (markAsSeen) await _markSeen(_reportsTourKey);
  }

  // ---------------------------------------------------------------------------
  // Budget setup
  // ---------------------------------------------------------------------------

  static Future<void> showBudgetTourIfNeeded({
    required BuildContext context,
    required GlobalKey incomeKey,
    required GlobalKey expenseKey,
    required GlobalKey jarsKey,
    required GlobalKey saveKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _budgetTourKey,
      delay: const Duration(milliseconds: 650),
      show: () => showBudgetTour(
        context: context,
        incomeKey: incomeKey,
        expenseKey: expenseKey,
        jarsKey: jarsKey,
        saveKey: saveKey,
      ),
    );
  }

  static Future<void> showBudgetTour({
    required BuildContext context,
    required GlobalKey incomeKey,
    required GlobalKey expenseKey,
    required GlobalKey jarsKey,
    required GlobalKey saveKey,
    bool markAsSeen = false,
  }) async {
    final c = _TourCopy.of(context);
    await _show(context: context, targets: [
      _target(
        id: 'budget_income',
        key: incomeKey,
        title: c.budgetIncomeTitle,
        text: c.budgetIncomeText,
        align: ContentAlign.bottom,
        icon: Icons.trending_up_rounded,
      ),
      _target(
        id: 'budget_expense',
        key: expenseKey,
        title: c.budgetExpenseTitle,
        text: c.budgetExpenseText,
        align: ContentAlign.bottom,
        icon: Icons.trending_down_rounded,
      ),
      _target(
        id: 'budget_jars',
        key: jarsKey,
        title: c.budgetJarsTitle,
        text: c.budgetJarsText,
        align: ContentAlign.top,
        icon: Icons.savings_rounded,
      ),
      _target(
        id: 'budget_save',
        key: saveKey,
        title: c.budgetSaveTitle,
        text: c.budgetSaveText,
        align: ContentAlign.top,
        icon: Icons.save_rounded,
      ),
    ]);
    if (markAsSeen) await _markSeen(_budgetTourKey);
  }

  // ---------------------------------------------------------------------------
  // Day goals
  // ---------------------------------------------------------------------------

  static Future<void> showDayGoalsTourIfNeeded({
    required BuildContext context,
    required GlobalKey summaryKey,
    required GlobalKey filterKey,
    required GlobalKey fabKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _dayGoalsTourKey,
      delay: const Duration(milliseconds: 650),
      show: () => showDayGoalsTour(
        context: context,
        summaryKey: summaryKey,
        filterKey: filterKey,
        fabKey: fabKey,
      ),
    );
  }

  static Future<void> showDayGoalsTour({
    required BuildContext context,
    required GlobalKey summaryKey,
    required GlobalKey filterKey,
    required GlobalKey fabKey,
    bool markAsSeen = false,
  }) async {
    final c = _TourCopy.of(context);
    await _show(context: context, targets: [
      _target(
        id: 'day_goals_summary',
        key: summaryKey,
        title: c.dayGoalsSummaryTitle,
        text: c.dayGoalsSummaryText,
        align: ContentAlign.bottom,
        icon: Icons.today_rounded,
      ),
      _target(
        id: 'day_goals_filter',
        key: filterKey,
        title: c.dayGoalsFilterTitle,
        text: c.dayGoalsFilterText,
        align: ContentAlign.bottom,
        icon: Icons.visibility_off_rounded,
      ),
      _target(
        id: 'day_goals_fab',
        key: fabKey,
        title: c.dayGoalsFabTitle,
        text: c.dayGoalsFabText,
        align: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        icon: Icons.add_rounded,
      ),
    ]);
    if (markAsSeen) await _markSeen(_dayGoalsTourKey);
  }

  // ---------------------------------------------------------------------------
  // Questionnaire
  // ---------------------------------------------------------------------------

  static Future<void> showQuestionnaireTourIfNeeded({
    required BuildContext context,
    required GlobalKey progressKey,
    required GlobalKey stepKey,
    required GlobalKey nextKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _questionnaireTourKey,
      delay: const Duration(milliseconds: 650),
      show: () => showQuestionnaireTour(
        context: context,
        progressKey: progressKey,
        stepKey: stepKey,
        nextKey: nextKey,
      ),
    );
  }

  static Future<void> showQuestionnaireTour({
    required BuildContext context,
    required GlobalKey progressKey,
    required GlobalKey stepKey,
    required GlobalKey nextKey,
    bool markAsSeen = false,
  }) async {
    final c = _TourCopy.of(context);
    await _show(context: context, targets: [
      _target(
        id: 'questionnaire_progress',
        key: progressKey,
        title: c.questionnaireProgressTitle,
        text: c.questionnaireProgressText,
        align: ContentAlign.bottom,
        icon: Icons.stacked_line_chart_rounded,
      ),
      _target(
        id: 'questionnaire_next',
        key: nextKey,
        title: c.questionnaireNextTitle,
        text: c.questionnaireNextText,
        align: ContentAlign.top,
        icon: Icons.arrow_forward_rounded,
      ),
    ]);
    if (markAsSeen) await _markSeen(_questionnaireTourKey);
  }

  // ---------------------------------------------------------------------------
  // Expenses
  // ---------------------------------------------------------------------------

  static Future<void> showExpensesTourIfNeeded({
    required BuildContext context,
    required GlobalKey controlsKey,
    required GlobalKey summaryKey,
    required GlobalKey transactionsKey,
    required GlobalKey fabKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _expensesTourKey,
      requiredTab: 5,
      delay: const Duration(milliseconds: 650),
      show: () => showExpensesTour(
        context: context,
        controlsKey: controlsKey,
        summaryKey: summaryKey,
        transactionsKey: transactionsKey,
        fabKey: fabKey,
      ),
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
    final c = _TourCopy.of(context);
    await _show(context: context, targets: [
      _target(
        id: 'expenses_controls',
        key: controlsKey,
        title: c.expensesControlsTitle,
        text: c.expensesControlsText,
        align: ContentAlign.bottom,
        icon: Icons.calendar_month_rounded,
      ),
      _target(
        id: 'expenses_summary',
        key: summaryKey,
        title: c.expensesSummaryTitle,
        text: c.expensesSummaryText,
        align: ContentAlign.bottom,
        icon: Icons.account_balance_wallet_rounded,
      ),
      _target(
        id: 'expenses_transactions',
        key: transactionsKey,
        title: c.expensesTransactionsTitle,
        text: c.expensesTransactionsText,
        align: ContentAlign.top,
        icon: Icons.receipt_long_rounded,
      ),
      _target(
        id: 'expenses_fab',
        key: fabKey,
        title: c.expensesFabTitle,
        text: c.expensesFabText,
        align: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        icon: Icons.add_rounded,
      ),
    ]);
    if (markAsSeen) await _markSeen(_expensesTourKey);
  }

  // ---------------------------------------------------------------------------
  // Reset / helpers
  // ---------------------------------------------------------------------------

  static Future<void> resetAllTours() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in <String>[
      _mainTourKey,
      _goalsTourKey,
      _reportsTourKey,
      _userGoalsTourKey,
      _profileTourKey,
      _budgetTourKey,
      _dayGoalsTourKey,
      _questionnaireTourKey,
      _expensesTourKey,
      _fullAppTourKey,
      _fullAppStepKey,
    ]) {
      await prefs.remove(key);
    }

    _isFullFlowActive = false;
    _fullFlowTabSelector = null;
    _setFullFlowStep(NestFullOnboardingStep.finished);
  }

  static Future<void> _showOnceIfNeeded({
    required BuildContext context,
    required String prefsKey,
    required Duration delay,
    required Future<void> Function() show,
    int? requiredTab,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(prefsKey) ?? false) return;

    await Future<void>.delayed(delay);
    if (!context.mounted) return;
    if (requiredTab != null && activeHomeTab.value != requiredTab) return;

    await show();
    await prefs.setBool(prefsKey, true);
  }

  static Future<void> _markSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  static Future<bool> _showIntroDialog(
    BuildContext context,
    _TourCopy copy,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _TourDialog(
        icon: Icons.auto_awesome_rounded,
        title: copy.welcomeTitle,
        body: copy.welcomeBody,
        primaryText: copy.start,
        secondaryText: copy.skip,
        onPrimary: () => Navigator.pop(ctx, true),
        onSecondary: () async {
          _isFullFlowActive = false;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_fullAppTourKey, true);
          if (ctx.mounted) Navigator.pop(ctx, false);
        },
      ),
    );

    return result ?? false;
  }

  static Future<void> _showFinishDialog(
    BuildContext context,
    _TourCopy copy,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _TourDialog(
        icon: Icons.check_circle_rounded,
        title: copy.finishTitle,
        body: copy.finishBody,
        primaryText: copy.gotIt,
        onPrimary: () => Navigator.pop(ctx),
      ),
    );
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
    final copy = _TourCopy.of(context);
    final completer = Completer<void>();

    final tutorial = TutorialCoachMark(
      targets: visibleTargets,
      colorShadow: Colors.black,
      opacityShadow: 0.76,
      paddingFocus: 7,
      focusAnimationDuration: const Duration(milliseconds: 280),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      pulseEnable: true,
      textSkip: copy.skip,
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
    if (size.width <= 6 || size.height <= 6) return false;

    final screenSize = MediaQuery.maybeOf(context)?.size;
    if (screenSize == null) return true;

    // Prevent old bug: do not highlight almost the entire screen.
    final coversAlmostWholeWidth = size.width >= screenSize.width * 0.94;
    final coversLargeHeight = size.height >= screenSize.height * 0.42;
    return !(coversAlmostWholeWidth && coversLargeHeight);
  }

  static TargetFocus _target({
    required String id,
    required GlobalKey key,
    required String title,
    required String text,
    required ContentAlign align,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    IconData icon = Icons.auto_awesome_rounded,
  }) {
    return TargetFocus(
      identify: id,
      keyTarget: key,
      shape: shape,
      radius: 18,
      contents: [
        TargetContent(
          align: align,
          child: _CoachCard(title: title, text: text, icon: icon),
        ),
      ],
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.title,
    required this.text,
    required this.icon,
  });

  final String title;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = _TourCopy.of(context);
    const dark = Color(0xFF160E38);
    const primary = Color(0xFF7054D4);

    return Container(
      constraints: const BoxConstraints(maxWidth: 330),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAFF).withOpacity(0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2DAFA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8066E6), Color(0xFF6EB5F7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 19),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 15,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF8D8AA3),
              fontSize: 13,
              height: 1.32,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              c.nextHint,
              style: const TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TourDialog extends StatelessWidget {
  const _TourDialog({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryText,
    required this.onPrimary,
    this.secondaryText,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryText;
  final VoidCallback onPrimary;
  final String? secondaryText;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF160E38);
    const primary = Color(0xFF7054D4);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFAFF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE2DAFA), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8066E6), Color(0xFF6EB5F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: dark,
                fontSize: 20,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              body,
              style: const TextStyle(
                color: Color(0xFF8D8AA3),
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                if (secondaryText != null && onSecondary != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        side: const BorderSide(color: Color(0xFFE2DAFA)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        secondaryText!,
                        style: const TextStyle(
                          color: primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: onPrimary,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      primaryText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TourCopy {
  const _TourCopy({
    required this.skip,
    required this.start,
    required this.gotIt,
    required this.nextHint,
    required this.welcomeTitle,
    required this.welcomeBody,
    required this.finishTitle,
    required this.finishBody,
    required this.mainMenuTitle,
    required this.mainMenuText,
    required this.mainNavigationTitle,
    required this.mainNavigationText,
    required this.mainHelpTitle,
    required this.mainHelpText,
    required this.goalsModeTitle,
    required this.goalsModeText,
    required this.goalsFilterTitle,
    required this.goalsFilterText,
    required this.goalsAddTitle,
    required this.goalsAddText,
    required this.userGoalsHeaderTitle,
    required this.userGoalsHeaderText,
    required this.userGoalsFiltersTitle,
    required this.userGoalsFiltersText,
    required this.userGoalsAddTitle,
    required this.userGoalsAddText,
    required this.profileHeaderTitle,
    required this.profileHeaderText,
    required this.profileCardTitle,
    required this.profileCardText,
    required this.profileFocusTitle,
    required this.profileFocusText,
    required this.reportsPeriodTitle,
    required this.reportsPeriodText,
    required this.reportsChartTitle,
    required this.reportsChartText,
    required this.budgetIncomeTitle,
    required this.budgetIncomeText,
    required this.budgetExpenseTitle,
    required this.budgetExpenseText,
    required this.budgetJarsTitle,
    required this.budgetJarsText,
    required this.budgetSaveTitle,
    required this.budgetSaveText,
    required this.dayGoalsSummaryTitle,
    required this.dayGoalsSummaryText,
    required this.dayGoalsFilterTitle,
    required this.dayGoalsFilterText,
    required this.dayGoalsFabTitle,
    required this.dayGoalsFabText,
    required this.questionnaireProgressTitle,
    required this.questionnaireProgressText,
    required this.questionnaireNextTitle,
    required this.questionnaireNextText,
    required this.expensesControlsTitle,
    required this.expensesControlsText,
    required this.expensesSummaryTitle,
    required this.expensesSummaryText,
    required this.expensesTransactionsTitle,
    required this.expensesTransactionsText,
    required this.expensesFabTitle,
    required this.expensesFabText,
  });

  final String skip;
  final String start;
  final String gotIt;
  final String nextHint;
  final String welcomeTitle;
  final String welcomeBody;
  final String finishTitle;
  final String finishBody;
  final String mainMenuTitle;
  final String mainMenuText;
  final String mainNavigationTitle;
  final String mainNavigationText;
  final String mainHelpTitle;
  final String mainHelpText;
  final String goalsModeTitle;
  final String goalsModeText;
  final String goalsFilterTitle;
  final String goalsFilterText;
  final String goalsAddTitle;
  final String goalsAddText;
  final String userGoalsHeaderTitle;
  final String userGoalsHeaderText;
  final String userGoalsFiltersTitle;
  final String userGoalsFiltersText;
  final String userGoalsAddTitle;
  final String userGoalsAddText;
  final String profileHeaderTitle;
  final String profileHeaderText;
  final String profileCardTitle;
  final String profileCardText;
  final String profileFocusTitle;
  final String profileFocusText;
  final String reportsPeriodTitle;
  final String reportsPeriodText;
  final String reportsChartTitle;
  final String reportsChartText;
  final String budgetIncomeTitle;
  final String budgetIncomeText;
  final String budgetExpenseTitle;
  final String budgetExpenseText;
  final String budgetJarsTitle;
  final String budgetJarsText;
  final String budgetSaveTitle;
  final String budgetSaveText;
  final String dayGoalsSummaryTitle;
  final String dayGoalsSummaryText;
  final String dayGoalsFilterTitle;
  final String dayGoalsFilterText;
  final String dayGoalsFabTitle;
  final String dayGoalsFabText;
  final String questionnaireProgressTitle;
  final String questionnaireProgressText;
  final String questionnaireNextTitle;
  final String questionnaireNextText;
  final String expensesControlsTitle;
  final String expensesControlsText;
  final String expensesSummaryTitle;
  final String expensesSummaryText;
  final String expensesTransactionsTitle;
  final String expensesTransactionsText;
  final String expensesFabTitle;
  final String expensesFabText;

  static _TourCopy of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    switch (code) {
      case 'de':
        return _de;
      case 'fr':
        return _fr;
      case 'es':
        return _es;
      case 'tr':
        return _tr;
      case 'en':
        return _en;
      case 'ru':
      default:
        return _ru;
    }
  }

  static const _ru = _TourCopy(
    skip: 'Пропустить',
    start: 'Начать',
    gotIt: 'Понятно',
    nextHint: 'Нажми на экран, чтобы продолжить',
    welcomeTitle: 'Быстрый тур по приложению',
    welcomeBody: 'Покажу основные места: главную, цели, личные трекеры, отчёты и бюджет. Это займёт меньше минуты.',
    finishTitle: 'Готово',
    finishBody: 'Теперь ты знаешь, где находятся основные функции. Тур можно будет запустить снова из настроек.',
    mainMenuTitle: 'Меню действий',
    mainMenuText: 'Здесь открываются быстрые действия: добавить данные, перейти к целям, бюджету, личным трекерам и отчётам.',
    mainNavigationTitle: 'Нижняя навигация',
    mainNavigationText: 'Используй её, чтобы быстро переключаться между главными разделами приложения.',
    mainHelpTitle: 'Подсказки',
    mainHelpText: 'Отсюда можно повторно открыть тур или получить помощь по экрану.',
    goalsModeTitle: 'Задачи и цели',
    goalsModeText: 'Переключайся между ежедневными задачами и большими целями.',
    goalsFilterTitle: 'Период и вид',
    goalsFilterText: 'Здесь можно смотреть день, неделю, месяц или календарь.',
    goalsAddTitle: 'Добавление',
    goalsAddText: 'Создавай задачу вручную, добавляй повторяющуюся задачу, сканируй дневник или используй календарь.',
    userGoalsHeaderTitle: 'Большие цели',
    userGoalsHeaderText: 'Здесь хранятся цели по сферам жизни и горизонту планирования.',
    userGoalsFiltersTitle: 'Фильтры целей',
    userGoalsFiltersText: 'Фильтруй цели по периоду, сфере и статусу.',
    userGoalsAddTitle: 'Новая цель',
    userGoalsAddText: 'Добавь большую цель и связывай с ней ежедневные задачи.',
    profileHeaderTitle: 'Личное',
    profileHeaderText: 'Раздел для здоровья, настроения и хобби.',
    profileCardTitle: 'Профиль',
    profileCardText: 'Здесь можно изменить личные данные и настройки.',
    profileFocusTitle: 'Трекеры',
    profileFocusText: 'Отмечай здоровье, настроение, привычки и личный прогресс.',
    reportsPeriodTitle: 'Период отчёта',
    reportsPeriodText: 'Выбери день, неделю или месяц для анализа.',
    reportsChartTitle: 'Динамика',
    reportsChartText: 'Смотри прогресс, привычки, настроение и распределение времени.',
    budgetIncomeTitle: 'Доходы',
    budgetIncomeText: 'Настрой категории доходов для бюджета.',
    budgetExpenseTitle: 'Расходы',
    budgetExpenseText: 'Настрой категории расходов и используй их при добавлении операций.',
    budgetJarsTitle: 'Копилки',
    budgetJarsText: 'Создавай цели накопления и отслеживай прогресс.',
    budgetSaveTitle: 'Сохранить настройки',
    budgetSaveText: 'После изменения категорий не забудь сохранить настройки бюджета.',
    dayGoalsSummaryTitle: 'Сводка дня',
    dayGoalsSummaryText: 'Здесь видно, сколько задач запланировано, выполнено и сколько осталось часов.',
    dayGoalsFilterTitle: 'Скрыть выполненные',
    dayGoalsFilterText: 'Включи этот режим, чтобы оставить только актуальные задачи.',
    dayGoalsFabTitle: 'Добавить задачу',
    dayGoalsFabText: 'Открой меню добавления: вручную, через скан или календарь.',
    questionnaireProgressTitle: 'Прогресс',
    questionnaireProgressText: 'Полоса показывает, сколько шагов анкеты уже пройдено.',
    questionnaireNextTitle: 'Дальше',
    questionnaireNextText: 'Переходи к следующему шагу после заполнения блока.',
    expensesControlsTitle: 'Период бюджета',
    expensesControlsText: 'Переключай неделю, месяц или год и смотри нужный период.',
    expensesSummaryTitle: 'Финансовая сводка',
    expensesSummaryText: 'Здесь видно свободный остаток, доходы и расходы.',
    expensesTransactionsTitle: 'Операции',
    expensesTransactionsText: 'Список доходов и расходов за выбранный период.',
    expensesFabTitle: 'Добавить операцию',
    expensesFabText: 'Добавь расход, доход или копилку.',
  );

  static const _en = _TourCopy(
    skip: 'Skip',
    start: 'Start',
    gotIt: 'Got it',
    nextHint: 'Tap anywhere to continue',
    welcomeTitle: 'Quick app tour',
    welcomeBody: 'I will show the main areas: home, goals, personal trackers, reports and budget. It takes less than a minute.',
    finishTitle: 'Done',
    finishBody: 'You now know where the main features are. You can restart the tour from settings.',
    mainMenuTitle: 'Action menu',
    mainMenuText: 'Open quick actions, goals, budget, personal trackers and reports from here.',
    mainNavigationTitle: 'Bottom navigation',
    mainNavigationText: 'Use it to switch between the main sections.',
    mainHelpTitle: 'Help',
    mainHelpText: 'Open the tour again or get help for the current screen.',
    goalsModeTitle: 'Tasks and goals',
    goalsModeText: 'Switch between daily tasks and bigger goals.',
    goalsFilterTitle: 'Period and view',
    goalsFilterText: 'View your day, week, month or calendar.',
    goalsAddTitle: 'Add',
    goalsAddText: 'Create tasks manually, add recurring tasks, scan a journal or use calendar.',
    userGoalsHeaderTitle: 'Big goals',
    userGoalsHeaderText: 'Store goals by life area and planning horizon.',
    userGoalsFiltersTitle: 'Goal filters',
    userGoalsFiltersText: 'Filter goals by period, area and status.',
    userGoalsAddTitle: 'New goal',
    userGoalsAddText: 'Add a big goal and connect daily tasks to it.',
    profileHeaderTitle: 'Personal',
    profileHeaderText: 'Health, mood and hobby tracking live here.',
    profileCardTitle: 'Profile',
    profileCardText: 'Edit your personal data and settings.',
    profileFocusTitle: 'Trackers',
    profileFocusText: 'Track health, mood, habits and personal progress.',
    reportsPeriodTitle: 'Report period',
    reportsPeriodText: 'Choose day, week or month for analysis.',
    reportsChartTitle: 'Progress',
    reportsChartText: 'Review progress, habits, mood and time distribution.',
    budgetIncomeTitle: 'Income',
    budgetIncomeText: 'Configure income categories for your budget.',
    budgetExpenseTitle: 'Expenses',
    budgetExpenseText: 'Configure expense categories for transactions.',
    budgetJarsTitle: 'Savings jars',
    budgetJarsText: 'Create saving goals and track progress.',
    budgetSaveTitle: 'Save settings',
    budgetSaveText: 'Save your budget settings after changing categories.',
    dayGoalsSummaryTitle: 'Day summary',
    dayGoalsSummaryText: 'See planned, completed and remaining tasks and hours.',
    dayGoalsFilterTitle: 'Hide completed',
    dayGoalsFilterText: 'Turn this on to show only active tasks.',
    dayGoalsFabTitle: 'Add task',
    dayGoalsFabText: 'Open the add menu: manual, scan or calendar.',
    questionnaireProgressTitle: 'Progress',
    questionnaireProgressText: 'The bar shows how many questionnaire steps are completed.',
    questionnaireNextTitle: 'Next',
    questionnaireNextText: 'Move to the next step after completing the block.',
    expensesControlsTitle: 'Budget period',
    expensesControlsText: 'Switch week, month or year and review the selected period.',
    expensesSummaryTitle: 'Financial summary',
    expensesSummaryText: 'See free balance, income and expenses.',
    expensesTransactionsTitle: 'Transactions',
    expensesTransactionsText: 'Income and expenses for the selected period.',
    expensesFabTitle: 'Add transaction',
    expensesFabText: 'Add an expense, income or saving jar.',
  );

  static const _de = _en;
  static const _fr = _en;
  static const _es = _en;
  static const _tr = _en;
}
