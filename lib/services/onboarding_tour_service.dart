
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

enum NestFullOnboardingStep {
  home,
  goals,
  personal,
  profile, // Backward-compatible alias for the Personal/Profile screen.
  reports,
  expenses,
  finished,
}

/// Fresh Ladna onboarding service for the redesigned screens.
/// Text is localized inside the service, so no ARB regeneration is required.
class OnboardingTourService {
  OnboardingTourService._();

  static const String _fullAppTourKey = 'ladna_tour_full_app_seen_v3';
  static const String _homeTourKey = 'ladna_tour_home_seen_v3';
  static const String _goalsTourKey = 'ladna_tour_goals_seen_v3';
  static const String _personalTourKey = 'ladna_tour_personal_seen_v3';
  static const String _reportsTourKey = 'ladna_tour_reports_seen_v3';
  static const String _expensesTourKey = 'ladna_tour_expenses_seen_v3';
  static const String _dayGoalsTourKey = 'ladna_tour_day_goals_seen_v3';

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
    if (!_isFullFlowActive) return false;
    final current = fullFlowStep.value;
    if (step == NestFullOnboardingStep.profile) {
      return current == NestFullOnboardingStep.personal ||
          current == NestFullOnboardingStep.profile;
    }
    if (step == NestFullOnboardingStep.personal) {
      return current == NestFullOnboardingStep.personal ||
          current == NestFullOnboardingStep.profile;
    }
    return current == step;
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

