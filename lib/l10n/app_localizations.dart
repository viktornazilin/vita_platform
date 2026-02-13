import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nest App'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @budgetSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget & jars'**
  String get budgetSetupTitle;

  /// No description provided for @budgetSetupSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get budgetSetupSaved;

  /// No description provided for @budgetSetupSaveError.
  ///
  /// In en, this message translates to:
  /// **'Save error'**
  String get budgetSetupSaveError;

  /// No description provided for @budgetIncomeCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Income categories'**
  String get budgetIncomeCategoriesTitle;

  /// No description provided for @budgetIncomeCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used when adding income'**
  String get budgetIncomeCategoriesSubtitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language. “System” uses your device language.'**
  String get settingsLanguageSubtitle;

  /// No description provided for @budgetExpenseCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense categories'**
  String get budgetExpenseCategoriesTitle;

  /// No description provided for @budgetExpenseCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Limits help you keep spending under control'**
  String get budgetExpenseCategoriesSubtitle;

  /// No description provided for @budgetJarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings jars'**
  String get budgetJarsTitle;

  /// No description provided for @budgetJarsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Percent is a share of free funds that is added automatically'**
  String get budgetJarsSubtitle;

  /// No description provided for @loginOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get loginOr;

  /// No description provided for @registerLegalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By registering you accept '**
  String get registerLegalPrefix;

  /// No description provided for @registerLegalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get registerLegalTerms;

  /// No description provided for @registerLegalMiddle.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get registerLegalMiddle;

  /// No description provided for @registerLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get registerLegalPrivacy;

  /// No description provided for @registerLegalSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get registerLegalSuffix;

  /// No description provided for @budgetNewIncomeCategory.
  ///
  /// In en, this message translates to:
  /// **'New income category'**
  String get budgetNewIncomeCategory;

  /// No description provided for @budgetNewExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'New expense category'**
  String get budgetNewExpenseCategory;

  /// No description provided for @budgetCategoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get budgetCategoryNameHint;

  /// No description provided for @budgetAddJar.
  ///
  /// In en, this message translates to:
  /// **'Add a jar'**
  String get budgetAddJar;

  /// No description provided for @budgetJarAdded.
  ///
  /// In en, this message translates to:
  /// **'Jar added'**
  String get budgetJarAdded;

  /// No description provided for @budgetJarAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add: {error}'**
  String budgetJarAddFailed(Object error);

  /// No description provided for @budgetJarDeleted.
  ///
  /// In en, this message translates to:
  /// **'Jar deleted'**
  String get budgetJarDeleted;

  /// No description provided for @budgetJarDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete: {error}'**
  String budgetJarDeleteFailed(Object error);

  /// No description provided for @budgetNoJarsTitle.
  ///
  /// In en, this message translates to:
  /// **'No jars yet'**
  String get budgetNoJarsTitle;

  /// No description provided for @budgetNoJarsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first savings goal — we’ll help you reach it.'**
  String get budgetNoJarsSubtitle;

  /// No description provided for @budgetSetOrChangeLimit.
  ///
  /// In en, this message translates to:
  /// **'Set/change limit'**
  String get budgetSetOrChangeLimit;

  /// No description provided for @budgetDeleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get budgetDeleteCategoryTitle;

  /// No description provided for @budgetCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category: {name}'**
  String budgetCategoryLabel(Object name);

  /// No description provided for @budgetDeleteJarTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete jar?'**
  String get budgetDeleteJarTitle;

  /// No description provided for @budgetJarLabel.
  ///
  /// In en, this message translates to:
  /// **'Jar: {title}'**
  String budgetJarLabel(Object title);

  /// No description provided for @budgetJarSummary.
  ///
  /// In en, this message translates to:
  /// **'Saved: {saved} ₽ • Percent: {percent}%{targetPart}'**
  String budgetJarSummary(Object saved, Object percent, Object targetPart);

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'loading…'**
  String get commonLoading;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get commonSaving;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdate;

  /// No description provided for @commonCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get commonCollapse;

  /// No description provided for @commonDots.
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get commonDots;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get commonChange;

  /// No description provided for @commonDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get commonDate;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get commonDash;

  /// No description provided for @commonPick.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get commonPick;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonCloseTooltip;

  /// No description provided for @commonTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get commonTitle;

  /// No description provided for @commonDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get commonDeleteConfirmTitle;

  /// No description provided for @dayGoalsAllLifeBlocks.
  ///
  /// In en, this message translates to:
  /// **'All areas'**
  String get dayGoalsAllLifeBlocks;

  /// No description provided for @dayGoalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No goals for this day'**
  String get dayGoalsEmpty;

  /// No description provided for @dayGoalsAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add a goal: {error}'**
  String dayGoalsAddFailed(Object error);

  /// No description provided for @dayGoalsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goal updated'**
  String get dayGoalsUpdated;

  /// No description provided for @dayGoalsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update the goal: {error}'**
  String dayGoalsUpdateFailed(Object error);

  /// No description provided for @dayGoalsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Goal deleted'**
  String get dayGoalsDeleted;

  /// No description provided for @dayGoalsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete: {error}'**
  String dayGoalsDeleteFailed(Object error);

  /// No description provided for @dayGoalsToggleFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change status: {error}'**
  String dayGoalsToggleFailed(Object error);

  /// No description provided for @dayGoalsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete goal?'**
  String get dayGoalsDeleteConfirmTitle;

  /// No description provided for @dayGoalsFabAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get dayGoalsFabAddTitle;

  /// No description provided for @dayGoalsFabAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create manually'**
  String get dayGoalsFabAddSubtitle;

  /// No description provided for @dayGoalsFabScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get dayGoalsFabScanTitle;

  /// No description provided for @dayGoalsFabScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Photo of journal'**
  String get dayGoalsFabScanSubtitle;

  /// No description provided for @dayGoalsFabCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar'**
  String get dayGoalsFabCalendarTitle;

  /// No description provided for @dayGoalsFabCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import/export today\'s goals'**
  String get dayGoalsFabCalendarSubtitle;

  /// No description provided for @epicIntroSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get epicIntroSkip;

  /// No description provided for @epicIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A home for thoughts. A place where goals,\ndreams, and plans grow — gently and mindfully.'**
  String get epicIntroSubtitle;

  /// No description provided for @epicIntroPrimaryCta.
  ///
  /// In en, this message translates to:
  /// **'Start my journey'**
  String get epicIntroPrimaryCta;

  /// No description provided for @epicIntroLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get epicIntroLater;

  /// No description provided for @epicIntroSecondaryCta.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get epicIntroSecondaryCta;

  /// No description provided for @epicIntroFooter.
  ///
  /// In en, this message translates to:
  /// **'You can always return to the prologue in Settings.'**
  String get epicIntroFooter;

  /// No description provided for @homeMoodSaved.
  ///
  /// In en, this message translates to:
  /// **'Mood saved'**
  String get homeMoodSaved;

  /// No description provided for @homeMoodSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String homeMoodSaveFailed(Object error);

  /// No description provided for @homeTodayAndWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Today & week'**
  String get homeTodayAndWeekTitle;

  /// No description provided for @homeTodayAndWeekSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick overview — all key metrics are here'**
  String get homeTodayAndWeekSubtitle;

  /// No description provided for @homeMetricMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get homeMetricMoodTitle;

  /// No description provided for @homeMoodNoEntry.
  ///
  /// In en, this message translates to:
  /// **'no entry'**
  String get homeMoodNoEntry;

  /// No description provided for @homeMoodNoNote.
  ///
  /// In en, this message translates to:
  /// **'no note'**
  String get homeMoodNoNote;

  /// No description provided for @homeMoodHasNote.
  ///
  /// In en, this message translates to:
  /// **'has note'**
  String get homeMoodHasNote;

  /// No description provided for @homeMetricTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get homeMetricTasksTitle;

  /// No description provided for @homeMetricHoursPerDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Hours/day'**
  String get homeMetricHoursPerDayTitle;

  /// No description provided for @homeMetricEfficiencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get homeMetricEfficiencyTitle;

  /// No description provided for @homeEfficiencyPlannedHours.
  ///
  /// In en, this message translates to:
  /// **'plan {hours}h'**
  String homeEfficiencyPlannedHours(Object hours);

  /// No description provided for @homeMoodTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood today'**
  String get homeMoodTodayTitle;

  /// No description provided for @homeMoodNoTodayEntry.
  ///
  /// In en, this message translates to:
  /// **'No entry for today'**
  String get homeMoodNoTodayEntry;

  /// No description provided for @homeMoodEntryNoNote.
  ///
  /// In en, this message translates to:
  /// **'Entry exists (no note)'**
  String get homeMoodEntryNoNote;

  /// No description provided for @homeMoodQuickHint.
  ///
  /// In en, this message translates to:
  /// **'Add a quick check-in — it takes 10 seconds'**
  String get homeMoodQuickHint;

  /// No description provided for @homeMoodUpdateHint.
  ///
  /// In en, this message translates to:
  /// **'You can update — it will overwrite today\'s entry'**
  String get homeMoodUpdateHint;

  /// No description provided for @homeMoodNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get homeMoodNoteLabel;

  /// No description provided for @homeMoodNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What influenced your state?'**
  String get homeMoodNoteHint;

  /// No description provided for @homeOpenMoodHistoryCta.
  ///
  /// In en, this message translates to:
  /// **'Open mood history'**
  String get homeOpenMoodHistoryCta;

  /// No description provided for @homeWeekSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Week summary'**
  String get homeWeekSummaryTitle;

  /// No description provided for @homeOpenReportsCta.
  ///
  /// In en, this message translates to:
  /// **'Open detailed reports'**
  String get homeOpenReportsCta;

  /// No description provided for @homeWeekExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Week expenses'**
  String get homeWeekExpensesTitle;

  /// No description provided for @homeNoExpensesThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No expenses this week'**
  String get homeNoExpensesThisWeek;

  /// No description provided for @homeOpenExpensesCta.
  ///
  /// In en, this message translates to:
  /// **'Open expenses'**
  String get homeOpenExpensesCta;

  /// No description provided for @homeExpensesTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {total} €'**
  String homeExpensesTotal(Object total);

  /// No description provided for @homeExpensesAvgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg/day: {avg} €'**
  String homeExpensesAvgPerDay(Object avg);

  /// No description provided for @homeInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get homeInsightsTitle;

  /// No description provided for @homeTopCategory.
  ///
  /// In en, this message translates to:
  /// **'• Top category: {category} — {amount} €'**
  String homeTopCategory(Object category, Object amount);

  /// No description provided for @homePeakExpense.
  ///
  /// In en, this message translates to:
  /// **'• Peak spending: {day} — {amount} €'**
  String homePeakExpense(Object day, Object amount);

  /// No description provided for @homeOpenDetailedExpensesCta.
  ///
  /// In en, this message translates to:
  /// **'Open detailed expenses'**
  String get homeOpenDetailedExpensesCta;

  /// No description provided for @homeWeekCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get homeWeekCardTitle;

  /// No description provided for @homeWeekLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load stats'**
  String get homeWeekLoadFailedTitle;

  /// No description provided for @homeWeekLoadFailedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your internet or try again later.'**
  String get homeWeekLoadFailedSubtitle;

  /// No description provided for @gcalTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar'**
  String get gcalTitle;

  /// No description provided for @gcalHeaderImport.
  ///
  /// In en, this message translates to:
  /// **'Find events in your calendar and import them as goals.'**
  String get gcalHeaderImport;

  /// No description provided for @gcalHeaderExport.
  ///
  /// In en, this message translates to:
  /// **'Pick a period and export goals from the app to Google Calendar.'**
  String get gcalHeaderExport;

  /// No description provided for @gcalModeImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get gcalModeImport;

  /// No description provided for @gcalModeExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get gcalModeExport;

  /// No description provided for @gcalCalendarLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get gcalCalendarLabel;

  /// No description provided for @gcalPrimaryCalendar.
  ///
  /// In en, this message translates to:
  /// **'Primary (default)'**
  String get gcalPrimaryCalendar;

  /// No description provided for @gcalPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get gcalPeriodLabel;

  /// No description provided for @gcalRangeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get gcalRangeToday;

  /// No description provided for @gcalRangeNext7.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get gcalRangeNext7;

  /// No description provided for @gcalRangeNext30.
  ///
  /// In en, this message translates to:
  /// **'Next 30 days'**
  String get gcalRangeNext30;

  /// No description provided for @gcalRangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Choose period...'**
  String get gcalRangeCustom;

  /// No description provided for @gcalDefaultLifeBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'Default life block (for import)'**
  String get gcalDefaultLifeBlockLabel;

  /// No description provided for @gcalLifeBlockForGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Life block for this goal'**
  String get gcalLifeBlockForGoalLabel;

  /// No description provided for @gcalEventsNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Events are not loaded'**
  String get gcalEventsNotLoaded;

  /// No description provided for @gcalConnectToLoadEvents.
  ///
  /// In en, this message translates to:
  /// **'Connect your account to load events'**
  String get gcalConnectToLoadEvents;

  /// No description provided for @gcalExportHint.
  ///
  /// In en, this message translates to:
  /// **'Export will create events in the selected calendar for the chosen period.'**
  String get gcalExportHint;

  /// No description provided for @gcalConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get gcalConnect;

  /// No description provided for @gcalConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get gcalConnected;

  /// No description provided for @gcalFindEvents.
  ///
  /// In en, this message translates to:
  /// **'Find events'**
  String get gcalFindEvents;

  /// No description provided for @gcalImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get gcalImport;

  /// No description provided for @gcalExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get gcalExport;

  /// No description provided for @gcalNoTitle.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get gcalNoTitle;

  /// No description provided for @gcalImportedGoalsCount.
  ///
  /// In en, this message translates to:
  /// **'Imported goals: {count}'**
  String gcalImportedGoalsCount(Object count);

  /// No description provided for @gcalExportedGoalsCount.
  ///
  /// In en, this message translates to:
  /// **'Exported goals: {count}'**
  String gcalExportedGoalsCount(Object count);

  /// No description provided for @launcherQuickFunctionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get launcherQuickFunctionsTitle;

  /// No description provided for @launcherQuickFunctionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation and actions in one tap'**
  String get launcherQuickFunctionsSubtitle;

  /// No description provided for @launcherSectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get launcherSectionsTitle;

  /// No description provided for @launcherQuickTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get launcherQuickTitle;

  /// No description provided for @launcherHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get launcherHome;

  /// No description provided for @launcherGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get launcherGoals;

  /// No description provided for @launcherMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get launcherMood;

  /// No description provided for @launcherProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get launcherProfile;

  /// No description provided for @launcherInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get launcherInsights;

  /// No description provided for @launcherReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get launcherReports;

  /// No description provided for @launcherMassAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk add for the day'**
  String get launcherMassAddTitle;

  /// No description provided for @launcherMassAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses + Goals + Mood'**
  String get launcherMassAddSubtitle;

  /// No description provided for @launcherAiPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'AI plan for week/month'**
  String get launcherAiPlanTitle;

  /// No description provided for @launcherAiPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis of goals, questionnaire and progress'**
  String get launcherAiPlanSubtitle;

  /// No description provided for @launcherAiInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI insights'**
  String get launcherAiInsightsTitle;

  /// No description provided for @launcherAiInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How events affect goals and progress'**
  String get launcherAiInsightsSubtitle;

  /// No description provided for @launcherRecurringGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring goal'**
  String get launcherRecurringGoalTitle;

  /// No description provided for @launcherRecurringGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan ahead for multiple days'**
  String get launcherRecurringGoalSubtitle;

  /// No description provided for @launcherGoogleCalendarSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar sync'**
  String get launcherGoogleCalendarSyncTitle;

  /// No description provided for @launcherGoogleCalendarSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export goals to calendar'**
  String get launcherGoogleCalendarSyncSubtitle;

  /// No description provided for @launcherNoDatesToCreate.
  ///
  /// In en, this message translates to:
  /// **'No dates to create (check deadline/settings).'**
  String get launcherNoDatesToCreate;

  /// No description provided for @launcherCreateSeriesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create a series of goals: {error}'**
  String launcherCreateSeriesFailed(Object error);

  /// No description provided for @launcherSaveError.
  ///
  /// In en, this message translates to:
  /// **'Save error: {error}'**
  String launcherSaveError(Object error);

  /// No description provided for @launcherCreatedGoalsCount.
  ///
  /// In en, this message translates to:
  /// **'Goals created: {count}'**
  String launcherCreatedGoalsCount(Object count);

  /// No description provided for @launcherSavedSummary.
  ///
  /// In en, this message translates to:
  /// **'Saved: {expenses} expense(s), {incomes} income(s), {goals} goal(s), {habits} habit(s){moodPart}'**
  String launcherSavedSummary(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodPart,
  );

  /// No description provided for @homeTitleHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitleHome;

  /// No description provided for @homeTitleGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get homeTitleGoals;

  /// No description provided for @homeTitleMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get homeTitleMood;

  /// No description provided for @homeTitleProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeTitleProfile;

  /// No description provided for @homeTitleReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get homeTitleReports;

  /// No description provided for @homeTitleExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get homeTitleExpenses;

  /// No description provided for @homeTitleApp.
  ///
  /// In en, this message translates to:
  /// **'MyNEST'**
  String get homeTitleApp;

  /// No description provided for @homeSignOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get homeSignOutTooltip;

  /// No description provided for @homeSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get homeSignOutTitle;

  /// No description provided for @homeSignOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your current session will be ended.'**
  String get homeSignOutSubtitle;

  /// No description provided for @homeSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get homeSignOutConfirm;

  /// No description provided for @homeSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign out: {error}'**
  String homeSignOutFailed(Object error);

  /// No description provided for @homeQuickActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActionsTooltip;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// No description provided for @expensesPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get expensesPickDate;

  /// No description provided for @expensesCommitTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lock jar allocation'**
  String get expensesCommitTooltip;

  /// No description provided for @expensesCommitUndoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Undo lock'**
  String get expensesCommitUndoTooltip;

  /// No description provided for @expensesBudgetSettings.
  ///
  /// In en, this message translates to:
  /// **'Budget settings'**
  String get expensesBudgetSettings;

  /// No description provided for @expensesCommitDone.
  ///
  /// In en, this message translates to:
  /// **'Allocation locked'**
  String get expensesCommitDone;

  /// No description provided for @expensesCommitUndone.
  ///
  /// In en, this message translates to:
  /// **'Lock removed'**
  String get expensesCommitUndone;

  /// No description provided for @expensesMonthSummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly summary'**
  String get expensesMonthSummary;

  /// No description provided for @expensesIncomeLegend.
  ///
  /// In en, this message translates to:
  /// **'Income {value} €'**
  String expensesIncomeLegend(Object value);

  /// No description provided for @expensesExpenseLegend.
  ///
  /// In en, this message translates to:
  /// **'Expenses {value} €'**
  String expensesExpenseLegend(Object value);

  /// No description provided for @expensesFreeLegend.
  ///
  /// In en, this message translates to:
  /// **'Free {value} €'**
  String expensesFreeLegend(Object value);

  /// No description provided for @expensesDaySum.
  ///
  /// In en, this message translates to:
  /// **'Day total: {value} €'**
  String expensesDaySum(Object value);

  /// No description provided for @expensesNoTxForDay.
  ///
  /// In en, this message translates to:
  /// **'No transactions for this day'**
  String get expensesNoTxForDay;

  /// No description provided for @expensesDeleteTxTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get expensesDeleteTxTitle;

  /// No description provided for @expensesDeleteTxBody.
  ///
  /// In en, this message translates to:
  /// **'{category} — {amount} €'**
  String expensesDeleteTxBody(Object category, Object amount);

  /// No description provided for @expensesCategoriesMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly expense categories'**
  String get expensesCategoriesMonthTitle;

  /// No description provided for @expensesNoCategoryData.
  ///
  /// In en, this message translates to:
  /// **'No category data yet'**
  String get expensesNoCategoryData;

  /// No description provided for @expensesJarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings jars'**
  String get expensesJarsTitle;

  /// No description provided for @expensesNoJars.
  ///
  /// In en, this message translates to:
  /// **'No jars yet'**
  String get expensesNoJars;

  /// No description provided for @expensesCommitShort.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get expensesCommitShort;

  /// No description provided for @expensesCommitUndoShort.
  ///
  /// In en, this message translates to:
  /// **'Undo lock'**
  String get expensesCommitUndoShort;

  /// No description provided for @expensesAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get expensesAddIncome;

  /// No description provided for @expensesAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expensesAddExpense;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get loginHidePassword;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get loginCreateAccount;

  /// No description provided for @loginBtnSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginBtnSignIn;

  /// No description provided for @loginContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginContinueGoogle;

  /// No description provided for @loginContinueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple ID'**
  String get loginContinueApple;

  /// No description provided for @loginErrEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get loginErrEmailRequired;

  /// No description provided for @loginErrEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get loginErrEmailInvalid;

  /// No description provided for @loginErrPassRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get loginErrPassRequired;

  /// No description provided for @loginErrPassMin6.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get loginErrPassMin6;

  /// No description provided for @loginResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Password recovery'**
  String get loginResetTitle;

  /// No description provided for @loginResetSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get loginResetSend;

  /// No description provided for @loginResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get loginResetSent;

  /// No description provided for @loginResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send email: {error}'**
  String loginResetFailed(Object error);

  /// No description provided for @moodTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get moodTitle;

  /// No description provided for @moodOnePerDay.
  ///
  /// In en, this message translates to:
  /// **'1 entry = 1 day'**
  String get moodOnePerDay;

  /// No description provided for @moodHowDoYouFeel.
  ///
  /// In en, this message translates to:
  /// **'How do you feel?'**
  String get moodHowDoYouFeel;

  /// No description provided for @moodNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get moodNoteLabel;

  /// No description provided for @moodNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What affected your mood?'**
  String get moodNoteHint;

  /// No description provided for @moodSaved.
  ///
  /// In en, this message translates to:
  /// **'Mood saved'**
  String get moodSaved;

  /// No description provided for @moodUpdated.
  ///
  /// In en, this message translates to:
  /// **'Entry updated'**
  String get moodUpdated;

  /// No description provided for @moodHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood history'**
  String get moodHistoryTitle;

  /// No description provided for @moodTapToEdit.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit'**
  String get moodTapToEdit;

  /// No description provided for @moodNoNote.
  ///
  /// In en, this message translates to:
  /// **'No note'**
  String get moodNoNote;

  /// No description provided for @moodEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get moodEditTitle;

  /// No description provided for @moodEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get moodEmptyTitle;

  /// No description provided for @moodEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a date, select mood and save.'**
  String get moodEmptySubtitle;

  /// No description provided for @moodErrSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save mood: {error}'**
  String moodErrSaveFailed(Object error);

  /// No description provided for @moodErrUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update entry: {error}'**
  String moodErrUpdateFailed(Object error);

  /// No description provided for @moodErrDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete entry: {error}'**
  String moodErrDeleteFailed(Object error);

  /// No description provided for @onbTopTitle.
  ///
  /// In en, this message translates to:
  /// **'Hero’s Initiation'**
  String get onbTopTitle;

  /// No description provided for @onbErrSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save your answers'**
  String get onbErrSaveFailed;

  /// No description provided for @onbProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s get to know each other'**
  String get onbProfileTitle;

  /// No description provided for @onbProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps with your profile and personalization'**
  String get onbProfileSubtitle;

  /// No description provided for @onbNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get onbNameLabel;

  /// No description provided for @onbNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Viktor'**
  String get onbNameHint;

  /// No description provided for @onbAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get onbAgeLabel;

  /// No description provided for @onbAgeHint.
  ///
  /// In en, this message translates to:
  /// **'For example: 26'**
  String get onbAgeHint;

  /// No description provided for @onbNameNote.
  ///
  /// In en, this message translates to:
  /// **'You can change your name later in your profile.'**
  String get onbNameNote;

  /// No description provided for @onbBlocksTitle.
  ///
  /// In en, this message translates to:
  /// **'Which life areas do you want to track?'**
  String get onbBlocksTitle;

  /// No description provided for @onbBlocksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This will be the foundation for your goals and quests'**
  String get onbBlocksSubtitle;

  /// No description provided for @onbPrioritiesTitle.
  ///
  /// In en, this message translates to:
  /// **'What matters most to you in the next 3–6 months?'**
  String get onbPrioritiesTitle;

  /// No description provided for @onbPrioritiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up to three — this affects recommendations'**
  String get onbPrioritiesSubtitle;

  /// No description provided for @onbPriorityHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get onbPriorityHealth;

  /// No description provided for @onbPriorityCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get onbPriorityCareer;

  /// No description provided for @onbPriorityMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get onbPriorityMoney;

  /// No description provided for @onbPriorityFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get onbPriorityFamily;

  /// No description provided for @onbPriorityGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get onbPriorityGrowth;

  /// No description provided for @onbPriorityLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get onbPriorityLove;

  /// No description provided for @onbPriorityCreativity.
  ///
  /// In en, this message translates to:
  /// **'Creativity'**
  String get onbPriorityCreativity;

  /// No description provided for @onbPriorityBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get onbPriorityBalance;

  /// No description provided for @onbGoalsBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals in “{block}”'**
  String onbGoalsBlockTitle(Object block);

  /// No description provided for @onbGoalsBlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Focus: tactical → mid-term → long-term'**
  String get onbGoalsBlockSubtitle;

  /// No description provided for @onbGoalLongLabel.
  ///
  /// In en, this message translates to:
  /// **'Long-term goal (6–24 months)'**
  String get onbGoalLongLabel;

  /// No description provided for @onbGoalLongHint.
  ///
  /// In en, this message translates to:
  /// **'For example: reach German level B2'**
  String get onbGoalLongHint;

  /// No description provided for @onbGoalMidLabel.
  ///
  /// In en, this message translates to:
  /// **'Mid-term goal (2–6 months)'**
  String get onbGoalMidLabel;

  /// No description provided for @onbGoalMidHint.
  ///
  /// In en, this message translates to:
  /// **'For example: finish A2→B1 and pass the exam'**
  String get onbGoalMidHint;

  /// No description provided for @onbGoalTacticalLabel.
  ///
  /// In en, this message translates to:
  /// **'Tactical goal (2–4 weeks)'**
  String get onbGoalTacticalLabel;

  /// No description provided for @onbGoalTacticalHint.
  ///
  /// In en, this message translates to:
  /// **'For example: 12×30 min sessions + 2 speaking clubs'**
  String get onbGoalTacticalHint;

  /// No description provided for @onbWhyLabel.
  ///
  /// In en, this message translates to:
  /// **'Why is this important? (optional)'**
  String get onbWhyLabel;

  /// No description provided for @onbWhyHint.
  ///
  /// In en, this message translates to:
  /// **'Motivation/meaning — helps you stay on track'**
  String get onbWhyHint;

  /// No description provided for @onbOptionalNote.
  ///
  /// In en, this message translates to:
  /// **'You can leave it empty and tap “Next”.'**
  String get onbOptionalNote;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get registerTitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get registerNameLabel;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get registerShowPassword;

  /// No description provided for @registerHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get registerHidePassword;

  /// No description provided for @registerBtnSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerBtnSignUp;

  /// No description provided for @registerContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get registerContinueGoogle;

  /// No description provided for @registerContinueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple ID'**
  String get registerContinueApple;

  /// No description provided for @registerContinueAppleIos.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple ID (iOS)'**
  String get registerContinueAppleIos;

  /// No description provided for @registerHaveAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get registerHaveAccountCta;

  /// No description provided for @registerErrNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get registerErrNameRequired;

  /// No description provided for @registerErrEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get registerErrEmailRequired;

  /// No description provided for @registerErrEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get registerErrEmailInvalid;

  /// No description provided for @registerErrPassRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get registerErrPassRequired;

  /// No description provided for @registerErrPassMin8.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get registerErrPassMin8;

  /// No description provided for @registerErrPassNeedLower.
  ///
  /// In en, this message translates to:
  /// **'Add a lowercase letter (a-z)'**
  String get registerErrPassNeedLower;

  /// No description provided for @registerErrPassNeedUpper.
  ///
  /// In en, this message translates to:
  /// **'Add an uppercase letter (A-Z)'**
  String get registerErrPassNeedUpper;

  /// No description provided for @registerErrPassNeedDigit.
  ///
  /// In en, this message translates to:
  /// **'Add a digit (0-9)'**
  String get registerErrPassNeedDigit;

  /// No description provided for @registerErrConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Repeat the password'**
  String get registerErrConfirmRequired;

  /// No description provided for @registerErrPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerErrPasswordsMismatch;

  /// No description provided for @registerErrAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'You need to accept the Terms and Privacy Policy'**
  String get registerErrAcceptTerms;

  /// No description provided for @registerAppleOnlyIos.
  ///
  /// In en, this message translates to:
  /// **'Apple ID is available on iPhone/iPad (iOS only)'**
  String get registerAppleOnlyIos;

  /// No description provided for @welcomeAppName.
  ///
  /// In en, this message translates to:
  /// **'VitaPlatform'**
  String get welcomeAppName;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your goals, mood, and time\n— all in one place'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get welcomeSignIn;

  /// No description provided for @welcomeCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get welcomeCreateAccount;

  /// No description provided for @habitsWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitsWeekTitle;

  /// No description provided for @habitsWeekTopTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits (top this week)'**
  String get habitsWeekTopTitle;

  /// No description provided for @habitsWeekEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add at least one habit — your progress will appear here.'**
  String get habitsWeekEmptyHint;

  /// No description provided for @habitsWeekFooterHint.
  ///
  /// In en, this message translates to:
  /// **'We show your most active habits over the last 7 days.'**
  String get habitsWeekFooterHint;

  /// No description provided for @mentalWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Mental health'**
  String get mentalWeekTitle;

  /// No description provided for @mentalWeekLoadError.
  ///
  /// In en, this message translates to:
  /// **'Load error: {error}'**
  String mentalWeekLoadError(Object error);

  /// No description provided for @mentalWeekNoAnswers.
  ///
  /// In en, this message translates to:
  /// **'No answers found for this week (for the current user_id).'**
  String get mentalWeekNoAnswers;

  /// No description provided for @mentalWeekYesNoHeader.
  ///
  /// In en, this message translates to:
  /// **'Yes/No (week)'**
  String get mentalWeekYesNoHeader;

  /// No description provided for @mentalWeekScalesHeader.
  ///
  /// In en, this message translates to:
  /// **'Scales (trend)'**
  String get mentalWeekScalesHeader;

  /// No description provided for @mentalWeekFooterHint.
  ///
  /// In en, this message translates to:
  /// **'We only show a few questions to keep the screen clean.'**
  String get mentalWeekFooterHint;

  /// No description provided for @mentalWeekNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get mentalWeekNoData;

  /// No description provided for @mentalWeekYesCount.
  ///
  /// In en, this message translates to:
  /// **'Yes: {yes}/{total}'**
  String mentalWeekYesCount(Object yes, Object total);

  /// No description provided for @moodWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly mood'**
  String get moodWeekTitle;

  /// No description provided for @moodWeekMarkedCount.
  ///
  /// In en, this message translates to:
  /// **'Logged: {filled}/{total}'**
  String moodWeekMarkedCount(Object filled, Object total);

  /// No description provided for @moodWeekAverageDash.
  ///
  /// In en, this message translates to:
  /// **'Average: —'**
  String get moodWeekAverageDash;

  /// No description provided for @moodWeekAverageValue.
  ///
  /// In en, this message translates to:
  /// **'Average: {avg}/5'**
  String moodWeekAverageValue(Object avg);

  /// No description provided for @moodWeekFooterHint.
  ///
  /// In en, this message translates to:
  /// **'This is a quick overview. Details are below in the history.'**
  String get moodWeekFooterHint;

  /// No description provided for @goalsByBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals by area'**
  String get goalsByBlockTitle;

  /// No description provided for @goalsAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get goalsAddTooltip;

  /// No description provided for @goalsHorizonTacticalShort.
  ///
  /// In en, this message translates to:
  /// **'Tactical'**
  String get goalsHorizonTacticalShort;

  /// No description provided for @goalsHorizonMidShort.
  ///
  /// In en, this message translates to:
  /// **'Mid-term'**
  String get goalsHorizonMidShort;

  /// No description provided for @goalsHorizonLongShort.
  ///
  /// In en, this message translates to:
  /// **'Long-term'**
  String get goalsHorizonLongShort;

  /// No description provided for @goalsHorizonTacticalLong.
  ///
  /// In en, this message translates to:
  /// **'2–6 weeks'**
  String get goalsHorizonTacticalLong;

  /// No description provided for @goalsHorizonMidLong.
  ///
  /// In en, this message translates to:
  /// **'3–6 months'**
  String get goalsHorizonMidLong;

  /// No description provided for @goalsHorizonLongLong.
  ///
  /// In en, this message translates to:
  /// **'1+ year'**
  String get goalsHorizonLongLong;

  /// No description provided for @goalsEditorNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get goalsEditorNewTitle;

  /// No description provided for @goalsEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get goalsEditorEditTitle;

  /// No description provided for @goalsEditorLifeBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get goalsEditorLifeBlockLabel;

  /// No description provided for @goalsEditorHorizonLabel.
  ///
  /// In en, this message translates to:
  /// **'Horizon'**
  String get goalsEditorHorizonLabel;

  /// No description provided for @goalsEditorTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get goalsEditorTitleLabel;

  /// No description provided for @goalsEditorTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Improve English to B2'**
  String get goalsEditorTitleHint;

  /// No description provided for @goalsEditorDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get goalsEditorDescLabel;

  /// No description provided for @goalsEditorDescHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly: what exactly, and how we measure success'**
  String get goalsEditorDescHint;

  /// No description provided for @goalsEditorDeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline: {date}'**
  String goalsEditorDeadlineLabel(Object date);

  /// No description provided for @goalsDeadlineInline.
  ///
  /// In en, this message translates to:
  /// **'Deadline: {date}'**
  String goalsDeadlineInline(Object date);

  /// No description provided for @goalsEmptyAllHint.
  ///
  /// In en, this message translates to:
  /// **'No goals yet. Add your first goal for the selected areas.'**
  String get goalsEmptyAllHint;

  /// No description provided for @goalsNoBlocksToShow.
  ///
  /// In en, this message translates to:
  /// **'No available areas to display.'**
  String get goalsNoBlocksToShow;

  /// No description provided for @goalsNoGoalsForBlock.
  ///
  /// In en, this message translates to:
  /// **'No goals for the selected area.'**
  String get goalsNoGoalsForBlock;

  /// No description provided for @goalsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete goal?'**
  String get goalsDeleteConfirmTitle;

  /// No description provided for @goalsDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be deleted and cannot be restored.'**
  String goalsDeleteConfirmBody(Object title);

  /// No description provided for @habitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitsTitle;

  /// No description provided for @habitsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Add your first one.'**
  String get habitsEmptyHint;

  /// No description provided for @habitsEditorNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get habitsEditorNewTitle;

  /// No description provided for @habitsEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get habitsEditorEditTitle;

  /// No description provided for @habitsEditorTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get habitsEditorTitleLabel;

  /// No description provided for @habitsEditorTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning workout'**
  String get habitsEditorTitleHint;

  /// No description provided for @habitsNegativeLabel.
  ///
  /// In en, this message translates to:
  /// **'Negative habit'**
  String get habitsNegativeLabel;

  /// No description provided for @habitsNegativeHint.
  ///
  /// In en, this message translates to:
  /// **'Mark it if you want to track and reduce it.'**
  String get habitsNegativeHint;

  /// No description provided for @habitsPositiveHint.
  ///
  /// In en, this message translates to:
  /// **'A positive/neutral habit to reinforce.'**
  String get habitsPositiveHint;

  /// No description provided for @habitsNegativeShort.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get habitsNegativeShort;

  /// No description provided for @habitsPositiveShort.
  ///
  /// In en, this message translates to:
  /// **'Positive/neutral'**
  String get habitsPositiveShort;

  /// No description provided for @habitsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete habit?'**
  String get habitsDeleteConfirmTitle;

  /// No description provided for @habitsDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be deleted and cannot be restored.'**
  String habitsDeleteConfirmBody(Object title);

  /// No description provided for @habitsFooterHint.
  ///
  /// In en, this message translates to:
  /// **'Later we’ll add habit “filtering” on the home screen.'**
  String get habitsFooterHint;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameTitle;

  /// No description provided for @profileNamePrompt.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get profileNamePrompt;

  /// No description provided for @profileAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAgeLabel;

  /// No description provided for @profileAgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAgeTitle;

  /// No description provided for @profileAgePrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your age'**
  String get profileAgePrompt;

  /// No description provided for @profileAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccountSection;

  /// No description provided for @profileSeenPrologueTitle.
  ///
  /// In en, this message translates to:
  /// **'Prologue completed'**
  String get profileSeenPrologueTitle;

  /// No description provided for @profileSeenPrologueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this manually'**
  String get profileSeenPrologueSubtitle;

  /// No description provided for @profileFocusSection.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get profileFocusSection;

  /// No description provided for @profileTargetHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Target hours per day'**
  String get profileTargetHoursLabel;

  /// No description provided for @profileTargetHoursValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String profileTargetHoursValue(Object hours);

  /// No description provided for @profileTargetHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily hours target'**
  String get profileTargetHoursTitle;

  /// No description provided for @profileTargetHoursFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get profileTargetHoursFieldLabel;

  /// No description provided for @profileQuestionnaireSection.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire & life areas'**
  String get profileQuestionnaireSection;

  /// No description provided for @profileQuestionnaireNotDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t completed the questionnaire yet.'**
  String get profileQuestionnaireNotDoneTitle;

  /// No description provided for @profileQuestionnaireCta.
  ///
  /// In en, this message translates to:
  /// **'Complete now'**
  String get profileQuestionnaireCta;

  /// No description provided for @profileLifeBlocksTitle.
  ///
  /// In en, this message translates to:
  /// **'Life areas'**
  String get profileLifeBlocksTitle;

  /// No description provided for @profileLifeBlocksHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. health, career, family'**
  String get profileLifeBlocksHint;

  /// No description provided for @profilePrioritiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Priorities'**
  String get profilePrioritiesTitle;

  /// No description provided for @profilePrioritiesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. sport, finance, reading'**
  String get profilePrioritiesHint;

  /// No description provided for @profileDangerZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get profileDangerZoneTitle;

  /// No description provided for @profileDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get profileDeleteAccountTitle;

  /// No description provided for @profileDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible.\nThe following will be deleted: goals, habits, mood, expenses/income, jars, AI plans, XP, and your profile.'**
  String get profileDeleteAccountBody;

  /// No description provided for @profileDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get profileDeleteAccountConfirm;

  /// No description provided for @profileDeleteAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Delete account and all data'**
  String get profileDeleteAccountCta;

  /// No description provided for @profileDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get profileDeletingAccount;

  /// No description provided for @profileDeleteAccountFootnote.
  ///
  /// In en, this message translates to:
  /// **'Deletion is irreversible. Your data will be permanently removed from Supabase.'**
  String get profileDeleteAccountFootnote;

  /// No description provided for @profileAccountDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get profileAccountDeletedToast;

  /// No description provided for @lifeBlockHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get lifeBlockHealth;

  /// No description provided for @lifeBlockCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get lifeBlockCareer;

  /// No description provided for @lifeBlockFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get lifeBlockFamily;

  /// No description provided for @lifeBlockFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get lifeBlockFinance;

  /// No description provided for @lifeBlockLearning.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get lifeBlockLearning;

  /// No description provided for @lifeBlockSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get lifeBlockSocial;

  /// No description provided for @lifeBlockRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get lifeBlockRest;

  /// No description provided for @lifeBlockBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get lifeBlockBalance;

  /// No description provided for @lifeBlockLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get lifeBlockLove;

  /// No description provided for @lifeBlockCreativity.
  ///
  /// In en, this message translates to:
  /// **'Creativity'**
  String get lifeBlockCreativity;

  /// No description provided for @lifeBlockGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get lifeBlockGeneral;

  /// No description provided for @addDayGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'New daily goal'**
  String get addDayGoalTitle;

  /// No description provided for @addDayGoalFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get addDayGoalFieldTitle;

  /// No description provided for @addDayGoalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Workout / Work / Study'**
  String get addDayGoalTitleHint;

  /// No description provided for @addDayGoalFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get addDayGoalFieldDescription;

  /// No description provided for @addDayGoalDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Shortly: what exactly needs to be done'**
  String get addDayGoalDescriptionHint;

  /// No description provided for @addDayGoalStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get addDayGoalStartTime;

  /// No description provided for @addDayGoalLifeBlock.
  ///
  /// In en, this message translates to:
  /// **'Life area'**
  String get addDayGoalLifeBlock;

  /// No description provided for @addDayGoalImportance.
  ///
  /// In en, this message translates to:
  /// **'Importance'**
  String get addDayGoalImportance;

  /// No description provided for @addDayGoalEmotion.
  ///
  /// In en, this message translates to:
  /// **'Emotion'**
  String get addDayGoalEmotion;

  /// No description provided for @addDayGoalHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get addDayGoalHours;

  /// No description provided for @addDayGoalEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get addDayGoalEnterTitle;

  /// No description provided for @addExpenseNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get addExpenseNewTitle;

  /// No description provided for @addExpenseEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get addExpenseEditTitle;

  /// No description provided for @addExpenseAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addExpenseAmountLabel;

  /// No description provided for @addExpenseAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get addExpenseAmountInvalid;

  /// No description provided for @addExpenseCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addExpenseCategoryLabel;

  /// No description provided for @addExpenseCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get addExpenseCategoryRequired;

  /// No description provided for @addExpenseCreateCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get addExpenseCreateCategoryTooltip;

  /// No description provided for @addExpenseNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get addExpenseNoteLabel;

  /// No description provided for @addExpenseNewCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get addExpenseNewCategoryTitle;

  /// No description provided for @addExpenseCategoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addExpenseCategoryNameLabel;

  /// No description provided for @addIncomeNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New income'**
  String get addIncomeNewTitle;

  /// No description provided for @addIncomeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit income'**
  String get addIncomeEditTitle;

  /// No description provided for @addIncomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Amount, category and note'**
  String get addIncomeSubtitle;

  /// No description provided for @addIncomeAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addIncomeAmountLabel;

  /// No description provided for @addIncomeAmountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1200.50'**
  String get addIncomeAmountHint;

  /// No description provided for @addIncomeAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get addIncomeAmountInvalid;

  /// No description provided for @addIncomeCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addIncomeCategoryLabel;

  /// No description provided for @addIncomeCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get addIncomeCategoryRequired;

  /// No description provided for @addIncomeNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get addIncomeNoteLabel;

  /// No description provided for @addIncomeNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get addIncomeNoteHint;

  /// No description provided for @addIncomeNewCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New income category'**
  String get addIncomeNewCategoryTitle;

  /// No description provided for @addIncomeCategoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addIncomeCategoryNameLabel;

  /// No description provided for @addIncomeCategoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Salary, Freelance…'**
  String get addIncomeCategoryNameHint;

  /// No description provided for @addIncomeCategoryNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a category name'**
  String get addIncomeCategoryNameEmpty;

  /// No description provided for @addJarNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New jar'**
  String get addJarNewTitle;

  /// No description provided for @addJarEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit jar'**
  String get addJarEditTitle;

  /// No description provided for @addJarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the target and the share of free money'**
  String get addJarSubtitle;

  /// No description provided for @addJarNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addJarNameLabel;

  /// No description provided for @addJarNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Trip, Emergency fund, House'**
  String get addJarNameHint;

  /// No description provided for @addJarNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get addJarNameRequired;

  /// No description provided for @addJarPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Share of free money, %'**
  String get addJarPercentLabel;

  /// No description provided for @addJarPercentHint.
  ///
  /// In en, this message translates to:
  /// **'0 if you top up manually'**
  String get addJarPercentHint;

  /// No description provided for @addJarPercentRange.
  ///
  /// In en, this message translates to:
  /// **'Percent must be between 0 and 100'**
  String get addJarPercentRange;

  /// No description provided for @addJarTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get addJarTargetLabel;

  /// No description provided for @addJarTargetHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5000'**
  String get addJarTargetHint;

  /// No description provided for @addJarTargetHelper.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get addJarTargetHelper;

  /// No description provided for @addJarTargetRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a target (positive number)'**
  String get addJarTargetRequired;

  /// No description provided for @aiInsightTypeDataQuality.
  ///
  /// In en, this message translates to:
  /// **'Data quality'**
  String get aiInsightTypeDataQuality;

  /// No description provided for @aiInsightTypeRisk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get aiInsightTypeRisk;

  /// No description provided for @aiInsightTypeEmotional.
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get aiInsightTypeEmotional;

  /// No description provided for @aiInsightTypeHabit.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get aiInsightTypeHabit;

  /// No description provided for @aiInsightTypeGoal.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get aiInsightTypeGoal;

  /// No description provided for @aiInsightTypeDefault.
  ///
  /// In en, this message translates to:
  /// **'Insight'**
  String get aiInsightTypeDefault;

  /// No description provided for @aiInsightStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong impact'**
  String get aiInsightStrengthStrong;

  /// No description provided for @aiInsightStrengthNoticeable.
  ///
  /// In en, this message translates to:
  /// **'Noticeable impact'**
  String get aiInsightStrengthNoticeable;

  /// No description provided for @aiInsightStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak impact'**
  String get aiInsightStrengthWeak;

  /// No description provided for @aiInsightStrengthLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Low confidence'**
  String get aiInsightStrengthLowConfidence;

  /// No description provided for @aiInsightStrengthPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String aiInsightStrengthPercent(int value);

  /// No description provided for @aiInsightEvidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get aiInsightEvidenceTitle;

  /// No description provided for @aiInsightImpactPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get aiInsightImpactPositive;

  /// No description provided for @aiInsightImpactNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get aiInsightImpactNegative;

  /// No description provided for @aiInsightImpactMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get aiInsightImpactMixed;

  /// No description provided for @aiInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI insights'**
  String get aiInsightsTitle;

  /// No description provided for @aiInsightsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Run AI analysis?'**
  String get aiInsightsConfirmTitle;

  /// No description provided for @aiInsightsConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'AI will analyze your tasks, habits, and wellbeing for the selected period and save insights. This may take a few seconds.'**
  String get aiInsightsConfirmBody;

  /// No description provided for @aiInsightsConfirmRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get aiInsightsConfirmRun;

  /// No description provided for @aiInsightsPeriod7.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get aiInsightsPeriod7;

  /// No description provided for @aiInsightsPeriod30.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get aiInsightsPeriod30;

  /// No description provided for @aiInsightsPeriod90.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get aiInsightsPeriod90;

  /// No description provided for @aiInsightsLastRun.
  ///
  /// In en, this message translates to:
  /// **'Last run: {date}'**
  String aiInsightsLastRun(String date);

  /// No description provided for @aiInsightsEmptyNotRunTitle.
  ///
  /// In en, this message translates to:
  /// **'AI hasn’t been run yet'**
  String get aiInsightsEmptyNotRunTitle;

  /// No description provided for @aiInsightsEmptyNotRunSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a period and tap “Run”. Insights will be saved and available in the app.'**
  String get aiInsightsEmptyNotRunSubtitle;

  /// No description provided for @aiInsightsCtaRun.
  ///
  /// In en, this message translates to:
  /// **'Run analysis'**
  String get aiInsightsCtaRun;

  /// No description provided for @aiInsightsEmptyNoInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'No insights yet'**
  String get aiInsightsEmptyNoInsightsTitle;

  /// No description provided for @aiInsightsEmptyNoInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add more data (tasks, habits, question answers) and run the analysis again.'**
  String get aiInsightsEmptyNoInsightsSubtitle;

  /// No description provided for @aiInsightsCtaRunAgain.
  ///
  /// In en, this message translates to:
  /// **'Run again'**
  String get aiInsightsCtaRunAgain;

  /// No description provided for @aiInsightsErrorAi.
  ///
  /// In en, this message translates to:
  /// **'AI error: {error}'**
  String aiInsightsErrorAi(String error);

  /// No description provided for @gcTitleDaySync.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar • day sync'**
  String get gcTitleDaySync;

  /// No description provided for @gcSubtitleImport.
  ///
  /// In en, this message translates to:
  /// **'Import this day’s events into goals.'**
  String get gcSubtitleImport;

  /// No description provided for @gcSubtitleExport.
  ///
  /// In en, this message translates to:
  /// **'Export this day’s goals into the calendar.'**
  String get gcSubtitleExport;

  /// No description provided for @gcModeImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get gcModeImport;

  /// No description provided for @gcModeExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get gcModeExport;

  /// No description provided for @gcCalendarLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get gcCalendarLabel;

  /// No description provided for @gcCalendarPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary (default)'**
  String get gcCalendarPrimary;

  /// No description provided for @gcDefaultLifeBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'Default life block (for import)'**
  String get gcDefaultLifeBlockLabel;

  /// No description provided for @gcLifeBlockForThisGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Life block for this goal'**
  String get gcLifeBlockForThisGoalLabel;

  /// No description provided for @gcEventsNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Events are not loaded'**
  String get gcEventsNotLoaded;

  /// No description provided for @gcConnectToLoadEvents.
  ///
  /// In en, this message translates to:
  /// **'Connect your account to load events'**
  String get gcConnectToLoadEvents;

  /// No description provided for @gcExportHint.
  ///
  /// In en, this message translates to:
  /// **'Export will create events in the selected calendar for this day’s goals.'**
  String get gcExportHint;

  /// No description provided for @gcConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get gcConnect;

  /// No description provided for @gcConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get gcConnected;

  /// No description provided for @gcFindForDay.
  ///
  /// In en, this message translates to:
  /// **'Find for day'**
  String get gcFindForDay;

  /// No description provided for @gcImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get gcImport;

  /// No description provided for @gcExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get gcExport;

  /// No description provided for @gcNoTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get gcNoTitle;

  /// No description provided for @gcLoadingDots.
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get gcLoadingDots;

  /// No description provided for @gcImportedGoals.
  ///
  /// In en, this message translates to:
  /// **'Imported goals: {count}'**
  String gcImportedGoals(int count);

  /// No description provided for @gcExportedGoals.
  ///
  /// In en, this message translates to:
  /// **'Exported goals: {count}'**
  String gcExportedGoals(int count);

  /// No description provided for @editGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get editGoalTitle;

  /// No description provided for @editGoalSectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get editGoalSectionDetails;

  /// No description provided for @editGoalSectionLifeBlock.
  ///
  /// In en, this message translates to:
  /// **'Life block'**
  String get editGoalSectionLifeBlock;

  /// No description provided for @editGoalSectionParams.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get editGoalSectionParams;

  /// No description provided for @editGoalFieldTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get editGoalFieldTitleLabel;

  /// No description provided for @editGoalFieldTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 3 km run'**
  String get editGoalFieldTitleHint;

  /// No description provided for @editGoalFieldDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get editGoalFieldDescLabel;

  /// No description provided for @editGoalFieldDescHint.
  ///
  /// In en, this message translates to:
  /// **'What exactly needs to be done?'**
  String get editGoalFieldDescHint;

  /// No description provided for @editGoalFieldLifeBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'Life block'**
  String get editGoalFieldLifeBlockLabel;

  /// No description provided for @editGoalFieldImportanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Importance'**
  String get editGoalFieldImportanceLabel;

  /// No description provided for @editGoalImportanceLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get editGoalImportanceLow;

  /// No description provided for @editGoalImportanceMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get editGoalImportanceMedium;

  /// No description provided for @editGoalImportanceHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get editGoalImportanceHigh;

  /// No description provided for @editGoalFieldEmotionLabel.
  ///
  /// In en, this message translates to:
  /// **'Emotion'**
  String get editGoalFieldEmotionLabel;

  /// No description provided for @editGoalFieldEmotionHint.
  ///
  /// In en, this message translates to:
  /// **'😊'**
  String get editGoalFieldEmotionHint;

  /// No description provided for @editGoalDurationHours.
  ///
  /// In en, this message translates to:
  /// **'Duration (h)'**
  String get editGoalDurationHours;

  /// No description provided for @editGoalStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get editGoalStartTime;

  /// No description provided for @editGoalUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get editGoalUntitled;

  /// No description provided for @expenseCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expenseCategoryOther;

  /// No description provided for @goalStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get goalStatusDone;

  /// No description provided for @goalStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get goalStatusInProgress;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @goalImportanceChip.
  ///
  /// In en, this message translates to:
  /// **'Priority {value}/5'**
  String goalImportanceChip(int value);

  /// No description provided for @goalHoursChip.
  ///
  /// In en, this message translates to:
  /// **'Hours {value}'**
  String goalHoursChip(String value);

  /// No description provided for @goalPathEmpty.
  ///
  /// In en, this message translates to:
  /// **'No goals on the path'**
  String get goalPathEmpty;

  /// No description provided for @timelineActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get timelineActionEdit;

  /// No description provided for @timelineActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get timelineActionDelete;

  /// No description provided for @saveBarSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saveBarSaving;

  /// No description provided for @saveBarSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBarSave;

  /// No description provided for @reportEmptyChartNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get reportEmptyChartNotEnoughData;

  /// No description provided for @limitSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit for “{categoryName}”'**
  String limitSheetTitle(String categoryName);

  /// No description provided for @limitSheetHintNoLimit.
  ///
  /// In en, this message translates to:
  /// **'Leave empty — no limit'**
  String get limitSheetHintNoLimit;

  /// No description provided for @limitSheetFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit'**
  String get limitSheetFieldLabel;

  /// No description provided for @limitSheetFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 15000'**
  String get limitSheetFieldHint;

  /// No description provided for @limitSheetCtaNoLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get limitSheetCtaNoLimit;

  /// No description provided for @profileWebNotificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications (Web)'**
  String get profileWebNotificationsSection;

  /// No description provided for @profileWebNotificationsPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get profileWebNotificationsPermissionTitle;

  /// No description provided for @profileWebNotificationsPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Works on Web and only while the tab is open.'**
  String get profileWebNotificationsPermissionSubtitle;

  /// No description provided for @profileWebNotificationsEveningTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening check-in'**
  String get profileWebNotificationsEveningTitle;

  /// No description provided for @profileWebNotificationsEveningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String profileWebNotificationsEveningSubtitle(Object time);

  /// No description provided for @profileWebNotificationsChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Change time'**
  String get profileWebNotificationsChangeTime;

  /// No description provided for @profileWebNotificationsUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Browser notifications are not available in this build. They work only in the Web version (and only while the tab is open).'**
  String get profileWebNotificationsUnsupported;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ru',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
