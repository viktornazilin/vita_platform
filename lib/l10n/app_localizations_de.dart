// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Nest App';

  @override
  String get login => 'Anmelden';

  @override
  String get register => 'Registrieren';

  @override
  String get home => 'Start';

  @override
  String get budgetSetupTitle => 'Budget & Spargläser';

  @override
  String get budgetSetupSaved => 'Einstellungen gespeichert';

  @override
  String get budgetSetupSaveError => 'Fehler beim Speichern';

  @override
  String get budgetIncomeCategoriesTitle => 'Einnahmenkategorien';

  @override
  String get budgetIncomeCategoriesSubtitle =>
      'Werden beim Hinzufügen von Einnahmen verwendet';

  @override
  String get settingsLanguageTitle => 'Sprache';

  @override
  String get settingsLanguageSubtitle =>
      'Wähle die App-Sprache. „System“ nutzt die Gerätesprache.';

  @override
  String get budgetExpenseCategoriesTitle => 'Ausgabenkategorien';

  @override
  String get budgetExpenseCategoriesSubtitle =>
      'Limits helfen dir, Ausgaben im Griff zu behalten';

  @override
  String get budgetJarsTitle => 'Sparziele';

  @override
  String get budgetJarsSubtitle =>
      'Prozent = Anteil der freien Mittel, der automatisch zugewiesen wird';

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
  String get budgetNewIncomeCategory => 'Neue Einnahmenkategorie';

  @override
  String get budgetNewExpenseCategory => 'Neue Ausgabenkategorie';

  @override
  String get budgetCategoryNameHint => 'Z. B.: Gehalt / Essen / Verkehr';

  @override
  String get budgetAddJar => 'Sparziel hinzufügen';

  @override
  String get budgetJarAdded => 'Sparziel hinzugefügt';

  @override
  String budgetJarAddFailed(Object error) {
    return 'Hinzufügen fehlgeschlagen: $error';
  }

  @override
  String get budgetJarDeleted => 'Sparziel gelöscht';

  @override
  String budgetJarDeleteFailed(Object error) {
    return 'Löschen fehlgeschlagen: $error';
  }

  @override
  String get budgetNoJarsTitle => 'Noch keine Sparziele';

  @override
  String get budgetNoJarsSubtitle =>
      'Erstelle dein erstes Sparziel — wir helfen dir dabei.';

  @override
  String get budgetSetOrChangeLimit => 'Limit festlegen/ändern';

  @override
  String get budgetDeleteCategoryTitle => 'Kategorie löschen?';

  @override
  String budgetCategoryLabel(Object name) {
    return 'Kategorie: $name';
  }

  @override
  String get budgetDeleteJarTitle => 'Sparziel löschen?';

  @override
  String budgetJarLabel(Object title) {
    return 'Sparziel: $title';
  }

  @override
  String budgetJarSummary(Object saved, Object percent, Object targetPart) {
    return 'Gespart: $saved ₽ • Prozent: $percent%$targetPart';
  }

  @override
  String get commonAdd => 'Hinzufügen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonLoading => 'lädt…';

  @override
  String get commonSaving => 'Speichern…';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonUpdate => 'Aktualisieren';

  @override
  String get commonCollapse => 'Einklappen';

  @override
  String get commonDots => '...';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonNext => 'Weiter';

  @override
  String get commonDone => 'Fertig';

  @override
  String get commonChange => 'Ändern';

  @override
  String get commonDate => 'Datum';

  @override
  String get commonRefresh => 'Aktualisieren';

  @override
  String get commonDash => '—';

  @override
  String get commonPick => 'Auswählen';

  @override
  String get commonRemove => 'Entfernen';

  @override
  String get commonOr => 'oder';

  @override
  String get commonCreate => 'Erstellen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonCloseTooltip => 'Schließen';

  @override
  String get commonTitle => 'Titel';

  @override
  String get commonDeleteConfirmTitle => 'Eintrag löschen?';

  @override
  String get dayGoalsAllLifeBlocks => 'Alle Bereiche';

  @override
  String get dayGoalsEmpty => 'Keine Ziele für diesen Tag';

  @override
  String dayGoalsAddFailed(Object error) {
    return 'Ziel konnte nicht hinzugefügt werden: $error';
  }

  @override
  String get dayGoalsUpdated => 'Ziel aktualisiert';

  @override
  String dayGoalsUpdateFailed(Object error) {
    return 'Ziel konnte nicht aktualisiert werden: $error';
  }

  @override
  String get dayGoalsDeleted => 'Ziel gelöscht';

  @override
  String dayGoalsDeleteFailed(Object error) {
    return 'Löschen fehlgeschlagen: $error';
  }

  @override
  String dayGoalsToggleFailed(Object error) {
    return 'Status konnte nicht geändert werden: $error';
  }

  @override
  String get dayGoalsDeleteConfirmTitle => 'Ziel löschen?';

  @override
  String get dayGoalsFabAddTitle => 'Ziel hinzufügen';

  @override
  String get dayGoalsFabAddSubtitle => 'Manuell erstellen';

  @override
  String get dayGoalsFabScanTitle => 'Scan';

  @override
  String get dayGoalsFabScanSubtitle => 'Foto des Planers';

  @override
  String get dayGoalsFabCalendarTitle => 'Google Calendar';

  @override
  String get dayGoalsFabCalendarSubtitle => 'Import/Export der heutigen Ziele';

  @override
  String get epicIntroSkip => 'Überspringen';

  @override
  String get epicIntroSubtitle =>
      'Ein Zuhause für Gedanken. Ein Ort, an dem Ziele,\nTräume und Pläne wachsen — achtsam und behutsam.';

  @override
  String get epicIntroPrimaryCta => 'Meine Reise starten';

  @override
  String get epicIntroLater => 'Später';

  @override
  String get epicIntroSecondaryCta => 'Zum Login';

  @override
  String get epicIntroFooter =>
      'Du kannst jederzeit in den Einstellungen zum Prolog zurückkehren.';

  @override
  String get homeMoodSaved => 'Stimmung gespeichert';

  @override
  String homeMoodSaveFailed(Object error) {
    return 'Speichern fehlgeschlagen: $error';
  }

  @override
  String get homeTodayAndWeekTitle => 'Heute & Woche';

  @override
  String get homeTodayAndWeekSubtitle =>
      'Kurzer Überblick — alle wichtigen Kennzahlen auf einen Blick';

  @override
  String get homeMetricMoodTitle => 'Stimmung';

  @override
  String get homeMoodNoEntry => 'kein Eintrag';

  @override
  String get homeMoodNoNote => 'keine Notiz';

  @override
  String get homeMoodHasNote => 'mit Notiz';

  @override
  String get homeMetricTasksTitle => 'Aufgaben';

  @override
  String get homeMetricHoursPerDayTitle => 'Stunden/Tag';

  @override
  String get homeMetricEfficiencyTitle => 'Effizienz';

  @override
  String homeEfficiencyPlannedHours(Object hours) {
    return 'Plan ${hours}h';
  }

  @override
  String get homeMoodTodayTitle => 'Stimmung heute';

  @override
  String get homeMoodNoTodayEntry => 'Kein Eintrag für heute';

  @override
  String get homeMoodEntryNoNote => 'Eintrag vorhanden (ohne Notiz)';

  @override
  String get homeMoodQuickHint => 'Kurzer Check-in — dauert 10 Sekunden';

  @override
  String get homeMoodUpdateHint =>
      'Du kannst aktualisieren — der Eintrag für heute wird überschrieben';

  @override
  String get homeMoodNoteLabel => 'Notiz (optional)';

  @override
  String get homeMoodNoteHint => 'Was hat deinen Zustand beeinflusst?';

  @override
  String get homeOpenMoodHistoryCta => 'Stimmungsverlauf öffnen';

  @override
  String get homeWeekSummaryTitle => 'Wochenübersicht';

  @override
  String get homeOpenReportsCta => 'Detaillierte Berichte öffnen';

  @override
  String get homeWeekExpensesTitle => 'Wochenausgaben';

  @override
  String get homeNoExpensesThisWeek => 'Keine Ausgaben diese Woche';

  @override
  String get homeOpenExpensesCta => 'Ausgaben öffnen';

  @override
  String homeExpensesTotal(Object total) {
    return 'Gesamt: $total €';
  }

  @override
  String homeExpensesAvgPerDay(Object avg) {
    return 'Ø pro Tag: $avg €';
  }

  @override
  String get homeInsightsTitle => 'Insights';

  @override
  String homeTopCategory(Object category, Object amount) {
    return '• Top-Kategorie: $category — $amount €';
  }

  @override
  String homePeakExpense(Object day, Object amount) {
    return '• Ausgaben-Peak: $day — $amount €';
  }

  @override
  String get homeOpenDetailedExpensesCta => 'Detaillierte Ausgaben öffnen';

  @override
  String get homeWeekCardTitle => 'Woche';

  @override
  String get homeWeekLoadFailedTitle => 'Statistik konnte nicht geladen werden';

  @override
  String get homeWeekLoadFailedSubtitle =>
      'Bitte Internet prüfen oder später erneut versuchen.';

  @override
  String get gcalTitle => 'Google Kalender';

  @override
  String get gcalHeaderImport =>
      'Finde Ereignisse im Kalender und importiere sie als Ziele.';

  @override
  String get gcalHeaderExport =>
      'Wähle einen Zeitraum und exportiere Ziele aus der App in den Google Kalender.';

  @override
  String get gcalModeImport => 'Import';

  @override
  String get gcalModeExport => 'Export';

  @override
  String get gcalCalendarLabel => 'Kalender';

  @override
  String get gcalPrimaryCalendar => 'Primary (Standard)';

  @override
  String get gcalPeriodLabel => 'Zeitraum';

  @override
  String get gcalRangeToday => 'Heute';

  @override
  String get gcalRangeNext7 => 'Nächste 7 Tage';

  @override
  String get gcalRangeNext30 => 'Nächste 30 Tage';

  @override
  String get gcalRangeCustom => 'Zeitraum wählen...';

  @override
  String get gcalDefaultLifeBlockLabel => 'Standard-Lebensbereich (für Import)';

  @override
  String get gcalLifeBlockForGoalLabel => 'Lebensbereich für dieses Ziel';

  @override
  String get gcalEventsNotLoaded => 'Ereignisse wurden nicht geladen';

  @override
  String get gcalConnectToLoadEvents =>
      'Verbinde dein Konto, um Ereignisse zu laden';

  @override
  String get gcalExportHint =>
      'Beim Export werden Ereignisse im ausgewählten Kalender für den gewählten Zeitraum erstellt.';

  @override
  String get gcalConnect => 'Verbinden';

  @override
  String get gcalConnected => 'Verbunden';

  @override
  String get gcalFindEvents => 'Ereignisse suchen';

  @override
  String get gcalImport => 'Importieren';

  @override
  String get gcalExport => 'Exportieren';

  @override
  String get gcalNoTitle => 'Ohne Titel';

  @override
  String gcalImportedGoalsCount(Object count) {
    return 'Importierte Ziele: $count';
  }

  @override
  String gcalExportedGoalsCount(Object count) {
    return 'Exportierte Ziele: $count';
  }

  @override
  String get launcherQuickFunctionsTitle => 'Schnellfunktionen';

  @override
  String get launcherQuickFunctionsSubtitle =>
      'Navigation und Aktionen mit einem Tipp';

  @override
  String get launcherSectionsTitle => 'Bereiche';

  @override
  String get launcherQuickTitle => 'Schnell';

  @override
  String get launcherHome => 'Start';

  @override
  String get launcherGoals => 'Ziele';

  @override
  String get launcherMood => 'Stimmung';

  @override
  String get launcherProfile => 'Profil';

  @override
  String get launcherInsights => 'Insights';

  @override
  String get launcherReports => 'Berichte';

  @override
  String get launcherMassAddTitle => 'Sammel-Eingabe für den Tag';

  @override
  String get launcherMassAddSubtitle => 'Ausgaben + Ziele + Stimmung';

  @override
  String get launcherAiPlanTitle => 'KI-Plan für Woche/Monat';

  @override
  String get launcherAiPlanSubtitle =>
      'Analyse von Zielen, Fragebogen und Fortschritt';

  @override
  String get launcherAiInsightsTitle => 'KI-Insights';

  @override
  String get launcherAiInsightsSubtitle =>
      'Wie Ereignisse Ziele und Fortschritt beeinflussen';

  @override
  String get launcherRecurringGoalTitle => 'Wiederkehrendes Ziel';

  @override
  String get launcherRecurringGoalSubtitle =>
      'Planung für mehrere Tage im Voraus';

  @override
  String get launcherGoogleCalendarSyncTitle =>
      'Google Kalender Synchronisierung';

  @override
  String get launcherGoogleCalendarSyncSubtitle =>
      'Ziele in den Kalender exportieren';

  @override
  String get launcherNoDatesToCreate =>
      'Keine Termine zum Erstellen (Deadline/Einstellungen prüfen).';

  @override
  String launcherCreateSeriesFailed(Object error) {
    return 'Serie von Zielen konnte nicht erstellt werden: $error';
  }

  @override
  String launcherSaveError(Object error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String launcherCreatedGoalsCount(Object count) {
    return 'Erstellte Ziele: $count';
  }

  @override
  String launcherSavedSummary(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodPart,
  ) {
    return 'Gespeichert: $expenses Ausgabe(n), $incomes Einnahme(n), $goals Aufgabe(n), $habits Gewohnheit(en)$moodPart';
  }

  @override
  String get homeTitleHome => 'Start';

  @override
  String get homeTitleGoals => 'Ziele';

  @override
  String get homeTitleMood => 'Stimmung';

  @override
  String get homeTitleProfile => 'Profil';

  @override
  String get homeTitleReports => 'Berichte';

  @override
  String get homeTitleExpenses => 'Ausgaben';

  @override
  String get homeTitleApp => 'MyNEST';

  @override
  String get homeSignOutTooltip => 'Abmelden';

  @override
  String get homeSignOutTitle => 'Abmelden?';

  @override
  String get homeSignOutSubtitle => 'Die aktuelle Sitzung wird beendet.';

  @override
  String get homeSignOutConfirm => 'Abmelden';

  @override
  String homeSignOutFailed(Object error) {
    return 'Abmelden fehlgeschlagen: $error';
  }

  @override
  String get homeQuickActionsTooltip => 'Schnellaktionen';

  @override
  String get expensesTitle => 'Ausgaben';

  @override
  String get expensesPickDate => 'Datum wählen';

  @override
  String get expensesCommitTooltip => 'Zuweisung zu Sparzielen fixieren';

  @override
  String get expensesCommitUndoTooltip => 'Fixierung aufheben';

  @override
  String get expensesBudgetSettings => 'Budget-Einstellungen';

  @override
  String get expensesCommitDone => 'Zuweisung fixiert';

  @override
  String get expensesCommitUndone => 'Fixierung aufgehoben';

  @override
  String get expensesMonthSummary => 'Monatsübersicht';

  @override
  String expensesIncomeLegend(Object value) {
    return 'Einnahmen $value €';
  }

  @override
  String expensesExpenseLegend(Object value) {
    return 'Ausgaben $value €';
  }

  @override
  String expensesFreeLegend(Object value) {
    return 'Frei $value €';
  }

  @override
  String expensesDaySum(Object value) {
    return 'Summe am Tag: $value €';
  }

  @override
  String get expensesNoTxForDay => 'Keine Buchungen für diesen Tag';

  @override
  String get expensesDeleteTxTitle => 'Buchung löschen?';

  @override
  String expensesDeleteTxBody(Object category, Object amount) {
    return '$category — $amount €';
  }

  @override
  String get expensesCategoriesMonthTitle => 'Ausgabenkategorien im Monat';

  @override
  String get expensesNoCategoryData => 'Noch keine Daten nach Kategorien';

  @override
  String get expensesJarsTitle => 'Sparziele';

  @override
  String get expensesNoJars => 'Noch keine Sparziele';

  @override
  String get expensesCommitShort => 'Fixieren';

  @override
  String get expensesCommitUndoShort => 'Fixierung aufheben';

  @override
  String get expensesAddIncome => 'Einnahme hinzufügen';

  @override
  String get expensesAddExpense => 'Ausgabe hinzufügen';

  @override
  String get loginTitle => 'Anmelden';

  @override
  String get loginEmailLabel => 'E-Mail';

  @override
  String get loginPasswordLabel => 'Passwort';

  @override
  String get loginShowPassword => 'Passwort anzeigen';

  @override
  String get loginHidePassword => 'Passwort verbergen';

  @override
  String get loginForgotPassword => 'Passwort vergessen?';

  @override
  String get loginCreateAccount => 'Konto erstellen';

  @override
  String get loginBtnSignIn => 'Anmelden';

  @override
  String get loginContinueGoogle => 'Mit Google fortfahren';

  @override
  String get loginContinueApple => 'Mit Apple ID fortfahren';

  @override
  String get loginErrEmailRequired => 'E-Mail eingeben';

  @override
  String get loginErrEmailInvalid => 'Ungültige E-Mail';

  @override
  String get loginErrPassRequired => 'Passwort eingeben';

  @override
  String get loginErrPassMin6 => 'Mindestens 6 Zeichen';

  @override
  String get loginResetTitle => 'Passwort zurücksetzen';

  @override
  String get loginResetSend => 'Senden';

  @override
  String get loginResetSent =>
      'E-Mail zum Zurücksetzen wurde gesendet. Bitte Postfach prüfen.';

  @override
  String loginResetFailed(Object error) {
    return 'E-Mail konnte nicht gesendet werden: $error';
  }

  @override
  String get moodTitle => 'Stimmung';

  @override
  String get moodOnePerDay => '1 Eintrag = 1 Tag';

  @override
  String get moodHowDoYouFeel => 'Wie fühlst du dich?';

  @override
  String get moodNoteLabel => 'Notiz (optional)';

  @override
  String get moodNoteHint => 'Was hat deine Stimmung beeinflusst?';

  @override
  String get moodSaved => 'Stimmung gespeichert';

  @override
  String get moodUpdated => 'Eintrag aktualisiert';

  @override
  String get moodHistoryTitle => 'Stimmungs-Verlauf';

  @override
  String get moodTapToEdit => 'Tippen zum Bearbeiten';

  @override
  String get moodNoNote => 'Keine Notiz';

  @override
  String get moodEditTitle => 'Eintrag bearbeiten';

  @override
  String get moodEmptyTitle => 'Noch keine Einträge';

  @override
  String get moodEmptySubtitle =>
      'Wähle ein Datum, markiere deine Stimmung und speichere den Eintrag.';

  @override
  String moodErrSaveFailed(Object error) {
    return 'Stimmung konnte nicht gespeichert werden: $error';
  }

  @override
  String moodErrUpdateFailed(Object error) {
    return 'Eintrag konnte nicht aktualisiert werden: $error';
  }

  @override
  String moodErrDeleteFailed(Object error) {
    return 'Eintrag konnte nicht gelöscht werden: $error';
  }

  @override
  String get onbTopTitle => '';

  @override
  String get onbErrSaveFailed => 'Antworten konnten nicht gespeichert werden';

  @override
  String get onbProfileTitle => 'Lass uns kurz kennenlernen';

  @override
  String get onbProfileSubtitle =>
      'Das hilft für dein Profil und die Personalisierung';

  @override
  String get onbNameLabel => 'Name';

  @override
  String get onbNameHint => 'Zum Beispiel: Viktor';

  @override
  String get onbAgeLabel => 'Alter';

  @override
  String get onbAgeHint => 'Zum Beispiel: 26';

  @override
  String get onbNameNote => 'Du kannst deinen Namen später im Profil ändern.';

  @override
  String get onbBlocksTitle => 'Welche Lebensbereiche möchtest du verfolgen?';

  @override
  String get onbBlocksSubtitle =>
      'Das wird die Basis für deine Ziele und Quests';

  @override
  String get onbPrioritiesTitle =>
      'Was ist dir in den nächsten 3–6 Monaten am wichtigsten?';

  @override
  String get onbPrioritiesSubtitle =>
      'Wähle bis zu drei — das beeinflusst Empfehlungen';

  @override
  String get onbPriorityHealth => 'Gesundheit';

  @override
  String get onbPriorityCareer => 'Karriere';

  @override
  String get onbPriorityMoney => 'Geld';

  @override
  String get onbPriorityFamily => 'Familie';

  @override
  String get onbPriorityGrowth => 'Entwicklung';

  @override
  String get onbPriorityLove => 'Liebe';

  @override
  String get onbPriorityCreativity => 'Kreativität';

  @override
  String get onbPriorityBalance => 'Balance';

  @override
  String onbGoalsBlockTitle(Object block) {
    return 'Ziele im Bereich „$block“';
  }

  @override
  String get onbGoalsBlockSubtitle =>
      'Fokus: Taktik → mittelfristig → langfristig';

  @override
  String get onbGoalLongLabel => 'Langfristiges Ziel (6–24 Monate)';

  @override
  String get onbGoalLongHint => 'Zum Beispiel: Deutsch bis Niveau B2';

  @override
  String get onbGoalMidLabel => 'Mittelfristiges Ziel (2–6 Monate)';

  @override
  String get onbGoalMidHint =>
      'Zum Beispiel: Kurs A2→B1 absolvieren und Prüfung ablegen';

  @override
  String get onbGoalTacticalLabel => 'Taktisches Ziel (2–4 Wochen)';

  @override
  String get onbGoalTacticalHint =>
      'Zum Beispiel: 12 Einheiten à 30 Min + 2 Sprach-Treffen';

  @override
  String get onbWhyLabel => 'Warum ist das wichtig? (optional)';

  @override
  String get onbWhyHint => 'Motivation/Sinn — hilft, dranzubleiben';

  @override
  String get onbOptionalNote =>
      'Du kannst es leer lassen und auf „Weiter“ tippen.';

  @override
  String get registerTitle => 'Konto erstellen';

  @override
  String get registerNameLabel => 'Name';

  @override
  String get registerEmailLabel => 'E-Mail';

  @override
  String get registerPasswordLabel => 'Passwort';

  @override
  String get registerConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get registerShowPassword => 'Passwort anzeigen';

  @override
  String get registerHidePassword => 'Passwort verbergen';

  @override
  String get registerBtnSignUp => 'Registrieren';

  @override
  String get registerContinueGoogle => 'Weiter mit Google';

  @override
  String get registerContinueApple => 'Weiter mit Apple ID';

  @override
  String get registerContinueAppleIos => 'Weiter mit Apple ID (iOS)';

  @override
  String get registerHaveAccountCta => 'Schon ein Konto? Anmelden';

  @override
  String get registerErrNameRequired => 'Bitte Namen eingeben';

  @override
  String get registerErrEmailRequired => 'Bitte E-Mail eingeben';

  @override
  String get registerErrEmailInvalid => 'Ungültige E-Mail';

  @override
  String get registerErrPassRequired => 'Bitte Passwort eingeben';

  @override
  String get registerErrPassMin8 => 'Mindestens 8 Zeichen';

  @override
  String get registerErrPassNeedLower =>
      'Füge einen Kleinbuchstaben hinzu (a-z)';

  @override
  String get registerErrPassNeedUpper =>
      'Füge einen Großbuchstaben hinzu (A-Z)';

  @override
  String get registerErrPassNeedDigit => 'Füge eine Zahl hinzu (0-9)';

  @override
  String get registerErrConfirmRequired => 'Bitte Passwort wiederholen';

  @override
  String get registerErrPasswordsMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get registerErrAcceptTerms =>
      'Bitte AGB und Datenschutzerklärung akzeptieren';

  @override
  String get registerAppleOnlyIos =>
      'Apple ID ist auf iPhone/iPad (iOS) verfügbar';

  @override
  String get welcomeAppName => 'VitaPlatform';

  @override
  String get welcomeSubtitle =>
      'Verwalte Ziele, Stimmung und Zeit\n— alles an einem Ort';

  @override
  String get welcomeSignIn => 'Anmelden';

  @override
  String get welcomeCreateAccount => 'Konto erstellen';

  @override
  String get habitsWeekTitle => 'Gewohnheiten';

  @override
  String get habitsWeekTopTitle => 'Gewohnheiten (Top der Woche)';

  @override
  String get habitsWeekEmptyHint =>
      'Füge mindestens eine Gewohnheit hinzu — dann siehst du hier deinen Fortschritt.';

  @override
  String get habitsWeekFooterHint =>
      'Wir zeigen die aktivsten Gewohnheiten der letzten 7 Tage.';

  @override
  String get mentalWeekTitle => 'Mentale Gesundheit';

  @override
  String mentalWeekLoadError(Object error) {
    return 'Ladefehler: $error';
  }

  @override
  String get mentalWeekNoAnswers =>
      'Für diese Woche wurden keine Antworten gefunden (für die aktuelle user_id).';

  @override
  String get mentalWeekYesNoHeader => 'Ja/Nein (Woche)';

  @override
  String get mentalWeekScalesHeader => 'Skalen (Trend)';

  @override
  String get mentalWeekFooterHint =>
      'Wir zeigen nur ein paar Fragen, damit der Bildschirm nicht überladen wirkt.';

  @override
  String get mentalWeekNoData => 'Keine Daten';

  @override
  String mentalWeekYesCount(Object yes, Object total) {
    return 'Ja: $yes/$total';
  }

  @override
  String get moodWeekTitle => 'Stimmung der Woche';

  @override
  String moodWeekMarkedCount(Object filled, Object total) {
    return 'Erfasst: $filled/$total';
  }

  @override
  String get moodWeekAverageDash => 'Durchschnitt: —';

  @override
  String moodWeekAverageValue(Object avg) {
    return 'Durchschnitt: $avg/5';
  }

  @override
  String get moodWeekFooterHint =>
      'Das ist ein schneller Überblick. Details findest du unten in der Historie.';

  @override
  String get goalsByBlockTitle => 'Ziele nach Lebensbereich';

  @override
  String get goalsAddTooltip => 'Ziel hinzufügen';

  @override
  String get goalsHorizonTacticalShort => 'Taktik';

  @override
  String get goalsHorizonMidShort => 'Mittelfristig';

  @override
  String get goalsHorizonLongShort => 'Langfristig';

  @override
  String get goalsHorizonTacticalLong => '2–6 Wochen';

  @override
  String get goalsHorizonMidLong => '3–6 Monate';

  @override
  String get goalsHorizonLongLong => '1+ Jahr';

  @override
  String get goalsEditorNewTitle => 'Neues Ziel';

  @override
  String get goalsEditorEditTitle => 'Ziel bearbeiten';

  @override
  String get goalsEditorLifeBlockLabel => 'Bereich';

  @override
  String get goalsEditorHorizonLabel => 'Zeithorizont';

  @override
  String get goalsEditorTitleLabel => 'Titel';

  @override
  String get goalsEditorTitleHint => 'z. B. Englisch bis B2 verbessern';

  @override
  String get goalsEditorDescLabel => 'Beschreibung (optional)';

  @override
  String get goalsEditorDescHint =>
      'Kurz: was genau und wie wir den Erfolg messen';

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
      'Noch keine Ziele. Füge dein erstes Ziel für die ausgewählten Bereiche hinzu.';

  @override
  String get goalsNoBlocksToShow => 'Keine verfügbaren Bereiche zum Anzeigen.';

  @override
  String get goalsNoGoalsForBlock =>
      'Keine Ziele für den ausgewählten Bereich.';

  @override
  String get goalsDeleteConfirmTitle => 'Ziel löschen?';

  @override
  String goalsDeleteConfirmBody(Object title) {
    return '„$title“ wird gelöscht und kann nicht wiederhergestellt werden.';
  }

  @override
  String get habitsTitle => 'Gewohnheiten';

  @override
  String get habitsEmptyHint =>
      'Noch keine Gewohnheiten. Füge deine erste hinzu.';

  @override
  String get habitsEditorNewTitle => 'Neue Gewohnheit';

  @override
  String get habitsEditorEditTitle => 'Gewohnheit bearbeiten';

  @override
  String get habitsEditorTitleLabel => 'Titel';

  @override
  String get habitsEditorTitleHint => 'z. B. Morgengymnastik';

  @override
  String get habitsNegativeLabel => 'Negative Gewohnheit';

  @override
  String get habitsNegativeHint =>
      'Markiere sie, wenn du sie verfolgen und reduzieren möchtest.';

  @override
  String get habitsPositiveHint =>
      'Eine positive/neutrale Gewohnheit zur Stärkung.';

  @override
  String get habitsNegativeShort => 'Negativ';

  @override
  String get habitsPositiveShort => 'Positiv/neutral';

  @override
  String get habitsDeleteConfirmTitle => 'Gewohnheit löschen?';

  @override
  String habitsDeleteConfirmBody(Object title) {
    return '„$title“ wird gelöscht und kann nicht wiederhergestellt werden.';
  }

  @override
  String get habitsFooterHint =>
      'Später fügen wir ein „Filtern“ der Gewohnheiten auf dem Home-Screen hinzu.';

  @override
  String get profileTitle => 'Mein Profil';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileNameTitle => 'Name';

  @override
  String get profileNamePrompt => 'Wie sollen wir dich nennen?';

  @override
  String get profileAgeLabel => 'Alter';

  @override
  String get profileAgeTitle => 'Alter';

  @override
  String get profileAgePrompt => 'Bitte Alter eingeben';

  @override
  String get profileAccountSection => 'Konto';

  @override
  String get profileSeenPrologueTitle => 'Prolog abgeschlossen';

  @override
  String get profileSeenPrologueSubtitle => 'Kann man manuell ändern';

  @override
  String get profileFocusSection => 'Fokus';

  @override
  String get profileTargetHoursLabel => 'Zielstunden pro Tag';

  @override
  String profileTargetHoursValue(Object hours) {
    return '$hours Std.';
  }

  @override
  String get profileTargetHoursTitle => 'Ziel: Stunden pro Tag';

  @override
  String get profileTargetHoursFieldLabel => 'Stunden';

  @override
  String get profileQuestionnaireSection => 'Fragebogen & Lebensbereiche';

  @override
  String get profileQuestionnaireNotDoneTitle =>
      'Du hast den Fragebogen noch nicht ausgefüllt.';

  @override
  String get profileQuestionnaireCta => 'Jetzt ausfüllen';

  @override
  String get profileLifeBlocksTitle => 'Lebensbereiche';

  @override
  String get profileLifeBlocksHint => 'z. B. Gesundheit, Karriere, Familie';

  @override
  String get profilePrioritiesTitle => 'Prioritäten';

  @override
  String get profilePrioritiesHint => 'z. B. Sport, Finanzen, Lesen';

  @override
  String get profileDangerZoneTitle => 'Gefahrenzone';

  @override
  String get profileDeleteAccountTitle => 'Konto löschen?';

  @override
  String get profileDeleteAccountBody =>
      'Diese Aktion kann nicht rückgängig gemacht werden.\nGelöscht werden: Ziele, Gewohnheiten, Stimmung, Ausgaben/Einnahmen, Spargläser, KI-Pläne, XP und Profil.';

  @override
  String get profileDeleteAccountConfirm => 'Für immer löschen';

  @override
  String get profileDeleteAccountCta => 'Konto und alle Daten löschen';

  @override
  String get profileDeletingAccount => 'Wird gelöscht…';

  @override
  String get profileDeleteAccountFootnote =>
      'Das Löschen ist endgültig. Deine Daten werden vollständig aus Supabase entfernt.';

  @override
  String get profileAccountDeletedToast => 'Konto gelöscht';

  @override
  String get lifeBlockHealth => 'Gesundheit';

  @override
  String get lifeBlockCareer => 'Karriere';

  @override
  String get lifeBlockFamily => 'Familie';

  @override
  String get lifeBlockFinance => 'Finanzen';

  @override
  String get lifeBlockLearning => 'Weiterentwicklung';

  @override
  String get lifeBlockSocial => 'Soziales';

  @override
  String get lifeBlockRest => 'Erholung';

  @override
  String get lifeBlockBalance => 'Balance';

  @override
  String get lifeBlockLove => 'Liebe';

  @override
  String get lifeBlockCreativity => 'Kreativität';

  @override
  String get lifeBlockGeneral => 'Allgemein';

  @override
  String get addDayGoalTitle => 'Neues Tagesziel';

  @override
  String get addDayGoalFieldTitle => 'Titel *';

  @override
  String get addDayGoalTitleHint => 'Z. B.: Training / Arbeit / Lernen';

  @override
  String get addDayGoalFieldDescription => 'Beschreibung';

  @override
  String get addDayGoalDescriptionHint =>
      'Kurz: was genau erledigt werden soll';

  @override
  String get addDayGoalStartTime => 'Startzeit';

  @override
  String get addDayGoalLifeBlock => 'Lebensbereich';

  @override
  String get addDayGoalImportance => 'Wichtigkeit';

  @override
  String get addDayGoalEmotion => 'Emotion';

  @override
  String get addDayGoalHours => 'Stunden';

  @override
  String get addDayGoalEnterTitle => 'Bitte Titel eingeben';

  @override
  String get addExpenseNewTitle => 'Neue Ausgabe';

  @override
  String get addExpenseEditTitle => 'Ausgabe bearbeiten';

  @override
  String get addExpenseAmountLabel => 'Betrag';

  @override
  String get addExpenseAmountInvalid => 'Bitte einen gültigen Betrag eingeben';

  @override
  String get addExpenseCategoryLabel => 'Kategorie';

  @override
  String get addExpenseCategoryRequired => 'Bitte eine Kategorie auswählen';

  @override
  String get addExpenseCreateCategoryTooltip => 'Kategorie erstellen';

  @override
  String get addExpenseNoteLabel => 'Kommentar';

  @override
  String get addExpenseNewCategoryTitle => 'Neue Kategorie';

  @override
  String get addExpenseCategoryNameLabel => 'Name';

  @override
  String get addIncomeNewTitle => 'Neue Einnahme';

  @override
  String get addIncomeEditTitle => 'Einnahme bearbeiten';

  @override
  String get addIncomeSubtitle => 'Betrag, Kategorie und Kommentar';

  @override
  String get addIncomeAmountLabel => 'Betrag';

  @override
  String get addIncomeAmountHint => 'z. B. 1200,50';

  @override
  String get addIncomeAmountInvalid => 'Bitte einen gültigen Betrag eingeben';

  @override
  String get addIncomeCategoryLabel => 'Kategorie';

  @override
  String get addIncomeCategoryRequired => 'Bitte eine Kategorie auswählen';

  @override
  String get addIncomeNoteLabel => 'Kommentar';

  @override
  String get addIncomeNoteHint => 'Optional';

  @override
  String get addIncomeNewCategoryTitle => 'Neue Einnahmen-Kategorie';

  @override
  String get addIncomeCategoryNameLabel => 'Name';

  @override
  String get addIncomeCategoryNameHint => 'z. B. Gehalt, Freelance…';

  @override
  String get addIncomeCategoryNameEmpty =>
      'Bitte einen Kategorienamen eingeben';

  @override
  String get addJarNewTitle => 'Neue Sparbüchse';

  @override
  String get addJarEditTitle => 'Sparbüchse bearbeiten';

  @override
  String get addJarSubtitle =>
      'Lege Zielbetrag und Anteil vom freien Geld fest';

  @override
  String get addJarNameLabel => 'Name';

  @override
  String get addJarNameHint => 'z. B. Reise, Notgroschen, Haus';

  @override
  String get addJarNameRequired => 'Bitte einen Namen eingeben';

  @override
  String get addJarPercentLabel => 'Anteil vom freien Geld, %';

  @override
  String get addJarPercentHint => '0, wenn du manuell auffüllst';

  @override
  String get addJarPercentRange => 'Prozent muss zwischen 0 und 100 liegen';

  @override
  String get addJarTargetLabel => 'Zielbetrag';

  @override
  String get addJarTargetHint => 'z. B. 5000';

  @override
  String get addJarTargetHelper => 'Pflichtfeld';

  @override
  String get addJarTargetRequired => 'Bitte ein Ziel angeben (positive Zahl)';

  @override
  String get aiInsightTypeDataQuality => 'Datenqualität';

  @override
  String get aiInsightTypeRisk => 'Risiko';

  @override
  String get aiInsightTypeEmotional => 'Emotionen';

  @override
  String get aiInsightTypeHabit => 'Gewohnheiten';

  @override
  String get aiInsightTypeGoal => 'Ziele';

  @override
  String get aiInsightTypeDefault => 'Insight';

  @override
  String get aiInsightStrengthStrong => 'Starker Einfluss';

  @override
  String get aiInsightStrengthNoticeable => 'Spürbarer Einfluss';

  @override
  String get aiInsightStrengthWeak => 'Schwacher Einfluss';

  @override
  String get aiInsightStrengthLowConfidence => 'Geringe Sicherheit';

  @override
  String aiInsightStrengthPercent(int value) {
    return '$value%';
  }

  @override
  String get aiInsightEvidenceTitle => 'Belege';

  @override
  String get aiInsightImpactPositive => 'Positiv';

  @override
  String get aiInsightImpactNegative => 'Negativ';

  @override
  String get aiInsightImpactMixed => 'Gemischt';

  @override
  String get aiInsightsTitle => 'KI-Insights';

  @override
  String get aiInsightsConfirmTitle => 'KI-Analyse starten?';

  @override
  String get aiInsightsConfirmBody =>
      'Die KI analysiert Aufgaben, Gewohnheiten und Wohlbefinden für den ausgewählten Zeitraum und speichert Insights. Das kann ein paar Sekunden dauern.';

  @override
  String get aiInsightsConfirmRun => 'Starten';

  @override
  String get aiInsightsPeriod7 => '7 Tage';

  @override
  String get aiInsightsPeriod30 => '30 Tage';

  @override
  String get aiInsightsPeriod90 => '90 Tage';

  @override
  String aiInsightsLastRun(String date) {
    return 'Letzter Lauf: $date';
  }

  @override
  String get aiInsightsEmptyNotRunTitle => 'KI wurde noch nicht gestartet';

  @override
  String get aiInsightsEmptyNotRunSubtitle =>
      'Wähle einen Zeitraum und tippe auf „Starten“. Insights werden gespeichert und sind in der App verfügbar.';

  @override
  String get aiInsightsCtaRun => 'Analyse starten';

  @override
  String get aiInsightsEmptyNoInsightsTitle => 'Noch keine Insights';

  @override
  String get aiInsightsEmptyNoInsightsSubtitle =>
      'Füge mehr Daten hinzu (Aufgaben, Gewohnheiten, Antworten) und starte die Analyse erneut.';

  @override
  String get aiInsightsCtaRunAgain => 'Erneut starten';

  @override
  String aiInsightsErrorAi(String error) {
    return 'KI-Fehler: $error';
  }

  @override
  String get gcTitleDaySync => 'Google Kalender • Tagessynchronisierung';

  @override
  String get gcSubtitleImport =>
      'Importiere die Ereignisse dieses Tages als Ziele.';

  @override
  String get gcSubtitleExport =>
      'Exportiere die Ziele dieses Tages in den Kalender.';

  @override
  String get gcModeImport => 'Import';

  @override
  String get gcModeExport => 'Export';

  @override
  String get gcCalendarLabel => 'Kalender';

  @override
  String get gcCalendarPrimary => 'Primär (Standard)';

  @override
  String get gcDefaultLifeBlockLabel => 'Standard-Lebensbereich (für Import)';

  @override
  String get gcLifeBlockForThisGoalLabel => 'Lebensbereich für dieses Ziel';

  @override
  String get gcEventsNotLoaded => 'Ereignisse wurden nicht geladen';

  @override
  String get gcConnectToLoadEvents =>
      'Verbinde dein Konto, um Ereignisse zu laden';

  @override
  String get gcExportHint =>
      'Beim Export werden Ereignisse im ausgewählten Kalender für die Ziele dieses Tages erstellt.';

  @override
  String get gcConnect => 'Verbinden';

  @override
  String get gcConnected => 'Verbunden';

  @override
  String get gcFindForDay => 'Für den Tag suchen';

  @override
  String get gcImport => 'Import';

  @override
  String get gcExport => 'Export';

  @override
  String get gcNoTitle => 'Ohne Titel';

  @override
  String get gcLoadingDots => '...';

  @override
  String gcImportedGoals(int count) {
    return 'Importierte Ziele: $count';
  }

  @override
  String gcExportedGoals(int count) {
    return 'Exportierte Ziele: $count';
  }

  @override
  String get editGoalTitle => 'Ziel bearbeiten';

  @override
  String get editGoalSectionDetails => 'Details';

  @override
  String get editGoalSectionLifeBlock => 'Lebensbereich';

  @override
  String get editGoalSectionParams => 'Einstellungen';

  @override
  String get editGoalFieldTitleLabel => 'Titel';

  @override
  String get editGoalFieldTitleHint => 'Zum Beispiel: 3 km laufen';

  @override
  String get editGoalFieldDescLabel => 'Beschreibung';

  @override
  String get editGoalFieldDescHint => 'Was genau muss gemacht werden?';

  @override
  String get editGoalFieldLifeBlockLabel => 'Lebensbereich';

  @override
  String get editGoalFieldImportanceLabel => 'Wichtigkeit';

  @override
  String get editGoalImportanceLow => 'Niedrig';

  @override
  String get editGoalImportanceMedium => 'Mittel';

  @override
  String get editGoalImportanceHigh => 'Hoch';

  @override
  String get editGoalFieldEmotionLabel => 'Emotion';

  @override
  String get editGoalFieldEmotionHint => '😊';

  @override
  String get editGoalDurationHours => 'Dauer (Std.)';

  @override
  String get editGoalStartTime => 'Start';

  @override
  String get editGoalUntitled => 'Ohne Titel';

  @override
  String get expenseCategoryOther => 'Sonstiges';

  @override
  String get goalStatusDone => 'Erledigt';

  @override
  String get goalStatusInProgress => 'In Bearbeitung';

  @override
  String get actionDelete => 'Löschen';

  @override
  String goalImportanceChip(int value) {
    return 'Wichtigkeit $value/5';
  }

  @override
  String goalHoursChip(String value) {
    return 'Stunden $value';
  }

  @override
  String get goalPathEmpty => 'Keine Ziele auf dem Pfad';

  @override
  String get timelineActionEdit => 'Bearbeiten';

  @override
  String get timelineActionDelete => 'Löschen';

  @override
  String get saveBarSaving => 'Speichern…';

  @override
  String get saveBarSave => 'Speichern';

  @override
  String get reportEmptyChartNotEnoughData => 'Nicht genügend Daten';

  @override
  String limitSheetTitle(String categoryName) {
    return 'Limit für „$categoryName“';
  }

  @override
  String get limitSheetHintNoLimit => 'Leer lassen — kein Limit';

  @override
  String get limitSheetFieldLabel => 'Monatliches Limit';

  @override
  String get limitSheetFieldHint => 'z. B. 15000';

  @override
  String get limitSheetCtaNoLimit => 'Kein Limit';

  @override
  String get profileWebNotificationsSection => 'Benachrichtigungen (Web)';

  @override
  String get profileWebNotificationsPermissionTitle =>
      'Benachrichtigungen erlauben';

  @override
  String get profileWebNotificationsPermissionSubtitle =>
      'Funktioniert im Web und nur solange der Tab geöffnet ist.';

  @override
  String get profileWebNotificationsEveningTitle => 'Abend-Check-in';

  @override
  String profileWebNotificationsEveningSubtitle(Object time) {
    return 'Jeden Tag um $time';
  }

  @override
  String get profileWebNotificationsChangeTime => 'Zeit ändern';

  @override
  String get profileWebNotificationsUnsupported =>
      'Browser-Benachrichtigungen sind in diesem Build nicht verfügbar. Sie funktionieren nur in der Web-Version (und nur solange der Tab geöffnet ist).';
}
