// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Ladna';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'Créer un compte';

  @override
  String get home => 'Maison';

  @override
  String get budgetSetupTitle => 'Budget et enveloppes';

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
      'Choisis la langue de l’application. « Système » utilise la langue de ton appareil.';

  @override
  String get budgetExpenseCategoriesTitle => 'Catégories de dépenses';

  @override
  String get budgetExpenseCategoriesSubtitle =>
      'Les limites t’aident à garder tes dépenses sous contrôle';

  @override
  String get budgetJarsTitle => 'Enveloppes d’épargne';

  @override
  String get budgetJarsSubtitle =>
      'Le pourcentage correspond à la part des fonds disponibles ajoutée automatiquement';

  @override
  String get loginOr => 'ou';

  @override
  String get registerLegalPrefix => 'En t’inscrivant, tu acceptes les ';

  @override
  String get registerLegalTerms => 'Conditions d’utilisation';

  @override
  String get registerLegalMiddle => ' et la ';

  @override
  String get registerLegalPrivacy => 'Politique de confidentialité';

  @override
  String get registerLegalSuffix => '.';

  @override
  String get budgetNewIncomeCategory => 'Nouvelle catégorie de revenus';

  @override
  String get budgetNewExpenseCategory => 'Nouvelle catégorie de dépenses';

  @override
  String get budgetCategoryNameHint => 'Nom de la catégorie';

  @override
  String get budgetAddJar => 'Ajouter une enveloppe';

  @override
  String get budgetJarAdded => 'Enveloppe ajoutée';

  @override
  String budgetJarAddFailed(Object error) {
    return 'Impossible d’ajouter : $error';
  }

  @override
  String get budgetJarDeleted => 'Enveloppe supprimée';

  @override
  String budgetJarDeleteFailed(Object error) {
    return 'Impossible de supprimer : $error';
  }

  @override
  String get budgetNoJarsTitle => 'Aucune enveloppe pour le moment';

  @override
  String get budgetNoJarsSubtitle =>
      'Crée ton premier objectif d’épargne — nous t’aiderons à l’atteindre.';

  @override
  String get budgetSetOrChangeLimit => 'Définir/modifier la limite';

  @override
  String get budgetDeleteCategoryTitle => 'Supprimer la catégorie ?';

  @override
  String budgetCategoryLabel(Object name) {
    return 'Catégorie : $name';
  }

  @override
  String get budgetDeleteJarTitle => 'Supprimer l’enveloppe ?';

  @override
  String budgetJarLabel(Object title) {
    return 'Enveloppe : $title';
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
  String get commonChange => 'Modifier';

  @override
  String get commonDate => 'Date';

  @override
  String get commonRefresh => 'Actualiser';

  @override
  String get commonDash => '—';

  @override
  String get commonPick => 'Choisir';

  @override
  String get commonRemove => 'Supprimer';

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
    return 'Impossible de modifier le statut : $error';
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
      'Importer/exporter les objectifs du jour';

  @override
  String get epicIntroSkip => 'Ignorer';

  @override
  String get epicIntroSubtitle =>
      'Un espace pour les pensées. Un lieu où les objectifs,\nles rêves et les plans grandissent — doucement et en conscience.';

  @override
  String get epicIntroPrimaryCta => 'Commencer mon parcours';

  @override
  String get epicIntroLater => 'Plus tard';

  @override
  String get epicIntroSecondaryCta => 'Se connecter';

  @override
  String get epicIntroFooter =>
      'Tu peux toujours revenir au prologue dans les paramètres.';

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
      'Un aperçu rapide — toutes les métriques clés sont ici';

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
  String get homeMoodNoTodayEntry => 'Aucune entrée aujourd’hui';

  @override
  String get homeMoodEntryNoNote => 'Entrée existante (sans note)';

  @override
  String get homeMoodQuickHint =>
      'Ajoute un check-in rapide — cela prend 10 secondes';

  @override
  String get homeMoodUpdateHint =>
      'Tu peux mettre à jour — cela remplacera l’entrée d’aujourd’hui';

  @override
  String get homeMoodNoteLabel => 'Note (facultatif)';

  @override
  String get homeMoodNoteHint => 'Qu’est-ce qui a influencé ton état ?';

  @override
  String get homeOpenMoodHistoryCta => 'Ouvrir l’historique de l’humeur';

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
    return 'Moy./jour : $avg €';
  }

  @override
  String get homeInsightsTitle => 'Insights';

  @override
  String homeTopCategory(Object category, Object amount) {
    return '• Catégorie principale : $category — $amount €';
  }

  @override
  String homePeakExpense(Object day, Object amount) {
    return '• Pic de dépense : $day — $amount €';
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
      'Vérifie ta connexion Internet ou réessaie plus tard.';

  @override
  String get gcalTitle => 'Google Calendar';

  @override
  String get gcalHeaderImport =>
      'Trouve des événements dans ton calendrier et importe-les comme objectifs.';

  @override
  String get gcalHeaderExport =>
      'Choisis une période et exporte les objectifs de l’application vers Google Calendar.';

  @override
  String get gcalModeImport => 'Importer';

  @override
  String get gcalModeExport => 'Exporter';

  @override
  String get gcalCalendarLabel => 'Calendrier';

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
  String get gcalRangeCustom => 'Choisir une période...';

  @override
  String get gcalDefaultLifeBlockLabel =>
      'Domaine de vie par défaut (pour l’import)';

  @override
  String get gcalLifeBlockForGoalLabel => 'Domaine de vie pour cet objectif';

  @override
  String get gcalEventsNotLoaded => 'Les événements ne sont pas chargés';

  @override
  String get gcalConnectToLoadEvents =>
      'Connecte ton compte pour charger les événements';

  @override
  String get gcalExportHint =>
      'L’export créera des événements dans le calendrier sélectionné pour la période choisie.';

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
      'Navigation et actions en un geste';

  @override
  String get launcherSectionsTitle => 'Sections';

  @override
  String get launcherQuickTitle => 'Rapide';

  @override
  String get launcherHome => 'Maison';

  @override
  String get launcherGoals => 'Tâches';

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
  String get launcherMassAddSubtitle => 'Dépenses + objectifs + humeur';

  @override
  String get launcherAiPlanTitle => 'Plan IA pour semaine/mois';

  @override
  String get launcherAiPlanSubtitle =>
      'Analyse des objectifs, du questionnaire et de la progression';

  @override
  String get launcherAiInsightsTitle => 'Insights IA';

  @override
  String get launcherAiInsightsSubtitle =>
      'Comment les événements influencent les objectifs et la progression';

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
      'Exporter les objectifs vers le calendrier';

  @override
  String get launcherNoDatesToCreate =>
      'Aucune date à créer (vérifie l’échéance/les paramètres).';

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
  String get homeTitleHome => 'Maison';

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
  String get homeTitleApp => 'Ladna';

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
  String get expensesCommitTooltip =>
      'Verrouiller la répartition des enveloppes';

  @override
  String get expensesCommitUndoTooltip => 'Annuler';

  @override
  String get expensesBudgetSettings => 'Paramètres du budget';

  @override
  String get expensesCommitDone => 'Répartition verrouillée';

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
    return 'Disponible $value €';
  }

  @override
  String expensesDaySum(Object value) {
    return 'Total du jour : $value €';
  }

  @override
  String get expensesNoTxForDay => 'Aucune opération pour ce jour';

  @override
  String get expensesDeleteTxTitle => 'Supprimer l’opération ?';

  @override
  String expensesDeleteTxBody(Object category, Object amount) {
    return '$category — $amount €';
  }

  @override
  String get expensesCategoriesMonthTitle =>
      'Catégories de dépenses mensuelles';

  @override
  String get expensesNoCategoryData =>
      'Aucune donnée de catégorie pour le moment';

  @override
  String get expensesJarsTitle => 'Enveloppes d’épargne';

  @override
  String get expensesNoJars => 'Aucune enveloppe pour le moment';

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
      'E-mail de réinitialisation envoyé. Vérifie ta boîte de réception.';

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
  String get moodNoteLabel => 'Note (facultatif)';

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
  String get moodEmptyTitle => 'Aucune entrée pour le moment';

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
  String get onbNameLabel => 'Nom';

  @override
  String get onbNameHint => 'Par exemple : Viktor';

  @override
  String get onbAgeLabel => 'Âge';

  @override
  String get onbAgeHint => 'Par exemple : 26';

  @override
  String get onbNameNote =>
      'Tu pourras modifier ton nom plus tard dans ton profil.';

  @override
  String get onbBlocksTitle => 'Quels domaines de vie veux-tu suivre ?';

  @override
  String get onbBlocksSubtitle => 'Ce sera la base de tes objectifs et quêtes';

  @override
  String get onbPrioritiesTitle =>
      'Qu’est-ce qui compte le plus pour toi dans les 3–6 prochains mois ?';

  @override
  String get onbPrioritiesSubtitle =>
      'Choisis jusqu’à trois éléments — cela influence les recommandations';

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
  String get onbPriorityBalance => 'Solde';

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
  String get onbGoalMidHint =>
      'Par exemple : terminer A2→B1 et réussir l’examen';

  @override
  String get onbGoalTacticalLabel => 'Objectif tactique (2–4 semaines)';

  @override
  String get onbGoalTacticalHint =>
      'Par exemple : 12 séances de 30 min + 2 clubs de conversation';

  @override
  String get onbWhyLabel => 'Pourquoi est-ce important ? (facultatif)';

  @override
  String get onbWhyHint =>
      'Motivation/sens — t’aide à rester sur la bonne voie';

  @override
  String get onbOptionalNote =>
      'Tu peux laisser vide et appuyer sur « Suivant ».';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerNameLabel => 'Nom';

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
  String get registerHaveAccountCta => 'Tu as déjà un compte ? Connecte-toi';

  @override
  String get registerErrNameRequired => 'Saisis ton nom';

  @override
  String get registerErrEmailRequired => 'Saisis ton e-mail';

  @override
  String get registerErrEmailInvalid => 'E-mail invalide';

  @override
  String get registerErrPassRequired => 'Saisis un mot de passe';

  @override
  String get registerErrPassMin8 => 'Au moins 8 caractères';

  @override
  String get registerErrPassNeedLower => 'Ajoute une lettre minuscule (a-z)';

  @override
  String get registerErrPassNeedUpper => 'Ajoute une lettre majuscule (A-Z)';

  @override
  String get registerErrPassNeedDigit => 'Ajoute un chiffre (0-9)';

  @override
  String get registerErrConfirmRequired => 'Répète le mot de passe';

  @override
  String get registerErrPasswordsMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get registerErrAcceptTerms =>
      'Tu dois accepter les conditions et la politique de confidentialité';

  @override
  String get registerAppleOnlyIos =>
      'Apple ID est disponible sur iPhone/iPad (iOS uniquement)';

  @override
  String get welcomeAppName => 'VitaPlatform';

  @override
  String get welcomeSubtitle =>
      'Gère tes objectifs, ton humeur et ton temps\n— au même endroit';

  @override
  String get welcomeSignIn => 'Se connecter';

  @override
  String get welcomeCreateAccount => 'Créer un compte';

  @override
  String get habitsWeekTitle => 'Habitudes';

  @override
  String get habitsWeekTopTitle => 'Habitudes (top cette semaine)';

  @override
  String get habitsWeekEmptyHint =>
      'Ajoute au moins une habitude — ta progression apparaîtra ici.';

  @override
  String get habitsWeekFooterHint =>
      'Nous affichons tes habitudes les plus actives des 7 derniers jours.';

  @override
  String get mentalWeekTitle => 'Santé mentale';

  @override
  String mentalWeekLoadError(Object error) {
    return 'Erreur de chargement : $error';
  }

  @override
  String get mentalWeekNoAnswers =>
      'Aucune réponse trouvée cette semaine (pour le user_id actuel).';

  @override
  String get mentalWeekYesNoHeader => 'Oui/Non (semaine)';

  @override
  String get mentalWeekScalesHeader => 'Échelles (tendance)';

  @override
  String get mentalWeekFooterHint =>
      'Nous n’affichons que quelques questions pour garder l’écran lisible.';

  @override
  String get mentalWeekNoData => 'Aucune donnée';

  @override
  String mentalWeekYesCount(Object yes, Object total) {
    return 'Oui : $yes/$total';
  }

  @override
  String get moodWeekTitle => 'Humeur hebdomadaire';

  @override
  String moodWeekMarkedCount(Object filled, Object total) {
    return 'Renseigné : $filled/$total';
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
  String get goalsHorizonLongLong => '1 an et +';

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
  String get goalsEditorTitleHint => 'p. ex. améliorer son anglais jusqu’au B2';

  @override
  String get goalsEditorDescLabel => 'Description (facultative)';

  @override
  String get goalsEditorDescHint =>
      'Brièvement : quoi exactement et comment mesurer la réussite';

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
      'Aucun objectif pour le moment. Ajoute ton premier objectif pour les domaines sélectionnés.';

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
      'Aucune habitude pour le moment. Ajoute la première.';

  @override
  String get habitsEditorNewTitle => 'Nouvelle habitude';

  @override
  String get habitsEditorEditTitle => 'Modifier l’habitude';

  @override
  String get habitsEditorTitleLabel => 'Titre';

  @override
  String get habitsEditorTitleHint => 'p. ex. entraînement du matin';

  @override
  String get habitsNegativeLabel => 'Habitude négative';

  @override
  String get habitsNegativeHint => 'Coche si tu veux la suivre et la réduire.';

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
      'Plus tard, nous ajouterons le filtrage des habitudes sur l’écran d’accueil.';

  @override
  String get profileTitle => 'Mon profil';

  @override
  String get profileNameLabel => 'Nom';

  @override
  String get profileNameTitle => 'Nom';

  @override
  String get profileNamePrompt => 'Comment devons-nous t’appeler ?';

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
  String get profileSeenPrologueSubtitle => 'Tu peux le modifier manuellement';

  @override
  String get profileFocusSection => 'Focus';

  @override
  String get profileTargetHoursLabel => 'Heures cibles par jour';

  @override
  String profileTargetHoursValue(Object hours) {
    return '$hours h';
  }

  @override
  String get profileTargetHoursTitle => 'Objectif d’heures quotidien';

  @override
  String get profileTargetHoursFieldLabel => 'Heures';

  @override
  String get profileQuestionnaireSection => 'Questionnaire et domaines de vie';

  @override
  String get profileQuestionnaireNotDoneTitle =>
      'Tu n’as pas encore terminé le questionnaire.';

  @override
  String get profileQuestionnaireCta => 'Terminer maintenant';

  @override
  String get profileLifeBlocksTitle => 'Domaines de vie';

  @override
  String get profileLifeBlocksHint => 'p. ex. santé, carrière, famille';

  @override
  String get profilePrioritiesTitle => 'Priorités';

  @override
  String get profilePrioritiesHint => 'p. ex. sport, finances, lecture';

  @override
  String get profileDangerZoneTitle => 'Zone dangereuse';

  @override
  String get profileDeleteAccountTitle => 'Supprimer le compte ?';

  @override
  String get profileDeleteAccountBody =>
      'Cette action est irréversible.\nLes éléments suivants seront supprimés : objectifs, habitudes, humeur, dépenses/revenus, enveloppes, plans IA, XP et ton profil.';

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
  String get lifeBlockBalance => 'Solde';

  @override
  String get lifeBlockLove => 'Amour';

  @override
  String get lifeBlockCreativity => 'Créativité';

  @override
  String get lifeBlockGeneral => 'Général';

  @override
  String get addDayGoalTitle => 'Nouvel objectif quotidien';

  @override
  String get addDayGoalFieldTitle => 'Titre *';

  @override
  String get addDayGoalTitleHint => 'p. ex. : entraînement / travail / études';

  @override
  String get addDayGoalFieldDescription => 'Description';

  @override
  String get addDayGoalDescriptionHint =>
      'En bref : ce qui doit être fait exactement';

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
  String get addExpenseCategoryRequired => 'Sélectionne une catégorie';

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
  String get addIncomeAmountHint => 'p. ex. 1200,50';

  @override
  String get addIncomeAmountInvalid => 'Saisis un montant valide';

  @override
  String get addIncomeCategoryLabel => 'Catégorie';

  @override
  String get addIncomeCategoryRequired => 'Sélectionne une catégorie';

  @override
  String get addIncomeNoteLabel => 'Note';

  @override
  String get addIncomeNoteHint => 'Facultatif';

  @override
  String get addIncomeNewCategoryTitle => 'Nouvelle catégorie de revenus';

  @override
  String get addIncomeCategoryNameLabel => 'Nom de la catégorie';

  @override
  String get addIncomeCategoryNameHint => 'p. ex. Salaire, freelance…';

  @override
  String get addIncomeCategoryNameEmpty => 'Saisis un nom de catégorie';

  @override
  String get addJarNewTitle => 'Nouvelle enveloppe';

  @override
  String get addJarEditTitle => 'Modifier l’enveloppe';

  @override
  String get addJarSubtitle =>
      'Définis l’objectif et la part de l’argent disponible';

  @override
  String get addJarNameLabel => 'Nom';

  @override
  String get addJarNameHint => 'p. ex. Voyage, fonds d’urgence, maison';

  @override
  String get addJarNameRequired => 'Saisis un nom';

  @override
  String get addJarPercentLabel => 'Part de l’argent disponible, %';

  @override
  String get addJarPercentHint => '0 si tu ajoutes manuellement';

  @override
  String get addJarPercentRange => 'Le pourcentage doit être entre 0 et 100';

  @override
  String get addJarTargetLabel => 'Montant cible';

  @override
  String get addJarTargetHint => 'p. ex. 5000';

  @override
  String get addJarTargetHelper => 'Obligatoire';

  @override
  String get addJarTargetRequired => 'Saisis un objectif (nombre positif)';

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
  String get aiInsightImpactNegative => 'Négative';

  @override
  String get aiInsightImpactMixed => 'Mixte';

  @override
  String get aiInsightsTitle => 'Insights IA';

  @override
  String get aiInsightsConfirmTitle => 'Lancer l’analyse IA ?';

  @override
  String get aiInsightsConfirmBody =>
      'L’IA analysera tes tâches, habitudes et bien-être pour la période sélectionnée et enregistrera les insights. Cela peut prendre quelques secondes.';

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
      'Choisis une période et appuie sur « Lancer ». Les insights seront enregistrés et disponibles dans l’application.';

  @override
  String get aiInsightsCtaRun => 'Lancer l’analyse';

  @override
  String get aiInsightsEmptyNoInsightsTitle => 'Aucun insight pour le moment';

  @override
  String get aiInsightsEmptyNoInsightsSubtitle =>
      'Ajoute plus de données (tâches, habitudes, réponses aux questions) et relance l’analyse.';

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
      'Importer les événements de ce jour comme objectifs.';

  @override
  String get gcSubtitleExport =>
      'Exporter les objectifs de ce jour vers le calendrier.';

  @override
  String get gcModeImport => 'Importer';

  @override
  String get gcModeExport => 'Exporter';

  @override
  String get gcCalendarLabel => 'Calendrier';

  @override
  String get gcCalendarPrimary => 'Principal (par défaut)';

  @override
  String get gcDefaultLifeBlockLabel =>
      'Domaine de vie par défaut (pour l’import)';

  @override
  String get gcLifeBlockForThisGoalLabel => 'Domaine de vie pour cet objectif';

  @override
  String get gcEventsNotLoaded => 'Les événements ne sont pas chargés';

  @override
  String get gcConnectToLoadEvents =>
      'Connecte ton compte pour charger les événements';

  @override
  String get gcExportHint =>
      'L’export créera des événements dans le calendrier sélectionné pour les objectifs de ce jour.';

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
  String get editGoalFieldTitleHint => 'Exemple : course de 3 km';

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
  String get editGoalStartTime => 'Commencer';

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
  String get limitSheetFieldHint => 'p. ex. 15000';

  @override
  String get limitSheetCtaNoLimit => 'Aucune limite';

  @override
  String get profileWebNotificationsSection => 'Notifications (Web)';

  @override
  String get profileWebNotificationsPermissionTitle =>
      'Autoriser les notifications';

  @override
  String get profileWebNotificationsPermissionSubtitle =>
      'Fonctionne sur le Web et uniquement lorsque l’onglet est ouvert.';

  @override
  String get profileWebNotificationsEveningTitle => 'Check-in du soir';

  @override
  String profileWebNotificationsEveningSubtitle(Object time) {
    return 'Tous les jours à $time';
  }

  @override
  String get profileWebNotificationsChangeTime => 'Changer l’heure';

  @override
  String get profileWebNotificationsUnsupported =>
      'Les notifications du navigateur ne sont pas disponibles dans cette version. Elles fonctionnent uniquement dans la version Web (et seulement lorsque l’onglet est ouvert).';

  @override
  String get lifeBlockEducation => 'Éducation';

  @override
  String get lifeBlockHobbies => 'Loisirs';

  @override
  String get userGoalsTitle => 'Mes objectifs';

  @override
  String get userGoalsSubtitle =>
      'Objectifs stratégiques par domaine de vie : court, moyen et long terme.';

  @override
  String get userGoalsNewTitle => 'Nouvel objectif';

  @override
  String get userGoalsEditTitle => 'Modifier l’objectif';

  @override
  String get userGoalsCreateGoal => 'Créer un objectif';

  @override
  String get userGoalsCreated => 'Objectif créé';

  @override
  String userGoalsCreateError(Object error) {
    return 'Impossible de créer l’objectif : $error';
  }

  @override
  String get userGoalsUpdated => 'Objectif mis à jour';

  @override
  String userGoalsUpdateError(Object error) {
    return 'Impossible de mettre à jour l’objectif : $error';
  }

  @override
  String userGoalsStatusChangeError(Object error) {
    return 'Impossible de modifier le statut : $error';
  }

  @override
  String userGoalsDeleteError(Object error) {
    return 'Impossible de supprimer l’objectif : $error';
  }

  @override
  String get userGoalsDeleteConfirmTitle => 'Supprimer l’objectif ?';

  @override
  String get userGoalsAllBlocks => 'Tous';

  @override
  String get userGoalsAllHorizons => 'Tous les horizons';

  @override
  String get userGoalsLoadErrorTitle => 'Erreur de chargement';

  @override
  String get userGoalsNoActiveBlocksTitle => 'Aucun domaine de vie actif';

  @override
  String get userGoalsNoActiveBlocksSubtitle =>
      'Choisis d’abord les domaines de vie suivis par l’utilisateur.';

  @override
  String get userGoalsEmptyTitle => 'Aucun objectif pour le moment';

  @override
  String get userGoalsEmptySubtitle =>
      'Crée ton premier objectif stratégique pour l’un de tes domaines de vie.';

  @override
  String userGoalsDeadline(Object date) {
    return 'Échéance : $date';
  }

  @override
  String get userGoalsStatusCompleted => 'Terminé';

  @override
  String get userGoalsStatusActive => 'Actif';

  @override
  String get userGoalsReopen => 'Rouvrir';

  @override
  String get userGoalsComplete => 'Terminer';

  @override
  String get userGoalsFieldLifeBlock => 'Domaine de vie';

  @override
  String get userGoalsFieldHorizon => 'Horizon';

  @override
  String get userGoalsFieldTitle => 'Titre de l’objectif';

  @override
  String get userGoalsFieldDescription => 'Description';

  @override
  String get userGoalsPickTargetDate => 'Choisir la date cible';

  @override
  String get userGoalsClearDate => 'Effacer la date';

  @override
  String get monthJanuary => 'Janvier';

  @override
  String get monthFebruary => 'Février';

  @override
  String get monthMarch => 'Mars';

  @override
  String get monthApril => 'Avril';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJune => 'Juin';

  @override
  String get monthJuly => 'Juillet';

  @override
  String get monthAugust => 'Août';

  @override
  String get monthSeptember => 'Septembre';

  @override
  String get monthOctober => 'Octobre';

  @override
  String get monthNovember => 'Novembre';

  @override
  String get monthDecember => 'Décembre';

  @override
  String get weekdayMonShort => 'Lun';

  @override
  String get weekdayTueShort => 'Mar';

  @override
  String get weekdayWedShort => 'Mer';

  @override
  String get weekdayThuShort => 'Jeu';

  @override
  String get weekdayFriShort => 'Ven';

  @override
  String get weekdaySatShort => 'Sam';

  @override
  String get weekdaySunShort => 'Dim';

  @override
  String get lifeBlockRelations => 'Relations';

  @override
  String get lifeBlockSpirituality => 'Spiritualité';

  @override
  String goalsHeaderWeek(Object month, Object year, Object week) {
    return '$month $year, semaine $week';
  }

  @override
  String get goalsQuickActionsTitle => 'Actions rapides';

  @override
  String get goalsQuickActionsSubtitle => 'Ajouter et planifier en un geste';

  @override
  String get goalsMassAddTitle => 'Saisie quotidienne groupée';

  @override
  String get goalsMassAddSubtitle =>
      'Dépenses + revenus + tâches + humeur + habitudes';

  @override
  String goalsMassAddSaved(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodSuffix,
  ) {
    return 'Enregistré : $expenses dépense(s), $incomes revenu(s), $goals tâche(s), $habits habitude(s)$moodSuffix';
  }

  @override
  String get goalsMassAddMoodSuffix => ', humeur';

  @override
  String goalsSaveError(Object error) {
    return 'Erreur d’enregistrement : $error';
  }

  @override
  String get goalsRecurringGoalTitle => 'Objectif récurrent';

  @override
  String get goalsRecurringGoalSubtitle =>
      'Planifier plusieurs jours à l’avance';

  @override
  String get goalsRecurringNoDates =>
      'Aucune date à créer. Vérifie l’échéance ou les paramètres.';

  @override
  String goalsPlanHoursDescription(Object hours) {
    return 'Plan : $hours h';
  }

  @override
  String goalsCreatedCount(Object count) {
    return 'Objectifs créés : $count';
  }

  @override
  String goalsRecurringCreateError(Object error) {
    return 'Impossible de créer la série d’objectifs : $error';
  }

  @override
  String get goalsSimpleTaskTitle => 'Tâche rapide';

  @override
  String get goalsSimpleTaskSubtitle =>
      'Titre uniquement, heure facultative, catégorie Général';

  @override
  String get goalsSimpleTaskSheetSubtitle =>
      'Titre uniquement, heure facultative. La catégorie par défaut est Général.';

  @override
  String get goalsTaskCreated => 'Tâche créée';

  @override
  String goalsTaskCreateError(Object error) {
    return 'Erreur de création de tâche : $error';
  }

  @override
  String get goalsAll => 'Tous';

  @override
  String get goalsViewDashboard => 'Tableau de bord';

  @override
  String get goalsViewCalendar => 'Calendrier';

  @override
  String get goalsViewWeek => 'Semaine';

  @override
  String get goalsViewMonth => 'Mois';

  @override
  String get goalsByBlocksTitle => 'Objectifs par domaine de vie';

  @override
  String get goalsShow => 'Afficher';

  @override
  String get goalsByBlocksHiddenHint => 'Masqué. Appuie sur 👁 pour afficher.';

  @override
  String get goalsEnterTaskTitle => 'Saisis un titre de tâche';

  @override
  String get goalsTaskTitleLabel => 'Titre de la tâche';

  @override
  String get goalsAddTime => 'Ajouter une heure';

  @override
  String goalsTimeValue(Object time) {
    return 'Heure : $time';
  }

  @override
  String get goalsRemoveTime => 'Supprimer l’heure';

  @override
  String get goalsCreateTask => 'Créer une tâche';

  @override
  String get goalsWeekSummaryTitle => 'Résumé de la semaine';

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
    return '$hours h';
  }

  @override
  String goalsHoursTargetSuffixNoSpace(Object hours) {
    return ' / ${hours}h';
  }

  @override
  String get dayGoalsHiddenCompletedEmpty =>
      'Tous les objectifs visibles sont masqués. Désactive le filtre « Masquer terminés ».';

  @override
  String get dayGoalsKanbanOpenShort => 'Ouvert';

  @override
  String get dayGoalsKanbanDoneShort => 'Terminé';

  @override
  String get dayGoalsKanbanOpenTitle => 'En cours';

  @override
  String get dayGoalsKanbanDoneTitle => 'Terminé';

  @override
  String get dayGoalsKanbanOpenEmpty => 'Aucune tâche active';

  @override
  String get dayGoalsKanbanDoneEmpty => 'Rien ici pour le moment';

  @override
  String dayGoalsHoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String get dayGoalsSectionMorning => 'Matin';

  @override
  String get dayGoalsSectionDay => 'Jour';

  @override
  String get dayGoalsSectionEvening => 'Soir';

  @override
  String get dayGoalsSummaryTitle => 'Résumé du jour';

  @override
  String get dayGoalsSummarySubtitle =>
      'Reste concentré sur l’essentiel et garde une journée maîtrisable.';

  @override
  String get dayGoalsSummaryTotal => 'Total';

  @override
  String get dayGoalsSummaryDone => 'Terminé';

  @override
  String get dayGoalsSummaryRemaining => 'Restant';

  @override
  String dayGoalsRemainingHours(Object hours) {
    return 'Heures restantes : $hours';
  }

  @override
  String get dayGoalsHideCompleted => 'Masquer terminés';

  @override
  String get reportsTabSummary => 'Résumé';

  @override
  String get reportsTabRelations => 'Relations';

  @override
  String get reportsTabProductivity => 'Productivité';

  @override
  String get reportsTabExpenses => 'Dépenses';

  @override
  String get reportsCompletedTasks => 'Tâches terminées';

  @override
  String get reportsSpentHours => 'Heures passées';

  @override
  String get reportsEfficiency => 'Efficacité';

  @override
  String get reportsPeriodEfficiency => 'Efficacité de la période';

  @override
  String reportsPlanFactHours(Object planned, Object actual) {
    return 'Plan : $planned h • Réel : $actual h';
  }

  @override
  String get reportsAdditionalMetrics => 'Métriques supplémentaires';

  @override
  String get reportsCorrelations => 'Relations entre les métriques';

  @override
  String get reportsCorrelationsHint =>
      'Ce n’est pas une corrélation scientifique, mais des comparaisons claires par période.';

  @override
  String get reportsMoodProductivity => 'Humeur → productivité';

  @override
  String get reportsGoodMood => 'Bonne';

  @override
  String get reportsBadMood => 'Mauvaise';

  @override
  String get reportsHabitsMoodProductivity =>
      'Habitudes → humeur / productivité';

  @override
  String get reportsMoodMostlyHappy => 'plutôt 😊';

  @override
  String get reportsMoodMostlySad => 'plutôt 😞';

  @override
  String get reportsMoodMostlyNeutral => 'plutôt 😐';

  @override
  String reportsHabitsComparisonHint(int percent) {
    return 'Comparaison des jours avec ≥ $percent% d’habitudes réalisées et de tous les autres jours.';
  }

  @override
  String get reportsMoodHigh => 'Humeur (élevée)';

  @override
  String get reportsMoodLow => 'Humeur (faible)';

  @override
  String get reportsHoursHigh => 'Heures (élevées)';

  @override
  String get reportsHoursLow => 'Heures (faibles)';

  @override
  String get reportsHabitsHighShort => 'habitudes élevées';

  @override
  String get reportsHabitsLowShort => 'habitudes faibles';

  @override
  String get reportsMentalMood => 'État mental → humeur';

  @override
  String get reportsExpensesMood => 'Dépenses → humeur';

  @override
  String get reportsHappyDays => 'jours 😊';

  @override
  String get reportsSadDays => 'jours 😞';

  @override
  String get reportsCompletedByBlocks => 'Terminées par bloc';

  @override
  String get reportsNoCompletedTasks => 'Aucune tâche terminée';

  @override
  String reportsTasksCount(int count) {
    return '$count tâches';
  }

  @override
  String get reportsHoursByDays => 'Heures passées par jour';

  @override
  String get reportsExpensesForPeriod => 'Dépenses de la période';

  @override
  String reportsTotalEuro(Object amount) {
    return 'Total : $amount €';
  }

  @override
  String reportsAvgExpensePerDay(Object amount) {
    return 'Dépense moyenne/jour : $amount €';
  }

  @override
  String get reportsNoExpensesByCategory => 'Aucune dépense par catégorie';

  @override
  String get reportsAvgTimePerGoal => 'Temps moyen par tâche';

  @override
  String get reportsOnTimeConditional => '« À l’heure » (approx.)';

  @override
  String get reportsTop3ProductiveDays => 'TOP 3 des jours productifs';

  @override
  String reportsTopDayLine(int day, int month, int year, Object hours) {
    return '• $day.$month.$year : $hours h';
  }

  @override
  String get reportsPeriodDay => 'Jour';

  @override
  String get reportsPeriodWeekShort => 'Semaine';

  @override
  String get reportsPeriodMonthShort => 'Mois';

  @override
  String get reportsForward => 'Suivant';

  @override
  String get reportsTapChartSector => 'Appuie sur un segment du graphique';

  @override
  String get reportsLatestAiInsights => 'Derniers insights IA';

  @override
  String get reportsOpenAll => 'Tout ouvrir';

  @override
  String get reportsInsightsLoadFailed => 'Impossible de charger les insights';

  @override
  String get reportsNoSavedInsights =>
      'Aucun insight enregistré pour le moment.';

  @override
  String get reportsRunAiInsightsHint =>
      'Ouvre « Insights IA » et lance une analyse — ils apparaîtront ici.';

  @override
  String get reportsAiPeriod7Days => '7 derniers jours';

  @override
  String get reportsAiPeriod30Days => '30 derniers jours';

  @override
  String get reportsAiPeriod90Days => '90 derniers jours';

  @override
  String reportsHoursValue(Object hours) {
    return '$hours h';
  }

  @override
  String reportsEuroValue(Object amount) {
    return '$amount €';
  }

  @override
  String get commonError => 'Erreur';

  @override
  String get aiPlanConsentSaved => 'Consentement au traitement IA enregistré';

  @override
  String aiPlanConsentCheckFailed(Object error) {
    return 'Impossible de vérifier ou d’enregistrer le consentement au traitement IA. Vérifie que la table users contient les champs ai_processing_consent, ai_processing_consent_at et ai_processing_consent_version. Détails : $error';
  }

  @override
  String get aiPlanConsentTitle => 'Consentement au traitement IA';

  @override
  String get aiPlanConsentBody =>
      'Pour générer un plan IA, Ladna analysera tes objectifs, tâches, habitudes, ton humeur et d’autres données de l’application. Ces données sont utilisées uniquement pour créer des recommandations, des plans et des insights personnalisés.';

  @override
  String get aiPlanConsentDeclineBody =>
      'Tu peux refuser le consentement — dans ce cas, la fonction IA ne sera pas lancée.';

  @override
  String get aiPlanConsentNotNow => 'Pas maintenant';

  @override
  String get aiPlanConsentAgree => 'J’accepte';

  @override
  String aiPlanOpenLinkFailed(Object url) {
    return 'Impossible d’ouvrir le lien : $url';
  }

  @override
  String get aiPlanUpdated => 'Plan IA mis à jour';

  @override
  String get aiPlanEmptyEdgeFunction =>
      'Le plan est vide. Vérifie l’Edge Function ai-plan.';

  @override
  String aiPlanHoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String aiPlanImportanceMeta(int importance) {
    return 'importance $importance/5';
  }

  @override
  String get aiPlanLinkedToGoal => 'lié à un objectif';

  @override
  String get aiPlanNothingToApply =>
      'Rien à appliquer — sélectionne des éléments';

  @override
  String get aiPlanDefaultTaskTitle => 'Tâche IA';

  @override
  String aiPlanTasksAdded(int count) {
    return 'Tâches ajoutées : $count';
  }

  @override
  String get aiPlanApplyTypeError =>
      'Erreur de type de données lors de l’ajout des tâches : l’un des champs est arrivé sous forme true/false au lieu d’un nombre. Mets à nouveau le fichier à jour : dans cette version, les valeurs booléennes sont également converties en nombres et le champ is_completed n’est plus envoyé manuellement.';

  @override
  String get aiPlanTitleWeek => 'Plan IA pour la semaine';

  @override
  String get aiPlanTitleMonth => 'Plan IA pour le mois';

  @override
  String get aiPlanRegenerateTooltip => 'Générer à nouveau';

  @override
  String aiPlanUpdatedAt(Object date) {
    return 'Mis à jour : $date';
  }

  @override
  String get aiPlanCheckingConsent =>
      'Vérification du consentement au traitement IA...';

  @override
  String get aiPlanApplyingTasks => 'Ajout des tâches...';

  @override
  String get aiPlanGenerating => 'Génération du plan IA...';

  @override
  String aiPlanApplyCount(int count) {
    return 'Appliquer ($count)';
  }

  @override
  String get aiPlanRejectTooltip => 'Refuser';

  @override
  String get aiPlanAcceptTooltip => 'Accepter';

  @override
  String get aiPlanFieldBlock => 'Bloc';

  @override
  String get aiPlanFieldImportance => 'Importance';

  @override
  String get aiPlanFieldHours => 'Heures';

  @override
  String get aiPlanFieldRepeat => 'Répéter';

  @override
  String get aiPlanConsentRequiredTitle =>
      'Le consentement au traitement IA est requis';

  @override
  String get aiPlanConsentRequiredBody =>
      'Avant de générer un plan IA, tu dois confirmer que Ladna peut analyser les données de l’application pour des recommandations personnalisées.';

  @override
  String get aiPlanGiveConsent => 'Donner le consentement';

  @override
  String get aiPlanPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get aiPlanDatenschutz => 'Politique de protection des données';

  @override
  String get aiPlanTermsOfUse => 'Conditions d’utilisation';

  @override
  String get aiPlanEmptyTitle => 'Le plan est vide';

  @override
  String get aiPlanEmptyBody =>
      'Appuie sur le bouton ci-dessous pour générer un plan basé sur les insights IA, les objectifs, les tâches, les habitudes et l’humeur.';

  @override
  String get aiPlanGeneratePlan => 'Générer le plan';

  @override
  String get aiPlanRepeatNone => 'Pas de répétition';

  @override
  String get aiPlanRepeatDaily => 'Tous les jours';

  @override
  String get aiPlanRepeatWeekdays => 'Jours de semaine';

  @override
  String get aiPlanRepeatWeekly => 'Une fois par semaine';

  @override
  String get aiPlanLifeBlockOther => 'Autre';

  @override
  String get aiInsightsConsentTitle => 'Consentement au traitement IA';

  @override
  String get aiInsightsConsentBody =>
      'Pour générer des insights IA, Ladna analysera tes objectifs, tâches, habitudes, ton humeur et d’autres données de l’application. Ces données sont utilisées uniquement pour créer des recommandations, des plans et des insights personnalisés.';

  @override
  String get aiInsightsConsentDeclineBody =>
      'Tu peux refuser le consentement — dans ce cas, la fonction IA ne sera pas lancée.';

  @override
  String get aiInsightsConsentNotNow => 'Pas maintenant';

  @override
  String get aiInsightsConsentAgree => 'J’accepte';

  @override
  String get aiInsightsConsentSaved =>
      'Consentement au traitement IA enregistré';

  @override
  String aiInsightsConsentCheckFailed(Object error) {
    return 'Impossible de vérifier ou d’enregistrer le consentement au traitement IA. Vérifie que la table users contient les champs ai_processing_consent, ai_processing_consent_at et ai_processing_consent_version. Détails : $error';
  }

  @override
  String get aiInsightsCheckingConsent =>
      'Vérification du consentement au traitement IA...';

  @override
  String get aiInsightsUserNotAuthorized =>
      'L’utilisateur n’est pas authentifié';

  @override
  String aiInsightsOpenLinkFailed(Object url) {
    return 'Impossible d’ouvrir le lien : $url';
  }

  @override
  String get aiInsightsDefaultTitle => 'Insight IA';

  @override
  String get aiInsightsConsentRequiredTitle =>
      'Le consentement au traitement IA est requis';

  @override
  String get aiInsightsConsentRequiredBody =>
      'Avant de générer des insights IA, tu dois confirmer que Ladna peut analyser les données de l’application pour des recommandations personnalisées.';

  @override
  String get aiInsightsGiveConsent => 'Donner le consentement';

  @override
  String get aiInsightsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get aiInsightsDatenschutz => 'Politique de protection des données';

  @override
  String get aiInsightsTermsOfUse => 'Conditions d’utilisation';

  @override
  String get massDailyTitle => 'Saisie quotidienne groupée';

  @override
  String get massDailyDatePrefix => 'Date : ';

  @override
  String get massDailyChoose => 'Choisir';

  @override
  String get massDailyBack => 'Retour';

  @override
  String get massDailyCancel => 'Annuler';

  @override
  String get massDailyNext => 'Suivant';

  @override
  String get massDailySaveAll => 'Tout enregistrer';

  @override
  String get massDailyEmptyRowsIgnored => 'Les lignes vides sont ignorées.';

  @override
  String get massDailyMoodTitle => 'Humeur';

  @override
  String get massDailyMoodSubtitle =>
      'Note facultative sur le déroulement de la journée.';

  @override
  String get massDailyNote => 'Note';

  @override
  String get massDailyHabitsTitle => 'Habitudes';

  @override
  String get massDailyHabitsSubtitle =>
      'Marque l’exécution et ajoute une quantité si nécessaire.';

  @override
  String get massDailyRefresh => 'Actualiser';

  @override
  String get massDailyNoHabits =>
      'Aucune habitude pour le moment. Ajoute-les dans ton profil.';

  @override
  String massDailyHabitsLoadFailed(Object error) {
    return 'Impossible de charger les habitudes : $error';
  }

  @override
  String get massDailyMentalTitle => 'Santé mentale';

  @override
  String get massDailyMentalSubtitle =>
      'Un court point quotidien sur ton état pour l’analyse ultérieure.';

  @override
  String get massDailyMentalIntro =>
      'Réponds à quelques questions — cela aide à suivre ton état.';

  @override
  String get massDailyNoMentalQuestions =>
      'Aucune question pour le moment. Ajoute-les à la table mental_questions.';

  @override
  String massDailyMentalLoadFailed(Object error) {
    return 'Impossible de charger les questions : $error';
  }

  @override
  String get massDailyExpensesTitle => 'Dépenses';

  @override
  String get massDailyExpensesSubtitle =>
      'Ajoute les dépenses du jour sélectionné.';

  @override
  String get massDailyIncomesTitle => 'Revenus';

  @override
  String get massDailyIncomesSubtitle =>
      'Ajoute les revenus du jour sélectionné.';

  @override
  String get massDailyGoalsTitle => 'Tâches';

  @override
  String get massDailyGoalsSubtitle =>
      'Note ce sur quoi tu as travaillé ce jour-là et le temps que cela a pris.';

  @override
  String get massDailyAddRow => 'Ajouter une ligne';

  @override
  String get massDailyNoMood => 'Aucune humeur';

  @override
  String get massDailyQuantityExample => 'Quantité (par exemple, cigarettes)';

  @override
  String get massDailyQuantityOptional => 'Quantité (facultatif)';

  @override
  String get massDailyQuantityShort => 'Qté';

  @override
  String get massDailyHabitNegative => 'Négative';

  @override
  String get massDailyHabitPositive => 'Positif';

  @override
  String get massDailyAnswer => 'Réponse';

  @override
  String get massDailyAmount => 'Montant';

  @override
  String get massDailyCategory => 'Catégorie';

  @override
  String get massDailyNoCategories => 'Aucune catégorie';

  @override
  String get massDailyTaskTitle => 'Titre de la tâche';

  @override
  String get massDailyHours => 'Heures';

  @override
  String get massDailyTime => 'Heure';

  @override
  String get massDailyEmotion => 'Émotion';

  @override
  String get massDailyNoEmotion => 'Aucune émotion';

  @override
  String get massDailyImportance => 'Importance';

  @override
  String get massDailyBigGoal => 'Grand objectif';

  @override
  String get massDailyNoLink => 'Non lié';

  @override
  String get massDailyLoadingUserGoals => 'Chargement des grands objectifs...';

  @override
  String get massDailyNoUserGoalsForCategory =>
      'Il n’y a pas encore de grands objectifs pour cette catégorie.';

  @override
  String get massDailyHorizonTactical => 'Tactique';

  @override
  String get massDailyHorizonMid => 'Moyen terme';

  @override
  String get massDailyHorizonLong => 'Long terme';

  @override
  String get massDailyLifeBlockGeneral => 'Général';

  @override
  String get massDailyLifeBlockHealth => 'Santé';

  @override
  String get massDailyLifeBlockCareer => 'Carrière';

  @override
  String get massDailyLifeBlockFamily => 'Famille';

  @override
  String get massDailyLifeBlockFinance => 'Finances';

  @override
  String get massDailyLifeBlockEducation => 'Éducation';

  @override
  String get massDailyLifeBlockHobbies => 'Loisirs';

  @override
  String get importJournalTextNotRecognized =>
      'Le texte n’a pas été reconnu. Essaie une autre photo.';

  @override
  String get importJournalRecognizedTextTitle => 'Texte reconnu';

  @override
  String get importJournalContinue => 'Continuer';

  @override
  String get importJournalUntitled => 'Sans titre';

  @override
  String get importJournalNoTasksFound =>
      'Impossible d’extraire des tâches du texte.';

  @override
  String importJournalAddedGoals(Object count) {
    return 'Objectifs ajoutés : $count';
  }

  @override
  String importJournalImportFailed(Object error) {
    return 'Impossible d’importer : $error';
  }

  @override
  String get importJournalVisionApiKeyMissing =>
      'VISION_API_KEY n’est pas défini. Lance l’application avec --dart-define=VISION_API_KEY=...';

  @override
  String importJournalVisionApiError(Object statusCode, Object body) {
    return 'Vision API a renvoyé l’erreur $statusCode : $body';
  }

  @override
  String get importJournalEditTitle => 'Modifier';

  @override
  String get importJournalNameLabel => 'Nom';

  @override
  String get importJournalTimeColon => 'Heure :';

  @override
  String get importJournalHoursColon => 'Heures :';

  @override
  String get importJournalFoundTasksTitle => 'Tâches trouvées';

  @override
  String importJournalTaskSubtitle(Object time, Object hours) {
    return '$time • $hours h';
  }

  @override
  String get importJournalAddSelected => 'Ajouter la sélection';

  @override
  String get recurringGoalSelectAtLeastOneWeekday =>
      'Sélectionne au moins un jour de la semaine';

  @override
  String get recurringGoalTitle => 'Objectif récurrent';

  @override
  String get recurringGoalSubtitle =>
      'Crée des tâches d’aujourd’hui jusqu’à la date sélectionnée.';

  @override
  String get recurringGoalDetailsSection => 'Détails';

  @override
  String get recurringGoalTitleLabel => 'Titre de l’objectif';

  @override
  String get recurringGoalTitleHint => 'Par exemple : entraînement';

  @override
  String get recurringGoalEmotionLabel => 'Émotion';

  @override
  String get recurringGoalEmotionHint => 'Par exemple : 💪 motivation';

  @override
  String get recurringGoalRegularitySection => 'Récurrence';

  @override
  String get recurringGoalEveryNDays => 'Tous les N jours';

  @override
  String get recurringGoalByWeekdays => 'Par jours de semaine';

  @override
  String get recurringGoalIntervalLabel => 'Intervalle';

  @override
  String recurringGoalEveryNDaysShort(Object count) {
    return '$count j';
  }

  @override
  String get recurringGoalWeekdayMon => 'Lun';

  @override
  String get recurringGoalWeekdayTue => 'Mar';

  @override
  String get recurringGoalWeekdayWed => 'Mer';

  @override
  String get recurringGoalWeekdayThu => 'Jeu';

  @override
  String get recurringGoalWeekdayFri => 'Ven';

  @override
  String get recurringGoalWeekdaySat => 'Sam';

  @override
  String get recurringGoalWeekdaySun => 'Dim';

  @override
  String recurringGoalTimeButton(Object time) {
    return 'Heure : $time';
  }

  @override
  String recurringGoalUntilButton(Object date) {
    return 'Jusqu’au : $date';
  }

  @override
  String get recurringGoalParametersSection => 'Paramètres';

  @override
  String get recurringGoalLifeBlockLabel => 'Domaine de vie';

  @override
  String get recurringGoalImportanceLabel => 'Importance';

  @override
  String get recurringGoalUserGoalLabel => 'Grand objectif';

  @override
  String get recurringGoalNoLink => 'Aucun lien';

  @override
  String recurringGoalLoadingUserGoals(Object block) {
    return 'Chargement des objectifs pour « $block »...';
  }

  @override
  String recurringGoalNoUserGoalsForBlock(Object block) {
    return 'Aucun objectif disponible pour « $block » pour le moment.';
  }

  @override
  String get recurringGoalPlannedHoursLabel => 'Heures prévues';

  @override
  String recurringGoalOccurrencesCount(Object count) {
    return 'Tâches à créer : $count';
  }

  @override
  String get recurringGoalCreate => 'Créer';

  @override
  String get recurringGoalLifeBlockGeneral => 'Général';

  @override
  String get recurringGoalLifeBlockHealth => 'Santé';

  @override
  String get recurringGoalLifeBlockCareer => 'Carrière';

  @override
  String get recurringGoalLifeBlockFinance => 'Finances';

  @override
  String get recurringGoalLifeBlockRelationships => 'Relations';

  @override
  String get recurringGoalLifeBlockSelf => 'Développement personnel';

  @override
  String get recurringGoalLifeBlockEducation => 'Éducation';

  @override
  String get recurringGoalLifeBlockTravel => 'Voyage';

  @override
  String get recurringGoalLifeBlockHome => 'Maison';

  @override
  String get recurringGoalHorizonTactical => 'Tactique';

  @override
  String get recurringGoalHorizonMid => 'Moyen terme';

  @override
  String get recurringGoalHorizonLong => 'Long terme';

  @override
  String get addDayGoalLinkSectionTitle => 'Lier à un objectif';

  @override
  String get addDayGoalUserGoalLabel => 'Grand objectif';

  @override
  String get addDayGoalNoLinkedGoal => 'Aucun lien';

  @override
  String addDayGoalLoadingUserGoals(Object block) {
    return 'Chargement des objectifs pour « $block »...';
  }

  @override
  String addDayGoalNoUserGoalsForBlock(Object block) {
    return 'Aucun objectif disponible pour « $block » pour le moment.';
  }

  @override
  String get addDayGoalLifeBlockGeneral => 'Général';

  @override
  String get addDayGoalLifeBlockHealth => 'Santé';

  @override
  String get addDayGoalLifeBlockCareer => 'Carrière';

  @override
  String get addDayGoalLifeBlockFinance => 'Finances';

  @override
  String get addDayGoalLifeBlockRelationships => 'Relations';

  @override
  String get addDayGoalLifeBlockSelf => 'Développement personnel';

  @override
  String get addDayGoalLifeBlockEducation => 'Éducation';

  @override
  String get addDayGoalLifeBlockTravel => 'Voyage';

  @override
  String get addDayGoalLifeBlockHome => 'Maison';

  @override
  String get addDayGoalHorizonTactical => 'Tactique';

  @override
  String get addDayGoalHorizonMid => 'Moyen terme';

  @override
  String get addDayGoalHorizonLong => 'Long terme';

  @override
  String get lifeBlockSelf => 'Développement personnel';

  @override
  String get lifeBlockTravel => 'Voyage';

  @override
  String get lifeBlockHome => 'Maison';

  @override
  String get horizonTactical => 'Tactique';

  @override
  String get horizonMid => 'Moyen terme';

  @override
  String get horizonLong => 'Long terme';

  @override
  String get editGoalSectionDateTime => 'Date et heure';

  @override
  String get editGoalSectionUserGoalLink => 'Lier à un grand objectif';

  @override
  String get userGoalLinkFieldLabel => 'Grand objectif';

  @override
  String get userGoalLinkNone => 'Aucun lien';

  @override
  String userGoalLinkLoadingForBlock(Object block) {
    return 'Chargement des objectifs pour « $block »...';
  }

  @override
  String userGoalLinkNoGoalsForBlock(Object block) {
    return 'Aucun objectif disponible pour « $block » pour le moment.';
  }

  @override
  String editGoalHoursValue(Object hours) {
    return 'Heures : $hours';
  }

  @override
  String commonHoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String get healthTrackerTitle => 'Suivi santé';

  @override
  String get healthCalorieTargetTitle => 'Objectif calorique';

  @override
  String get healthDailyCaloriesLabel => 'Kcal par jour';

  @override
  String get healthAddMealTitle => 'Ajouter un repas';

  @override
  String get healthMealTypeLabel => 'Repas';

  @override
  String get healthMealBreakfast => 'Petit-déjeuner';

  @override
  String get healthMealLunch => 'Déjeuner';

  @override
  String get healthMealDinner => 'Dîner';

  @override
  String get healthMealSnack => 'Collation';

  @override
  String get healthCaloriesLabel => 'Calories';

  @override
  String get healthEnterCalories => 'Saisis les calories';

  @override
  String get healthMealDescriptionLabel => 'Qu’as-tu mangé ?';

  @override
  String get healthAddDescription => 'Ajoute une description';

  @override
  String get healthAddBurnTitle => 'Ajouter des calories brûlées';

  @override
  String get healthCaloriesBurnedLabel => 'Calories brûlées';

  @override
  String get healthCommentLabel => 'Commentaire';

  @override
  String get healthWaterTodayTitle => 'Combien d’eau as-tu bu aujourd’hui ?';

  @override
  String get healthSaveWater => 'Enregistrer l’eau';

  @override
  String get healthSetTarget => 'Définir l’objectif';

  @override
  String healthTargetCalories(Object calories) {
    return 'Objectif $calories kcal';
  }

  @override
  String get healthAddMealButton => 'Ajouter un aliment';

  @override
  String get healthAddBurnButton => 'Ajouter une dépense';

  @override
  String healthWaterButton(Object liters) {
    return 'Eau $liters L';
  }

  @override
  String get healthConsumed => 'Consommé';

  @override
  String get healthBurned => 'Brûlé';

  @override
  String get healthBalance => 'Solde';

  @override
  String get healthDeltaVsTarget => 'Écart par rapport à l’objectif';

  @override
  String get healthWaterDrunk => 'Eau bue';

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
  String get healthMealsTodayTitle => 'Repas du jour';

  @override
  String get healthNoMeals => 'Aucune entrée de repas pour le moment.';

  @override
  String get healthBurnsTitle => 'Calories brûlées';

  @override
  String get healthNoBurns =>
      'Aucune entrée de calories brûlées pour le moment.';

  @override
  String get healthNoComment => 'Aucun commentaire';

  @override
  String get hobbyTrackerTitle => 'Suivi des loisirs';

  @override
  String get hobbyTrackerNewHobbyTitle => 'Nouveau loisir';

  @override
  String get hobbyTrackerHobbyNameLabel => 'Nom du loisir';

  @override
  String get hobbyTrackerEnterHobbyValidator => 'Saisis un loisir';

  @override
  String get hobbyTrackerWeeklyGoalMinutesLabel =>
      'Objectif hebdomadaire, minutes';

  @override
  String get hobbyTrackerEnterGoalValidator => 'Saisis un objectif';

  @override
  String get hobbyTrackerCreateButton => 'Créer';

  @override
  String hobbyTrackerAddTimeTitle(Object title) {
    return 'Ajouter du temps : $title';
  }

  @override
  String get hobbyTrackerMinutesSpentLabel => 'Minutes passées';

  @override
  String get hobbyTrackerNoteLabel => 'Note';

  @override
  String get hobbyTrackerDeleteConfirmTitle => 'Supprimer le loisir ?';

  @override
  String hobbyTrackerDeleteConfirmBody(Object title) {
    return 'Le loisir « $title » sera supprimé avec toutes ses entrées.';
  }

  @override
  String get hobbyTrackerAddHobbyTooltip => 'Ajouter un loisir';

  @override
  String get hobbyTrackerEmptyText =>
      'Aucun loisir pour le moment. Ajoute ta première activité et commence à suivre le temps.';

  @override
  String get hobbyTrackerCreateHobbyButton => 'Créer un loisir';

  @override
  String get hobbyTrackerDeleteHobbyTooltip => 'Supprimer le loisir';

  @override
  String get hobbyTrackerAddEntryButton => 'Ajouter une entrée';

  @override
  String hobbyTrackerToday(Object value) {
    return 'Aujourd’hui $value';
  }

  @override
  String hobbyTrackerWeek(Object value) {
    return 'Semaine $value';
  }

  @override
  String hobbyTrackerGoal(Object value) {
    return 'Objectif : $value';
  }

  @override
  String hobbyTrackerMinutesShort(Object minutes) {
    return '$minutes min';
  }

  @override
  String hobbyTrackerHoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String hobbyTrackerHoursMinutesShort(Object hours, Object minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get importGoalsReviewTitle => 'Importer des objectifs';

  @override
  String get importGoalsReviewSubtitle =>
      'Sélectionne ce que tu veux importer et ajuste le titre ou la description si nécessaire.';

  @override
  String get importGoalsReviewSelectAll => 'Tout sélectionner';

  @override
  String get importGoalsReviewYes => 'Oui';

  @override
  String get importGoalsReviewNo => 'Non';

  @override
  String get importGoalsReviewListSection => 'Liste';

  @override
  String get importGoalsReviewImport => 'Importer';

  @override
  String get importGoalsReviewFieldTitle => 'Titre';

  @override
  String get importGoalsReviewFieldDescription => 'Description';

  @override
  String importGoalsReviewTime(Object time) {
    return 'Heure : $time';
  }

  @override
  String get importGoalsReviewChange => 'Modifier';

  @override
  String get shoppingBasketCopyHeader => '🛒 Liste de courses';

  @override
  String shoppingDueDatePrefix(Object date) {
    return 'avant le $date';
  }

  @override
  String get shoppingBasketCopied => 'Liste de courses copiée';

  @override
  String get shoppingNewWishlistItem => 'Nouvel élément de wishlist';

  @override
  String get shoppingNewPurchase => 'Nouvel achat';

  @override
  String get shoppingEditItem => 'Modifier l’élément';

  @override
  String get shoppingFieldTitle => 'Titre';

  @override
  String get shoppingEnterTitle => 'Saisis un titre';

  @override
  String get shoppingFieldDescription => 'Description';

  @override
  String get shoppingFieldPrice => 'Prix';

  @override
  String get shoppingFieldStore => 'Magasin';

  @override
  String get shoppingFieldExpenseCategory => 'Catégorie de dépense';

  @override
  String get shoppingNoCategory => 'Sans catégorie';

  @override
  String get shoppingAlreadyBought => 'Déjà acheté';

  @override
  String get shoppingPurchaseDate => 'Date d’achat';

  @override
  String get shoppingReset => 'Réinitialiser';

  @override
  String get shoppingEmpty => 'Vide pour le moment.';

  @override
  String get shoppingTrackerTitle => 'Suivi des achats';

  @override
  String get shoppingCopyBasket => 'Copier le panier';

  @override
  String get shoppingBasketTitle => 'Liste de courses';

  @override
  String get shoppingWishlistTitle => 'Wishlist';

  @override
  String get profileOpenLinkFailed => 'Impossible d’ouvrir le lien.';

  @override
  String get profileDangerZoneSubtitle => 'Suppression du compte';

  @override
  String get profileLegalDocumentsTitle => 'Documents juridiques';

  @override
  String get profileLegalDocumentsSubtitle =>
      'Tu peux ouvrir la politique de confidentialité, la déclaration de protection des données, les conditions d’utilisation et les mentions légales à tout moment.';

  @override
  String get profileLegalPrivacyTitle => 'Politique de confidentialité';

  @override
  String get profileLegalPrivacySubtitle =>
      'Version anglaise de la politique de confidentialité';

  @override
  String get profileLegalDatenschutzTitle =>
      'Déclaration de protection des données';

  @override
  String get profileLegalDatenschutzSubtitle =>
      'Version allemande de la politique de confidentialité';

  @override
  String get profileLegalTermsTitle => 'Conditions d’utilisation';

  @override
  String get profileLegalTermsSubtitle =>
      'Règles et conditions d’utilisation de Ladna';

  @override
  String get profileLegalImpressumTitle => 'Mentions légales';

  @override
  String get profileLegalImpressumSubtitle =>
      'Mentions légales et informations sur le fournisseur';

  @override
  String get settingsLanguageSystem => 'Système';

  @override
  String get settingsLanguageRussian => 'Russe';

  @override
  String get settingsLanguageEnglish => 'Anglais';

  @override
  String get settingsLanguageGerman => 'Allemand';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageSpanish => 'Espagnol';

  @override
  String get settingsLanguageTurkish => 'Turc';

  @override
  String get profileWebNotificationsEveningBody =>
      'Marque tes habitudes et fais le bilan de ta journée 👌';

  @override
  String get profileWebNotificationsPermissionDeniedToast =>
      'L’autorisation n’a pas été accordée. Vérifie les paramètres de notification de ton navigateur.';

  @override
  String get profileWebNotificationsPermissionGrantedToast =>
      'Les notifications du navigateur sont activées ✅';

  @override
  String profileWebNotificationsTimeChangedToast(Object time) {
    return 'Heure de notification : $time';
  }

  @override
  String get profileWebNotificationsLoadingSettings =>
      'Chargement des paramètres...';

  @override
  String get profileWebNotificationsEnabledToast =>
      'Activé. N’oublie pas d’autoriser les notifications dans ton navigateur.';

  @override
  String get profileWebNotificationsDisabledToast => 'Désactivé.';

  @override
  String get profileEditChipsDefaultHint =>
      'Saisis les valeurs séparées par des virgules';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue dans Ladna';

  @override
  String get onboardingWelcomeBody =>
      'Je vais te montrer rapidement les principales fonctions : actions rapides, tâches, grands objectifs, profil, rapports et finances.';

  @override
  String get onboardingSkip => 'Ignorer';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingFinishTitle => 'Terminé';

  @override
  String get onboardingFinishBody =>
      'Tu sais maintenant où se trouvent les principales fonctions de Ladna. Tu peux relancer le tutoriel plus tard depuis l’icône d’aide sur l’écran d’accueil.';

  @override
  String get onboardingGotIt => 'Compris';

  @override
  String get onboardingMainQuickActionsTitle => 'Actions rapides';

  @override
  String get onboardingMainQuickActionsText =>
      'Utilise ce bouton pour ajouter rapidement des tâches, l’humeur, des dépenses, des habitudes et lancer le plan IA.';

  @override
  String get onboardingMainNavigationTitle => 'Navigation Ladna';

  @override
  String get onboardingMainNavigationText =>
      'Tu trouveras ici les sections principales : accueil, tâches, grands objectifs, profil, rapports et finances.';

  @override
  String get onboardingMainHelpTitle => 'Rouvrir le guide';

  @override
  String get onboardingMainHelpText =>
      'Appuie sur cette icône quand tu veux refaire le tutoriel interactif plus tard.';

  @override
  String get onboardingGoalsFilterTitle => 'Filtre par domaine de vie';

  @override
  String get onboardingGoalsFilterText =>
      'Choisis carrière, santé, finances et d’autres domaines pour voir les tâches dans le bon contexte.';

  @override
  String get onboardingGoalsModeTitle => 'Tableau de bord ou calendrier';

  @override
  String get onboardingGoalsModeText =>
      'Le tableau de bord donne une vue d’ensemble, tandis que le calendrier t’aide à planifier les tâches par jour et par semaine.';

  @override
  String get onboardingGoalsAddTitle => 'Ajouter des actions';

  @override
  String get onboardingGoalsAddText =>
      'Ici, tu peux ajouter rapidement une tâche, une série de tâches ou remplir toute une journée avec plusieurs entrées.';

  @override
  String get onboardingReportsPeriodTitle => 'Période d’analyse';

  @override
  String get onboardingReportsPeriodText =>
      'Passe du jour à la semaine ou au mois pour comparer les objectifs, l’humeur, les habitudes et les finances dans le temps.';

  @override
  String get onboardingReportsChartTitle => 'Graphiques interactifs';

  @override
  String get onboardingReportsChartText =>
      'Appuie sur les segments et les points du graphique — l’application affichera uniquement les détails de l’élément sélectionné.';

  @override
  String get onboardingUserGoalsHeaderTitle => 'Grands objectifs';

  @override
  String get onboardingUserGoalsHeaderText =>
      'C’est ici que sont stockés les objectifs stratégiques : court, moyen et long terme. Plus tard, tu pourras y lier des tâches quotidiennes.';

  @override
  String get onboardingUserGoalsFiltersTitle => 'Filtres d’objectifs';

  @override
  String get onboardingUserGoalsFiltersText =>
      'Filtre les objectifs par domaine de vie et par horizon pour te concentrer rapidement sur la direction voulue.';

  @override
  String get onboardingUserGoalsAddTitle => 'Créer un grand objectif';

  @override
  String get onboardingUserGoalsAddText =>
      'Appuie ici pour ajouter un objectif, choisir un domaine de vie, un horizon et une échéance.';

  @override
  String get onboardingProfileHeaderTitle => 'Profil';

  @override
  String get onboardingProfileHeaderText =>
      'C’est le centre des paramètres personnels de Ladna : compte, focus, habitudes et préférences de l’application.';

  @override
  String get onboardingProfileCardTitle => 'Données personnelles';

  @override
  String get onboardingProfileCardText =>
      'Le nom, l’âge et les paramètres de base servent à personnaliser l’interface et les futures recommandations IA.';

  @override
  String get onboardingProfileFocusTitle => 'Focus et paramètres';

  @override
  String get onboardingProfileFocusText =>
      'Ces paramètres influencent la planification de la journée, l’analyse et les recommandations dans l’application.';

  @override
  String get onboardingBudgetIncomeTitle => 'Catégories de revenus';

  @override
  String get onboardingBudgetIncomeText =>
      'Ajoute des sources de revenus pour que l’analyse financière comprenne la structure de tes entrées.';

  @override
  String get onboardingBudgetExpenseTitle => 'Catégories de dépenses';

  @override
  String get onboardingBudgetExpenseText =>
      'Configure ici les catégories de dépenses et les limites. Cela t’aide à voir où ton budget part le plus vite.';

  @override
  String get onboardingBudgetJarsTitle => 'Enveloppes et répartition';

  @override
  String get onboardingBudgetJarsText =>
      'Utilise les enveloppes pour les objectifs d’épargne : voyage, fonds d’urgence, investissements ou gros achats.';

  @override
  String get onboardingBudgetSaveTitle => 'Enregistrer les paramètres';

  @override
  String get onboardingBudgetSaveText =>
      'Après les modifications, n’oublie pas d’enregistrer ton budget pour que les catégories et limites soient stockées dans la base de données.';

  @override
  String get onboardingDayGoalsSummaryTitle => 'Résumé du jour';

  @override
  String get onboardingDayGoalsSummaryText =>
      'Cette carte montre la progression de ta journée : combien de tâches sont terminées, ce qu’il reste et combien de temps est encore planifié.';

  @override
  String get onboardingDayGoalsFilterTitle => 'Masquer terminés';

  @override
  String get onboardingDayGoalsFilterText =>
      'Active ce filtre pour ne garder que les tâches actives à l’écran.';

  @override
  String get onboardingDayGoalsFabTitle => 'Ajouter une activité';

  @override
  String get onboardingDayGoalsFabText =>
      'Utilise ce bouton pour ajouter une tâche, reconnaître une entrée de journal ou synchroniser Google Calendar.';

  @override
  String get onboardingQuestionnaireProgressTitle =>
      'Progression de la configuration';

  @override
  String get onboardingQuestionnaireProgressText =>
      'Ici, tu vois à quelle étape de la configuration initiale tu te trouves.';

  @override
  String get onboardingQuestionnaireNextTitle => 'Continuer';

  @override
  String get onboardingQuestionnaireNextText =>
      'Après avoir terminé l’étape actuelle, appuie ici. À la fin, Ladna enregistrera ton profil, tes domaines de vie et tes objectifs.';

  @override
  String get onboardingExpensesControlsTitle => 'Jour et paramètres du budget';

  @override
  String get onboardingExpensesControlsText =>
      'Choisis ici la date de l’opération et ouvre les paramètres des catégories, limites et enveloppes.';

  @override
  String get onboardingExpensesSummaryTitle => 'Résumé financier mensuel';

  @override
  String get onboardingExpensesSummaryText =>
      'Cette carte affiche les revenus mensuels, les dépenses et le solde disponible — la base de l’analyse du budget.';

  @override
  String get onboardingExpensesTransactionsTitle =>
      'Opérations du jour sélectionné';

  @override
  String get onboardingExpensesTransactionsText =>
      'Ici, tu vois les revenus et dépenses de la journée. Appuie sur une opération pour la modifier ou glisse vers la gauche pour la supprimer.';

  @override
  String get onboardingExpensesFabTitle => 'Ajouter un revenu ou une dépense';

  @override
  String get onboardingExpensesFabText =>
      'Appuie sur plus pour ouvrir le menu et ajouter rapidement une nouvelle opération financière.';

  @override
  String get onboardingNextHint => 'Appuie sur l’écran pour continuer';

  @override
  String get registerLegalTermsTitle => 'Conditions d’utilisation';

  @override
  String get registerLegalPrivacyTitle => 'Politique de confidentialité';

  @override
  String get registerLegalDatenschutzTitle =>
      'Déclaration de protection des données';

  @override
  String get registerLegalImpressumTitle => 'Mentions légales';

  @override
  String registerLegalOptionalTitle(Object title) {
    return '$title · facultatif';
  }

  @override
  String get registerErrOpenRequiredLegalDocs =>
      'Merci d’ouvrir et de lire d’abord les conditions d’utilisation et la politique de confidentialité.';

  @override
  String registerLegalOpenFailed(Object document) {
    return 'Impossible d’ouvrir $document.';
  }

  @override
  String get registerLegalAcceptedText =>
      'J’ai lu et j’accepte les conditions d’utilisation et la politique de confidentialité.';

  @override
  String get registerLegalOpenRequiredDocsText =>
      'Ouvre et lis d’abord les conditions d’utilisation et la politique de confidentialité. La déclaration de protection des données et les mentions légales sont disponibles comme informations juridiques supplémentaires.';

  @override
  String get launcherDayGoals => 'Objectifs';

  @override
  String launcherPlannedHoursDescription(Object hours) {
    return 'Plan : $hours h';
  }
}
