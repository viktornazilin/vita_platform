// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Ladna';

  @override
  String get login => 'Anmelden';

  @override
  String get register => 'Konto erstellen';

  @override
  String get home => 'Startseite';

  @override
  String get budgetSetupTitle => 'Budget & Spartöpfe';

  @override
  String get budgetSetupSaved => 'Einstellungen gespeichert';

  @override
  String get budgetSetupSaveError => 'Fehler beim Speichern';

  @override
  String get budgetIncomeCategoriesTitle => 'Einnahmekategorien';

  @override
  String get budgetIncomeCategoriesSubtitle =>
      'Wird beim Erfassen von Einnahmen verwendet';

  @override
  String get settingsLanguageTitle => 'Sprache';

  @override
  String get settingsLanguageSubtitle =>
      'Wähle die App-Sprache. „System“ nutzt die Gerätesprache.';

  @override
  String get budgetExpenseCategoriesTitle => 'Ausgabenkategorien';

  @override
  String get budgetExpenseCategoriesSubtitle =>
      'Limits helfen dir, Ausgaben im Blick zu behalten';

  @override
  String get budgetJarsTitle => 'Spartöpfe';

  @override
  String get budgetJarsSubtitle =>
      'Der Prozentsatz ist der Anteil freier Mittel, der automatisch hinzugefügt wird';

  @override
  String get loginOr => 'oder';

  @override
  String get registerLegalPrefix => 'Mit der Registrierung akzeptierst du die ';

  @override
  String get registerLegalTerms => 'Nutzungsbedingungen';

  @override
  String get registerLegalMiddle => ' und die ';

  @override
  String get registerLegalPrivacy => 'Datenschutzerklärung';

  @override
  String get registerLegalSuffix => '.';

  @override
  String get budgetNewIncomeCategory => 'Neue Einnahmekategorie';

  @override
  String get budgetNewExpenseCategory => 'Neue Ausgabenkategorie';

  @override
  String get budgetCategoryNameHint => 'Kategoriename';

  @override
  String get budgetAddJar => 'Spartopf hinzufügen';

  @override
  String get budgetJarAdded => 'Spartopf hinzugefügt';

  @override
  String budgetJarAddFailed(Object error) {
    return 'Konnte nicht hinzugefügt werden: $error';
  }

  @override
  String get budgetJarDeleted => 'Spartopf gelöscht';

  @override
  String budgetJarDeleteFailed(Object error) {
    return 'Konnte nicht gelöscht werden: $error';
  }

  @override
  String get budgetNoJarsTitle => 'Noch keine Spartöpfe';

  @override
  String get budgetNoJarsSubtitle =>
      'Erstelle dein erstes Sparziel — wir helfen dir, es zu erreichen.';

  @override
  String get budgetSetOrChangeLimit => 'Limit setzen/ändern';

  @override
  String get budgetDeleteCategoryTitle => 'Kategorie löschen?';

  @override
  String budgetCategoryLabel(Object name) {
    return 'Kategorie: $name';
  }

  @override
  String get budgetDeleteJarTitle => 'Spartopf löschen?';

  @override
  String budgetJarLabel(Object title) {
    return 'Spartopf: $title';
  }

  @override
  String budgetJarSummary(Object saved, Object percent, Object targetPart) {
    return 'Gespart: $saved ₽ • Anteil: $percent%$targetPart';
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
  String get commonLoading => 'Lädt…';

  @override
  String get commonSaving => 'Wird gespeichert…';

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
    return 'Konnte nicht gelöscht werden: $error';
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
  String get dayGoalsFabScanTitle => 'Scannen';

  @override
  String get dayGoalsFabScanSubtitle => 'Foto des Journals';

  @override
  String get dayGoalsFabCalendarTitle => 'Google Kalender';

  @override
  String get dayGoalsFabCalendarSubtitle =>
      'Heutige Ziele importieren/exportieren';

  @override
  String get epicIntroSkip => 'Überspringen';

  @override
  String get epicIntroSubtitle =>
      'Ein Zuhause für Gedanken. Ein Ort, an dem Ziele,\nTräume und Pläne wachsen — ruhig und bewusst.';

  @override
  String get epicIntroPrimaryCta => 'Meine Reise starten';

  @override
  String get epicIntroLater => 'Später';

  @override
  String get epicIntroSecondaryCta => 'Anmelden';

  @override
  String get epicIntroFooter =>
      'Du kannst jederzeit in den Einstellungen zum Prolog zurückkehren.';

  @override
  String get homeMoodSaved => 'Stimmung gespeichert';

  @override
  String homeMoodSaveFailed(Object error) {
    return 'Konnte nicht gespeichert werden: $error';
  }

  @override
  String get homeTodayAndWeekTitle => 'Heute & Woche';

  @override
  String get homeTodayAndWeekSubtitle =>
      'Ein schneller Überblick — alle wichtigen Kennzahlen hier';

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
    return 'Plan $hours Std.';
  }

  @override
  String get homeMoodTodayTitle => 'Stimmung heute';

  @override
  String get homeMoodNoTodayEntry => 'Heute noch kein Eintrag';

  @override
  String get homeMoodEntryNoNote => 'Eintrag vorhanden (ohne Notiz)';

  @override
  String get homeMoodQuickHint =>
      'Füge einen schnellen Check-in hinzu — dauert 10 Sekunden';

  @override
  String get homeMoodUpdateHint =>
      'Du kannst aktualisieren — der heutige Eintrag wird überschrieben';

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
  String get homeNoExpensesThisWeek => 'Diese Woche keine Ausgaben';

  @override
  String get homeOpenExpensesCta => 'Ausgaben öffnen';

  @override
  String homeExpensesTotal(Object total) {
    return 'Gesamt: $total €';
  }

  @override
  String homeExpensesAvgPerDay(Object avg) {
    return 'Ø/Tag: $avg €';
  }

  @override
  String get homeInsightsTitle => 'Insights';

  @override
  String homeTopCategory(Object category, Object amount) {
    return '• Top-Kategorie: $category — $amount €';
  }

  @override
  String homePeakExpense(Object day, Object amount) {
    return '• Höchste Ausgabe: $day — $amount €';
  }

  @override
  String get homeOpenDetailedExpensesCta => 'Detaillierte Ausgaben öffnen';

  @override
  String get homeWeekCardTitle => 'Woche';

  @override
  String get homeWeekLoadFailedTitle =>
      'Statistiken konnten nicht geladen werden';

  @override
  String get homeWeekLoadFailedSubtitle =>
      'Prüfe deine Internetverbindung oder versuche es später erneut.';

  @override
  String get gcalTitle => 'Google Kalender';

  @override
  String get gcalHeaderImport =>
      'Finde Termine in deinem Kalender und importiere sie als Ziele.';

  @override
  String get gcalHeaderExport =>
      'Wähle einen Zeitraum und exportiere Ziele aus der App in Google Kalender.';

  @override
  String get gcalModeImport => 'Import';

  @override
  String get gcalModeExport => 'Export';

  @override
  String get gcalCalendarLabel => 'Kalender';

  @override
  String get gcalPrimaryCalendar => 'Primär (Standard)';

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
  String get gcalEventsNotLoaded => 'Termine sind nicht geladen';

  @override
  String get gcalConnectToLoadEvents =>
      'Verbinde dein Konto, um Termine zu laden';

  @override
  String get gcalExportHint =>
      'Der Export erstellt Termine im ausgewählten Kalender für den gewählten Zeitraum.';

  @override
  String get gcalConnect => 'Verbinden';

  @override
  String get gcalConnected => 'Verbunden';

  @override
  String get gcalFindEvents => 'Termine suchen';

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
  String get launcherQuickFunctionsTitle => 'Schnellaktionen';

  @override
  String get launcherQuickFunctionsSubtitle =>
      'Navigation und Aktionen mit einem Tipp';

  @override
  String get launcherSectionsTitle => 'Bereiche';

  @override
  String get launcherQuickTitle => 'Schnell';

  @override
  String get launcherHome => 'Startseite';

  @override
  String get launcherGoals => 'Tagesziele';

  @override
  String get launcherMood => 'Stimmung';

  @override
  String get launcherProfile => 'Profil';

  @override
  String get launcherInsights => 'Insights';

  @override
  String get launcherReports => 'Berichte';

  @override
  String get launcherMassAddTitle => 'Masseneintrag für den Tag';

  @override
  String get launcherMassAddSubtitle => 'Ausgaben + Ziele + Stimmung';

  @override
  String get launcherAiPlanTitle => 'AI-Plan für Woche/Monat';

  @override
  String get launcherAiPlanSubtitle =>
      'Analyse von Zielen, Fragebogen und Fortschritt';

  @override
  String get launcherAiInsightsTitle => 'AI-Insights';

  @override
  String get launcherAiInsightsSubtitle =>
      'Wie Ereignisse Ziele und Fortschritt beeinflussen';

  @override
  String get launcherRecurringGoalTitle => 'Wiederkehrendes Ziel';

  @override
  String get launcherRecurringGoalSubtitle => 'Mehrere Tage im Voraus planen';

  @override
  String get launcherGoogleCalendarSyncTitle => 'Google-Kalender-Sync';

  @override
  String get launcherGoogleCalendarSyncSubtitle =>
      'Ziele in den Kalender exportieren';

  @override
  String get launcherNoDatesToCreate =>
      'Keine Termine zu erstellen (Deadline/Einstellungen prüfen).';

  @override
  String launcherCreateSeriesFailed(Object error) {
    return 'Zielserie konnte nicht erstellt werden: $error';
  }

  @override
  String launcherSaveError(Object error) {
    return 'Speicherfehler: $error';
  }

  @override
  String launcherCreatedGoalsCount(Object count) {
    return 'Ziele erstellt: $count';
  }

  @override
  String launcherSavedSummary(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodPart,
  ) {
    return 'Gespeichert: $expenses Ausgabe(n), $incomes Einnahme(n), $goals Ziel(e), $habits Gewohnheit(en)$moodPart';
  }

  @override
  String get homeTitleHome => 'Startseite';

  @override
  String get homeTitleGoals => 'Tagesziele';

  @override
  String get homeTitleMood => 'Stimmung';

  @override
  String get homeTitleProfile => 'Profil';

  @override
  String get homeTitleReports => 'Berichte';

  @override
  String get homeTitleExpenses => 'Ausgaben';

  @override
  String get homeTitleApp => 'Ladna';

  @override
  String get homeSignOutTooltip => 'Abmelden';

  @override
  String get homeSignOutTitle => 'Abmelden?';

  @override
  String get homeSignOutSubtitle => 'Deine aktuelle Sitzung wird beendet.';

  @override
  String get homeSignOutConfirm => 'Abmelden';

  @override
  String homeSignOutFailed(Object error) {
    return 'Abmeldung fehlgeschlagen: $error';
  }

  @override
  String get homeQuickActionsTooltip => 'Schnellaktionen';

  @override
  String get expensesTitle => 'Ausgaben';

  @override
  String get expensesPickDate => 'Datum auswählen';

  @override
  String get expensesCommitTooltip => 'Topf-Verteilung sperren';

  @override
  String get expensesCommitUndoTooltip => 'Sperre aufheben';

  @override
  String get expensesBudgetSettings => 'Budgeteinstellungen';

  @override
  String get expensesCommitDone => 'Verteilung gesperrt';

  @override
  String get expensesCommitUndone => 'Sperre aufgehoben';

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
    return 'Tagessumme: $value €';
  }

  @override
  String get expensesNoTxForDay => 'Keine Transaktionen für diesen Tag';

  @override
  String get expensesDeleteTxTitle => 'Transaktion löschen?';

  @override
  String expensesDeleteTxBody(Object category, Object amount) {
    return '$category — $amount €';
  }

  @override
  String get expensesCategoriesMonthTitle => 'Ausgabenkategorien im Monat';

  @override
  String get expensesNoCategoryData => 'Noch keine Kategoriedaten';

  @override
  String get expensesJarsTitle => 'Spartöpfe';

  @override
  String get expensesNoJars => 'Noch keine Spartöpfe';

  @override
  String get expensesCommitShort => 'Sperren';

  @override
  String get expensesCommitUndoShort => 'Sperre aufheben';

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
  String get loginResetTitle => 'Passwort wiederherstellen';

  @override
  String get loginResetSend => 'Senden';

  @override
  String get loginResetSent =>
      'E-Mail zum Zurücksetzen des Passworts wurde gesendet. Prüfe deinen Posteingang.';

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
  String get moodHistoryTitle => 'Stimmungsverlauf';

  @override
  String get moodTapToEdit => 'Zum Bearbeiten tippen';

  @override
  String get moodNoNote => 'Keine Notiz';

  @override
  String get moodEditTitle => 'Eintrag bearbeiten';

  @override
  String get moodEmptyTitle => 'Noch keine Einträge';

  @override
  String get moodEmptySubtitle =>
      'Wähle ein Datum, eine Stimmung und speichere.';

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
  String get onbErrSaveFailed =>
      'Deine Antworten konnten nicht gespeichert werden';

  @override
  String get onbProfileTitle => 'Lass uns einander kennenlernen';

  @override
  String get onbProfileSubtitle =>
      'Das hilft deinem Profil und der Personalisierung';

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
      'Das ist die Grundlage für deine Ziele und Quests';

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
  String get onbPriorityGrowth => 'Wachstum';

  @override
  String get onbPriorityLove => 'Liebe';

  @override
  String get onbPriorityCreativity => 'Kreativität';

  @override
  String get onbPriorityBalance => 'Balance';

  @override
  String onbGoalsBlockTitle(Object block) {
    return 'Ziele in „$block“';
  }

  @override
  String get onbGoalsBlockSubtitle =>
      'Fokus: taktisch → mittelfristig → langfristig';

  @override
  String get onbGoalLongLabel => 'Langfristiges Ziel (6–24 Monate)';

  @override
  String get onbGoalLongHint => 'Zum Beispiel: Deutsch-Niveau B2 erreichen';

  @override
  String get onbGoalMidLabel => 'Mittelfristiges Ziel (2–6 Monate)';

  @override
  String get onbGoalMidHint =>
      'Zum Beispiel: A2→B1 abschließen und die Prüfung bestehen';

  @override
  String get onbGoalTacticalLabel => 'Taktisches Ziel (2–4 Wochen)';

  @override
  String get onbGoalTacticalHint =>
      'Zum Beispiel: 12×30-Minuten-Sessions + 2 Sprachclubs';

  @override
  String get onbWhyLabel => 'Warum ist das wichtig? (optional)';

  @override
  String get onbWhyHint => 'Motivation/Sinn — hilft dir, dranzubleiben';

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
  String get registerContinueGoogle => 'Mit Google fortfahren';

  @override
  String get registerContinueApple => 'Mit Apple ID fortfahren';

  @override
  String get registerContinueAppleIos => 'Mit Apple ID fortfahren (iOS)';

  @override
  String get registerHaveAccountCta => 'Du hast schon ein Konto? Anmelden';

  @override
  String get registerErrNameRequired => 'Gib deinen Namen ein';

  @override
  String get registerErrEmailRequired => 'Gib deine E-Mail ein';

  @override
  String get registerErrEmailInvalid => 'Ungültige E-Mail';

  @override
  String get registerErrPassRequired => 'Gib ein Passwort ein';

  @override
  String get registerErrPassMin8 => 'Mindestens 8 Zeichen';

  @override
  String get registerErrPassNeedLower =>
      'Füge einen Kleinbuchstaben hinzu (a-z)';

  @override
  String get registerErrPassNeedUpper =>
      'Füge einen Großbuchstaben hinzu (A-Z)';

  @override
  String get registerErrPassNeedDigit => 'Füge eine Ziffer hinzu (0-9)';

  @override
  String get registerErrConfirmRequired => 'Wiederhole das Passwort';

  @override
  String get registerErrPasswordsMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get registerErrAcceptTerms =>
      'Du musst die Nutzungsbedingungen und die Datenschutzerklärung akzeptieren';

  @override
  String get registerAppleOnlyIos =>
      'Apple ID ist auf iPhone/iPad verfügbar (nur iOS)';

  @override
  String get welcomeAppName => 'VitaPlatform';

  @override
  String get welcomeSubtitle =>
      'Verwalte deine Ziele, Stimmung und Zeit\n— alles an einem Ort';

  @override
  String get welcomeSignIn => 'Anmelden';

  @override
  String get welcomeCreateAccount => 'Konto erstellen';

  @override
  String get habitsWeekTitle => 'Gewohnheiten';

  @override
  String get habitsWeekTopTitle => 'Gewohnheiten (Top dieser Woche)';

  @override
  String get habitsWeekEmptyHint =>
      'Füge mindestens eine Gewohnheit hinzu — dein Fortschritt erscheint hier.';

  @override
  String get habitsWeekFooterHint =>
      'Wir zeigen deine aktivsten Gewohnheiten der letzten 7 Tage.';

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
      'Wir zeigen nur wenige Fragen, damit der Bildschirm übersichtlich bleibt.';

  @override
  String get mentalWeekNoData => 'Keine Daten';

  @override
  String mentalWeekYesCount(Object yes, Object total) {
    return 'Ja: $yes/$total';
  }

  @override
  String get moodWeekTitle => 'Wöchentliche Stimmung';

  @override
  String moodWeekMarkedCount(Object filled, Object total) {
    return 'Eingetragen: $filled/$total';
  }

  @override
  String get moodWeekAverageDash => 'Durchschnitt: —';

  @override
  String moodWeekAverageValue(Object avg) {
    return 'Durchschnitt: $avg/5';
  }

  @override
  String get moodWeekFooterHint =>
      'Das ist eine schnelle Übersicht. Details findest du unten im Verlauf.';

  @override
  String get goalsByBlockTitle => 'Ziele nach Bereich';

  @override
  String get goalsAddTooltip => 'Ziel hinzufügen';

  @override
  String get goalsHorizonTacticalShort => 'Taktisch';

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
  String get goalsEditorHorizonLabel => 'Horizont';

  @override
  String get goalsEditorTitleLabel => 'Titel';

  @override
  String get goalsEditorTitleHint => 'z. B. Englisch auf B2 verbessern';

  @override
  String get goalsEditorDescLabel => 'Beschreibung (optional)';

  @override
  String get goalsEditorDescHint => 'Kurz: was genau und wie messen wir Erfolg';

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
  String get goalsNoBlocksToShow => 'Keine verfügbaren Bereiche zur Anzeige.';

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
  String get habitsEditorTitleHint => 'z. B. Morgentraining';

  @override
  String get habitsNegativeLabel => 'Negative Gewohnheit';

  @override
  String get habitsNegativeHint =>
      'Markiere sie, wenn du sie verfolgen und reduzieren möchtest.';

  @override
  String get habitsPositiveHint =>
      'Eine positive/neutrale Gewohnheit, die du stärken möchtest.';

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
      'Später fügen wir „Filterung“ von Gewohnheiten auf der Startseite hinzu.';

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
  String get profileAgePrompt => 'Gib dein Alter ein';

  @override
  String get profileAccountSection => 'Konto';

  @override
  String get profileSeenPrologueTitle => 'Prolog abgeschlossen';

  @override
  String get profileSeenPrologueSubtitle => 'Du kannst das manuell ändern';

  @override
  String get profileFocusSection => 'Fokus';

  @override
  String get profileTargetHoursLabel => 'Zielstunden pro Tag';

  @override
  String profileTargetHoursValue(Object hours) {
    return '$hours Std.';
  }

  @override
  String get profileTargetHoursTitle => 'Tägliches Stundenziel';

  @override
  String get profileTargetHoursFieldLabel => 'Stunden';

  @override
  String get profileQuestionnaireSection => 'Fragebogen & Lebensbereiche';

  @override
  String get profileQuestionnaireNotDoneTitle =>
      'Du hast den Fragebogen noch nicht abgeschlossen.';

  @override
  String get profileQuestionnaireCta => 'Jetzt abschließen';

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
      'Diese Aktion kann nicht rückgängig gemacht werden.\nGelöscht werden: Ziele, Gewohnheiten, Stimmung, Ausgaben/Einnahmen, Spartöpfe, AI-Pläne, XP und dein Profil.';

  @override
  String get profileDeleteAccountConfirm => 'Für immer löschen';

  @override
  String get profileDeleteAccountCta => 'Konto und alle Daten löschen';

  @override
  String get profileDeletingAccount => 'Wird gelöscht…';

  @override
  String get profileDeleteAccountFootnote =>
      'Das Löschen ist unwiderruflich. Deine Daten werden dauerhaft aus Supabase entfernt.';

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
  String get lifeBlockLearning => 'Wachstum';

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
  String get addDayGoalTitleHint => 'z. B.: Training / Arbeit / Lernen';

  @override
  String get addDayGoalFieldDescription => 'Beschreibung';

  @override
  String get addDayGoalDescriptionHint => 'Kurz: was genau getan werden muss';

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
  String get addDayGoalEnterTitle => 'Gib einen Titel ein';

  @override
  String get addExpenseNewTitle => 'Neue Ausgabe';

  @override
  String get addExpenseEditTitle => 'Ausgabe bearbeiten';

  @override
  String get addExpenseAmountLabel => 'Betrag';

  @override
  String get addExpenseAmountInvalid => 'Gib einen gültigen Betrag ein';

  @override
  String get addExpenseCategoryLabel => 'Kategorie';

  @override
  String get addExpenseCategoryRequired => 'Wähle eine Kategorie';

  @override
  String get addExpenseCreateCategoryTooltip => 'Kategorie erstellen';

  @override
  String get addExpenseNoteLabel => 'Notiz';

  @override
  String get addExpenseNewCategoryTitle => 'Neue Kategorie';

  @override
  String get addExpenseCategoryNameLabel => 'Name';

  @override
  String get addIncomeNewTitle => 'Neue Einnahme';

  @override
  String get addIncomeEditTitle => 'Einnahme bearbeiten';

  @override
  String get addIncomeSubtitle => 'Betrag, Kategorie und Notiz';

  @override
  String get addIncomeAmountLabel => 'Betrag';

  @override
  String get addIncomeAmountHint => 'z. B. 1200,50';

  @override
  String get addIncomeAmountInvalid => 'Gib einen gültigen Betrag ein';

  @override
  String get addIncomeCategoryLabel => 'Kategorie';

  @override
  String get addIncomeCategoryRequired => 'Wähle eine Kategorie';

  @override
  String get addIncomeNoteLabel => 'Notiz';

  @override
  String get addIncomeNoteHint => 'Optional';

  @override
  String get addIncomeNewCategoryTitle => 'Neue Einnahmekategorie';

  @override
  String get addIncomeCategoryNameLabel => 'Kategoriename';

  @override
  String get addIncomeCategoryNameHint => 'z. B. Gehalt, Freelance…';

  @override
  String get addIncomeCategoryNameEmpty => 'Gib einen Kategorienamen ein';

  @override
  String get addJarNewTitle => 'Neuer Spartopf';

  @override
  String get addJarEditTitle => 'Spartopf bearbeiten';

  @override
  String get addJarSubtitle => 'Lege Ziel und Anteil des freien Geldes fest';

  @override
  String get addJarNameLabel => 'Name';

  @override
  String get addJarNameHint => 'z. B. Reise, Notgroschen, Wohnung';

  @override
  String get addJarNameRequired => 'Gib einen Namen ein';

  @override
  String get addJarPercentLabel => 'Anteil des freien Geldes, %';

  @override
  String get addJarPercentHint => '0, wenn du manuell auffüllst';

  @override
  String get addJarPercentRange =>
      'Der Prozentsatz muss zwischen 0 und 100 liegen';

  @override
  String get addJarTargetLabel => 'Zielbetrag';

  @override
  String get addJarTargetHint => 'z. B. 5000';

  @override
  String get addJarTargetHelper => 'Erforderlich';

  @override
  String get addJarTargetRequired => 'Gib ein Ziel ein (positive Zahl)';

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
  String get aiInsightsTitle => 'AI-Insights';

  @override
  String get aiInsightsConfirmTitle => 'AI-Analyse starten?';

  @override
  String get aiInsightsConfirmBody =>
      'AI analysiert deine Aufgaben, Gewohnheiten und dein Wohlbefinden für den ausgewählten Zeitraum und speichert Insights. Das kann einige Sekunden dauern.';

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
  String get aiInsightsEmptyNotRunTitle => 'AI wurde noch nicht gestartet';

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
    return 'AI-Fehler: $error';
  }

  @override
  String get gcTitleDaySync => 'Google Kalender • Tagessync';

  @override
  String get gcSubtitleImport =>
      'Importiere die Termine dieses Tages in Ziele.';

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
  String get gcEventsNotLoaded => 'Termine sind nicht geladen';

  @override
  String get gcConnectToLoadEvents =>
      'Verbinde dein Konto, um Termine zu laden';

  @override
  String get gcExportHint =>
      'Der Export erstellt Termine im ausgewählten Kalender für die Ziele dieses Tages.';

  @override
  String get gcConnect => 'Verbinden';

  @override
  String get gcConnected => 'Verbunden';

  @override
  String get gcFindForDay => 'Für den Tag suchen';

  @override
  String get gcImport => 'Importieren';

  @override
  String get gcExport => 'Exportieren';

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
  String get editGoalFieldTitleHint => 'Beispiel: 3-km-Lauf';

  @override
  String get editGoalFieldDescLabel => 'Beschreibung';

  @override
  String get editGoalFieldDescHint => 'Was genau muss getan werden?';

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
  String get goalStatusInProgress => 'In Arbeit';

  @override
  String get actionDelete => 'Löschen';

  @override
  String goalImportanceChip(int value) {
    return 'Priorität $value/5';
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
  String get saveBarSaving => 'Wird gespeichert…';

  @override
  String get saveBarSave => 'Speichern';

  @override
  String get reportEmptyChartNotEnoughData => 'Nicht genug Daten';

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
      'Funktioniert im Web und nur, solange der Tab geöffnet ist.';

  @override
  String get profileWebNotificationsEveningTitle => 'Abendlicher Check-in';

  @override
  String profileWebNotificationsEveningSubtitle(Object time) {
    return 'Jeden Tag um $time';
  }

  @override
  String get profileWebNotificationsChangeTime => 'Zeit ändern';

  @override
  String get profileWebNotificationsUnsupported =>
      'Browser-Benachrichtigungen sind in diesem Build nicht verfügbar. Sie funktionieren nur in der Web-Version (und nur, solange der Tab geöffnet ist).';

  @override
  String get lifeBlockEducation => 'Bildung';

  @override
  String get lifeBlockHobbies => 'Hobbys';

  @override
  String get userGoalsTitle => 'Meine Ziele';

  @override
  String get userGoalsSubtitle =>
      'Strategische Ziele nach Lebensbereich: kurzfristig, mittelfristig und langfristig.';

  @override
  String get userGoalsNewTitle => 'Neues Ziel';

  @override
  String get userGoalsEditTitle => 'Ziel bearbeiten';

  @override
  String get userGoalsCreateGoal => 'Ziel erstellen';

  @override
  String get userGoalsCreated => 'Ziel erstellt';

  @override
  String userGoalsCreateError(Object error) {
    return 'Ziel konnte nicht erstellt werden: $error';
  }

  @override
  String get userGoalsUpdated => 'Ziel aktualisiert';

  @override
  String userGoalsUpdateError(Object error) {
    return 'Ziel konnte nicht aktualisiert werden: $error';
  }

  @override
  String userGoalsStatusChangeError(Object error) {
    return 'Status konnte nicht geändert werden: $error';
  }

  @override
  String userGoalsDeleteError(Object error) {
    return 'Ziel konnte nicht gelöscht werden: $error';
  }

  @override
  String get userGoalsDeleteConfirmTitle => 'Ziel löschen?';

  @override
  String get userGoalsAllBlocks => 'Alle';

  @override
  String get userGoalsAllHorizons => 'Alle Horizonte';

  @override
  String get userGoalsLoadErrorTitle => 'Ladefehler';

  @override
  String get userGoalsNoActiveBlocksTitle => 'Keine aktiven Lebensbereiche';

  @override
  String get userGoalsNoActiveBlocksSubtitle =>
      'Wähle zuerst die Lebensbereiche aus, die der Nutzer verfolgt.';

  @override
  String get userGoalsEmptyTitle => 'Noch keine Ziele';

  @override
  String get userGoalsEmptySubtitle =>
      'Erstelle dein erstes strategisches Ziel für einen deiner Lebensbereiche.';

  @override
  String userGoalsDeadline(Object date) {
    return 'Deadline: $date';
  }

  @override
  String get userGoalsStatusCompleted => 'Abgeschlossen';

  @override
  String get userGoalsStatusActive => 'Aktiv';

  @override
  String get userGoalsReopen => 'Wieder öffnen';

  @override
  String get userGoalsComplete => 'Abschließen';

  @override
  String get userGoalsFieldLifeBlock => 'Lebensbereich';

  @override
  String get userGoalsFieldHorizon => 'Horizont';

  @override
  String get userGoalsFieldTitle => 'Zieltitel';

  @override
  String get userGoalsFieldDescription => 'Beschreibung';

  @override
  String get userGoalsPickTargetDate => 'Zieldatum wählen';

  @override
  String get userGoalsClearDate => 'Datum löschen';

  @override
  String get monthJanuary => 'Januar';

  @override
  String get monthFebruary => 'Februar';

  @override
  String get monthMarch => 'März';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJune => 'Juni';

  @override
  String get monthJuly => 'Juli';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'Oktober';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'Dezember';

  @override
  String get weekdayMonShort => 'Mo';

  @override
  String get weekdayTueShort => 'Di';

  @override
  String get weekdayWedShort => 'Mi';

  @override
  String get weekdayThuShort => 'Do';

  @override
  String get weekdayFriShort => 'Fr';

  @override
  String get weekdaySatShort => 'Sa';

  @override
  String get weekdaySunShort => 'So';

  @override
  String get lifeBlockRelations => 'Beziehungen';

  @override
  String get lifeBlockSpirituality => 'Spiritualität';

  @override
  String goalsHeaderWeek(Object month, Object year, Object week) {
    return '$month $year, Woche $week';
  }

  @override
  String get goalsQuickActionsTitle => 'Schnellaktionen';

  @override
  String get goalsQuickActionsSubtitle =>
      'Hinzufügen und planen mit einem Tipp';

  @override
  String get goalsMassAddTitle => 'Massentageseintrag';

  @override
  String get goalsMassAddSubtitle =>
      'Ausgaben + Einnahmen + Aufgaben + Stimmung + Gewohnheiten';

  @override
  String goalsMassAddSaved(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodSuffix,
  ) {
    return 'Gespeichert: $expenses Ausgabe(n), $incomes Einnahme(n), $goals Aufgabe(n), $habits Gewohnheit(en)$moodSuffix';
  }

  @override
  String get goalsMassAddMoodSuffix => ', Stimmung';

  @override
  String goalsSaveError(Object error) {
    return 'Speicherfehler: $error';
  }

  @override
  String get goalsRecurringGoalTitle => 'Wiederkehrendes Ziel';

  @override
  String get goalsRecurringGoalSubtitle => 'Mehrere Tage im Voraus planen';

  @override
  String get goalsRecurringNoDates =>
      'Keine Termine zu erstellen. Prüfe Deadline oder Einstellungen.';

  @override
  String goalsPlanHoursDescription(Object hours) {
    return 'Plan: $hours Std.';
  }

  @override
  String goalsCreatedCount(Object count) {
    return 'Ziele erstellt: $count';
  }

  @override
  String goalsRecurringCreateError(Object error) {
    return 'Zielserie konnte nicht erstellt werden: $error';
  }

  @override
  String get goalsSimpleTaskTitle => 'Schnellaufgabe';

  @override
  String get goalsSimpleTaskSubtitle =>
      'Nur Titel, optionale Uhrzeit, Kategorie Allgemein';

  @override
  String get goalsSimpleTaskSheetSubtitle =>
      'Nur Titel, optionale Uhrzeit. Standardkategorie ist Allgemein.';

  @override
  String get goalsTaskCreated => 'Aufgabe erstellt';

  @override
  String goalsTaskCreateError(Object error) {
    return 'Fehler beim Erstellen der Aufgabe: $error';
  }

  @override
  String get goalsAll => 'Alle';

  @override
  String get goalsViewDashboard => 'Dashboard';

  @override
  String get goalsViewCalendar => 'Kalender';

  @override
  String get goalsViewWeek => 'Woche';

  @override
  String get goalsViewMonth => 'Monat';

  @override
  String get goalsByBlocksTitle => 'Ziele nach Lebensbereich';

  @override
  String get goalsShow => 'Anzeigen';

  @override
  String get goalsByBlocksHiddenHint =>
      'Ausgeblendet. Tippe auf 👁 zum Anzeigen.';

  @override
  String get goalsEnterTaskTitle => 'Gib einen Aufgabentitel ein';

  @override
  String get goalsTaskTitleLabel => 'Aufgabentitel';

  @override
  String get goalsAddTime => 'Zeit hinzufügen';

  @override
  String goalsTimeValue(Object time) {
    return 'Zeit: $time';
  }

  @override
  String get goalsRemoveTime => 'Zeit entfernen';

  @override
  String get goalsCreateTask => 'Aufgabe erstellen';

  @override
  String get goalsWeekSummaryTitle => 'Wochenübersicht';

  @override
  String goalsHoursShort(Object hours) {
    return '$hours Std.';
  }

  @override
  String goalsHoursTargetSuffix(Object hours) {
    return ' / $hours Std.';
  }

  @override
  String goalsHoursShortNoSpace(Object hours) {
    return '${hours}Std.';
  }

  @override
  String goalsHoursTargetSuffixNoSpace(Object hours) {
    return ' / ${hours}Std.';
  }

  @override
  String get dayGoalsHiddenCompletedEmpty =>
      'Alle sichtbaren Ziele sind ausgeblendet. Deaktiviere den Filter „Erledigte ausblenden“.';

  @override
  String get dayGoalsKanbanOpenShort => 'Offen';

  @override
  String get dayGoalsKanbanDoneShort => 'Erledigt';

  @override
  String get dayGoalsKanbanOpenTitle => 'In Arbeit';

  @override
  String get dayGoalsKanbanDoneTitle => 'Erledigt';

  @override
  String get dayGoalsKanbanOpenEmpty => 'Keine aktiven Aufgaben';

  @override
  String get dayGoalsKanbanDoneEmpty => 'Noch nichts hier';

  @override
  String dayGoalsHoursShort(Object hours) {
    return '$hours Std.';
  }

  @override
  String get dayGoalsSectionMorning => 'Morgen';

  @override
  String get dayGoalsSectionDay => 'Tag';

  @override
  String get dayGoalsSectionEvening => 'Abend';

  @override
  String get dayGoalsSummaryTitle => 'Tagesübersicht';

  @override
  String get dayGoalsSummarySubtitle =>
      'Bleib fokussiert auf das Wichtige und halte den Tag überschaubar.';

  @override
  String get dayGoalsSummaryTotal => 'Gesamt';

  @override
  String get dayGoalsSummaryDone => 'Erledigt';

  @override
  String get dayGoalsSummaryRemaining => 'Verbleibend';

  @override
  String dayGoalsRemainingHours(Object hours) {
    return 'Verbleibende Stunden: $hours';
  }

  @override
  String get dayGoalsHideCompleted => 'Erledigte ausblenden';

  @override
  String get reportsTabSummary => 'Übersicht';

  @override
  String get reportsTabRelations => 'Zusammenhänge';

  @override
  String get reportsTabProductivity => 'Produktivität';

  @override
  String get reportsTabExpenses => 'Ausgaben';

  @override
  String get reportsCompletedTasks => 'Erledigte Aufgaben';

  @override
  String get reportsSpentHours => 'Aufgewendete Stunden';

  @override
  String get reportsEfficiency => 'Effizienz';

  @override
  String get reportsPeriodEfficiency => 'Effizienz des Zeitraums';

  @override
  String reportsPlanFactHours(Object planned, Object actual) {
    return 'Plan: $planned Std. • Ist: $actual Std.';
  }

  @override
  String get reportsAdditionalMetrics => 'Zusätzliche Kennzahlen';

  @override
  String get reportsCorrelations => 'Zusammenhänge zwischen Kennzahlen';

  @override
  String get reportsCorrelationsHint =>
      'Das ist keine wissenschaftliche Korrelation, sondern ein klarer Vergleich nach Zeitraum.';

  @override
  String get reportsMoodProductivity => 'Stimmung → Produktivität';

  @override
  String get reportsGoodMood => 'Gut';

  @override
  String get reportsBadMood => 'Schlecht';

  @override
  String get reportsHabitsMoodProductivity =>
      'Gewohnheiten → Stimmung / Produktivität';

  @override
  String get reportsMoodMostlyHappy => 'meist 😊';

  @override
  String get reportsMoodMostlySad => 'meist 😞';

  @override
  String get reportsMoodMostlyNeutral => 'meist 😐';

  @override
  String reportsHabitsComparisonHint(int percent) {
    return 'Vergleich von Tagen mit ≥ $percent% erledigten Gewohnheiten und allen anderen Tagen.';
  }

  @override
  String get reportsMoodHigh => 'Stimmung (hoch)';

  @override
  String get reportsMoodLow => 'Stimmung (niedrig)';

  @override
  String get reportsHoursHigh => 'Stunden (hoch)';

  @override
  String get reportsHoursLow => 'Stunden (niedrig)';

  @override
  String get reportsHabitsHighShort => 'Gewohnheiten hoch';

  @override
  String get reportsHabitsLowShort => 'Gewohnheiten niedrig';

  @override
  String get reportsMentalMood => 'Mentaler Zustand → Stimmung';

  @override
  String get reportsExpensesMood => 'Ausgaben → Stimmung';

  @override
  String get reportsHappyDays => '😊 Tage';

  @override
  String get reportsSadDays => '😞 Tage';

  @override
  String get reportsCompletedByBlocks => 'Erledigt nach Bereichen';

  @override
  String get reportsNoCompletedTasks => 'Keine erledigten Aufgaben';

  @override
  String reportsTasksCount(int count) {
    return '$count Aufgaben';
  }

  @override
  String get reportsHoursByDays => 'Aufgewendete Stunden nach Tag';

  @override
  String get reportsExpensesForPeriod => 'Ausgaben für den Zeitraum';

  @override
  String reportsTotalEuro(Object amount) {
    return 'Gesamt: $amount €';
  }

  @override
  String reportsAvgExpensePerDay(Object amount) {
    return 'Durchschnittliche Ausgaben/Tag: $amount €';
  }

  @override
  String get reportsNoExpensesByCategory => 'Keine Ausgaben nach Kategorie';

  @override
  String get reportsAvgTimePerGoal => 'Durchschnittliche Zeit pro Aufgabe';

  @override
  String get reportsOnTimeConditional => '„Pünktlich“ (ca.)';

  @override
  String get reportsTop3ProductiveDays => 'TOP 3 produktive Tage';

  @override
  String reportsTopDayLine(int day, int month, int year, Object hours) {
    return '• $day.$month.$year: $hours Std.';
  }

  @override
  String get reportsPeriodDay => 'Tag';

  @override
  String get reportsPeriodWeekShort => 'Woche';

  @override
  String get reportsPeriodMonthShort => 'Monat';

  @override
  String get reportsForward => 'Weiter';

  @override
  String get reportsTapChartSector => 'Tippe auf ein Diagrammsegment';

  @override
  String get reportsLatestAiInsights => 'Neueste AI-Insights';

  @override
  String get reportsOpenAll => 'Alle öffnen';

  @override
  String get reportsInsightsLoadFailed =>
      'Insights konnten nicht geladen werden';

  @override
  String get reportsNoSavedInsights => 'Noch keine gespeicherten Insights.';

  @override
  String get reportsRunAiInsightsHint =>
      'Öffne „AI-Insights“ und starte eine Analyse — dann erscheinen sie hier.';

  @override
  String get reportsAiPeriod7Days => 'letzte 7 Tage';

  @override
  String get reportsAiPeriod30Days => 'letzte 30 Tage';

  @override
  String get reportsAiPeriod90Days => 'letzte 90 Tage';

  @override
  String reportsHoursValue(Object hours) {
    return '$hours Std.';
  }

  @override
  String reportsEuroValue(Object amount) {
    return '$amount €';
  }

  @override
  String get commonError => 'Fehler';

  @override
  String get aiPlanConsentSaved =>
      'Einwilligung zur AI-Verarbeitung gespeichert';

  @override
  String aiPlanConsentCheckFailed(Object error) {
    return 'Einwilligung zur AI-Verarbeitung konnte nicht geprüft oder gespeichert werden. Stelle sicher, dass die Tabelle users die Felder ai_processing_consent, ai_processing_consent_at und ai_processing_consent_version enthält. Details: $error';
  }

  @override
  String get aiPlanConsentTitle => 'Einwilligung zur AI-Verarbeitung';

  @override
  String get aiPlanConsentBody =>
      'Um einen AI-Plan zu generieren, analysiert Ladna deine Ziele, Aufgaben, Gewohnheiten, Stimmung und andere App-Daten. Diese Daten werden nur zur Erstellung persönlicher Empfehlungen, Pläne und Insights verwendet.';

  @override
  String get aiPlanConsentDeclineBody =>
      'Du kannst die Einwilligung ablehnen — dann wird die AI-Funktion nicht gestartet.';

  @override
  String get aiPlanConsentNotNow => 'Nicht jetzt';

  @override
  String get aiPlanConsentAgree => 'Ich stimme zu';

  @override
  String aiPlanOpenLinkFailed(Object url) {
    return 'Link konnte nicht geöffnet werden: $url';
  }

  @override
  String get aiPlanUpdated => 'AI-Plan aktualisiert';

  @override
  String get aiPlanEmptyEdgeFunction =>
      'Der Plan ist leer. Prüfe die ai-plan Edge Function.';

  @override
  String aiPlanHoursShort(Object hours) {
    return '$hours Std.';
  }

  @override
  String aiPlanImportanceMeta(int importance) {
    return 'Wichtigkeit $importance/5';
  }

  @override
  String get aiPlanLinkedToGoal => 'mit einem Ziel verknüpft';

  @override
  String get aiPlanNothingToApply =>
      'Nichts anzuwenden — wähle einige Elemente aus';

  @override
  String get aiPlanDefaultTaskTitle => 'AI-Aufgabe';

  @override
  String aiPlanTasksAdded(int count) {
    return 'Aufgaben hinzugefügt: $count';
  }

  @override
  String get aiPlanApplyTypeError =>
      'Datentypfehler beim Hinzufügen von Aufgaben: Eines der Felder kam als true/false statt als Zahl. Aktualisiere die Datei erneut: In dieser Version werden boolesche Werte zusätzlich in Zahlen umgewandelt und das Feld is_completed wird nicht mehr manuell gesendet.';

  @override
  String get aiPlanTitleWeek => 'AI-Plan für die Woche';

  @override
  String get aiPlanTitleMonth => 'AI-Plan für den Monat';

  @override
  String get aiPlanRegenerateTooltip => 'Erneut generieren';

  @override
  String aiPlanUpdatedAt(Object date) {
    return 'Aktualisiert: $date';
  }

  @override
  String get aiPlanCheckingConsent =>
      'Einwilligung zur AI-Verarbeitung wird geprüft...';

  @override
  String get aiPlanApplyingTasks => 'Aufgaben werden hinzugefügt...';

  @override
  String get aiPlanGenerating => 'AI-Plan wird generiert...';

  @override
  String aiPlanApplyCount(int count) {
    return 'Anwenden ($count)';
  }

  @override
  String get aiPlanRejectTooltip => 'Ablehnen';

  @override
  String get aiPlanAcceptTooltip => 'Akzeptieren';

  @override
  String get aiPlanFieldBlock => 'Block';

  @override
  String get aiPlanFieldImportance => 'Wichtigkeit';

  @override
  String get aiPlanFieldHours => 'Stunden';

  @override
  String get aiPlanFieldRepeat => 'Wiederholen';

  @override
  String get aiPlanConsentRequiredTitle =>
      'Einwilligung zur AI-Verarbeitung erforderlich';

  @override
  String get aiPlanConsentRequiredBody =>
      'Bevor ein AI-Plan generiert wird, musst du bestätigen, dass Ladna App-Daten für persönliche Empfehlungen analysieren darf.';

  @override
  String get aiPlanGiveConsent => 'Einwilligung geben';

  @override
  String get aiPlanPrivacyPolicy => 'Privacy Policy';

  @override
  String get aiPlanDatenschutz => 'Datenschutzerklärung';

  @override
  String get aiPlanTermsOfUse => 'Terms of Use';

  @override
  String get aiPlanEmptyTitle => 'Der Plan ist leer';

  @override
  String get aiPlanEmptyBody =>
      'Drücke unten auf die Schaltfläche, um einen Plan basierend auf AI-Insights, Zielen, Aufgaben, Gewohnheiten und Stimmung zu generieren.';

  @override
  String get aiPlanGeneratePlan => 'Plan generieren';

  @override
  String get aiPlanRepeatNone => 'Keine Wiederholung';

  @override
  String get aiPlanRepeatDaily => 'Jeden Tag';

  @override
  String get aiPlanRepeatWeekdays => 'Werktage';

  @override
  String get aiPlanRepeatWeekly => 'Einmal pro Woche';

  @override
  String get aiPlanLifeBlockOther => 'Sonstiges';

  @override
  String get aiInsightsConsentTitle => 'Einwilligung zur AI-Verarbeitung';

  @override
  String get aiInsightsConsentBody =>
      'Um AI-Insights zu generieren, analysiert Ladna deine Ziele, Aufgaben, Gewohnheiten, Stimmung und andere App-Daten. Diese Daten werden nur zur Erstellung persönlicher Empfehlungen, Pläne und Insights verwendet.';

  @override
  String get aiInsightsConsentDeclineBody =>
      'Du kannst die Einwilligung ablehnen — dann wird die AI-Funktion nicht gestartet.';

  @override
  String get aiInsightsConsentNotNow => 'Nicht jetzt';

  @override
  String get aiInsightsConsentAgree => 'Ich stimme zu';

  @override
  String get aiInsightsConsentSaved =>
      'Einwilligung zur AI-Verarbeitung gespeichert';

  @override
  String aiInsightsConsentCheckFailed(Object error) {
    return 'Einwilligung zur AI-Verarbeitung konnte nicht geprüft oder gespeichert werden. Stelle sicher, dass die Tabelle users die Felder ai_processing_consent, ai_processing_consent_at und ai_processing_consent_version enthält. Details: $error';
  }

  @override
  String get aiInsightsCheckingConsent =>
      'Einwilligung zur AI-Verarbeitung wird geprüft...';

  @override
  String get aiInsightsUserNotAuthorized => 'Nutzer ist nicht authentifiziert';

  @override
  String aiInsightsOpenLinkFailed(Object url) {
    return 'Link konnte nicht geöffnet werden: $url';
  }

  @override
  String get aiInsightsDefaultTitle => 'AI-Insight';

  @override
  String get aiInsightsConsentRequiredTitle =>
      'Einwilligung zur AI-Verarbeitung erforderlich';

  @override
  String get aiInsightsConsentRequiredBody =>
      'Bevor AI-Insights generiert werden, musst du bestätigen, dass Ladna App-Daten für persönliche Empfehlungen analysieren darf.';

  @override
  String get aiInsightsGiveConsent => 'Einwilligung geben';

  @override
  String get aiInsightsPrivacyPolicy => 'Privacy Policy';

  @override
  String get aiInsightsDatenschutz => 'Datenschutzerklärung';

  @override
  String get aiInsightsTermsOfUse => 'Terms of Use';

  @override
  String get massDailyTitle => 'Massentageseintrag';

  @override
  String get massDailyDatePrefix => 'Datum: ';

  @override
  String get massDailyChoose => 'Auswählen';

  @override
  String get massDailyBack => 'Zurück';

  @override
  String get massDailyCancel => 'Abbrechen';

  @override
  String get massDailyNext => 'Weiter';

  @override
  String get massDailySaveAll => 'Alles speichern';

  @override
  String get massDailyEmptyRowsIgnored => 'Leere Zeilen werden ignoriert.';

  @override
  String get massDailyMoodTitle => 'Stimmung';

  @override
  String get massDailyMoodSubtitle =>
      'Optionale Notiz darüber, wie der Tag gelaufen ist.';

  @override
  String get massDailyNote => 'Notiz';

  @override
  String get massDailyHabitsTitle => 'Gewohnheiten';

  @override
  String get massDailyHabitsSubtitle =>
      'Markiere die Erledigung und füge bei Bedarf eine Menge hinzu.';

  @override
  String get massDailyRefresh => 'Aktualisieren';

  @override
  String get massDailyNoHabits =>
      'Noch keine Gewohnheiten. Füge sie in deinem Profil hinzu.';

  @override
  String massDailyHabitsLoadFailed(Object error) {
    return 'Gewohnheiten konnten nicht geladen werden: $error';
  }

  @override
  String get massDailyMentalTitle => 'Mentale Gesundheit';

  @override
  String get massDailyMentalSubtitle =>
      'Ein kurzer täglicher Zustands-Check-in für spätere Analysen.';

  @override
  String get massDailyMentalIntro =>
      'Beantworte ein paar Fragen — das hilft, deinen Zustand zu verfolgen.';

  @override
  String get massDailyNoMentalQuestions =>
      'Noch keine Fragen. Füge sie zur Tabelle mental_questions hinzu.';

  @override
  String massDailyMentalLoadFailed(Object error) {
    return 'Fragen konnten nicht geladen werden: $error';
  }

  @override
  String get massDailyExpensesTitle => 'Ausgaben';

  @override
  String get massDailyExpensesSubtitle =>
      'Füge Ausgaben für den ausgewählten Tag hinzu.';

  @override
  String get massDailyIncomesTitle => 'Einnahmen';

  @override
  String get massDailyIncomesSubtitle =>
      'Füge Einnahmen für den ausgewählten Tag hinzu.';

  @override
  String get massDailyGoalsTitle => 'Aufgaben';

  @override
  String get massDailyGoalsSubtitle =>
      'Halte fest, woran du an diesem Tag gearbeitet hast und wie viel Zeit es gekostet hat.';

  @override
  String get massDailyAddRow => 'Zeile hinzufügen';

  @override
  String get massDailyNoMood => 'Keine Stimmung';

  @override
  String get massDailyQuantityExample => 'Menge (zum Beispiel Zigaretten)';

  @override
  String get massDailyQuantityOptional => 'Menge (optional)';

  @override
  String get massDailyQuantityShort => 'Menge';

  @override
  String get massDailyHabitNegative => 'Negativ';

  @override
  String get massDailyHabitPositive => 'Positiv';

  @override
  String get massDailyAnswer => 'Antwort';

  @override
  String get massDailyAmount => 'Betrag';

  @override
  String get massDailyCategory => 'Kategorie';

  @override
  String get massDailyNoCategories => 'Keine Kategorien';

  @override
  String get massDailyTaskTitle => 'Aufgabentitel';

  @override
  String get massDailyHours => 'Stunden';

  @override
  String get massDailyTime => 'Zeit';

  @override
  String get massDailyEmotion => 'Emotion';

  @override
  String get massDailyNoEmotion => 'Keine Emotion';

  @override
  String get massDailyImportance => 'Wichtigkeit';

  @override
  String get massDailyBigGoal => 'Großes Ziel';

  @override
  String get massDailyNoLink => 'Nicht verknüpft';

  @override
  String get massDailyLoadingUserGoals => 'Große Ziele werden geladen...';

  @override
  String get massDailyNoUserGoalsForCategory =>
      'Für diese Kategorie gibt es noch keine großen Ziele.';

  @override
  String get massDailyHorizonTactical => 'Taktisch';

  @override
  String get massDailyHorizonMid => 'Mittelfristig';

  @override
  String get massDailyHorizonLong => 'Langfristig';

  @override
  String get massDailyLifeBlockGeneral => 'Allgemein';

  @override
  String get massDailyLifeBlockHealth => 'Gesundheit';

  @override
  String get massDailyLifeBlockCareer => 'Karriere';

  @override
  String get massDailyLifeBlockFamily => 'Familie';

  @override
  String get massDailyLifeBlockFinance => 'Finanzen';

  @override
  String get massDailyLifeBlockEducation => 'Bildung';

  @override
  String get massDailyLifeBlockHobbies => 'Hobbys';

  @override
  String get importJournalTextNotRecognized =>
      'Text wurde nicht erkannt. Versuche ein anderes Foto.';

  @override
  String get importJournalRecognizedTextTitle => 'Erkannter Text';

  @override
  String get importJournalContinue => 'Weiter';

  @override
  String get importJournalUntitled => 'Ohne Titel';

  @override
  String get importJournalNoTasksFound =>
      'Aus dem Text konnten keine Aufgaben extrahiert werden.';

  @override
  String importJournalAddedGoals(Object count) {
    return 'Ziele hinzugefügt: $count';
  }

  @override
  String importJournalImportFailed(Object error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get importJournalVisionApiKeyMissing =>
      'VISION_API_KEY ist nicht gesetzt. Starte die App mit --dart-define=VISION_API_KEY=...';

  @override
  String importJournalVisionApiError(Object statusCode, Object body) {
    return 'Vision API hat Fehler $statusCode zurückgegeben: $body';
  }

  @override
  String get importJournalEditTitle => 'Bearbeiten';

  @override
  String get importJournalNameLabel => 'Name';

  @override
  String get importJournalTimeColon => 'Zeit:';

  @override
  String get importJournalHoursColon => 'Stunden:';

  @override
  String get importJournalFoundTasksTitle => 'Gefundene Aufgaben';

  @override
  String importJournalTaskSubtitle(Object time, Object hours) {
    return '$time • $hours Std.';
  }

  @override
  String get importJournalAddSelected => 'Ausgewählte hinzufügen';

  @override
  String get recurringGoalSelectAtLeastOneWeekday =>
      'Wähle mindestens einen Wochentag aus';

  @override
  String get recurringGoalTitle => 'Wiederkehrendes Ziel';

  @override
  String get recurringGoalSubtitle =>
      'Erstellt Aufgaben von heute bis zum ausgewählten Datum.';

  @override
  String get recurringGoalDetailsSection => 'Details';

  @override
  String get recurringGoalTitleLabel => 'Zieltitel';

  @override
  String get recurringGoalTitleHint => 'Zum Beispiel: Training';

  @override
  String get recurringGoalEmotionLabel => 'Emotion';

  @override
  String get recurringGoalEmotionHint => 'Zum Beispiel: 💪 Motivation';

  @override
  String get recurringGoalRegularitySection => 'Regelmäßigkeit';

  @override
  String get recurringGoalEveryNDays => 'Alle N Tage';

  @override
  String get recurringGoalByWeekdays => 'Nach Wochentagen';

  @override
  String get recurringGoalIntervalLabel => 'Intervall';

  @override
  String recurringGoalEveryNDaysShort(Object count) {
    return '$count T';
  }

  @override
  String get recurringGoalWeekdayMon => 'Mo';

  @override
  String get recurringGoalWeekdayTue => 'Di';

  @override
  String get recurringGoalWeekdayWed => 'Mi';

  @override
  String get recurringGoalWeekdayThu => 'Do';

  @override
  String get recurringGoalWeekdayFri => 'Fr';

  @override
  String get recurringGoalWeekdaySat => 'Sa';

  @override
  String get recurringGoalWeekdaySun => 'So';

  @override
  String recurringGoalTimeButton(Object time) {
    return 'Zeit: $time';
  }

  @override
  String recurringGoalUntilButton(Object date) {
    return 'Bis: $date';
  }

  @override
  String get recurringGoalParametersSection => 'Parameter';

  @override
  String get recurringGoalLifeBlockLabel => 'Lebensbereich';

  @override
  String get recurringGoalImportanceLabel => 'Wichtigkeit';

  @override
  String get recurringGoalUserGoalLabel => 'Großes Ziel';

  @override
  String get recurringGoalNoLink => 'Keine Verknüpfung';

  @override
  String recurringGoalLoadingUserGoals(Object block) {
    return 'Ziele für „$block“ werden geladen...';
  }

  @override
  String recurringGoalNoUserGoalsForBlock(Object block) {
    return 'Für „$block“ sind noch keine Ziele verfügbar.';
  }

  @override
  String get recurringGoalPlannedHoursLabel => 'Geplante Stunden';

  @override
  String recurringGoalOccurrencesCount(Object count) {
    return 'Zu erstellende Aufgaben: $count';
  }

  @override
  String get recurringGoalCreate => 'Erstellen';

  @override
  String get recurringGoalLifeBlockGeneral => 'Allgemein';

  @override
  String get recurringGoalLifeBlockHealth => 'Gesundheit';

  @override
  String get recurringGoalLifeBlockCareer => 'Karriere';

  @override
  String get recurringGoalLifeBlockFinance => 'Finanzen';

  @override
  String get recurringGoalLifeBlockRelationships => 'Beziehungen';

  @override
  String get recurringGoalLifeBlockSelf => 'Selbstentwicklung';

  @override
  String get recurringGoalLifeBlockEducation => 'Bildung';

  @override
  String get recurringGoalLifeBlockTravel => 'Reisen';

  @override
  String get recurringGoalLifeBlockHome => 'Zuhause';

  @override
  String get recurringGoalHorizonTactical => 'Taktisch';

  @override
  String get recurringGoalHorizonMid => 'Mittelfristig';

  @override
  String get recurringGoalHorizonLong => 'Langfristig';

  @override
  String get addDayGoalLinkSectionTitle => 'Mit einem Ziel verknüpfen';

  @override
  String get addDayGoalUserGoalLabel => 'Großes Ziel';

  @override
  String get addDayGoalNoLinkedGoal => 'Keine Verknüpfung';

  @override
  String addDayGoalLoadingUserGoals(Object block) {
    return 'Ziele für „$block“ werden geladen...';
  }

  @override
  String addDayGoalNoUserGoalsForBlock(Object block) {
    return 'Für „$block“ sind noch keine Ziele verfügbar.';
  }

  @override
  String get addDayGoalLifeBlockGeneral => 'Allgemein';

  @override
  String get addDayGoalLifeBlockHealth => 'Gesundheit';

  @override
  String get addDayGoalLifeBlockCareer => 'Karriere';

  @override
  String get addDayGoalLifeBlockFinance => 'Finanzen';

  @override
  String get addDayGoalLifeBlockRelationships => 'Beziehungen';

  @override
  String get addDayGoalLifeBlockSelf => 'Selbstentwicklung';

  @override
  String get addDayGoalLifeBlockEducation => 'Bildung';

  @override
  String get addDayGoalLifeBlockTravel => 'Reisen';

  @override
  String get addDayGoalLifeBlockHome => 'Zuhause';

  @override
  String get addDayGoalHorizonTactical => 'Taktisch';

  @override
  String get addDayGoalHorizonMid => 'Mittelfristig';

  @override
  String get addDayGoalHorizonLong => 'Langfristig';

  @override
  String get lifeBlockSelf => 'Selbstentwicklung';

  @override
  String get lifeBlockTravel => 'Reisen';

  @override
  String get lifeBlockHome => 'Zuhause';

  @override
  String get horizonTactical => 'Taktisch';

  @override
  String get horizonMid => 'Mittelfristig';

  @override
  String get horizonLong => 'Langfristig';

  @override
  String get editGoalSectionDateTime => 'Datum und Uhrzeit';

  @override
  String get editGoalSectionUserGoalLink =>
      'Verknüpfung mit einem größeren Ziel';

  @override
  String get userGoalLinkFieldLabel => 'Größeres Ziel';

  @override
  String get userGoalLinkNone => 'Keine Verknüpfung';

  @override
  String userGoalLinkLoadingForBlock(Object block) {
    return 'Ziele für „$block“ werden geladen...';
  }

  @override
  String userGoalLinkNoGoalsForBlock(Object block) {
    return 'Für „$block“ sind noch keine Ziele verfügbar.';
  }

  @override
  String editGoalHoursValue(Object hours) {
    return 'Stunden: $hours';
  }

  @override
  String commonHoursShort(Object hours) {
    return '$hours Std.';
  }

  @override
  String get healthTrackerTitle => 'Gesundheitstracker';

  @override
  String get healthCalorieTargetTitle => 'Kalorienziel';

  @override
  String get healthDailyCaloriesLabel => 'Kcal pro Tag';

  @override
  String get healthAddMealTitle => 'Mahlzeit hinzufügen';

  @override
  String get healthMealTypeLabel => 'Mahlzeit';

  @override
  String get healthMealBreakfast => 'Frühstück';

  @override
  String get healthMealLunch => 'Mittagessen';

  @override
  String get healthMealDinner => 'Abendessen';

  @override
  String get healthMealSnack => 'Snack';

  @override
  String get healthCaloriesLabel => 'Kalorien';

  @override
  String get healthEnterCalories => 'Kalorien eingeben';

  @override
  String get healthMealDescriptionLabel => 'Was hast du gegessen?';

  @override
  String get healthAddDescription => 'Beschreibung hinzufügen';

  @override
  String get healthAddBurnTitle => 'Verbrannte Kalorien hinzufügen';

  @override
  String get healthCaloriesBurnedLabel => 'Verbrannte Kalorien';

  @override
  String get healthCommentLabel => 'Kommentar';

  @override
  String get healthWaterTodayTitle =>
      'Wie viel Wasser hast du heute getrunken?';

  @override
  String get healthSaveWater => 'Wasser speichern';

  @override
  String get healthSetTarget => 'Ziel festlegen';

  @override
  String healthTargetCalories(Object calories) {
    return 'Ziel $calories kcal';
  }

  @override
  String get healthAddMealButton => 'Essen hinzufügen';

  @override
  String get healthAddBurnButton => 'Verbrauch hinzufügen';

  @override
  String healthWaterButton(Object liters) {
    return 'Wasser $liters L';
  }

  @override
  String get healthConsumed => 'Gegessen';

  @override
  String get healthBurned => 'Verbrannt';

  @override
  String get healthBalance => 'Bilanz';

  @override
  String get healthDeltaVsTarget => 'Abweichung vom Ziel';

  @override
  String get healthWaterDrunk => 'Getrunkenes Wasser';

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
  String get healthMealsTodayTitle => 'Mahlzeiten heute';

  @override
  String get healthNoMeals => 'Noch keine Essenseinträge.';

  @override
  String get healthBurnsTitle => 'Verbrannte Kalorien';

  @override
  String get healthNoBurns => 'Noch keine Einträge zu verbrannten Kalorien.';

  @override
  String get healthNoComment => 'Kein Kommentar';

  @override
  String get hobbyTrackerTitle => 'Hobby-Tracker';

  @override
  String get hobbyTrackerNewHobbyTitle => 'Neues Hobby';

  @override
  String get hobbyTrackerHobbyNameLabel => 'Hobbyname';

  @override
  String get hobbyTrackerEnterHobbyValidator => 'Gib ein Hobby ein';

  @override
  String get hobbyTrackerWeeklyGoalMinutesLabel => 'Wochenziel, Minuten';

  @override
  String get hobbyTrackerEnterGoalValidator => 'Gib ein Ziel ein';

  @override
  String get hobbyTrackerCreateButton => 'Erstellen';

  @override
  String hobbyTrackerAddTimeTitle(Object title) {
    return 'Zeit hinzufügen: $title';
  }

  @override
  String get hobbyTrackerMinutesSpentLabel => 'Aufgewendete Minuten';

  @override
  String get hobbyTrackerNoteLabel => 'Notiz';

  @override
  String get hobbyTrackerDeleteConfirmTitle => 'Hobby löschen?';

  @override
  String hobbyTrackerDeleteConfirmBody(Object title) {
    return 'Hobby „$title“ wird zusammen mit allen Einträgen gelöscht.';
  }

  @override
  String get hobbyTrackerAddHobbyTooltip => 'Hobby hinzufügen';

  @override
  String get hobbyTrackerEmptyText =>
      'Noch keine Hobbys. Füge deine erste Aktivität hinzu und beginne, Zeit zu tracken.';

  @override
  String get hobbyTrackerCreateHobbyButton => 'Hobby erstellen';

  @override
  String get hobbyTrackerDeleteHobbyTooltip => 'Hobby löschen';

  @override
  String get hobbyTrackerAddEntryButton => 'Eintrag hinzufügen';

  @override
  String hobbyTrackerToday(Object value) {
    return 'Heute $value';
  }

  @override
  String hobbyTrackerWeek(Object value) {
    return 'Woche $value';
  }

  @override
  String hobbyTrackerGoal(Object value) {
    return 'Ziel: $value';
  }

  @override
  String hobbyTrackerMinutesShort(Object minutes) {
    return '$minutes Min.';
  }

  @override
  String hobbyTrackerHoursShort(Object hours) {
    return '$hours Std.';
  }

  @override
  String hobbyTrackerHoursMinutesShort(Object hours, Object minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String get importGoalsReviewTitle => 'Ziele importieren';

  @override
  String get importGoalsReviewSubtitle =>
      'Wähle aus, was importiert werden soll, und passe bei Bedarf Titel oder Beschreibung an.';

  @override
  String get importGoalsReviewSelectAll => 'Alles auswählen';

  @override
  String get importGoalsReviewYes => 'Ja';

  @override
  String get importGoalsReviewNo => 'Nein';

  @override
  String get importGoalsReviewListSection => 'Liste';

  @override
  String get importGoalsReviewImport => 'Importieren';

  @override
  String get importGoalsReviewFieldTitle => 'Titel';

  @override
  String get importGoalsReviewFieldDescription => 'Beschreibung';

  @override
  String importGoalsReviewTime(Object time) {
    return 'Zeit: $time';
  }

  @override
  String get importGoalsReviewChange => 'Ändern';

  @override
  String get shoppingBasketCopyHeader => '🛒 Einkaufsliste';

  @override
  String shoppingDueDatePrefix(Object date) {
    return 'bis $date';
  }

  @override
  String get shoppingBasketCopied => 'Einkaufsliste kopiert';

  @override
  String get shoppingNewWishlistItem => 'Neuer Wunschlisten-Eintrag';

  @override
  String get shoppingNewPurchase => 'Neue Anschaffung';

  @override
  String get shoppingEditItem => 'Eintrag bearbeiten';

  @override
  String get shoppingFieldTitle => 'Titel';

  @override
  String get shoppingEnterTitle => 'Gib einen Titel ein';

  @override
  String get shoppingFieldDescription => 'Beschreibung';

  @override
  String get shoppingFieldPrice => 'Preis';

  @override
  String get shoppingFieldStore => 'Geschäft';

  @override
  String get shoppingFieldExpenseCategory => 'Ausgabenkategorie';

  @override
  String get shoppingNoCategory => 'Keine Kategorie';

  @override
  String get shoppingAlreadyBought => 'Schon gekauft';

  @override
  String get shoppingPurchaseDate => 'Kaufdatum';

  @override
  String get shoppingReset => 'Zurücksetzen';

  @override
  String get shoppingEmpty => 'Noch leer.';

  @override
  String get shoppingTrackerTitle => 'Shopping-Tracker';

  @override
  String get shoppingCopyBasket => 'Warenkorb kopieren';

  @override
  String get shoppingBasketTitle => 'Einkaufsliste';

  @override
  String get shoppingWishlistTitle => 'Wunschliste';

  @override
  String get profileOpenLinkFailed => 'Link konnte nicht geöffnet werden.';

  @override
  String get profileDangerZoneSubtitle => 'Kontolöschung';

  @override
  String get profileLegalDocumentsTitle => 'Rechtliche Dokumente';

  @override
  String get profileLegalDocumentsSubtitle =>
      'Du kannst Privacy Policy, Datenschutz, Terms of Use und Impressum jederzeit öffnen.';

  @override
  String get profileLegalPrivacyTitle => 'Privacy Policy';

  @override
  String get profileLegalPrivacySubtitle =>
      'Englische Version der Datenschutzerklärung';

  @override
  String get profileLegalDatenschutzTitle => 'Datenschutzerklärung';

  @override
  String get profileLegalDatenschutzSubtitle =>
      'Deutsche Version der Datenschutzerklärung';

  @override
  String get profileLegalTermsTitle => 'Terms of Use';

  @override
  String get profileLegalTermsSubtitle =>
      'Regeln und Bedingungen für die Nutzung von Ladna';

  @override
  String get profileLegalImpressumTitle => 'Impressum';

  @override
  String get profileLegalImpressumSubtitle =>
      'Rechtlicher Hinweis und Anbieterinformationen';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageRussian => 'Russisch';

  @override
  String get settingsLanguageEnglish => 'Englisch';

  @override
  String get settingsLanguageGerman => 'Deutsch';

  @override
  String get settingsLanguageFrench => 'Französisch';

  @override
  String get settingsLanguageSpanish => 'Spanisch';

  @override
  String get settingsLanguageTurkish => 'Türkisch';

  @override
  String get profileWebNotificationsEveningBody =>
      'Markiere deine Gewohnheiten und schließe den Tag ab 👌';

  @override
  String get profileWebNotificationsPermissionDeniedToast =>
      'Berechtigung wurde nicht erteilt. Prüfe die Benachrichtigungseinstellungen deines Browsers.';

  @override
  String get profileWebNotificationsPermissionGrantedToast =>
      'Browser-Benachrichtigungen sind aktiviert ✅';

  @override
  String profileWebNotificationsTimeChangedToast(Object time) {
    return 'Benachrichtigungszeit: $time';
  }

  @override
  String get profileWebNotificationsLoadingSettings =>
      'Einstellungen werden geladen...';

  @override
  String get profileWebNotificationsEnabledToast =>
      'Aktiviert. Denke daran, Benachrichtigungen im Browser zu erlauben.';

  @override
  String get profileWebNotificationsDisabledToast => 'Deaktiviert.';

  @override
  String get profileEditChipsDefaultHint =>
      'Werte durch Kommas getrennt eingeben';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei Ladna';

  @override
  String get onboardingWelcomeBody =>
      'Ich zeige dir kurz die wichtigsten Funktionen: Schnellaktionen, Aufgaben, große Ziele, Profil, Berichte und Finanzen.';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingStart => 'Starten';

  @override
  String get onboardingFinishTitle => 'Fertig';

  @override
  String get onboardingFinishBody =>
      'Jetzt weißt du, wo sich die wichtigsten Funktionen von Ladna befinden. Du kannst das Tutorial später über das Hilfe-Symbol auf der Startseite erneut starten.';

  @override
  String get onboardingGotIt => 'Verstanden';

  @override
  String get onboardingMainQuickActionsTitle => 'Schnellaktionen';

  @override
  String get onboardingMainQuickActionsText =>
      'Mit dieser Schaltfläche kannst du schnell Aufgaben, Stimmung, Ausgaben und Gewohnheiten hinzufügen sowie den AI-Plan starten.';

  @override
  String get onboardingMainNavigationTitle => 'Ladna-Navigation';

  @override
  String get onboardingMainNavigationText =>
      'Hier findest du die Hauptbereiche: Startseite, Aufgaben, große Ziele, Profil, Berichte und Finanzen.';

  @override
  String get onboardingMainHelpTitle => 'Anleitung erneut öffnen';

  @override
  String get onboardingMainHelpText =>
      'Tippe auf dieses Symbol, wenn du das interaktive How-To später wiederholen möchtest.';

  @override
  String get onboardingGoalsFilterTitle => 'Filter nach Lebensbereich';

  @override
  String get onboardingGoalsFilterText =>
      'Wähle Karriere, Gesundheit, Finanzen und andere Bereiche, um Aufgaben im passenden Kontext zu sehen.';

  @override
  String get onboardingGoalsModeTitle => 'Dashboard oder Kalender';

  @override
  String get onboardingGoalsModeText =>
      'Das Dashboard zeigt das Gesamtbild, während der Kalender beim Planen von Aufgaben nach Tagen und Wochen hilft.';

  @override
  String get onboardingGoalsAddTitle => 'Aktionen hinzufügen';

  @override
  String get onboardingGoalsAddText =>
      'Hier kannst du schnell eine Aufgabe, eine Aufgabenserie oder einen ganzen Tag mit mehreren Einträgen erfassen.';

  @override
  String get onboardingReportsPeriodTitle => 'Analysezeitraum';

  @override
  String get onboardingReportsPeriodText =>
      'Wechsle zwischen Tag, Woche und Monat, um Ziele, Stimmung, Gewohnheiten und Finanzen im Verlauf zu vergleichen.';

  @override
  String get onboardingReportsChartTitle => 'Interaktive Diagramme';

  @override
  String get onboardingReportsChartText =>
      'Tippe auf Diagrammsegmente und Punkte — die App zeigt Details nur zum ausgewählten Element.';

  @override
  String get onboardingUserGoalsHeaderTitle => 'Große Ziele';

  @override
  String get onboardingUserGoalsHeaderText =>
      'Hier werden strategische Ziele gespeichert: kurzfristig, mittelfristig und langfristig. Später kannst du tägliche Aufgaben damit verknüpfen.';

  @override
  String get onboardingUserGoalsFiltersTitle => 'Zielfilter';

  @override
  String get onboardingUserGoalsFiltersText =>
      'Filtere Ziele nach Lebensbereich und Horizont, um dich schnell auf die gewünschte Richtung zu fokussieren.';

  @override
  String get onboardingUserGoalsAddTitle => 'Großes Ziel erstellen';

  @override
  String get onboardingUserGoalsAddText =>
      'Tippe hier, um ein Ziel hinzuzufügen sowie Lebensbereich, Horizont und Deadline auszuwählen.';

  @override
  String get onboardingProfileHeaderTitle => 'Profil';

  @override
  String get onboardingProfileHeaderText =>
      'Das ist das Zentrum deiner persönlichen Ladna-Einstellungen: Konto, Fokus, Gewohnheiten und App-Präferenzen.';

  @override
  String get onboardingProfileCardTitle => 'Persönliche Daten';

  @override
  String get onboardingProfileCardText =>
      'Name, Alter und Basisparameter werden verwendet, um die Oberfläche und zukünftige AI-Empfehlungen zu personalisieren.';

  @override
  String get onboardingProfileFocusTitle => 'Fokus und Einstellungen';

  @override
  String get onboardingProfileFocusText =>
      'Diese Parameter beeinflussen Tagesplanung, Analysen und Empfehlungen in der App.';

  @override
  String get onboardingBudgetIncomeTitle => 'Einnahmekategorien';

  @override
  String get onboardingBudgetIncomeText =>
      'Füge Einnahmequellen hinzu, damit die Finanzanalyse die Struktur deiner Zuflüsse versteht.';

  @override
  String get onboardingBudgetExpenseTitle => 'Ausgabenkategorien';

  @override
  String get onboardingBudgetExpenseText =>
      'Hier richtest du Ausgabenkategorien und Limits ein. So siehst du, wohin dein Budget am schnellsten fließt.';

  @override
  String get onboardingBudgetJarsTitle => 'Spartöpfe und Verteilung';

  @override
  String get onboardingBudgetJarsText =>
      'Nutze Spartöpfe für Sparziele: Reisen, Notgroschen, Investments oder größere Anschaffungen.';

  @override
  String get onboardingBudgetSaveTitle => 'Einstellungen speichern';

  @override
  String get onboardingBudgetSaveText =>
      'Vergiss nach Änderungen nicht, dein Budget zu speichern, damit Kategorien und Limits in der Datenbank landen.';

  @override
  String get onboardingDayGoalsSummaryTitle => 'Tagesübersicht';

  @override
  String get onboardingDayGoalsSummaryText =>
      'Diese Karte zeigt deinen Tagesfortschritt: wie viele Aufgaben erledigt sind, was übrig bleibt und wie viel Zeit noch geplant ist.';

  @override
  String get onboardingDayGoalsFilterTitle => 'Erledigte ausblenden';

  @override
  String get onboardingDayGoalsFilterText =>
      'Aktiviere diesen Filter, um nur aktive Aufgaben auf dem Bildschirm zu behalten.';

  @override
  String get onboardingDayGoalsFabTitle => 'Aktivität hinzufügen';

  @override
  String get onboardingDayGoalsFabText =>
      'Mit dieser Schaltfläche kannst du eine Aufgabe hinzufügen, einen Journaleintrag erkennen oder Google Kalender synchronisieren.';

  @override
  String get onboardingQuestionnaireProgressTitle => 'Einrichtungsfortschritt';

  @override
  String get onboardingQuestionnaireProgressText =>
      'Hier siehst du, auf welchem Schritt der Ersteinrichtung du dich gerade befindest.';

  @override
  String get onboardingQuestionnaireNextTitle => 'Weitergehen';

  @override
  String get onboardingQuestionnaireNextText =>
      'Tippe nach Abschluss des aktuellen Schritts hier. Am Ende speichert Ladna dein Profil, deine Lebensbereiche und Ziele.';

  @override
  String get onboardingExpensesControlsTitle => 'Tag und Budgeteinstellungen';

  @override
  String get onboardingExpensesControlsText =>
      'Wähle hier das Datum der Transaktion und öffne Einstellungen für Kategorien, Limits und Spartöpfe.';

  @override
  String get onboardingExpensesSummaryTitle => 'Monatliche Finanzübersicht';

  @override
  String get onboardingExpensesSummaryText =>
      'Diese Karte zeigt monatliche Einnahmen, Ausgaben und freien Saldo — die Grundlage für die Budgetanalyse.';

  @override
  String get onboardingExpensesTransactionsTitle =>
      'Transaktionen für den ausgewählten Tag';

  @override
  String get onboardingExpensesTransactionsText =>
      'Hier siehst du Einnahmen und Ausgaben des Tages. Tippe auf eine Transaktion zum Bearbeiten oder wische nach links zum Löschen.';

  @override
  String get onboardingExpensesFabTitle => 'Einnahme oder Ausgabe hinzufügen';

  @override
  String get onboardingExpensesFabText =>
      'Tippe auf Plus, um das Menü zu öffnen und schnell eine neue Finanztransaktion hinzuzufügen.';

  @override
  String get onboardingNextHint => 'Tippe auf den Bildschirm, um fortzufahren';

  @override
  String get registerLegalTermsTitle => 'Terms of Use';

  @override
  String get registerLegalPrivacyPrefix =>
      'Ich stimme der Verarbeitung meiner personenbezogenen Daten gemäß der';

  @override
  String get registerLegalTermsPrefix => 'Ich stimme den';

  @override
  String get registerLegalOptionalLinksPrefix => 'Ebenfalls verfügbar:';

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
      'Bitte öffne und lies zuerst Terms of Use und Privacy Policy.';

  @override
  String registerLegalOpenFailed(Object document) {
    return '$document konnte nicht geöffnet werden.';
  }

  @override
  String get registerLegalAcceptedText =>
      'Ich habe Terms of Use und Privacy Policy gelesen und akzeptiere sie.';

  @override
  String get registerLegalOpenRequiredDocsText =>
      'Öffne und lies zuerst Terms of Use und Privacy Policy. Datenschutzerklärung und Impressum sind als zusätzliche rechtliche Informationen verfügbar.';

  @override
  String get launcherDayGoals => 'Ziele';

  @override
  String launcherPlannedHoursDescription(Object hours) {
    return 'Plan: $hours Std.';
  }

  @override
  String get profileGdprSection => 'Datenschutz & GDPR';

  @override
  String get profileGdprExportTitle => 'Meine Daten exportieren';

  @override
  String get profileGdprExportSubtitle =>
      'Erstellt einen JSON-Export aller App-Daten, die deinem Benutzerkonto zugeordnet sind.';

  @override
  String get profileGdprNotSignedInToast =>
      'Du bist nicht angemeldet. Der Datenexport ist daher nicht möglich.';

  @override
  String get profileGdprDialogTitle => 'GDPR-Datenexport erstellt';

  @override
  String profileGdprDialogFileName(String fileName) {
    return 'Dateiname: $fileName';
  }

  @override
  String get profileGdprDialogBody =>
      'Der Export wurde als JSON erstellt und in die Zwischenablage kopiert.\n\nDu kannst den Inhalt jetzt in eine Datei mit der Endung .json einfügen.';

  @override
  String get profileGdprDialogPreviewLabel => 'Vorschau:';

  @override
  String get profileGdprCopyButton => 'Kopieren';

  @override
  String get profileGdprDoneButton => 'Fertig';

  @override
  String get profileGdprCopiedAgainToast =>
      'Datenexport wurde erneut in die Zwischenablage kopiert.';

  @override
  String get profileGdprCreatedToast =>
      'GDPR-Datenexport wurde erstellt und kopiert.';

  @override
  String profileGdprFailedToast(String error) {
    return 'Datenexport fehlgeschlagen: $error';
  }

  @override
  String get profileGdprExportNoteAccount =>
      'Dieser Export enthält das authentifizierte Benutzerkonto, den Profil-Datensatz aus public.users, alle benutzerbezogenen App-Tabellen und Referenztabellen, die zum Verständnis der exportierten Antworten erforderlich sind.';

  @override
  String get profileGdprExportNoteRls =>
      'Der Export wird durch Supabase Row Level Security begrenzt. Tabellen, die nicht existieren oder nicht gelesen werden dürfen, werden mit einem _export_warning-Eintrag zurückgegeben.';

  @override
  String get profileGdprExportNoteEncrypted =>
      'Verschlüsselte Payload-Felder werden so exportiert, wie sie gespeichert sind. Die Entschlüsselung hängt von der Verschlüsselungslogik der App und der aktiven Benutzersitzung ab.';
}
