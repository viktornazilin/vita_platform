// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nest App';

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
  String get dayGoalsFabAddTitle => 'Add goal';

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
  String get launcherGoals => 'Goals';

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
  String get homeTitleApp => 'MyNEST';

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
  String get onbPriorityFamily => 'Family';

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
  String get mentalWeekNoAnswers =>
      'No answers found for this week (for the current user_id).';

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
  String get lifeBlockFamily => 'Family';

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
}