    onSelectTab(0);
    setActiveHomeTab(0);
    _setFullFlowStep(NestFullOnboardingStep.home);

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!context.mounted || !_isFullFlowActive) return;

    final copy = _TourCopy.of(context);
    final start = await _showIntroDialog(context, copy);
    if (!start || !context.mounted) return;

    onSelectTab(0);
    setActiveHomeTab(0);
    _setFullFlowStep(NestFullOnboardingStep.home);
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
        await _moveFullFlowTo(NestFullOnboardingStep.personal, 2);
        break;
      case NestFullOnboardingStep.personal:
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
    _setFullFlowStep(step);
    _fullFlowTabSelector?.call(tabIndex);
    setActiveHomeTab(tabIndex);
  }

  static Future<void> _finishFullFlow(BuildContext? context) async {
    _isFullFlowActive = false;
    _setFullFlowStep(NestFullOnboardingStep.finished);
    _fullFlowTabSelector = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fullAppTourKey, true);

    if (context != null && context.mounted) {
      await _showFinishDialog(context, _TourCopy.of(context));
    }
  }

  static void _setFullFlowStep(NestFullOnboardingStep? step) {
    if (fullFlowStep.value != step) fullFlowStep.value = step;
  }

  // ---------------------------------------------------------------------------
  // Screen tours
  // ---------------------------------------------------------------------------

  static Future<void> showHomeDashboardTourIfNeeded({
    required BuildContext context,
    required GlobalKey headerKey,
    required GlobalKey focusKey,
    required GlobalKey overviewKey,
    required GlobalKey invitesKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _homeTourKey,
      requiredTab: 0,
      show: () => showHomeDashboardTour(
        context: context,
        headerKey: headerKey,
        focusKey: focusKey,
        overviewKey: overviewKey,
        invitesKey: invitesKey,
      ),
    );
  }

  static Future<void> showHomeDashboardTour({
    required BuildContext context,
    required GlobalKey headerKey,
    required GlobalKey focusKey,
    required GlobalKey overviewKey,
    required GlobalKey invitesKey,
    bool markAsSeen = false,
  }) async {
    final c = _TourCopy.of(context);
    await _show(context: context, targets: [
      _target(
        id: 'home_header',
        key: headerKey,
        title: c.homeHeaderTitle,
        text: c.homeHeaderText,
        align: ContentAlign.bottom,
        icon: Icons.home_rounded,
      ),
      _target(
        id: 'home_focus',
        key: focusKey,
        title: c.homeFocusTitle,
        text: c.homeFocusText,
        align: ContentAlign.bottom,
        icon: Icons.center_focus_strong_rounded,
      ),
      _target(
        id: 'home_invites',
        key: invitesKey,
        title: c.homeInvitesTitle,
        text: c.homeInvitesText,
        align: ContentAlign.bottom,
        icon: Icons.group_add_rounded,
      ),
      _target(
        id: 'home_overview',
        key: overviewKey,
        title: c.homeOverviewTitle,
        text: c.homeOverviewText,
        align: ContentAlign.top,
        icon: Icons.dashboard_rounded,
      ),
    ]);
    if (markAsSeen) await _markSeen(_homeTourKey);
  }

  static Future<void> showMainTourIfNeeded({
    required BuildContext context,
    required GlobalKey launcherKey,
    required GlobalKey helpKey,
    required GlobalKey? navigationKey,
  }) async {
    await showHomeDashboardTourIfNeeded(
      context: context,
      headerKey: launcherKey,
      focusKey: launcherKey,
      overviewKey: navigationKey ?? launcherKey,
      invitesKey: helpKey,
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
    await _show(context: context, targets: [
      _target(
        id: 'main_menu',
        key: launcherKey,
        title: c.mainMenuTitle,
        text: c.mainMenuText,
        align: ContentAlign.top,
        icon: Icons.auto_awesome_rounded,
      ),
      if (navigationKey != null)
        _target(
          id: 'main_nav',
          key: navigationKey,
          title: c.mainNavigationTitle,
          text: c.mainNavigationText,
          align: ContentAlign.top,
          icon: Icons.swipe_rounded,
        ),
    ]);
    if (markAsSeen) await _markSeen(_homeTourKey);
  }

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
    GlobalKey? summaryKey,
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
      if (summaryKey != null)
        _target(
          id: 'goals_summary',
          key: summaryKey,
          title: c.goalsSummaryTitle,
          text: c.goalsSummaryText,
          align: ContentAlign.top,
          icon: Icons.analytics_rounded,
        ),
      _target(
        id: 'goals_add',
        key: addKey,
        title: c.goalsAddTitle,
        text: c.goalsAddText,
        align: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        icon: Icons.add_rounded,
      ),
    ]);
    if (markAsSeen) await _markSeen(_goalsTourKey);
  }

  static Future<void> showPersonalTourIfNeeded({
    required BuildContext context,
    required GlobalKey tabsKey,
    required GlobalKey moodKey,
    required GlobalKey trackersKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _personalTourKey,
      requiredTab: 2,
      show: () => showPersonalTour(
        context: context,
        tabsKey: tabsKey,
        moodKey: moodKey,
        trackersKey: trackersKey,
      ),
    );
  }

  static Future<void> showPersonalTour({
    required BuildContext context,
    required GlobalKey tabsKey,
    required GlobalKey moodKey,
    required GlobalKey trackersKey,
    bool markAsSeen = false,
  }) async {
    final c = _TourCopy.of(context);
    await _show(context: context, targets: [
      _target(
        id: 'personal_tabs',
        key: tabsKey,
        title: c.personalTabsTitle,
        text: c.personalTabsText,
        align: ContentAlign.bottom,
        icon: Icons.favorite_rounded,
      ),
      _target(
        id: 'personal_mood',
        key: moodKey,
        title: c.personalMoodTitle,
        text: c.personalMoodText,
        align: ContentAlign.bottom,
        icon: Icons.mood_rounded,
      ),
      _target(
        id: 'personal_trackers',
        key: trackersKey,
        title: c.personalTrackersTitle,
        text: c.personalTrackersText,
        align: ContentAlign.top,
        icon: Icons.monitor_heart_rounded,
      ),
    ]);
    if (markAsSeen) await _markSeen(_personalTourKey);
  }

  // Backward-compatible old names.
  static Future<void> showUserGoalsTourIfNeeded({
    required BuildContext context,
    required GlobalKey headerKey,
    required GlobalKey filtersKey,
    required GlobalKey addKey,
  }) async {
    await showPersonalTourIfNeeded(
      context: context,
      tabsKey: headerKey,
      moodKey: filtersKey,
      trackersKey: addKey,
    );
  }

  static Future<void> showUserGoalsTour({
    required BuildContext context,
    required GlobalKey headerKey,
    required GlobalKey filtersKey,
    required GlobalKey addKey,
    bool markAsSeen = false,
  }) async {
    await showPersonalTour(
      context: context,
      tabsKey: headerKey,
      moodKey: filtersKey,
      trackersKey: addKey,
      markAsSeen: markAsSeen,
    );
  }

  static Future<void> showProfileTourIfNeeded({
    required BuildContext context,
    required GlobalKey headerKey,
    required GlobalKey profileCardKey,
    required GlobalKey focusKey,
  }) async {
    await showPersonalTourIfNeeded(
      context: context,
      tabsKey: headerKey,
      moodKey: profileCardKey,
      trackersKey: focusKey,
    );
  }

  static Future<void> showProfileTour({
    required BuildContext context,
    required GlobalKey headerKey,
    required GlobalKey profileCardKey,
    required GlobalKey focusKey,
    bool markAsSeen = false,
  }) async {
    await showPersonalTour(
      context: context,
      tabsKey: headerKey,
      moodKey: profileCardKey,
      trackersKey: focusKey,
      markAsSeen: markAsSeen,
    );
  }

  static Future<void> showReportsTourIfNeeded({
    required BuildContext context,
    required GlobalKey periodKey,
    required GlobalKey chartKey,
    GlobalKey? tabsKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _reportsTourKey,
      requiredTab: 4,
      show: () => showReportsTour(
        context: context,
        periodKey: periodKey,
        chartKey: chartKey,
        tabsKey: tabsKey,
      ),
    );
  }

  static Future<void> showReportsTour({
    required BuildContext context,
    required GlobalKey periodKey,
    required GlobalKey chartKey,
    GlobalKey? tabsKey,
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
      if (tabsKey != null)
        _target(
          id: 'reports_tabs',
          key: tabsKey,
          title: c.reportsTabsTitle,
          text: c.reportsTabsText,
          align: ContentAlign.bottom,
          icon: Icons.insights_rounded,
        ),
      _target(
        id: 'reports_chart',
        key: chartKey,
        title: c.reportsChartTitle,
        text: c.reportsChartText,
        align: ContentAlign.top,
        icon: Icons.bar_chart_rounded,
      ),
    ]);
    if (markAsSeen) await _markSeen(_reportsTourKey);
  }

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

  static Future<void> showDayGoalsTourIfNeeded({
    required BuildContext context,
    required GlobalKey summaryKey,
    required GlobalKey filterKey,
    required GlobalKey fabKey,
  }) async {
    await _showOnceIfNeeded(
      context: context,
      prefsKey: _dayGoalsTourKey,
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
        id: 'day_summary',
        key: summaryKey,
        title: c.dayGoalsSummaryTitle,
        text: c.dayGoalsSummaryText,
        align: ContentAlign.bottom,
        icon: Icons.today_rounded,
      ),
      _target(
        id: 'day_filter',
        key: filterKey,
        title: c.dayGoalsFilterTitle,
        text: c.dayGoalsFilterText,
        align: ContentAlign.bottom,
        icon: Icons.filter_alt_rounded,
      ),
      _target(
        id: 'day_fab',
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

  static Future<void> showBudgetTourIfNeeded({
    required BuildContext context,
    required GlobalKey incomeKey,
    required GlobalKey expenseKey,
    required GlobalKey jarsKey,
    required GlobalKey saveKey,
  }) async {}

  static Future<void> showBudgetTour({
    required BuildContext context,
    required GlobalKey incomeKey,
    required GlobalKey expenseKey,
    required GlobalKey jarsKey,
    required GlobalKey saveKey,
    bool markAsSeen = false,
  }) async {}

  static Future<void> showQuestionnaireTourIfNeeded({
    required BuildContext context,
    required GlobalKey progressKey,
    required GlobalKey nextKey,
  }) async {}

  static Future<void> showQuestionnaireTour({
    required BuildContext context,
    required GlobalKey progressKey,
    required GlobalKey nextKey,
    bool markAsSeen = false,
  }) async {}

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  static Future<void> _showOnceIfNeeded({
    required BuildContext context,
    required String prefsKey,
    required Future<void> Function() show,
    int? requiredTab,
    Duration delay = const Duration(milliseconds: 650),
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

    final visibleTargets = targets.where((target) {
      final key = target.keyTarget;
      return key is GlobalKey && key.currentContext != null;
    }).toList();

    if (visibleTargets.isEmpty) return;

    _isTourVisible = true;
    final copy = _TourCopy.of(context);

    final completer = Completer<void>();
    TutorialCoachMark(
      targets: visibleTargets,
      colorShadow: const Color(0xFF100C1E),
      opacityShadow: 0.78,
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 260),
      unFocusAnimationDuration: const Duration(milliseconds: 180),
      pulseEnable: true,
      textSkip: copy.skip,
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 14,
      ),
      onFinish: () {
        _isTourVisible = false;
        if (!completer.isCompleted) completer.complete();
      },
      onSkip: () {
        _isTourVisible = false;
        if (!completer.isCompleted) completer.complete();
        return true;
      },
    ).show(context: context);

    await completer.future;
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
    const primary = Color(0xFF7054D4);

    return Container(
      constraints: const BoxConstraints(maxWidth: 330),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAFF).withOpacity(0.98),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8066E6), Color(0xFFD4E040)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF160E38),
                    fontSize: 16,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF6A6680),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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
    return AlertDialog(
      backgroundColor: const Color(0xFFFBFAFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF7054D4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF160E38),
                fontSize: 20,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        body,
        style: const TextStyle(
          color: Color(0xFF6A6680),
          fontSize: 14,
          height: 1.38,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (secondaryText != null && onSecondary != null)
          TextButton(onPressed: onSecondary, child: Text(secondaryText!)),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF7054D4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: onPrimary,
          child: Text(primaryText),
        ),
      ],
    );
  }
}

