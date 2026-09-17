// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ladna';

  @override
  String get login => 'Login';

  @override
  String get register => 'Create account';

  @override
  String get home => 'Home';

  @override
  String get budgetSetupTitle => 'Budget & jars';

  @override
  String get budgetSetupSaved => 'Settings saved';

  @override
  String get budgetSetupSaveError => 'Save error';

  @override
  String get budgetIncomeCategoriesTitle => 'Income categories';

  @override
  String get budgetIncomeCategoriesSubtitle => 'Used when adding income';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle =>
      'Choose the app language. “System” uses your device language.';

  @override
  String get budgetExpenseCategoriesTitle => 'Expense categories';

  @override
  String get budgetExpenseCategoriesSubtitle =>
      'Limits help you keep spending under control';

  @override
  String get budgetJarsTitle => 'Savings jars';

  @override
  String get budgetJarsSubtitle =>
      'Percent is a share of free funds that is added automatically';

  @override
  String get loginOr => 'or';

  @override
  String get registerLegalPrefix => 'By registering you accept ';

  @override
  String get registerLegalTerms => 'Terms';

  @override
  String get registerLegalMiddle => ' and ';

  @override
  String get registerLegalPrivacy => 'Privacy Policy';

  @override
  String get registerLegalSuffix => '.';

  @override
  String get budgetNewIncomeCategory => 'New income category';

  @override
  String get budgetNewExpenseCategory => 'New expense category';

  @override
  String get budgetCategoryNameHint => 'Category name';

  @override
  String get budgetAddJar => 'Add a jar';

  @override
  String get budgetJarAdded => 'Jar added';

  @override
  String budgetJarAddFailed(Object error) {
    return 'Could not add: $error';
  }

  @override
  String get budgetJarDeleted => 'Jar deleted';

  @override
  String budgetJarDeleteFailed(Object error) {
    return 'Could not delete: $error';
  }

  @override
  String get budgetNoJarsTitle => 'No jars yet';

  @override
  String get budgetNoJarsSubtitle =>
      'Create your first savings goal — we’ll help you reach it.';

  @override
  String get budgetSetOrChangeLimit => 'Set/change limit';

  @override
  String get budgetDeleteCategoryTitle => 'Delete category?';

  @override
  String budgetCategoryLabel(Object name) {
    return 'Category: $name';
  }

  @override
  String get budgetDeleteJarTitle => 'Delete jar?';

  @override
  String budgetJarLabel(Object title) {
    return 'Jar: $title';
  }

  @override
  String budgetJarSummary(Object saved, Object percent, Object targetPart) {
    return 'Saved: $saved ₽ • Percent: $percent%$targetPart';
  }

  @override
  String get commonAdd => 'Add';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonLoading => 'loading…';

  @override
  String get commonSaving => 'Saving…';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonUpdate => 'Update';

  @override
  String get commonCollapse => 'Collapse';

  @override
  String get commonDots => '...';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonDone => 'Done';

  @override
  String get commonChange => 'Change';

  @override
  String get commonDate => 'Date';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonDash => '—';

  @override
  String get commonPick => 'Pick';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonOr => 'or';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCloseTooltip => 'Close';

  @override
  String get commonTitle => 'Title';

  @override
  String get commonDeleteConfirmTitle => 'Delete entry?';

  @override
  String get dayGoalsAllLifeBlocks => 'All areas';

  @override
  String get dayGoalsEmpty => 'No goals for this day';

  @override
  String dayGoalsAddFailed(Object error) {
    return 'Could not add a goal: $error';
  }

  @override
  String get dayGoalsUpdated => 'Goal updated';

  @override
  String dayGoalsUpdateFailed(Object error) {
    return 'Could not update the goal: $error';
  }

  @override
  String get dayGoalsDeleted => 'Goal deleted';

  @override
  String dayGoalsDeleteFailed(Object error) {
    return 'Could not delete: $error';
  }

  @override
  String dayGoalsToggleFailed(Object error) {
    return 'Could not change status: $error';
  }

  @override
  String get dayGoalsDeleteConfirmTitle => 'Delete goal?';

  @override
  String get dayGoalsFabAddTitle => 'Add a task';

  @override
  String get dayGoalsFabAddSubtitle => 'Create manually';

  @override
  String get dayGoalsFabScanTitle => 'Scan';

  @override
  String get dayGoalsFabScanSubtitle => 'Photo of journal';

  @override
  String get dayGoalsFabCalendarTitle => 'Google Calendar';

  @override
  String get dayGoalsFabCalendarSubtitle => 'Import/export today\'s goals';

  @override
  String get epicIntroSkip => 'Skip';

  @override
  String get epicIntroSubtitle =>
      'A home for thoughts. A place where goals,\ndreams, and plans grow — gently and mindfully.';

  @override
  String get epicIntroPrimaryCta => 'Start my journey';

  @override
  String get epicIntroLater => 'Later';

  @override
  String get epicIntroSecondaryCta => 'Sign in';

  @override
  String get epicIntroFooter =>
      'You can always return to the prologue in Settings.';

  @override
  String get homeMoodSaved => 'Mood saved';

  @override
  String homeMoodSaveFailed(Object error) {
    return 'Could not save: $error';
  }

  @override
  String get homeTodayAndWeekTitle => 'Today & week';

  @override
  String get homeTodayAndWeekSubtitle =>
      'A quick overview — all key metrics are here';

  @override
  String get homeMetricMoodTitle => 'Mood';

  @override
  String get homeMoodNoEntry => 'no entry';

  @override
  String get homeMoodNoNote => 'no note';

  @override
  String get homeMoodHasNote => 'has note';

  @override
  String get homeMetricTasksTitle => 'Tasks';

  @override
  String get homeMetricHoursPerDayTitle => 'Hours/day';

  @override
  String get homeMetricEfficiencyTitle => 'Efficiency';

  @override
  String homeEfficiencyPlannedHours(Object hours) {
    return 'plan ${hours}h';
  }

  @override
  String get homeMoodTodayTitle => 'Mood today';

  @override
  String get homeMoodNoTodayEntry => 'No entry for today';

  @override
  String get homeMoodEntryNoNote => 'Entry exists (no note)';

  @override
  String get homeMoodQuickHint => 'Add a quick check-in — it takes 10 seconds';

  @override
  String get homeMoodUpdateHint =>
      'You can update — it will overwrite today\'s entry';

  @override
  String get homeMoodNoteLabel => 'Note (optional)';

  @override
  String get homeMoodNoteHint => 'What influenced your state?';

  @override
  String get homeOpenMoodHistoryCta => 'Open mood history';

  @override
  String get homeWeekSummaryTitle => 'Week summary';

  @override
  String get homeOpenReportsCta => 'Open detailed reports';

  @override
  String get homeWeekExpensesTitle => 'Week expenses';

  @override
  String get homeNoExpensesThisWeek => 'No expenses this week';

  @override
  String get homeOpenExpensesCta => 'Open expenses';

  @override
  String homeExpensesTotal(Object total) {
    return 'Total: $total €';
  }

  @override
  String homeExpensesAvgPerDay(Object avg) {
    return 'Avg/day: $avg €';
  }

  @override
  String get homeInsightsTitle => 'Insights';

  @override
  String homeTopCategory(Object category, Object amount) {
    return '• Top category: $category — $amount €';
  }

  @override
  String homePeakExpense(Object day, Object amount) {
    return '• Peak spending: $day — $amount €';
  }

  @override
  String get homeOpenDetailedExpensesCta => 'Open detailed expenses';

  @override
  String get homeWeekCardTitle => 'Week';

  @override
  String get homeWeekLoadFailedTitle => 'Could not load stats';

  @override
  String get homeWeekLoadFailedSubtitle =>
      'Check your internet or try again later.';

  @override
  String get gcalTitle => 'Google Calendar';

  @override
  String get gcalHeaderImport =>
      'Find events in your calendar and import them as goals.';

  @override
  String get gcalHeaderExport =>
      'Pick a period and export goals from the app to Google Calendar.';

  @override
  String get gcalModeImport => 'Import';

  @override
  String get gcalModeExport => 'Export';

  @override
  String get gcalCalendarLabel => 'Calendar';

  @override
  String get gcalPrimaryCalendar => 'Primary (default)';

  @override
  String get gcalPeriodLabel => 'Period';

  @override
  String get gcalRangeToday => 'Today';

  @override
  String get gcalRangeNext7 => 'Next 7 days';

  @override
  String get gcalRangeNext30 => 'Next 30 days';

  @override
  String get gcalRangeCustom => 'Choose period...';

  @override
  String get gcalDefaultLifeBlockLabel => 'Default life block (for import)';

  @override
  String get gcalLifeBlockForGoalLabel => 'Life block for this goal';

  @override
  String get gcalEventsNotLoaded => 'Events are not loaded';

  @override
  String get gcalConnectToLoadEvents => 'Connect your account to load events';

  @override
  String get gcalExportHint =>
      'Export will create events in the selected calendar for the chosen period.';

  @override
  String get gcalConnect => 'Connect';

  @override
  String get gcalConnected => 'Connected';

  @override
  String get gcalFindEvents => 'Find events';

  @override
  String get gcalImport => 'Import';

  @override
  String get gcalExport => 'Export';

  @override
  String get gcalNoTitle => 'Untitled';

  @override
  String gcalImportedGoalsCount(Object count) {
    return 'Imported goals: $count';
  }

  @override
  String gcalExportedGoalsCount(Object count) {
    return 'Exported goals: $count';
  }

  @override
  String get launcherQuickFunctionsTitle => 'Quick actions';

  @override
  String get launcherQuickFunctionsSubtitle =>
      'Navigation and actions in one tap';

  @override
  String get launcherSectionsTitle => 'Sections';

  @override
  String get launcherQuickTitle => 'Quick';

  @override
  String get launcherHome => 'Home';

  @override
  String get launcherGoals => 'Day goals';

  @override
  String get launcherMood => 'Mood';

  @override
  String get launcherProfile => 'Profile';

  @override
  String get launcherInsights => 'Insights';

  @override
  String get launcherReports => 'Reports';

  @override
  String get launcherMassAddTitle => 'Bulk add for the day';

  @override
  String get launcherMassAddSubtitle => 'Expenses + Goals + Mood';

  @override
  String get launcherAiPlanTitle => 'AI plan for week/month';

  @override
  String get launcherAiPlanSubtitle =>
      'Analysis of goals, questionnaire and progress';

  @override
  String get launcherAiInsightsTitle => 'AI insights';

  @override
  String get launcherAiInsightsSubtitle =>
      'How events affect goals and progress';

  @override
  String get launcherRecurringGoalTitle => 'Recurring goal';

  @override
  String get launcherRecurringGoalSubtitle => 'Plan ahead for multiple days';

  @override
  String get launcherGoogleCalendarSyncTitle => 'Google Calendar sync';

  @override
  String get launcherGoogleCalendarSyncSubtitle => 'Export goals to calendar';

  @override
  String get launcherNoDatesToCreate =>
      'No dates to create (check deadline/settings).';

  @override
  String launcherCreateSeriesFailed(Object error) {
    return 'Could not create a series of goals: $error';
  }

  @override
  String launcherSaveError(Object error) {
    return 'Save error: $error';
  }

  @override
  String launcherCreatedGoalsCount(Object count) {
    return 'Goals created: $count';
  }

  @override
  String launcherSavedSummary(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodPart,
  ) {
    return 'Saved: $expenses expense(s), $incomes income(s), $goals goal(s), $habits habit(s)$moodPart';
  }

  @override
  String get homeTitleHome => 'Home';

  @override
  String get homeTitleGoals => 'Goals';

  @override
  String get homeTitleMood => 'Mood';

  @override
  String get homeTitleProfile => 'Profile';

  @override
  String get homeTitleReports => 'Reports';

  @override
  String get homeTitleExpenses => 'Expenses';

  @override
  String get homeTitleApp => 'Ladna';

  @override
  String get homeSignOutTooltip => 'Sign out';

  @override
  String get homeSignOutTitle => 'Sign out?';

  @override
  String get homeSignOutSubtitle => 'Your current session will be ended.';

  @override
  String get homeSignOutConfirm => 'Sign out';

  @override
  String homeSignOutFailed(Object error) {
    return 'Could not sign out: $error';
  }

  @override
  String get homeQuickActionsTooltip => 'Quick actions';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get expensesPickDate => 'Pick date';

  @override
  String get expensesCommitTooltip => 'Lock jar allocation';

  @override
  String get expensesCommitUndoTooltip => 'Undo lock';

  @override
  String get expensesBudgetSettings => 'Budget settings';

  @override
  String get expensesCommitDone => 'Allocation locked';

  @override
  String get expensesCommitUndone => 'Lock removed';

  @override
  String get expensesMonthSummary => 'Monthly summary';

  @override
  String expensesIncomeLegend(Object value) {
    return 'Income $value €';
  }

  @override
  String expensesExpenseLegend(Object value) {
    return 'Expenses $value €';
  }

  @override
  String expensesFreeLegend(Object value) {
    return 'Free $value €';
  }

  @override
  String expensesDaySum(Object value) {
    return 'Day total: $value €';
  }

  @override
  String get expensesNoTxForDay => 'No transactions for this day';

  @override
  String get expensesDeleteTxTitle => 'Delete transaction?';

  @override
  String expensesDeleteTxBody(Object category, Object amount) {
    return '$category — $amount €';
  }

  @override
  String get expensesCategoriesMonthTitle => 'Monthly expense categories';

  @override
  String get expensesNoCategoryData => 'No category data yet';

  @override
  String get expensesJarsTitle => 'Savings jars';

  @override
  String get expensesNoJars => 'No jars yet';

  @override
  String get expensesCommitShort => 'Lock';

  @override
  String get expensesCommitUndoShort => 'Undo lock';

  @override
  String get expensesAddIncome => 'Add income';

  @override
  String get expensesAddExpense => 'Add expense';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginCreateAccount => 'Create account';

  @override
  String get loginBtnSignIn => 'Sign in';

  @override
  String get loginContinueGoogle => 'Continue with Google';

  @override
  String get loginContinueApple => 'Continue with Apple ID';

  @override
  String get loginErrEmailRequired => 'Enter email';

  @override
  String get loginErrEmailInvalid => 'Invalid email';

  @override
  String get loginErrPassRequired => 'Enter password';

  @override
  String get loginErrPassMin6 => 'Minimum 6 characters';

  @override
  String get loginResetTitle => 'Password recovery';

  @override
  String get loginResetSend => 'Send';

  @override
  String get loginResetSent => 'Password reset email sent. Check your inbox.';

  @override
  String loginResetFailed(Object error) {
    return 'Could not send email: $error';
  }

  @override
  String get moodTitle => 'Mood';

  @override
  String get moodOnePerDay => '1 entry = 1 day';

  @override
  String get moodHowDoYouFeel => 'How do you feel?';

  @override
  String get moodNoteLabel => 'Note (optional)';

  @override
  String get moodNoteHint => 'What affected your mood?';

  @override
  String get moodSaved => 'Mood saved';

  @override
  String get moodUpdated => 'Entry updated';

  @override
  String get moodHistoryTitle => 'Mood history';

  @override
  String get moodTapToEdit => 'Tap to edit';

  @override
  String get moodNoNote => 'No note';

  @override
  String get moodEditTitle => 'Edit entry';

  @override
  String get moodEmptyTitle => 'No entries yet';

  @override
  String get moodEmptySubtitle => 'Pick a date, select mood and save.';

  @override
  String moodErrSaveFailed(Object error) {
    return 'Could not save mood: $error';
  }

  @override
  String moodErrUpdateFailed(Object error) {
    return 'Could not update entry: $error';
  }

  @override
  String moodErrDeleteFailed(Object error) {
    return 'Could not delete entry: $error';
  }

  @override
  String get onbTopTitle => '';

  @override
  String get onbErrSaveFailed => 'Couldn’t save your answers';

  @override
  String get onbProfileTitle => 'Let’s get to know each other';

  @override
  String get onbProfileSubtitle =>
      'This helps with your profile and personalization';

  @override
  String get onbNameLabel => 'Name';

  @override
  String get onbNameHint => 'For example: Viktor';

  @override
  String get onbAgeLabel => 'Age';

  @override
  String get onbAgeHint => 'For example: 26';

  @override
  String get onbNameNote => 'You can change your name later in your profile.';

  @override
  String get onbBlocksTitle => 'Which life areas do you want to track?';

  @override
  String get onbBlocksSubtitle =>
      'This will be the foundation for your goals and quests';

  @override
  String get onbPrioritiesTitle =>
      'What matters most to you in the next 3–6 months?';

  @override
  String get onbPrioritiesSubtitle =>
      'Pick up to three — this affects recommendations';

  @override
  String get onbPriorityHealth => 'Health';

  @override
  String get onbPriorityCareer => 'Career';

  @override
  String get onbPriorityMoney => 'Money';

  @override
  String get onbPriorityFamily => 'Household';

  @override
  String get onbPriorityGrowth => 'Growth';

  @override
  String get onbPriorityLove => 'Love';

  @override
  String get onbPriorityCreativity => 'Creativity';

  @override
  String get onbPriorityBalance => 'Balance';

  @override
  String onbGoalsBlockTitle(Object block) {
    return 'Goals in “$block”';
  }

  @override
  String get onbGoalsBlockSubtitle => 'Focus: tactical → mid-term → long-term';

  @override
  String get onbGoalLongLabel => 'Long-term goal (6–24 months)';

  @override
  String get onbGoalLongHint => 'For example: reach German level B2';

  @override
  String get onbGoalMidLabel => 'Mid-term goal (2–6 months)';

  @override
  String get onbGoalMidHint => 'For example: finish A2→B1 and pass the exam';

  @override
  String get onbGoalTacticalLabel => 'Tactical goal (2–4 weeks)';

  @override
  String get onbGoalTacticalHint =>
      'For example: 12×30 min sessions + 2 speaking clubs';

  @override
  String get onbWhyLabel => 'Why is this important? (optional)';

  @override
  String get onbWhyHint => 'Motivation/meaning — helps you stay on track';

  @override
  String get onbOptionalNote => 'You can leave it empty and tap “Next”.';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get registerNameLabel => 'Name';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerShowPassword => 'Show password';

  @override
  String get registerHidePassword => 'Hide password';

  @override
  String get registerBtnSignUp => 'Sign up';

  @override
  String get registerContinueGoogle => 'Continue with Google';

  @override
  String get registerContinueApple => 'Continue with Apple ID';

  @override
  String get registerContinueAppleIos => 'Continue with Apple ID (iOS)';

  @override
  String get registerHaveAccountCta => 'Already have an account? Sign in';

  @override
  String get registerErrNameRequired => 'Enter your name';

  @override
  String get registerErrEmailRequired => 'Enter your email';

  @override
  String get registerErrEmailInvalid => 'Invalid email';

  @override
  String get registerErrPassRequired => 'Enter a password';

  @override
  String get registerErrPassMin8 => 'At least 8 characters';

  @override
  String get registerErrPassNeedLower => 'Add a lowercase letter (a-z)';

  @override
  String get registerErrPassNeedUpper => 'Add an uppercase letter (A-Z)';

  @override
  String get registerErrPassNeedDigit => 'Add a digit (0-9)';

  @override
  String get registerErrConfirmRequired => 'Repeat the password';

  @override
  String get registerErrPasswordsMismatch => 'Passwords do not match';

  @override
  String get registerErrAcceptTerms =>
      'You need to accept the Terms and Privacy Policy';

  @override
  String get registerAppleOnlyIos =>
      'Apple ID is available on iPhone/iPad (iOS only)';

  @override
  String get welcomeAppName => 'VitaPlatform';

  @override
  String get welcomeSubtitle =>
      'Manage your goals, mood, and time\n— all in one place';

  @override
  String get welcomeSignIn => 'Sign in';

  @override
  String get welcomeCreateAccount => 'Create account';

  @override
  String get habitsWeekTitle => 'Habits';

  @override
  String get habitsWeekTopTitle => 'Habits (top this week)';

  @override
  String get habitsWeekEmptyHint =>
      'Add at least one habit — your progress will appear here.';

  @override
  String get habitsWeekFooterHint =>
      'We show your most active habits over the last 7 days.';

  @override
  String get mentalWeekTitle => 'Mental health';

  @override
  String mentalWeekLoadError(Object error) {
    return 'Load error: $error';
  }

  @override
  String get mentalWeekNoAnswers => 'No answers found for this week.';

  @override
  String get mentalWeekYesNoHeader => 'Yes/No (week)';

  @override
  String get mentalWeekScalesHeader => 'Scales (trend)';

  @override
  String get mentalWeekFooterHint =>
      'We only show a few questions to keep the screen clean.';

  @override
  String get mentalWeekNoData => 'No data';

  @override
  String mentalWeekYesCount(Object yes, Object total) {
    return 'Yes: $yes/$total';
  }

  @override
  String get moodWeekTitle => 'Weekly mood';

  @override
  String moodWeekMarkedCount(Object filled, Object total) {
    return 'Logged: $filled/$total';
  }

  @override
  String get moodWeekAverageDash => 'Average: —';

  @override
  String moodWeekAverageValue(Object avg) {
    return 'Average: $avg/5';
  }

  @override
  String get moodWeekFooterHint =>
      'This is a quick overview. Details are below in the history.';

  @override
  String get goalsByBlockTitle => 'Goals by area';

  @override
  String get goalsAddTooltip => 'Add goal';

  @override
  String get goalsHorizonTacticalShort => 'Tactical';

  @override
  String get goalsHorizonMidShort => 'Mid-term';

  @override
  String get goalsHorizonLongShort => 'Long-term';

  @override
  String get goalsHorizonTacticalLong => '2–6 weeks';

  @override
  String get goalsHorizonMidLong => '3–6 months';

  @override
  String get goalsHorizonLongLong => '1+ year';

  @override
  String get goalsEditorNewTitle => 'New goal';

  @override
  String get goalsEditorEditTitle => 'Edit goal';

  @override
  String get goalsEditorLifeBlockLabel => 'Area';

  @override
  String get goalsEditorHorizonLabel => 'Horizon';

  @override
  String get goalsEditorTitleLabel => 'Title';

  @override
  String get goalsEditorTitleHint => 'e.g. Improve English to B2';

  @override
  String get goalsEditorDescLabel => 'Description (optional)';

  @override
  String get goalsEditorDescHint =>
      'Briefly: what exactly, and how we measure success';

  @override
  String goalsEditorDeadlineLabel(Object date) {
    return 'Deadline: $date';
  }

  @override
  String goalsDeadlineInline(Object date) {
    return 'Deadline: $date';
  }

  @override
  String get goalsEmptyAllHint =>
      'No goals yet. Add your first goal for the selected areas.';

  @override
  String get goalsNoBlocksToShow => 'No available areas to display.';

  @override
  String get goalsNoGoalsForBlock => 'No goals for the selected area.';

  @override
  String get goalsDeleteConfirmTitle => 'Delete goal?';

  @override
  String goalsDeleteConfirmBody(Object title) {
    return '“$title” will be deleted and cannot be restored.';
  }

  @override
  String get habitsTitle => 'Habits';

  @override
  String get habitsEmptyHint => 'No habits yet. Add your first one.';

  @override
  String get habitsEditorNewTitle => 'New habit';

  @override
  String get habitsEditorEditTitle => 'Edit habit';

  @override
  String get habitsEditorTitleLabel => 'Title';

  @override
  String get habitsEditorTitleHint => 'e.g. Morning workout';

  @override
  String get habitsNegativeLabel => 'Negative habit';

  @override
  String get habitsNegativeHint =>
      'Mark it if you want to track and reduce it.';

  @override
  String get habitsPositiveHint => 'A positive/neutral habit to reinforce.';

  @override
  String get habitsNegativeShort => 'Negative';

  @override
  String get habitsPositiveShort => 'Positive/neutral';

  @override
  String get habitsDeleteConfirmTitle => 'Delete habit?';

  @override
  String habitsDeleteConfirmBody(Object title) {
    return '“$title” will be deleted and cannot be restored.';
  }

  @override
  String get habitsFooterHint =>
      'Later we’ll add habit “filtering” on the home screen.';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileNameTitle => 'Name';

  @override
  String get profileNamePrompt => 'What should we call you?';

  @override
  String get profileAgeLabel => 'Age';

  @override
  String get profileAgeTitle => 'Age';

  @override
  String get profileAgePrompt => 'Enter your age';

  @override
  String get profileAccountSection => 'Account';

  @override
  String get profileSeenPrologueTitle => 'Prologue completed';

  @override
  String get profileSeenPrologueSubtitle => 'You can change this manually';

  @override
  String get profileFocusSection => 'Focus';

  @override
  String get profileTargetHoursLabel => 'Target hours per day';

  @override
  String profileTargetHoursValue(Object hours) {
    return '$hours h';
  }

  @override
  String get profileTargetHoursTitle => 'Daily hours target';

  @override
  String get profileTargetHoursFieldLabel => 'Hours';

  @override
  String get profileQuestionnaireSection => 'Questionnaire & life areas';

  @override
  String get profileQuestionnaireNotDoneTitle =>
      'You haven\'t completed the questionnaire yet.';

  @override
  String get profileQuestionnaireCta => 'Complete now';

  @override
  String get profileLifeBlocksTitle => 'Life areas';

  @override
  String get profileLifeBlocksHint => 'e.g. health, career, family';

  @override
  String get profilePrioritiesTitle => 'Priorities';

  @override
  String get profilePrioritiesHint => 'e.g. sport, finance, reading';

  @override
  String get profileDangerZoneTitle => 'Danger zone';

  @override
  String get profileDeleteAccountTitle => 'Delete account?';

  @override
  String get profileDeleteAccountBody =>
      'This action is irreversible.\nThe following will be deleted: goals, habits, mood, expenses/income, jars, AI plans, XP, and your profile.';

  @override
  String get profileDeleteAccountConfirm => 'Delete forever';

  @override
  String get profileDeleteAccountCta => 'Delete account and all data';

  @override
  String get profileDeletingAccount => 'Deleting…';

  @override
  String get profileDeleteAccountFootnote =>
      'Deletion is irreversible. Your data will be permanently removed from Supabase.';

  @override
  String get profileAccountDeletedToast => 'Account deleted';

  @override
  String get lifeBlockHealth => 'Health';

  @override
  String get lifeBlockCareer => 'Career';

  @override
  String get lifeBlockFamily => 'Household';

  @override
  String get lifeBlockFinance => 'Finance';

  @override
  String get lifeBlockLearning => 'Growth';

  @override
  String get lifeBlockSocial => 'Social';

  @override
  String get lifeBlockRest => 'Rest';

  @override
  String get lifeBlockBalance => 'Balance';

  @override
  String get lifeBlockLove => 'Love';

  @override
  String get lifeBlockCreativity => 'Creativity';

  @override
  String get lifeBlockGeneral => 'General';

  @override
  String get addDayGoalTitle => 'New daily goal';

  @override
  String get addDayGoalFieldTitle => 'Title *';

  @override
  String get addDayGoalTitleHint => 'E.g.: Workout / Work / Study';

  @override
  String get addDayGoalFieldDescription => 'Description';

  @override
  String get addDayGoalDescriptionHint =>
      'Shortly: what exactly needs to be done';

  @override
  String get addDayGoalStartTime => 'Start time';

  @override
  String get addDayGoalLifeBlock => 'Life area';

  @override
  String get addDayGoalImportance => 'Importance';

  @override
  String get addDayGoalEmotion => 'Emotion';

  @override
  String get addDayGoalHours => 'Hours';

  @override
  String get addDayGoalEnterTitle => 'Enter a title';

  @override
  String get addExpenseNewTitle => 'New expense';

  @override
  String get addExpenseEditTitle => 'Edit expense';

  @override
  String get addExpenseAmountLabel => 'Amount';

  @override
  String get addExpenseAmountInvalid => 'Enter a valid amount';

  @override
  String get addExpenseCategoryLabel => 'Category';

  @override
  String get addExpenseCategoryRequired => 'Select a category';

  @override
  String get addExpenseCreateCategoryTooltip => 'Create category';

  @override
  String get addExpenseNoteLabel => 'Note';

  @override
  String get addExpenseNewCategoryTitle => 'New category';

  @override
  String get addExpenseCategoryNameLabel => 'Name';

  @override
  String get addIncomeNewTitle => 'New income';

  @override
  String get addIncomeEditTitle => 'Edit income';

  @override
  String get addIncomeSubtitle => 'Amount, category and note';

  @override
  String get addIncomeAmountLabel => 'Amount';

  @override
  String get addIncomeAmountHint => 'e.g. 1200.50';

  @override
  String get addIncomeAmountInvalid => 'Enter a valid amount';

  @override
  String get addIncomeCategoryLabel => 'Category';

  @override
  String get addIncomeCategoryRequired => 'Select a category';

  @override
  String get addIncomeNoteLabel => 'Note';

  @override
  String get addIncomeNoteHint => 'Optional';

  @override
  String get addIncomeNewCategoryTitle => 'New income category';

  @override
  String get addIncomeCategoryNameLabel => 'Name';

  @override
  String get addIncomeCategoryNameHint => 'e.g. Salary, Freelance…';

  @override
  String get addIncomeCategoryNameEmpty => 'Enter a category name';

  @override
  String get addJarNewTitle => 'New jar';

  @override
  String get addJarEditTitle => 'Edit jar';

  @override
  String get addJarSubtitle => 'Set the target and the share of free money';

  @override
  String get addJarNameLabel => 'Name';

  @override
  String get addJarNameHint => 'e.g. Trip, Emergency fund, House';

  @override
  String get addJarNameRequired => 'Enter a name';

  @override
  String get addJarPercentLabel => 'Share of free money, %';

  @override
  String get addJarPercentHint => '0 if you top up manually';

  @override
  String get addJarPercentRange => 'Percent must be between 0 and 100';

  @override
  String get addJarTargetLabel => 'Target amount';

  @override
  String get addJarTargetHint => 'e.g. 5000';

  @override
  String get addJarTargetHelper => 'Required';

  @override
  String get addJarTargetRequired => 'Enter a target (positive number)';

  @override
  String get aiInsightTypeDataQuality => 'Data quality';

  @override
  String get aiInsightTypeRisk => 'Risk';

  @override
  String get aiInsightTypeEmotional => 'Emotions';

  @override
  String get aiInsightTypeHabit => 'Habits';

  @override
  String get aiInsightTypeGoal => 'Goals';

  @override
  String get aiInsightTypeDefault => 'Insight';

  @override
  String get aiInsightStrengthStrong => 'Strong impact';

  @override
  String get aiInsightStrengthNoticeable => 'Noticeable impact';

  @override
  String get aiInsightStrengthWeak => 'Weak impact';

  @override
  String get aiInsightStrengthLowConfidence => 'Low confidence';

  @override
  String aiInsightStrengthPercent(int value) {
    return '$value%';
  }

  @override
  String get aiInsightEvidenceTitle => 'Evidence';

  @override
  String get aiInsightImpactPositive => 'Positive';

  @override
  String get aiInsightImpactNegative => 'Negative';

  @override
  String get aiInsightImpactMixed => 'Mixed';

  @override
  String get aiInsightsTitle => 'AI insights';

  @override
  String get aiInsightsConfirmTitle => 'Run AI analysis?';

  @override
  String get aiInsightsConfirmBody =>
      'AI will analyze your tasks, habits, and wellbeing for the selected period and save insights. This may take a few seconds.';

  @override
  String get aiInsightsConfirmRun => 'Run';

  @override
  String get aiInsightsPeriod7 => '7 days';

  @override
  String get aiInsightsPeriod30 => '30 days';

  @override
  String get aiInsightsPeriod90 => '90 days';

  @override
  String aiInsightsLastRun(String date) {
    return 'Last run: $date';
  }

  @override
  String get aiInsightsEmptyNotRunTitle => 'AI hasn’t been run yet';

  @override
  String get aiInsightsEmptyNotRunSubtitle =>
      'Pick a period and tap “Run”. Insights will be saved and available in the app.';

  @override
  String get aiInsightsCtaRun => 'Run analysis';

  @override
  String get aiInsightsEmptyNoInsightsTitle => 'No insights yet';

  @override
  String get aiInsightsEmptyNoInsightsSubtitle =>
      'Add more data (tasks, habits, question answers) and run the analysis again.';

  @override
  String get aiInsightsCtaRunAgain => 'Run again';

  @override
  String aiInsightsErrorAi(String error) {
    return 'AI error: $error';
  }

  @override
  String get gcTitleDaySync => 'Google Calendar • day sync';

  @override
  String get gcSubtitleImport => 'Import this day’s events into goals.';

  @override
  String get gcSubtitleExport => 'Export this day’s goals into the calendar.';

  @override
  String get gcModeImport => 'Import';

  @override
  String get gcModeExport => 'Export';

  @override
  String get gcCalendarLabel => 'Calendar';

  @override
  String get gcCalendarPrimary => 'Primary (default)';

  @override
  String get gcDefaultLifeBlockLabel => 'Default life block (for import)';

  @override
  String get gcLifeBlockForThisGoalLabel => 'Life block for this goal';

  @override
  String get gcEventsNotLoaded => 'Events are not loaded';

  @override
  String get gcConnectToLoadEvents => 'Connect your account to load events';

  @override
  String get gcExportHint =>
      'Export will create events in the selected calendar for this day’s goals.';

  @override
  String get gcConnect => 'Connect';

  @override
  String get gcConnected => 'Connected';

  @override
  String get gcFindForDay => 'Find for day';

  @override
  String get gcImport => 'Import';

  @override
  String get gcExport => 'Export';

  @override
  String get gcNoTitle => 'No title';

  @override
  String get gcLoadingDots => '...';

  @override
  String gcImportedGoals(int count) {
    return 'Imported goals: $count';
  }

  @override
  String gcExportedGoals(int count) {
    return 'Exported goals: $count';
  }

  @override
  String get editGoalTitle => 'Edit goal';

  @override
  String get editGoalSectionDetails => 'Details';

  @override
  String get editGoalSectionLifeBlock => 'Life block';

  @override
  String get editGoalSectionParams => 'Settings';

  @override
  String get editGoalFieldTitleLabel => 'Title';

  @override
  String get editGoalFieldTitleHint => 'Example: 3 km run';

  @override
  String get editGoalFieldDescLabel => 'Description';

  @override
  String get editGoalFieldDescHint => 'What exactly needs to be done?';

  @override
  String get editGoalFieldLifeBlockLabel => 'Life block';

  @override
  String get editGoalFieldImportanceLabel => 'Importance';

  @override
  String get editGoalImportanceLow => 'Low';

  @override
  String get editGoalImportanceMedium => 'Medium';

  @override
  String get editGoalImportanceHigh => 'High';

  @override
  String get editGoalFieldEmotionLabel => 'Emotion';

  @override
  String get editGoalFieldEmotionHint => '😊';

  @override
  String get editGoalDurationHours => 'Duration (h)';

  @override
  String get editGoalStartTime => 'Start';

  @override
  String get editGoalUntitled => 'Untitled';

  @override
  String get expenseCategoryOther => 'Other';

  @override
  String get goalStatusDone => 'Done';

  @override
  String get goalStatusInProgress => 'In progress';

  @override
  String get actionDelete => 'Delete';

  @override
  String goalImportanceChip(int value) {
    return 'Priority $value/5';
  }

  @override
  String goalHoursChip(String value) {
    return 'Hours $value';
  }

  @override
  String get goalPathEmpty => 'No goals on the path';

  @override
  String get timelineActionEdit => 'Edit';

  @override
  String get timelineActionDelete => 'Delete';

  @override
  String get saveBarSaving => 'Saving…';

  @override
  String get saveBarSave => 'Save';

  @override
  String get reportEmptyChartNotEnoughData => 'Not enough data';

  @override
  String limitSheetTitle(String categoryName) {
    return 'Limit for “$categoryName”';
  }

  @override
  String get limitSheetHintNoLimit => 'Leave empty — no limit';

  @override
  String get limitSheetFieldLabel => 'Monthly limit';

  @override
  String get limitSheetFieldHint => 'e.g. 15000';

  @override
  String get limitSheetCtaNoLimit => 'No limit';

  @override
  String get profileWebNotificationsSection => 'Notifications (Web)';

  @override
  String get profileWebNotificationsPermissionTitle => 'Allow notifications';

  @override
  String get profileWebNotificationsPermissionSubtitle =>
      'Works on Web and only while the tab is open.';

  @override
  String get profileWebNotificationsEveningTitle => 'Evening check-in';

  @override
  String profileWebNotificationsEveningSubtitle(Object time) {
    return 'Every day at $time';
  }

  @override
  String get profileWebNotificationsChangeTime => 'Change time';

  @override
  String get profileWebNotificationsUnsupported =>
      'Browser notifications are not available in this build. They work only in the Web version (and only while the tab is open).';

  @override
  String get lifeBlockEducation => 'Education';

  @override
  String get lifeBlockHobbies => 'Hobbies';

  @override
  String get userGoalsTitle => 'My goals';

  @override
  String get userGoalsSubtitle =>
      'Strategic goals by life area: short-term, mid-term, and long-term.';

  @override
  String get userGoalsNewTitle => 'New goal';

  @override
  String get userGoalsEditTitle => 'Edit goal';

  @override
  String get userGoalsCreateGoal => 'Create goal';

  @override
  String get userGoalsCreated => 'Goal created';

  @override
  String userGoalsCreateError(Object error) {
    return 'Could not create goal: $error';
  }

  @override
  String get userGoalsUpdated => 'Goal updated';

  @override
  String userGoalsUpdateError(Object error) {
    return 'Could not update goal: $error';
  }

  @override
  String userGoalsStatusChangeError(Object error) {
    return 'Could not change status: $error';
  }

  @override
  String userGoalsDeleteError(Object error) {
    return 'Could not delete goal: $error';
  }

  @override
  String get userGoalsDeleteConfirmTitle => 'Delete goal?';

  @override
  String get userGoalsAllBlocks => 'All';

  @override
  String get userGoalsAllHorizons => 'All horizons';

  @override
  String get userGoalsLoadErrorTitle => 'Loading error';

  @override
  String get userGoalsNoActiveBlocksTitle => 'No active life areas';

  @override
  String get userGoalsNoActiveBlocksSubtitle =>
      'First, choose the life areas the user tracks.';

  @override
  String get userGoalsEmptyTitle => 'No goals yet';

  @override
  String get userGoalsEmptySubtitle =>
      'Create your first strategic goal for one of your life areas.';

  @override
  String userGoalsDeadline(Object date) {
    return 'Deadline: $date';
  }

  @override
  String get userGoalsStatusCompleted => 'Completed';

  @override
  String get userGoalsStatusActive => 'Active';

  @override
  String get userGoalsReopen => 'Reopen';

  @override
  String get userGoalsComplete => 'Complete';

  @override
  String get userGoalsFieldLifeBlock => 'Life area';

  @override
  String get userGoalsFieldHorizon => 'Horizon';

  @override
  String get userGoalsFieldTitle => 'Goal title';

  @override
  String get userGoalsFieldDescription => 'Description';

  @override
  String get userGoalsPickTargetDate => 'Choose target date';

  @override
  String get userGoalsClearDate => 'Clear date';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get weekdayMonShort => 'Mon';

  @override
  String get weekdayTueShort => 'Tue';

  @override
  String get weekdayWedShort => 'Wed';

  @override
  String get weekdayThuShort => 'Thu';

  @override
  String get weekdayFriShort => 'Fri';

  @override
  String get weekdaySatShort => 'Sat';

  @override
  String get weekdaySunShort => 'Sun';

  @override
  String get lifeBlockRelations => 'Relationships';

  @override
  String get lifeBlockSpirituality => 'Spirituality';

  @override
  String goalsHeaderWeek(Object month, Object year, Object week) {
    return '$month $year, week $week';
  }

  @override
  String get goalsQuickActionsTitle => 'Quick actions';

  @override
  String get goalsQuickActionsSubtitle => 'Add and plan in one tap';

  @override
  String get goalsMassAddTitle => 'Mass daily entry';

  @override
  String get goalsMassAddSubtitle =>
      'Expenses + Income + Tasks + Mood + Habits';

  @override
  String goalsMassAddSaved(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodSuffix,
  ) {
    return 'Saved: $expenses expense(s), $incomes income item(s), $goals task(s), $habits habit(s)$moodSuffix';
  }

  @override
  String get goalsMassAddMoodSuffix => ', mood';

  @override
  String goalsSaveError(Object error) {
    return 'Save error: $error';
  }

  @override
  String get goalsRecurringGoalTitle => 'Recurring goal';

  @override
  String get goalsRecurringGoalSubtitle => 'Plan several days ahead';

  @override
  String get goalsRecurringNoDates =>
      'No dates to create. Check the deadline or settings.';

  @override
  String goalsPlanHoursDescription(Object hours) {
    return 'Plan: $hours h';
  }

  @override
  String goalsCreatedCount(Object count) {
    return 'Goals created: $count';
  }

  @override
  String goalsRecurringCreateError(Object error) {
    return 'Could not create the goal series: $error';
  }

  @override
  String get goalsSimpleTaskTitle => 'Quick task';

  @override
  String get goalsSimpleTaskSubtitle =>
      'Title only, optional time, General category';

  @override
  String get goalsSimpleTaskSheetSubtitle =>
      'Title only, optional time. The default category is General.';

  @override
  String get goalsTaskCreated => 'Task created';

  @override
  String goalsTaskCreateError(Object error) {
    return 'Task creation error: $error';
  }

  @override
  String get goalsAll => 'All';

  @override
  String get goalsViewDashboard => 'Dashboard';

  @override
  String get goalsViewCalendar => 'Calendar';

  @override
  String get goalsViewWeek => 'Week';

  @override
  String get goalsViewMonth => 'Month';

  @override
  String get goalsByBlocksTitle => 'Goals by life area';

  @override
  String get goalsShow => 'Show';

  @override
  String get goalsByBlocksHiddenHint => 'Hidden. Tap 👁 to show.';

  @override
  String get goalsEnterTaskTitle => 'Enter a task title';

  @override
  String get goalsTaskTitleLabel => 'Task title';

  @override
  String get goalsAddTime => 'Add time';

  @override
  String goalsTimeValue(Object time) {
    return 'Time: $time';
  }

  @override
  String get goalsRemoveTime => 'Remove time';

  @override
  String get goalsCreateTask => 'Create task';

  @override
  String get goalsWeekSummaryTitle => 'Week summary';

  @override
  String goalsHoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String goalsHoursTargetSuffix(Object hours) {
    return ' / $hours h';
  }

  @override
  String goalsHoursShortNoSpace(Object hours) {
    return '${hours}h';
  }

  @override
  String goalsHoursTargetSuffixNoSpace(Object hours) {
    return ' / ${hours}h';
  }

  @override
  String get dayGoalsHiddenCompletedEmpty =>
      'All visible goals are hidden. Turn off the “Hide completed” filter.';

  @override
  String get dayGoalsKanbanOpenShort => 'Open';

  @override
  String get dayGoalsKanbanDoneShort => 'Done';

  @override
  String get dayGoalsKanbanOpenTitle => 'In progress';

  @override
  String get dayGoalsKanbanDoneTitle => 'Done';

  @override
  String get dayGoalsKanbanOpenEmpty => 'No active tasks';

  @override
  String get dayGoalsKanbanDoneEmpty => 'Nothing here yet';

  @override
  String dayGoalsHoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String get dayGoalsSectionMorning => 'Morning';

  @override
  String get dayGoalsSectionDay => 'Day';

  @override
  String get dayGoalsSectionEvening => 'Evening';

  @override
  String get dayGoalsSummaryTitle => 'Day summary';

  @override
  String get dayGoalsSummarySubtitle =>
      'Stay focused on what matters and keep the day manageable.';

  @override
  String get dayGoalsSummaryTotal => 'Total';

  @override
  String get dayGoalsSummaryDone => 'Done';

  @override
  String get dayGoalsSummaryRemaining => 'Remaining';

  @override
  String dayGoalsRemainingHours(Object hours) {
    return 'Hours remaining: $hours';
  }

  @override
  String get dayGoalsHideCompleted => 'Hide completed';

  @override
  String get reportsTabSummary => 'Summary';

  @override
  String get reportsTabRelations => 'Relations';

  @override
  String get reportsTabProductivity => 'Productivity';

  @override
  String get reportsTabExpenses => 'Expenses';

  @override
  String get reportsCompletedTasks => 'Completed tasks';

  @override
  String get reportsSpentHours => 'Hours spent';

  @override
  String get reportsEfficiency => 'Efficiency';

  @override
  String get reportsPeriodEfficiency => 'Period efficiency';

  @override
  String reportsPlanFactHours(Object planned, Object actual) {
    return 'Plan: $planned h • Actual: $actual h';
  }

  @override
  String get reportsAdditionalMetrics => 'Additional metrics';

  @override
  String get reportsCorrelations => 'Relations between metrics';

  @override
  String get reportsCorrelationsHint =>
      'This is not a scientific correlation, but clear period-based comparisons.';

  @override
  String get reportsMoodProductivity => 'Mood → Productivity';

  @override
  String get reportsGoodMood => 'Good';

  @override
  String get reportsBadMood => 'Bad';

  @override
  String get reportsHabitsMoodProductivity => 'Habits → Mood / Productivity';

  @override
  String get reportsMoodMostlyHappy => 'mostly 😊';

  @override
  String get reportsMoodMostlySad => 'mostly 😞';

  @override
  String get reportsMoodMostlyNeutral => 'mostly 😐';

  @override
  String reportsHabitsComparisonHint(int percent) {
    return 'Comparison of days with ≥ $percent% habits completed and all other days.';
  }

  @override
  String get reportsMoodHigh => 'Mood (high)';

  @override
  String get reportsMoodLow => 'Mood (low)';

  @override
  String get reportsHoursHigh => 'Hours (high)';

  @override
  String get reportsHoursLow => 'Hours (low)';

  @override
  String get reportsHabitsHighShort => 'habits high';

  @override
  String get reportsHabitsLowShort => 'habits low';

  @override
  String get reportsMentalMood => 'Mental state → Mood';

  @override
  String get reportsExpensesMood => 'Expenses → Mood';

  @override
  String get reportsHappyDays => '😊 days';

  @override
  String get reportsSadDays => '😞 days';

  @override
  String get reportsCompletedByBlocks => 'Completed by blocks';

  @override
  String get reportsNoCompletedTasks => 'No completed tasks';

  @override
  String reportsTasksCount(int count) {
    return '$count tasks';
  }

  @override
  String get reportsHoursByDays => 'Hours spent by day';

  @override
  String get reportsExpensesForPeriod => 'Expenses for period';

  @override
  String reportsTotalEuro(Object amount) {
    return 'Total: $amount €';
  }

  @override
  String reportsAvgExpensePerDay(Object amount) {
    return 'Average expense/day: $amount €';
  }

  @override
  String get reportsNoExpensesByCategory => 'No expenses by category';

  @override
  String get reportsAvgTimePerGoal => 'Average time per task';

  @override
  String get reportsOnTimeConditional => '“On time” (approx.)';

  @override
  String get reportsTop3ProductiveDays => 'TOP 3 productive days';

  @override
  String reportsTopDayLine(int day, int month, int year, Object hours) {
    return '• $day.$month.$year: $hours h';
  }

  @override
  String get reportsPeriodDay => 'Day';

  @override
  String get reportsPeriodWeekShort => 'Week';

  @override
  String get reportsPeriodMonthShort => 'Month';

  @override
  String get reportsForward => 'Forward';

  @override
  String get reportsTapChartSector => 'Tap a chart segment';

  @override
  String get reportsLatestAiInsights => 'Latest AI insights';

  @override
  String get reportsOpenAll => 'Open all';

  @override
  String get reportsInsightsLoadFailed => 'Could not load insights';

  @override
  String get reportsNoSavedInsights => 'No saved insights yet.';

  @override
  String get reportsRunAiInsightsHint =>
      'Open “AI insights” and run an analysis — then they will appear here.';

  @override
  String get reportsAiPeriod7Days => 'last 7 days';

  @override
  String get reportsAiPeriod30Days => 'last 30 days';

  @override
  String get reportsAiPeriod90Days => 'last 90 days';

  @override
  String reportsHoursValue(Object hours) {
    return '$hours h';
  }

  @override
  String reportsEuroValue(Object amount) {
    return '$amount €';
  }

  @override
  String get commonError => 'Error';

  @override
  String get aiPlanConsentSaved => 'AI processing consent saved';

  @override
  String aiPlanConsentCheckFailed(Object error) {
    return 'Could not check or save AI processing consent. Make sure the users table has the fields ai_processing_consent, ai_processing_consent_at and ai_processing_consent_version. Details: $error';
  }

  @override
  String get aiPlanConsentTitle => 'AI processing consent';

  @override
  String get aiPlanConsentBody =>
      'To generate an AI plan, Ladna will analyze your goals, tasks, habits, mood and other app data. This data is used only to create personal recommendations, plans and insights.';

  @override
  String get aiPlanConsentDeclineBody =>
      'You can decline consent — in that case, the AI feature will not run.';

  @override
  String get aiPlanConsentNotNow => 'Not now';

  @override
  String get aiPlanConsentAgree => 'I agree';

  @override
  String aiPlanOpenLinkFailed(Object url) {
    return 'Could not open link: $url';
  }

  @override
  String get aiPlanUpdated => 'AI plan updated';

  @override
  String get aiPlanEmptyEdgeFunction =>
      'The plan is empty. Check the ai-plan Edge Function.';

  @override
  String aiPlanHoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String aiPlanImportanceMeta(int importance) {
    return 'importance $importance/5';
  }

  @override
  String get aiPlanLinkedToGoal => 'linked to a goal';

  @override
  String get aiPlanNothingToApply => 'Nothing to apply — select some items';

  @override
  String get aiPlanDefaultTaskTitle => 'AI task';

  @override
  String aiPlanTasksAdded(int count) {
    return 'Tasks added: $count';
  }

  @override
  String get aiPlanApplyTypeError =>
      'Data type error while adding tasks: one of the fields came as true/false instead of a number. Update the file again: in this version, bool values are additionally converted to numbers and the is_completed field is no longer sent manually.';

  @override
  String get aiPlanTitleWeek => 'AI plan for the week';

  @override
  String get aiPlanTitleMonth => 'AI plan for the month';

  @override
  String get aiPlanRegenerateTooltip => 'Generate again';

  @override
  String aiPlanUpdatedAt(Object date) {
    return 'Updated: $date';
  }

  @override
  String get aiPlanCheckingConsent => 'Checking AI processing consent...';

  @override
  String get aiPlanApplyingTasks => 'Adding tasks...';

  @override
  String get aiPlanGenerating => 'Generating AI plan...';

  @override
  String aiPlanApplyCount(int count) {
    return 'Apply ($count)';
  }

  @override
  String get aiPlanRejectTooltip => 'Reject';

  @override
  String get aiPlanAcceptTooltip => 'Accept';

  @override
  String get aiPlanFieldBlock => 'Block';

  @override
  String get aiPlanFieldImportance => 'Importance';

  @override
  String get aiPlanFieldHours => 'Hours';

  @override
  String get aiPlanFieldRepeat => 'Repeat';

  @override
  String get aiPlanConsentRequiredTitle => 'AI processing consent is required';

  @override
  String get aiPlanConsentRequiredBody =>
      'Before generating an AI plan, you need to confirm that Ladna may analyze app data for personal recommendations.';

  @override
  String get aiPlanGiveConsent => 'Give consent';

  @override
  String get aiPlanPrivacyPolicy => 'Privacy Policy';

  @override
  String get aiPlanDatenschutz => 'Data Protection Policy';

  @override
  String get aiPlanTermsOfUse => 'Terms of Use';

  @override
  String get aiPlanEmptyTitle => 'The plan is empty';

  @override
  String get aiPlanEmptyBody =>
      'Press the button below to generate a plan based on AI insights, goals, tasks, habits and mood.';

  @override
  String get aiPlanGeneratePlan => 'Generate plan';

  @override
  String get aiPlanRepeatNone => 'No repeat';

  @override
  String get aiPlanRepeatDaily => 'Every day';

  @override
  String get aiPlanRepeatWeekdays => 'Weekdays';

  @override
  String get aiPlanRepeatWeekly => 'Once a week';

  @override
  String get aiPlanLifeBlockOther => 'Other';

  @override
  String get aiInsightsConsentTitle => 'AI processing consent';

  @override
  String get aiInsightsConsentBody =>
      'To generate AI insights, Ladna will analyze your goals, tasks, habits, mood and other app data. This data is used only to create personal recommendations, plans and insights.';

  @override
  String get aiInsightsConsentDeclineBody =>
      'You can decline consent — in that case, the AI feature will not run.';

  @override
  String get aiInsightsConsentNotNow => 'Not now';

  @override
  String get aiInsightsConsentAgree => 'I agree';

  @override
  String get aiInsightsConsentSaved => 'AI processing consent saved';

  @override
  String aiInsightsConsentCheckFailed(Object error) {
    return 'Could not check or save AI processing consent. Make sure the users table has the fields ai_processing_consent, ai_processing_consent_at and ai_processing_consent_version. Details: $error';
  }

  @override
  String get aiInsightsCheckingConsent => 'Checking AI processing consent...';

  @override
  String get aiInsightsUserNotAuthorized => 'User is not authenticated';

  @override
  String aiInsightsOpenLinkFailed(Object url) {
    return 'Could not open link: $url';
  }

  @override
  String get aiInsightsDefaultTitle => 'AI insight';

  @override
  String get aiInsightsConsentRequiredTitle =>
      'AI processing consent is required';

  @override
  String get aiInsightsConsentRequiredBody =>
      'Before generating AI insights, you need to confirm that Ladna may analyze app data for personal recommendations.';

  @override
  String get aiInsightsGiveConsent => 'Give consent';

  @override
  String get aiInsightsPrivacyPolicy => 'Privacy Policy';

  @override
  String get aiInsightsDatenschutz => 'Data Protection Policy';

  @override
  String get aiInsightsTermsOfUse => 'Terms of Use';

  @override
  String get massDailyTitle => 'Mass daily entry';

  @override
  String get massDailyDatePrefix => 'Date: ';

  @override
  String get massDailyChoose => 'Choose';

  @override
  String get massDailyBack => 'Back';

  @override
  String get massDailyCancel => 'Cancel';

  @override
  String get massDailyNext => 'Next';

  @override
  String get massDailySaveAll => 'Save all';

  @override
  String get massDailyEmptyRowsIgnored => 'Empty rows are ignored.';

  @override
  String get massDailyMoodTitle => 'Mood';

  @override
  String get massDailyMoodSubtitle => 'Optional note about how the day went.';

  @override
  String get massDailyNote => 'Note';

  @override
  String get massDailyHabitsTitle => 'Habits';

  @override
  String get massDailyHabitsSubtitle =>
      'Mark completion and add a quantity if needed.';

  @override
  String get massDailyRefresh => 'Refresh';

  @override
  String get massDailyNoHabits => 'No habits yet. Add them in your profile.';

  @override
  String massDailyHabitsLoadFailed(Object error) {
    return 'Could not load habits: $error';
  }

  @override
  String get massDailyMentalTitle => 'Mental health';

  @override
  String get massDailyMentalSubtitle =>
      'A short daily state check-in for later analytics.';

  @override
  String get massDailyMentalIntro =>
      'Answer a few questions — this helps track your state.';

  @override
  String get massDailyNoMentalQuestions =>
      'No questions yet. Add them to the mental_questions table.';

  @override
  String massDailyMentalLoadFailed(Object error) {
    return 'Could not load questions: $error';
  }

  @override
  String get massDailyExpensesTitle => 'Expenses';

  @override
  String get massDailyExpensesSubtitle => 'Add expenses for the selected day.';

  @override
  String get massDailyIncomesTitle => 'Income';

  @override
  String get massDailyIncomesSubtitle => 'Add income for the selected day.';

  @override
  String get massDailyGoalsTitle => 'Tasks';

  @override
  String get massDailyGoalsSubtitle =>
      'Record what you worked on that day and how much time it took.';

  @override
  String get massDailyAddRow => 'Add row';

  @override
  String get massDailyNoMood => 'No mood';

  @override
  String get massDailyQuantityExample => 'Quantity (for example, cigarettes)';

  @override
  String get massDailyQuantityOptional => 'Quantity (optional)';

  @override
  String get massDailyQuantityShort => 'Qty';

  @override
  String get massDailyHabitNegative => 'Negative';

  @override
  String get massDailyHabitPositive => 'Positive';

  @override
  String get massDailyAnswer => 'Answer';

  @override
  String get massDailyAmount => 'Amount';

  @override
  String get massDailyCategory => 'Category';

  @override
  String get massDailyNoCategories => 'No categories';

  @override
  String get massDailyTaskTitle => 'Task title';

  @override
  String get massDailyHours => 'Hours';

  @override
  String get massDailyTime => 'Time';

  @override
  String get massDailyEmotion => 'Emotion';

  @override
  String get massDailyNoEmotion => 'No emotion';

  @override
  String get massDailyImportance => 'Importance';

  @override
  String get massDailyBigGoal => 'Big goal';

  @override
  String get massDailyNoLink => 'Not linked';

  @override
  String get massDailyLoadingUserGoals => 'Loading big goals...';

  @override
  String get massDailyNoUserGoalsForCategory =>
      'There are no big goals for this category yet.';

  @override
  String get massDailyHorizonTactical => 'Tactical';

  @override
  String get massDailyHorizonMid => 'Mid-term';

  @override
  String get massDailyHorizonLong => 'Long-term';

  @override
  String get massDailyLifeBlockGeneral => 'General';

  @override
  String get massDailyLifeBlockHealth => 'Health';

  @override
  String get massDailyLifeBlockCareer => 'Career';

  @override
  String get massDailyLifeBlockFamily => 'Household';

  @override
  String get massDailyLifeBlockFinance => 'Finance';

  @override
  String get massDailyLifeBlockEducation => 'Education';

  @override
  String get massDailyLifeBlockHobbies => 'Hobbies';

  @override
  String get importJournalTextNotRecognized =>
      'Text was not recognized. Try another photo.';

  @override
  String get importJournalRecognizedTextTitle => 'Recognized text';

  @override
  String get importJournalContinue => 'Continue';

  @override
  String get importJournalUntitled => 'Untitled';

  @override
  String get importJournalNoTasksFound =>
      'Could not extract tasks from the text.';

  @override
  String importJournalAddedGoals(Object count) {
    return 'Added goals: $count';
  }

  @override
  String importJournalImportFailed(Object error) {
    return 'Could not import: $error';
  }

  @override
  String get importJournalVisionApiKeyMissing =>
      'VISION_API_KEY is not set. Run the app with --dart-define=VISION_API_KEY=...';

  @override
  String importJournalVisionApiError(Object statusCode, Object body) {
    return 'Vision API returned error $statusCode: $body';
  }

  @override
  String get importJournalEditTitle => 'Edit';

  @override
  String get importJournalNameLabel => 'Name';

  @override
  String get importJournalTimeColon => 'Time:';

  @override
  String get importJournalHoursColon => 'Hours:';

  @override
  String get importJournalFoundTasksTitle => 'Found tasks';

  @override
  String importJournalTaskSubtitle(Object time, Object hours) {
    return '$time • $hours h';
  }

  @override
  String get importJournalAddSelected => 'Add selected';

  @override
  String get recurringGoalSelectAtLeastOneWeekday =>
      'Select at least one weekday';

  @override
  String get recurringGoalTitle => 'Recurring goal';

  @override
  String get recurringGoalSubtitle =>
      'Creates tasks from today until the selected date.';

  @override
  String get recurringGoalDetailsSection => 'Details';

  @override
  String get recurringGoalTitleLabel => 'Goal title';

  @override
  String get recurringGoalTitleHint => 'For example: Workout';

  @override
  String get recurringGoalEmotionLabel => 'Emotion';

  @override
  String get recurringGoalEmotionHint => 'For example: 💪 motivation';

  @override
  String get recurringGoalRegularitySection => 'Recurrence';

  @override
  String get recurringGoalEveryNDays => 'Every N days';

  @override
  String get recurringGoalByWeekdays => 'By weekdays';

  @override
  String get recurringGoalIntervalLabel => 'Interval';

  @override
  String recurringGoalEveryNDaysShort(Object count) {
    return '$count d';
  }

  @override
  String get recurringGoalWeekdayMon => 'Mon';

  @override
  String get recurringGoalWeekdayTue => 'Tue';

  @override
  String get recurringGoalWeekdayWed => 'Wed';

  @override
  String get recurringGoalWeekdayThu => 'Thu';

  @override
  String get recurringGoalWeekdayFri => 'Fri';

  @override
  String get recurringGoalWeekdaySat => 'Sat';

  @override
  String get recurringGoalWeekdaySun => 'Sun';

  @override
  String recurringGoalTimeButton(Object time) {
    return 'Time: $time';
  }

  @override
  String recurringGoalUntilButton(Object date) {
    return 'Until: $date';
  }

  @override
  String get recurringGoalParametersSection => 'Parameters';

  @override
  String get recurringGoalLifeBlockLabel => 'Life block';

  @override
  String get recurringGoalImportanceLabel => 'Importance';

  @override
  String get recurringGoalUserGoalLabel => 'Big goal';

  @override
  String get recurringGoalNoLink => 'No link';

  @override
  String recurringGoalLoadingUserGoals(Object block) {
    return 'Loading goals for “$block”...';
  }

  @override
  String recurringGoalNoUserGoalsForBlock(Object block) {
    return 'There are no available goals for “$block” yet.';
  }

  @override
  String get recurringGoalPlannedHoursLabel => 'Planned hours';

  @override
  String recurringGoalOccurrencesCount(Object count) {
    return 'Tasks to be created: $count';
  }

  @override
  String get recurringGoalCreate => 'Create';

  @override
  String get recurringGoalLifeBlockGeneral => 'General';

  @override
  String get recurringGoalLifeBlockHealth => 'Health';

  @override
  String get recurringGoalLifeBlockCareer => 'Career';

  @override
  String get recurringGoalLifeBlockFinance => 'Finance';

  @override
  String get recurringGoalLifeBlockRelationships => 'Relationships';

  @override
  String get recurringGoalLifeBlockSelf => 'Self-development';

  @override
  String get recurringGoalLifeBlockEducation => 'Education';

  @override
  String get recurringGoalLifeBlockTravel => 'Travel';

  @override
  String get recurringGoalLifeBlockHome => 'Home';

  @override
  String get recurringGoalHorizonTactical => 'Tactical';

  @override
  String get recurringGoalHorizonMid => 'Mid-term';

  @override
  String get recurringGoalHorizonLong => 'Long-term';

  @override
  String get addDayGoalLinkSectionTitle => 'Link to a goal';

  @override
  String get addDayGoalUserGoalLabel => 'Big goal';

  @override
  String get addDayGoalNoLinkedGoal => 'No link';

  @override
  String addDayGoalLoadingUserGoals(Object block) {
    return 'Loading goals for “$block”...';
  }

  @override
  String addDayGoalNoUserGoalsForBlock(Object block) {
    return 'There are no available goals for “$block” yet.';
  }

  @override
  String get addDayGoalLifeBlockGeneral => 'General';

  @override
  String get addDayGoalLifeBlockHealth => 'Health';

  @override
  String get addDayGoalLifeBlockCareer => 'Career';

  @override
  String get addDayGoalLifeBlockFinance => 'Finance';

  @override
  String get addDayGoalLifeBlockRelationships => 'Relationships';

  @override
  String get addDayGoalLifeBlockSelf => 'Self-development';

  @override
  String get addDayGoalLifeBlockEducation => 'Education';

  @override
  String get addDayGoalLifeBlockTravel => 'Travel';

  @override
  String get addDayGoalLifeBlockHome => 'Home';

  @override
  String get addDayGoalHorizonTactical => 'Tactical';

  @override
  String get addDayGoalHorizonMid => 'Mid-term';

  @override
  String get addDayGoalHorizonLong => 'Long-term';

  @override
  String get lifeBlockSelf => 'Self-development';

  @override
  String get lifeBlockTravel => 'Travel';

  @override
  String get lifeBlockHome => 'Home';

  @override
  String get horizonTactical => 'Tactical';

  @override
  String get horizonMid => 'Mid-term';

  @override
  String get horizonLong => 'Long-term';

  @override
  String get editGoalSectionDateTime => 'Date and time';

  @override
  String get editGoalSectionUserGoalLink => 'Link to a larger goal';

  @override
  String get userGoalLinkFieldLabel => 'Larger goal';

  @override
  String get userGoalLinkNone => 'No link';

  @override
  String userGoalLinkLoadingForBlock(Object block) {
    return 'Loading goals for “$block”...';
  }

  @override
  String userGoalLinkNoGoalsForBlock(Object block) {
    return 'No available goals for “$block” yet.';
  }

  @override
  String editGoalHoursValue(Object hours) {
    return 'Hours: $hours';
  }

  @override
  String commonHoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String get healthTrackerTitle => 'Health tracker';

  @override
  String get healthCalorieTargetTitle => 'Calorie target';

  @override
  String get healthDailyCaloriesLabel => 'Kcal per day';

  @override
  String get healthAddMealTitle => 'Add meal';

  @override
  String get healthMealTypeLabel => 'Meal';

  @override
  String get healthMealBreakfast => 'Breakfast';

  @override
  String get healthMealLunch => 'Lunch';

  @override
  String get healthMealDinner => 'Dinner';

  @override
  String get healthMealSnack => 'Snack';

  @override
  String get healthCaloriesLabel => 'Calories';

  @override
  String get healthEnterCalories => 'Enter calories';

  @override
  String get healthMealDescriptionLabel => 'What did you eat?';

  @override
  String get healthAddDescription => 'Add a description';

  @override
  String get healthAddBurnTitle => 'Add calories burned';

  @override
  String get healthCaloriesBurnedLabel => 'Calories burned';

  @override
  String get healthCommentLabel => 'Comment';

  @override
  String get healthWaterTodayTitle => 'How much water did you drink today?';

  @override
  String get healthSaveWater => 'Save water';

  @override
  String get healthSetTarget => 'Set target';

  @override
  String healthTargetCalories(Object calories) {
    return 'Target $calories kcal';
  }

  @override
  String get healthAddMealButton => 'Add food';

  @override
  String get healthAddBurnButton => 'Add burn';

  @override
  String healthWaterButton(Object liters) {
    return 'Water $liters L';
  }

  @override
  String get healthConsumed => 'Consumed';

  @override
  String get healthBurned => 'Burned';

  @override
  String get healthBalance => 'Balance';

  @override
  String get healthDeltaVsTarget => 'Delta vs target';

  @override
  String get healthWaterDrunk => 'Water drunk';

  @override
  String healthKcalValue(Object value) {
    return '$value kcal';
  }

  @override
  String healthKcalValueWithSign(Object value) {
    return '$value kcal';
  }

  @override
  String healthLitersValue(Object value) {
    return '$value L';
  }

  @override
  String get healthMealsTodayTitle => 'Meals today';

  @override
  String get healthNoMeals => 'No meal entries yet.';

  @override
  String get healthBurnsTitle => 'Calories burned';

  @override
  String get healthNoBurns => 'No burned-calorie entries yet.';

  @override
  String get healthNoComment => 'No comment';

  @override
  String get hobbyTrackerTitle => 'Hobby tracker';

  @override
  String get hobbyTrackerNewHobbyTitle => 'New hobby';

  @override
  String get hobbyTrackerHobbyNameLabel => 'Hobby name';

  @override
  String get hobbyTrackerEnterHobbyValidator => 'Enter a hobby';

  @override
  String get hobbyTrackerWeeklyGoalMinutesLabel => 'Weekly goal, minutes';

  @override
  String get hobbyTrackerEnterGoalValidator => 'Enter a goal';

  @override
  String get hobbyTrackerCreateButton => 'Create';

  @override
  String hobbyTrackerAddTimeTitle(Object title) {
    return 'Add time: $title';
  }

  @override
  String get hobbyTrackerMinutesSpentLabel => 'Minutes spent';

  @override
  String get hobbyTrackerNoteLabel => 'Note';

  @override
  String get hobbyTrackerDeleteConfirmTitle => 'Delete hobby?';

  @override
  String hobbyTrackerDeleteConfirmBody(Object title) {
    return 'Hobby \"$title\" will be deleted together with all entries.';
  }

  @override
  String get hobbyTrackerAddHobbyTooltip => 'Add hobby';

  @override
  String get hobbyTrackerEmptyText =>
      'No hobbies yet. Add your first activity and start tracking time.';

  @override
  String get hobbyTrackerCreateHobbyButton => 'Create hobby';

  @override
  String get hobbyTrackerDeleteHobbyTooltip => 'Delete hobby';

  @override
  String get hobbyTrackerAddEntryButton => 'Add entry';

  @override
  String hobbyTrackerToday(Object value) {
    return 'Today $value';
  }

  @override
  String hobbyTrackerWeek(Object value) {
    return 'Week $value';
  }

  @override
  String hobbyTrackerGoal(Object value) {
    return 'Goal: $value';
  }

  @override
  String hobbyTrackerMinutesShort(Object minutes) {
    return '${minutes}m';
  }

  @override
  String hobbyTrackerHoursShort(Object hours) {
    return '${hours}h';
  }

  @override
  String hobbyTrackerHoursMinutesShort(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get importGoalsReviewTitle => 'Import goals';

  @override
  String get importGoalsReviewSubtitle =>
      'Select what to import and adjust the title or description if needed.';

  @override
  String get importGoalsReviewSelectAll => 'Select all';

  @override
  String get importGoalsReviewYes => 'Yes';

  @override
  String get importGoalsReviewNo => 'No';

  @override
  String get importGoalsReviewListSection => 'List';

  @override
  String get importGoalsReviewImport => 'Import';

  @override
  String get importGoalsReviewFieldTitle => 'Title';

  @override
  String get importGoalsReviewFieldDescription => 'Description';

  @override
  String importGoalsReviewTime(Object time) {
    return 'Time: $time';
  }

  @override
  String get importGoalsReviewChange => 'Change';

  @override
  String get shoppingBasketCopyHeader => '🛒 Shopping list';

  @override
  String shoppingDueDatePrefix(Object date) {
    return 'by $date';
  }

  @override
  String get shoppingBasketCopied => 'Shopping list copied';

  @override
  String get shoppingNewWishlistItem => 'New wish item';

  @override
  String get shoppingNewPurchase => 'New purchase';

  @override
  String get shoppingEditItem => 'Edit item';

  @override
  String get shoppingFieldTitle => 'Title';

  @override
  String get shoppingEnterTitle => 'Enter a title';

  @override
  String get shoppingFieldDescription => 'Description';

  @override
  String get shoppingFieldPrice => 'Price';

  @override
  String get shoppingFieldStore => 'Store';

  @override
  String get shoppingFieldExpenseCategory => 'Expense category';

  @override
  String get shoppingNoCategory => 'No category';

  @override
  String get shoppingAlreadyBought => 'Already bought';

  @override
  String get shoppingPurchaseDate => 'Purchase date';

  @override
  String get shoppingReset => 'Reset';

  @override
  String get shoppingEmpty => 'Empty for now.';

  @override
  String get shoppingTrackerTitle => 'Shopping tracker';

  @override
  String get shoppingCopyBasket => 'Copy basket';

  @override
  String get shoppingBasketTitle => 'Shopping list';

  @override
  String get shoppingWishlistTitle => 'Wishlist';

  @override
  String get profileOpenLinkFailed => 'Could not open the link.';

  @override
  String get profileDangerZoneSubtitle => 'Account deletion';

  @override
  String get profileLegalDocumentsTitle => 'Legal documents';

  @override
  String get profileLegalDocumentsSubtitle =>
      'You can open the Privacy Policy, Datenschutz, Terms of Use, and Impressum at any time.';

  @override
  String get profileLegalPrivacyTitle => 'Privacy Policy';

  @override
  String get profileLegalPrivacySubtitle =>
      'English version of the privacy policy';

  @override
  String get profileLegalDatenschutzTitle => 'Datenschutzerklärung';

  @override
  String get profileLegalDatenschutzSubtitle =>
      'German version of the privacy policy';

  @override
  String get profileLegalTermsTitle => 'Terms of Use';

  @override
  String get profileLegalTermsSubtitle =>
      'Rules and conditions for using Ladna';

  @override
  String get profileLegalImpressumTitle => 'Impressum';

  @override
  String get profileLegalImpressumSubtitle =>
      'Legal notice and provider information';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageGerman => 'Deutsch';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageTurkish => 'Türkçe';

  @override
  String get profileWebNotificationsEveningBody =>
      'Mark your habits and wrap up your day 👌';

  @override
  String get profileWebNotificationsPermissionDeniedToast =>
      'Permission was not granted. Check your browser notification settings.';

  @override
  String get profileWebNotificationsPermissionGrantedToast =>
      'Browser notifications are enabled ✅';

  @override
  String profileWebNotificationsTimeChangedToast(Object time) {
    return 'Notification time: $time';
  }

  @override
  String get profileWebNotificationsLoadingSettings => 'Loading settings...';

  @override
  String get profileWebNotificationsEnabledToast =>
      'Enabled. Remember to allow notifications in your browser.';

  @override
  String get profileWebNotificationsDisabledToast => 'Disabled.';

  @override
  String get profileEditChipsDefaultHint => 'Enter values separated by commas';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Ladna';

  @override
  String get onboardingWelcomeBody =>
      'I’ll quickly show you the main features: quick actions, tasks, big goals, profile, reports, and finances.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingFinishTitle => 'Done';

  @override
  String get onboardingFinishBody =>
      'Now you know where the main Ladna features are. You can restart the tutorial later from the help icon on the home screen.';

  @override
  String get onboardingGotIt => 'Got it';

  @override
  String get onboardingMainQuickActionsTitle => 'Quick actions';

  @override
  String get onboardingMainQuickActionsText =>
      'Use this button to quickly add tasks, mood, expenses, habits, and launch the AI plan.';

  @override
  String get onboardingMainNavigationTitle => 'Ladna navigation';

  @override
  String get onboardingMainNavigationText =>
      'Here you’ll find the main sections: home, tasks, big goals, profile, reports, and finances.';

  @override
  String get onboardingMainHelpTitle => 'Open the guide again';

  @override
  String get onboardingMainHelpText =>
      'Tap this icon whenever you want to repeat the interactive How-To later.';

  @override
  String get onboardingGoalsFilterTitle => 'Life area filter';

  @override
  String get onboardingGoalsFilterText =>
      'Choose career, health, finance, and other areas to view tasks in the right context.';

  @override
  String get onboardingGoalsModeTitle => 'Dashboard or calendar';

  @override
  String get onboardingGoalsModeText =>
      'The dashboard shows the big picture, while the calendar helps you plan tasks by day and week.';

  @override
  String get onboardingGoalsAddTitle => 'Add actions';

  @override
  String get onboardingGoalsAddText =>
      'Here you can quickly add a task, a task series, or fill a whole day with several entries.';

  @override
  String get onboardingReportsPeriodTitle => 'Analysis period';

  @override
  String get onboardingReportsPeriodText =>
      'Switch between day, week, and month to compare goals, mood, habits, and finances over time.';

  @override
  String get onboardingReportsChartTitle => 'Interactive charts';

  @override
  String get onboardingReportsChartText =>
      'Tap chart segments and points — the app will show details for the selected element only.';

  @override
  String get onboardingUserGoalsHeaderTitle => 'Big goals';

  @override
  String get onboardingUserGoalsHeaderText =>
      'This is where strategic goals are stored: short-term, mid-term, and long-term. Later, you can link daily tasks to them.';

  @override
  String get onboardingUserGoalsFiltersTitle => 'Goal filters';

  @override
  String get onboardingUserGoalsFiltersText =>
      'Filter goals by life area and horizon to quickly focus on the direction you need.';

  @override
  String get onboardingUserGoalsAddTitle => 'Create a big goal';

  @override
  String get onboardingUserGoalsAddText =>
      'Tap here to add a goal, choose a life area, horizon, and deadline.';

  @override
  String get onboardingProfileHeaderTitle => 'Profile';

  @override
  String get onboardingProfileHeaderText =>
      'This is the center for personal Ladna settings: account, focus, habits, and app preferences.';

  @override
  String get onboardingProfileCardTitle => 'Personal data';

  @override
  String get onboardingProfileCardText =>
      'Name, age, and basic parameters are used to personalize the interface and future AI recommendations.';

  @override
  String get onboardingProfileFocusTitle => 'Focus and settings';

  @override
  String get onboardingProfileFocusText =>
      'These parameters influence day planning, analytics, and recommendations in the app.';

  @override
  String get onboardingBudgetIncomeTitle => 'Income categories';

  @override
  String get onboardingBudgetIncomeText =>
      'Add income sources so financial analytics can understand the structure of your inflows.';

  @override
  String get onboardingBudgetExpenseTitle => 'Expense categories';

  @override
  String get onboardingBudgetExpenseText =>
      'Set up expense categories and limits here. This helps you see where your budget is going fastest.';

  @override
  String get onboardingBudgetJarsTitle => 'Jars and allocation';

  @override
  String get onboardingBudgetJarsText =>
      'Use jars for savings goals: travel, emergency fund, investments, or large purchases.';

  @override
  String get onboardingBudgetSaveTitle => 'Save settings';

  @override
  String get onboardingBudgetSaveText =>
      'After making changes, don’t forget to save your budget so categories and limits are stored in the database.';

  @override
  String get onboardingDayGoalsSummaryTitle => 'Day summary';

  @override
  String get onboardingDayGoalsSummaryText =>
      'This card shows your day progress: how many tasks are done, what remains, and how much time is still planned.';

  @override
  String get onboardingDayGoalsFilterTitle => 'Hide completed';

  @override
  String get onboardingDayGoalsFilterText =>
      'Turn on this filter to keep only active tasks on the screen.';

  @override
  String get onboardingDayGoalsFabTitle => 'Add activity';

  @override
  String get onboardingDayGoalsFabText =>
      'Use this button to add a task, recognize a journal entry, or sync Google Calendar.';

  @override
  String get onboardingQuestionnaireProgressTitle => 'Setup progress';

  @override
  String get onboardingQuestionnaireProgressText =>
      'Here you can see which step of the initial setup you’re currently on.';

  @override
  String get onboardingQuestionnaireNextTitle => 'Move forward';

  @override
  String get onboardingQuestionnaireNextText =>
      'After completing the current step, tap here. At the end, Ladna will save your profile, life areas, and goals.';

  @override
  String get onboardingExpensesControlsTitle => 'Day and budget settings';

  @override
  String get onboardingExpensesControlsText =>
      'Choose the operation date here and open settings for categories, limits, and jars.';

  @override
  String get onboardingExpensesSummaryTitle => 'Monthly finance summary';

  @override
  String get onboardingExpensesSummaryText =>
      'This card shows monthly income, expenses, and free balance — the foundation for budget analysis.';

  @override
  String get onboardingExpensesTransactionsTitle =>
      'Transactions for the selected day';

  @override
  String get onboardingExpensesTransactionsText =>
      'Here you can see income and expenses for the day. Tap a transaction to edit it, or swipe left to delete it.';

  @override
  String get onboardingExpensesFabTitle => 'Add income or expense';

  @override
  String get onboardingExpensesFabText =>
      'Tap plus to open the menu and quickly add a new financial transaction.';

  @override
  String get onboardingNextHint => 'Tap the screen to continue';

  @override
  String get registerLegalTermsTitle => 'Terms of Use';

  @override
  String get registerLegalPrivacyPrefix =>
      'I agree to the processing of my personal data under the';

  @override
  String get registerLegalTermsPrefix => 'I agree to the';

  @override
  String get registerLegalOptionalLinksPrefix => 'Also available:';

  @override
  String get registerLegalPrivacyTitle => 'Privacy Policy';

  @override
  String get registerLegalDatenschutzTitle => 'Datenschutzerklärung';

  @override
  String get registerLegalImpressumTitle => 'Impressum';

  @override
  String registerLegalOptionalTitle(Object title) {
    return '$title · optional';
  }

  @override
  String get registerErrOpenRequiredLegalDocs =>
      'Please open and read Terms of Use and Privacy Policy first.';

  @override
  String registerLegalOpenFailed(Object document) {
    return 'Could not open $document.';
  }

  @override
  String get registerLegalAcceptedText =>
      'I have read and accept the Terms of Use and Privacy Policy.';

  @override
  String get registerLegalOpenRequiredDocsText =>
      'Open and read Terms of Use and Privacy Policy first. Datenschutzerklärung and Impressum are available as additional legal information.';

  @override
  String get launcherDayGoals => 'Goals';

  @override
  String launcherPlannedHoursDescription(Object hours) {
    return 'Plan: $hours h';
  }

  @override
  String get profileGdprSection => 'Privacy & GDPR';

  @override
  String get profileGdprExportTitle => 'Export my data';

  @override
  String get profileGdprExportSubtitle =>
      'Creates a JSON export of all app data linked to your account.';

  @override
  String get profileGdprNotSignedInToast =>
      'You are not signed in. Data export is not possible.';

  @override
  String get profileGdprDialogTitle => 'GDPR data export created';

  @override
  String profileGdprDialogFileName(String fileName) {
    return 'File name: $fileName';
  }

  @override
  String get profileGdprDialogBody =>
      'The export was created as JSON and copied to your clipboard.\n\nYou can now paste the content into a file ending with .json.';

  @override
  String get profileGdprDialogPreviewLabel => 'Preview:';

  @override
  String get profileGdprCopyButton => 'Copy';

  @override
  String get profileGdprDoneButton => 'Done';

  @override
  String get profileGdprCopiedAgainToast =>
      'Data export was copied to the clipboard again.';

  @override
  String get profileGdprCreatedToast =>
      'GDPR data export was created and copied.';

  @override
  String profileGdprFailedToast(String error) {
    return 'Data export failed: $error';
  }

  @override
  String get profileGdprExportNoteAccount =>
      'This export contains the authenticated user account, the public.users profile row, all user-scoped app tables, and reference tables required to understand exported answers.';

  @override
  String get profileGdprExportNoteRls =>
      'The export is limited by Supabase Row Level Security. Tables that do not exist or are not readable are returned with an _export_warning entry.';

  @override
  String get profileGdprExportNoteEncrypted =>
      'Encrypted payload fields are exported as stored. Decryption depends on the app encryption implementation and the active user session.';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get profileFallbackName => 'User';

  @override
  String get profileNoEmail => 'No email';

  @override
  String get personalData => 'Personal data';

  @override
  String get name => 'Name';

  @override
  String get enterName => 'Enter name';

  @override
  String get age => 'Age';

  @override
  String get enterAge => 'Enter age';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get lifeSpheres => 'Life spheres';

  @override
  String get mySpheres => 'My spheres';

  @override
  String get edit => 'Edit';

  @override
  String get habits => 'Habits';

  @override
  String get myHabits => 'My habits';

  @override
  String get noHabitsYet => 'No habits yet';

  @override
  String get addHabitHint =>
      'Habit creation remains in the current habit editor.';

  @override
  String daysCount(int n) {
    return '$n days';
  }

  @override
  String get focus => 'Focus';

  @override
  String get targetHoursTitle => 'Daily target hours';

  @override
  String get targetHoursSubtitle => 'Used to calculate progress';

  @override
  String get targetHoursField => 'Hours per day';

  @override
  String get hoursShort => 'h';

  @override
  String get notifications => 'Notifications';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get notificationsSubtitle => 'Works while the tab is open';

  @override
  String get eveningCheckIn => 'Evening check-in';

  @override
  String get eveningCheckInBody => 'Log your mood and close the day calmly.';

  @override
  String everyDayAt(String time) {
    return 'Every day at $time';
  }

  @override
  String get notificationsUnsupported =>
      'Notifications are not supported here.';

  @override
  String get notificationsEnabled => 'Notifications enabled.';

  @override
  String get notificationsDenied => 'Notification permission was not granted.';

  @override
  String get notificationsMasterSubtitleOn => 'Enabled';

  @override
  String get notificationsMasterSubtitleOff => 'Disabled';

  @override
  String get notificationsSystemDisabledHint =>
      'Disabled in iOS system settings';

  @override
  String get openSystemSettings => 'Open iOS Settings';

  @override
  String get notificationsGoalsTitle => 'Goal reminders';

  @override
  String notificationsGoalsSubtitle(int minutes) {
    return '$minutes min before start';
  }

  @override
  String get notificationsReflectionTitle => 'Evening reflection';

  @override
  String get notificationsHabitsTitle => 'Habit reminders';

  @override
  String get notificationsMinutesPickerTitle => 'How many minutes before';

  @override
  String get app => 'App';

  @override
  String get language => 'Language';

  @override
  String get system => 'System';

  @override
  String get googleCalendarSubtitle => 'Export goals to calendar';

  @override
  String get googleCalendarMovedHint =>
      'Google Calendar is now in profile settings.';

  @override
  String get exportData => 'Export data';

  @override
  String get exportDataSubtitle => 'JSON export of your account';

  @override
  String get exportCopied => 'Export copied to clipboard.';

  @override
  String get exportFailed => 'Could not export data';

  @override
  String get notSignedIn => 'User is not signed in.';

  @override
  String get legalDocuments => 'Legal documents';

  @override
  String get openLinkFailed => 'Could not open the link.';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountSubtitle => 'All data will be permanently deleted';

  @override
  String get deleteAccountConfirm =>
      'This cannot be undone. All account data will be permanently deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get desiredBalance => 'Life wheel';

  @override
  String get desiredBalanceHint =>
      'Set up your life wheel for the selected areas. Total cannot exceed 100%.';

  @override
  String get lifeWheelTapHint =>
      'Tap a segment or an area below to set an exact percentage.';

  @override
  String get outOfHundredPercent => 'of 100%';

  @override
  String get percent => 'Percentage';

  @override
  String lifeWheelPercentLimit(int maxAllowed) {
    return 'You can enter 0 to $maxAllowed%. The total balance cannot exceed 100%.';
  }

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving…';

  @override
  String get newHabit => 'New habit';

  @override
  String get editHabit => 'Edit habit';

  @override
  String get habitName => 'Habit name';

  @override
  String get negativeHabit => 'Negative habit';

  @override
  String get deleteHabit => 'Delete habit?';

  @override
  String deleteHabitQuestion(String title) {
    return 'Habit \"$title\" will be deleted.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get spaces => 'Spaces';

  @override
  String get space => 'Space';

  @override
  String get mySpaces => 'My spaces';

  @override
  String get spacesHint =>
      'Create shared spaces for home, family, trips, and projects.';

  @override
  String get noSpacesYet => 'No spaces yet';

  @override
  String get noSpacesHint => 'Create your first space and invite other users.';

  @override
  String get createSpace => 'Create space';

  @override
  String get editSpace => 'Edit space';

  @override
  String get deleteSpace => 'Delete space';

  @override
  String get leaveSpace => 'Leave space';

  @override
  String get deleteSpaceConfirm =>
      'This space and its shared data will be deleted. This cannot be undone.';

  @override
  String get leaveSpaceConfirm =>
      'You will no longer see tasks and data from this space.';

  @override
  String get spaceName => 'Space name';

  @override
  String get spaceNameRequired => 'Enter a space name';

  @override
  String get spaceDescription => 'Description';

  @override
  String get spaceIcon => 'Icon';

  @override
  String get spaceColor => 'HEX color';

  @override
  String get spaceValidity => 'Validity';

  @override
  String get noDeadline => 'No deadline';

  @override
  String get spaceNoDeadline => 'No expiration date';

  @override
  String get setDeadline => 'Set date';

  @override
  String get changeDeadline => 'Change date';

  @override
  String spaceValidUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get spaceValidityHint =>
      'After this date, the space stays in the database but disappears from screens and task selection.';

  @override
  String get spaceTapToManage => 'Tap to manage members';

  @override
  String get spaceManageSubtitle => 'Members and invites';

  @override
  String get members => 'Members';

  @override
  String get noMembersYet => 'No members yet';

  @override
  String get inviteMember => 'Invite';

  @override
  String inviteMemberHint(String spaceName) {
    return 'The invite will be sent for “$spaceName”.';
  }

  @override
  String get email => 'Email';

  @override
  String get sendInvite => 'Send';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get incomingInvites => 'Incoming invites';

  @override
  String get spaceInviteSubtitle => 'You were invited to a shared space';

  @override
  String get acceptInvite => 'Accept';

  @override
  String get declineInvite => 'Decline';

  @override
  String get spaceInviteAccepted => 'Invite accepted.';

  @override
  String get spaceInviteSent => 'Invite sent.';

  @override
  String get you => 'You';

  @override
  String get spaceRoleOwner => 'Owner';

  @override
  String get spaceRoleAdmin => 'Admin';

  @override
  String get spaceRoleMember => 'Member';

  @override
  String get spaceRoleViewer => 'Viewer';

  @override
  String get spacesLoadFailed => 'Could not load spaces';

  @override
  String get spaceMembersLoadFailed => 'Could not load members';

  @override
  String get spaceSaveFailed => 'Could not save space';

  @override
  String get spaceActionFailed => 'Could not complete the action';

  @override
  String get spaceInviteSendFailed => 'Could not send invite';

  @override
  String get spaceInviteAcceptFailed => 'Could not accept invite';

  @override
  String get spaceInviteDeclineFailed => 'Could not decline invite';

  @override
  String get noData => 'No data';

  @override
  String get dayGoalsHeaderTitle => 'Daily tasks';

  @override
  String get dayGoalsAllHiddenHint =>
      'All visible tasks are hidden. Turn off “Hide completed”.';

  @override
  String get dayGoalsEmptyHint =>
      'No tasks for this day yet. Add the first task with the button below.';

  @override
  String get dayGoalsStatTotal => 'Total';

  @override
  String get dayGoalsStatDone => 'Done';

  @override
  String get dayGoalsStatLeft => 'Left';

  @override
  String dayGoalsHoursLeftLabel(String hours) {
    return 'Hours left: $hours';
  }

  @override
  String get dayGoalsFilterAll => 'All';

  @override
  String get dayGoalsFilterPersonal => 'Personal';

  @override
  String get dayGoalsFilterAllSpheres => 'All areas';

  @override
  String dayGoalsLaneLeftBadge(int count) {
    return 'Left $count';
  }

  @override
  String dayGoalsLaneDoneBadge(int count) {
    return 'Done $count';
  }

  @override
  String get dayGoalsLaneInProgress => '⚡ In progress';

  @override
  String get dayGoalsLaneInProgressEmpty =>
      'Active tasks for this block will appear here';

  @override
  String get dayGoalsLaneDoneTitle => '✅ Done';

  @override
  String get dayGoalsLaneDoneEmpty =>
      'Completed tasks will appear here after a focus block';

  @override
  String get dayGoalsSpaceMetaLabel => '👥 Space';

  @override
  String get dayGoalsCompletedLabel => 'Completed';

  @override
  String get dayGoalsNotifSoftAskTitle => 'Never miss a goal';

  @override
  String get dayGoalsNotifSoftAskBody =>
      'Ladna will remind you 15 minutes before a goal starts — like an alarm, but for your tasks.';

  @override
  String get dayGoalsNotifSoftAskEnable => 'Enable reminders';

  @override
  String get dayGoalsNotifSoftAskDismiss => 'Not now';

  @override
  String get dayGoalsPeriodMorning => 'Morning';

  @override
  String get dayGoalsPeriodDay => 'Day';

  @override
  String get dayGoalsPeriodEvening => 'Evening';

  @override
  String get dayGoalsSphereLifePersonal => 'Personal';

  @override
  String get dayGoalsSphereTravel => 'Travel';

  @override
  String get dayGoalsSphereHome => 'Home';

  @override
  String dayGoalsMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get registerErrNameMin2 => 'Name must be at least 2 characters.';

  @override
  String launcherPlanHours(String hours) {
    return 'Plan: $hours h';
  }

  @override
  String get launcherGoalsAndTasks => 'Goals & tasks';

  @override
  String get launcherPersonal => 'Personal';

  @override
  String get launcherReportsTab => 'Reports';

  @override
  String get launcherBudget => 'Budget';

  @override
  String get launcherQuickActions => 'Quick actions';

  @override
  String get launcherBulkAdd => 'Bulk add';

  @override
  String get launcherBulkAddSubtitle => 'Expenses + Tasks + Mood';

  @override
  String get launcherAiWeeklyPlan => 'AI weekly plan';

  @override
  String get launcherAiWeeklyPlanSubtitle => 'Goals and progress analysis';

  @override
  String get launcherAiInsights => 'AI insights';

  @override
  String get launcherNavAndActions => 'Navigation and actions';

  @override
  String get navMenu => 'Menu';

  @override
  String get navPersonal => 'Personal';

  @override
  String get lifeBlocksSetupTitle => 'What should we track?';

  @override
  String get lifeBlocksSetupSubtitle =>
      'Choose life areas. Ladna will build your home screen, goals and reports around them.';

  @override
  String get lifeBlocksSetupContinue => 'Continue';

  @override
  String get lifeBlocksSetupHint => 'Choose at least 1 area';

  @override
  String get goalsScreenGoalsAndTasks => 'Goals & Tasks';

  @override
  String get goalsScreenTasks => 'Tasks';

  @override
  String get goalsScreenDashboard => 'Dashboard';

  @override
  String get goalsScreenWeek => 'Week';

  @override
  String get goalsScreenMonth => 'Month';

  @override
  String get goalsScreenCalendar => 'Calendar';

  @override
  String get goalsScreenWeekView => 'Week view';

  @override
  String get goalsScreenMonthView => 'Month days';

  @override
  String get goalsScreenNoTasks => 'No tasks';

  @override
  String get goalsScreenCompleted => 'completed';

  @override
  String get goalsScreenWeekSummary => 'Week summary';

  @override
  String get goalsScreenThisWeek => 'This week';

  @override
  String get goalsScreenTodayShort => 'today';

  @override
  String get goalsScreenAll => 'All';

  @override
  String get goalsScreenPersonalTasks => 'Personal';

  @override
  String get goalsScreenUpToOneMonth => 'Up to 1 mo';

  @override
  String get goalsScreenUpToSixMonths => 'Up to 6 mo';

  @override
  String get goalsScreenYearPlus => 'Year+';

  @override
  String get goalsScreenBySpheres => 'By spheres';

  @override
  String get goalsScreenHide => '';

  @override
  String get goalsScreenProgress => 'Progress';

  @override
  String get goalsScreenAdd => 'Add';

  @override
  String get goalsScreenNoGoalsYet => 'No goals yet';

  @override
  String get goalsScreenNoGoalsYetSub =>
      'Add your first goal with the button below.';

  @override
  String get goalsScreenNewGoal => 'New goal';

  @override
  String get goalsScreenEditGoal => 'Edit goal';

  @override
  String get goalsScreenTitle => 'Title';

  @override
  String get goalsScreenDescription => 'Description';

  @override
  String get goalsScreenSphere => 'Sphere';

  @override
  String get goalsScreenHorizon => 'Horizon';

  @override
  String get goalsScreenDeleteGoal => 'Delete goal';

  @override
  String get goalsScreenDeleteGoalQuestion =>
      'This goal will be deleted. Related daily tasks will stay, but without a big-goal link.';

  @override
  String goalsScreenCompletedTasks(int done, int total) {
    return '$done tasks completed out of $total';
  }

  @override
  String goalsScreenGoalsCount(int n) {
    return '$n goals';
  }

  @override
  String get moodScore1 => 'Very low';

  @override
  String get moodScore2 => 'Low';

  @override
  String get moodScore3 => 'Neutral';

  @override
  String get moodScore4 => 'Good';

  @override
  String get moodScore5 => 'Great';

  @override
  String get moodScaleHint =>
      'Mood scale: 1 means very low, 3 neutral, 5 great.';

  @override
  String get moodHowAreYouTitle => 'How are you today?';

  @override
  String get moodWhatInfluencedLabel => 'What affected your mood?';

  @override
  String get moodRecentEntriesTitle => 'Recent entries';

  @override
  String get moodNoEntriesHint => 'No entries yet. Save today’s mood.';

  @override
  String get moodTodayLabel => 'Today';

  @override
  String get moodSelectedDayLabel => 'Selected day';

  @override
  String get reportsScreenReports => 'Reports';

  @override
  String get reportsScreenDayShort => 'Day';

  @override
  String get reportsScreenWeekShort => 'Week';

  @override
  String get reportsScreenMonthShort => 'Month';

  @override
  String get reportsScreenSummary => 'Summary';

  @override
  String get reportsScreenProgress => 'Progress';

  @override
  String get reportsScreenMood => 'Mood';

  @override
  String get reportsScreenTasksDone => 'Tasks done';

  @override
  String get reportsScreenFocusHours => 'Focus hours';

  @override
  String get reportsScreenOutOf => 'of';

  @override
  String get reportsScreenPeriodAverage => 'Period average';

  @override
  String get reportsScreenMoodAverage => 'Average mood';

  @override
  String get reportsScreenOutOfFiveAverage => 'out of 5 average';

  @override
  String get reportsScreenOutOfFive => 'out of 5';

  @override
  String get reportsScreenHowMoodScoreWorks => 'How mood is calculated';

  @override
  String get reportsScreenMoodScoreExplanation =>
      'The user chooses one of 5 moods. Each icon has a score: 1 very low, 2 low, 3 neutral, 4 good, 5 great. Reports show the average for the selected period.';

  @override
  String get reportsScreenMoodVeryLow => 'Very low';

  @override
  String get reportsScreenMoodLow => 'Low';

  @override
  String get reportsScreenMoodNeutral => 'Neutral';

  @override
  String get reportsScreenMoodGood => 'Good';

  @override
  String get reportsScreenMoodGreat => 'Great';

  @override
  String get reportsScreenPeriodEfficiency => 'Period efficiency';

  @override
  String get reportsScreenPlan => 'Plan';

  @override
  String get reportsScreenFact => 'Actual';

  @override
  String get reportsScreenTimeBySphere => 'Time by spheres';

  @override
  String get reportsScreenTopProductiveDays => 'Top 3 productive days';

  @override
  String get reportsScreenAiObservation => 'AI observation';

  @override
  String get reportsScreenPeriodStatistics => 'Period statistics';

  @override
  String get reportsScreenExtendedAiObservationSchedule =>
      'This is your statistics for the period. The extended AI observation will update on Sunday.';

  @override
  String get reportsScreenAiLoading => 'Preparing your personal observation…';

  @override
  String get reportsScreenAiUnavailable =>
      'AI observation is currently unavailable. Check the function connection or try again later.';

  @override
  String get reportsScreenInsight => 'Insight';

  @override
  String get reportsScreenPattern => 'Pattern';

  @override
  String get reportsScreenPeriodTasks => 'Period tasks';

  @override
  String get reportsScreenDone => 'done';

  @override
  String get reportsScreenPeriodProgress => 'Period progress';

  @override
  String get reportsScreenTempoBelowNorm => 'Pace below target';

  @override
  String get reportsScreenTempoGood => 'Pace is on track';

  @override
  String get reportsScreenDetails => 'Details';

  @override
  String get reportsScreenAvgTimePerTask => 'Avg. time / task';

  @override
  String get reportsScreenDoneOnTime => 'Done on time';

  @override
  String get reportsScreenMoved => 'Moved';

  @override
  String get reportsScreenCompleted => 'Completed';

  @override
  String get reportsScreenForThisPeriod => 'for this period';

  @override
  String get reportsScreenBestStreak => 'Best streak';

  @override
  String get reportsScreenDaysInARow => 'days in a row';

  @override
  String get reportsScreenByHabits => 'By habits';

  @override
  String get reportsScreenStreaksFourWeeks => 'Streaks over 4 weeks';

  @override
  String get reportsScreenFourWeeksAgo => '4 weeks ago';

  @override
  String get reportsScreenMissed => 'missed';

  @override
  String get reportsScreenToday => 'today';

  @override
  String get reportsScreenBestDay => 'Best day';

  @override
  String get reportsScreenWeekDynamics => 'Week dynamics';

  @override
  String get reportsScreenByDays => 'By days';

  @override
  String get reportsScreenOnTime => 'On time';

  @override
  String get reportsScreenTasks => 'Tasks';

  @override
  String get reportsScreenHours => 'Hours';

  @override
  String get reportsScreenCurrentPeriodShort => 'this';

  @override
  String get reportsScreenPreviousPeriodShort => 'prev.';

  @override
  String get reportsScreenCorrelations => 'Correlations';

  @override
  String get reportsScreenStreaks => 'Streaks';

  @override
  String get reportsScreenWeakLink => 'Weak link';

  @override
  String get reportsScreenNoDataYet => 'Not enough data yet';

  @override
  String get reportsScreenPulse => 'PULSE';

  @override
  String get reportsScreenMonthEfficiency => 'Month efficiency';

  @override
  String get reportsScreenFactVsDesiredBalance => 'Actual vs desired balance';

  @override
  String get reportsScreenBalancePlanFactHint =>
      'Plan is the thin marker; actual is the filled bar.';

  @override
  String get reportsScreenBalanceEmptyHint =>
      'Set your desired life balance in Profile — the actual vs plan comparison will appear here.';

  @override
  String get reportsScreenPlanLegend => 'plan';

  @override
  String get reportsScreenFactLegend => 'actual';

  @override
  String get reportsScreenOverageLegend => 'overage';

  @override
  String get reportsScreenSleepSevenPlus => 'Sleep 7+ hours';

  @override
  String get reportsScreenHabitCompletion => 'Habit completion';

  @override
  String get reportsScreenWeekStart => 'Mon–Tue';

  @override
  String get reportsScreenMoreStableThanWeekend => 'More stable than week end';

  @override
  String get reportsScreenHighLoad => 'High load';

  @override
  String get reportsScreenTaskImpact => 'Task impact';

  @override
  String get reportsScreenDaysWithHabits => 'Days with habits';

  @override
  String get reportsScreenMoodHigher => 'Mood is higher';

  @override
  String get reportsScreenOpenTasks => 'Open tasks';

  @override
  String get reportsScreenMoodImpact => 'Mood impact';

  @override
  String get reportsScreenExpensesAboveNorm => 'Expenses above norm';

  @override
  String get reportsScreenNextDayMood => 'Next-day mood';

  @override
  String get reportsScreenComparisonTitleDay => 'This day vs previous day';

  @override
  String get reportsScreenComparisonTitleWeek => 'This week vs last week';

  @override
  String get reportsScreenComparisonTitleMonth => 'This month vs last month';

  @override
  String reportsScreenBestDaySubtitle(int tasks, String hours) {
    return '$tasks tasks · $hours h focus';
  }

  @override
  String reportsScreenMonthEfficiencySubtitle(
    int completed,
    String outOf,
    int total,
    int daysLeft,
  ) {
    return '$completed tasks $outOf $total · $daysLeft days left';
  }

  @override
  String reportsScreenWeakLinkRecommendation(String label, int pct) {
    return '$label — $pct% for the period. Attach it to your easiest habit.';
  }

  @override
  String get reportsScreenSummaryInsight =>
      'You are more productive on Tuesday and Wednesday. Move the most important tasks to the start of the week.';

  @override
  String get reportsScreenProgressInsight =>
      'One sphere is postponed more often than others. Try reserving a separate morning block for it.';

  @override
  String get reportsScreenHabitsInsight =>
      'On days when habits are completed, productivity is usually higher. Start with the easiest habit.';

  @override
  String get reportsScreenMoodInsight =>
      'Mood is higher on days with completed habits. Keep a small morning ritual.';

  @override
  String get budgetCategoryNameLabel => 'Name';

  @override
  String get navGoals => 'Goals';

  @override
  String get navMood => 'Mood';

  @override
  String get navProfile => 'Profile';

  @override
  String get navReports => 'Reports';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get goalsDeleteConfirmBodyShort => 'This will be permanently deleted.';

  @override
  String get paywallTitle => 'Ladna Premium';

  @override
  String get paywallSubtitle =>
      'First 30 days free, then a subscription. Cancel anytime.';

  @override
  String get paywallOpenButton => 'Start free trial';

  @override
  String get paywallRestoreButton => 'Restore purchases';

  @override
  String get paywallLogoutButton => 'Log out';
}
