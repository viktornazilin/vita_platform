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
  String get budgetSetupTitle => 'Presupuesto y botes';

  @override
  String get budgetSetupSaved => 'Ajustes guardados';

  @override
  String get budgetSetupSaveError => 'Error al guardar';

  @override
  String get budgetIncomeCategoriesTitle => 'Categorías de ingresos';

  @override
  String get budgetIncomeCategoriesSubtitle => 'Se usan al añadir ingresos';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSubtitle =>
      'Elige el idioma de la app. “Sistema” usa el idioma del dispositivo.';

  @override
  String get budgetExpenseCategoriesTitle => 'Categorías de gastos';

  @override
  String get budgetExpenseCategoriesSubtitle =>
      'Los límites te ayudan a mantener el gasto bajo control';

  @override
  String get budgetJarsTitle => 'Botes de ahorro';

  @override
  String get budgetJarsSubtitle =>
      'El porcentaje es la parte de los fondos libres que se añade automáticamente';

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
  String get budgetAddJar => 'Añadir un bote';

  @override
  String get budgetJarAdded => 'Bote añadido';

  @override
  String budgetJarAddFailed(Object error) {
    return 'No se pudo añadir: $error';
  }

  @override
  String get budgetJarDeleted => 'Bote eliminado';

  @override
  String budgetJarDeleteFailed(Object error) {
    return 'No se pudo eliminar: $error';
  }

  @override
  String get budgetNoJarsTitle => 'Aún no hay botes';

  @override
  String get budgetNoJarsSubtitle =>
      'Crea tu primera meta de ahorro — te ayudaremos a conseguirla.';

  @override
  String get budgetSetOrChangeLimit => 'Establecer/cambiar límite';

  @override
  String get budgetDeleteCategoryTitle => '¿Eliminar categoría?';

  @override
  String budgetCategoryLabel(Object name) {
    return 'Categoría: $name';
  }

  @override
  String get budgetDeleteJarTitle => '¿Eliminar bote?';

  @override
  String budgetJarLabel(Object title) {
    return 'Bote: $title';
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
  String get commonDone => 'Hecho';

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
  String get commonDeleteConfirmTitle => '¿Eliminar entrada?';

  @override
  String get dayGoalsAllLifeBlocks => 'Todas las áreas';

  @override
  String get dayGoalsEmpty => 'No hay objetivos para este día';

  @override
  String dayGoalsAddFailed(Object error) {
    return 'No se pudo añadir un objetivo: $error';
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
      'Importar/exportar los objetivos de hoy';

  @override
  String get epicIntroSkip => 'Omitir';

  @override
  String get epicIntroSubtitle =>
      'Un hogar para los pensamientos. Un lugar donde metas,\nsueños y planes crecen — con calma y consciencia.';

  @override
  String get epicIntroPrimaryCta => 'Empezar mi viaje';

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
      'Un resumen rápido — aquí están todas las métricas clave';

  @override
  String get homeMetricMoodTitle => 'Ánimo';

  @override
  String get homeMoodNoEntry => 'sin entrada';

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
  String get homeMoodTodayTitle => 'Ánimo de hoy';

  @override
  String get homeMoodNoTodayEntry => 'No hay entrada para hoy';

  @override
  String get homeMoodEntryNoNote => 'Hay entrada (sin nota)';

  @override
  String get homeMoodQuickHint =>
      'Añade un check-in rápido — tarda 10 segundos';

  @override
  String get homeMoodUpdateHint =>
      'Puedes actualizar — sobrescribirá la entrada de hoy';

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
  String get homeWeekExpensesTitle => 'Gastos de la semana';

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
    return 'Prom/día: $avg €';
  }

  @override
  String get homeInsightsTitle => 'Insights';

  @override
  String homeTopCategory(Object category, Object amount) {
    return '• Categoría principal: $category — $amount €';
  }

  @override
  String homePeakExpense(Object day, Object amount) {
    return '• Pico de gasto: $day — $amount €';
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
      'Comprueba tu internet o inténtalo de nuevo más tarde.';

  @override
  String get gcalTitle => 'Google Calendar';

  @override
  String get gcalHeaderImport =>
      'Busca eventos en tu calendario e impórtalos como objetivos.';

  @override
  String get gcalHeaderExport =>
      'Elige un periodo y exporta los objetivos de la app a Google Calendar.';

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
  String get gcalDefaultLifeBlockLabel => 'Área predeterminada (para importar)';

  @override
  String get gcalLifeBlockForGoalLabel => 'Área para este objetivo';

  @override
  String get gcalEventsNotLoaded => 'Los eventos no se han cargado';

  @override
  String get gcalConnectToLoadEvents =>
      'Conecta tu cuenta para cargar los eventos';

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
  String get launcherAiPlanTitle => 'Plan IA para semana/mes';

  @override
  String get launcherAiPlanSubtitle =>
      'Análisis de objetivos, cuestionario y progreso';

  @override
  String get launcherAiInsightsTitle => 'Insights IA';

  @override
  String get launcherAiInsightsSubtitle =>
      'Cómo los eventos afectan a los objetivos y al progreso';

  @override
  String get launcherRecurringGoalTitle => 'Objetivo recurrente';

  @override
  String get launcherRecurringGoalSubtitle =>
      'Planifica varios días por adelantado';

  @override
  String get launcherGoogleCalendarSyncTitle =>
      'Sincronización con Google Calendar';

  @override
  String get launcherGoogleCalendarSyncSubtitle =>
      'Exportar objetivos al calendario';

  @override
  String get launcherNoDatesToCreate =>
      'No hay fechas para crear (revisa la fecha límite/ajustes).';

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
  String get homeTitleMood => 'Ánimo';

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
  String get expensesCommitTooltip => 'Bloquear asignación a botes';

  @override
  String get expensesCommitUndoTooltip => 'Deshacer bloqueo';

  @override
  String get expensesBudgetSettings => 'Ajustes de presupuesto';

  @override
  String get expensesCommitDone => 'Asignación bloqueada';

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
  String get expensesCategoriesMonthTitle => 'Categorías de gastos del mes';

  @override
  String get expensesNoCategoryData => 'Aún no hay datos por categoría';

  @override
  String get expensesJarsTitle => 'Botes de ahorro';

  @override
  String get expensesNoJars => 'Aún no hay botes';

  @override
  String get expensesCommitShort => 'Bloquear';

  @override
  String get expensesCommitUndoShort => 'Deshacer';

  @override
  String get expensesAddIncome => 'Añadir ingreso';

  @override
  String get expensesAddExpense => 'Añadir gasto';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginEmailLabel => 'Correo';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginShowPassword => 'Mostrar contraseña';

  @override
  String get loginHidePassword => 'Ocultar contraseña';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginCreateAccount => 'Crear cuenta';

  @override
  String get loginBtnSignIn => 'Iniciar sesión';

  @override
  String get loginContinueGoogle => 'Continuar con Google';

  @override
  String get loginContinueApple => 'Continuar con Apple ID';

  @override
  String get loginErrEmailRequired => 'Introduce el correo';

  @override
  String get loginErrEmailInvalid => 'Correo inválido';

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
      'Correo de restablecimiento enviado. Revisa tu bandeja de entrada.';

  @override
  String loginResetFailed(Object error) {
    return 'No se pudo enviar el correo: $error';
  }

  @override
  String get moodTitle => 'Ánimo';

  @override
  String get moodOnePerDay => '1 entrada = 1 día';

  @override
  String get moodHowDoYouFeel => '¿Cómo te sientes?';

  @override
  String get moodNoteLabel => 'Nota (opcional)';

  @override
  String get moodNoteHint => '¿Qué afectó tu ánimo?';

  @override
  String get moodSaved => 'Ánimo guardado';

  @override
  String get moodUpdated => 'Entrada actualizada';

  @override
  String get moodHistoryTitle => 'Historial de ánimo';

  @override
  String get moodTapToEdit => 'Toca para editar';

  @override
  String get moodNoNote => 'Sin nota';

  @override
  String get moodEditTitle => 'Editar entrada';

  @override
  String get moodEmptyTitle => 'Aún no hay entradas';

  @override
  String get moodEmptySubtitle =>
      'Elige una fecha, selecciona el ánimo y guarda.';

  @override
  String moodErrSaveFailed(Object error) {
    return 'No se pudo guardar el ánimo: $error';
  }

  @override
  String moodErrUpdateFailed(Object error) {
    return 'No se pudo actualizar la entrada: $error';
  }

  @override
  String moodErrDeleteFailed(Object error) {
    return 'No se pudo eliminar la entrada: $error';
  }

  @override
  String get onbTopTitle => '';

  @override
  String get onbErrSaveFailed => 'No se pudieron guardar tus respuestas';

  @override
  String get onbProfileTitle => 'Conozcámonos';

  @override
  String get onbProfileSubtitle =>
      'Esto ayuda a tu perfil y a la personalización';

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
  String get onbBlocksTitle => '¿Qué áreas de tu vida quieres seguir?';

  @override
  String get onbBlocksSubtitle =>
      'Esto será la base de tus objetivos y misiones';

  @override
  String get onbPrioritiesTitle =>
      '¿Qué es lo más importante para ti en los próximos 3–6 meses?';

  @override
  String get onbPrioritiesSubtitle =>
      'Elige hasta tres — esto afecta las recomendaciones';

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
      'Enfoque: táctico → medio plazo → largo plazo';

  @override
  String get onbGoalLongLabel => 'Objetivo a largo plazo (6–24 meses)';

  @override
  String get onbGoalLongHint => 'Por ejemplo: alcanzar el nivel B2 de alemán';

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
  String get onbWhyHint => 'Motivación/sentido — te ayuda a seguir';

  @override
  String get onbOptionalNote => 'Puedes dejarlo vacío y tocar “Siguiente”.';

  @override
  String get registerTitle => 'Crear un cuenta';

  @override
  String get registerNameLabel => 'Nombre';

  @override
  String get registerEmailLabel => 'Correo';

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
  String get registerHaveAccountCta => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get registerErrNameRequired => 'Introduce tu nombre';

  @override
  String get registerErrEmailRequired => 'Introduce tu correo';

  @override
  String get registerErrEmailInvalid => 'Correo inválido';

  @override
  String get registerErrPassRequired => 'Introduce una contraseña';

  @override
  String get registerErrPassMin8 => 'Al menos 8 caracteres';

  @override
  String get registerErrPassNeedLower => 'Añade una minúscula (a-z)';

  @override
  String get registerErrPassNeedUpper => 'Añade una mayúscula (A-Z)';

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
      'Gestiona tus objetivos, tu ánimo y tu tiempo\n— todo en un solo lugar';

  @override
  String get welcomeSignIn => 'Iniciar sesión';

  @override
  String get welcomeCreateAccount => 'Crear cuenta';

  @override
  String get habitsWeekTitle => 'Hábitos';

  @override
  String get habitsWeekTopTitle => 'Hábitos (top de la semana)';

  @override
  String get habitsWeekEmptyHint =>
      'Añade al menos un hábito — tu progreso aparecerá aquí.';

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
      'No se encontraron respuestas para esta semana (para el user_id actual).';

  @override
  String get mentalWeekYesNoHeader => 'Sí/No (semana)';

  @override
  String get mentalWeekScalesHeader => 'Escalas (tendencia)';

  @override
  String get mentalWeekFooterHint =>
      'Solo mostramos algunas preguntas para mantener la pantalla limpia.';

  @override
  String get mentalWeekNoData => 'Sin datos';

  @override
  String mentalWeekYesCount(Object yes, Object total) {
    return 'Sí: $yes/$total';
  }

  @override
  String get moodWeekTitle => 'Ánimo semanal';

  @override
  String moodWeekMarkedCount(Object filled, Object total) {
    return 'Registrado: $filled/$total';
  }

  @override
  String get moodWeekAverageDash => 'Promedio: —';

  @override
  String moodWeekAverageValue(Object avg) {
    return 'Promedio: $avg/5';
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
  String get goalsEditorTitleHint => 'p. ej. Mejorar el inglés hasta B2';

  @override
  String get goalsEditorDescLabel => 'Descripción (opcional)';

  @override
  String get goalsEditorDescHint =>
      'En breve: qué exactamente y cómo medimos el éxito';

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
      'Aún no hay objetivos. Añade tu primer objetivo para las áreas seleccionadas.';

  @override
  String get goalsNoBlocksToShow => 'No hay áreas disponibles para mostrar.';

  @override
  String get goalsNoGoalsForBlock =>
      'No hay objetivos para el área seleccionada.';

  @override
  String get goalsDeleteConfirmTitle => '¿Eliminar objetivo?';

  @override
  String goalsDeleteConfirmBody(Object title) {
    return '“$title” se eliminará y no se podrá restaurar.';
  }

  @override
  String get habitsTitle => 'Hábitos';

  @override
  String get habitsEmptyHint => 'Aún no hay hábitos. Añade el primero.';

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
  String get habitsNegativeHint =>
      'Márcalo si quieres registrarlo y reducirlo.';

  @override
  String get habitsPositiveHint => 'Un hábito positivo/neutro para reforzar.';

  @override
  String get habitsNegativeShort => 'Negativo';

  @override
  String get habitsPositiveShort => 'Positivo/neutro';

  @override
  String get habitsDeleteConfirmTitle => '¿Eliminar hábito?';

  @override
  String habitsDeleteConfirmBody(Object title) {
    return '“$title” se eliminará y no se podrá restaurar.';
  }

  @override
  String get habitsFooterHint =>
      'Más adelante añadiremos un “filtro” de hábitos en la pantalla de inicio.';

  @override
  String get profileTitle => 'Mi perfil';

  @override
  String get profileNameLabel => 'Nombre';

  @override
  String get profileNameTitle => 'Nombre';

  @override
  String get profileNamePrompt => '¿Cómo quieres que te llamemos?';

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
  String get profileSeenPrologueSubtitle => 'Puedes cambiar esto manualmente';

  @override
  String get profileFocusSection => 'Enfoque';

  @override
  String get profileTargetHoursLabel => 'Horas objetivo por día';

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
      'Esta acción es irreversible.\nSe eliminarán: objetivos, hábitos, ánimo, gastos/ingresos, botes, planes IA, XP y tu perfil.';

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
  String get addDayGoalTitleHint => 'p. ej.: Entrenar / Trabajo / Estudio';

  @override
  String get addDayGoalFieldDescription => 'Descripción';

  @override
  String get addDayGoalDescriptionHint =>
      'En breve: qué exactamente debe hacerse';

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
  String get addIncomeCategoryNameLabel => 'Nombre';

  @override
  String get addIncomeCategoryNameHint => 'p. ej. Sueldo, Freelance…';

  @override
  String get addIncomeCategoryNameEmpty => 'Introduce un nombre de categoría';

  @override
  String get addJarNewTitle => 'Nuevo bote';

  @override
  String get addJarEditTitle => 'Editar bote';

  @override
  String get addJarSubtitle => 'Define el objetivo y la parte del dinero libre';

  @override
  String get addJarNameLabel => 'Nombre';

  @override
  String get addJarNameHint => 'p. ej. Viaje, Fondo de emergencia, Casa';

  @override
  String get addJarNameRequired => 'Introduce un nombre';

  @override
  String get addJarPercentLabel => 'Parte del dinero libre, %';

  @override
  String get addJarPercentHint => '0 si lo aportas manualmente';

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
  String get aiInsightsTitle => 'Insights IA';

  @override
  String get aiInsightsConfirmTitle => '¿Ejecutar análisis IA?';

  @override
  String get aiInsightsConfirmBody =>
      'La IA analizará tus tareas, hábitos y bienestar para el periodo seleccionado y guardará insights. Esto puede tardar unos segundos.';

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
      'Añade más datos (tareas, hábitos, respuestas) y vuelve a ejecutar el análisis.';

  @override
  String get aiInsightsCtaRunAgain => 'Ejecutar de nuevo';

  @override
  String aiInsightsErrorAi(String error) {
    return 'Error de IA: $error';
  }

  @override
  String get gcTitleDaySync => 'Google Calendar • sincronización del día';

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
  String get gcDefaultLifeBlockLabel => 'Área predeterminada (para importar)';

  @override
  String get gcLifeBlockForThisGoalLabel => 'Área para este objetivo';

  @override
  String get gcEventsNotLoaded => 'Los eventos no se han cargado';

  @override
  String get gcConnectToLoadEvents =>
      'Conecta tu cuenta para cargar los eventos';

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
  String get editGoalFieldTitleHint => 'Ejemplo: correr 3 km';

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
  String get goalPathEmpty => 'No hay objetivos en el camino';

  @override
  String get timelineActionEdit => 'Editar';

  @override
  String get timelineActionDelete => 'Eliminar';

  @override
  String get saveBarSaving => 'Guardando…';

  @override
  String get saveBarSave => 'Guardar';

  @override
  String get reportEmptyChartNotEnoughData => 'No hay suficientes datos';

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
      'Funciona en Web y solo mientras la pestaña esté abierta.';

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
      'Las notificaciones del navegador no están disponibles en esta versión. Funcionan solo en la versión Web (y únicamente mientras la pestaña esté abierta).';
}
