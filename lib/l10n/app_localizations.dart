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
  /// **'Ladna'**
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
  /// **'Ladna'**
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
  /// **''**
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

  /// No description provided for @lifeBlockEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get lifeBlockEducation;

  /// No description provided for @lifeBlockHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get lifeBlockHobbies;

  /// No description provided for @userGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'My goals'**
  String get userGoalsTitle;

  /// No description provided for @userGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Strategic goals by life area: short-term, mid-term, and long-term.'**
  String get userGoalsSubtitle;

  /// No description provided for @userGoalsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get userGoalsNewTitle;

  /// No description provided for @userGoalsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get userGoalsEditTitle;

  /// No description provided for @userGoalsCreateGoal.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get userGoalsCreateGoal;

  /// No description provided for @userGoalsCreated.
  ///
  /// In en, this message translates to:
  /// **'Goal created'**
  String get userGoalsCreated;

  /// No description provided for @userGoalsCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create goal: {error}'**
  String userGoalsCreateError(Object error);

  /// No description provided for @userGoalsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goal updated'**
  String get userGoalsUpdated;

  /// No description provided for @userGoalsUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update goal: {error}'**
  String userGoalsUpdateError(Object error);

  /// No description provided for @userGoalsStatusChangeError.
  ///
  /// In en, this message translates to:
  /// **'Could not change status: {error}'**
  String userGoalsStatusChangeError(Object error);

  /// No description provided for @userGoalsDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete goal: {error}'**
  String userGoalsDeleteError(Object error);

  /// No description provided for @userGoalsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete goal?'**
  String get userGoalsDeleteConfirmTitle;

  /// No description provided for @userGoalsAllBlocks.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get userGoalsAllBlocks;

  /// No description provided for @userGoalsAllHorizons.
  ///
  /// In en, this message translates to:
  /// **'All horizons'**
  String get userGoalsAllHorizons;

  /// No description provided for @userGoalsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get userGoalsLoadErrorTitle;

  /// No description provided for @userGoalsNoActiveBlocksTitle.
  ///
  /// In en, this message translates to:
  /// **'No active life areas'**
  String get userGoalsNoActiveBlocksTitle;

  /// No description provided for @userGoalsNoActiveBlocksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'First, choose the life areas the user tracks.'**
  String get userGoalsNoActiveBlocksSubtitle;

  /// No description provided for @userGoalsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get userGoalsEmptyTitle;

  /// No description provided for @userGoalsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first strategic goal for one of your life areas.'**
  String get userGoalsEmptySubtitle;

  /// No description provided for @userGoalsDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline: {date}'**
  String userGoalsDeadline(Object date);

  /// No description provided for @userGoalsStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get userGoalsStatusCompleted;

  /// No description provided for @userGoalsStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get userGoalsStatusActive;

  /// No description provided for @userGoalsReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get userGoalsReopen;

  /// No description provided for @userGoalsComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get userGoalsComplete;

  /// No description provided for @userGoalsFieldLifeBlock.
  ///
  /// In en, this message translates to:
  /// **'Life area'**
  String get userGoalsFieldLifeBlock;

  /// No description provided for @userGoalsFieldHorizon.
  ///
  /// In en, this message translates to:
  /// **'Horizon'**
  String get userGoalsFieldHorizon;

  /// No description provided for @userGoalsFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal title'**
  String get userGoalsFieldTitle;

  /// No description provided for @userGoalsFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get userGoalsFieldDescription;

  /// No description provided for @userGoalsPickTargetDate.
  ///
  /// In en, this message translates to:
  /// **'Choose target date'**
  String get userGoalsPickTargetDate;

  /// No description provided for @userGoalsClearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get userGoalsClearDate;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @weekdayMonShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMonShort;

  /// No description provided for @weekdayTueShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTueShort;

  /// No description provided for @weekdayWedShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWedShort;

  /// No description provided for @weekdayThuShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThuShort;

  /// No description provided for @weekdayFriShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFriShort;

  /// No description provided for @weekdaySatShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySatShort;

  /// No description provided for @weekdaySunShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySunShort;

  /// No description provided for @lifeBlockRelations.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get lifeBlockRelations;

  /// No description provided for @lifeBlockSpirituality.
  ///
  /// In en, this message translates to:
  /// **'Spirituality'**
  String get lifeBlockSpirituality;

  /// No description provided for @goalsHeaderWeek.
  ///
  /// In en, this message translates to:
  /// **'{month} {year}, week {week}'**
  String goalsHeaderWeek(Object month, Object year, Object week);

  /// No description provided for @goalsQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get goalsQuickActionsTitle;

  /// No description provided for @goalsQuickActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add and plan in one tap'**
  String get goalsQuickActionsSubtitle;

  /// No description provided for @goalsMassAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Mass daily entry'**
  String get goalsMassAddTitle;

  /// No description provided for @goalsMassAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses + Income + Tasks + Mood + Habits'**
  String get goalsMassAddSubtitle;

  /// No description provided for @goalsMassAddSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved: {expenses} expense(s), {incomes} income item(s), {goals} task(s), {habits} habit(s){moodSuffix}'**
  String goalsMassAddSaved(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodSuffix,
  );

  /// No description provided for @goalsMassAddMoodSuffix.
  ///
  /// In en, this message translates to:
  /// **', mood'**
  String get goalsMassAddMoodSuffix;

  /// No description provided for @goalsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Save error: {error}'**
  String goalsSaveError(Object error);

  /// No description provided for @goalsRecurringGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring goal'**
  String get goalsRecurringGoalTitle;

  /// No description provided for @goalsRecurringGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan several days ahead'**
  String get goalsRecurringGoalSubtitle;

  /// No description provided for @goalsRecurringNoDates.
  ///
  /// In en, this message translates to:
  /// **'No dates to create. Check the deadline or settings.'**
  String get goalsRecurringNoDates;

  /// No description provided for @goalsPlanHoursDescription.
  ///
  /// In en, this message translates to:
  /// **'Plan: {hours} h'**
  String goalsPlanHoursDescription(Object hours);

  /// No description provided for @goalsCreatedCount.
  ///
  /// In en, this message translates to:
  /// **'Goals created: {count}'**
  String goalsCreatedCount(Object count);

  /// No description provided for @goalsRecurringCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create the goal series: {error}'**
  String goalsRecurringCreateError(Object error);

  /// No description provided for @goalsSimpleTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick task'**
  String get goalsSimpleTaskTitle;

  /// No description provided for @goalsSimpleTaskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Title only, optional time, General category'**
  String get goalsSimpleTaskSubtitle;

  /// No description provided for @goalsSimpleTaskSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Title only, optional time. The default category is General.'**
  String get goalsSimpleTaskSheetSubtitle;

  /// No description provided for @goalsTaskCreated.
  ///
  /// In en, this message translates to:
  /// **'Task created'**
  String get goalsTaskCreated;

  /// No description provided for @goalsTaskCreateError.
  ///
  /// In en, this message translates to:
  /// **'Task creation error: {error}'**
  String goalsTaskCreateError(Object error);

  /// No description provided for @goalsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get goalsAll;

  /// No description provided for @goalsViewDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get goalsViewDashboard;

  /// No description provided for @goalsViewCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get goalsViewCalendar;

  /// No description provided for @goalsViewWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get goalsViewWeek;

  /// No description provided for @goalsViewMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get goalsViewMonth;

  /// No description provided for @goalsByBlocksTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals by life area'**
  String get goalsByBlocksTitle;

  /// No description provided for @goalsShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get goalsShow;

  /// No description provided for @goalsByBlocksHiddenHint.
  ///
  /// In en, this message translates to:
  /// **'Hidden. Tap 👁 to show.'**
  String get goalsByBlocksHiddenHint;

  /// No description provided for @goalsEnterTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a task title'**
  String get goalsEnterTaskTitle;

  /// No description provided for @goalsTaskTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get goalsTaskTitleLabel;

  /// No description provided for @goalsAddTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get goalsAddTime;

  /// No description provided for @goalsTimeValue.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String goalsTimeValue(Object time);

  /// No description provided for @goalsRemoveTime.
  ///
  /// In en, this message translates to:
  /// **'Remove time'**
  String get goalsRemoveTime;

  /// No description provided for @goalsCreateTask.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get goalsCreateTask;

  /// No description provided for @goalsWeekSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Week summary'**
  String get goalsWeekSummaryTitle;

  /// No description provided for @goalsHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String goalsHoursShort(Object hours);

  /// No description provided for @goalsHoursTargetSuffix.
  ///
  /// In en, this message translates to:
  /// **' / {hours} h'**
  String goalsHoursTargetSuffix(Object hours);

  /// No description provided for @goalsHoursShortNoSpace.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String goalsHoursShortNoSpace(Object hours);

  /// No description provided for @goalsHoursTargetSuffixNoSpace.
  ///
  /// In en, this message translates to:
  /// **' / {hours}h'**
  String goalsHoursTargetSuffixNoSpace(Object hours);

  /// No description provided for @dayGoalsHiddenCompletedEmpty.
  ///
  /// In en, this message translates to:
  /// **'All visible goals are hidden. Turn off the “Hide completed” filter.'**
  String get dayGoalsHiddenCompletedEmpty;

  /// No description provided for @dayGoalsKanbanOpenShort.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get dayGoalsKanbanOpenShort;

  /// No description provided for @dayGoalsKanbanDoneShort.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dayGoalsKanbanDoneShort;

  /// No description provided for @dayGoalsKanbanOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get dayGoalsKanbanOpenTitle;

  /// No description provided for @dayGoalsKanbanDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dayGoalsKanbanDoneTitle;

  /// No description provided for @dayGoalsKanbanOpenEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active tasks'**
  String get dayGoalsKanbanOpenEmpty;

  /// No description provided for @dayGoalsKanbanDoneEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get dayGoalsKanbanDoneEmpty;

  /// No description provided for @dayGoalsHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String dayGoalsHoursShort(Object hours);

  /// No description provided for @dayGoalsSectionMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get dayGoalsSectionMorning;

  /// No description provided for @dayGoalsSectionDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayGoalsSectionDay;

  /// No description provided for @dayGoalsSectionEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get dayGoalsSectionEvening;

  /// No description provided for @dayGoalsSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Day summary'**
  String get dayGoalsSummaryTitle;

  /// No description provided for @dayGoalsSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay focused on what matters and keep the day manageable.'**
  String get dayGoalsSummarySubtitle;

  /// No description provided for @dayGoalsSummaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get dayGoalsSummaryTotal;

  /// No description provided for @dayGoalsSummaryDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dayGoalsSummaryDone;

  /// No description provided for @dayGoalsSummaryRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get dayGoalsSummaryRemaining;

  /// No description provided for @dayGoalsRemainingHours.
  ///
  /// In en, this message translates to:
  /// **'Hours remaining: {hours}'**
  String dayGoalsRemainingHours(Object hours);

  /// No description provided for @dayGoalsHideCompleted.
  ///
  /// In en, this message translates to:
  /// **'Hide completed'**
  String get dayGoalsHideCompleted;

  /// No description provided for @reportsTabSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get reportsTabSummary;

  /// No description provided for @reportsTabRelations.
  ///
  /// In en, this message translates to:
  /// **'Relations'**
  String get reportsTabRelations;

  /// No description provided for @reportsTabProductivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get reportsTabProductivity;

  /// No description provided for @reportsTabExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get reportsTabExpenses;

  /// No description provided for @reportsCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed tasks'**
  String get reportsCompletedTasks;

  /// No description provided for @reportsSpentHours.
  ///
  /// In en, this message translates to:
  /// **'Hours spent'**
  String get reportsSpentHours;

  /// No description provided for @reportsEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get reportsEfficiency;

  /// No description provided for @reportsPeriodEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Period efficiency'**
  String get reportsPeriodEfficiency;

  /// No description provided for @reportsPlanFactHours.
  ///
  /// In en, this message translates to:
  /// **'Plan: {planned} h • Actual: {actual} h'**
  String reportsPlanFactHours(Object planned, Object actual);

  /// No description provided for @reportsAdditionalMetrics.
  ///
  /// In en, this message translates to:
  /// **'Additional metrics'**
  String get reportsAdditionalMetrics;

  /// No description provided for @reportsCorrelations.
  ///
  /// In en, this message translates to:
  /// **'Relations between metrics'**
  String get reportsCorrelations;

  /// No description provided for @reportsCorrelationsHint.
  ///
  /// In en, this message translates to:
  /// **'This is not a scientific correlation, but clear period-based comparisons.'**
  String get reportsCorrelationsHint;

  /// No description provided for @reportsMoodProductivity.
  ///
  /// In en, this message translates to:
  /// **'Mood → Productivity'**
  String get reportsMoodProductivity;

  /// No description provided for @reportsGoodMood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get reportsGoodMood;

  /// No description provided for @reportsBadMood.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get reportsBadMood;

  /// No description provided for @reportsHabitsMoodProductivity.
  ///
  /// In en, this message translates to:
  /// **'Habits → Mood / Productivity'**
  String get reportsHabitsMoodProductivity;

  /// No description provided for @reportsMoodMostlyHappy.
  ///
  /// In en, this message translates to:
  /// **'mostly 😊'**
  String get reportsMoodMostlyHappy;

  /// No description provided for @reportsMoodMostlySad.
  ///
  /// In en, this message translates to:
  /// **'mostly 😞'**
  String get reportsMoodMostlySad;

  /// No description provided for @reportsMoodMostlyNeutral.
  ///
  /// In en, this message translates to:
  /// **'mostly 😐'**
  String get reportsMoodMostlyNeutral;

  /// No description provided for @reportsHabitsComparisonHint.
  ///
  /// In en, this message translates to:
  /// **'Comparison of days with ≥ {percent}% habits completed and all other days.'**
  String reportsHabitsComparisonHint(int percent);

  /// No description provided for @reportsMoodHigh.
  ///
  /// In en, this message translates to:
  /// **'Mood (high)'**
  String get reportsMoodHigh;

  /// No description provided for @reportsMoodLow.
  ///
  /// In en, this message translates to:
  /// **'Mood (low)'**
  String get reportsMoodLow;

  /// No description provided for @reportsHoursHigh.
  ///
  /// In en, this message translates to:
  /// **'Hours (high)'**
  String get reportsHoursHigh;

  /// No description provided for @reportsHoursLow.
  ///
  /// In en, this message translates to:
  /// **'Hours (low)'**
  String get reportsHoursLow;

  /// No description provided for @reportsHabitsHighShort.
  ///
  /// In en, this message translates to:
  /// **'habits high'**
  String get reportsHabitsHighShort;

  /// No description provided for @reportsHabitsLowShort.
  ///
  /// In en, this message translates to:
  /// **'habits low'**
  String get reportsHabitsLowShort;

  /// No description provided for @reportsMentalMood.
  ///
  /// In en, this message translates to:
  /// **'Mental state → Mood'**
  String get reportsMentalMood;

  /// No description provided for @reportsExpensesMood.
  ///
  /// In en, this message translates to:
  /// **'Expenses → Mood'**
  String get reportsExpensesMood;

  /// No description provided for @reportsHappyDays.
  ///
  /// In en, this message translates to:
  /// **'😊 days'**
  String get reportsHappyDays;

  /// No description provided for @reportsSadDays.
  ///
  /// In en, this message translates to:
  /// **'😞 days'**
  String get reportsSadDays;

  /// No description provided for @reportsCompletedByBlocks.
  ///
  /// In en, this message translates to:
  /// **'Completed by blocks'**
  String get reportsCompletedByBlocks;

  /// No description provided for @reportsNoCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'No completed tasks'**
  String get reportsNoCompletedTasks;

  /// No description provided for @reportsTasksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks'**
  String reportsTasksCount(int count);

  /// No description provided for @reportsHoursByDays.
  ///
  /// In en, this message translates to:
  /// **'Hours spent by day'**
  String get reportsHoursByDays;

  /// No description provided for @reportsExpensesForPeriod.
  ///
  /// In en, this message translates to:
  /// **'Expenses for period'**
  String get reportsExpensesForPeriod;

  /// No description provided for @reportsTotalEuro.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount} €'**
  String reportsTotalEuro(Object amount);

  /// No description provided for @reportsAvgExpensePerDay.
  ///
  /// In en, this message translates to:
  /// **'Average expense/day: {amount} €'**
  String reportsAvgExpensePerDay(Object amount);

  /// No description provided for @reportsNoExpensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'No expenses by category'**
  String get reportsNoExpensesByCategory;

  /// No description provided for @reportsAvgTimePerGoal.
  ///
  /// In en, this message translates to:
  /// **'Average time per task'**
  String get reportsAvgTimePerGoal;

  /// No description provided for @reportsOnTimeConditional.
  ///
  /// In en, this message translates to:
  /// **'“On time” (approx.)'**
  String get reportsOnTimeConditional;

  /// No description provided for @reportsTop3ProductiveDays.
  ///
  /// In en, this message translates to:
  /// **'TOP 3 productive days'**
  String get reportsTop3ProductiveDays;

  /// No description provided for @reportsTopDayLine.
  ///
  /// In en, this message translates to:
  /// **'• {day}.{month}.{year}: {hours} h'**
  String reportsTopDayLine(int day, int month, int year, Object hours);

  /// No description provided for @reportsPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get reportsPeriodDay;

  /// No description provided for @reportsPeriodWeekShort.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get reportsPeriodWeekShort;

  /// No description provided for @reportsPeriodMonthShort.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get reportsPeriodMonthShort;

  /// No description provided for @reportsForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get reportsForward;

  /// No description provided for @reportsTapChartSector.
  ///
  /// In en, this message translates to:
  /// **'Tap a chart segment'**
  String get reportsTapChartSector;

  /// No description provided for @reportsLatestAiInsights.
  ///
  /// In en, this message translates to:
  /// **'Latest AI insights'**
  String get reportsLatestAiInsights;

  /// No description provided for @reportsOpenAll.
  ///
  /// In en, this message translates to:
  /// **'Open all'**
  String get reportsOpenAll;

  /// No description provided for @reportsInsightsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load insights'**
  String get reportsInsightsLoadFailed;

  /// No description provided for @reportsNoSavedInsights.
  ///
  /// In en, this message translates to:
  /// **'No saved insights yet.'**
  String get reportsNoSavedInsights;

  /// No description provided for @reportsRunAiInsightsHint.
  ///
  /// In en, this message translates to:
  /// **'Open “AI insights” and run an analysis — then they will appear here.'**
  String get reportsRunAiInsightsHint;

  /// No description provided for @reportsAiPeriod7Days.
  ///
  /// In en, this message translates to:
  /// **'last 7 days'**
  String get reportsAiPeriod7Days;

  /// No description provided for @reportsAiPeriod30Days.
  ///
  /// In en, this message translates to:
  /// **'last 30 days'**
  String get reportsAiPeriod30Days;

  /// No description provided for @reportsAiPeriod90Days.
  ///
  /// In en, this message translates to:
  /// **'last 90 days'**
  String get reportsAiPeriod90Days;

  /// No description provided for @reportsHoursValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String reportsHoursValue(Object hours);

  /// No description provided for @reportsEuroValue.
  ///
  /// In en, this message translates to:
  /// **'{amount} €'**
  String reportsEuroValue(Object amount);

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @aiPlanConsentSaved.
  ///
  /// In en, this message translates to:
  /// **'AI processing consent saved'**
  String get aiPlanConsentSaved;

  /// No description provided for @aiPlanConsentCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check or save AI processing consent. Make sure the users table has the fields ai_processing_consent, ai_processing_consent_at and ai_processing_consent_version. Details: {error}'**
  String aiPlanConsentCheckFailed(Object error);

  /// No description provided for @aiPlanConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'AI processing consent'**
  String get aiPlanConsentTitle;

  /// No description provided for @aiPlanConsentBody.
  ///
  /// In en, this message translates to:
  /// **'To generate an AI plan, Ladna will analyze your goals, tasks, habits, mood and other app data. This data is used only to create personal recommendations, plans and insights.'**
  String get aiPlanConsentBody;

  /// No description provided for @aiPlanConsentDeclineBody.
  ///
  /// In en, this message translates to:
  /// **'You can decline consent — in that case, the AI feature will not run.'**
  String get aiPlanConsentDeclineBody;

  /// No description provided for @aiPlanConsentNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get aiPlanConsentNotNow;

  /// No description provided for @aiPlanConsentAgree.
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get aiPlanConsentAgree;

  /// No description provided for @aiPlanOpenLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open link: {url}'**
  String aiPlanOpenLinkFailed(Object url);

  /// No description provided for @aiPlanUpdated.
  ///
  /// In en, this message translates to:
  /// **'AI plan updated'**
  String get aiPlanUpdated;

  /// No description provided for @aiPlanEmptyEdgeFunction.
  ///
  /// In en, this message translates to:
  /// **'The plan is empty. Check the ai-plan Edge Function.'**
  String get aiPlanEmptyEdgeFunction;

  /// No description provided for @aiPlanHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String aiPlanHoursShort(Object hours);

  /// No description provided for @aiPlanImportanceMeta.
  ///
  /// In en, this message translates to:
  /// **'importance {importance}/5'**
  String aiPlanImportanceMeta(int importance);

  /// No description provided for @aiPlanLinkedToGoal.
  ///
  /// In en, this message translates to:
  /// **'linked to a goal'**
  String get aiPlanLinkedToGoal;

  /// No description provided for @aiPlanNothingToApply.
  ///
  /// In en, this message translates to:
  /// **'Nothing to apply — select some items'**
  String get aiPlanNothingToApply;

  /// No description provided for @aiPlanDefaultTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'AI task'**
  String get aiPlanDefaultTaskTitle;

  /// No description provided for @aiPlanTasksAdded.
  ///
  /// In en, this message translates to:
  /// **'Tasks added: {count}'**
  String aiPlanTasksAdded(int count);

  /// No description provided for @aiPlanApplyTypeError.
  ///
  /// In en, this message translates to:
  /// **'Data type error while adding tasks: one of the fields came as true/false instead of a number. Update the file again: in this version, bool values are additionally converted to numbers and the is_completed field is no longer sent manually.'**
  String get aiPlanApplyTypeError;

  /// No description provided for @aiPlanTitleWeek.
  ///
  /// In en, this message translates to:
  /// **'AI plan for the week'**
  String get aiPlanTitleWeek;

  /// No description provided for @aiPlanTitleMonth.
  ///
  /// In en, this message translates to:
  /// **'AI plan for the month'**
  String get aiPlanTitleMonth;

  /// No description provided for @aiPlanRegenerateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Generate again'**
  String get aiPlanRegenerateTooltip;

  /// No description provided for @aiPlanUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated: {date}'**
  String aiPlanUpdatedAt(Object date);

  /// No description provided for @aiPlanCheckingConsent.
  ///
  /// In en, this message translates to:
  /// **'Checking AI processing consent...'**
  String get aiPlanCheckingConsent;

  /// No description provided for @aiPlanApplyingTasks.
  ///
  /// In en, this message translates to:
  /// **'Adding tasks...'**
  String get aiPlanApplyingTasks;

  /// No description provided for @aiPlanGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating AI plan...'**
  String get aiPlanGenerating;

  /// No description provided for @aiPlanApplyCount.
  ///
  /// In en, this message translates to:
  /// **'Apply ({count})'**
  String aiPlanApplyCount(int count);

  /// No description provided for @aiPlanRejectTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get aiPlanRejectTooltip;

  /// No description provided for @aiPlanAcceptTooltip.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get aiPlanAcceptTooltip;

  /// No description provided for @aiPlanFieldBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get aiPlanFieldBlock;

  /// No description provided for @aiPlanFieldImportance.
  ///
  /// In en, this message translates to:
  /// **'Importance'**
  String get aiPlanFieldImportance;

  /// No description provided for @aiPlanFieldHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get aiPlanFieldHours;

  /// No description provided for @aiPlanFieldRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get aiPlanFieldRepeat;

  /// No description provided for @aiPlanConsentRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'AI processing consent is required'**
  String get aiPlanConsentRequiredTitle;

  /// No description provided for @aiPlanConsentRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Before generating an AI plan, you need to confirm that Ladna may analyze app data for personal recommendations.'**
  String get aiPlanConsentRequiredBody;

  /// No description provided for @aiPlanGiveConsent.
  ///
  /// In en, this message translates to:
  /// **'Give consent'**
  String get aiPlanGiveConsent;

  /// No description provided for @aiPlanPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aiPlanPrivacyPolicy;

  /// No description provided for @aiPlanDatenschutz.
  ///
  /// In en, this message translates to:
  /// **'Data Protection Policy'**
  String get aiPlanDatenschutz;

  /// No description provided for @aiPlanTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get aiPlanTermsOfUse;

  /// No description provided for @aiPlanEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'The plan is empty'**
  String get aiPlanEmptyTitle;

  /// No description provided for @aiPlanEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Press the button below to generate a plan based on AI insights, goals, tasks, habits and mood.'**
  String get aiPlanEmptyBody;

  /// No description provided for @aiPlanGeneratePlan.
  ///
  /// In en, this message translates to:
  /// **'Generate plan'**
  String get aiPlanGeneratePlan;

  /// No description provided for @aiPlanRepeatNone.
  ///
  /// In en, this message translates to:
  /// **'No repeat'**
  String get aiPlanRepeatNone;

  /// No description provided for @aiPlanRepeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get aiPlanRepeatDaily;

  /// No description provided for @aiPlanRepeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get aiPlanRepeatWeekdays;

  /// No description provided for @aiPlanRepeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Once a week'**
  String get aiPlanRepeatWeekly;

  /// No description provided for @aiPlanLifeBlockOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get aiPlanLifeBlockOther;

  /// No description provided for @aiInsightsConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'AI processing consent'**
  String get aiInsightsConsentTitle;

  /// No description provided for @aiInsightsConsentBody.
  ///
  /// In en, this message translates to:
  /// **'To generate AI insights, Ladna will analyze your goals, tasks, habits, mood and other app data. This data is used only to create personal recommendations, plans and insights.'**
  String get aiInsightsConsentBody;

  /// No description provided for @aiInsightsConsentDeclineBody.
  ///
  /// In en, this message translates to:
  /// **'You can decline consent — in that case, the AI feature will not run.'**
  String get aiInsightsConsentDeclineBody;

  /// No description provided for @aiInsightsConsentNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get aiInsightsConsentNotNow;

  /// No description provided for @aiInsightsConsentAgree.
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get aiInsightsConsentAgree;

  /// No description provided for @aiInsightsConsentSaved.
  ///
  /// In en, this message translates to:
  /// **'AI processing consent saved'**
  String get aiInsightsConsentSaved;

  /// No description provided for @aiInsightsConsentCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check or save AI processing consent. Make sure the users table has the fields ai_processing_consent, ai_processing_consent_at and ai_processing_consent_version. Details: {error}'**
  String aiInsightsConsentCheckFailed(Object error);

  /// No description provided for @aiInsightsCheckingConsent.
  ///
  /// In en, this message translates to:
  /// **'Checking AI processing consent...'**
  String get aiInsightsCheckingConsent;

  /// No description provided for @aiInsightsUserNotAuthorized.
  ///
  /// In en, this message translates to:
  /// **'User is not authenticated'**
  String get aiInsightsUserNotAuthorized;

  /// No description provided for @aiInsightsOpenLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open link: {url}'**
  String aiInsightsOpenLinkFailed(Object url);

  /// No description provided for @aiInsightsDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'AI insight'**
  String get aiInsightsDefaultTitle;

  /// No description provided for @aiInsightsConsentRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'AI processing consent is required'**
  String get aiInsightsConsentRequiredTitle;

  /// No description provided for @aiInsightsConsentRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Before generating AI insights, you need to confirm that Ladna may analyze app data for personal recommendations.'**
  String get aiInsightsConsentRequiredBody;

  /// No description provided for @aiInsightsGiveConsent.
  ///
  /// In en, this message translates to:
  /// **'Give consent'**
  String get aiInsightsGiveConsent;

  /// No description provided for @aiInsightsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aiInsightsPrivacyPolicy;

  /// No description provided for @aiInsightsDatenschutz.
  ///
  /// In en, this message translates to:
  /// **'Data Protection Policy'**
  String get aiInsightsDatenschutz;

  /// No description provided for @aiInsightsTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get aiInsightsTermsOfUse;

  /// No description provided for @massDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Mass daily entry'**
  String get massDailyTitle;

  /// No description provided for @massDailyDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get massDailyDatePrefix;

  /// No description provided for @massDailyChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get massDailyChoose;

  /// No description provided for @massDailyBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get massDailyBack;

  /// No description provided for @massDailyCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get massDailyCancel;

  /// No description provided for @massDailyNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get massDailyNext;

  /// No description provided for @massDailySaveAll.
  ///
  /// In en, this message translates to:
  /// **'Save all'**
  String get massDailySaveAll;

  /// No description provided for @massDailyEmptyRowsIgnored.
  ///
  /// In en, this message translates to:
  /// **'Empty rows are ignored.'**
  String get massDailyEmptyRowsIgnored;

  /// No description provided for @massDailyMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get massDailyMoodTitle;

  /// No description provided for @massDailyMoodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional note about how the day went.'**
  String get massDailyMoodSubtitle;

  /// No description provided for @massDailyNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get massDailyNote;

  /// No description provided for @massDailyHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get massDailyHabitsTitle;

  /// No description provided for @massDailyHabitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark completion and add a quantity if needed.'**
  String get massDailyHabitsSubtitle;

  /// No description provided for @massDailyRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get massDailyRefresh;

  /// No description provided for @massDailyNoHabits.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Add them in your profile.'**
  String get massDailyNoHabits;

  /// No description provided for @massDailyHabitsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load habits: {error}'**
  String massDailyHabitsLoadFailed(Object error);

  /// No description provided for @massDailyMentalTitle.
  ///
  /// In en, this message translates to:
  /// **'Mental health'**
  String get massDailyMentalTitle;

  /// No description provided for @massDailyMentalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A short daily state check-in for later analytics.'**
  String get massDailyMentalSubtitle;

  /// No description provided for @massDailyMentalIntro.
  ///
  /// In en, this message translates to:
  /// **'Answer a few questions — this helps track your state.'**
  String get massDailyMentalIntro;

  /// No description provided for @massDailyNoMentalQuestions.
  ///
  /// In en, this message translates to:
  /// **'No questions yet. Add them to the mental_questions table.'**
  String get massDailyNoMentalQuestions;

  /// No description provided for @massDailyMentalLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load questions: {error}'**
  String massDailyMentalLoadFailed(Object error);

  /// No description provided for @massDailyExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get massDailyExpensesTitle;

  /// No description provided for @massDailyExpensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add expenses for the selected day.'**
  String get massDailyExpensesSubtitle;

  /// No description provided for @massDailyIncomesTitle.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get massDailyIncomesTitle;

  /// No description provided for @massDailyIncomesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add income for the selected day.'**
  String get massDailyIncomesSubtitle;

  /// No description provided for @massDailyGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get massDailyGoalsTitle;

  /// No description provided for @massDailyGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record what you worked on that day and how much time it took.'**
  String get massDailyGoalsSubtitle;

  /// No description provided for @massDailyAddRow.
  ///
  /// In en, this message translates to:
  /// **'Add row'**
  String get massDailyAddRow;

  /// No description provided for @massDailyNoMood.
  ///
  /// In en, this message translates to:
  /// **'No mood'**
  String get massDailyNoMood;

  /// No description provided for @massDailyQuantityExample.
  ///
  /// In en, this message translates to:
  /// **'Quantity (for example, cigarettes)'**
  String get massDailyQuantityExample;

  /// No description provided for @massDailyQuantityOptional.
  ///
  /// In en, this message translates to:
  /// **'Quantity (optional)'**
  String get massDailyQuantityOptional;

  /// No description provided for @massDailyQuantityShort.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get massDailyQuantityShort;

  /// No description provided for @massDailyHabitNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get massDailyHabitNegative;

  /// No description provided for @massDailyHabitPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get massDailyHabitPositive;

  /// No description provided for @massDailyAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get massDailyAnswer;

  /// No description provided for @massDailyAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get massDailyAmount;

  /// No description provided for @massDailyCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get massDailyCategory;

  /// No description provided for @massDailyNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get massDailyNoCategories;

  /// No description provided for @massDailyTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get massDailyTaskTitle;

  /// No description provided for @massDailyHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get massDailyHours;

  /// No description provided for @massDailyTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get massDailyTime;

  /// No description provided for @massDailyEmotion.
  ///
  /// In en, this message translates to:
  /// **'Emotion'**
  String get massDailyEmotion;

  /// No description provided for @massDailyNoEmotion.
  ///
  /// In en, this message translates to:
  /// **'No emotion'**
  String get massDailyNoEmotion;

  /// No description provided for @massDailyImportance.
  ///
  /// In en, this message translates to:
  /// **'Importance'**
  String get massDailyImportance;

  /// No description provided for @massDailyBigGoal.
  ///
  /// In en, this message translates to:
  /// **'Big goal'**
  String get massDailyBigGoal;

  /// No description provided for @massDailyNoLink.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get massDailyNoLink;

  /// No description provided for @massDailyLoadingUserGoals.
  ///
  /// In en, this message translates to:
  /// **'Loading big goals...'**
  String get massDailyLoadingUserGoals;

  /// No description provided for @massDailyNoUserGoalsForCategory.
  ///
  /// In en, this message translates to:
  /// **'There are no big goals for this category yet.'**
  String get massDailyNoUserGoalsForCategory;

  /// No description provided for @massDailyHorizonTactical.
  ///
  /// In en, this message translates to:
  /// **'Tactical'**
  String get massDailyHorizonTactical;

  /// No description provided for @massDailyHorizonMid.
  ///
  /// In en, this message translates to:
  /// **'Mid-term'**
  String get massDailyHorizonMid;

  /// No description provided for @massDailyHorizonLong.
  ///
  /// In en, this message translates to:
  /// **'Long-term'**
  String get massDailyHorizonLong;

  /// No description provided for @massDailyLifeBlockGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get massDailyLifeBlockGeneral;

  /// No description provided for @massDailyLifeBlockHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get massDailyLifeBlockHealth;

  /// No description provided for @massDailyLifeBlockCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get massDailyLifeBlockCareer;

  /// No description provided for @massDailyLifeBlockFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get massDailyLifeBlockFamily;

  /// No description provided for @massDailyLifeBlockFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get massDailyLifeBlockFinance;

  /// No description provided for @massDailyLifeBlockEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get massDailyLifeBlockEducation;

  /// No description provided for @massDailyLifeBlockHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get massDailyLifeBlockHobbies;

  /// No description provided for @importJournalTextNotRecognized.
  ///
  /// In en, this message translates to:
  /// **'Text was not recognized. Try another photo.'**
  String get importJournalTextNotRecognized;

  /// No description provided for @importJournalRecognizedTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognized text'**
  String get importJournalRecognizedTextTitle;

  /// No description provided for @importJournalContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get importJournalContinue;

  /// No description provided for @importJournalUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get importJournalUntitled;

  /// No description provided for @importJournalNoTasksFound.
  ///
  /// In en, this message translates to:
  /// **'Could not extract tasks from the text.'**
  String get importJournalNoTasksFound;

  /// No description provided for @importJournalAddedGoals.
  ///
  /// In en, this message translates to:
  /// **'Added goals: {count}'**
  String importJournalAddedGoals(Object count);

  /// No description provided for @importJournalImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not import: {error}'**
  String importJournalImportFailed(Object error);

  /// No description provided for @importJournalVisionApiKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'VISION_API_KEY is not set. Run the app with --dart-define=VISION_API_KEY=...'**
  String get importJournalVisionApiKeyMissing;

  /// No description provided for @importJournalVisionApiError.
  ///
  /// In en, this message translates to:
  /// **'Vision API returned error {statusCode}: {body}'**
  String importJournalVisionApiError(Object statusCode, Object body);

  /// No description provided for @importJournalEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get importJournalEditTitle;

  /// No description provided for @importJournalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get importJournalNameLabel;

  /// No description provided for @importJournalTimeColon.
  ///
  /// In en, this message translates to:
  /// **'Time:'**
  String get importJournalTimeColon;

  /// No description provided for @importJournalHoursColon.
  ///
  /// In en, this message translates to:
  /// **'Hours:'**
  String get importJournalHoursColon;

  /// No description provided for @importJournalFoundTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Found tasks'**
  String get importJournalFoundTasksTitle;

  /// No description provided for @importJournalTaskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{time} • {hours} h'**
  String importJournalTaskSubtitle(Object time, Object hours);

  /// No description provided for @importJournalAddSelected.
  ///
  /// In en, this message translates to:
  /// **'Add selected'**
  String get importJournalAddSelected;

  /// No description provided for @recurringGoalSelectAtLeastOneWeekday.
  ///
  /// In en, this message translates to:
  /// **'Select at least one weekday'**
  String get recurringGoalSelectAtLeastOneWeekday;

  /// No description provided for @recurringGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring goal'**
  String get recurringGoalTitle;

  /// No description provided for @recurringGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Creates tasks from today until the selected date.'**
  String get recurringGoalSubtitle;

  /// No description provided for @recurringGoalDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get recurringGoalDetailsSection;

  /// No description provided for @recurringGoalTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal title'**
  String get recurringGoalTitleLabel;

  /// No description provided for @recurringGoalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Workout'**
  String get recurringGoalTitleHint;

  /// No description provided for @recurringGoalEmotionLabel.
  ///
  /// In en, this message translates to:
  /// **'Emotion'**
  String get recurringGoalEmotionLabel;

  /// No description provided for @recurringGoalEmotionHint.
  ///
  /// In en, this message translates to:
  /// **'For example: 💪 motivation'**
  String get recurringGoalEmotionHint;

  /// No description provided for @recurringGoalRegularitySection.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get recurringGoalRegularitySection;

  /// No description provided for @recurringGoalEveryNDays.
  ///
  /// In en, this message translates to:
  /// **'Every N days'**
  String get recurringGoalEveryNDays;

  /// No description provided for @recurringGoalByWeekdays.
  ///
  /// In en, this message translates to:
  /// **'By weekdays'**
  String get recurringGoalByWeekdays;

  /// No description provided for @recurringGoalIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get recurringGoalIntervalLabel;

  /// No description provided for @recurringGoalEveryNDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{count} d'**
  String recurringGoalEveryNDaysShort(Object count);

  /// No description provided for @recurringGoalWeekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get recurringGoalWeekdayMon;

  /// No description provided for @recurringGoalWeekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get recurringGoalWeekdayTue;

  /// No description provided for @recurringGoalWeekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get recurringGoalWeekdayWed;

  /// No description provided for @recurringGoalWeekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get recurringGoalWeekdayThu;

  /// No description provided for @recurringGoalWeekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get recurringGoalWeekdayFri;

  /// No description provided for @recurringGoalWeekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get recurringGoalWeekdaySat;

  /// No description provided for @recurringGoalWeekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get recurringGoalWeekdaySun;

  /// No description provided for @recurringGoalTimeButton.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String recurringGoalTimeButton(Object time);

  /// No description provided for @recurringGoalUntilButton.
  ///
  /// In en, this message translates to:
  /// **'Until: {date}'**
  String recurringGoalUntilButton(Object date);

  /// No description provided for @recurringGoalParametersSection.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get recurringGoalParametersSection;

  /// No description provided for @recurringGoalLifeBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'Life block'**
  String get recurringGoalLifeBlockLabel;

  /// No description provided for @recurringGoalImportanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Importance'**
  String get recurringGoalImportanceLabel;

  /// No description provided for @recurringGoalUserGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Big goal'**
  String get recurringGoalUserGoalLabel;

  /// No description provided for @recurringGoalNoLink.
  ///
  /// In en, this message translates to:
  /// **'No link'**
  String get recurringGoalNoLink;

  /// No description provided for @recurringGoalLoadingUserGoals.
  ///
  /// In en, this message translates to:
  /// **'Loading goals for “{block}”...'**
  String recurringGoalLoadingUserGoals(Object block);

  /// No description provided for @recurringGoalNoUserGoalsForBlock.
  ///
  /// In en, this message translates to:
  /// **'There are no available goals for “{block}” yet.'**
  String recurringGoalNoUserGoalsForBlock(Object block);

  /// No description provided for @recurringGoalPlannedHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Planned hours'**
  String get recurringGoalPlannedHoursLabel;

  /// No description provided for @recurringGoalOccurrencesCount.
  ///
  /// In en, this message translates to:
  /// **'Tasks to be created: {count}'**
  String recurringGoalOccurrencesCount(Object count);

  /// No description provided for @recurringGoalCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get recurringGoalCreate;

  /// No description provided for @recurringGoalLifeBlockGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get recurringGoalLifeBlockGeneral;

  /// No description provided for @recurringGoalLifeBlockHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get recurringGoalLifeBlockHealth;

  /// No description provided for @recurringGoalLifeBlockCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get recurringGoalLifeBlockCareer;

  /// No description provided for @recurringGoalLifeBlockFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get recurringGoalLifeBlockFinance;

  /// No description provided for @recurringGoalLifeBlockRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get recurringGoalLifeBlockRelationships;

  /// No description provided for @recurringGoalLifeBlockSelf.
  ///
  /// In en, this message translates to:
  /// **'Self-development'**
  String get recurringGoalLifeBlockSelf;

  /// No description provided for @recurringGoalLifeBlockEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get recurringGoalLifeBlockEducation;

  /// No description provided for @recurringGoalLifeBlockTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get recurringGoalLifeBlockTravel;

  /// No description provided for @recurringGoalLifeBlockHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get recurringGoalLifeBlockHome;

  /// No description provided for @recurringGoalHorizonTactical.
  ///
  /// In en, this message translates to:
  /// **'Tactical'**
  String get recurringGoalHorizonTactical;

  /// No description provided for @recurringGoalHorizonMid.
  ///
  /// In en, this message translates to:
  /// **'Mid-term'**
  String get recurringGoalHorizonMid;

  /// No description provided for @recurringGoalHorizonLong.
  ///
  /// In en, this message translates to:
  /// **'Long-term'**
  String get recurringGoalHorizonLong;

  /// No description provided for @addDayGoalLinkSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Link to a goal'**
  String get addDayGoalLinkSectionTitle;

  /// No description provided for @addDayGoalUserGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Big goal'**
  String get addDayGoalUserGoalLabel;

  /// No description provided for @addDayGoalNoLinkedGoal.
  ///
  /// In en, this message translates to:
  /// **'No link'**
  String get addDayGoalNoLinkedGoal;

  /// No description provided for @addDayGoalLoadingUserGoals.
  ///
  /// In en, this message translates to:
  /// **'Loading goals for “{block}”...'**
  String addDayGoalLoadingUserGoals(Object block);

  /// No description provided for @addDayGoalNoUserGoalsForBlock.
  ///
  /// In en, this message translates to:
  /// **'There are no available goals for “{block}” yet.'**
  String addDayGoalNoUserGoalsForBlock(Object block);

  /// No description provided for @addDayGoalLifeBlockGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get addDayGoalLifeBlockGeneral;

  /// No description provided for @addDayGoalLifeBlockHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get addDayGoalLifeBlockHealth;

  /// No description provided for @addDayGoalLifeBlockCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get addDayGoalLifeBlockCareer;

  /// No description provided for @addDayGoalLifeBlockFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get addDayGoalLifeBlockFinance;

  /// No description provided for @addDayGoalLifeBlockRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get addDayGoalLifeBlockRelationships;

  /// No description provided for @addDayGoalLifeBlockSelf.
  ///
  /// In en, this message translates to:
  /// **'Self-development'**
  String get addDayGoalLifeBlockSelf;

  /// No description provided for @addDayGoalLifeBlockEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get addDayGoalLifeBlockEducation;

  /// No description provided for @addDayGoalLifeBlockTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get addDayGoalLifeBlockTravel;

  /// No description provided for @addDayGoalLifeBlockHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get addDayGoalLifeBlockHome;

  /// No description provided for @addDayGoalHorizonTactical.
  ///
  /// In en, this message translates to:
  /// **'Tactical'**
  String get addDayGoalHorizonTactical;

  /// No description provided for @addDayGoalHorizonMid.
  ///
  /// In en, this message translates to:
  /// **'Mid-term'**
  String get addDayGoalHorizonMid;

  /// No description provided for @addDayGoalHorizonLong.
  ///
  /// In en, this message translates to:
  /// **'Long-term'**
  String get addDayGoalHorizonLong;

  /// No description provided for @lifeBlockSelf.
  ///
  /// In en, this message translates to:
  /// **'Self-development'**
  String get lifeBlockSelf;

  /// No description provided for @lifeBlockTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get lifeBlockTravel;

  /// No description provided for @lifeBlockHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get lifeBlockHome;

  /// No description provided for @horizonTactical.
  ///
  /// In en, this message translates to:
  /// **'Tactical'**
  String get horizonTactical;

  /// No description provided for @horizonMid.
  ///
  /// In en, this message translates to:
  /// **'Mid-term'**
  String get horizonMid;

  /// No description provided for @horizonLong.
  ///
  /// In en, this message translates to:
  /// **'Long-term'**
  String get horizonLong;

  /// No description provided for @editGoalSectionDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get editGoalSectionDateTime;

  /// No description provided for @editGoalSectionUserGoalLink.
  ///
  /// In en, this message translates to:
  /// **'Link to a larger goal'**
  String get editGoalSectionUserGoalLink;

  /// No description provided for @userGoalLinkFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Larger goal'**
  String get userGoalLinkFieldLabel;

  /// No description provided for @userGoalLinkNone.
  ///
  /// In en, this message translates to:
  /// **'No link'**
  String get userGoalLinkNone;

  /// No description provided for @userGoalLinkLoadingForBlock.
  ///
  /// In en, this message translates to:
  /// **'Loading goals for “{block}”...'**
  String userGoalLinkLoadingForBlock(Object block);

  /// No description provided for @userGoalLinkNoGoalsForBlock.
  ///
  /// In en, this message translates to:
  /// **'No available goals for “{block}” yet.'**
  String userGoalLinkNoGoalsForBlock(Object block);

  /// No description provided for @editGoalHoursValue.
  ///
  /// In en, this message translates to:
  /// **'Hours: {hours}'**
  String editGoalHoursValue(Object hours);

  /// No description provided for @commonHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String commonHoursShort(Object hours);

  /// No description provided for @healthTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Health tracker'**
  String get healthTrackerTitle;

  /// No description provided for @healthCalorieTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Calorie target'**
  String get healthCalorieTargetTitle;

  /// No description provided for @healthDailyCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Kcal per day'**
  String get healthDailyCaloriesLabel;

  /// No description provided for @healthAddMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get healthAddMealTitle;

  /// No description provided for @healthMealTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get healthMealTypeLabel;

  /// No description provided for @healthMealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get healthMealBreakfast;

  /// No description provided for @healthMealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get healthMealLunch;

  /// No description provided for @healthMealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get healthMealDinner;

  /// No description provided for @healthMealSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get healthMealSnack;

  /// No description provided for @healthCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get healthCaloriesLabel;

  /// No description provided for @healthEnterCalories.
  ///
  /// In en, this message translates to:
  /// **'Enter calories'**
  String get healthEnterCalories;

  /// No description provided for @healthMealDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'What did you eat?'**
  String get healthMealDescriptionLabel;

  /// No description provided for @healthAddDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a description'**
  String get healthAddDescription;

  /// No description provided for @healthAddBurnTitle.
  ///
  /// In en, this message translates to:
  /// **'Add calories burned'**
  String get healthAddBurnTitle;

  /// No description provided for @healthCaloriesBurnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories burned'**
  String get healthCaloriesBurnedLabel;

  /// No description provided for @healthCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get healthCommentLabel;

  /// No description provided for @healthWaterTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'How much water did you drink today?'**
  String get healthWaterTodayTitle;

  /// No description provided for @healthSaveWater.
  ///
  /// In en, this message translates to:
  /// **'Save water'**
  String get healthSaveWater;

  /// No description provided for @healthSetTarget.
  ///
  /// In en, this message translates to:
  /// **'Set target'**
  String get healthSetTarget;

  /// No description provided for @healthTargetCalories.
  ///
  /// In en, this message translates to:
  /// **'Target {calories} kcal'**
  String healthTargetCalories(Object calories);

  /// No description provided for @healthAddMealButton.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get healthAddMealButton;

  /// No description provided for @healthAddBurnButton.
  ///
  /// In en, this message translates to:
  /// **'Add burn'**
  String get healthAddBurnButton;

  /// No description provided for @healthWaterButton.
  ///
  /// In en, this message translates to:
  /// **'Water {liters} L'**
  String healthWaterButton(Object liters);

  /// No description provided for @healthConsumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get healthConsumed;

  /// No description provided for @healthBurned.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get healthBurned;

  /// No description provided for @healthBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get healthBalance;

  /// No description provided for @healthDeltaVsTarget.
  ///
  /// In en, this message translates to:
  /// **'Delta vs target'**
  String get healthDeltaVsTarget;

  /// No description provided for @healthWaterDrunk.
  ///
  /// In en, this message translates to:
  /// **'Water drunk'**
  String get healthWaterDrunk;

  /// No description provided for @healthKcalValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String healthKcalValue(Object value);

  /// No description provided for @healthKcalValueWithSign.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String healthKcalValueWithSign(Object value);

  /// No description provided for @healthLitersValue.
  ///
  /// In en, this message translates to:
  /// **'{value} L'**
  String healthLitersValue(Object value);

  /// No description provided for @healthMealsTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Meals today'**
  String get healthMealsTodayTitle;

  /// No description provided for @healthNoMeals.
  ///
  /// In en, this message translates to:
  /// **'No meal entries yet.'**
  String get healthNoMeals;

  /// No description provided for @healthBurnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Calories burned'**
  String get healthBurnsTitle;

  /// No description provided for @healthNoBurns.
  ///
  /// In en, this message translates to:
  /// **'No burned-calorie entries yet.'**
  String get healthNoBurns;

  /// No description provided for @healthNoComment.
  ///
  /// In en, this message translates to:
  /// **'No comment'**
  String get healthNoComment;

  /// No description provided for @hobbyTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Hobby tracker'**
  String get hobbyTrackerTitle;

  /// No description provided for @hobbyTrackerNewHobbyTitle.
  ///
  /// In en, this message translates to:
  /// **'New hobby'**
  String get hobbyTrackerNewHobbyTitle;

  /// No description provided for @hobbyTrackerHobbyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Hobby name'**
  String get hobbyTrackerHobbyNameLabel;

  /// No description provided for @hobbyTrackerEnterHobbyValidator.
  ///
  /// In en, this message translates to:
  /// **'Enter a hobby'**
  String get hobbyTrackerEnterHobbyValidator;

  /// No description provided for @hobbyTrackerWeeklyGoalMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal, minutes'**
  String get hobbyTrackerWeeklyGoalMinutesLabel;

  /// No description provided for @hobbyTrackerEnterGoalValidator.
  ///
  /// In en, this message translates to:
  /// **'Enter a goal'**
  String get hobbyTrackerEnterGoalValidator;

  /// No description provided for @hobbyTrackerCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get hobbyTrackerCreateButton;

  /// No description provided for @hobbyTrackerAddTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add time: {title}'**
  String hobbyTrackerAddTimeTitle(Object title);

  /// No description provided for @hobbyTrackerMinutesSpentLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes spent'**
  String get hobbyTrackerMinutesSpentLabel;

  /// No description provided for @hobbyTrackerNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get hobbyTrackerNoteLabel;

  /// No description provided for @hobbyTrackerDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete hobby?'**
  String get hobbyTrackerDeleteConfirmTitle;

  /// No description provided for @hobbyTrackerDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Hobby \"{title}\" will be deleted together with all entries.'**
  String hobbyTrackerDeleteConfirmBody(Object title);

  /// No description provided for @hobbyTrackerAddHobbyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add hobby'**
  String get hobbyTrackerAddHobbyTooltip;

  /// No description provided for @hobbyTrackerEmptyText.
  ///
  /// In en, this message translates to:
  /// **'No hobbies yet. Add your first activity and start tracking time.'**
  String get hobbyTrackerEmptyText;

  /// No description provided for @hobbyTrackerCreateHobbyButton.
  ///
  /// In en, this message translates to:
  /// **'Create hobby'**
  String get hobbyTrackerCreateHobbyButton;

  /// No description provided for @hobbyTrackerDeleteHobbyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete hobby'**
  String get hobbyTrackerDeleteHobbyTooltip;

  /// No description provided for @hobbyTrackerAddEntryButton.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get hobbyTrackerAddEntryButton;

  /// No description provided for @hobbyTrackerToday.
  ///
  /// In en, this message translates to:
  /// **'Today {value}'**
  String hobbyTrackerToday(Object value);

  /// No description provided for @hobbyTrackerWeek.
  ///
  /// In en, this message translates to:
  /// **'Week {value}'**
  String hobbyTrackerWeek(Object value);

  /// No description provided for @hobbyTrackerGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal: {value}'**
  String hobbyTrackerGoal(Object value);

  /// No description provided for @hobbyTrackerMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String hobbyTrackerMinutesShort(Object minutes);

  /// No description provided for @hobbyTrackerHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String hobbyTrackerHoursShort(Object hours);

  /// No description provided for @hobbyTrackerHoursMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String hobbyTrackerHoursMinutesShort(Object hours, Object minutes);

  /// No description provided for @importGoalsReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Import goals'**
  String get importGoalsReviewTitle;

  /// No description provided for @importGoalsReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select what to import and adjust the title or description if needed.'**
  String get importGoalsReviewSubtitle;

  /// No description provided for @importGoalsReviewSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get importGoalsReviewSelectAll;

  /// No description provided for @importGoalsReviewYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get importGoalsReviewYes;

  /// No description provided for @importGoalsReviewNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get importGoalsReviewNo;

  /// No description provided for @importGoalsReviewListSection.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get importGoalsReviewListSection;

  /// No description provided for @importGoalsReviewImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importGoalsReviewImport;

  /// No description provided for @importGoalsReviewFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get importGoalsReviewFieldTitle;

  /// No description provided for @importGoalsReviewFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get importGoalsReviewFieldDescription;

  /// No description provided for @importGoalsReviewTime.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String importGoalsReviewTime(Object time);

  /// No description provided for @importGoalsReviewChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get importGoalsReviewChange;

  /// No description provided for @shoppingBasketCopyHeader.
  ///
  /// In en, this message translates to:
  /// **'🛒 Shopping list'**
  String get shoppingBasketCopyHeader;

  /// No description provided for @shoppingDueDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'by {date}'**
  String shoppingDueDatePrefix(Object date);

  /// No description provided for @shoppingBasketCopied.
  ///
  /// In en, this message translates to:
  /// **'Shopping list copied'**
  String get shoppingBasketCopied;

  /// No description provided for @shoppingNewWishlistItem.
  ///
  /// In en, this message translates to:
  /// **'New wish item'**
  String get shoppingNewWishlistItem;

  /// No description provided for @shoppingNewPurchase.
  ///
  /// In en, this message translates to:
  /// **'New purchase'**
  String get shoppingNewPurchase;

  /// No description provided for @shoppingEditItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get shoppingEditItem;

  /// No description provided for @shoppingFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get shoppingFieldTitle;

  /// No description provided for @shoppingEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get shoppingEnterTitle;

  /// No description provided for @shoppingFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get shoppingFieldDescription;

  /// No description provided for @shoppingFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get shoppingFieldPrice;

  /// No description provided for @shoppingFieldStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get shoppingFieldStore;

  /// No description provided for @shoppingFieldExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense category'**
  String get shoppingFieldExpenseCategory;

  /// No description provided for @shoppingNoCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get shoppingNoCategory;

  /// No description provided for @shoppingAlreadyBought.
  ///
  /// In en, this message translates to:
  /// **'Already bought'**
  String get shoppingAlreadyBought;

  /// No description provided for @shoppingPurchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase date'**
  String get shoppingPurchaseDate;

  /// No description provided for @shoppingReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get shoppingReset;

  /// No description provided for @shoppingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty for now.'**
  String get shoppingEmpty;

  /// No description provided for @shoppingTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping tracker'**
  String get shoppingTrackerTitle;

  /// No description provided for @shoppingCopyBasket.
  ///
  /// In en, this message translates to:
  /// **'Copy basket'**
  String get shoppingCopyBasket;

  /// No description provided for @shoppingBasketTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingBasketTitle;

  /// No description provided for @shoppingWishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get shoppingWishlistTitle;

  /// No description provided for @profileOpenLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get profileOpenLinkFailed;

  /// No description provided for @profileDangerZoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account deletion'**
  String get profileDangerZoneSubtitle;

  /// No description provided for @profileLegalDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal documents'**
  String get profileLegalDocumentsTitle;

  /// No description provided for @profileLegalDocumentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can open the Privacy Policy, Datenschutz, Terms of Use, and Impressum at any time.'**
  String get profileLegalDocumentsSubtitle;

  /// No description provided for @profileLegalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profileLegalPrivacyTitle;

  /// No description provided for @profileLegalPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'English version of the privacy policy'**
  String get profileLegalPrivacySubtitle;

  /// No description provided for @profileLegalDatenschutzTitle.
  ///
  /// In en, this message translates to:
  /// **'Datenschutzerklärung'**
  String get profileLegalDatenschutzTitle;

  /// No description provided for @profileLegalDatenschutzSubtitle.
  ///
  /// In en, this message translates to:
  /// **'German version of the privacy policy'**
  String get profileLegalDatenschutzSubtitle;

  /// No description provided for @profileLegalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get profileLegalTermsTitle;

  /// No description provided for @profileLegalTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rules and conditions for using Ladna'**
  String get profileLegalTermsSubtitle;

  /// No description provided for @profileLegalImpressumTitle.
  ///
  /// In en, this message translates to:
  /// **'Impressum'**
  String get profileLegalImpressumTitle;

  /// No description provided for @profileLegalImpressumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Legal notice and provider information'**
  String get profileLegalImpressumSubtitle;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRussian;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get settingsLanguageGerman;

  /// No description provided for @settingsLanguageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get settingsLanguageFrench;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get settingsLanguageTurkish;

  /// No description provided for @profileWebNotificationsEveningBody.
  ///
  /// In en, this message translates to:
  /// **'Mark your habits and wrap up your day 👌'**
  String get profileWebNotificationsEveningBody;

  /// No description provided for @profileWebNotificationsPermissionDeniedToast.
  ///
  /// In en, this message translates to:
  /// **'Permission was not granted. Check your browser notification settings.'**
  String get profileWebNotificationsPermissionDeniedToast;

  /// No description provided for @profileWebNotificationsPermissionGrantedToast.
  ///
  /// In en, this message translates to:
  /// **'Browser notifications are enabled ✅'**
  String get profileWebNotificationsPermissionGrantedToast;

  /// No description provided for @profileWebNotificationsTimeChangedToast.
  ///
  /// In en, this message translates to:
  /// **'Notification time: {time}'**
  String profileWebNotificationsTimeChangedToast(Object time);

  /// No description provided for @profileWebNotificationsLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Loading settings...'**
  String get profileWebNotificationsLoadingSettings;

  /// No description provided for @profileWebNotificationsEnabledToast.
  ///
  /// In en, this message translates to:
  /// **'Enabled. Remember to allow notifications in your browser.'**
  String get profileWebNotificationsEnabledToast;

  /// No description provided for @profileWebNotificationsDisabledToast.
  ///
  /// In en, this message translates to:
  /// **'Disabled.'**
  String get profileWebNotificationsDisabledToast;

  /// No description provided for @profileEditChipsDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'Enter values separated by commas'**
  String get profileEditChipsDefaultHint;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Ladna'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'I’ll quickly show you the main features: quick actions, tasks, big goals, profile, reports, and finances.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// No description provided for @onboardingFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onboardingFinishTitle;

  /// No description provided for @onboardingFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Now you know where the main Ladna features are. You can restart the tutorial later from the help icon on the home screen.'**
  String get onboardingFinishBody;

  /// No description provided for @onboardingGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get onboardingGotIt;

  /// No description provided for @onboardingMainQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get onboardingMainQuickActionsTitle;

  /// No description provided for @onboardingMainQuickActionsText.
  ///
  /// In en, this message translates to:
  /// **'Use this button to quickly add tasks, mood, expenses, habits, and launch the AI plan.'**
  String get onboardingMainQuickActionsText;

  /// No description provided for @onboardingMainNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Ladna navigation'**
  String get onboardingMainNavigationTitle;

  /// No description provided for @onboardingMainNavigationText.
  ///
  /// In en, this message translates to:
  /// **'Here you’ll find the main sections: home, tasks, big goals, profile, reports, and finances.'**
  String get onboardingMainNavigationText;

  /// No description provided for @onboardingMainHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Open the guide again'**
  String get onboardingMainHelpTitle;

  /// No description provided for @onboardingMainHelpText.
  ///
  /// In en, this message translates to:
  /// **'Tap this icon whenever you want to repeat the interactive How-To later.'**
  String get onboardingMainHelpText;

  /// No description provided for @onboardingGoalsFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Life area filter'**
  String get onboardingGoalsFilterTitle;

  /// No description provided for @onboardingGoalsFilterText.
  ///
  /// In en, this message translates to:
  /// **'Choose career, health, finance, and other areas to view tasks in the right context.'**
  String get onboardingGoalsFilterText;

  /// No description provided for @onboardingGoalsModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard or calendar'**
  String get onboardingGoalsModeTitle;

  /// No description provided for @onboardingGoalsModeText.
  ///
  /// In en, this message translates to:
  /// **'The dashboard shows the big picture, while the calendar helps you plan tasks by day and week.'**
  String get onboardingGoalsModeText;

  /// No description provided for @onboardingGoalsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add actions'**
  String get onboardingGoalsAddTitle;

  /// No description provided for @onboardingGoalsAddText.
  ///
  /// In en, this message translates to:
  /// **'Here you can quickly add a task, a task series, or fill a whole day with several entries.'**
  String get onboardingGoalsAddText;

  /// No description provided for @onboardingReportsPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis period'**
  String get onboardingReportsPeriodTitle;

  /// No description provided for @onboardingReportsPeriodText.
  ///
  /// In en, this message translates to:
  /// **'Switch between day, week, and month to compare goals, mood, habits, and finances over time.'**
  String get onboardingReportsPeriodText;

  /// No description provided for @onboardingReportsChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive charts'**
  String get onboardingReportsChartTitle;

  /// No description provided for @onboardingReportsChartText.
  ///
  /// In en, this message translates to:
  /// **'Tap chart segments and points — the app will show details for the selected element only.'**
  String get onboardingReportsChartText;

  /// No description provided for @onboardingUserGoalsHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Big goals'**
  String get onboardingUserGoalsHeaderTitle;

  /// No description provided for @onboardingUserGoalsHeaderText.
  ///
  /// In en, this message translates to:
  /// **'This is where strategic goals are stored: short-term, mid-term, and long-term. Later, you can link daily tasks to them.'**
  String get onboardingUserGoalsHeaderText;

  /// No description provided for @onboardingUserGoalsFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal filters'**
  String get onboardingUserGoalsFiltersTitle;

  /// No description provided for @onboardingUserGoalsFiltersText.
  ///
  /// In en, this message translates to:
  /// **'Filter goals by life area and horizon to quickly focus on the direction you need.'**
  String get onboardingUserGoalsFiltersText;

  /// No description provided for @onboardingUserGoalsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a big goal'**
  String get onboardingUserGoalsAddTitle;

  /// No description provided for @onboardingUserGoalsAddText.
  ///
  /// In en, this message translates to:
  /// **'Tap here to add a goal, choose a life area, horizon, and deadline.'**
  String get onboardingUserGoalsAddText;

  /// No description provided for @onboardingProfileHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get onboardingProfileHeaderTitle;

  /// No description provided for @onboardingProfileHeaderText.
  ///
  /// In en, this message translates to:
  /// **'This is the center for personal Ladna settings: account, focus, habits, and app preferences.'**
  String get onboardingProfileHeaderText;

  /// No description provided for @onboardingProfileCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get onboardingProfileCardTitle;

  /// No description provided for @onboardingProfileCardText.
  ///
  /// In en, this message translates to:
  /// **'Name, age, and basic parameters are used to personalize the interface and future AI recommendations.'**
  String get onboardingProfileCardText;

  /// No description provided for @onboardingProfileFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus and settings'**
  String get onboardingProfileFocusTitle;

  /// No description provided for @onboardingProfileFocusText.
  ///
  /// In en, this message translates to:
  /// **'These parameters influence day planning, analytics, and recommendations in the app.'**
  String get onboardingProfileFocusText;

  /// No description provided for @onboardingBudgetIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Income categories'**
  String get onboardingBudgetIncomeTitle;

  /// No description provided for @onboardingBudgetIncomeText.
  ///
  /// In en, this message translates to:
  /// **'Add income sources so financial analytics can understand the structure of your inflows.'**
  String get onboardingBudgetIncomeText;

  /// No description provided for @onboardingBudgetExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense categories'**
  String get onboardingBudgetExpenseTitle;

  /// No description provided for @onboardingBudgetExpenseText.
  ///
  /// In en, this message translates to:
  /// **'Set up expense categories and limits here. This helps you see where your budget is going fastest.'**
  String get onboardingBudgetExpenseText;

  /// No description provided for @onboardingBudgetJarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Jars and allocation'**
  String get onboardingBudgetJarsTitle;

  /// No description provided for @onboardingBudgetJarsText.
  ///
  /// In en, this message translates to:
  /// **'Use jars for savings goals: travel, emergency fund, investments, or large purchases.'**
  String get onboardingBudgetJarsText;

  /// No description provided for @onboardingBudgetSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get onboardingBudgetSaveTitle;

  /// No description provided for @onboardingBudgetSaveText.
  ///
  /// In en, this message translates to:
  /// **'After making changes, don’t forget to save your budget so categories and limits are stored in the database.'**
  String get onboardingBudgetSaveText;

  /// No description provided for @onboardingDayGoalsSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Day summary'**
  String get onboardingDayGoalsSummaryTitle;

  /// No description provided for @onboardingDayGoalsSummaryText.
  ///
  /// In en, this message translates to:
  /// **'This card shows your day progress: how many tasks are done, what remains, and how much time is still planned.'**
  String get onboardingDayGoalsSummaryText;

  /// No description provided for @onboardingDayGoalsFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide completed'**
  String get onboardingDayGoalsFilterTitle;

  /// No description provided for @onboardingDayGoalsFilterText.
  ///
  /// In en, this message translates to:
  /// **'Turn on this filter to keep only active tasks on the screen.'**
  String get onboardingDayGoalsFilterText;

  /// No description provided for @onboardingDayGoalsFabTitle.
  ///
  /// In en, this message translates to:
  /// **'Add activity'**
  String get onboardingDayGoalsFabTitle;

  /// No description provided for @onboardingDayGoalsFabText.
  ///
  /// In en, this message translates to:
  /// **'Use this button to add a task, recognize a journal entry, or sync Google Calendar.'**
  String get onboardingDayGoalsFabText;

  /// No description provided for @onboardingQuestionnaireProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup progress'**
  String get onboardingQuestionnaireProgressTitle;

  /// No description provided for @onboardingQuestionnaireProgressText.
  ///
  /// In en, this message translates to:
  /// **'Here you can see which step of the initial setup you’re currently on.'**
  String get onboardingQuestionnaireProgressText;

  /// No description provided for @onboardingQuestionnaireNextTitle.
  ///
  /// In en, this message translates to:
  /// **'Move forward'**
  String get onboardingQuestionnaireNextTitle;

  /// No description provided for @onboardingQuestionnaireNextText.
  ///
  /// In en, this message translates to:
  /// **'After completing the current step, tap here. At the end, Ladna will save your profile, life areas, and goals.'**
  String get onboardingQuestionnaireNextText;

  /// No description provided for @onboardingExpensesControlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Day and budget settings'**
  String get onboardingExpensesControlsTitle;

  /// No description provided for @onboardingExpensesControlsText.
  ///
  /// In en, this message translates to:
  /// **'Choose the operation date here and open settings for categories, limits, and jars.'**
  String get onboardingExpensesControlsText;

  /// No description provided for @onboardingExpensesSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly finance summary'**
  String get onboardingExpensesSummaryTitle;

  /// No description provided for @onboardingExpensesSummaryText.
  ///
  /// In en, this message translates to:
  /// **'This card shows monthly income, expenses, and free balance — the foundation for budget analysis.'**
  String get onboardingExpensesSummaryText;

  /// No description provided for @onboardingExpensesTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions for the selected day'**
  String get onboardingExpensesTransactionsTitle;

  /// No description provided for @onboardingExpensesTransactionsText.
  ///
  /// In en, this message translates to:
  /// **'Here you can see income and expenses for the day. Tap a transaction to edit it, or swipe left to delete it.'**
  String get onboardingExpensesTransactionsText;

  /// No description provided for @onboardingExpensesFabTitle.
  ///
  /// In en, this message translates to:
  /// **'Add income or expense'**
  String get onboardingExpensesFabTitle;

  /// No description provided for @onboardingExpensesFabText.
  ///
  /// In en, this message translates to:
  /// **'Tap plus to open the menu and quickly add a new financial transaction.'**
  String get onboardingExpensesFabText;

  /// No description provided for @onboardingNextHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the screen to continue'**
  String get onboardingNextHint;

  /// No description provided for @registerLegalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get registerLegalTermsTitle;

  /// No description provided for @registerLegalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get registerLegalPrivacyTitle;

  /// No description provided for @registerLegalDatenschutzTitle.
  ///
  /// In en, this message translates to:
  /// **'Datenschutzerklärung'**
  String get registerLegalDatenschutzTitle;

  /// No description provided for @registerLegalImpressumTitle.
  ///
  /// In en, this message translates to:
  /// **'Impressum'**
  String get registerLegalImpressumTitle;

  /// No description provided for @registerLegalOptionalTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} · optional'**
  String registerLegalOptionalTitle(Object title);

  /// No description provided for @registerErrOpenRequiredLegalDocs.
  ///
  /// In en, this message translates to:
  /// **'Please open and read Terms of Use and Privacy Policy first.'**
  String get registerErrOpenRequiredLegalDocs;

  /// No description provided for @registerLegalOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open {document}.'**
  String registerLegalOpenFailed(Object document);

  /// No description provided for @registerLegalAcceptedText.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the Terms of Use and Privacy Policy.'**
  String get registerLegalAcceptedText;

  /// No description provided for @registerLegalOpenRequiredDocsText.
  ///
  /// In en, this message translates to:
  /// **'Open and read Terms of Use and Privacy Policy first. Datenschutzerklärung and Impressum are available as additional legal information.'**
  String get registerLegalOpenRequiredDocsText;

  /// No description provided for @launcherDayGoals.
  ///
  /// In en, this message translates to:
  /// **'Day goals'**
  String get launcherDayGoals;

  /// No description provided for @launcherPlannedHoursDescription.
  ///
  /// In en, this message translates to:
  /// **'Plan: {hours} h'**
  String launcherPlannedHoursDescription(Object hours);
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