class _TourCopy {
  const _TourCopy(this.code);

  final String code;

  static _TourCopy of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return _TourCopy({'ru', 'en', 'de', 'fr', 'es', 'tr'}.contains(code) ? code : 'en');
  }

  String pick(Map<String, String> v) => v[code] ?? v['en'] ?? v.values.first;

  String get skip => pick(const {'ru': 'Пропустить', 'en': 'Skip', 'de': 'Überspringen', 'fr': 'Passer', 'es': 'Omitir', 'tr': 'Atla'});
  String get start => pick(const {'ru': 'Начать', 'en': 'Start', 'de': 'Starten', 'fr': 'Commencer', 'es': 'Empezar', 'tr': 'Başla'});
  String get gotIt => pick(const {'ru': 'Понятно', 'en': 'Got it', 'de': 'Verstanden', 'fr': 'Compris', 'es': 'Entendido', 'tr': 'Anladım'});

  String get welcomeTitle => pick(const {'ru': 'Быстрый тур по Ladna', 'en': 'A quick tour of Ladna', 'de': 'Kurzer Rundgang durch Ladna', 'fr': 'Petit tour de Ladna', 'es': 'Un recorrido rápido por Ladna', 'tr': 'Ladna’da kısa tur'});
  String get welcomeBody => pick(const {'ru': 'Покажу самые важные места: фокус дня, цели, личное состояние, отчёты и бюджет.', 'en': 'I’ll show the key areas: today focus, goals, personal wellbeing, reports and budget.', 'de': 'Ich zeige dir die wichtigsten Bereiche: Tagesfokus, Ziele, Persönliches, Berichte und Budget.', 'fr': 'Je te montre les zones clés : focus du jour, objectifs, personnel, rapports et budget.', 'es': 'Te mostraré lo clave: foco diario, metas, personal, informes y presupuesto.', 'tr': 'Önemli alanları göstereceğim: günlük odak, hedefler, kişisel alan, raporlar ve bütçe.'});
  String get finishTitle => pick(const {'ru': 'Готово — можно начинать', 'en': 'You’re ready', 'de': 'Alles bereit', 'fr': 'C’est prêt', 'es': 'Todo listo', 'tr': 'Hazırsın'});
  String get finishBody => pick(const {'ru': 'Теперь ты знаешь основные экраны. Начни с пары задач на сегодня — дальше Ladna соберёт аналитику.', 'en': 'You now know the main screens. Start with a couple of tasks today — Ladna will build the analytics from there.', 'de': 'Du kennst jetzt die wichtigsten Screens. Starte mit ein paar Aufgaben für heute.', 'fr': 'Tu connais les écrans principaux. Commence par quelques tâches aujourd’hui.', 'es': 'Ya conoces las pantallas principales. Empieza con un par de tareas hoy.', 'tr': 'Ana ekranları gördün. Bugün birkaç görevle başla.'});

  String get homeHeaderTitle => pick(const {'ru': 'Главная — твой центр дня', 'en': 'Home is your day hub'});
  String get homeHeaderText => pick(const {'ru': 'Здесь собраны быстрый вход в профиль, дата и общий контекст дня.', 'en': 'Here you see the date, profile shortcut and the overall daily context.'});
  String get homeFocusTitle => pick(const {'ru': 'Фокус дня', 'en': 'Today focus'});
  String get homeFocusText => pick(const {'ru': 'Главная карточка показывает несколько ключевых задач. Их можно закрывать прямо отсюда.', 'en': 'This card shows your key tasks. You can complete them right from here.'});
  String get homeInvitesTitle => pick(const {'ru': 'Приглашения в пространства', 'en': 'Space invites'});
  String get homeInvitesText => pick(const {'ru': 'Если тебя пригласили в общее пространство, уведомление появится здесь.', 'en': 'When someone invites you to a shared space, it appears here.'});
  String get homeOverviewTitle => pick(const {'ru': 'Обзор дня', 'en': 'Day overview'});
  String get homeOverviewText => pick(const {'ru': 'Настроение, задачи, привычки и фокус-часы дают быстрый срез дня.', 'en': 'Mood, tasks, habits and focus hours give a quick day snapshot.'});

  String get mainMenuTitle => pick(const {'ru': 'Меню действий', 'en': 'Action menu'});
  String get mainMenuText => pick(const {'ru': 'Центральная кнопка открывает быстрые действия.', 'en': 'The center button opens quick actions.'});
  String get mainNavigationTitle => pick(const {'ru': 'Навигация', 'en': 'Navigation'});
  String get mainNavigationText => pick(const {'ru': 'Снизу — основные разделы приложения.', 'en': 'The bottom bar holds the main sections.'});

  String get goalsModeTitle => pick(const {'ru': 'Задачи и большие цели', 'en': 'Tasks and big goals'});
  String get goalsModeText => pick(const {'ru': 'Переключайся между ежедневными задачами и большими целями.', 'en': 'Switch between daily tasks and long-term goals.'});
  String get goalsFilterTitle => pick(const {'ru': 'Личные и общие пространства', 'en': 'Personal and shared spaces'});
  String get goalsFilterText => pick(const {'ru': 'Фильтр показывает все задачи, только личные или задачи конкретного пространства.', 'en': 'Filter all tasks, personal tasks or a specific shared space.'});
  String get goalsSummaryTitle => pick(const {'ru': 'Итог периода', 'en': 'Period summary'});
  String get goalsSummaryText => pick(const {'ru': 'Здесь видно прогресс недели или месяца по задачам и часам.', 'en': 'See weekly or monthly progress by tasks and hours.'});
  String get goalsAddTitle => pick(const {'ru': 'Добавить задачу', 'en': 'Add a task'});
  String get goalsAddText => pick(const {'ru': 'Создавай личные задачи или задачи внутри пространства и назначай исполнителя.', 'en': 'Create personal tasks or shared-space tasks and assign someone.'});

  String get personalTabsTitle => pick(const {'ru': 'Личное состояние', 'en': 'Personal wellbeing'});
  String get personalTabsText => pick(const {'ru': 'Здесь здоровье, настроение и хобби объединены в один личный центр.', 'en': 'Health, mood and hobbies live together in one personal hub.'});
  String get personalMoodTitle => pick(const {'ru': 'Настроение', 'en': 'Mood'});
  String get personalMoodText => pick(const {'ru': 'Оцени день по шкале и добавь заметку — это улучшит отчёты.', 'en': 'Rate the day and add a note — it improves your reports.'});
  String get personalTrackersTitle => pick(const {'ru': 'Трекеры', 'en': 'Trackers'});
  String get personalTrackersText => pick(const {'ru': 'Следи за здоровьем, привычками и хобби без лишней сложности.', 'en': 'Track health, habits and hobbies without extra complexity.'});

  String get reportsPeriodTitle => pick(const {'ru': 'Период отчёта', 'en': 'Report period'});
  String get reportsPeriodText => pick(const {'ru': 'Выбирай день, неделю или месяц и листай периоды стрелками.', 'en': 'Choose day, week or month and move between periods.'});
  String get reportsTabsTitle => pick(const {'ru': 'Тип аналитики', 'en': 'Analytics type'});
  String get reportsTabsText => pick(const {'ru': 'Сводка, прогресс, привычки и настроение показывают разные стороны твоего ритма.', 'en': 'Summary, progress, habits and mood show different sides of your rhythm.'});
  String get reportsChartTitle => pick(const {'ru': 'Пульс периода', 'en': 'Period pulse'});
  String get reportsChartText => pick(const {'ru': 'Главная карточка собирает выполнение задач, привычки, настроение и фокус.', 'en': 'The main card combines tasks, habits, mood and focus.'});

  String get expensesControlsTitle => pick(const {'ru': 'Период бюджета', 'en': 'Budget period'});
  String get expensesControlsText => pick(const {'ru': 'Смотри расходы за день, неделю, месяц или год.', 'en': 'View spending by day, week, month or year.'});
  String get expensesSummaryTitle => pick(const {'ru': 'Финансовая сводка', 'en': 'Financial summary'});
  String get expensesSummaryText => pick(const {'ru': 'Доходы, расходы, баланс и структура затрат — в одном месте.', 'en': 'Income, expenses, balance and spending structure in one place.'});
  String get expensesTransactionsTitle => pick(const {'ru': 'Списки и накопления', 'en': 'Lists and jars'});
  String get expensesTransactionsText => pick(const {'ru': 'Покупки, категории и цели накоплений помогают держать быт под контролем.', 'en': 'Shopping lists, categories and saving jars keep daily life under control.'});
  String get expensesFabTitle => pick(const {'ru': 'Добавить операцию', 'en': 'Add entry'});
  String get expensesFabText => pick(const {'ru': 'Через эту кнопку добавляются расходы, доходы, списки и накопления.', 'en': 'Use this button to add expenses, income, lists and jars.'});

  String get dayGoalsSummaryTitle => pick(const {'ru': 'Сводка дня', 'en': 'Day summary'});
  String get dayGoalsSummaryText => pick(const {'ru': 'Смотри, сколько задач всего, сколько готово и сколько фокус-часов осталось.', 'en': 'See total tasks, completed tasks and remaining focus hours.'});
  String get dayGoalsFilterTitle => pick(const {'ru': 'Фильтры дня', 'en': 'Day filters'});
  String get dayGoalsFilterText => pick(const {'ru': 'Отделяй личные задачи от пространств и фильтруй задачи по сферам жизни.', 'en': 'Separate personal tasks from spaces and filter by life areas.'});
  String get dayGoalsFabTitle => pick(const {'ru': 'Быстрое добавление', 'en': 'Quick add'});
  String get dayGoalsFabText => pick(const {'ru': 'Добавляй обычные, регулярные задачи, импортируй ежедневник или синхронизируй календарь.', 'en': 'Add tasks, recurring plans, journal imports or calendar sync.'});
}
