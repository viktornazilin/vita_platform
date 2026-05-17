// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Nest App';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get register => 'Crear cuenta';

  @override
  String get home => 'Inicio';

  @override
  String get budgetSetupTitle => 'Presupuesto y huchas';

  @override
  String get budgetSetupSaved => 'Ajustes guardados';

  @override
  String get budgetSetupSaveError => 'Error al guardar';

  @override
  String get budgetIncomeCategoriesTitle => 'Categorías de ingresos';

  @override
  String get budgetIncomeCategoriesSubtitle => 'Se usa al añadir ingresos';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSubtitle =>
      'Elige el idioma de la app. “Sistema” usa el idioma de tu dispositivo.';

  @override
  String get budgetExpenseCategoriesTitle => 'Categorías de gastos';

  @override
  String get budgetExpenseCategoriesSubtitle =>
      'Los límites te ayudan a mantener los gastos bajo control';

  @override
  String get budgetJarsTitle => 'Huchas de ahorro';

  @override
  String get budgetJarsSubtitle =>
      'El porcentaje es una parte de los fondos libres que se añade automáticamente';

  @override
  String get loginOr => 'o';

  @override
  String get registerLegalPrefix => 'Al registrarte, aceptas los ';

  @override
  String get registerLegalTerms => 'Términos de uso';

  @override
  String get registerLegalMiddle => ' y la ';

  @override
  String get registerLegalPrivacy => 'Política de privacidad';

  @override
  String get registerLegalSuffix => '.';

  @override
  String get budgetNewIncomeCategory => 'Nueva categoría de ingresos';

  @override
  String get budgetNewExpenseCategory => 'Nueva categoría de gastos';

  @override
  String get budgetCategoryNameHint => 'Nombre de la categoría';

  @override
  String get budgetAddJar => 'Añadir una hucha';

  @override
  String get budgetJarAdded => 'Hucha añadida';

  @override
  String budgetJarAddFailed(Object error) {
    return 'No se pudo añadir: $error';
  }

  @override
  String get budgetJarDeleted => 'Hucha eliminada';

  @override
  String budgetJarDeleteFailed(Object error) {
    return 'No se pudo eliminar: $error';
  }

  @override
  String get budgetNoJarsTitle => 'Todavía no hay huchas';

  @override
  String get budgetNoJarsSubtitle =>
      'Crea tu primer objetivo de ahorro; te ayudaremos a alcanzarlo.';

  @override
  String get budgetSetOrChangeLimit => 'Establecer/cambiar límite';

  @override
  String get budgetDeleteCategoryTitle => '¿Eliminar categoría?';

  @override
  String budgetCategoryLabel(Object name) {
    return 'Categoría: $name';
  }

  @override
  String get budgetDeleteJarTitle => '¿Eliminar hucha?';

  @override
  String budgetJarLabel(Object title) {
    return 'Hucha: $title';
  }

  @override
  String budgetJarSummary(Object saved, Object percent, Object targetPart) {
    return 'Ahorrado: $saved ₽ • Porcentaje: $percent%$targetPart';
  }

  @override
  String get commonAdd => 'Añadir';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonLoading => 'cargando…';

  @override
  String get commonSaving => 'Guardando…';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonUpdate => 'Actualizar';

  @override
  String get commonCollapse => 'Contraer';

  @override
  String get commonDots => '...';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonChange => 'Cambiar';

  @override
  String get commonDate => 'Fecha';

  @override
  String get commonRefresh => 'Actualizar';

  @override
  String get commonDash => '—';

  @override
  String get commonPick => 'Elegir';

  @override
  String get commonRemove => 'Quitar';

  @override
  String get commonOr => 'o';

  @override
  String get commonCreate => 'Crear';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonCloseTooltip => 'Cerrar';

  @override
  String get commonTitle => 'Título';

  @override
  String get commonDeleteConfirmTitle => '¿Eliminar registro?';

  @override
  String get dayGoalsAllLifeBlocks => 'Todas las áreas';

  @override
  String get dayGoalsEmpty => 'No hay objetivos para este día';

  @override
  String dayGoalsAddFailed(Object error) {
    return 'No se pudo añadir el objetivo: $error';
  }

  @override
  String get dayGoalsUpdated => 'Objetivo actualizado';

  @override
  String dayGoalsUpdateFailed(Object error) {
    return 'No se pudo actualizar el objetivo: $error';
  }

  @override
  String get dayGoalsDeleted => 'Objetivo eliminado';

  @override
  String dayGoalsDeleteFailed(Object error) {
    return 'No se pudo eliminar: $error';
  }

  @override
  String dayGoalsToggleFailed(Object error) {
    return 'No se pudo cambiar el estado: $error';
  }

  @override
  String get dayGoalsDeleteConfirmTitle => '¿Eliminar objetivo?';

  @override
  String get dayGoalsFabAddTitle => 'Añadir objetivo';

  @override
  String get dayGoalsFabAddSubtitle => 'Crear manualmente';

  @override
  String get dayGoalsFabScanTitle => 'Escanear';

  @override
  String get dayGoalsFabScanSubtitle => 'Foto del diario';

  @override
  String get dayGoalsFabCalendarTitle => 'Google Calendar';

  @override
  String get dayGoalsFabCalendarSubtitle =>
      'Importar/exportar objetivos de hoy';

  @override
  String get epicIntroSkip => 'Omitir';

  @override
  String get epicIntroSubtitle =>
      'Un hogar para tus pensamientos. Un lugar donde los objetivos,\nlos sueños y los planes crecen con calma y consciencia.';

  @override
  String get epicIntroPrimaryCta => 'Empezar mi camino';

  @override
  String get epicIntroLater => 'Más tarde';

  @override
  String get epicIntroSecondaryCta => 'Iniciar sesión';

  @override
  String get epicIntroFooter => 'Siempre puedes volver al prólogo en Ajustes.';

  @override
  String get homeMoodSaved => 'Estado de ánimo guardado';

  @override
  String homeMoodSaveFailed(Object error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String get homeTodayAndWeekTitle => 'Hoy y semana';

  @override
  String get homeTodayAndWeekSubtitle =>
      'Un resumen rápido: todas las métricas clave están aquí';

  @override
  String get homeMetricMoodTitle => 'Estado de ánimo';

  @override
  String get homeMoodNoEntry => 'sin registro';

  @override
  String get homeMoodNoNote => 'sin nota';

  @override
  String get homeMoodHasNote => 'con nota';

  @override
  String get homeMetricTasksTitle => 'Tareas';

  @override
  String get homeMetricHoursPerDayTitle => 'Horas/día';

  @override
  String get homeMetricEfficiencyTitle => 'Eficiencia';

  @override
  String homeEfficiencyPlannedHours(Object hours) {
    return 'plan $hours h';
  }

  @override
  String get homeMoodTodayTitle => 'Estado de ánimo de hoy';

  @override
  String get homeMoodNoTodayEntry => 'No hay registro para hoy';

  @override
  String get homeMoodEntryNoNote => 'Hay registro (sin nota)';

  @override
  String get homeMoodQuickHint => 'Añade un check-in rápido: tarda 10 segundos';

  @override
  String get homeMoodUpdateHint =>
      'Puedes actualizarlo: sobrescribirá el registro de hoy';

  @override
  String get homeMoodNoteLabel => 'Nota (opcional)';

  @override
  String get homeMoodNoteHint => '¿Qué influyó en tu estado?';

  @override
  String get homeOpenMoodHistoryCta => 'Abrir historial de ánimo';

  @override
  String get homeWeekSummaryTitle => 'Resumen semanal';

  @override
  String get homeOpenReportsCta => 'Abrir informes detallados';

  @override
  String get homeWeekExpensesTitle => 'Gastos semanales';

  @override
  String get homeNoExpensesThisWeek => 'No hay gastos esta semana';

  @override
  String get homeOpenExpensesCta => 'Abrir gastos';

  @override
  String homeExpensesTotal(Object total) {
    return 'Total: $total €';
  }

  @override
  String homeExpensesAvgPerDay(Object avg) {
    return 'Media/día: $avg €';
  }

  @override
  String get homeInsightsTitle => 'Insights';

  @override
  String homeTopCategory(Object category, Object amount) {
    return '• Categoría principal: $category — $amount €';
  }

  @override
  String homePeakExpense(Object day, Object amount) {
    return '• Mayor gasto: $day — $amount €';
  }

  @override
  String get homeOpenDetailedExpensesCta => 'Abrir gastos detallados';

  @override
  String get homeWeekCardTitle => 'Semana';

  @override
  String get homeWeekLoadFailedTitle =>
      'No se pudieron cargar las estadísticas';

  @override
  String get homeWeekLoadFailedSubtitle =>
      'Comprueba tu conexión o inténtalo más tarde.';

  @override
  String get gcalTitle => 'Google Calendar';

  @override
  String get gcalHeaderImport =>
      'Busca eventos en tu calendario e impórtalos como objetivos.';

  @override
  String get gcalHeaderExport =>
      'Elige un periodo y exporta objetivos de la app a Google Calendar.';

  @override
  String get gcalModeImport => 'Importar';

  @override
  String get gcalModeExport => 'Exportar';

  @override
  String get gcalCalendarLabel => 'Calendario';

  @override
  String get gcalPrimaryCalendar => 'Principal (predeterminado)';

  @override
  String get gcalPeriodLabel => 'Periodo';

  @override
  String get gcalRangeToday => 'Hoy';

  @override
  String get gcalRangeNext7 => 'Próximos 7 días';

  @override
  String get gcalRangeNext30 => 'Próximos 30 días';

  @override
  String get gcalRangeCustom => 'Elegir periodo...';

  @override
  String get gcalDefaultLifeBlockLabel =>
      'Área de vida predeterminada (para importar)';

  @override
  String get gcalLifeBlockForGoalLabel => 'Área de vida para este objetivo';

  @override
  String get gcalEventsNotLoaded => 'Los eventos no están cargados';

  @override
  String get gcalConnectToLoadEvents => 'Conecta tu cuenta para cargar eventos';

  @override
  String get gcalExportHint =>
      'La exportación creará eventos en el calendario seleccionado para el periodo elegido.';

  @override
  String get gcalConnect => 'Conectar';

  @override
  String get gcalConnected => 'Conectado';

  @override
  String get gcalFindEvents => 'Buscar eventos';

  @override
  String get gcalImport => 'Importar';

  @override
  String get gcalExport => 'Exportar';

  @override
  String get gcalNoTitle => 'Sin título';

  @override
  String gcalImportedGoalsCount(Object count) {
    return 'Objetivos importados: $count';
  }

  @override
  String gcalExportedGoalsCount(Object count) {
    return 'Objetivos exportados: $count';
  }

  @override
  String get launcherQuickFunctionsTitle => 'Acciones rápidas';

  @override
  String get launcherQuickFunctionsSubtitle =>
      'Navegación y acciones con un toque';

  @override
  String get launcherSectionsTitle => 'Secciones';

  @override
  String get launcherQuickTitle => 'Rápido';

  @override
  String get launcherHome => 'Inicio';

  @override
  String get launcherGoals => 'Objetivos';

  @override
  String get launcherMood => 'Ánimo';

  @override
  String get launcherProfile => 'Perfil';

  @override
  String get launcherInsights => 'Insights';

  @override
  String get launcherReports => 'Informes';

  @override
  String get launcherMassAddTitle => 'Añadir en bloque para el día';

  @override
  String get launcherMassAddSubtitle => 'Gastos + Objetivos + Ánimo';

  @override
  String get launcherAiPlanTitle => 'Plan de IA para semana/mes';

  @override
  String get launcherAiPlanSubtitle =>
      'Análisis de objetivos, cuestionario y progreso';

  @override
  String get launcherAiInsightsTitle => 'Insights de IA';

  @override
  String get launcherAiInsightsSubtitle =>
      'Cómo los eventos afectan a objetivos y progreso';

  @override
  String get launcherRecurringGoalTitle => 'Objetivo recurrente';

  @override
  String get launcherRecurringGoalSubtitle =>
      'Planifica con varios días de antelación';

  @override
  String get launcherGoogleCalendarSyncTitle =>
      'Sincronización con Google Calendar';

  @override
  String get launcherGoogleCalendarSyncSubtitle =>
      'Exportar objetivos al calendario';

  @override
  String get launcherNoDatesToCreate =>
      'No hay fechas para crear (comprueba fecha límite/ajustes).';

  @override
  String launcherCreateSeriesFailed(Object error) {
    return 'No se pudo crear una serie de objetivos: $error';
  }

  @override
  String launcherSaveError(Object error) {
    return 'Error al guardar: $error';
  }

  @override
  String launcherCreatedGoalsCount(Object count) {
    return 'Objetivos creados: $count';
  }

  @override
  String launcherSavedSummary(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodPart,
  ) {
    return 'Guardado: $expenses gasto(s), $incomes ingreso(s), $goals objetivo(s), $habits hábito(s)$moodPart';
  }

  @override
  String get homeTitleHome => 'Inicio';

  @override
  String get homeTitleGoals => 'Objetivos';

  @override
  String get homeTitleMood => 'Estado de ánimo';

  @override
  String get homeTitleProfile => 'Perfil';

  @override
  String get homeTitleReports => 'Informes';

  @override
  String get homeTitleExpenses => 'Gastos';

  @override
  String get homeTitleApp => 'MyNEST';

  @override
  String get homeSignOutTooltip => 'Cerrar sesión';

  @override
  String get homeSignOutTitle => '¿Cerrar sesión?';

  @override
  String get homeSignOutSubtitle => 'Se cerrará tu sesión actual.';

  @override
  String get homeSignOutConfirm => 'Cerrar sesión';

  @override
  String homeSignOutFailed(Object error) {
    return 'No se pudo cerrar sesión: $error';
  }

  @override
  String get homeQuickActionsTooltip => 'Acciones rápidas';

  @override
  String get expensesTitle => 'Gastos';

  @override
  String get expensesPickDate => 'Elegir fecha';

  @override
  String get expensesCommitTooltip => 'Bloquear distribución de huchas';

  @override
  String get expensesCommitUndoTooltip => 'Deshacer bloqueo';

  @override
  String get expensesBudgetSettings => 'Configuración del presupuesto';

  @override
  String get expensesCommitDone => 'Distribución bloqueada';

  @override
  String get expensesCommitUndone => 'Bloqueo eliminado';

  @override
  String get expensesMonthSummary => 'Resumen mensual';

  @override
  String expensesIncomeLegend(Object value) {
    return 'Ingresos $value €';
  }

  @override
  String expensesExpenseLegend(Object value) {
    return 'Gastos $value €';
  }

  @override
  String expensesFreeLegend(Object value) {
    return 'Libre $value €';
  }

  @override
  String expensesDaySum(Object value) {
    return 'Total del día: $value €';
  }

  @override
  String get expensesNoTxForDay => 'No hay transacciones para este día';

  @override
  String get expensesDeleteTxTitle => '¿Eliminar transacción?';

  @override
  String expensesDeleteTxBody(Object category, Object amount) {
    return '$category — $amount €';
  }

  @override
  String get expensesCategoriesMonthTitle => 'Categorías de gastos mensuales';

  @override
  String get expensesNoCategoryData => 'Todavía no hay datos por categoría';

  @override
  String get expensesJarsTitle => 'Huchas de ahorro';

  @override
  String get expensesNoJars => 'Todavía no hay huchas';

  @override
  String get expensesCommitShort => 'Bloquear';

  @override
  String get expensesCommitUndoShort => 'Deshacer bloqueo';

  @override
  String get expensesAddIncome => 'Añadir ingreso';

  @override
  String get expensesAddExpense => 'Añadir gasto';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginShowPassword => 'Mostrar contraseña';

  @override
  String get loginHidePassword => 'Ocultar contraseña';

  @override
  String get loginForgotPassword => '¿Has olvidado la contraseña?';

  @override
  String get loginCreateAccount => 'Crear cuenta';

  @override
  String get loginBtnSignIn => 'Iniciar sesión';

  @override
  String get loginContinueGoogle => 'Continuar con Google';

  @override
  String get loginContinueApple => 'Continuar con Apple ID';

  @override
  String get loginErrEmailRequired => 'Introduce el email';

  @override
  String get loginErrEmailInvalid => 'Email no válido';

  @override
  String get loginErrPassRequired => 'Introduce la contraseña';

  @override
  String get loginErrPassMin6 => 'Mínimo 6 caracteres';

  @override
  String get loginResetTitle => 'Recuperación de contraseña';

  @override
  String get loginResetSend => 'Enviar';

  @override
  String get loginResetSent =>
      'Email de restablecimiento enviado. Revisa tu bandeja de entrada.';

  @override
  String loginResetFailed(Object error) {
    return 'No se pudo enviar el email: $error';
  }

  @override
  String get moodTitle => 'Estado de ánimo';

  @override
  String get moodOnePerDay => '1 registro = 1 día';

  @override
  String get moodHowDoYouFeel => '¿Cómo te sientes?';

  @override
  String get moodNoteLabel => 'Nota (opcional)';

  @override
  String get moodNoteHint => '¿Qué afectó a tu estado de ánimo?';

  @override
  String get moodSaved => 'Estado de ánimo guardado';

  @override
  String get moodUpdated => 'Registro actualizado';

  @override
  String get moodHistoryTitle => 'Historial de ánimo';

  @override
  String get moodTapToEdit => 'Toca para editar';

  @override
  String get moodNoNote => 'Sin nota';

  @override
  String get moodEditTitle => 'Editar registro';

  @override
  String get moodEmptyTitle => 'Todavía no hay registros';

  @override
  String get moodEmptySubtitle =>
      'Elige una fecha, selecciona tu estado de ánimo y guarda.';

  @override
  String moodErrSaveFailed(Object error) {
    return 'No se pudo guardar el estado de ánimo: $error';
  }

  @override
  String moodErrUpdateFailed(Object error) {
    return 'No se pudo actualizar el registro: $error';
  }

  @override
  String moodErrDeleteFailed(Object error) {
    return 'No se pudo eliminar el registro: $error';
  }

  @override
  String get onbTopTitle => '';

  @override
  String get onbErrSaveFailed => 'No se pudieron guardar tus respuestas';

  @override
  String get onbProfileTitle => 'Conozcámonos mejor';

  @override
  String get onbProfileSubtitle =>
      'Esto ayuda con tu perfil y la personalización';

  @override
  String get onbNameLabel => 'Nombre';

  @override
  String get onbNameHint => 'Por ejemplo: Viktor';

  @override
  String get onbAgeLabel => 'Edad';

  @override
  String get onbAgeHint => 'Por ejemplo: 26';

  @override
  String get onbNameNote => 'Puedes cambiar tu nombre más tarde en tu perfil.';

  @override
  String get onbBlocksTitle => '¿Qué áreas de vida quieres seguir?';

  @override
  String get onbBlocksSubtitle => 'Esto será la base de tus objetivos y quests';

  @override
  String get onbPrioritiesTitle =>
      '¿Qué es lo más importante para ti en los próximos 3–6 meses?';

  @override
  String get onbPrioritiesSubtitle =>
      'Elige hasta tres: esto afecta a las recomendaciones';

  @override
  String get onbPriorityHealth => 'Salud';

  @override
  String get onbPriorityCareer => 'Carrera';

  @override
  String get onbPriorityMoney => 'Dinero';

  @override
  String get onbPriorityFamily => 'Familia';

  @override
  String get onbPriorityGrowth => 'Crecimiento';

  @override
  String get onbPriorityLove => 'Amor';

  @override
  String get onbPriorityCreativity => 'Creatividad';

  @override
  String get onbPriorityBalance => 'Equilibrio';

  @override
  String onbGoalsBlockTitle(Object block) {
    return 'Objetivos en “$block”';
  }

  @override
  String get onbGoalsBlockSubtitle =>
      'Foco: táctico → medio plazo → largo plazo';

  @override
  String get onbGoalLongLabel => 'Objetivo a largo plazo (6–24 meses)';

  @override
  String get onbGoalLongHint => 'Por ejemplo: alcanzar nivel B2 de alemán';

  @override
  String get onbGoalMidLabel => 'Objetivo a medio plazo (2–6 meses)';

  @override
  String get onbGoalMidHint =>
      'Por ejemplo: terminar A2→B1 y aprobar el examen';

  @override
  String get onbGoalTacticalLabel => 'Objetivo táctico (2–4 semanas)';

  @override
  String get onbGoalTacticalHint =>
      'Por ejemplo: 12×30 min + 2 clubes de conversación';

  @override
  String get onbWhyLabel => '¿Por qué es importante? (opcional)';

  @override
  String get onbWhyHint => 'Motivación/sentido: ayuda a mantener el rumbo';

  @override
  String get onbOptionalNote => 'Puedes dejarlo vacío y tocar “Siguiente”.';

  @override
  String get registerTitle => 'Crear una cuenta';

  @override
  String get registerNameLabel => 'Nombre';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Contraseña';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get registerShowPassword => 'Mostrar contraseña';

  @override
  String get registerHidePassword => 'Ocultar contraseña';

  @override
  String get registerBtnSignUp => 'Registrarse';

  @override
  String get registerContinueGoogle => 'Continuar con Google';

  @override
  String get registerContinueApple => 'Continuar con Apple ID';

  @override
  String get registerContinueAppleIos => 'Continuar con Apple ID (iOS)';

  @override
  String get registerHaveAccountCta => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get registerErrNameRequired => 'Introduce tu nombre';

  @override
  String get registerErrEmailRequired => 'Introduce tu email';

  @override
  String get registerErrEmailInvalid => 'Email no válido';

  @override
  String get registerErrPassRequired => 'Introduce una contraseña';

  @override
  String get registerErrPassMin8 => 'Al menos 8 caracteres';

  @override
  String get registerErrPassNeedLower => 'Añade una letra minúscula (a-z)';

  @override
  String get registerErrPassNeedUpper => 'Añade una letra mayúscula (A-Z)';

  @override
  String get registerErrPassNeedDigit => 'Añade un dígito (0-9)';

  @override
  String get registerErrConfirmRequired => 'Repite la contraseña';

  @override
  String get registerErrPasswordsMismatch => 'Las contraseñas no coinciden';

  @override
  String get registerErrAcceptTerms =>
      'Debes aceptar los Términos y la Política de privacidad';

  @override
  String get registerAppleOnlyIos =>
      'Apple ID está disponible en iPhone/iPad (solo iOS)';

  @override
  String get welcomeAppName => 'VitaPlatform';

  @override
  String get welcomeSubtitle =>
      'Gestiona tus objetivos, estado de ánimo y tiempo\n— todo en un solo lugar';

  @override
  String get welcomeSignIn => 'Iniciar sesión';

  @override
  String get welcomeCreateAccount => 'Crear cuenta';

  @override
  String get habitsWeekTitle => 'Hábitos';

  @override
  String get habitsWeekTopTitle => 'Hábitos (top de esta semana)';

  @override
  String get habitsWeekEmptyHint =>
      'Añade al menos un hábito: tu progreso aparecerá aquí.';

  @override
  String get habitsWeekFooterHint =>
      'Mostramos tus hábitos más activos de los últimos 7 días.';

  @override
  String get mentalWeekTitle => 'Salud mental';

  @override
  String mentalWeekLoadError(Object error) {
    return 'Error de carga: $error';
  }

  @override
  String get mentalWeekNoAnswers =>
      'No se encontraron respuestas esta semana (para el user_id actual).';

  @override
  String get mentalWeekYesNoHeader => 'Sí/No (semana)';

  @override
  String get mentalWeekScalesHeader => 'Escalas (tendencia)';

  @override
  String get mentalWeekFooterHint =>
      'Mostramos solo algunas preguntas para mantener la pantalla limpia.';

  @override
  String get mentalWeekNoData => 'Sin datos';

  @override
  String mentalWeekYesCount(Object yes, Object total) {
    return 'Sí: $yes/$total';
  }

  @override
  String get moodWeekTitle => 'Estado de ánimo semanal';

  @override
  String moodWeekMarkedCount(Object filled, Object total) {
    return 'Registrado: $filled/$total';
  }

  @override
  String get moodWeekAverageDash => 'Media: —';

  @override
  String moodWeekAverageValue(Object avg) {
    return 'Media: $avg/5';
  }

  @override
  String get moodWeekFooterHint =>
      'Este es un resumen rápido. Los detalles están abajo en el historial.';

  @override
  String get goalsByBlockTitle => 'Objetivos por área';

  @override
  String get goalsAddTooltip => 'Añadir objetivo';

  @override
  String get goalsHorizonTacticalShort => 'Táctico';

  @override
  String get goalsHorizonMidShort => 'Medio plazo';

  @override
  String get goalsHorizonLongShort => 'Largo plazo';

  @override
  String get goalsHorizonTacticalLong => '2–6 semanas';

  @override
  String get goalsHorizonMidLong => '3–6 meses';

  @override
  String get goalsHorizonLongLong => '1+ año';

  @override
  String get goalsEditorNewTitle => 'Nuevo objetivo';

  @override
  String get goalsEditorEditTitle => 'Editar objetivo';

  @override
  String get goalsEditorLifeBlockLabel => 'Área';

  @override
  String get goalsEditorHorizonLabel => 'Horizonte';

  @override
  String get goalsEditorTitleLabel => 'Título';

  @override
  String get goalsEditorTitleHint => 'p. ej. Mejorar inglés hasta B2';

  @override
  String get goalsEditorDescLabel => 'Descripción (opcional)';

  @override
  String get goalsEditorDescHint =>
      'Brevemente: qué exactamente y cómo mediremos el éxito';

  @override
  String goalsEditorDeadlineLabel(Object date) {
    return 'Fecha límite: $date';
  }

  @override
  String goalsDeadlineInline(Object date) {
    return 'Fecha límite: $date';
  }

  @override
  String get goalsEmptyAllHint =>
      'Todavía no hay objetivos. Añade tu primer objetivo para las áreas seleccionadas.';

  @override
  String get goalsNoBlocksToShow => 'No hay áreas disponibles para mostrar.';

  @override
  String get goalsNoGoalsForBlock =>
      'No hay objetivos para el área seleccionada.';

  @override
  String get goalsDeleteConfirmTitle => '¿Eliminar objetivo?';

  @override
  String goalsDeleteConfirmBody(Object title) {
    return '“$title” se eliminará y no podrá restaurarse.';
  }

  @override
  String get habitsTitle => 'Hábitos';

  @override
  String get habitsEmptyHint => 'Todavía no hay hábitos. Añade el primero.';

  @override
  String get habitsEditorNewTitle => 'Nuevo hábito';

  @override
  String get habitsEditorEditTitle => 'Editar hábito';

  @override
  String get habitsEditorTitleLabel => 'Título';

  @override
  String get habitsEditorTitleHint => 'p. ej. Entrenamiento matutino';

  @override
  String get habitsNegativeLabel => 'Hábito negativo';

  @override
  String get habitsNegativeHint => 'Márcalo si quieres seguirlo y reducirlo.';

  @override
  String get habitsPositiveHint => 'Un hábito positivo/neutral para reforzar.';

  @override
  String get habitsNegativeShort => 'Negativo';

  @override
  String get habitsPositiveShort => 'Positivo/neutral';

  @override
  String get habitsDeleteConfirmTitle => '¿Eliminar hábito?';

  @override
  String habitsDeleteConfirmBody(Object title) {
    return '“$title” se eliminará y no podrá restaurarse.';
  }

  @override
  String get habitsFooterHint =>
      'Más tarde añadiremos “filtros” de hábitos en la pantalla principal.';

  @override
  String get profileTitle => 'Mi perfil';

  @override
  String get profileNameLabel => 'Nombre';

  @override
  String get profileNameTitle => 'Nombre';

  @override
  String get profileNamePrompt => '¿Cómo deberíamos llamarte?';

  @override
  String get profileAgeLabel => 'Edad';

  @override
  String get profileAgeTitle => 'Edad';

  @override
  String get profileAgePrompt => 'Introduce tu edad';

  @override
  String get profileAccountSection => 'Cuenta';

  @override
  String get profileSeenPrologueTitle => 'Prólogo completado';

  @override
  String get profileSeenPrologueSubtitle => 'Puedes cambiarlo manualmente';

  @override
  String get profileFocusSection => 'Foco';

  @override
  String get profileTargetHoursLabel => 'Horas objetivo al día';

  @override
  String profileTargetHoursValue(Object hours) {
    return '$hours h';
  }

  @override
  String get profileTargetHoursTitle => 'Objetivo diario de horas';

  @override
  String get profileTargetHoursFieldLabel => 'Horas';

  @override
  String get profileQuestionnaireSection => 'Cuestionario y áreas de vida';

  @override
  String get profileQuestionnaireNotDoneTitle =>
      'Aún no has completado el cuestionario.';

  @override
  String get profileQuestionnaireCta => 'Completar ahora';

  @override
  String get profileLifeBlocksTitle => 'Áreas de vida';

  @override
  String get profileLifeBlocksHint => 'p. ej. salud, carrera, familia';

  @override
  String get profilePrioritiesTitle => 'Prioridades';

  @override
  String get profilePrioritiesHint => 'p. ej. deporte, finanzas, lectura';

  @override
  String get profileDangerZoneTitle => 'Zona de peligro';

  @override
  String get profileDeleteAccountTitle => '¿Eliminar cuenta?';

  @override
  String get profileDeleteAccountBody =>
      'Esta acción es irreversible.\nSe eliminarán: objetivos, hábitos, estado de ánimo, gastos/ingresos, huchas, planes de IA, XP y tu perfil.';

  @override
  String get profileDeleteAccountConfirm => 'Eliminar para siempre';

  @override
  String get profileDeleteAccountCta => 'Eliminar cuenta y todos los datos';

  @override
  String get profileDeletingAccount => 'Eliminando…';

  @override
  String get profileDeleteAccountFootnote =>
      'La eliminación es irreversible. Tus datos se eliminarán permanentemente de Supabase.';

  @override
  String get profileAccountDeletedToast => 'Cuenta eliminada';

  @override
  String get lifeBlockHealth => 'Salud';

  @override
  String get lifeBlockCareer => 'Carrera';

  @override
  String get lifeBlockFamily => 'Familia';

  @override
  String get lifeBlockFinance => 'Finanzas';

  @override
  String get lifeBlockLearning => 'Crecimiento';

  @override
  String get lifeBlockSocial => 'Social';

  @override
  String get lifeBlockRest => 'Descanso';

  @override
  String get lifeBlockBalance => 'Equilibrio';

  @override
  String get lifeBlockLove => 'Amor';

  @override
  String get lifeBlockCreativity => 'Creatividad';

  @override
  String get lifeBlockGeneral => 'General';

  @override
  String get addDayGoalTitle => 'Nuevo objetivo diario';

  @override
  String get addDayGoalFieldTitle => 'Título *';

  @override
  String get addDayGoalTitleHint => 'Ej.: Entrenamiento / Trabajo / Estudio';

  @override
  String get addDayGoalFieldDescription => 'Descripción';

  @override
  String get addDayGoalDescriptionHint =>
      'Brevemente: qué hay que hacer exactamente';

  @override
  String get addDayGoalStartTime => 'Hora de inicio';

  @override
  String get addDayGoalLifeBlock => 'Área de vida';

  @override
  String get addDayGoalImportance => 'Importancia';

  @override
  String get addDayGoalEmotion => 'Emoción';

  @override
  String get addDayGoalHours => 'Horas';

  @override
  String get addDayGoalEnterTitle => 'Introduce un título';

  @override
  String get addExpenseNewTitle => 'Nuevo gasto';

  @override
  String get addExpenseEditTitle => 'Editar gasto';

  @override
  String get addExpenseAmountLabel => 'Importe';

  @override
  String get addExpenseAmountInvalid => 'Introduce un importe válido';

  @override
  String get addExpenseCategoryLabel => 'Categoría';

  @override
  String get addExpenseCategoryRequired => 'Selecciona una categoría';

  @override
  String get addExpenseCreateCategoryTooltip => 'Crear categoría';

  @override
  String get addExpenseNoteLabel => 'Nota';

  @override
  String get addExpenseNewCategoryTitle => 'Nueva categoría';

  @override
  String get addExpenseCategoryNameLabel => 'Nombre';

  @override
  String get addIncomeNewTitle => 'Nuevo ingreso';

  @override
  String get addIncomeEditTitle => 'Editar ingreso';

  @override
  String get addIncomeSubtitle => 'Importe, categoría y nota';

  @override
  String get addIncomeAmountLabel => 'Importe';

  @override
  String get addIncomeAmountHint => 'p. ej. 1200.50';

  @override
  String get addIncomeAmountInvalid => 'Introduce un importe válido';

  @override
  String get addIncomeCategoryLabel => 'Categoría';

  @override
  String get addIncomeCategoryRequired => 'Selecciona una categoría';

  @override
  String get addIncomeNoteLabel => 'Nota';

  @override
  String get addIncomeNoteHint => 'Opcional';

  @override
  String get addIncomeNewCategoryTitle => 'Nueva categoría de ingresos';

  @override
  String get addIncomeCategoryNameLabel => 'Nombre de la categoría';

  @override
  String get addIncomeCategoryNameHint => 'p. ej. Salario, Freelance…';

  @override
  String get addIncomeCategoryNameEmpty => 'Introduce un nombre de categoría';

  @override
  String get addJarNewTitle => 'Nueva hucha';

  @override
  String get addJarEditTitle => 'Editar hucha';

  @override
  String get addJarSubtitle => 'Define el objetivo y la parte del dinero libre';

  @override
  String get addJarNameLabel => 'Nombre';

  @override
  String get addJarNameHint => 'p. ej. Viaje, fondo de emergencia, casa';

  @override
  String get addJarNameRequired => 'Introduce un nombre';

  @override
  String get addJarPercentLabel => 'Parte del dinero libre, %';

  @override
  String get addJarPercentHint => '0 si la recargas manualmente';

  @override
  String get addJarPercentRange => 'El porcentaje debe estar entre 0 y 100';

  @override
  String get addJarTargetLabel => 'Importe objetivo';

  @override
  String get addJarTargetHint => 'p. ej. 5000';

  @override
  String get addJarTargetHelper => 'Obligatorio';

  @override
  String get addJarTargetRequired => 'Introduce un objetivo (número positivo)';

  @override
  String get aiInsightTypeDataQuality => 'Calidad de datos';

  @override
  String get aiInsightTypeRisk => 'Riesgo';

  @override
  String get aiInsightTypeEmotional => 'Emociones';

  @override
  String get aiInsightTypeHabit => 'Hábitos';

  @override
  String get aiInsightTypeGoal => 'Objetivos';

  @override
  String get aiInsightTypeDefault => 'Insight';

  @override
  String get aiInsightStrengthStrong => 'Impacto fuerte';

  @override
  String get aiInsightStrengthNoticeable => 'Impacto notable';

  @override
  String get aiInsightStrengthWeak => 'Impacto débil';

  @override
  String get aiInsightStrengthLowConfidence => 'Baja confianza';

  @override
  String aiInsightStrengthPercent(int value) {
    return '$value%';
  }

  @override
  String get aiInsightEvidenceTitle => 'Evidencia';

  @override
  String get aiInsightImpactPositive => 'Positivo';

  @override
  String get aiInsightImpactNegative => 'Negativo';

  @override
  String get aiInsightImpactMixed => 'Mixto';

  @override
  String get aiInsightsTitle => 'Insights de IA';

  @override
  String get aiInsightsConfirmTitle => '¿Ejecutar análisis de IA?';

  @override
  String get aiInsightsConfirmBody =>
      'La IA analizará tus tareas, hábitos y bienestar durante el periodo seleccionado y guardará insights. Puede tardar unos segundos.';

  @override
  String get aiInsightsConfirmRun => 'Ejecutar';

  @override
  String get aiInsightsPeriod7 => '7 días';

  @override
  String get aiInsightsPeriod30 => '30 días';

  @override
  String get aiInsightsPeriod90 => '90 días';

  @override
  String aiInsightsLastRun(String date) {
    return 'Última ejecución: $date';
  }

  @override
  String get aiInsightsEmptyNotRunTitle => 'La IA aún no se ha ejecutado';

  @override
  String get aiInsightsEmptyNotRunSubtitle =>
      'Elige un periodo y toca “Ejecutar”. Los insights se guardarán y estarán disponibles en la app.';

  @override
  String get aiInsightsCtaRun => 'Ejecutar análisis';

  @override
  String get aiInsightsEmptyNoInsightsTitle => 'Aún no hay insights';

  @override
  String get aiInsightsEmptyNoInsightsSubtitle =>
      'Añade más datos (tareas, hábitos, respuestas) y ejecuta el análisis otra vez.';

  @override
  String get aiInsightsCtaRunAgain => 'Ejecutar de nuevo';

  @override
  String aiInsightsErrorAi(String error) {
    return 'Error de IA: $error';
  }

  @override
  String get gcTitleDaySync => 'Google Calendar • sincronización diaria';

  @override
  String get gcSubtitleImport =>
      'Importa los eventos de este día como objetivos.';

  @override
  String get gcSubtitleExport =>
      'Exporta los objetivos de este día al calendario.';

  @override
  String get gcModeImport => 'Importar';

  @override
  String get gcModeExport => 'Exportar';

  @override
  String get gcCalendarLabel => 'Calendario';

  @override
  String get gcCalendarPrimary => 'Principal (predeterminado)';

  @override
  String get gcDefaultLifeBlockLabel =>
      'Área de vida predeterminada (para importar)';

  @override
  String get gcLifeBlockForThisGoalLabel => 'Área de vida para este objetivo';

  @override
  String get gcEventsNotLoaded => 'Los eventos no están cargados';

  @override
  String get gcConnectToLoadEvents => 'Conecta tu cuenta para cargar eventos';

  @override
  String get gcExportHint =>
      'La exportación creará eventos en el calendario seleccionado para los objetivos de este día.';

  @override
  String get gcConnect => 'Conectar';

  @override
  String get gcConnected => 'Conectado';

  @override
  String get gcFindForDay => 'Buscar para el día';

  @override
  String get gcImport => 'Importar';

  @override
  String get gcExport => 'Exportar';

  @override
  String get gcNoTitle => 'Sin título';

  @override
  String get gcLoadingDots => '...';

  @override
  String gcImportedGoals(int count) {
    return 'Objetivos importados: $count';
  }

  @override
  String gcExportedGoals(int count) {
    return 'Objetivos exportados: $count';
  }

  @override
  String get editGoalTitle => 'Editar objetivo';

  @override
  String get editGoalSectionDetails => 'Detalles';

  @override
  String get editGoalSectionLifeBlock => 'Área de vida';

  @override
  String get editGoalSectionParams => 'Ajustes';

  @override
  String get editGoalFieldTitleLabel => 'Título';

  @override
  String get editGoalFieldTitleHint => 'Ejemplo: carrera de 3 km';

  @override
  String get editGoalFieldDescLabel => 'Descripción';

  @override
  String get editGoalFieldDescHint => '¿Qué hay que hacer exactamente?';

  @override
  String get editGoalFieldLifeBlockLabel => 'Área de vida';

  @override
  String get editGoalFieldImportanceLabel => 'Importancia';

  @override
  String get editGoalImportanceLow => 'Baja';

  @override
  String get editGoalImportanceMedium => 'Media';

  @override
  String get editGoalImportanceHigh => 'Alta';

  @override
  String get editGoalFieldEmotionLabel => 'Emoción';

  @override
  String get editGoalFieldEmotionHint => '😊';

  @override
  String get editGoalDurationHours => 'Duración (h)';

  @override
  String get editGoalStartTime => 'Inicio';

  @override
  String get editGoalUntitled => 'Sin título';

  @override
  String get expenseCategoryOther => 'Otro';

  @override
  String get goalStatusDone => 'Hecho';

  @override
  String get goalStatusInProgress => 'En progreso';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String goalImportanceChip(int value) {
    return 'Prioridad $value/5';
  }

  @override
  String goalHoursChip(String value) {
    return 'Horas $value';
  }

  @override
  String get goalPathEmpty => 'No hay objetivos en la ruta';

  @override
  String get timelineActionEdit => 'Editar';

  @override
  String get timelineActionDelete => 'Eliminar';

  @override
  String get saveBarSaving => 'Guardando…';

  @override
  String get saveBarSave => 'Guardar';

  @override
  String get reportEmptyChartNotEnoughData => 'Datos insuficientes';

  @override
  String limitSheetTitle(String categoryName) {
    return 'Límite para “$categoryName”';
  }

  @override
  String get limitSheetHintNoLimit => 'Déjalo vacío — sin límite';

  @override
  String get limitSheetFieldLabel => 'Límite mensual';

  @override
  String get limitSheetFieldHint => 'p. ej. 15000';

  @override
  String get limitSheetCtaNoLimit => 'Sin límite';

  @override
  String get profileWebNotificationsSection => 'Notificaciones (Web)';

  @override
  String get profileWebNotificationsPermissionTitle =>
      'Permitir notificaciones';

  @override
  String get profileWebNotificationsPermissionSubtitle =>
      'Funciona en Web y solo mientras la pestaña está abierta.';

  @override
  String get profileWebNotificationsEveningTitle => 'Check-in nocturno';

  @override
  String profileWebNotificationsEveningSubtitle(Object time) {
    return 'Todos los días a las $time';
  }

  @override
  String get profileWebNotificationsChangeTime => 'Cambiar hora';

  @override
  String get profileWebNotificationsUnsupported =>
      'Las notificaciones del navegador no están disponibles en esta compilación. Funcionan solo en la versión Web (y solo mientras la pestaña está abierta).';

  @override
  String get lifeBlockEducation => 'Educación';

  @override
  String get lifeBlockHobbies => 'Hobbies';

  @override
  String get userGoalsTitle => 'Mis objetivos';

  @override
  String get userGoalsSubtitle =>
      'Objetivos estratégicos por área de vida: corto, medio y largo plazo.';

  @override
  String get userGoalsNewTitle => 'Nuevo objetivo';

  @override
  String get userGoalsEditTitle => 'Editar objetivo';

  @override
  String get userGoalsCreateGoal => 'Crear objetivo';

  @override
  String get userGoalsCreated => 'Objetivo creado';

  @override
  String userGoalsCreateError(Object error) {
    return 'No se pudo crear el objetivo: $error';
  }

  @override
  String get userGoalsUpdated => 'Objetivo actualizado';

  @override
  String userGoalsUpdateError(Object error) {
    return 'No se pudo actualizar el objetivo: $error';
  }

  @override
  String userGoalsStatusChangeError(Object error) {
    return 'No se pudo cambiar el estado: $error';
  }

  @override
  String userGoalsDeleteError(Object error) {
    return 'No se pudo eliminar el objetivo: $error';
  }

  @override
  String get userGoalsDeleteConfirmTitle => '¿Eliminar objetivo?';

  @override
  String get userGoalsAllBlocks => 'Todos';

  @override
  String get userGoalsAllHorizons => 'Todos los horizontes';

  @override
  String get userGoalsLoadErrorTitle => 'Error de carga';

  @override
  String get userGoalsNoActiveBlocksTitle => 'No hay áreas de vida activas';

  @override
  String get userGoalsNoActiveBlocksSubtitle =>
      'Primero elige las áreas de vida que sigue el usuario.';

  @override
  String get userGoalsEmptyTitle => 'Todavía no hay objetivos';

  @override
  String get userGoalsEmptySubtitle =>
      'Crea tu primer objetivo estratégico para una de tus áreas de vida.';

  @override
  String userGoalsDeadline(Object date) {
    return 'Fecha límite: $date';
  }

  @override
  String get userGoalsStatusCompleted => 'Completado';

  @override
  String get userGoalsStatusActive => 'Activo';

  @override
  String get userGoalsReopen => 'Reabrir';

  @override
  String get userGoalsComplete => 'Completar';

  @override
  String get userGoalsFieldLifeBlock => 'Área de vida';

  @override
  String get userGoalsFieldHorizon => 'Horizonte';

  @override
  String get userGoalsFieldTitle => 'Título del objetivo';

  @override
  String get userGoalsFieldDescription => 'Descripción';

  @override
  String get userGoalsPickTargetDate => 'Elegir fecha objetivo';

  @override
  String get userGoalsClearDate => 'Borrar fecha';

  @override
  String get monthJanuary => 'Enero';

  @override
  String get monthFebruary => 'Febrero';

  @override
  String get monthMarch => 'Marzo';

  @override
  String get monthApril => 'Abril';

  @override
  String get monthMay => 'Mayo';

  @override
  String get monthJune => 'Junio';

  @override
  String get monthJuly => 'Julio';

  @override
  String get monthAugust => 'Agosto';

  @override
  String get monthSeptember => 'Septiembre';

  @override
  String get monthOctober => 'Octubre';

  @override
  String get monthNovember => 'Noviembre';

  @override
  String get monthDecember => 'Diciembre';

  @override
  String get weekdayMonShort => 'Lun';

  @override
  String get weekdayTueShort => 'Mar';

  @override
  String get weekdayWedShort => 'Mié';

  @override
  String get weekdayThuShort => 'Jue';

  @override
  String get weekdayFriShort => 'Vie';

  @override
  String get weekdaySatShort => 'Sáb';

  @override
  String get weekdaySunShort => 'Dom';

  @override
  String get lifeBlockRelations => 'Relaciones';

  @override
  String get lifeBlockSpirituality => 'Espiritualidad';

  @override
  String goalsHeaderWeek(Object month, Object year, Object week) {
    return '$month $year, semana $week';
  }

  @override
  String get goalsQuickActionsTitle => 'Acciones rápidas';

  @override
  String get goalsQuickActionsSubtitle => 'Añade y planifica con un toque';

  @override
  String get goalsMassAddTitle => 'Entrada diaria masiva';

  @override
  String get goalsMassAddSubtitle =>
      'Gastos + Ingresos + Tareas + Ánimo + Hábitos';

  @override
  String goalsMassAddSaved(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodSuffix,
  ) {
    return 'Guardado: $expenses gasto(s), $incomes ingreso(s), $goals tarea(s), $habits hábito(s)$moodSuffix';
  }

  @override
  String get goalsMassAddMoodSuffix => ', ánimo';

  @override
  String goalsSaveError(Object error) {
    return 'Error al guardar: $error';
  }

  @override
  String get goalsRecurringGoalTitle => 'Objetivo recurrente';

  @override
  String get goalsRecurringGoalSubtitle =>
      'Planifica varios días por adelantado';

  @override
  String get goalsRecurringNoDates =>
      'No hay fechas para crear. Comprueba la fecha límite o los ajustes.';

  @override
  String goalsPlanHoursDescription(Object hours) {
    return 'Plan: $hours h';
  }

  @override
  String goalsCreatedCount(Object count) {
    return 'Objetivos creados: $count';
  }

  @override
  String goalsRecurringCreateError(Object error) {
    return 'No se pudo crear la serie de objetivos: $error';
  }

  @override
  String get goalsSimpleTaskTitle => 'Tarea rápida';

  @override
  String get goalsSimpleTaskSubtitle =>
      'Solo título, hora opcional, categoría General';

  @override
  String get goalsSimpleTaskSheetSubtitle =>
      'Solo título, hora opcional. La categoría predeterminada es General.';

  @override
  String get goalsTaskCreated => 'Tarea creada';

  @override
  String goalsTaskCreateError(Object error) {
    return 'Error al crear tarea: $error';
  }

  @override
  String get goalsAll => 'Todos';

  @override
  String get goalsViewDashboard => 'Dashboard';

  @override
  String get goalsViewCalendar => 'Calendario';

  @override
  String get goalsViewWeek => 'Semana';

  @override
  String get goalsViewMonth => 'Mes';

  @override
  String get goalsByBlocksTitle => 'Objetivos por área de vida';

  @override
  String get goalsShow => 'Mostrar';

  @override
  String get goalsByBlocksHiddenHint => 'Oculto. Toca 👁 para mostrar.';

  @override
  String get goalsEnterTaskTitle => 'Introduce un título de tarea';

  @override
  String get goalsTaskTitleLabel => 'Título de la tarea';

  @override
  String get goalsAddTime => 'Añadir hora';

  @override
  String goalsTimeValue(Object time) {
    return 'Hora: $time';
  }

  @override
  String get goalsRemoveTime => 'Quitar hora';

  @override
  String get goalsCreateTask => 'Crear tarea';

  @override
  String get goalsWeekSummaryTitle => 'Resumen semanal';

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
      'Todos los objetivos visibles están ocultos. Desactiva el filtro “Ocultar completados”.';

  @override
  String get dayGoalsKanbanOpenShort => 'Abiertas';

  @override
  String get dayGoalsKanbanDoneShort => 'Hechas';

  @override
  String get dayGoalsKanbanOpenTitle => 'En progreso';

  @override
  String get dayGoalsKanbanDoneTitle => 'Hecho';

  @override
  String get dayGoalsKanbanOpenEmpty => 'No hay tareas activas';

  @override
  String get dayGoalsKanbanDoneEmpty => 'Todavía no hay nada aquí';

  @override
  String dayGoalsHoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String get dayGoalsSectionMorning => 'Mañana';

  @override
  String get dayGoalsSectionDay => 'Día';

  @override
  String get dayGoalsSectionEvening => 'Tarde';

  @override
  String get dayGoalsSummaryTitle => 'Resumen del día';

  @override
  String get dayGoalsSummarySubtitle =>
      'Mantén el foco en lo importante y haz que el día sea manejable.';

  @override
  String get dayGoalsSummaryTotal => 'Total';

  @override
  String get dayGoalsSummaryDone => 'Hecho';

  @override
  String get dayGoalsSummaryRemaining => 'Restante';

  @override
  String dayGoalsRemainingHours(Object hours) {
    return 'Horas restantes: $hours';
  }

  @override
  String get dayGoalsHideCompleted => 'Ocultar completados';

  @override
  String get reportsTabSummary => 'Resumen';

  @override
  String get reportsTabRelations => 'Relaciones';

  @override
  String get reportsTabProductivity => 'Productividad';

  @override
  String get reportsTabExpenses => 'Gastos';

  @override
  String get reportsCompletedTasks => 'Tareas completadas';

  @override
  String get reportsSpentHours => 'Horas empleadas';

  @override
  String get reportsEfficiency => 'Eficiencia';

  @override
  String get reportsPeriodEfficiency => 'Eficiencia del periodo';

  @override
  String reportsPlanFactHours(Object planned, Object actual) {
    return 'Plan: $planned h • Real: $actual h';
  }

  @override
  String get reportsAdditionalMetrics => 'Métricas adicionales';

  @override
  String get reportsCorrelations => 'Relaciones entre métricas';

  @override
  String get reportsCorrelationsHint =>
      'No es una correlación científica, sino comparaciones claras por periodo.';

  @override
  String get reportsMoodProductivity => 'Ánimo → Productividad';

  @override
  String get reportsGoodMood => 'Bueno';

  @override
  String get reportsBadMood => 'Malo';

  @override
  String get reportsHabitsMoodProductivity => 'Hábitos → Ánimo / Productividad';

  @override
  String get reportsMoodMostlyHappy => 'mayormente 😊';

  @override
  String get reportsMoodMostlySad => 'mayormente 😞';

  @override
  String get reportsMoodMostlyNeutral => 'mayormente 😐';

  @override
  String reportsHabitsComparisonHint(int percent) {
    return 'Comparación de días con ≥ $percent% de hábitos completados y todos los demás días.';
  }

  @override
  String get reportsMoodHigh => 'Ánimo (alto)';

  @override
  String get reportsMoodLow => 'Ánimo (bajo)';

  @override
  String get reportsHoursHigh => 'Horas (alto)';

  @override
  String get reportsHoursLow => 'Horas (bajo)';

  @override
  String get reportsHabitsHighShort => 'hábitos altos';

  @override
  String get reportsHabitsLowShort => 'hábitos bajos';

  @override
  String get reportsMentalMood => 'Estado mental → Ánimo';

  @override
  String get reportsExpensesMood => 'Gastos → Ánimo';

  @override
  String get reportsHappyDays => 'días 😊';

  @override
  String get reportsSadDays => 'días 😞';

  @override
  String get reportsCompletedByBlocks => 'Completadas por bloques';

  @override
  String get reportsNoCompletedTasks => 'No hay tareas completadas';

  @override
  String reportsTasksCount(int count) {
    return '$count tareas';
  }

  @override
  String get reportsHoursByDays => 'Horas empleadas por día';

  @override
  String get reportsExpensesForPeriod => 'Gastos del periodo';

  @override
  String reportsTotalEuro(Object amount) {
    return 'Total: $amount €';
  }

  @override
  String reportsAvgExpensePerDay(Object amount) {
    return 'Gasto medio/día: $amount €';
  }

  @override
  String get reportsNoExpensesByCategory => 'No hay gastos por categoría';

  @override
  String get reportsAvgTimePerGoal => 'Tiempo medio por tarea';

  @override
  String get reportsOnTimeConditional => '“A tiempo” (aprox.)';

  @override
  String get reportsTop3ProductiveDays => 'TOP 3 días productivos';

  @override
  String reportsTopDayLine(int day, int month, int year, Object hours) {
    return '• $day.$month.$year: $hours h';
  }

  @override
  String get reportsPeriodDay => 'Día';

  @override
  String get reportsPeriodWeekShort => 'Semana';

  @override
  String get reportsPeriodMonthShort => 'Mes';

  @override
  String get reportsForward => 'Adelante';

  @override
  String get reportsTapChartSector => 'Toca un segmento del gráfico';

  @override
  String get reportsLatestAiInsights => 'Últimos insights de IA';

  @override
  String get reportsOpenAll => 'Abrir todo';

  @override
  String get reportsInsightsLoadFailed => 'No se pudieron cargar insights';

  @override
  String get reportsNoSavedInsights => 'Todavía no hay insights guardados.';

  @override
  String get reportsRunAiInsightsHint =>
      'Abre “Insights de IA” y ejecuta un análisis; después aparecerán aquí.';

  @override
  String get reportsAiPeriod7Days => 'últimos 7 días';

  @override
  String get reportsAiPeriod30Days => 'últimos 30 días';

  @override
  String get reportsAiPeriod90Days => 'últimos 90 días';

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
  String get aiPlanConsentSaved =>
      'Consentimiento para procesamiento con IA guardado';

  @override
  String aiPlanConsentCheckFailed(Object error) {
    return 'No se pudo comprobar o guardar el consentimiento para procesamiento con IA. Asegúrate de que la tabla users tenga los campos ai_processing_consent, ai_processing_consent_at y ai_processing_consent_version. Detalles: $error';
  }

  @override
  String get aiPlanConsentTitle => 'Consentimiento para procesamiento con IA';

  @override
  String get aiPlanConsentBody =>
      'Para generar un plan de IA, Nest analizará tus objetivos, tareas, hábitos, estado de ánimo y otros datos de la app. Estos datos se usan solo para crear recomendaciones, planes e insights personales.';

  @override
  String get aiPlanConsentDeclineBody =>
      'Puedes rechazar el consentimiento; en ese caso, la función de IA no se ejecutará.';

  @override
  String get aiPlanConsentNotNow => 'Ahora no';

  @override
  String get aiPlanConsentAgree => 'Acepto';

  @override
  String aiPlanOpenLinkFailed(Object url) {
    return 'No se pudo abrir el enlace: $url';
  }

  @override
  String get aiPlanUpdated => 'Plan de IA actualizado';

  @override
  String get aiPlanEmptyEdgeFunction =>
      'El plan está vacío. Revisa la Edge Function ai-plan.';

  @override
  String aiPlanHoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String aiPlanImportanceMeta(int importance) {
    return 'importancia $importance/5';
  }

  @override
  String get aiPlanLinkedToGoal => 'vinculado a un objetivo';

  @override
  String get aiPlanNothingToApply =>
      'Nada que aplicar — selecciona algunos elementos';

  @override
  String get aiPlanDefaultTaskTitle => 'Tarea de IA';

  @override
  String aiPlanTasksAdded(int count) {
    return 'Tareas añadidas: $count';
  }

  @override
  String get aiPlanApplyTypeError =>
      'Error de tipo de datos al añadir tareas: uno de los campos llegó como true/false en lugar de un número. Actualiza el archivo de nuevo: en esta versión, los valores bool se convierten además a números y el campo is_completed ya no se envía manualmente.';

  @override
  String get aiPlanTitleWeek => 'Plan de IA para la semana';

  @override
  String get aiPlanTitleMonth => 'Plan de IA para el mes';

  @override
  String get aiPlanRegenerateTooltip => 'Generar de nuevo';

  @override
  String aiPlanUpdatedAt(Object date) {
    return 'Actualizado: $date';
  }

  @override
  String get aiPlanCheckingConsent =>
      'Comprobando consentimiento para procesamiento con IA...';

  @override
  String get aiPlanApplyingTasks => 'Añadiendo tareas...';

  @override
  String get aiPlanGenerating => 'Generando plan de IA...';

  @override
  String aiPlanApplyCount(int count) {
    return 'Aplicar ($count)';
  }

  @override
  String get aiPlanRejectTooltip => 'Rechazar';

  @override
  String get aiPlanAcceptTooltip => 'Aceptar';

  @override
  String get aiPlanFieldBlock => 'Bloque';

  @override
  String get aiPlanFieldImportance => 'Importancia';

  @override
  String get aiPlanFieldHours => 'Horas';

  @override
  String get aiPlanFieldRepeat => 'Repetición';

  @override
  String get aiPlanConsentRequiredTitle =>
      'Se requiere consentimiento para procesamiento con IA';

  @override
  String get aiPlanConsentRequiredBody =>
      'Antes de generar un plan de IA, debes confirmar que Nest puede analizar datos de la app para recomendaciones personales.';

  @override
  String get aiPlanGiveConsent => 'Dar consentimiento';

  @override
  String get aiPlanPrivacyPolicy => 'Política de privacidad';

  @override
  String get aiPlanDatenschutz => 'Política de protección de datos';

  @override
  String get aiPlanTermsOfUse => 'Términos de uso';

  @override
  String get aiPlanEmptyTitle => 'El plan está vacío';

  @override
  String get aiPlanEmptyBody =>
      'Pulsa el botón de abajo para generar un plan basado en insights de IA, objetivos, tareas, hábitos y estado de ánimo.';

  @override
  String get aiPlanGeneratePlan => 'Generar plan';

  @override
  String get aiPlanRepeatNone => 'Sin repetición';

  @override
  String get aiPlanRepeatDaily => 'Cada día';

  @override
  String get aiPlanRepeatWeekdays => 'Días laborables';

  @override
  String get aiPlanRepeatWeekly => 'Una vez por semana';

  @override
  String get aiPlanLifeBlockOther => 'Otro';

  @override
  String get aiInsightsConsentTitle =>
      'Consentimiento para procesamiento con IA';

  @override
  String get aiInsightsConsentBody =>
      'Para generar insights de IA, Nest analizará tus objetivos, tareas, hábitos, estado de ánimo y otros datos de la app. Estos datos se usan solo para crear recomendaciones, planes e insights personales.';

  @override
  String get aiInsightsConsentDeclineBody =>
      'Puedes rechazar el consentimiento; en ese caso, la función de IA no se ejecutará.';

  @override
  String get aiInsightsConsentNotNow => 'Ahora no';

  @override
  String get aiInsightsConsentAgree => 'Acepto';

  @override
  String get aiInsightsConsentSaved =>
      'Consentimiento para procesamiento con IA guardado';

  @override
  String aiInsightsConsentCheckFailed(Object error) {
    return 'No se pudo comprobar o guardar el consentimiento para procesamiento con IA. Asegúrate de que la tabla users tenga los campos ai_processing_consent, ai_processing_consent_at y ai_processing_consent_version. Detalles: $error';
  }

  @override
  String get aiInsightsCheckingConsent =>
      'Comprobando consentimiento para procesamiento con IA...';

  @override
  String get aiInsightsUserNotAuthorized => 'El usuario no está autenticado';

  @override
  String aiInsightsOpenLinkFailed(Object url) {
    return 'No se pudo abrir el enlace: $url';
  }

  @override
  String get aiInsightsDefaultTitle => 'Insight de IA';

  @override
  String get aiInsightsConsentRequiredTitle =>
      'Se requiere consentimiento para procesamiento con IA';

  @override
  String get aiInsightsConsentRequiredBody =>
      'Antes de generar insights de IA, debes confirmar que Nest puede analizar datos de la app para recomendaciones personales.';

  @override
  String get aiInsightsGiveConsent => 'Dar consentimiento';

  @override
  String get aiInsightsPrivacyPolicy => 'Política de privacidad';

  @override
  String get aiInsightsDatenschutz => 'Política de protección de datos';

  @override
  String get aiInsightsTermsOfUse => 'Términos de uso';

  @override
  String get massDailyTitle => 'Entrada diaria masiva';

  @override
  String get massDailyDatePrefix => 'Fecha: ';

  @override
  String get massDailyChoose => 'Elegir';

  @override
  String get massDailyBack => 'Atrás';

  @override
  String get massDailyCancel => 'Cancelar';

  @override
  String get massDailyNext => 'Siguiente';

  @override
  String get massDailySaveAll => 'Guardar todo';

  @override
  String get massDailyEmptyRowsIgnored => 'Las filas vacías se ignoran.';

  @override
  String get massDailyMoodTitle => 'Estado de ánimo';

  @override
  String get massDailyMoodSubtitle => 'Nota opcional sobre cómo fue el día.';

  @override
  String get massDailyNote => 'Nota';

  @override
  String get massDailyHabitsTitle => 'Hábitos';

  @override
  String get massDailyHabitsSubtitle =>
      'Marca el cumplimiento y añade cantidad si hace falta.';

  @override
  String get massDailyRefresh => 'Actualizar';

  @override
  String get massDailyNoHabits =>
      'Todavía no hay hábitos. Añádelos en tu perfil.';

  @override
  String massDailyHabitsLoadFailed(Object error) {
    return 'No se pudieron cargar los hábitos: $error';
  }

  @override
  String get massDailyMentalTitle => 'Salud mental';

  @override
  String get massDailyMentalSubtitle =>
      'Un breve check-in diario para analítica posterior.';

  @override
  String get massDailyMentalIntro =>
      'Responde unas preguntas: esto ayuda a seguir tu estado.';

  @override
  String get massDailyNoMentalQuestions =>
      'Todavía no hay preguntas. Añádelas a la tabla mental_questions.';

  @override
  String massDailyMentalLoadFailed(Object error) {
    return 'No se pudieron cargar las preguntas: $error';
  }

  @override
  String get massDailyExpensesTitle => 'Gastos';

  @override
  String get massDailyExpensesSubtitle =>
      'Añade gastos para el día seleccionado.';

  @override
  String get massDailyIncomesTitle => 'Ingresos';

  @override
  String get massDailyIncomesSubtitle =>
      'Añade ingresos para el día seleccionado.';

  @override
  String get massDailyGoalsTitle => 'Tareas';

  @override
  String get massDailyGoalsSubtitle =>
      'Registra en qué trabajaste ese día y cuánto tiempo llevó.';

  @override
  String get massDailyAddRow => 'Añadir fila';

  @override
  String get massDailyNoMood => 'Sin estado de ánimo';

  @override
  String get massDailyQuantityExample => 'Cantidad (por ejemplo, cigarrillos)';

  @override
  String get massDailyQuantityOptional => 'Cantidad (opcional)';

  @override
  String get massDailyQuantityShort => 'Cant.';

  @override
  String get massDailyHabitNegative => 'Negativo';

  @override
  String get massDailyHabitPositive => 'Positivo';

  @override
  String get massDailyAnswer => 'Respuesta';

  @override
  String get massDailyAmount => 'Importe';

  @override
  String get massDailyCategory => 'Categoría';

  @override
  String get massDailyNoCategories => 'Sin categorías';

  @override
  String get massDailyTaskTitle => 'Título de la tarea';

  @override
  String get massDailyHours => 'Horas';

  @override
  String get massDailyTime => 'Hora';

  @override
  String get massDailyEmotion => 'Emoción';

  @override
  String get massDailyNoEmotion => 'Sin emoción';

  @override
  String get massDailyImportance => 'Importancia';

  @override
  String get massDailyBigGoal => 'Objetivo grande';

  @override
  String get massDailyNoLink => 'Sin vínculo';

  @override
  String get massDailyLoadingUserGoals => 'Cargando objetivos grandes...';

  @override
  String get massDailyNoUserGoalsForCategory =>
      'Todavía no hay objetivos grandes para esta categoría.';

  @override
  String get massDailyHorizonTactical => 'Táctico';

  @override
  String get massDailyHorizonMid => 'Medio plazo';

  @override
  String get massDailyHorizonLong => 'Largo plazo';

  @override
  String get massDailyLifeBlockGeneral => 'General';

  @override
  String get massDailyLifeBlockHealth => 'Salud';

  @override
  String get massDailyLifeBlockCareer => 'Carrera';

  @override
  String get massDailyLifeBlockFamily => 'Familia';

  @override
  String get massDailyLifeBlockFinance => 'Finanzas';

  @override
  String get massDailyLifeBlockEducation => 'Educación';

  @override
  String get massDailyLifeBlockHobbies => 'Hobbies';

  @override
  String get importJournalTextNotRecognized =>
      'No se reconoció el texto. Prueba con otra foto.';

  @override
  String get importJournalRecognizedTextTitle => 'Texto reconocido';

  @override
  String get importJournalContinue => 'Continuar';

  @override
  String get importJournalUntitled => 'Sin título';

  @override
  String get importJournalNoTasksFound =>
      'No se pudieron extraer tareas del texto.';

  @override
  String importJournalAddedGoals(Object count) {
    return 'Objetivos añadidos: $count';
  }

  @override
  String importJournalImportFailed(Object error) {
    return 'No se pudo importar: $error';
  }

  @override
  String get importJournalVisionApiKeyMissing =>
      'VISION_API_KEY no está configurado. Ejecuta la app con --dart-define=VISION_API_KEY=...';

  @override
  String importJournalVisionApiError(Object statusCode, Object body) {
    return 'Vision API devolvió el error $statusCode: $body';
  }

  @override
  String get importJournalEditTitle => 'Editar';

  @override
  String get importJournalNameLabel => 'Nombre';

  @override
  String get importJournalTimeColon => 'Hora:';

  @override
  String get importJournalHoursColon => 'Horas:';

  @override
  String get importJournalFoundTasksTitle => 'Tareas encontradas';

  @override
  String importJournalTaskSubtitle(Object time, Object hours) {
    return '$time • $hours h';
  }

  @override
  String get importJournalAddSelected => 'Añadir seleccionadas';

  @override
  String get recurringGoalSelectAtLeastOneWeekday =>
      'Selecciona al menos un día de la semana';

  @override
  String get recurringGoalTitle => 'Objetivo recurrente';

  @override
  String get recurringGoalSubtitle =>
      'Crea tareas desde hoy hasta la fecha seleccionada.';

  @override
  String get recurringGoalDetailsSection => 'Detalles';

  @override
  String get recurringGoalTitleLabel => 'Título del objetivo';

  @override
  String get recurringGoalTitleHint => 'Por ejemplo: Entrenamiento';

  @override
  String get recurringGoalEmotionLabel => 'Emoción';

  @override
  String get recurringGoalEmotionHint => 'Por ejemplo: 💪 motivación';

  @override
  String get recurringGoalRegularitySection => 'Recurrencia';

  @override
  String get recurringGoalEveryNDays => 'Cada N días';

  @override
  String get recurringGoalByWeekdays => 'Por días de la semana';

  @override
  String get recurringGoalIntervalLabel => 'Intervalo';

  @override
  String recurringGoalEveryNDaysShort(Object count) {
    return '$count d';
  }

  @override
  String get recurringGoalWeekdayMon => 'Lun';

  @override
  String get recurringGoalWeekdayTue => 'Mar';

  @override
  String get recurringGoalWeekdayWed => 'Mié';

  @override
  String get recurringGoalWeekdayThu => 'Jue';

  @override
  String get recurringGoalWeekdayFri => 'Vie';

  @override
  String get recurringGoalWeekdaySat => 'Sáb';

  @override
  String get recurringGoalWeekdaySun => 'Dom';

  @override
  String recurringGoalTimeButton(Object time) {
    return 'Hora: $time';
  }

  @override
  String recurringGoalUntilButton(Object date) {
    return 'Hasta: $date';
  }

  @override
  String get recurringGoalParametersSection => 'Parámetros';

  @override
  String get recurringGoalLifeBlockLabel => 'Área de vida';

  @override
  String get recurringGoalImportanceLabel => 'Importancia';

  @override
  String get recurringGoalUserGoalLabel => 'Objetivo grande';

  @override
  String get recurringGoalNoLink => 'Sin vínculo';

  @override
  String recurringGoalLoadingUserGoals(Object block) {
    return 'Cargando objetivos para “$block”...';
  }

  @override
  String recurringGoalNoUserGoalsForBlock(Object block) {
    return 'Todavía no hay objetivos disponibles para “$block”.';
  }

  @override
  String get recurringGoalPlannedHoursLabel => 'Horas planificadas';

  @override
  String recurringGoalOccurrencesCount(Object count) {
    return 'Tareas a crear: $count';
  }

  @override
  String get recurringGoalCreate => 'Crear';

  @override
  String get recurringGoalLifeBlockGeneral => 'General';

  @override
  String get recurringGoalLifeBlockHealth => 'Salud';

  @override
  String get recurringGoalLifeBlockCareer => 'Carrera';

  @override
  String get recurringGoalLifeBlockFinance => 'Finanzas';

  @override
  String get recurringGoalLifeBlockRelationships => 'Relaciones';

  @override
  String get recurringGoalLifeBlockSelf => 'Autodesarrollo';

  @override
  String get recurringGoalLifeBlockEducation => 'Educación';

  @override
  String get recurringGoalLifeBlockTravel => 'Viajes';

  @override
  String get recurringGoalLifeBlockHome => 'Hogar';

  @override
  String get recurringGoalHorizonTactical => 'Táctico';

  @override
  String get recurringGoalHorizonMid => 'Medio plazo';

  @override
  String get recurringGoalHorizonLong => 'Largo plazo';

  @override
  String get addDayGoalLinkSectionTitle => 'Vincular a un objetivo';

  @override
  String get addDayGoalUserGoalLabel => 'Objetivo grande';

  @override
  String get addDayGoalNoLinkedGoal => 'Sin vínculo';

  @override
  String addDayGoalLoadingUserGoals(Object block) {
    return 'Cargando objetivos para “$block”...';
  }

  @override
  String addDayGoalNoUserGoalsForBlock(Object block) {
    return 'Todavía no hay objetivos disponibles para “$block”.';
  }

  @override
  String get addDayGoalLifeBlockGeneral => 'General';

  @override
  String get addDayGoalLifeBlockHealth => 'Salud';

  @override
  String get addDayGoalLifeBlockCareer => 'Carrera';

  @override
  String get addDayGoalLifeBlockFinance => 'Finanzas';

  @override
  String get addDayGoalLifeBlockRelationships => 'Relaciones';

  @override
  String get addDayGoalLifeBlockSelf => 'Autodesarrollo';

  @override
  String get addDayGoalLifeBlockEducation => 'Educación';

  @override
  String get addDayGoalLifeBlockTravel => 'Viajes';

  @override
  String get addDayGoalLifeBlockHome => 'Hogar';

  @override
  String get addDayGoalHorizonTactical => 'Táctico';

  @override
  String get addDayGoalHorizonMid => 'Medio plazo';

  @override
  String get addDayGoalHorizonLong => 'Largo plazo';

  @override
  String get lifeBlockSelf => 'Autodesarrollo';

  @override
  String get lifeBlockTravel => 'Viajes';

  @override
  String get lifeBlockHome => 'Hogar';

  @override
  String get horizonTactical => 'Táctico';

  @override
  String get horizonMid => 'Medio plazo';

  @override
  String get horizonLong => 'Largo plazo';

  @override
  String get editGoalSectionDateTime => 'Fecha y hora';

  @override
  String get editGoalSectionUserGoalLink => 'Vincular a un objetivo mayor';

  @override
  String get userGoalLinkFieldLabel => 'Objetivo mayor';

  @override
  String get userGoalLinkNone => 'Sin vínculo';

  @override
  String userGoalLinkLoadingForBlock(Object block) {
    return 'Cargando objetivos para “$block”...';
  }

  @override
  String userGoalLinkNoGoalsForBlock(Object block) {
    return 'Todavía no hay objetivos disponibles para “$block”.';
  }

  @override
  String editGoalHoursValue(Object hours) {
    return 'Horas: $hours';
  }

  @override
  String commonHoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String get healthTrackerTitle => 'Tracker de salud';

  @override
  String get healthCalorieTargetTitle => 'Objetivo de calorías';

  @override
  String get healthDailyCaloriesLabel => 'Kcal al día';

  @override
  String get healthAddMealTitle => 'Añadir comida';

  @override
  String get healthMealTypeLabel => 'Comida';

  @override
  String get healthMealBreakfast => 'Desayuno';

  @override
  String get healthMealLunch => 'Almuerzo';

  @override
  String get healthMealDinner => 'Cena';

  @override
  String get healthMealSnack => 'Snack';

  @override
  String get healthCaloriesLabel => 'Calorías';

  @override
  String get healthEnterCalories => 'Introduce calorías';

  @override
  String get healthMealDescriptionLabel => '¿Qué comiste?';

  @override
  String get healthAddDescription => 'Añade una descripción';

  @override
  String get healthAddBurnTitle => 'Añadir calorías quemadas';

  @override
  String get healthCaloriesBurnedLabel => 'Calorías quemadas';

  @override
  String get healthCommentLabel => 'Comentario';

  @override
  String get healthWaterTodayTitle => '¿Cuánta agua bebiste hoy?';

  @override
  String get healthSaveWater => 'Guardar agua';

  @override
  String get healthSetTarget => 'Establecer objetivo';

  @override
  String healthTargetCalories(Object calories) {
    return 'Objetivo $calories kcal';
  }

  @override
  String get healthAddMealButton => 'Añadir comida';

  @override
  String get healthAddBurnButton => 'Añadir gasto';

  @override
  String healthWaterButton(Object liters) {
    return 'Agua $liters L';
  }

  @override
  String get healthConsumed => 'Consumido';

  @override
  String get healthBurned => 'Quemado';

  @override
  String get healthBalance => 'Balance';

  @override
  String get healthDeltaVsTarget => 'Diferencia vs objetivo';

  @override
  String get healthWaterDrunk => 'Agua bebida';

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
  String get healthMealsTodayTitle => 'Comidas de hoy';

  @override
  String get healthNoMeals => 'Todavía no hay registros de comida.';

  @override
  String get healthBurnsTitle => 'Calorías quemadas';

  @override
  String get healthNoBurns => 'Todavía no hay registros de calorías quemadas.';

  @override
  String get healthNoComment => 'Sin comentario';

  @override
  String get hobbyTrackerTitle => 'Tracker de hobbies';

  @override
  String get hobbyTrackerNewHobbyTitle => 'Nuevo hobby';

  @override
  String get hobbyTrackerHobbyNameLabel => 'Nombre del hobby';

  @override
  String get hobbyTrackerEnterHobbyValidator => 'Introduce un hobby';

  @override
  String get hobbyTrackerWeeklyGoalMinutesLabel => 'Objetivo semanal, minutos';

  @override
  String get hobbyTrackerEnterGoalValidator => 'Introduce un objetivo';

  @override
  String get hobbyTrackerCreateButton => 'Crear';

  @override
  String hobbyTrackerAddTimeTitle(Object title) {
    return 'Añadir tiempo: $title';
  }

  @override
  String get hobbyTrackerMinutesSpentLabel => 'Minutos dedicados';

  @override
  String get hobbyTrackerNoteLabel => 'Nota';

  @override
  String get hobbyTrackerDeleteConfirmTitle => '¿Eliminar hobby?';

  @override
  String hobbyTrackerDeleteConfirmBody(Object title) {
    return 'El hobby \"$title\" se eliminará junto con todos sus registros.';
  }

  @override
  String get hobbyTrackerAddHobbyTooltip => 'Añadir hobby';

  @override
  String get hobbyTrackerEmptyText =>
      'Todavía no hay hobbies. Añade tu primera actividad y empieza a registrar tiempo.';

  @override
  String get hobbyTrackerCreateHobbyButton => 'Crear hobby';

  @override
  String get hobbyTrackerDeleteHobbyTooltip => 'Eliminar hobby';

  @override
  String get hobbyTrackerAddEntryButton => 'Añadir registro';

  @override
  String hobbyTrackerToday(Object value) {
    return 'Hoy $value';
  }

  @override
  String hobbyTrackerWeek(Object value) {
    return 'Semana $value';
  }

  @override
  String hobbyTrackerGoal(Object value) {
    return 'Objetivo: $value';
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
  String get importGoalsReviewTitle => 'Importar objetivos';

  @override
  String get importGoalsReviewSubtitle =>
      'Selecciona qué importar y ajusta el título o la descripción si hace falta.';

  @override
  String get importGoalsReviewSelectAll => 'Seleccionar todo';

  @override
  String get importGoalsReviewYes => 'Sí';

  @override
  String get importGoalsReviewNo => 'No';

  @override
  String get importGoalsReviewListSection => 'Lista';

  @override
  String get importGoalsReviewImport => 'Importar';

  @override
  String get importGoalsReviewFieldTitle => 'Título';

  @override
  String get importGoalsReviewFieldDescription => 'Descripción';

  @override
  String importGoalsReviewTime(Object time) {
    return 'Hora: $time';
  }

  @override
  String get importGoalsReviewChange => 'Cambiar';

  @override
  String get shoppingBasketCopyHeader => '🛒 Lista de compras';

  @override
  String shoppingDueDatePrefix(Object date) {
    return 'hasta $date';
  }

  @override
  String get shoppingBasketCopied => 'Lista de compras copiada';

  @override
  String get shoppingNewWishlistItem => 'Nuevo elemento de wishlist';

  @override
  String get shoppingNewPurchase => 'Nueva compra';

  @override
  String get shoppingEditItem => 'Editar elemento';

  @override
  String get shoppingFieldTitle => 'Título';

  @override
  String get shoppingEnterTitle => 'Introduce un título';

  @override
  String get shoppingFieldDescription => 'Descripción';

  @override
  String get shoppingFieldPrice => 'Precio';

  @override
  String get shoppingFieldStore => 'Tienda';

  @override
  String get shoppingFieldExpenseCategory => 'Categoría de gasto';

  @override
  String get shoppingNoCategory => 'Sin categoría';

  @override
  String get shoppingAlreadyBought => 'Ya comprado';

  @override
  String get shoppingPurchaseDate => 'Fecha de compra';

  @override
  String get shoppingReset => 'Restablecer';

  @override
  String get shoppingEmpty => 'Vacío por ahora.';

  @override
  String get shoppingTrackerTitle => 'Tracker de compras';

  @override
  String get shoppingCopyBasket => 'Copiar cesta';

  @override
  String get shoppingBasketTitle => 'Lista de compras';

  @override
  String get shoppingWishlistTitle => 'Wishlist';

  @override
  String get profileOpenLinkFailed => 'No se pudo abrir el enlace.';

  @override
  String get profileDangerZoneSubtitle => 'Eliminación de cuenta';

  @override
  String get profileLegalDocumentsTitle => 'Documentos legales';

  @override
  String get profileLegalDocumentsSubtitle =>
      'Puedes abrir la Política de privacidad, Datenschutz, Términos de uso e Impressum en cualquier momento.';

  @override
  String get profileLegalPrivacyTitle => 'Política de privacidad';

  @override
  String get profileLegalPrivacySubtitle =>
      'Versión en inglés de la política de privacidad';

  @override
  String get profileLegalDatenschutzTitle => 'Datenschutzerklärung';

  @override
  String get profileLegalDatenschutzSubtitle =>
      'Versión alemana de la política de privacidad';

  @override
  String get profileLegalTermsTitle => 'Términos de uso';

  @override
  String get profileLegalTermsSubtitle => 'Reglas y condiciones para usar Nest';

  @override
  String get profileLegalImpressumTitle => 'Impressum';

  @override
  String get profileLegalImpressumSubtitle =>
      'Aviso legal e información del proveedor';

  @override
  String get settingsLanguageSystem => 'Sistema';

  @override
  String get settingsLanguageRussian => 'Ruso';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsLanguageGerman => 'Alemán';

  @override
  String get settingsLanguageFrench => 'Francés';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageTurkish => 'Turco';

  @override
  String get profileWebNotificationsEveningBody =>
      'Marca tus hábitos y cierra el día 👌';

  @override
  String get profileWebNotificationsPermissionDeniedToast =>
      'No se concedió el permiso. Revisa la configuración de notificaciones del navegador.';

  @override
  String get profileWebNotificationsPermissionGrantedToast =>
      'Notificaciones del navegador habilitadas ✅';

  @override
  String profileWebNotificationsTimeChangedToast(Object time) {
    return 'Hora de notificación: $time';
  }

  @override
  String get profileWebNotificationsLoadingSettings => 'Cargando ajustes...';

  @override
  String get profileWebNotificationsEnabledToast =>
      'Activado. Recuerda permitir las notificaciones en el navegador.';

  @override
  String get profileWebNotificationsDisabledToast => 'Desactivado.';

  @override
  String get profileEditChipsDefaultHint =>
      'Introduce valores separados por comas';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a Nest';

  @override
  String get onboardingWelcomeBody =>
      'Te mostraré rápidamente las funciones principales: acciones rápidas, tareas, grandes objetivos, perfil, informes y finanzas.';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingStart => 'Empezar';

  @override
  String get onboardingFinishTitle => 'Listo';

  @override
  String get onboardingFinishBody =>
      'Ahora sabes dónde están las funciones principales de Nest. Puedes reiniciar el tutorial más tarde desde el icono de ayuda en la pantalla principal.';

  @override
  String get onboardingGotIt => 'Entendido';

  @override
  String get onboardingMainQuickActionsTitle => 'Acciones rápidas';

  @override
  String get onboardingMainQuickActionsText =>
      'Usa este botón para añadir rápidamente tareas, estado de ánimo, gastos, hábitos y lanzar el plan de IA.';

  @override
  String get onboardingMainNavigationTitle => 'Navegación de Nest';

  @override
  String get onboardingMainNavigationText =>
      'Aquí encontrarás las secciones principales: inicio, tareas, grandes objetivos, perfil, informes y finanzas.';

  @override
  String get onboardingMainHelpTitle => 'Abrir la guía de nuevo';

  @override
  String get onboardingMainHelpText =>
      'Toca este icono cuando quieras repetir el How-To interactivo más tarde.';

  @override
  String get onboardingGoalsFilterTitle => 'Filtro por área de vida';

  @override
  String get onboardingGoalsFilterText =>
      'Elige carrera, salud, finanzas y otras áreas para ver tareas en el contexto adecuado.';

  @override
  String get onboardingGoalsModeTitle => 'Dashboard o calendario';

  @override
  String get onboardingGoalsModeText =>
      'El dashboard muestra la visión general, mientras que el calendario ayuda a planificar tareas por día y semana.';

  @override
  String get onboardingGoalsAddTitle => 'Añadir acciones';

  @override
  String get onboardingGoalsAddText =>
      'Aquí puedes añadir rápidamente una tarea, una serie de tareas o completar un día con varios registros.';

  @override
  String get onboardingReportsPeriodTitle => 'Periodo de análisis';

  @override
  String get onboardingReportsPeriodText =>
      'Cambia entre día, semana y mes para comparar objetivos, ánimo, hábitos y finanzas a lo largo del tiempo.';

  @override
  String get onboardingReportsChartTitle => 'Gráficos interactivos';

  @override
  String get onboardingReportsChartText =>
      'Toca segmentos y puntos de los gráficos: la app mostrará detalles solo del elemento seleccionado.';

  @override
  String get onboardingUserGoalsHeaderTitle => 'Grandes objetivos';

  @override
  String get onboardingUserGoalsHeaderText =>
      'Aquí se guardan objetivos estratégicos: corto, medio y largo plazo. Más tarde podrás vincular tareas diarias a ellos.';

  @override
  String get onboardingUserGoalsFiltersTitle => 'Filtros de objetivos';

  @override
  String get onboardingUserGoalsFiltersText =>
      'Filtra objetivos por área de vida y horizonte para centrarte rápidamente en la dirección que necesitas.';

  @override
  String get onboardingUserGoalsAddTitle => 'Crear un objetivo grande';

  @override
  String get onboardingUserGoalsAddText =>
      'Toca aquí para añadir un objetivo, elegir un área de vida, horizonte y fecha límite.';

  @override
  String get onboardingProfileHeaderTitle => 'Perfil';

  @override
  String get onboardingProfileHeaderText =>
      'Este es el centro de ajustes personales de Nest: cuenta, foco, hábitos y preferencias de la app.';

  @override
  String get onboardingProfileCardTitle => 'Datos personales';

  @override
  String get onboardingProfileCardText =>
      'Nombre, edad y parámetros básicos se usan para personalizar la interfaz y futuras recomendaciones de IA.';

  @override
  String get onboardingProfileFocusTitle => 'Foco y ajustes';

  @override
  String get onboardingProfileFocusText =>
      'Estos parámetros influyen en la planificación del día, la analítica y las recomendaciones de la app.';

  @override
  String get onboardingBudgetIncomeTitle => 'Categorías de ingresos';

  @override
  String get onboardingBudgetIncomeText =>
      'Añade fuentes de ingresos para que la analítica financiera entienda la estructura de tus entradas.';

  @override
  String get onboardingBudgetExpenseTitle => 'Categorías de gastos';

  @override
  String get onboardingBudgetExpenseText =>
      'Configura aquí categorías de gastos y límites. Esto ayuda a ver dónde se va más rápido tu presupuesto.';

  @override
  String get onboardingBudgetJarsTitle => 'Huchas y distribución';

  @override
  String get onboardingBudgetJarsText =>
      'Usa huchas para objetivos de ahorro: viajes, fondo de emergencia, inversiones o grandes compras.';

  @override
  String get onboardingBudgetSaveTitle => 'Guardar ajustes';

  @override
  String get onboardingBudgetSaveText =>
      'Después de hacer cambios, no olvides guardar el presupuesto para que categorías y límites queden en la base de datos.';

  @override
  String get onboardingDayGoalsSummaryTitle => 'Resumen del día';

  @override
  String get onboardingDayGoalsSummaryText =>
      'Esta tarjeta muestra tu progreso del día: cuántas tareas están hechas, qué queda y cuánto tiempo sigue planificado.';

  @override
  String get onboardingDayGoalsFilterTitle => 'Ocultar completadas';

  @override
  String get onboardingDayGoalsFilterText =>
      'Activa este filtro para dejar en pantalla solo las tareas activas.';

  @override
  String get onboardingDayGoalsFabTitle => 'Añadir actividad';

  @override
  String get onboardingDayGoalsFabText =>
      'Usa este botón para añadir una tarea, reconocer una entrada del diario o sincronizar Google Calendar.';

  @override
  String get onboardingQuestionnaireProgressTitle =>
      'Progreso de configuración';

  @override
  String get onboardingQuestionnaireProgressText =>
      'Aquí puedes ver en qué paso de la configuración inicial estás.';

  @override
  String get onboardingQuestionnaireNextTitle => 'Avanzar';

  @override
  String get onboardingQuestionnaireNextText =>
      'Después de completar el paso actual, toca aquí. Al final, Nest guardará tu perfil, áreas de vida y objetivos.';

  @override
  String get onboardingExpensesControlsTitle => 'Día y ajustes de presupuesto';

  @override
  String get onboardingExpensesControlsText =>
      'Elige aquí la fecha de operación y abre ajustes para categorías, límites y huchas.';

  @override
  String get onboardingExpensesSummaryTitle => 'Resumen financiero mensual';

  @override
  String get onboardingExpensesSummaryText =>
      'Esta tarjeta muestra ingresos mensuales, gastos y saldo libre: la base para analizar el presupuesto.';

  @override
  String get onboardingExpensesTransactionsTitle =>
      'Transacciones del día seleccionado';

  @override
  String get onboardingExpensesTransactionsText =>
      'Aquí ves ingresos y gastos del día. Toca una transacción para editarla o desliza a la izquierda para eliminarla.';

  @override
  String get onboardingExpensesFabTitle => 'Añadir ingreso o gasto';

  @override
  String get onboardingExpensesFabText =>
      'Toca el plus para abrir el menú y añadir rápidamente una nueva operación financiera.';

  @override
  String get onboardingNextHint => 'Toca la pantalla para continuar';

  @override
  String get registerLegalTermsTitle => 'Términos de uso';

  @override
  String get registerLegalPrivacyTitle => 'Política de privacidad';

  @override
  String get registerLegalDatenschutzTitle => 'Datenschutzerklärung';

  @override
  String get registerLegalImpressumTitle => 'Impressum';

  @override
  String registerLegalOptionalTitle(Object title) {
    return '$title · opcional';
  }

  @override
  String get registerErrOpenRequiredLegalDocs =>
      'Abre y lee primero los Términos de uso y la Política de privacidad.';

  @override
  String registerLegalOpenFailed(Object document) {
    return 'No se pudo abrir $document.';
  }

  @override
  String get registerLegalAcceptedText =>
      'He leído y acepto los Términos de uso y la Política de privacidad.';

  @override
  String get registerLegalOpenRequiredDocsText =>
      'Abre y lee primero los Términos de uso y la Política de privacidad. Datenschutzerklärung e Impressum están disponibles como información legal adicional.';

  @override
  String get launcherDayGoals => 'Objetivos del día';

  @override
  String launcherPlannedHoursDescription(Object hours) {
    return 'Plan: $hours h';
  }
}
