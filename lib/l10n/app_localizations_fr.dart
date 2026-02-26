// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Nest App';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'Créer un compte';

  @override
  String get home => 'Accueil';

  @override
  String get budgetSetupTitle => 'Budget et bocaux';

  @override
  String get budgetSetupSaved => 'Paramètres enregistrés';

  @override
  String get budgetSetupSaveError => 'Erreur d’enregistrement';

  @override
  String get budgetIncomeCategoriesTitle => 'Catégories de revenus';

  @override
  String get budgetIncomeCategoriesSubtitle =>
      'Utilisées lors de l’ajout d’un revenu';

  @override
  String get settingsLanguageTitle => 'Langue';

  @override
  String get settingsLanguageSubtitle =>
      'Choisis la langue de l’application. « Système » utilise la langue de l’appareil.';

  @override
  String get budgetExpenseCategoriesTitle => 'Catégories de dépenses';

  @override
  String get budgetExpenseCategoriesSubtitle =>
      'Les limites t’aident à garder tes dépenses sous contrôle';

  @override
  String get budgetJarsTitle => 'Bocaux d’épargne';

  @override
  String get budgetJarsSubtitle =>
      'Le pourcentage correspond à la part des fonds libres ajoutée automatiquement';

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
  String get budgetAddJar => 'Ajouter un bocal';

  @override
  String get budgetJarAdded => 'Bocal ajouté';

  @override
  String budgetJarAddFailed(Object error) {
    return 'Impossible d’ajouter : $error';
  }

  @override
  String get budgetJarDeleted => 'Bocal supprimé';

  @override
  String budgetJarDeleteFailed(Object error) {
    return 'Impossible de supprimer : $error';
  }

  @override
  String get budgetNoJarsTitle => 'Aucun bocal pour l’instant';

  @override
  String get budgetNoJarsSubtitle =>
      'Crée ton premier objectif d’épargne — on t’aidera à l’atteindre.';

  @override
  String get budgetSetOrChangeLimit => 'Définir/modifier la limite';

  @override
  String get budgetDeleteCategoryTitle => 'Supprimer la catégorie ?';

  @override
  String budgetCategoryLabel(Object name) {
    return 'Catégorie : $name';
  }

  @override
  String get budgetDeleteJarTitle => 'Supprimer le bocal ?';

  @override
  String budgetJarLabel(Object title) {
    return 'Bocal : $title';
  }

  @override
  String budgetJarSummary(Object saved, Object percent, Object targetPart) {
    return 'Épargné : $saved ₽ • Pourcentage : $percent%$targetPart';
  }

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonLoading => 'chargement…';

  @override
  String get commonSaving => 'Enregistrement…';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonUpdate => 'Mettre à jour';

  @override
  String get commonCollapse => 'Réduire';

  @override
  String get commonDots => '...';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonChange => 'Changer';

  @override
  String get commonDate => 'Date';

  @override
  String get commonRefresh => 'Actualiser';

  @override
  String get commonDash => '—';

  @override
  String get commonPick => 'Choisir';

  @override
  String get commonRemove => 'Retirer';

  @override
  String get commonOr => 'ou';

  @override
  String get commonCreate => 'Créer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonCloseTooltip => 'Fermer';

  @override
  String get commonTitle => 'Titre';

  @override
  String get commonDeleteConfirmTitle => 'Supprimer l’entrée ?';

  @override
  String get dayGoalsAllLifeBlocks => 'Tous les domaines';

  @override
  String get dayGoalsEmpty => 'Aucun objectif pour ce jour';

  @override
  String dayGoalsAddFailed(Object error) {
    return 'Impossible d’ajouter un objectif : $error';
  }

  @override
  String get dayGoalsUpdated => 'Objectif mis à jour';

  @override
  String dayGoalsUpdateFailed(Object error) {
    return 'Impossible de mettre à jour l’objectif : $error';
  }

  @override
  String get dayGoalsDeleted => 'Objectif supprimé';

  @override
  String dayGoalsDeleteFailed(Object error) {
    return 'Impossible de supprimer : $error';
  }

  @override
  String dayGoalsToggleFailed(Object error) {
    return 'Impossible de changer l’état : $error';
  }

  @override
  String get dayGoalsDeleteConfirmTitle => 'Supprimer l’objectif ?';

  @override
  String get dayGoalsFabAddTitle => 'Ajouter un objectif';

  @override
  String get dayGoalsFabAddSubtitle => 'Créer manuellement';

  @override
  String get dayGoalsFabScanTitle => 'Scanner';

  @override
  String get dayGoalsFabScanSubtitle => 'Photo du journal';

  @override
  String get dayGoalsFabCalendarTitle => 'Google Calendar';

  @override
  String get dayGoalsFabCalendarSubtitle =>
      'Importer/exporter les objectifs d’aujourd’hui';

  @override
  String get epicIntroSkip => 'Passer';

  @override
  String get epicIntroSubtitle =>
      'Un foyer pour les pensées. Un lieu où les objectifs,\nles rêves et les plans grandissent — avec douceur et pleine conscience.';

  @override
  String get epicIntroPrimaryCta => 'Commencer mon parcours';

  @override
  String get epicIntroLater => 'Plus tard';

  @override
  String get epicIntroSecondaryCta => 'Se connecter';

  @override
  String get epicIntroFooter =>
      'Tu peux toujours revenir au prologue dans les Paramètres.';

  @override
  String get homeMoodSaved => 'Humeur enregistrée';

  @override
  String homeMoodSaveFailed(Object error) {
    return 'Impossible d’enregistrer : $error';
  }

  @override
  String get homeTodayAndWeekTitle => 'Aujourd’hui et semaine';

  @override
  String get homeTodayAndWeekSubtitle =>
      'Aperçu rapide — toutes les métriques clés sont ici';

  @override
  String get homeMetricMoodTitle => 'Humeur';

  @override
  String get homeMoodNoEntry => 'aucune entrée';

  @override
  String get homeMoodNoNote => 'aucune note';

  @override
  String get homeMoodHasNote => 'avec note';

  @override
  String get homeMetricTasksTitle => 'Tâches';

  @override
  String get homeMetricHoursPerDayTitle => 'Heures/jour';

  @override
  String get homeMetricEfficiencyTitle => 'Efficacité';

  @override
  String homeEfficiencyPlannedHours(Object hours) {
    return 'plan $hours h';
  }

  @override
  String get homeMoodTodayTitle => 'Humeur du jour';

  @override
  String get homeMoodNoTodayEntry => 'Aucune entrée pour aujourd’hui';

  @override
  String get homeMoodEntryNoNote => 'Entrée existante (sans note)';

  @override
  String get homeMoodQuickHint =>
      'Ajoute un check-in rapide — ça prend 10 secondes';

  @override
  String get homeMoodUpdateHint =>
      'Tu peux mettre à jour — cela remplacera l’entrée d’aujourd’hui';

  @override
  String get homeMoodNoteLabel => 'Note (optionnel)';

  @override
  String get homeMoodNoteHint => 'Qu’est-ce qui a influencé ton état ?';

  @override
  String get homeOpenMoodHistoryCta => 'Ouvrir l’historique d’humeur';

  @override
  String get homeWeekSummaryTitle => 'Résumé de la semaine';

  @override
  String get homeOpenReportsCta => 'Ouvrir les rapports détaillés';

  @override
  String get homeWeekExpensesTitle => 'Dépenses de la semaine';

  @override
  String get homeNoExpensesThisWeek => 'Aucune dépense cette semaine';

  @override
  String get homeOpenExpensesCta => 'Ouvrir les dépenses';

  @override
  String homeExpensesTotal(Object total) {
    return 'Total : $total €';
  }

  @override
  String homeExpensesAvgPerDay(Object avg) {
    return 'Moy/jour : $avg €';
  }

  @override
  String get homeInsightsTitle => 'Insights';

  @override
  String homeTopCategory(Object category, Object amount) {
    return '• Catégorie principale : $category — $amount €';
  }

  @override
  String homePeakExpense(Object day, Object amount) {
    return '• Pic de dépenses : $day — $amount €';
  }

  @override
  String get homeOpenDetailedExpensesCta => 'Ouvrir les dépenses détaillées';

  @override
  String get homeWeekCardTitle => 'Semaine';

  @override
  String get homeWeekLoadFailedTitle =>
      'Impossible de charger les statistiques';

  @override
  String get homeWeekLoadFailedSubtitle =>
      'Vérifie ta connexion internet ou réessaie plus tard.';

  @override
  String get gcalTitle => 'Google Calendar';

  @override
  String get gcalHeaderImport =>
      'Trouve des événements dans ton agenda et importe-les comme objectifs.';

  @override
  String get gcalHeaderExport =>
      'Choisis une période et exporte les objectifs de l’app vers Google Calendar.';

  @override
  String get gcalModeImport => 'Importer';

  @override
  String get gcalModeExport => 'Exporter';

  @override
  String get gcalCalendarLabel => 'Agenda';

  @override
  String get gcalPrimaryCalendar => 'Principal (par défaut)';

  @override
  String get gcalPeriodLabel => 'Période';

  @override
  String get gcalRangeToday => 'Aujourd’hui';

  @override
  String get gcalRangeNext7 => '7 prochains jours';

  @override
  String get gcalRangeNext30 => '30 prochains jours';

  @override
  String get gcalRangeCustom => 'Choisir la période...';

  @override
  String get gcalDefaultLifeBlockLabel => 'Domaine par défaut (pour l’import)';

  @override
  String get gcalLifeBlockForGoalLabel => 'Domaine pour cet objectif';

  @override
  String get gcalEventsNotLoaded => 'Les événements ne sont pas chargés';

  @override
  String get gcalConnectToLoadEvents =>
      'Connecte ton compte pour charger les événements';

  @override
  String get gcalExportHint =>
      'L’export créera des événements dans l’agenda sélectionné pour la période choisie.';

  @override
  String get gcalConnect => 'Connecter';

  @override
  String get gcalConnected => 'Connecté';

  @override
  String get gcalFindEvents => 'Rechercher des événements';

  @override
  String get gcalImport => 'Importer';

  @override
  String get gcalExport => 'Exporter';

  @override
  String get gcalNoTitle => 'Sans titre';

  @override
  String gcalImportedGoalsCount(Object count) {
    return 'Objectifs importés : $count';
  }

  @override
  String gcalExportedGoalsCount(Object count) {
    return 'Objectifs exportés : $count';
  }

  @override
  String get launcherQuickFunctionsTitle => 'Actions rapides';

  @override
  String get launcherQuickFunctionsSubtitle =>
      'Navigation et actions en un tap';

  @override
  String get launcherSectionsTitle => 'Sections';

  @override
  String get launcherQuickTitle => 'Rapide';

  @override
  String get launcherHome => 'Accueil';

  @override
  String get launcherGoals => 'Objectifs';

  @override
  String get launcherMood => 'Humeur';

  @override
  String get launcherProfile => 'Profil';

  @override
  String get launcherInsights => 'Insights';

  @override
  String get launcherReports => 'Rapports';

  @override
  String get launcherMassAddTitle => 'Ajout groupé pour la journée';

  @override
  String get launcherMassAddSubtitle => 'Dépenses + Objectifs + Humeur';

  @override
  String get launcherAiPlanTitle => 'Plan IA pour semaine/mois';

  @override
  String get launcherAiPlanSubtitle =>
      'Analyse des objectifs, du questionnaire et des progrès';

  @override
  String get launcherAiInsightsTitle => 'Insights IA';

  @override
  String get launcherAiInsightsSubtitle =>
      'Comment les événements influencent les objectifs et les progrès';

  @override
  String get launcherRecurringGoalTitle => 'Objectif récurrent';

  @override
  String get launcherRecurringGoalSubtitle =>
      'Planifier plusieurs jours à l’avance';

  @override
  String get launcherGoogleCalendarSyncTitle =>
      'Synchronisation Google Calendar';

  @override
  String get launcherGoogleCalendarSyncSubtitle =>
      'Exporter les objectifs vers l’agenda';

  @override
  String get launcherNoDatesToCreate =>
      'Aucune date à créer (vérifie la deadline/les paramètres).';

  @override
  String launcherCreateSeriesFailed(Object error) {
    return 'Impossible de créer une série d’objectifs : $error';
  }

  @override
  String launcherSaveError(Object error) {
    return 'Erreur d’enregistrement : $error';
  }

  @override
  String launcherCreatedGoalsCount(Object count) {
    return 'Objectifs créés : $count';
  }

  @override
  String launcherSavedSummary(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodPart,
  ) {
    return 'Enregistré : $expenses dépense(s), $incomes revenu(s), $goals objectif(s), $habits habitude(s)$moodPart';
  }

  @override
  String get homeTitleHome => 'Accueil';

  @override
  String get homeTitleGoals => 'Objectifs';

  @override
  String get homeTitleMood => 'Humeur';

  @override
  String get homeTitleProfile => 'Profil';

  @override
  String get homeTitleReports => 'Rapports';

  @override
  String get homeTitleExpenses => 'Dépenses';

  @override
  String get homeTitleApp => 'MyNEST';

  @override
  String get homeSignOutTooltip => 'Se déconnecter';

  @override
  String get homeSignOutTitle => 'Se déconnecter ?';

  @override
  String get homeSignOutSubtitle => 'Ta session actuelle sera terminée.';

  @override
  String get homeSignOutConfirm => 'Se déconnecter';

  @override
  String homeSignOutFailed(Object error) {
    return 'Impossible de se déconnecter : $error';
  }

  @override
  String get homeQuickActionsTooltip => 'Actions rapides';

  @override
  String get expensesTitle => 'Dépenses';

  @override
  String get expensesPickDate => 'Choisir une date';

  @override
  String get expensesCommitTooltip => 'Verrouiller l’allocation des bocaux';

  @override
  String get expensesCommitUndoTooltip => 'Annuler le verrouillage';

  @override
  String get expensesBudgetSettings => 'Paramètres du budget';

  @override
  String get expensesCommitDone => 'Allocation verrouillée';

  @override
  String get expensesCommitUndone => 'Verrouillage supprimé';

  @override
  String get expensesMonthSummary => 'Résumé mensuel';

  @override
  String expensesIncomeLegend(Object value) {
    return 'Revenus $value €';
  }

  @override
  String expensesExpenseLegend(Object value) {
    return 'Dépenses $value €';
  }

  @override
  String expensesFreeLegend(Object value) {
    return 'Libre $value €';
  }

  @override
  String expensesDaySum(Object value) {
    return 'Total du jour : $value €';
  }

  @override
  String get expensesNoTxForDay => 'Aucune transaction pour ce jour';

  @override
  String get expensesDeleteTxTitle => 'Supprimer la transaction ?';

  @override
  String expensesDeleteTxBody(Object category, Object amount) {
    return '$category — $amount €';
  }

  @override
  String get expensesCategoriesMonthTitle => 'Catégories de dépenses du mois';

  @override
  String get expensesNoCategoryData =>
      'Aucune donnée par catégorie pour l’instant';

  @override
  String get expensesJarsTitle => 'Bocaux d’épargne';

  @override
  String get expensesNoJars => 'Aucun bocal pour l’instant';

  @override
  String get expensesCommitShort => 'Verrouiller';

  @override
  String get expensesCommitUndoShort => 'Annuler';

  @override
  String get expensesAddIncome => 'Ajouter un revenu';

  @override
  String get expensesAddExpense => 'Ajouter une dépense';

  @override
  String get loginTitle => 'Se connecter';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginShowPassword => 'Afficher le mot de passe';

  @override
  String get loginHidePassword => 'Masquer le mot de passe';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginCreateAccount => 'Créer un compte';

  @override
  String get loginBtnSignIn => 'Se connecter';

  @override
  String get loginContinueGoogle => 'Continuer avec Google';

  @override
  String get loginContinueApple => 'Continuer avec Apple ID';

  @override
  String get loginErrEmailRequired => 'Saisis l’e-mail';

  @override
  String get loginErrEmailInvalid => 'E-mail invalide';

  @override
  String get loginErrPassRequired => 'Saisis le mot de passe';

  @override
  String get loginErrPassMin6 => 'Minimum 6 caractères';

  @override
  String get loginResetTitle => 'Récupération du mot de passe';

  @override
  String get loginResetSend => 'Envoyer';

  @override
  String get loginResetSent =>
      'E-mail de réinitialisation envoyé. Vérifie ta boîte mail.';

  @override
  String loginResetFailed(Object error) {
    return 'Impossible d’envoyer l’e-mail : $error';
  }

  @override
  String get moodTitle => 'Humeur';

  @override
  String get moodOnePerDay => '1 entrée = 1 jour';

  @override
  String get moodHowDoYouFeel => 'Comment te sens-tu ?';

  @override
  String get moodNoteLabel => 'Note (optionnel)';

  @override
  String get moodNoteHint => 'Qu’est-ce qui a influencé ton humeur ?';

  @override
  String get moodSaved => 'Humeur enregistrée';

  @override
  String get moodUpdated => 'Entrée mise à jour';

  @override
  String get moodHistoryTitle => 'Historique de l’humeur';

  @override
  String get moodTapToEdit => 'Appuie pour modifier';

  @override
  String get moodNoNote => 'Aucune note';

  @override
  String get moodEditTitle => 'Modifier l’entrée';

  @override
  String get moodEmptyTitle => 'Aucune entrée pour l’instant';

  @override
  String get moodEmptySubtitle =>
      'Choisis une date, sélectionne l’humeur et enregistre.';

  @override
  String moodErrSaveFailed(Object error) {
    return 'Impossible d’enregistrer l’humeur : $error';
  }

  @override
  String moodErrUpdateFailed(Object error) {
    return 'Impossible de mettre à jour l’entrée : $error';
  }

  @override
  String moodErrDeleteFailed(Object error) {
    return 'Impossible de supprimer l’entrée : $error';
  }

  @override
  String get onbTopTitle => '';

  @override
  String get onbErrSaveFailed => 'Impossible d’enregistrer tes réponses';

  @override
  String get onbProfileTitle => 'Faisons connaissance';

  @override
  String get onbProfileSubtitle =>
      'Cela aide pour ton profil et la personnalisation';

  @override
  String get onbNameLabel => 'Prénom';

  @override
  String get onbNameHint => 'Par exemple : Viktor';

  @override
  String get onbAgeLabel => 'Âge';

  @override
  String get onbAgeHint => 'Par exemple : 26';

  @override
  String get onbNameNote =>
      'Tu pourras changer ton prénom plus tard dans ton profil.';

  @override
  String get onbBlocksTitle => 'Quels domaines de vie veux-tu suivre ?';

  @override
  String get onbBlocksSubtitle => 'Ce sera la base de tes objectifs et quêtes';

  @override
  String get onbPrioritiesTitle =>
      'Qu’est-ce qui compte le plus pour toi dans les 3–6 prochains mois ?';

  @override
  String get onbPrioritiesSubtitle =>
      'Choisis jusqu’à trois — cela influence les recommandations';

  @override
  String get onbPriorityHealth => 'Santé';

  @override
  String get onbPriorityCareer => 'Carrière';

  @override
  String get onbPriorityMoney => 'Argent';

  @override
  String get onbPriorityFamily => 'Famille';

  @override
  String get onbPriorityGrowth => 'Développement';

  @override
  String get onbPriorityLove => 'Amour';

  @override
  String get onbPriorityCreativity => 'Créativité';

  @override
  String get onbPriorityBalance => 'Équilibre';

  @override
  String onbGoalsBlockTitle(Object block) {
    return 'Objectifs dans « $block »';
  }

  @override
  String get onbGoalsBlockSubtitle =>
      'Focus : tactique → moyen terme → long terme';

  @override
  String get onbGoalLongLabel => 'Objectif long terme (6–24 mois)';

  @override
  String get onbGoalLongHint =>
      'Par exemple : atteindre le niveau B2 en allemand';

  @override
  String get onbGoalMidLabel => 'Objectif moyen terme (2–6 mois)';

  @override
  String get onbGoalMidHint => 'Par exemple : finir A2→B1 et réussir l’examen';

  @override
  String get onbGoalTacticalLabel => 'Objectif tactique (2–4 semaines)';

  @override
  String get onbGoalTacticalHint =>
      'Par exemple : 12×30 min + 2 clubs de conversation';

  @override
  String get onbWhyLabel => 'Pourquoi est-ce important ? (optionnel)';

  @override
  String get onbWhyHint =>
      'Motivation/sens — t’aide à rester sur la bonne voie';

  @override
  String get onbOptionalNote =>
      'Tu peux laisser vide et appuyer sur « Suivant ».';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerNameLabel => 'Prénom';

  @override
  String get registerEmailLabel => 'E-mail';

  @override
  String get registerPasswordLabel => 'Mot de passe';

  @override
  String get registerConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get registerShowPassword => 'Afficher le mot de passe';

  @override
  String get registerHidePassword => 'Masquer le mot de passe';

  @override
  String get registerBtnSignUp => 'S’inscrire';

  @override
  String get registerContinueGoogle => 'Continuer avec Google';

  @override
  String get registerContinueApple => 'Continuer avec Apple ID';

  @override
  String get registerContinueAppleIos => 'Continuer avec Apple ID (iOS)';

  @override
  String get registerHaveAccountCta => 'Déjà un compte ? Se connecter';

  @override
  String get registerErrNameRequired => 'Saisis ton prénom';

  @override
  String get registerErrEmailRequired => 'Saisis ton e-mail';

  @override
  String get registerErrEmailInvalid => 'E-mail invalide';

  @override
  String get registerErrPassRequired => 'Saisis un mot de passe';

  @override
  String get registerErrPassMin8 => 'Au moins 8 caractères';

  @override
  String get registerErrPassNeedLower => 'Ajoute une minuscule (a-z)';

  @override
  String get registerErrPassNeedUpper => 'Ajoute une majuscule (A-Z)';

  @override
  String get registerErrPassNeedDigit => 'Ajoute un chiffre (0-9)';

  @override
  String get registerErrConfirmRequired => 'Répète le mot de passe';

  @override
  String get registerErrPasswordsMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get registerErrAcceptTerms =>
      'Tu dois accepter les Conditions et la Politique de confidentialité';

  @override
  String get registerAppleOnlyIos =>
      'Apple ID est disponible sur iPhone/iPad (iOS uniquement)';

  @override
  String get welcomeAppName => 'VitaPlatform';

  @override
  String get welcomeSubtitle =>
      'Gère tes objectifs, ton humeur et ton temps\n— tout au même endroit';

  @override
  String get welcomeSignIn => 'Se connecter';

  @override
  String get welcomeCreateAccount => 'Créer un compte';

  @override
  String get habitsWeekTitle => 'Habitudes';

  @override
  String get habitsWeekTopTitle => 'Habitudes (top de la semaine)';

  @override
  String get habitsWeekEmptyHint =>
      'Ajoute au moins une habitude — tes progrès apparaîtront ici.';

  @override
  String get habitsWeekFooterHint =>
      'Nous affichons tes habitudes les plus actives sur les 7 derniers jours.';

  @override
  String get mentalWeekTitle => 'Santé mentale';

  @override
  String mentalWeekLoadError(Object error) {
    return 'Erreur de chargement : $error';
  }

  @override
  String get mentalWeekNoAnswers =>
      'Aucune réponse trouvée pour cette semaine (pour l’utilisateur actuel).';

  @override
  String get mentalWeekYesNoHeader => 'Oui/Non (semaine)';

  @override
  String get mentalWeekScalesHeader => 'Échelles (tendance)';

  @override
  String get mentalWeekFooterHint =>
      'Nous n’affichons que quelques questions pour garder l’écran clair.';

  @override
  String get mentalWeekNoData => 'Aucune donnée';

  @override
  String mentalWeekYesCount(Object yes, Object total) {
    return 'Oui : $yes/$total';
  }

  @override
  String get moodWeekTitle => 'Humeur de la semaine';

  @override
  String moodWeekMarkedCount(Object filled, Object total) {
    return 'Saisi : $filled/$total';
  }

  @override
  String get moodWeekAverageDash => 'Moyenne : —';

  @override
  String moodWeekAverageValue(Object avg) {
    return 'Moyenne : $avg/5';
  }

  @override
  String get moodWeekFooterHint =>
      'C’est un aperçu rapide. Les détails sont plus bas dans l’historique.';

  @override
  String get goalsByBlockTitle => 'Objectifs par domaine';

  @override
  String get goalsAddTooltip => 'Ajouter un objectif';

  @override
  String get goalsHorizonTacticalShort => 'Tactique';

  @override
  String get goalsHorizonMidShort => 'Moyen terme';

  @override
  String get goalsHorizonLongShort => 'Long terme';

  @override
  String get goalsHorizonTacticalLong => '2–6 semaines';

  @override
  String get goalsHorizonMidLong => '3–6 mois';

  @override
  String get goalsHorizonLongLong => '1+ an';

  @override
  String get goalsEditorNewTitle => 'Nouvel objectif';

  @override
  String get goalsEditorEditTitle => 'Modifier l’objectif';

  @override
  String get goalsEditorLifeBlockLabel => 'Domaine';

  @override
  String get goalsEditorHorizonLabel => 'Horizon';

  @override
  String get goalsEditorTitleLabel => 'Titre';

  @override
  String get goalsEditorTitleHint =>
      'ex. Améliorer l’anglais jusqu’au niveau B2';

  @override
  String get goalsEditorDescLabel => 'Description (optionnel)';

  @override
  String get goalsEditorDescHint =>
      'Bref : quoi exactement, et comment on mesure le succès';

  @override
  String goalsEditorDeadlineLabel(Object date) {
    return 'Échéance : $date';
  }

  @override
  String goalsDeadlineInline(Object date) {
    return 'Échéance : $date';
  }

  @override
  String get goalsEmptyAllHint =>
      'Aucun objectif pour l’instant. Ajoute ton premier objectif pour les domaines sélectionnés.';

  @override
  String get goalsNoBlocksToShow => 'Aucun domaine disponible à afficher.';

  @override
  String get goalsNoGoalsForBlock =>
      'Aucun objectif pour le domaine sélectionné.';

  @override
  String get goalsDeleteConfirmTitle => 'Supprimer l’objectif ?';

  @override
  String goalsDeleteConfirmBody(Object title) {
    return '« $title » sera supprimé et ne pourra pas être restauré.';
  }

  @override
  String get habitsTitle => 'Habitudes';

  @override
  String get habitsEmptyHint =>
      'Aucune habitude pour l’instant. Ajoute la première.';

  @override
  String get habitsEditorNewTitle => 'Nouvelle habitude';

  @override
  String get habitsEditorEditTitle => 'Modifier l’habitude';

  @override
  String get habitsEditorTitleLabel => 'Titre';

  @override
  String get habitsEditorTitleHint => 'ex. Gym du matin';

  @override
  String get habitsNegativeLabel => 'Habitude négative';

  @override
  String get habitsNegativeHint =>
      'Coche-la si tu veux la suivre et la réduire.';

  @override
  String get habitsPositiveHint => 'Une habitude positive/neutre à renforcer.';

  @override
  String get habitsNegativeShort => 'Négative';

  @override
  String get habitsPositiveShort => 'Positive/neutre';

  @override
  String get habitsDeleteConfirmTitle => 'Supprimer l’habitude ?';

  @override
  String habitsDeleteConfirmBody(Object title) {
    return '« $title » sera supprimé et ne pourra pas être restauré.';
  }

  @override
  String get habitsFooterHint =>
      'Plus tard, on ajoutera un “filtre” des habitudes sur l’écran d’accueil.';

  @override
  String get profileTitle => 'Mon profil';

  @override
  String get profileNameLabel => 'Prénom';

  @override
  String get profileNameTitle => 'Prénom';

  @override
  String get profileNamePrompt => 'Comment veux-tu qu’on t’appelle ?';

  @override
  String get profileAgeLabel => 'Âge';

  @override
  String get profileAgeTitle => 'Âge';

  @override
  String get profileAgePrompt => 'Saisis ton âge';

  @override
  String get profileAccountSection => 'Compte';

  @override
  String get profileSeenPrologueTitle => 'Prologue terminé';

  @override
  String get profileSeenPrologueSubtitle => 'Tu peux modifier ça manuellement';

  @override
  String get profileFocusSection => 'Focus';

  @override
  String get profileTargetHoursLabel => 'Heures cibles par jour';

  @override
  String profileTargetHoursValue(Object hours) {
    return '$hours h';
  }

  @override
  String get profileTargetHoursTitle => 'Objectif d’heures par jour';

  @override
  String get profileTargetHoursFieldLabel => 'Heures';

  @override
  String get profileQuestionnaireSection => 'Questionnaire et domaines de vie';

  @override
  String get profileQuestionnaireNotDoneTitle =>
      'Tu n’as pas encore complété le questionnaire.';

  @override
  String get profileQuestionnaireCta => 'Compléter maintenant';

  @override
  String get profileLifeBlocksTitle => 'Domaines de vie';

  @override
  String get profileLifeBlocksHint => 'ex. santé, carrière, famille';

  @override
  String get profilePrioritiesTitle => 'Priorités';

  @override
  String get profilePrioritiesHint => 'ex. sport, finances, lecture';

  @override
  String get profileDangerZoneTitle => 'Zone de danger';

  @override
  String get profileDeleteAccountTitle => 'Supprimer le compte ?';

  @override
  String get profileDeleteAccountBody =>
      'Cette action est irréversible.\nSeront supprimés : objectifs, habitudes, humeur, dépenses/revenus, bocaux, plans IA, XP et ton profil.';

  @override
  String get profileDeleteAccountConfirm => 'Supprimer définitivement';

  @override
  String get profileDeleteAccountCta =>
      'Supprimer le compte et toutes les données';

  @override
  String get profileDeletingAccount => 'Suppression…';

  @override
  String get profileDeleteAccountFootnote =>
      'La suppression est irréversible. Tes données seront définitivement supprimées de Supabase.';

  @override
  String get profileAccountDeletedToast => 'Compte supprimé';

  @override
  String get lifeBlockHealth => 'Santé';

  @override
  String get lifeBlockCareer => 'Carrière';

  @override
  String get lifeBlockFamily => 'Famille';

  @override
  String get lifeBlockFinance => 'Finances';

  @override
  String get lifeBlockLearning => 'Développement';

  @override
  String get lifeBlockSocial => 'Social';

  @override
  String get lifeBlockRest => 'Repos';

  @override
  String get lifeBlockBalance => 'Équilibre';

  @override
  String get lifeBlockLove => 'Amour';

  @override
  String get lifeBlockCreativity => 'Créativité';

  @override
  String get lifeBlockGeneral => 'Général';

  @override
  String get addDayGoalTitle => 'Nouvel objectif du jour';

  @override
  String get addDayGoalFieldTitle => 'Titre *';

  @override
  String get addDayGoalTitleHint => 'ex. Sport / Travail / Étude';

  @override
  String get addDayGoalFieldDescription => 'Description';

  @override
  String get addDayGoalDescriptionHint =>
      'En bref : qu’est-ce qui doit être fait exactement';

  @override
  String get addDayGoalStartTime => 'Heure de début';

  @override
  String get addDayGoalLifeBlock => 'Domaine de vie';

  @override
  String get addDayGoalImportance => 'Importance';

  @override
  String get addDayGoalEmotion => 'Émotion';

  @override
  String get addDayGoalHours => 'Heures';

  @override
  String get addDayGoalEnterTitle => 'Saisis un titre';

  @override
  String get addExpenseNewTitle => 'Nouvelle dépense';

  @override
  String get addExpenseEditTitle => 'Modifier la dépense';

  @override
  String get addExpenseAmountLabel => 'Montant';

  @override
  String get addExpenseAmountInvalid => 'Saisis un montant valide';

  @override
  String get addExpenseCategoryLabel => 'Catégorie';

  @override
  String get addExpenseCategoryRequired => 'Choisis une catégorie';

  @override
  String get addExpenseCreateCategoryTooltip => 'Créer une catégorie';

  @override
  String get addExpenseNoteLabel => 'Note';

  @override
  String get addExpenseNewCategoryTitle => 'Nouvelle catégorie';

  @override
  String get addExpenseCategoryNameLabel => 'Nom';

  @override
  String get addIncomeNewTitle => 'Nouveau revenu';

  @override
  String get addIncomeEditTitle => 'Modifier le revenu';

  @override
  String get addIncomeSubtitle => 'Montant, catégorie et note';

  @override
  String get addIncomeAmountLabel => 'Montant';

  @override
  String get addIncomeAmountHint => 'ex. 1200,50';

  @override
  String get addIncomeAmountInvalid => 'Saisis un montant valide';

  @override
  String get addIncomeCategoryLabel => 'Catégorie';

  @override
  String get addIncomeCategoryRequired => 'Choisis une catégorie';

  @override
  String get addIncomeNoteLabel => 'Note';

  @override
  String get addIncomeNoteHint => 'Optionnel';

  @override
  String get addIncomeNewCategoryTitle => 'Nouvelle catégorie de revenus';

  @override
  String get addIncomeCategoryNameLabel => 'Nom';

  @override
  String get addIncomeCategoryNameHint => 'ex. Salaire, Freelance…';

  @override
  String get addIncomeCategoryNameEmpty => 'Saisis un nom de catégorie';

  @override
  String get addJarNewTitle => 'Nouveau bocal';

  @override
  String get addJarEditTitle => 'Modifier le bocal';

  @override
  String get addJarSubtitle => 'Définis la cible et la part d’argent libre';

  @override
  String get addJarNameLabel => 'Nom';

  @override
  String get addJarNameHint => 'ex. Voyage, Fonds d’urgence, Maison';

  @override
  String get addJarNameRequired => 'Saisis un nom';

  @override
  String get addJarPercentLabel => 'Part de l’argent libre, %';

  @override
  String get addJarPercentHint => '0 si tu alimentes manuellement';

  @override
  String get addJarPercentRange => 'Le pourcentage doit être entre 0 et 100';

  @override
  String get addJarTargetLabel => 'Montant cible';

  @override
  String get addJarTargetHint => 'ex. 5000';

  @override
  String get addJarTargetHelper => 'Obligatoire';

  @override
  String get addJarTargetRequired => 'Saisis une cible (nombre positif)';

  @override
  String get aiInsightTypeDataQuality => 'Qualité des données';

  @override
  String get aiInsightTypeRisk => 'Risque';

  @override
  String get aiInsightTypeEmotional => 'Émotions';

  @override
  String get aiInsightTypeHabit => 'Habitudes';

  @override
  String get aiInsightTypeGoal => 'Objectifs';

  @override
  String get aiInsightTypeDefault => 'Insight';

  @override
  String get aiInsightStrengthStrong => 'Impact fort';

  @override
  String get aiInsightStrengthNoticeable => 'Impact notable';

  @override
  String get aiInsightStrengthWeak => 'Impact faible';

  @override
  String get aiInsightStrengthLowConfidence => 'Faible confiance';

  @override
  String aiInsightStrengthPercent(int value) {
    return '$value%';
  }

  @override
  String get aiInsightEvidenceTitle => 'Preuves';

  @override
  String get aiInsightImpactPositive => 'Positif';

  @override
  String get aiInsightImpactNegative => 'Négatif';

  @override
  String get aiInsightImpactMixed => 'Mixte';

  @override
  String get aiInsightsTitle => 'Insights IA';

  @override
  String get aiInsightsConfirmTitle => 'Lancer l’analyse IA ?';

  @override
  String get aiInsightsConfirmBody =>
      'L’IA analysera tes tâches, habitudes et ton bien-être sur la période sélectionnée et enregistrera des insights. Cela peut prendre quelques secondes.';

  @override
  String get aiInsightsConfirmRun => 'Lancer';

  @override
  String get aiInsightsPeriod7 => '7 jours';

  @override
  String get aiInsightsPeriod30 => '30 jours';

  @override
  String get aiInsightsPeriod90 => '90 jours';

  @override
  String aiInsightsLastRun(String date) {
    return 'Dernier lancement : $date';
  }

  @override
  String get aiInsightsEmptyNotRunTitle => 'L’IA n’a pas encore été lancée';

  @override
  String get aiInsightsEmptyNotRunSubtitle =>
      'Choisis une période et appuie sur « Lancer ». Les insights seront enregistrés et disponibles dans l’app.';

  @override
  String get aiInsightsCtaRun => 'Lancer l’analyse';

  @override
  String get aiInsightsEmptyNoInsightsTitle => 'Aucun insight pour l’instant';

  @override
  String get aiInsightsEmptyNoInsightsSubtitle =>
      'Ajoute plus de données (tâches, habitudes, réponses) et relance l’analyse.';

  @override
  String get aiInsightsCtaRunAgain => 'Relancer';

  @override
  String aiInsightsErrorAi(String error) {
    return 'Erreur IA : $error';
  }

  @override
  String get gcTitleDaySync => 'Google Calendar • synchronisation du jour';

  @override
  String get gcSubtitleImport =>
      'Importe les événements de ce jour comme objectifs.';

  @override
  String get gcSubtitleExport =>
      'Exporte les objectifs de ce jour dans l’agenda.';

  @override
  String get gcModeImport => 'Importer';

  @override
  String get gcModeExport => 'Exporter';

  @override
  String get gcCalendarLabel => 'Agenda';

  @override
  String get gcCalendarPrimary => 'Principal (par défaut)';

  @override
  String get gcDefaultLifeBlockLabel => 'Domaine par défaut (pour l’import)';

  @override
  String get gcLifeBlockForThisGoalLabel => 'Domaine pour cet objectif';

  @override
  String get gcEventsNotLoaded => 'Les événements ne sont pas chargés';

  @override
  String get gcConnectToLoadEvents =>
      'Connecte ton compte pour charger les événements';

  @override
  String get gcExportHint =>
      'L’export créera des événements dans l’agenda sélectionné pour les objectifs de ce jour.';

  @override
  String get gcConnect => 'Connecter';

  @override
  String get gcConnected => 'Connecté';

  @override
  String get gcFindForDay => 'Rechercher pour le jour';

  @override
  String get gcImport => 'Importer';

  @override
  String get gcExport => 'Exporter';

  @override
  String get gcNoTitle => 'Sans titre';

  @override
  String get gcLoadingDots => '...';

  @override
  String gcImportedGoals(int count) {
    return 'Objectifs importés : $count';
  }

  @override
  String gcExportedGoals(int count) {
    return 'Objectifs exportés : $count';
  }

  @override
  String get editGoalTitle => 'Modifier l’objectif';

  @override
  String get editGoalSectionDetails => 'Détails';

  @override
  String get editGoalSectionLifeBlock => 'Domaine de vie';

  @override
  String get editGoalSectionParams => 'Paramètres';

  @override
  String get editGoalFieldTitleLabel => 'Titre';

  @override
  String get editGoalFieldTitleHint => 'Exemple : courir 3 km';

  @override
  String get editGoalFieldDescLabel => 'Description';

  @override
  String get editGoalFieldDescHint => 'Que faut-il faire exactement ?';

  @override
  String get editGoalFieldLifeBlockLabel => 'Domaine de vie';

  @override
  String get editGoalFieldImportanceLabel => 'Importance';

  @override
  String get editGoalImportanceLow => 'Faible';

  @override
  String get editGoalImportanceMedium => 'Moyenne';

  @override
  String get editGoalImportanceHigh => 'Élevée';

  @override
  String get editGoalFieldEmotionLabel => 'Émotion';

  @override
  String get editGoalFieldEmotionHint => '😊';

  @override
  String get editGoalDurationHours => 'Durée (h)';

  @override
  String get editGoalStartTime => 'Début';

  @override
  String get editGoalUntitled => 'Sans titre';

  @override
  String get expenseCategoryOther => 'Autre';

  @override
  String get goalStatusDone => 'Terminé';

  @override
  String get goalStatusInProgress => 'En cours';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String goalImportanceChip(int value) {
    return 'Priorité $value/5';
  }

  @override
  String goalHoursChip(String value) {
    return 'Heures $value';
  }

  @override
  String get goalPathEmpty => 'Aucun objectif sur le parcours';

  @override
  String get timelineActionEdit => 'Modifier';

  @override
  String get timelineActionDelete => 'Supprimer';

  @override
  String get saveBarSaving => 'Enregistrement…';

  @override
  String get saveBarSave => 'Enregistrer';

  @override
  String get reportEmptyChartNotEnoughData => 'Pas assez de données';

  @override
  String limitSheetTitle(String categoryName) {
    return 'Limite pour « $categoryName »';
  }

  @override
  String get limitSheetHintNoLimit => 'Laisser vide — aucune limite';

  @override
  String get limitSheetFieldLabel => 'Limite mensuelle';

  @override
  String get limitSheetFieldHint => 'ex. 15000';

  @override
  String get limitSheetCtaNoLimit => 'Aucune limite';

  @override
  String get profileWebNotificationsSection => 'Notifications (Web)';

  @override
  String get profileWebNotificationsPermissionTitle =>
      'Autoriser les notifications';

  @override
  String get profileWebNotificationsPermissionSubtitle =>
      'Fonctionne sur le Web et uniquement tant que l’onglet est ouvert.';

  @override
  String get profileWebNotificationsEveningTitle => 'Check-in du soir';

  @override
  String profileWebNotificationsEveningSubtitle(Object time) {
    return 'Chaque jour à $time';
  }

  @override
  String get profileWebNotificationsChangeTime => 'Modifier l’heure';

  @override
  String get profileWebNotificationsUnsupported =>
      'Les notifications du navigateur ne sont pas disponibles dans cette version. Elles fonctionnent uniquement dans la version Web (et seulement tant que l’onglet est ouvert).';
}
