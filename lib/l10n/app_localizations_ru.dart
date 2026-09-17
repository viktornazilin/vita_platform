// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Ladna';

  @override
  String get login => 'Вход';

  @override
  String get register => 'Регистрация';

  @override
  String get home => 'Главная';

  @override
  String get budgetSetupTitle => 'Бюджет и копилки';

  @override
  String get budgetSetupSaved => 'Настройки сохранены';

  @override
  String get budgetSetupSaveError => 'Ошибка сохранения';

  @override
  String get budgetIncomeCategoriesTitle => 'Доходные категории';

  @override
  String get budgetIncomeCategoriesSubtitle =>
      'Используются при добавлении доходов';

  @override
  String get settingsLanguageTitle => 'Язык';

  @override
  String get settingsLanguageSubtitle =>
      'Выберите язык приложения. «Системный» использует язык устройства.';

  @override
  String get budgetExpenseCategoriesTitle => 'Расходные категории';

  @override
  String get budgetExpenseCategoriesSubtitle =>
      'Лимиты помогают держать траты под контролем';

  @override
  String get budgetJarsTitle => 'Копилки';

  @override
  String get budgetJarsSubtitle =>
      'Процент — доля от свободных средств, автоматически пополняемая';

  @override
  String get loginOr => 'или';

  @override
  String get registerLegalPrefix => 'Регистрируясь, вы принимаете ';

  @override
  String get registerLegalTerms => 'Условия использования';

  @override
  String get registerLegalMiddle => ' и ';

  @override
  String get registerLegalPrivacy => 'Политику конфиденциальности';

  @override
  String get registerLegalSuffix => '.';

  @override
  String get budgetNewIncomeCategory => 'Новая доходная категория';

  @override
  String get budgetNewExpenseCategory => 'Новая расходная категория';

  @override
  String get budgetCategoryNameHint => 'Например: Зарплата / Еда / Транспорт';

  @override
  String get budgetAddJar => 'Добавить копилку';

  @override
  String get budgetJarAdded => 'Копилка добавлена';

  @override
  String budgetJarAddFailed(Object error) {
    return 'Не удалось добавить: $error';
  }

  @override
  String get budgetJarDeleted => 'Копилка удалена';

  @override
  String budgetJarDeleteFailed(Object error) {
    return 'Не удалось удалить: $error';
  }

  @override
  String get budgetNoJarsTitle => 'Копилок пока нет';

  @override
  String get budgetNoJarsSubtitle =>
      'Создай первую цель накопления — мы поможем двигаться к ней.';

  @override
  String get budgetSetOrChangeLimit => 'Задать/изменить лимит';

  @override
  String get budgetDeleteCategoryTitle => 'Удалить категорию?';

  @override
  String budgetCategoryLabel(Object name) {
    return 'Категория: $name';
  }

  @override
  String get budgetDeleteJarTitle => 'Удалить копилку?';

  @override
  String budgetJarLabel(Object title) {
    return 'Копилка: $title';
  }

  @override
  String budgetJarSummary(Object saved, Object percent, Object targetPart) {
    return 'Накоплено: $saved ₽ • Процент: $percent%$targetPart';
  }

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonEdit => 'Редактировать';

  @override
  String get commonLoading => 'загрузка…';

  @override
  String get commonSaving => 'Сохранение…';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonUpdate => 'Обновить';

  @override
  String get commonCollapse => 'Свернуть';

  @override
  String get commonDots => '...';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonNext => 'Далее';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonChange => 'Изменить';

  @override
  String get commonDate => 'Дата';

  @override
  String get commonRefresh => 'Обновить';

  @override
  String get commonDash => '—';

  @override
  String get commonPick => 'Выбрать';

  @override
  String get commonRemove => 'Убрать';

  @override
  String get commonOr => 'или';

  @override
  String get commonCreate => 'Создать';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonCloseTooltip => 'Закрыть';

  @override
  String get commonTitle => 'Название';

  @override
  String get commonDeleteConfirmTitle => 'Удалить запись?';

  @override
  String get dayGoalsAllLifeBlocks => 'Все сферы';

  @override
  String get dayGoalsEmpty => 'Целей на этот день нет';

  @override
  String dayGoalsAddFailed(Object error) {
    return 'Не удалось добавить цель: $error';
  }

  @override
  String get dayGoalsUpdated => 'Цель обновлена';

  @override
  String dayGoalsUpdateFailed(Object error) {
    return 'Не удалось обновить цель: $error';
  }

  @override
  String get dayGoalsDeleted => 'Цель удалена';

  @override
  String dayGoalsDeleteFailed(Object error) {
    return 'Не удалось удалить: $error';
  }

  @override
  String dayGoalsToggleFailed(Object error) {
    return 'Не удалось изменить статус: $error';
  }

  @override
  String get dayGoalsDeleteConfirmTitle => 'Удалить цель?';

  @override
  String get dayGoalsFabAddTitle => 'Добавить задачу';

  @override
  String get dayGoalsFabAddSubtitle => 'Создать вручную';

  @override
  String get dayGoalsFabScanTitle => 'Скан';

  @override
  String get dayGoalsFabScanSubtitle => 'Фото ежедневника';

  @override
  String get dayGoalsFabCalendarTitle => 'Google Calendar';

  @override
  String get dayGoalsFabCalendarSubtitle => 'Импорт/экспорт целей за сегодня';

  @override
  String get epicIntroSkip => 'Пропустить';

  @override
  String get epicIntroSubtitle =>
      'Дом для мыслей. Место, где растут цели,\nмечты и планы — бережно и осознанно.';

  @override
  String get epicIntroPrimaryCta => 'Начать мой путь';

  @override
  String get epicIntroLater => 'Позже';

  @override
  String get epicIntroSecondaryCta => 'Войти в аккаунт';

  @override
  String get epicIntroFooter =>
      'Всегда можно вернуться к прологу в настройках.';

  @override
  String get homeMoodSaved => 'Настроение сохранено';

  @override
  String homeMoodSaveFailed(Object error) {
    return 'Не удалось сохранить: $error';
  }

  @override
  String get homeTodayAndWeekTitle => 'Сегодня и неделя';

  @override
  String get homeTodayAndWeekSubtitle =>
      'Короткий обзор — все ключевые метрики здесь';

  @override
  String get homeMetricMoodTitle => 'Настроение';

  @override
  String get homeMoodNoEntry => 'нет записи';

  @override
  String get homeMoodNoNote => 'без заметки';

  @override
  String get homeMoodHasNote => 'есть заметка';

  @override
  String get homeMetricTasksTitle => 'Задачи';

  @override
  String get homeMetricHoursPerDayTitle => 'Часов/день';

  @override
  String get homeMetricEfficiencyTitle => 'Эффективность';

  @override
  String homeEfficiencyPlannedHours(Object hours) {
    return 'план $hoursч';
  }

  @override
  String get homeMoodTodayTitle => 'Настроение сегодня';

  @override
  String get homeMoodNoTodayEntry => 'Записи за сегодня нет';

  @override
  String get homeMoodEntryNoNote => 'Запись есть (без заметки)';

  @override
  String get homeMoodQuickHint => 'Сделай быструю отметку — это 10 секунд';

  @override
  String get homeMoodUpdateHint =>
      'Можно обновить — запись перезапишется за сегодня';

  @override
  String get homeMoodNoteLabel => 'Заметка (необязательно)';

  @override
  String get homeMoodNoteHint => 'Что повлияло на состояние?';

  @override
  String get homeOpenMoodHistoryCta => 'Открыть историю настроений';

  @override
  String get homeWeekSummaryTitle => 'Сводка недели';

  @override
  String get homeOpenReportsCta => 'Открыть подробные отчёты';

  @override
  String get homeWeekExpensesTitle => 'Расходы недели';

  @override
  String get homeNoExpensesThisWeek => 'Нет расходов за неделю';

  @override
  String get homeOpenExpensesCta => 'Открыть расходы';

  @override
  String homeExpensesTotal(Object total) {
    return 'Всего: $total €';
  }

  @override
  String homeExpensesAvgPerDay(Object avg) {
    return 'Средний расход/день: $avg €';
  }

  @override
  String get homeInsightsTitle => 'Инсайты';

  @override
  String homeTopCategory(Object category, Object amount) {
    return '• Топ категория: $category — $amount €';
  }

  @override
  String homePeakExpense(Object day, Object amount) {
    return '• Пик расхода: $day — $amount €';
  }

  @override
  String get homeOpenDetailedExpensesCta => 'Открыть подробные расходы';

  @override
  String get homeWeekCardTitle => 'Неделя';

  @override
  String get homeWeekLoadFailedTitle => 'Не удалось загрузить статистику';

  @override
  String get homeWeekLoadFailedSubtitle =>
      'Проверь интернет или повтори позже.';

  @override
  String get gcalTitle => 'Google Calendar';

  @override
  String get gcalHeaderImport =>
      'Найди события в календаре и импортируй их как цели.';

  @override
  String get gcalHeaderExport =>
      'Выбери период и экспортируй цели из приложения в Google Calendar.';

  @override
  String get gcalModeImport => 'Импорт';

  @override
  String get gcalModeExport => 'Экспорт';

  @override
  String get gcalCalendarLabel => 'Календарь';

  @override
  String get gcalPrimaryCalendar => 'Primary (по умолчанию)';

  @override
  String get gcalPeriodLabel => 'Период';

  @override
  String get gcalRangeToday => 'Сегодня';

  @override
  String get gcalRangeNext7 => 'Следующие 7 дней';

  @override
  String get gcalRangeNext30 => 'Следующие 30 дней';

  @override
  String get gcalRangeCustom => 'Выбрать период...';

  @override
  String get gcalDefaultLifeBlockLabel => 'Сфера по умолчанию (для импорта)';

  @override
  String get gcalLifeBlockForGoalLabel => 'Сфера для этой цели';

  @override
  String get gcalEventsNotLoaded => 'События не загружены';

  @override
  String get gcalConnectToLoadEvents =>
      'Подключи аккаунт, чтобы загрузить события';

  @override
  String get gcalExportHint =>
      'Экспорт создаст события в выбранном календаре за выбранный период.';

  @override
  String get gcalConnect => 'Подключить';

  @override
  String get gcalConnected => 'Подключено';

  @override
  String get gcalFindEvents => 'Найти события';

  @override
  String get gcalImport => 'Импортировать';

  @override
  String get gcalExport => 'Экспортировать';

  @override
  String get gcalNoTitle => 'Без названия';

  @override
  String gcalImportedGoalsCount(Object count) {
    return 'Импортировано целей: $count';
  }

  @override
  String gcalExportedGoalsCount(Object count) {
    return 'Экспортировано целей: $count';
  }

  @override
  String get launcherQuickFunctionsTitle => 'Быстрые функции';

  @override
  String get launcherQuickFunctionsSubtitle =>
      'Навигация и действия в один тап';

  @override
  String get launcherSectionsTitle => 'Разделы';

  @override
  String get launcherQuickTitle => 'Быстро';

  @override
  String get launcherHome => 'Главная';

  @override
  String get launcherGoals => 'Задачи';

  @override
  String get launcherMood => 'Задачи';

  @override
  String get launcherProfile => 'Профиль';

  @override
  String get launcherInsights => 'Отчеты';

  @override
  String get launcherReports => 'Бюджет';

  @override
  String get launcherMassAddTitle => 'Массовое добавление за день';

  @override
  String get launcherMassAddSubtitle => 'Расходы + Задачи + Настроение';

  @override
  String get launcherAiPlanTitle => 'AI-план на неделю/месяц';

  @override
  String get launcherAiPlanSubtitle => 'Анализ целей, опроса и прогресса';

  @override
  String get launcherAiInsightsTitle => 'AI-инсайты';

  @override
  String get launcherAiInsightsSubtitle =>
      'Как события влияют на цели и прогресс';

  @override
  String get launcherRecurringGoalTitle => 'Регулярная цель';

  @override
  String get launcherRecurringGoalSubtitle =>
      'Планирование на несколько дней вперёд';

  @override
  String get launcherGoogleCalendarSyncTitle =>
      'Синхронизация с Google Calendar';

  @override
  String get launcherGoogleCalendarSyncSubtitle => 'Экспорт целей в календарь';

  @override
  String get launcherNoDatesToCreate =>
      'Нет дат для создания (проверь дедлайн/настройки).';

  @override
  String launcherCreateSeriesFailed(Object error) {
    return 'Не удалось создать серию целей: $error';
  }

  @override
  String launcherSaveError(Object error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String launcherCreatedGoalsCount(Object count) {
    return 'Создано целей: $count';
  }

  @override
  String launcherSavedSummary(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodPart,
  ) {
    return 'Сохранено: $expenses расход(ов), $incomes доход(ов), $goals задач(и), $habits привыч(ек)$moodPart';
  }

  @override
  String get homeTitleHome => 'Главная';

  @override
  String get homeTitleGoals => 'Задачи';

  @override
  String get homeTitleMood => 'Цели';

  @override
  String get homeTitleProfile => 'Профиль';

  @override
  String get homeTitleReports => 'Отчёты';

  @override
  String get homeTitleExpenses => 'Расходы';

  @override
  String get homeTitleApp => 'Ladna';

  @override
  String get homeSignOutTooltip => 'Выйти из аккаунта';

  @override
  String get homeSignOutTitle => 'Выйти из аккаунта?';

  @override
  String get homeSignOutSubtitle => 'Текущая сессия будет завершена.';

  @override
  String get homeSignOutConfirm => 'Выйти';

  @override
  String homeSignOutFailed(Object error) {
    return 'Не удалось выйти: $error';
  }

  @override
  String get homeQuickActionsTooltip => 'Быстрые действия';

  @override
  String get expensesTitle => 'Расходы';

  @override
  String get expensesPickDate => 'Выбрать дату';

  @override
  String get expensesCommitTooltip => 'Зафиксировать распределение по копилкам';

  @override
  String get expensesCommitUndoTooltip => 'Отменить фиксацию';

  @override
  String get expensesBudgetSettings => 'Настройки копилок и категорий';

  @override
  String get expensesCommitDone => 'Распределение зафиксировано';

  @override
  String get expensesCommitUndone => 'Фиксация отменена';

  @override
  String get expensesMonthSummary => 'Сводка месяца';

  @override
  String expensesIncomeLegend(Object value) {
    return 'Доходы $value €';
  }

  @override
  String expensesExpenseLegend(Object value) {
    return 'Расходы $value €';
  }

  @override
  String expensesFreeLegend(Object value) {
    return 'Свободно $value €';
  }

  @override
  String expensesDaySum(Object value) {
    return 'Сумма за день: $value €';
  }

  @override
  String get expensesNoTxForDay => 'Нет операций за этот день';

  @override
  String get expensesDeleteTxTitle => 'Удалить операцию?';

  @override
  String expensesDeleteTxBody(Object category, Object amount) {
    return '$category — $amount €';
  }

  @override
  String get expensesCategoriesMonthTitle => 'Категории расходов за месяц';

  @override
  String get expensesNoCategoryData => 'Пока нет данных по категориям';

  @override
  String get expensesJarsTitle => 'Копилки';

  @override
  String get expensesNoJars => 'Копилок пока нет';

  @override
  String get expensesCommitShort => 'Зафиксировать';

  @override
  String get expensesCommitUndoShort => 'Отменить фиксацию';

  @override
  String get expensesAddIncome => 'Добавить доход';

  @override
  String get expensesAddExpense => 'Добавить расход';

  @override
  String get loginTitle => 'Войдите в аккаунт';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Пароль';

  @override
  String get loginShowPassword => 'Показать пароль';

  @override
  String get loginHidePassword => 'Скрыть пароль';

  @override
  String get loginForgotPassword => 'Забыли пароль?';

  @override
  String get loginCreateAccount => 'Создать аккаунт';

  @override
  String get loginBtnSignIn => 'Войти';

  @override
  String get loginContinueGoogle => 'Продолжить с Google';

  @override
  String get loginContinueApple => 'Продолжить с Apple ID';

  @override
  String get loginErrEmailRequired => 'Введите email';

  @override
  String get loginErrEmailInvalid => 'Некорректный email';

  @override
  String get loginErrPassRequired => 'Введите пароль';

  @override
  String get loginErrPassMin6 => 'Минимум 6 символов';

  @override
  String get loginResetTitle => 'Восстановление пароля';

  @override
  String get loginResetSend => 'Отправить';

  @override
  String get loginResetSent =>
      'Письмо для смены пароля отправлено. Проверьте почту.';

  @override
  String loginResetFailed(Object error) {
    return 'Не удалось отправить письмо: $error';
  }

  @override
  String get moodTitle => 'Настроение';

  @override
  String get moodOnePerDay => '1 запись = 1 день';

  @override
  String get moodHowDoYouFeel => 'Как ты себя чувствуешь?';

  @override
  String get moodNoteLabel => 'Заметка (необязательно)';

  @override
  String get moodNoteHint => 'Что повлияло на твоё состояние?';

  @override
  String get moodSaved => 'Настроение сохранено';

  @override
  String get moodUpdated => 'Запись обновлена';

  @override
  String get moodHistoryTitle => 'История настроений';

  @override
  String get moodTapToEdit => 'Нажми, чтобы редактировать';

  @override
  String get moodNoNote => 'Без заметки';

  @override
  String get moodEditTitle => 'Редактировать запись';

  @override
  String get moodEmptyTitle => 'Пока нет записей';

  @override
  String get moodEmptySubtitle =>
      'Выбери дату, отметь настроение и сохрани запись.';

  @override
  String moodErrSaveFailed(Object error) {
    return 'Не удалось сохранить настроение: $error';
  }

  @override
  String moodErrUpdateFailed(Object error) {
    return 'Не удалось обновить запись: $error';
  }

  @override
  String moodErrDeleteFailed(Object error) {
    return 'Не удалось удалить запись: $error';
  }

  @override
  String get onbTopTitle => '';

  @override
  String get onbErrSaveFailed => 'Не удалось сохранить ответы';

  @override
  String get onbProfileTitle => 'Давай познакомимся';

  @override
  String get onbProfileSubtitle => 'Это нужно для профиля и персонализации';

  @override
  String get onbNameLabel => 'Имя';

  @override
  String get onbNameHint => 'Например: Виктор';

  @override
  String get onbAgeLabel => 'Возраст';

  @override
  String get onbAgeHint => 'Например: 26';

  @override
  String get onbNameNote => 'Имя можно менять позже в профиле.';

  @override
  String get onbBlocksTitle => 'Какие сферы жизни ты хочешь отслеживать?';

  @override
  String get onbBlocksSubtitle => 'Это станет основой твоих целей и квестов';

  @override
  String get onbPrioritiesTitle =>
      'Что для тебя важнее всего ближайшие 3–6 месяцев?';

  @override
  String get onbPrioritiesSubtitle =>
      'Выбери до трёх — это влияет на рекомендации';

  @override
  String get onbPriorityHealth => 'Здоровье';

  @override
  String get onbPriorityCareer => 'Карьера';

  @override
  String get onbPriorityMoney => 'Деньги';

  @override
  String get onbPriorityFamily => 'Дом и быт';

  @override
  String get onbPriorityGrowth => 'Развитие';

  @override
  String get onbPriorityLove => 'Любовь';

  @override
  String get onbPriorityCreativity => 'Творчество';

  @override
  String get onbPriorityBalance => 'Баланс';

  @override
  String onbGoalsBlockTitle(Object block) {
    return 'Цели в сфере «$block»';
  }

  @override
  String get onbGoalsBlockSubtitle =>
      'Фокус: тактика → средний срок → долгий срок';

  @override
  String get onbGoalLongLabel => 'Долгосрочная цель (6–24 месяца)';

  @override
  String get onbGoalLongHint => 'Например: выучить немецкий до уровня B2';

  @override
  String get onbGoalMidLabel => 'Среднесрочная цель (2–6 месяцев)';

  @override
  String get onbGoalMidHint => 'Например: пройти курс A2→B1 и сдать экзамен';

  @override
  String get onbGoalTacticalLabel => 'Тактическая цель (2–4 недели)';

  @override
  String get onbGoalTacticalHint =>
      'Например: 12 занятий по 30 минут + 2 разговорных клуба';

  @override
  String get onbWhyLabel => 'Почему это важно? (опционально)';

  @override
  String get onbWhyHint => 'Мотивация/смысл — поможет удерживать курс';

  @override
  String get onbOptionalNote => 'Можно оставить пустым и нажать «Далее».';

  @override
  String get registerTitle => 'Создайте аккаунт';

  @override
  String get registerNameLabel => 'Имя';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Пароль';

  @override
  String get registerConfirmPasswordLabel => 'Подтвердите пароль';

  @override
  String get registerShowPassword => 'Показать пароль';

  @override
  String get registerHidePassword => 'Скрыть пароль';

  @override
  String get registerBtnSignUp => 'Зарегистрироваться';

  @override
  String get registerContinueGoogle => 'Продолжить с Google';

  @override
  String get registerContinueApple => 'Продолжить с Apple ID';

  @override
  String get registerContinueAppleIos => 'Продолжить с Apple ID (iOS)';

  @override
  String get registerHaveAccountCta => 'Уже есть аккаунт? Войти';

  @override
  String get registerErrNameRequired => 'Введите имя';

  @override
  String get registerErrEmailRequired => 'Введите email';

  @override
  String get registerErrEmailInvalid => 'Некорректный email';

  @override
  String get registerErrPassRequired => 'Введите пароль';

  @override
  String get registerErrPassMin8 => 'Минимум 8 символов';

  @override
  String get registerErrPassNeedLower => 'Добавьте строчную букву (a-z)';

  @override
  String get registerErrPassNeedUpper => 'Добавьте заглавную букву (A-Z)';

  @override
  String get registerErrPassNeedDigit => 'Добавьте цифру (0-9)';

  @override
  String get registerErrConfirmRequired => 'Повторите пароль';

  @override
  String get registerErrPasswordsMismatch => 'Пароли не совпадают';

  @override
  String get registerErrAcceptTerms => 'Нужно принять Условия и Privacy Policy';

  @override
  String get registerAppleOnlyIos => 'Apple ID доступен на iPhone/iPad (iOS)';

  @override
  String get welcomeAppName => 'VitaPlatform';

  @override
  String get welcomeSubtitle =>
      'Управляй целями, настроением и временем\n— всё в одном месте';

  @override
  String get welcomeSignIn => 'Войти';

  @override
  String get welcomeCreateAccount => 'Создать аккаунт';

  @override
  String get habitsWeekTitle => 'Привычки';

  @override
  String get habitsWeekTopTitle => 'Привычки (топ недели)';

  @override
  String get habitsWeekEmptyHint =>
      'Добавь хотя бы одну привычку — и тут появится прогресс.';

  @override
  String get habitsWeekFooterHint =>
      'Показываем самые активные привычки за 7 дней.';

  @override
  String get mentalWeekTitle => 'Ментальное здоровье';

  @override
  String mentalWeekLoadError(Object error) {
    return 'Ошибка загрузки: $error';
  }

  @override
  String get mentalWeekNoAnswers => 'За эту неделю нет найденных ответов';

  @override
  String get mentalWeekYesNoHeader => 'Да/Нет (неделя)';

  @override
  String get mentalWeekScalesHeader => 'Шкалы (тренд)';

  @override
  String get mentalWeekFooterHint =>
      'Показываем только несколько вопросов, чтобы не перегружать экран.';

  @override
  String get mentalWeekNoData => 'Нет данных';

  @override
  String mentalWeekYesCount(Object yes, Object total) {
    return 'Да: $yes/$total';
  }

  @override
  String get moodWeekTitle => 'Состояние недели';

  @override
  String moodWeekMarkedCount(Object filled, Object total) {
    return 'Отмечено: $filled/$total';
  }

  @override
  String get moodWeekAverageDash => 'Среднее: —';

  @override
  String moodWeekAverageValue(Object avg) {
    return 'Среднее: $avg/5';
  }

  @override
  String get moodWeekFooterHint =>
      'Это быстрый обзор. Детали ниже — в истории.';

  @override
  String get goalsByBlockTitle => 'Цели по сферам';

  @override
  String get goalsAddTooltip => 'Добавить цель';

  @override
  String get goalsHorizonTacticalShort => 'Тактика';

  @override
  String get goalsHorizonMidShort => 'Средние';

  @override
  String get goalsHorizonLongShort => 'Долгие';

  @override
  String get goalsHorizonTacticalLong => '2–6 недель';

  @override
  String get goalsHorizonMidLong => '3–6 месяцев';

  @override
  String get goalsHorizonLongLong => '1+ год';

  @override
  String get goalsEditorNewTitle => 'Новая цель';

  @override
  String get goalsEditorEditTitle => 'Редактировать цель';

  @override
  String get goalsEditorLifeBlockLabel => 'Сфера';

  @override
  String get goalsEditorHorizonLabel => 'Горизонт';

  @override
  String get goalsEditorTitleLabel => 'Название';

  @override
  String get goalsEditorTitleHint => 'Например: Подтянуть английский до B2';

  @override
  String get goalsEditorDescLabel => 'Описание (опционально)';

  @override
  String get goalsEditorDescHint =>
      'Коротко: что именно и как измерим результат';

  @override
  String goalsEditorDeadlineLabel(Object date) {
    return 'Дедлайн: $date';
  }

  @override
  String goalsDeadlineInline(Object date) {
    return 'Дедлайн: $date';
  }

  @override
  String get goalsEmptyAllHint =>
      'Пока нет целей. Добавь первую цель для выбранных сфер.';

  @override
  String get goalsNoBlocksToShow => 'Нет доступных сфер для отображения.';

  @override
  String get goalsNoGoalsForBlock => 'Нет целей для выбранной сферы.';

  @override
  String get goalsDeleteConfirmTitle => 'Удалить цель?';

  @override
  String goalsDeleteConfirmBody(Object title) {
    return '«$title» будет удалена без возможности восстановления.';
  }

  @override
  String get habitsTitle => 'Привычки';

  @override
  String get habitsEmptyHint => 'Пока нет привычек. Добавь первую.';

  @override
  String get habitsEditorNewTitle => 'Новая привычка';

  @override
  String get habitsEditorEditTitle => 'Редактировать привычку';

  @override
  String get habitsEditorTitleLabel => 'Название';

  @override
  String get habitsEditorTitleHint => 'Например: Утренняя зарядка';

  @override
  String get habitsNegativeLabel => 'Негативная привычка';

  @override
  String get habitsNegativeHint =>
      'Отмечай, если хочешь отслеживать и сокращать.';

  @override
  String get habitsPositiveHint =>
      'Позитивная/нейтральная привычка для укрепления.';

  @override
  String get habitsNegativeShort => 'Негативная';

  @override
  String get habitsPositiveShort => 'Позитивная/нейтральная';

  @override
  String get habitsDeleteConfirmTitle => 'Удалить привычку?';

  @override
  String habitsDeleteConfirmBody(Object title) {
    return '«$title» будет удалена без возможности восстановления.';
  }

  @override
  String get habitsFooterHint =>
      'Позже добавим “отсеивание” привычек на главном экране.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileNameLabel => 'Имя';

  @override
  String get profileNameTitle => 'Имя';

  @override
  String get profileNamePrompt => 'Как тебя называть?';

  @override
  String get profileAgeLabel => 'Возраст';

  @override
  String get profileAgeTitle => 'Возраст';

  @override
  String get profileAgePrompt => 'Введите возраст';

  @override
  String get profileAccountSection => 'Аккаунт';

  @override
  String get profileSeenPrologueTitle => 'Пролог пройден';

  @override
  String get profileSeenPrologueSubtitle => 'Можно изменить вручную';

  @override
  String get profileFocusSection => 'Фокус';

  @override
  String get profileTargetHoursLabel => 'Целевая норма часов/день';

  @override
  String profileTargetHoursValue(Object hours) {
    return '$hours ч';
  }

  @override
  String get profileTargetHoursTitle => 'Цель по часам в день';

  @override
  String get profileTargetHoursFieldLabel => 'Часы';

  @override
  String get profileQuestionnaireSection => 'Опросник и сферы жизни';

  @override
  String get profileQuestionnaireNotDoneTitle => 'Вы ещё не прошли опросник.';

  @override
  String get profileQuestionnaireCta => 'Пройти сейчас';

  @override
  String get profileLifeBlocksTitle => 'Сферы жизни';

  @override
  String get profileLifeBlocksHint => 'Например: здоровье, карьера, семья';

  @override
  String get profilePrioritiesTitle => 'Приоритеты';

  @override
  String get profilePrioritiesHint => 'Например: спорт, финансы, чтение';

  @override
  String get profileDangerZoneTitle => 'Опасная зона';

  @override
  String get profileDeleteAccountTitle => 'Удалить аккаунт?';

  @override
  String get profileDeleteAccountBody =>
      'Это действие необратимо.\nБудут удалены: цели, привычки, настроение, расходы/доходы, банки, AI-планы, XP и профиль.';

  @override
  String get profileDeleteAccountConfirm => 'Удалить навсегда';

  @override
  String get profileDeleteAccountCta => 'Удалить аккаунт и все данные';

  @override
  String get profileDeletingAccount => 'Удаляем...';

  @override
  String get profileDeleteAccountFootnote =>
      'Удаление необратимо. Данные будут полностью удалены из Supabase.';

  @override
  String get profileAccountDeletedToast => 'Аккаунт удалён';

  @override
  String get lifeBlockHealth => 'Здоровье';

  @override
  String get lifeBlockCareer => 'Карьера';

  @override
  String get lifeBlockFamily => 'Дом и быт';

  @override
  String get lifeBlockFinance => 'Финансы';

  @override
  String get lifeBlockLearning => 'Развитие';

  @override
  String get lifeBlockSocial => 'Социальное';

  @override
  String get lifeBlockRest => 'Отдых';

  @override
  String get lifeBlockBalance => 'Баланс';

  @override
  String get lifeBlockLove => 'Любовь';

  @override
  String get lifeBlockCreativity => 'Творчество';

  @override
  String get lifeBlockGeneral => 'Общее';

  @override
  String get addDayGoalTitle => 'Новая цель на день';

  @override
  String get addDayGoalFieldTitle => 'Название *';

  @override
  String get addDayGoalTitleHint => 'Например: Тренировка / Работа / Учёба';

  @override
  String get addDayGoalFieldDescription => 'Описание';

  @override
  String get addDayGoalDescriptionHint => 'Коротко: что именно нужно сделать';

  @override
  String get addDayGoalStartTime => 'Время начала';

  @override
  String get addDayGoalLifeBlock => 'Сфера жизни';

  @override
  String get addDayGoalImportance => 'Важность';

  @override
  String get addDayGoalEmotion => 'Эмоция';

  @override
  String get addDayGoalHours => 'Часы';

  @override
  String get addDayGoalEnterTitle => 'Введите название';

  @override
  String get addExpenseNewTitle => 'Новый расход';

  @override
  String get addExpenseEditTitle => 'Редактировать расход';

  @override
  String get addExpenseAmountLabel => 'Сумма';

  @override
  String get addExpenseAmountInvalid => 'Введите корректную сумму';

  @override
  String get addExpenseCategoryLabel => 'Категория';

  @override
  String get addExpenseCategoryRequired => 'Выберите категорию';

  @override
  String get addExpenseCreateCategoryTooltip => 'Создать категорию';

  @override
  String get addExpenseNoteLabel => 'Комментарий';

  @override
  String get addExpenseNewCategoryTitle => 'Новая категория';

  @override
  String get addExpenseCategoryNameLabel => 'Название';

  @override
  String get addIncomeNewTitle => 'Новый доход';

  @override
  String get addIncomeEditTitle => 'Редактировать доход';

  @override
  String get addIncomeSubtitle => 'Сумма, категория и комментарий';

  @override
  String get addIncomeAmountLabel => 'Сумма';

  @override
  String get addIncomeAmountHint => 'Например: 1200.50';

  @override
  String get addIncomeAmountInvalid => 'Введите корректную сумму';

  @override
  String get addIncomeCategoryLabel => 'Категория';

  @override
  String get addIncomeCategoryRequired => 'Выберите категорию';

  @override
  String get addIncomeNoteLabel => 'Комментарий';

  @override
  String get addIncomeNoteHint => 'Опционально';

  @override
  String get addIncomeNewCategoryTitle => 'Новая категория дохода';

  @override
  String get addIncomeCategoryNameLabel => 'Название категории';

  @override
  String get addIncomeCategoryNameHint => 'Например: Зарплата, Фриланс…';

  @override
  String get addIncomeCategoryNameEmpty => 'Введите название категории';

  @override
  String get addJarNewTitle => 'Новая копилка';

  @override
  String get addJarEditTitle => 'Редактировать копилку';

  @override
  String get addJarSubtitle => 'Настрой сумму и долю от свободных денег';

  @override
  String get addJarNameLabel => 'Название';

  @override
  String get addJarNameHint => 'Например: Поездка, Подушка, Дом';

  @override
  String get addJarNameRequired => 'Укажите название';

  @override
  String get addJarPercentLabel => 'Процент от свободных, %';

  @override
  String get addJarPercentHint => '0 — если вручную пополняешь';

  @override
  String get addJarPercentRange => 'Процент должен быть от 0 до 100';

  @override
  String get addJarTargetLabel => 'Целевая сумма';

  @override
  String get addJarTargetHint => 'Например: 5000';

  @override
  String get addJarTargetHelper => 'Обязательно';

  @override
  String get addJarTargetRequired => 'Укажите цель (положительное число)';

  @override
  String get aiInsightTypeDataQuality => 'Качество данных';

  @override
  String get aiInsightTypeRisk => 'Риск';

  @override
  String get aiInsightTypeEmotional => 'Эмоции';

  @override
  String get aiInsightTypeHabit => 'Привычки';

  @override
  String get aiInsightTypeGoal => 'Цели';

  @override
  String get aiInsightTypeDefault => 'Инсайт';

  @override
  String get aiInsightStrengthStrong => 'Сильное влияние';

  @override
  String get aiInsightStrengthNoticeable => 'Заметное влияние';

  @override
  String get aiInsightStrengthWeak => 'Слабое влияние';

  @override
  String get aiInsightStrengthLowConfidence => 'Низкая уверенность';

  @override
  String aiInsightStrengthPercent(int value) {
    return '$value%';
  }

  @override
  String get aiInsightEvidenceTitle => 'Доказательства';

  @override
  String get aiInsightImpactPositive => 'Позитив';

  @override
  String get aiInsightImpactNegative => 'Негатив';

  @override
  String get aiInsightImpactMixed => 'Смешано';

  @override
  String get aiInsightsTitle => 'AI-инсайты';

  @override
  String get aiInsightsConfirmTitle => 'Запустить AI-анализ?';

  @override
  String get aiInsightsConfirmBody =>
      'AI проанализирует задачи, привычки и самочувствие за выбранный период и сохранит инсайты. Это может занять несколько секунд.';

  @override
  String get aiInsightsConfirmRun => 'Запустить';

  @override
  String get aiInsightsPeriod7 => '7 дней';

  @override
  String get aiInsightsPeriod30 => '30 дней';

  @override
  String get aiInsightsPeriod90 => '90 дней';

  @override
  String aiInsightsLastRun(String date) {
    return 'Последний запуск: $date';
  }

  @override
  String get aiInsightsEmptyNotRunTitle => 'AI ещё не запускался';

  @override
  String get aiInsightsEmptyNotRunSubtitle =>
      'Выбери период и нажми «Запустить». Инсайты сохранятся и будут доступны в приложении.';

  @override
  String get aiInsightsCtaRun => 'Запустить анализ';

  @override
  String get aiInsightsEmptyNoInsightsTitle => 'Инсайтов пока нет';

  @override
  String get aiInsightsEmptyNoInsightsSubtitle =>
      'Добавь больше данных (задачи, привычки, ответы на вопросы) и запусти анализ.';

  @override
  String get aiInsightsCtaRunAgain => 'Запустить снова';

  @override
  String aiInsightsErrorAi(String error) {
    return 'Ошибка AI: $error';
  }

  @override
  String get gcTitleDaySync => 'Google Calendar • синхронизация за день';

  @override
  String get gcSubtitleImport => 'Импортируй события этого дня в цели.';

  @override
  String get gcSubtitleExport => 'Экспортируй цели этого дня в календарь.';

  @override
  String get gcModeImport => 'Импорт';

  @override
  String get gcModeExport => 'Экспорт';

  @override
  String get gcCalendarLabel => 'Календарь';

  @override
  String get gcCalendarPrimary => 'Primary (по умолчанию)';

  @override
  String get gcDefaultLifeBlockLabel => 'Сфера по умолчанию (для импорта)';

  @override
  String get gcLifeBlockForThisGoalLabel => 'Сфера для этой цели';

  @override
  String get gcEventsNotLoaded => 'События не загружены';

  @override
  String get gcConnectToLoadEvents =>
      'Подключи аккаунт, чтобы загрузить события';

  @override
  String get gcExportHint =>
      'Экспорт создаст события в выбранном календаре для целей этого дня.';

  @override
  String get gcConnect => 'Подключить';

  @override
  String get gcConnected => 'Подключено';

  @override
  String get gcFindForDay => 'Найти за день';

  @override
  String get gcImport => 'Импорт';

  @override
  String get gcExport => 'Экспорт';

  @override
  String get gcNoTitle => 'Без названия';

  @override
  String get gcLoadingDots => '...';

  @override
  String gcImportedGoals(int count) {
    return 'Импортировано целей: $count';
  }

  @override
  String gcExportedGoals(int count) {
    return 'Экспортировано целей: $count';
  }

  @override
  String get editGoalTitle => 'Редактировать цель';

  @override
  String get editGoalSectionDetails => 'Детали';

  @override
  String get editGoalSectionLifeBlock => 'Сфера';

  @override
  String get editGoalSectionParams => 'Параметры';

  @override
  String get editGoalFieldTitleLabel => 'Название';

  @override
  String get editGoalFieldTitleHint => 'Например: Пробежка 3 км';

  @override
  String get editGoalFieldDescLabel => 'Описание';

  @override
  String get editGoalFieldDescHint => 'Что именно нужно сделать?';

  @override
  String get editGoalFieldLifeBlockLabel => 'Сфера жизни';

  @override
  String get editGoalFieldImportanceLabel => 'Важность';

  @override
  String get editGoalImportanceLow => 'Низкая';

  @override
  String get editGoalImportanceMedium => 'Средняя';

  @override
  String get editGoalImportanceHigh => 'Высокая';

  @override
  String get editGoalFieldEmotionLabel => 'Эмоция';

  @override
  String get editGoalFieldEmotionHint => '😊';

  @override
  String get editGoalDurationHours => 'Длительность (ч)';

  @override
  String get editGoalStartTime => 'Начало';

  @override
  String get editGoalUntitled => 'Без названия';

  @override
  String get expenseCategoryOther => 'Прочее';

  @override
  String get goalStatusDone => 'Готово';

  @override
  String get goalStatusInProgress => 'В процессе';

  @override
  String get actionDelete => 'Удалить';

  @override
  String goalImportanceChip(int value) {
    return 'Важность $value/5';
  }

  @override
  String goalHoursChip(String value) {
    return 'Часы $value';
  }

  @override
  String get goalPathEmpty => 'Нет целей в пути';

  @override
  String get timelineActionEdit => 'Редактировать';

  @override
  String get timelineActionDelete => 'Удалить';

  @override
  String get saveBarSaving => 'Сохранение…';

  @override
  String get saveBarSave => 'Сохранить';

  @override
  String get reportEmptyChartNotEnoughData => 'Недостаточно данных';

  @override
  String limitSheetTitle(String categoryName) {
    return 'Лимит для «$categoryName»';
  }

  @override
  String get limitSheetHintNoLimit => 'Пусто — без лимита';

  @override
  String get limitSheetFieldLabel => 'Максимум ₽ в месяц';

  @override
  String get limitSheetFieldHint => 'Например: 15000';

  @override
  String get limitSheetCtaNoLimit => 'Без лимита';

  @override
  String get profileWebNotificationsSection => 'Уведомления (Web)';

  @override
  String get profileWebNotificationsPermissionTitle => 'Разрешить уведомления';

  @override
  String get profileWebNotificationsPermissionSubtitle =>
      'Работает в Web и только пока вкладка открыта.';

  @override
  String get profileWebNotificationsEveningTitle => 'Вечерний чек-ин';

  @override
  String profileWebNotificationsEveningSubtitle(Object time) {
    return 'Каждый день в $time';
  }

  @override
  String get profileWebNotificationsChangeTime => 'Изменить время';

  @override
  String get profileWebNotificationsUnsupported =>
      'Браузерные уведомления недоступны в этой сборке. Они работают только в Web-версии (и только пока вкладка открыта).';

  @override
  String get lifeBlockEducation => 'Образование';

  @override
  String get lifeBlockHobbies => 'Хобби';

  @override
  String get userGoalsTitle => 'Мои цели';

  @override
  String get userGoalsSubtitle =>
      'Стратегические цели по сферам жизни: краткосрочные, среднесрочные и долгосрочные.';

  @override
  String get userGoalsNewTitle => 'Новая цель';

  @override
  String get userGoalsEditTitle => 'Редактировать цель';

  @override
  String get userGoalsCreateGoal => 'Создать цель';

  @override
  String get userGoalsCreated => 'Цель создана';

  @override
  String userGoalsCreateError(Object error) {
    return 'Ошибка создания цели: $error';
  }

  @override
  String get userGoalsUpdated => 'Цель обновлена';

  @override
  String userGoalsUpdateError(Object error) {
    return 'Ошибка обновления цели: $error';
  }

  @override
  String userGoalsStatusChangeError(Object error) {
    return 'Ошибка изменения статуса: $error';
  }

  @override
  String userGoalsDeleteError(Object error) {
    return 'Ошибка удаления: $error';
  }

  @override
  String get userGoalsDeleteConfirmTitle => 'Удалить цель?';

  @override
  String get userGoalsAllBlocks => 'Все';

  @override
  String get userGoalsAllHorizons => 'Все горизонты';

  @override
  String get userGoalsLoadErrorTitle => 'Ошибка загрузки';

  @override
  String get userGoalsNoActiveBlocksTitle => 'Нет активных сфер жизни';

  @override
  String get userGoalsNoActiveBlocksSubtitle =>
      'Сначала настрой блоки, которые пользователь отслеживает.';

  @override
  String get userGoalsEmptyTitle => 'Пока нет целей';

  @override
  String get userGoalsEmptySubtitle =>
      'Создай первую стратегическую цель для одной из сфер жизни.';

  @override
  String userGoalsDeadline(Object date) {
    return 'Дедлайн: $date';
  }

  @override
  String get userGoalsStatusCompleted => 'Выполнено';

  @override
  String get userGoalsStatusActive => 'Активно';

  @override
  String get userGoalsReopen => 'Вернуть';

  @override
  String get userGoalsComplete => 'Завершить';

  @override
  String get userGoalsFieldLifeBlock => 'Сфера жизни';

  @override
  String get userGoalsFieldHorizon => 'Горизонт';

  @override
  String get userGoalsFieldTitle => 'Название цели';

  @override
  String get userGoalsFieldDescription => 'Описание';

  @override
  String get userGoalsPickTargetDate => 'Выбрать дату цели';

  @override
  String get userGoalsClearDate => 'Очистить дату';

  @override
  String get monthJanuary => 'Январь';

  @override
  String get monthFebruary => 'Февраль';

  @override
  String get monthMarch => 'Март';

  @override
  String get monthApril => 'Апрель';

  @override
  String get monthMay => 'Май';

  @override
  String get monthJune => 'Июнь';

  @override
  String get monthJuly => 'Июль';

  @override
  String get monthAugust => 'Август';

  @override
  String get monthSeptember => 'Сентябрь';

  @override
  String get monthOctober => 'Октябрь';

  @override
  String get monthNovember => 'Ноябрь';

  @override
  String get monthDecember => 'Декабрь';

  @override
  String get weekdayMonShort => 'Пн';

  @override
  String get weekdayTueShort => 'Вт';

  @override
  String get weekdayWedShort => 'Ср';

  @override
  String get weekdayThuShort => 'Чт';

  @override
  String get weekdayFriShort => 'Пт';

  @override
  String get weekdaySatShort => 'Сб';

  @override
  String get weekdaySunShort => 'Вс';

  @override
  String get lifeBlockRelations => 'Отношения';

  @override
  String get lifeBlockSpirituality => 'Духовность';

  @override
  String goalsHeaderWeek(Object month, Object year, Object week) {
    return '$month $year, неделя $week';
  }

  @override
  String get goalsQuickActionsTitle => 'Быстрые функции';

  @override
  String get goalsQuickActionsSubtitle =>
      'Добавление и планирование в один тап';

  @override
  String get goalsMassAddTitle => 'Массовое добавление за день';

  @override
  String get goalsMassAddSubtitle =>
      'Расходы + Доходы + Задачи + Настроение + Привычки';

  @override
  String goalsMassAddSaved(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodSuffix,
  ) {
    return 'Сохранено: $expenses расход(ов), $incomes доход(ов), $goals задач(и), $habits привыч(ек)$moodSuffix';
  }

  @override
  String get goalsMassAddMoodSuffix => ', настроение';

  @override
  String goalsSaveError(Object error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String get goalsRecurringGoalTitle => 'Регулярная цель';

  @override
  String get goalsRecurringGoalSubtitle =>
      'Планирование на несколько дней вперёд';

  @override
  String get goalsRecurringNoDates =>
      'Нет дат для создания (проверь дедлайн/настройки).';

  @override
  String goalsPlanHoursDescription(Object hours) {
    return 'План: $hours ч';
  }

  @override
  String goalsCreatedCount(Object count) {
    return 'Создано целей: $count';
  }

  @override
  String goalsRecurringCreateError(Object error) {
    return 'Не удалось создать серию целей: $error';
  }

  @override
  String get goalsSimpleTaskTitle => 'Простое добавление задачи';

  @override
  String get goalsSimpleTaskSubtitle =>
      'Только название, время опционально, категория General';

  @override
  String get goalsSimpleTaskSheetSubtitle =>
      'Только название, время опционально. Категория по умолчанию — General.';

  @override
  String get goalsTaskCreated => 'Задача создана';

  @override
  String goalsTaskCreateError(Object error) {
    return 'Ошибка создания задачи: $error';
  }

  @override
  String get goalsAll => 'Все';

  @override
  String get goalsViewDashboard => 'Дашборд';

  @override
  String get goalsViewCalendar => 'Календарь';

  @override
  String get goalsViewWeek => 'Неделя';

  @override
  String get goalsViewMonth => 'Месяц';

  @override
  String get goalsByBlocksTitle => 'Цели по сферам';

  @override
  String get goalsShow => 'Показать';

  @override
  String get goalsByBlocksHiddenHint => 'Скрыто. Нажми 👁 чтобы показать.';

  @override
  String get goalsEnterTaskTitle => 'Введите название задачи';

  @override
  String get goalsTaskTitleLabel => 'Название задачи';

  @override
  String get goalsAddTime => 'Добавить время';

  @override
  String goalsTimeValue(Object time) {
    return 'Время: $time';
  }

  @override
  String get goalsRemoveTime => 'Убрать время';

  @override
  String get goalsCreateTask => 'Создать задачу';

  @override
  String get goalsWeekSummaryTitle => 'Итог недели';

  @override
  String goalsHoursShort(Object hours) {
    return '$hours ч';
  }

  @override
  String goalsHoursTargetSuffix(Object hours) {
    return ' / $hours ч';
  }

  @override
  String goalsHoursShortNoSpace(Object hours) {
    return '$hoursч';
  }

  @override
  String goalsHoursTargetSuffixNoSpace(Object hours) {
    return ' / $hoursч';
  }

  @override
  String get dayGoalsHiddenCompletedEmpty =>
      'Все видимые цели скрыты. Отключи фильтр «Скрыть выполненные».';

  @override
  String get dayGoalsKanbanOpenShort => 'Ост.';

  @override
  String get dayGoalsKanbanDoneShort => 'Гот.';

  @override
  String get dayGoalsKanbanOpenTitle => 'В работе';

  @override
  String get dayGoalsKanbanDoneTitle => 'Готово';

  @override
  String get dayGoalsKanbanOpenEmpty => 'Нет активных задач';

  @override
  String get dayGoalsKanbanDoneEmpty => 'Пока пусто';

  @override
  String dayGoalsHoursShort(Object hours) {
    return '$hours ч';
  }

  @override
  String get dayGoalsSectionMorning => 'Утро';

  @override
  String get dayGoalsSectionDay => 'День';

  @override
  String get dayGoalsSectionEvening => 'Вечер';

  @override
  String get dayGoalsSummaryTitle => 'Сводка дня';

  @override
  String get dayGoalsSummarySubtitle =>
      'Держи фокус на главном и не перегружай день.';

  @override
  String get dayGoalsSummaryTotal => 'Всего';

  @override
  String get dayGoalsSummaryDone => 'Готово';

  @override
  String get dayGoalsSummaryRemaining => 'Осталось';

  @override
  String dayGoalsRemainingHours(Object hours) {
    return 'Осталось часов: $hours';
  }

  @override
  String get dayGoalsHideCompleted => 'Скрыть выполненные';

  @override
  String get reportsTabSummary => 'Сводка';

  @override
  String get reportsTabRelations => 'Связи';

  @override
  String get reportsTabProductivity => 'Продуктивность';

  @override
  String get reportsTabExpenses => 'Расходы';

  @override
  String get reportsCompletedTasks => 'Выполнено задач';

  @override
  String get reportsSpentHours => 'Затрачено часов';

  @override
  String get reportsEfficiency => 'Эффективность';

  @override
  String get reportsPeriodEfficiency => 'Эффективность периода';

  @override
  String reportsPlanFactHours(Object planned, Object actual) {
    return 'План: $planned ч • Факт: $actual ч';
  }

  @override
  String get reportsAdditionalMetrics => 'Дополнительные метрики';

  @override
  String get reportsCorrelations => 'Связи между показателями';

  @override
  String get reportsCorrelationsHint =>
      'Это не “научная корреляция”, а понятные сравнения по периодам.';

  @override
  String get reportsMoodProductivity => 'Настроение → Продуктивность';

  @override
  String get reportsGoodMood => 'Хорошее';

  @override
  String get reportsBadMood => 'Плохое';

  @override
  String get reportsHabitsMoodProductivity =>
      'Привычки → Настроение / Продуктивность';

  @override
  String get reportsMoodMostlyHappy => 'скорее 😊';

  @override
  String get reportsMoodMostlySad => 'скорее 😞';

  @override
  String get reportsMoodMostlyNeutral => 'скорее 😐';

  @override
  String reportsHabitsComparisonHint(int percent) {
    return 'Сравнение дней, где выполнено ≥ $percent% привычек, и остальных дней.';
  }

  @override
  String get reportsMoodHigh => 'Настроение (high)';

  @override
  String get reportsMoodLow => 'Настроение (low)';

  @override
  String get reportsHoursHigh => 'Часы (high)';

  @override
  String get reportsHoursLow => 'Часы (low)';

  @override
  String get reportsHabitsHighShort => 'habits high';

  @override
  String get reportsHabitsLowShort => 'habits low';

  @override
  String get reportsMentalMood => 'Ментальное состояние → Настроение';

  @override
  String get reportsExpensesMood => 'Расходы → Настроение';

  @override
  String get reportsHappyDays => '😊 дни';

  @override
  String get reportsSadDays => '😞 дни';

  @override
  String get reportsCompletedByBlocks => 'Выполнено по блокам';

  @override
  String get reportsNoCompletedTasks => 'Нет выполненных задач';

  @override
  String reportsTasksCount(int count) {
    return '$count задач';
  }

  @override
  String get reportsHoursByDays => 'Затрачено часов по дням';

  @override
  String get reportsExpensesForPeriod => 'Расходы за период';

  @override
  String reportsTotalEuro(Object amount) {
    return 'Всего: $amount €';
  }

  @override
  String reportsAvgExpensePerDay(Object amount) {
    return 'Средний расход/день: $amount €';
  }

  @override
  String get reportsNoExpensesByCategory => 'Нет расходов по категориям';

  @override
  String get reportsAvgTimePerGoal => 'Среднее время на задачу';

  @override
  String get reportsOnTimeConditional => '«В срок» (условно)';

  @override
  String get reportsTop3ProductiveDays => 'ТОП-3 продуктивных дня';

  @override
  String reportsTopDayLine(int day, int month, int year, Object hours) {
    return '• $day.$month.$year: $hours ч';
  }

  @override
  String get reportsPeriodDay => 'День';

  @override
  String get reportsPeriodWeekShort => 'Нед';

  @override
  String get reportsPeriodMonthShort => 'Мес';

  @override
  String get reportsForward => 'Вперёд';

  @override
  String get reportsTapChartSector => 'Нажмите на сектор диаграммы';

  @override
  String get reportsLatestAiInsights => 'Последние AI-инсайты';

  @override
  String get reportsOpenAll => 'Открыть все';

  @override
  String get reportsInsightsLoadFailed => 'Не удалось загрузить инсайты';

  @override
  String get reportsNoSavedInsights => 'Пока нет сохранённых инсайтов.';

  @override
  String get reportsRunAiInsightsHint =>
      'Открой «AI-инсайты» и запусти анализ — после этого они появятся здесь.';

  @override
  String get reportsAiPeriod7Days => 'за 7 дней';

  @override
  String get reportsAiPeriod30Days => 'за 30 дней';

  @override
  String get reportsAiPeriod90Days => 'за 90 дней';

  @override
  String reportsHoursValue(Object hours) {
    return '$hours ч';
  }

  @override
  String reportsEuroValue(Object amount) {
    return '$amount €';
  }

  @override
  String get commonError => 'Ошибка';

  @override
  String get aiPlanConsentSaved => 'Согласие на AI-обработку сохранено';

  @override
  String aiPlanConsentCheckFailed(Object error) {
    return 'Не удалось проверить или сохранить согласие на AI-обработку. Проверь, что в таблицу users добавлены поля ai_processing_consent, ai_processing_consent_at и ai_processing_consent_version. Детали: $error';
  }

  @override
  String get aiPlanConsentTitle => 'Согласие на AI-обработку';

  @override
  String get aiPlanConsentBody =>
      'Чтобы сгенерировать AI-план, Ladna будет анализировать твои цели, задачи, привычки, настроение и другие данные приложения. Эти данные используются только для создания персональных рекомендаций, планов и инсайтов.';

  @override
  String get aiPlanConsentDeclineBody =>
      'Ты можешь не давать согласие — тогда AI-функция не будет запущена.';

  @override
  String get aiPlanConsentNotNow => 'Не сейчас';

  @override
  String get aiPlanConsentAgree => 'Согласен';

  @override
  String aiPlanOpenLinkFailed(Object url) {
    return 'Не удалось открыть ссылку: $url';
  }

  @override
  String get aiPlanUpdated => 'AI-план обновлён';

  @override
  String get aiPlanEmptyEdgeFunction =>
      'План пуст. Проверь Edge Function ai-plan.';

  @override
  String aiPlanHoursShort(Object hours) {
    return '$hours ч';
  }

  @override
  String aiPlanImportanceMeta(int importance) {
    return 'важность $importance/5';
  }

  @override
  String get aiPlanLinkedToGoal => 'связано с целью';

  @override
  String get aiPlanNothingToApply => 'Нечего применять — выбери пункты';

  @override
  String get aiPlanDefaultTaskTitle => 'AI-задача';

  @override
  String aiPlanTasksAdded(int count) {
    return 'Добавлено задач: $count';
  }

  @override
  String get aiPlanApplyTypeError =>
      'Ошибка типа данных при добавлении задач: одно из полей пришло как true/false вместо числа. Обнови файл ещё раз: в этой версии bool-значения дополнительно приводятся к числам, а поле is_completed больше не отправляется вручную.';

  @override
  String get aiPlanTitleWeek => 'AI-план на неделю';

  @override
  String get aiPlanTitleMonth => 'AI-план на месяц';

  @override
  String get aiPlanRegenerateTooltip => 'Сгенерировать заново';

  @override
  String aiPlanUpdatedAt(Object date) {
    return 'Обновлено: $date';
  }

  @override
  String get aiPlanCheckingConsent => 'Проверяю согласие на AI-обработку...';

  @override
  String get aiPlanApplyingTasks => 'Добавляю задачи...';

  @override
  String get aiPlanGenerating => 'Генерирую AI-план...';

  @override
  String aiPlanApplyCount(int count) {
    return 'Применить ($count)';
  }

  @override
  String get aiPlanRejectTooltip => 'Отклонить';

  @override
  String get aiPlanAcceptTooltip => 'Принять';

  @override
  String get aiPlanFieldBlock => 'Блок';

  @override
  String get aiPlanFieldImportance => 'Важность';

  @override
  String get aiPlanFieldHours => 'Часы';

  @override
  String get aiPlanFieldRepeat => 'Повтор';

  @override
  String get aiPlanConsentRequiredTitle => 'Нужно согласие на AI-обработку';

  @override
  String get aiPlanConsentRequiredBody =>
      'Перед генерацией AI-плана нужно подтвердить, что Ladna может анализировать данные приложения для персональных рекомендаций.';

  @override
  String get aiPlanGiveConsent => 'Дать согласие';

  @override
  String get aiPlanPrivacyPolicy => 'Privacy Policy';

  @override
  String get aiPlanDatenschutz => 'Datenschutzerklärung';

  @override
  String get aiPlanTermsOfUse => 'Terms of Use';

  @override
  String get aiPlanEmptyTitle => 'План пока пуст';

  @override
  String get aiPlanEmptyBody =>
      'Нажми кнопку ниже, чтобы сгенерировать план на основе AI-инсайтов, целей, задач, привычек и настроения.';

  @override
  String get aiPlanGeneratePlan => 'Сгенерировать план';

  @override
  String get aiPlanRepeatNone => 'Без повтора';

  @override
  String get aiPlanRepeatDaily => 'Каждый день';

  @override
  String get aiPlanRepeatWeekdays => 'По будням';

  @override
  String get aiPlanRepeatWeekly => 'Раз в неделю';

  @override
  String get aiPlanLifeBlockOther => 'Другое';

  @override
  String get aiInsightsConsentTitle => 'Согласие на AI-обработку';

  @override
  String get aiInsightsConsentBody =>
      'Чтобы сгенерировать AI-инсайты, Ladna будет анализировать твои цели, задачи, привычки, настроение и другие данные приложения. Эти данные используются только для создания персональных рекомендаций, планов и инсайтов.';

  @override
  String get aiInsightsConsentDeclineBody =>
      'Ты можешь не давать согласие — тогда AI-функция не будет запущена.';

  @override
  String get aiInsightsConsentNotNow => 'Не сейчас';

  @override
  String get aiInsightsConsentAgree => 'Согласен';

  @override
  String get aiInsightsConsentSaved => 'Согласие на AI-обработку сохранено';

  @override
  String aiInsightsConsentCheckFailed(Object error) {
    return 'Не удалось проверить или сохранить согласие на AI-обработку. Проверь, что в таблицу users добавлены поля ai_processing_consent, ai_processing_consent_at и ai_processing_consent_version. Детали: $error';
  }

  @override
  String get aiInsightsCheckingConsent =>
      'Проверяю согласие на AI-обработку...';

  @override
  String get aiInsightsUserNotAuthorized => 'Пользователь не авторизован';

  @override
  String aiInsightsOpenLinkFailed(Object url) {
    return 'Не удалось открыть ссылку: $url';
  }

  @override
  String get aiInsightsDefaultTitle => 'AI-инсайт';

  @override
  String get aiInsightsConsentRequiredTitle => 'Нужно согласие на AI-обработку';

  @override
  String get aiInsightsConsentRequiredBody =>
      'Перед генерацией AI-инсайтов нужно подтвердить, что Ladna может анализировать данные приложения для персональных рекомендаций.';

  @override
  String get aiInsightsGiveConsent => 'Дать согласие';

  @override
  String get aiInsightsPrivacyPolicy => 'Privacy Policy';

  @override
  String get aiInsightsDatenschutz => 'Datenschutzerklärung';

  @override
  String get aiInsightsTermsOfUse => 'Terms of Use';

  @override
  String get massDailyTitle => 'Массовое добавление за день';

  @override
  String get massDailyDatePrefix => 'Дата: ';

  @override
  String get massDailyChoose => 'Выбрать';

  @override
  String get massDailyBack => 'Назад';

  @override
  String get massDailyCancel => 'Отмена';

  @override
  String get massDailyNext => 'Далее';

  @override
  String get massDailySaveAll => 'Сохранить всё';

  @override
  String get massDailyEmptyRowsIgnored => 'Пустые строки игнорируются.';

  @override
  String get massDailyMoodTitle => 'Настроение';

  @override
  String get massDailyMoodSubtitle =>
      'Необязательная запись о том, как прошёл день.';

  @override
  String get massDailyNote => 'Заметка';

  @override
  String get massDailyHabitsTitle => 'Привычки';

  @override
  String get massDailyHabitsSubtitle =>
      'Отметь выполнение и при необходимости укажи количество.';

  @override
  String get massDailyRefresh => 'Обновить';

  @override
  String get massDailyNoHabits => 'Пока нет привычек. Добавь их в профиле.';

  @override
  String massDailyHabitsLoadFailed(Object error) {
    return 'Не удалось загрузить привычки: $error';
  }

  @override
  String get massDailyMentalTitle => 'Ментальное здоровье';

  @override
  String get massDailyMentalSubtitle =>
      'Короткая ежедневная фиксация состояния для дальнейшей аналитики.';

  @override
  String get massDailyMentalIntro =>
      'Ответь на несколько вопросов — это поможет отслеживать состояние.';

  @override
  String get massDailyNoMentalQuestions =>
      'Пока нет вопросов. Добавь их в таблицу mental_questions.';

  @override
  String massDailyMentalLoadFailed(Object error) {
    return 'Не удалось загрузить вопросы: $error';
  }

  @override
  String get massDailyExpensesTitle => 'Расходы';

  @override
  String get massDailyExpensesSubtitle => 'Добавь траты за выбранный день.';

  @override
  String get massDailyIncomesTitle => 'Доходы';

  @override
  String get massDailyIncomesSubtitle =>
      'Добавь поступления за выбранный день.';

  @override
  String get massDailyGoalsTitle => 'Задачи';

  @override
  String get massDailyGoalsSubtitle =>
      'Зафиксируй, над чем ты работал в этот день, и сколько времени это заняло.';

  @override
  String get massDailyAddRow => 'Добавить строку';

  @override
  String get massDailyNoMood => 'Без настроения';

  @override
  String get massDailyQuantityExample => 'Количество (например, сигареты)';

  @override
  String get massDailyQuantityOptional => 'Количество (необязательно)';

  @override
  String get massDailyQuantityShort => 'Кол-во';

  @override
  String get massDailyHabitNegative => 'Негативная';

  @override
  String get massDailyHabitPositive => 'Позитивная';

  @override
  String get massDailyAnswer => 'Ответ';

  @override
  String get massDailyAmount => 'Сумма';

  @override
  String get massDailyCategory => 'Категория';

  @override
  String get massDailyNoCategories => 'Нет категорий';

  @override
  String get massDailyTaskTitle => 'Название задачи';

  @override
  String get massDailyHours => 'Часы';

  @override
  String get massDailyTime => 'Время';

  @override
  String get massDailyEmotion => 'Эмоция';

  @override
  String get massDailyNoEmotion => 'Без эмоции';

  @override
  String get massDailyImportance => 'Важность';

  @override
  String get massDailyBigGoal => 'Большая цель';

  @override
  String get massDailyNoLink => 'Без связи';

  @override
  String get massDailyLoadingUserGoals => 'Загружаю большие цели...';

  @override
  String get massDailyNoUserGoalsForCategory =>
      'Для этой категории пока нет больших целей.';

  @override
  String get massDailyHorizonTactical => 'Тактическая';

  @override
  String get massDailyHorizonMid => 'Среднесрочная';

  @override
  String get massDailyHorizonLong => 'Долгосрочная';

  @override
  String get massDailyLifeBlockGeneral => 'Общее';

  @override
  String get massDailyLifeBlockHealth => 'Здоровье';

  @override
  String get massDailyLifeBlockCareer => 'Карьера';

  @override
  String get massDailyLifeBlockFamily => 'Дом и быт';

  @override
  String get massDailyLifeBlockFinance => 'Финансы';

  @override
  String get massDailyLifeBlockEducation => 'Образование';

  @override
  String get massDailyLifeBlockHobbies => 'Хобби';

  @override
  String get importJournalTextNotRecognized =>
      'Текст не распознан. Попробуй другое фото.';

  @override
  String get importJournalRecognizedTextTitle => 'Распознанный текст';

  @override
  String get importJournalContinue => 'Продолжить';

  @override
  String get importJournalUntitled => 'Без названия';

  @override
  String get importJournalNoTasksFound =>
      'Не удалось выделить задачи из текста.';

  @override
  String importJournalAddedGoals(Object count) {
    return 'Добавлено целей: $count';
  }

  @override
  String importJournalImportFailed(Object error) {
    return 'Не удалось импортировать: $error';
  }

  @override
  String get importJournalVisionApiKeyMissing =>
      'VISION_API_KEY не задан. Запусти приложение с --dart-define=VISION_API_KEY=...';

  @override
  String importJournalVisionApiError(Object statusCode, Object body) {
    return 'Vision API вернул ошибку $statusCode: $body';
  }

  @override
  String get importJournalEditTitle => 'Редактировать';

  @override
  String get importJournalNameLabel => 'Название';

  @override
  String get importJournalTimeColon => 'Время:';

  @override
  String get importJournalHoursColon => 'Часы:';

  @override
  String get importJournalFoundTasksTitle => 'Найденные задачи';

  @override
  String importJournalTaskSubtitle(Object time, Object hours) {
    return '$time • $hours ч';
  }

  @override
  String get importJournalAddSelected => 'Добавить выбранные';

  @override
  String get recurringGoalSelectAtLeastOneWeekday =>
      'Выберите хотя бы один день недели';

  @override
  String get recurringGoalTitle => 'Регулярная цель';

  @override
  String get recurringGoalSubtitle =>
      'Создаст задачи с сегодняшнего дня до выбранной даты.';

  @override
  String get recurringGoalDetailsSection => 'Детали';

  @override
  String get recurringGoalTitleLabel => 'Название цели';

  @override
  String get recurringGoalTitleHint => 'Например: Тренировка';

  @override
  String get recurringGoalEmotionLabel => 'Эмоция';

  @override
  String get recurringGoalEmotionHint => 'Например: 💪 мотивация';

  @override
  String get recurringGoalRegularitySection => 'Регулярность';

  @override
  String get recurringGoalEveryNDays => 'Каждые N дней';

  @override
  String get recurringGoalByWeekdays => 'По дням недели';

  @override
  String get recurringGoalIntervalLabel => 'Интервал';

  @override
  String recurringGoalEveryNDaysShort(Object count) {
    return '$count дн.';
  }

  @override
  String get recurringGoalWeekdayMon => 'Пн';

  @override
  String get recurringGoalWeekdayTue => 'Вт';

  @override
  String get recurringGoalWeekdayWed => 'Ср';

  @override
  String get recurringGoalWeekdayThu => 'Чт';

  @override
  String get recurringGoalWeekdayFri => 'Пт';

  @override
  String get recurringGoalWeekdaySat => 'Сб';

  @override
  String get recurringGoalWeekdaySun => 'Вс';

  @override
  String recurringGoalTimeButton(Object time) {
    return 'Время: $time';
  }

  @override
  String recurringGoalUntilButton(Object date) {
    return 'До: $date';
  }

  @override
  String get recurringGoalParametersSection => 'Параметры';

  @override
  String get recurringGoalLifeBlockLabel => 'Блок жизни';

  @override
  String get recurringGoalImportanceLabel => 'Важность';

  @override
  String get recurringGoalUserGoalLabel => 'Большая цель';

  @override
  String get recurringGoalNoLink => 'Без связи';

  @override
  String recurringGoalLoadingUserGoals(Object block) {
    return 'Загружаю цели для блока “$block”...';
  }

  @override
  String recurringGoalNoUserGoalsForBlock(Object block) {
    return 'Для блока “$block” пока нет доступных целей.';
  }

  @override
  String get recurringGoalPlannedHoursLabel => 'План часов';

  @override
  String recurringGoalOccurrencesCount(Object count) {
    return 'Будет создано задач: $count';
  }

  @override
  String get recurringGoalCreate => 'Создать';

  @override
  String get recurringGoalLifeBlockGeneral => 'Общее';

  @override
  String get recurringGoalLifeBlockHealth => 'Здоровье';

  @override
  String get recurringGoalLifeBlockCareer => 'Карьера';

  @override
  String get recurringGoalLifeBlockFinance => 'Финансы';

  @override
  String get recurringGoalLifeBlockRelationships => 'Отношения';

  @override
  String get recurringGoalLifeBlockSelf => 'Саморазвитие';

  @override
  String get recurringGoalLifeBlockEducation => 'Образование';

  @override
  String get recurringGoalLifeBlockTravel => 'Путешествия';

  @override
  String get recurringGoalLifeBlockHome => 'Дом';

  @override
  String get recurringGoalHorizonTactical => 'Тактическая';

  @override
  String get recurringGoalHorizonMid => 'Среднесрочная';

  @override
  String get recurringGoalHorizonLong => 'Долгосрочная';

  @override
  String get addDayGoalLinkSectionTitle => 'Связать с целью';

  @override
  String get addDayGoalUserGoalLabel => 'Большая цель';

  @override
  String get addDayGoalNoLinkedGoal => 'Без связи';

  @override
  String addDayGoalLoadingUserGoals(Object block) {
    return 'Загружаю цели для блока «$block»...';
  }

  @override
  String addDayGoalNoUserGoalsForBlock(Object block) {
    return 'Для блока «$block» пока нет доступных целей.';
  }

  @override
  String get addDayGoalLifeBlockGeneral => 'Общее';

  @override
  String get addDayGoalLifeBlockHealth => 'Здоровье';

  @override
  String get addDayGoalLifeBlockCareer => 'Карьера';

  @override
  String get addDayGoalLifeBlockFinance => 'Финансы';

  @override
  String get addDayGoalLifeBlockRelationships => 'Отношения';

  @override
  String get addDayGoalLifeBlockSelf => 'Саморазвитие';

  @override
  String get addDayGoalLifeBlockEducation => 'Образование';

  @override
  String get addDayGoalLifeBlockTravel => 'Путешествия';

  @override
  String get addDayGoalLifeBlockHome => 'Дом';

  @override
  String get addDayGoalHorizonTactical => 'Тактическая';

  @override
  String get addDayGoalHorizonMid => 'Среднесрочная';

  @override
  String get addDayGoalHorizonLong => 'Долгосрочная';

  @override
  String get lifeBlockSelf => 'Саморазвитие';

  @override
  String get lifeBlockTravel => 'Путешествия';

  @override
  String get lifeBlockHome => 'Дом';

  @override
  String get horizonTactical => 'Тактическая';

  @override
  String get horizonMid => 'Среднесрочная';

  @override
  String get horizonLong => 'Долгосрочная';

  @override
  String get editGoalSectionDateTime => 'Дата и время';

  @override
  String get editGoalSectionUserGoalLink => 'Связь с большой целью';

  @override
  String get userGoalLinkFieldLabel => 'Большая цель';

  @override
  String get userGoalLinkNone => 'Без связи';

  @override
  String userGoalLinkLoadingForBlock(Object block) {
    return 'Загружаю цели для блока «$block»...';
  }

  @override
  String userGoalLinkNoGoalsForBlock(Object block) {
    return 'Для блока «$block» пока нет доступных целей.';
  }

  @override
  String editGoalHoursValue(Object hours) {
    return 'Часы: $hours';
  }

  @override
  String commonHoursShort(Object hours) {
    return '$hours ч';
  }

  @override
  String get healthTrackerTitle => 'Трекер здоровья';

  @override
  String get healthCalorieTargetTitle => 'Норма калорий';

  @override
  String get healthDailyCaloriesLabel => 'Ккал в день';

  @override
  String get healthAddMealTitle => 'Добавить приём пищи';

  @override
  String get healthMealTypeLabel => 'Приём пищи';

  @override
  String get healthMealBreakfast => 'Завтрак';

  @override
  String get healthMealLunch => 'Обед';

  @override
  String get healthMealDinner => 'Ужин';

  @override
  String get healthMealSnack => 'Перекус';

  @override
  String get healthCaloriesLabel => 'Калории';

  @override
  String get healthEnterCalories => 'Введите калории';

  @override
  String get healthMealDescriptionLabel => 'Что это была за еда';

  @override
  String get healthAddDescription => 'Добавьте описание';

  @override
  String get healthAddBurnTitle => 'Добавить расход калорий';

  @override
  String get healthCaloriesBurnedLabel => 'Сколько калорий потрачено';

  @override
  String get healthCommentLabel => 'Комментарий';

  @override
  String get healthWaterTodayTitle => 'Сколько воды выпито сегодня';

  @override
  String get healthSaveWater => 'Сохранить воду';

  @override
  String get healthSetTarget => 'Указать норму';

  @override
  String healthTargetCalories(Object calories) {
    return 'Норма $calories ккал';
  }

  @override
  String get healthAddMealButton => 'Добавить еду';

  @override
  String get healthAddBurnButton => 'Добавить расход';

  @override
  String healthWaterButton(Object liters) {
    return 'Вода $liters л';
  }

  @override
  String get healthConsumed => 'Съедено';

  @override
  String get healthBurned => 'Потрачено';

  @override
  String get healthBalance => 'Баланс';

  @override
  String get healthDeltaVsTarget => 'Отклонение от нормы';

  @override
  String get healthWaterDrunk => 'Выпито воды';

  @override
  String healthKcalValue(Object value) {
    return '$value ккал';
  }

  @override
  String healthKcalValueWithSign(Object value) {
    return '$value ккал';
  }

  @override
  String healthLitersValue(Object value) {
    return '$value л';
  }

  @override
  String get healthMealsTodayTitle => 'Приёмы пищи за сегодня';

  @override
  String get healthNoMeals => 'Пока нет записей по еде.';

  @override
  String get healthBurnsTitle => 'Расход калорий';

  @override
  String get healthNoBurns => 'Пока нет записей о потраченных калориях.';

  @override
  String get healthNoComment => 'Без комментария';

  @override
  String get hobbyTrackerTitle => 'Трекер хобби';

  @override
  String get hobbyTrackerNewHobbyTitle => 'Новое хобби';

  @override
  String get hobbyTrackerHobbyNameLabel => 'Название хобби';

  @override
  String get hobbyTrackerEnterHobbyValidator => 'Введите хобби';

  @override
  String get hobbyTrackerWeeklyGoalMinutesLabel => 'Цель на неделю, минут';

  @override
  String get hobbyTrackerEnterGoalValidator => 'Введите цель';

  @override
  String get hobbyTrackerCreateButton => 'Создать';

  @override
  String hobbyTrackerAddTimeTitle(Object title) {
    return 'Добавить время: $title';
  }

  @override
  String get hobbyTrackerMinutesSpentLabel => 'Сколько минут потратил';

  @override
  String get hobbyTrackerNoteLabel => 'Заметка';

  @override
  String get hobbyTrackerDeleteConfirmTitle => 'Удалить хобби?';

  @override
  String hobbyTrackerDeleteConfirmBody(Object title) {
    return 'Хобби \"$title\" будет удалено вместе со всеми записями.';
  }

  @override
  String get hobbyTrackerAddHobbyTooltip => 'Добавить хобби';

  @override
  String get hobbyTrackerEmptyText =>
      'Пока нет хобби. Добавь первое направление и начни трекать время.';

  @override
  String get hobbyTrackerCreateHobbyButton => 'Создать хобби';

  @override
  String get hobbyTrackerDeleteHobbyTooltip => 'Удалить хобби';

  @override
  String get hobbyTrackerAddEntryButton => 'Внести';

  @override
  String hobbyTrackerToday(Object value) {
    return 'Сегодня $value';
  }

  @override
  String hobbyTrackerWeek(Object value) {
    return 'Неделя $value';
  }

  @override
  String hobbyTrackerGoal(Object value) {
    return 'Цель: $value';
  }

  @override
  String hobbyTrackerMinutesShort(Object minutes) {
    return '$minutesм';
  }

  @override
  String hobbyTrackerHoursShort(Object hours) {
    return '$hoursч';
  }

  @override
  String hobbyTrackerHoursMinutesShort(Object hours, Object minutes) {
    return '$hoursч $minutesм';
  }

  @override
  String get importGoalsReviewTitle => 'Импортировать цели';

  @override
  String get importGoalsReviewSubtitle =>
      'Отметь, что импортировать, и при необходимости поправь название/описание.';

  @override
  String get importGoalsReviewSelectAll => 'Выбрать всё';

  @override
  String get importGoalsReviewYes => 'Да';

  @override
  String get importGoalsReviewNo => 'Нет';

  @override
  String get importGoalsReviewListSection => 'Список';

  @override
  String get importGoalsReviewImport => 'Импортировать';

  @override
  String get importGoalsReviewFieldTitle => 'Название';

  @override
  String get importGoalsReviewFieldDescription => 'Описание';

  @override
  String importGoalsReviewTime(Object time) {
    return 'Время: $time';
  }

  @override
  String get importGoalsReviewChange => 'Изменить';

  @override
  String get shoppingBasketCopyHeader => '🛒 Список покупок';

  @override
  String shoppingDueDatePrefix(Object date) {
    return 'до $date';
  }

  @override
  String get shoppingBasketCopied => 'Список покупок скопирован';

  @override
  String get shoppingNewWishlistItem => 'Новый wish item';

  @override
  String get shoppingNewPurchase => 'Новая покупка';

  @override
  String get shoppingEditItem => 'Редактировать позицию';

  @override
  String get shoppingFieldTitle => 'Название';

  @override
  String get shoppingEnterTitle => 'Введите название';

  @override
  String get shoppingFieldDescription => 'Описание';

  @override
  String get shoppingFieldPrice => 'Стоимость';

  @override
  String get shoppingFieldStore => 'Магазин';

  @override
  String get shoppingFieldExpenseCategory => 'Категория расхода';

  @override
  String get shoppingNoCategory => 'Без категории';

  @override
  String get shoppingAlreadyBought => 'Уже куплено';

  @override
  String get shoppingPurchaseDate => 'Дата покупки';

  @override
  String get shoppingReset => 'Сбросить';

  @override
  String get shoppingEmpty => 'Пока пусто.';

  @override
  String get shoppingTrackerTitle => 'Трекер покупок';

  @override
  String get shoppingCopyBasket => 'Копировать корзину';

  @override
  String get shoppingBasketTitle => 'Список покупок';

  @override
  String get shoppingWishlistTitle => 'Wishlist';

  @override
  String get profileOpenLinkFailed => 'Не удалось открыть ссылку.';

  @override
  String get profileDangerZoneSubtitle => 'Удаление аккаунта';

  @override
  String get profileLegalDocumentsTitle => 'Правовые документы';

  @override
  String get profileLegalDocumentsSubtitle =>
      'Здесь ты можешь открыть Privacy Policy, Datenschutz, Terms of Use и Impressum в любое время.';

  @override
  String get profileLegalPrivacyTitle => 'Privacy Policy';

  @override
  String get profileLegalPrivacySubtitle =>
      'Английская версия политики конфиденциальности';

  @override
  String get profileLegalDatenschutzTitle => 'Datenschutzerklärung';

  @override
  String get profileLegalDatenschutzSubtitle =>
      'Немецкая версия политики конфиденциальности';

  @override
  String get profileLegalTermsTitle => 'Terms of Use';

  @override
  String get profileLegalTermsSubtitle =>
      'Правила и условия использования Ladna';

  @override
  String get profileLegalImpressumTitle => 'Impressum';

  @override
  String get profileLegalImpressumSubtitle =>
      'Юридическая информация и данные провайдера';

  @override
  String get settingsLanguageSystem => 'Системный';

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
      'Отметь привычки и подведи итоги дня 👌';

  @override
  String get profileWebNotificationsPermissionDeniedToast =>
      'Разрешение не выдано. Проверь настройки уведомлений в браузере.';

  @override
  String get profileWebNotificationsPermissionGrantedToast =>
      'Уведомления в браузере разрешены ✅';

  @override
  String profileWebNotificationsTimeChangedToast(Object time) {
    return 'Время уведомления: $time';
  }

  @override
  String get profileWebNotificationsLoadingSettings => 'Загрузка настроек...';

  @override
  String get profileWebNotificationsEnabledToast =>
      'Включено. Не забудь разрешить уведомления в браузере.';

  @override
  String get profileWebNotificationsDisabledToast => 'Выключено.';

  @override
  String get profileEditChipsDefaultHint => 'Введите через запятую';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в Ladna';

  @override
  String get onboardingWelcomeBody =>
      'Сейчас я быстро покажу главные функции: быстрые действия, задачи, большие цели, профиль, отчёты и финансы.';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingFinishTitle => 'Готово';

  @override
  String get onboardingFinishBody =>
      'Теперь ты знаешь, где находятся основные функции Ladna. Обучение можно запустить снова через значок помощи на главном экране.';

  @override
  String get onboardingGotIt => 'Понятно';

  @override
  String get onboardingMainQuickActionsTitle => 'Быстрые действия';

  @override
  String get onboardingMainQuickActionsText =>
      'Через эту кнопку ты быстро добавляешь задачи, настроение, расходы, привычки и запускаешь AI-план.';

  @override
  String get onboardingMainNavigationTitle => 'Навигация по Ladna';

  @override
  String get onboardingMainNavigationText =>
      'Здесь находятся основные разделы: главная, задачи, большие цели, профиль, отчёты и финансы.';

  @override
  String get onboardingMainHelpTitle => 'Инструкцию можно открыть снова';

  @override
  String get onboardingMainHelpText =>
      'Нажми на этот значок, если захочешь повторить интерактивный How-To позже.';

  @override
  String get onboardingGoalsFilterTitle => 'Фильтр по сфере жизни';

  @override
  String get onboardingGoalsFilterText =>
      'Выбирай карьеру, здоровье, финансы и другие сферы, чтобы смотреть задачи именно в нужном контексте.';

  @override
  String get onboardingGoalsModeTitle => 'Дашборд или календарь';

  @override
  String get onboardingGoalsModeText =>
      'Дашборд показывает общую картину, а календарь помогает планировать задачи по дням и неделям.';

  @override
  String get onboardingGoalsAddTitle => 'Добавление действий';

  @override
  String get onboardingGoalsAddText =>
      'Здесь можно быстро добавить задачу, серию задач или заполнить день сразу несколькими записями.';

  @override
  String get onboardingReportsPeriodTitle => 'Период анализа';

  @override
  String get onboardingReportsPeriodText =>
      'Переключай день, неделю и месяц, чтобы сравнивать динамику целей, настроения, привычек и финансов.';

  @override
  String get onboardingReportsChartTitle => 'Интерактивные графики';

  @override
  String get onboardingReportsChartText =>
      'Нажимай на сектора и точки графиков — приложение покажет подробности только по выбранному элементу.';

  @override
  String get onboardingUserGoalsHeaderTitle => 'Большие цели';

  @override
  String get onboardingUserGoalsHeaderText =>
      'Здесь хранятся стратегические цели: краткосрочные, среднесрочные и долгосрочные. Потом к ним можно привязывать ежедневные задачи.';

  @override
  String get onboardingUserGoalsFiltersTitle => 'Фильтры целей';

  @override
  String get onboardingUserGoalsFiltersText =>
      'Фильтруй цели по сфере жизни и горизонту, чтобы быстро сфокусироваться на нужном направлении.';

  @override
  String get onboardingUserGoalsAddTitle => 'Создать большую цель';

  @override
  String get onboardingUserGoalsAddText =>
      'Нажми сюда, чтобы добавить цель, выбрать сферу жизни, горизонт и дедлайн.';

  @override
  String get onboardingProfileHeaderTitle => 'Профиль';

  @override
  String get onboardingProfileHeaderText =>
      'Это центр персональных настроек Ladna: здесь пользователь управляет аккаунтом, фокусом, привычками и параметрами приложения.';

  @override
  String get onboardingProfileCardTitle => 'Личные данные';

  @override
  String get onboardingProfileCardText =>
      'Имя, возраст и базовые параметры используются для персонализации интерфейса и будущих AI-рекомендаций.';

  @override
  String get onboardingProfileFocusTitle => 'Фокус и настройки';

  @override
  String get onboardingProfileFocusText =>
      'Здесь задаются параметры, которые влияют на планирование дня, аналитику и рекомендации в приложении.';

  @override
  String get onboardingBudgetIncomeTitle => 'Категории доходов';

  @override
  String get onboardingBudgetIncomeText =>
      'Добавляй источники дохода, чтобы финансовая аналитика понимала структуру поступлений.';

  @override
  String get onboardingBudgetExpenseTitle => 'Категории расходов';

  @override
  String get onboardingBudgetExpenseText =>
      'Здесь настраиваются категории расходов и лимиты. Это помогает видеть, где бюджет уходит быстрее всего.';

  @override
  String get onboardingBudgetJarsTitle => 'Копилки и распределение';

  @override
  String get onboardingBudgetJarsText =>
      'Используй копилки для целей накопления: путешествия, подушка безопасности, инвестиции или крупные покупки.';

  @override
  String get onboardingBudgetSaveTitle => 'Сохранить настройки';

  @override
  String get onboardingBudgetSaveText =>
      'После изменений не забудь сохранить бюджет — тогда категории и лимиты попадут в базу.';

  @override
  String get onboardingDayGoalsSummaryTitle => 'Итог дня';

  @override
  String get onboardingDayGoalsSummaryText =>
      'В этой карточке видно прогресс дня: сколько задач выполнено, сколько осталось и сколько времени ещё запланировано.';

  @override
  String get onboardingDayGoalsFilterTitle => 'Скрыть выполненные';

  @override
  String get onboardingDayGoalsFilterText =>
      'Включи фильтр, чтобы оставить на экране только актуальные задачи.';

  @override
  String get onboardingDayGoalsFabTitle => 'Добавить активность';

  @override
  String get onboardingDayGoalsFabText =>
      'Через эту кнопку можно добавить задачу, распознать запись из ежедневника или синхронизировать Google Calendar.';

  @override
  String get onboardingQuestionnaireProgressTitle => 'Прогресс настройки';

  @override
  String get onboardingQuestionnaireProgressText =>
      'Здесь видно, на каком шаге первичной настройки ты сейчас находишься.';

  @override
  String get onboardingQuestionnaireNextTitle => 'Переход дальше';

  @override
  String get onboardingQuestionnaireNextText =>
      'После заполнения текущего шага нажми сюда. В конце Ladna сохранит профиль, сферы жизни и цели.';

  @override
  String get onboardingExpensesControlsTitle => 'День и настройки бюджета';

  @override
  String get onboardingExpensesControlsText =>
      'Здесь выбирается дата для операций, а также открываются настройки категорий, лимитов и копилок.';

  @override
  String get onboardingExpensesSummaryTitle => 'Финансовая сводка месяца';

  @override
  String get onboardingExpensesSummaryText =>
      'Карточка показывает доходы, расходы и свободный остаток за месяц — это база для анализа бюджета.';

  @override
  String get onboardingExpensesTransactionsTitle =>
      'Операции за выбранный день';

  @override
  String get onboardingExpensesTransactionsText =>
      'Здесь видны доходы и расходы за день. Нажми на операцию, чтобы изменить её, или свайпни влево для удаления.';

  @override
  String get onboardingExpensesFabTitle => 'Добавить доход или расход';

  @override
  String get onboardingExpensesFabText =>
      'Нажми на плюс, чтобы открыть меню и быстро добавить новую финансовую операцию.';

  @override
  String get onboardingNextHint => 'Нажми на экран, чтобы перейти дальше';

  @override
  String get registerLegalTermsTitle => 'Условия использования';

  @override
  String get registerLegalPrivacyPrefix =>
      'Я даю согласие на обработку моих персональных данных согласно';

  @override
  String get registerLegalTermsPrefix => 'Я соглашаюсь с';

  @override
  String get registerLegalOptionalLinksPrefix => 'Также доступны:';

  @override
  String get registerLegalPrivacyTitle => 'Политика конфиденциальности';

  @override
  String get registerLegalDatenschutzTitle => 'Datenschutzerklärung';

  @override
  String get registerLegalImpressumTitle => 'Impressum';

  @override
  String registerLegalOptionalTitle(Object title) {
    return '$title · дополнительно';
  }

  @override
  String get registerErrOpenRequiredLegalDocs =>
      'Сначала открой и прочитай Условия использования и Политику конфиденциальности.';

  @override
  String registerLegalOpenFailed(Object document) {
    return 'Не удалось открыть $document.';
  }

  @override
  String get registerLegalAcceptedText =>
      'Я прочитал(а) и принимаю Условия использования и Политику конфиденциальности.';

  @override
  String get registerLegalOpenRequiredDocsText =>
      'Сначала открой и прочитай Условия использования и Политику конфиденциальности. Datenschutzerklärung и Impressum доступны как дополнительная правовая информация.';

  @override
  String get launcherDayGoals => 'Цели';

  @override
  String launcherPlannedHoursDescription(Object hours) {
    return 'План: $hours ч';
  }

  @override
  String get profileGdprSection => 'Конфиденциальность и GDPR';

  @override
  String get profileGdprExportTitle => 'Экспортировать мои данные';

  @override
  String get profileGdprExportSubtitle =>
      'Создаёт JSON-экспорт всех данных приложения, связанных с твоим аккаунтом.';

  @override
  String get profileGdprNotSignedInToast =>
      'Ты не вошёл в аккаунт. Экспорт данных невозможен.';

  @override
  String get profileGdprDialogTitle => 'GDPR-экспорт данных создан';

  @override
  String profileGdprDialogFileName(String fileName) {
    return 'Имя файла: $fileName';
  }

  @override
  String get profileGdprDialogBody =>
      'Экспорт создан в формате JSON и скопирован в буфер обмена.\n\nТеперь ты можешь вставить содержимое в файл с расширением .json.';

  @override
  String get profileGdprDialogPreviewLabel => 'Предпросмотр:';

  @override
  String get profileGdprCopyButton => 'Копировать';

  @override
  String get profileGdprDoneButton => 'Готово';

  @override
  String get profileGdprCopiedAgainToast =>
      'Экспорт данных снова скопирован в буфер обмена.';

  @override
  String get profileGdprCreatedToast =>
      'GDPR-экспорт данных создан и скопирован.';

  @override
  String profileGdprFailedToast(String error) {
    return 'Не удалось экспортировать данные: $error';
  }

  @override
  String get profileGdprExportNoteAccount =>
      'Этот экспорт содержит аутентифицированный аккаунт пользователя, профиль из public.users, все пользовательские таблицы приложения и справочные таблицы, необходимые для понимания экспортированных ответов.';

  @override
  String get profileGdprExportNoteRls =>
      'Экспорт ограничен правилами Supabase Row Level Security. Таблицы, которые не существуют или недоступны для чтения, возвращаются с записью _export_warning.';

  @override
  String get profileGdprExportNoteEncrypted =>
      'Зашифрованные поля encrypted_payload экспортируются в том виде, в котором они сохранены. Расшифровка зависит от реализации шифрования в приложении и активной пользовательской сессии.';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get profileFallbackName => 'Пользователь';

  @override
  String get profileNoEmail => 'Email не указан';

  @override
  String get personalData => 'Личные данные';

  @override
  String get name => 'Имя';

  @override
  String get enterName => 'Введите имя';

  @override
  String get age => 'Возраст';

  @override
  String get enterAge => 'Введите возраст';

  @override
  String get notSpecified => 'Не указан';

  @override
  String get lifeSpheres => 'Сферы жизни';

  @override
  String get mySpheres => 'Мои сферы';

  @override
  String get edit => 'Редактировать';

  @override
  String get habits => 'Привычки';

  @override
  String get myHabits => 'Мои привычки';

  @override
  String get noHabitsYet => 'Привычек пока нет';

  @override
  String get addHabitHint =>
      'Добавление привычек оставлено в текущем редакторе привычек.';

  @override
  String daysCount(int n) {
    return '$n дней';
  }

  @override
  String get focus => 'Фокус';

  @override
  String get targetHoursTitle => 'Норма часов в день';

  @override
  String get targetHoursSubtitle => 'Используется для расчёта прогресса';

  @override
  String get targetHoursField => 'Часы в день';

  @override
  String get hoursShort => 'ч';

  @override
  String get notifications => 'Уведомления';

  @override
  String get allowNotifications => 'Разрешить уведомления';

  @override
  String get notificationsSubtitle => 'Работает только пока вкладка открыта';

  @override
  String get eveningCheckIn => 'Вечерний чек-ин';

  @override
  String get eveningCheckInBody => 'Отметь настроение и заверши день спокойно.';

  @override
  String everyDayAt(String time) {
    return 'Каждый день в $time';
  }

  @override
  String get notificationsUnsupported =>
      'Уведомления в этой среде не поддерживаются.';

  @override
  String get notificationsEnabled => 'Уведомления разрешены.';

  @override
  String get notificationsDenied => 'Разрешение на уведомления не получено.';

  @override
  String get notificationsMasterSubtitleOn => 'Включены';

  @override
  String get notificationsMasterSubtitleOff => 'Выключены';

  @override
  String get notificationsSystemDisabledHint =>
      'Отключены в системных настройках iOS';

  @override
  String get openSystemSettings => 'Открыть настройки iOS';

  @override
  String get notificationsGoalsTitle => 'Напоминания о целях';

  @override
  String notificationsGoalsSubtitle(int minutes) {
    return 'За $minutes мин до начала';
  }

  @override
  String get notificationsReflectionTitle => 'Вечерняя рефлексия';

  @override
  String get notificationsHabitsTitle => 'Напоминания о привычках';

  @override
  String get notificationsMinutesPickerTitle => 'За сколько минут напоминать';

  @override
  String get app => 'Приложение';

  @override
  String get language => 'Язык';

  @override
  String get system => 'Системный';

  @override
  String get googleCalendarSubtitle => 'Экспорт целей в календарь';

  @override
  String get googleCalendarMovedHint =>
      'Google Calendar теперь находится в настройках профиля.';

  @override
  String get exportData => 'Экспортировать данные';

  @override
  String get exportDataSubtitle => 'JSON-экспорт всего аккаунта';

  @override
  String get exportCopied => 'Экспорт скопирован в буфер обмена.';

  @override
  String get exportFailed => 'Не удалось экспортировать данные';

  @override
  String get notSignedIn => 'Пользователь не авторизован.';

  @override
  String get legalDocuments => 'Правовые документы';

  @override
  String get openLinkFailed => 'Не удалось открыть ссылку.';

  @override
  String get signOut => 'Выйти из аккаунта';

  @override
  String get signOutConfirm => 'Ты точно хочешь выйти из аккаунта?';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountSubtitle => 'Все данные будут удалены безвозвратно';

  @override
  String get deleteAccountConfirm =>
      'Это действие нельзя отменить. Все данные аккаунта будут удалены безвозвратно.';

  @override
  String get cancel => 'Отмена';

  @override
  String get desiredBalance => 'Колесо жизни';

  @override
  String get desiredBalanceHint =>
      'Настрой колесо жизни по выбранным сферам. Общая сумма не может быть больше 100%.';

  @override
  String get lifeWheelTapHint =>
      'Нажми на сектор или сферу ниже, чтобы задать точный процент.';

  @override
  String get outOfHundredPercent => 'из 100%';

  @override
  String get percent => 'Процент';

  @override
  String lifeWheelPercentLimit(int maxAllowed) {
    return 'Можно указать от 0 до $maxAllowed%. Общая сумма баланса не может превышать 100%.';
  }

  @override
  String get save => 'Сохранить';

  @override
  String get saving => 'Сохранение…';

  @override
  String get newHabit => 'Новая привычка';

  @override
  String get editHabit => 'Редактировать привычку';

  @override
  String get habitName => 'Название привычки';

  @override
  String get negativeHabit => 'Анти-привычка';

  @override
  String get deleteHabit => 'Удалить привычку?';

  @override
  String deleteHabitQuestion(String title) {
    return 'Привычка \"$title\" будет удалена.';
  }

  @override
  String get delete => 'Удалить';

  @override
  String get spaces => 'Пространства';

  @override
  String get space => 'Пространство';

  @override
  String get mySpaces => 'Мои пространства';

  @override
  String get spacesHint =>
      'Создавай общие пространства для дома, семьи, поездок и проектов.';

  @override
  String get noSpacesYet => 'Пространств пока нет';

  @override
  String get noSpacesHint =>
      'Создай первое пространство и пригласи туда других пользователей.';

  @override
  String get createSpace => 'Создать пространство';

  @override
  String get editSpace => 'Редактировать пространство';

  @override
  String get deleteSpace => 'Удалить пространство';

  @override
  String get leaveSpace => 'Покинуть пространство';

  @override
  String get deleteSpaceConfirm =>
      'Пространство и связанные с ним общие данные будут удалены. Это действие нельзя отменить.';

  @override
  String get leaveSpaceConfirm =>
      'Ты больше не будешь видеть задачи и данные этого пространства.';

  @override
  String get spaceName => 'Название пространства';

  @override
  String get spaceNameRequired => 'Введите название пространства';

  @override
  String get spaceDescription => 'Описание';

  @override
  String get spaceIcon => 'Иконка';

  @override
  String get spaceColor => 'Цвет HEX';

  @override
  String get spaceValidity => 'Срок действия';

  @override
  String get noDeadline => 'Бессрочно';

  @override
  String get spaceNoDeadline => 'Бессрочное пространство';

  @override
  String get setDeadline => 'Задать срок';

  @override
  String get changeDeadline => 'Изменить срок';

  @override
  String spaceValidUntil(String date) {
    return 'Действует до $date';
  }

  @override
  String get spaceValidityHint =>
      'После этой даты пространство останется в базе, но исчезнет с экранов и из выбора задач.';

  @override
  String get spaceTapToManage => 'Нажми, чтобы управлять участниками';

  @override
  String get spaceManageSubtitle => 'Участники и приглашения';

  @override
  String get members => 'Участники';

  @override
  String get noMembersYet => 'Участников пока нет';

  @override
  String get inviteMember => 'Пригласить';

  @override
  String inviteMemberHint(String spaceName) {
    return 'Приглашение будет отправлено в пространство «$spaceName».';
  }

  @override
  String get email => 'Email';

  @override
  String get sendInvite => 'Отправить';

  @override
  String get enterValidEmail => 'Введите корректный email';

  @override
  String get incomingInvites => 'Входящие приглашения';

  @override
  String get spaceInviteSubtitle => 'Вас пригласили в общее пространство';

  @override
  String get acceptInvite => 'Принять';

  @override
  String get declineInvite => 'Отклонить';

  @override
  String get spaceInviteAccepted => 'Приглашение принято.';

  @override
  String get spaceInviteSent => 'Приглашение отправлено.';

  @override
  String get you => 'Вы';

  @override
  String get spaceRoleOwner => 'Владелец';

  @override
  String get spaceRoleAdmin => 'Администратор';

  @override
  String get spaceRoleMember => 'Участник';

  @override
  String get spaceRoleViewer => 'Только просмотр';

  @override
  String get spacesLoadFailed => 'Не удалось загрузить пространства';

  @override
  String get spaceMembersLoadFailed => 'Не удалось загрузить участников';

  @override
  String get spaceSaveFailed => 'Не удалось сохранить пространство';

  @override
  String get spaceActionFailed => 'Не удалось выполнить действие';

  @override
  String get spaceInviteSendFailed => 'Не удалось отправить приглашение';

  @override
  String get spaceInviteAcceptFailed => 'Не удалось принять приглашение';

  @override
  String get spaceInviteDeclineFailed => 'Не удалось отклонить приглашение';

  @override
  String get noData => 'Нет данных';

  @override
  String get dayGoalsHeaderTitle => 'Задачи на день';

  @override
  String get dayGoalsAllHiddenHint =>
      'Все видимые задачи скрыты. Отключи фильтр «Скрыть выполненные».';

  @override
  String get dayGoalsEmptyHint =>
      'На этот день пока нет задач. Добавь первую задачу через кнопку ниже.';

  @override
  String get dayGoalsStatTotal => 'Всего';

  @override
  String get dayGoalsStatDone => 'Готово';

  @override
  String get dayGoalsStatLeft => 'Осталось';

  @override
  String dayGoalsHoursLeftLabel(String hours) {
    return 'Осталось часов: $hours';
  }

  @override
  String get dayGoalsFilterAll => 'Все';

  @override
  String get dayGoalsFilterPersonal => 'Личные';

  @override
  String get dayGoalsFilterAllSpheres => 'Все сферы';

  @override
  String dayGoalsLaneLeftBadge(int count) {
    return 'Ост. $count';
  }

  @override
  String dayGoalsLaneDoneBadge(int count) {
    return 'Гот. $count';
  }

  @override
  String get dayGoalsLaneInProgress => '⚡ В работе';

  @override
  String get dayGoalsLaneInProgressEmpty =>
      'Здесь появятся активные задачи этого блока';

  @override
  String get dayGoalsLaneDoneTitle => '✅ Готово';

  @override
  String get dayGoalsLaneDoneEmpty =>
      'Здесь будут завершённые задачи после фокуса-блока';

  @override
  String get dayGoalsSpaceMetaLabel => '👥 Пространство';

  @override
  String get dayGoalsCompletedLabel => 'Выполнено';

  @override
  String get dayGoalsNotifSoftAskTitle => 'Не пропусти ни одной цели';

  @override
  String get dayGoalsNotifSoftAskBody =>
      'Ladna напомнит о цели за 15 минут до начала — прямо как будильник, только для дел.';

  @override
  String get dayGoalsNotifSoftAskEnable => 'Включить напоминания';

  @override
  String get dayGoalsNotifSoftAskDismiss => 'Не сейчас';

  @override
  String get dayGoalsPeriodMorning => 'Утро';

  @override
  String get dayGoalsPeriodDay => 'День';

  @override
  String get dayGoalsPeriodEvening => 'Вечер';

  @override
  String get dayGoalsSphereLifePersonal => 'Личное';

  @override
  String get dayGoalsSphereTravel => 'Путешествия';

  @override
  String get dayGoalsSphereHome => 'Дом';

  @override
  String dayGoalsMinutesShort(int minutes) {
    return '$minutes мин';
  }

  @override
  String get registerErrNameMin2 => 'Имя должно содержать минимум 2 символа.';

  @override
  String launcherPlanHours(String hours) {
    return 'План: $hours ч';
  }

  @override
  String get launcherGoalsAndTasks => 'Цели и задачи';

  @override
  String get launcherPersonal => 'Личное';

  @override
  String get launcherReportsTab => 'Отчёты';

  @override
  String get launcherBudget => 'Бюджет';

  @override
  String get launcherQuickActions => 'Быстрые действия';

  @override
  String get launcherBulkAdd => 'Массовое добавление';

  @override
  String get launcherBulkAddSubtitle => 'Расходы + Задачи + Настроение';

  @override
  String get launcherAiWeeklyPlan => 'AI-план на неделю';

  @override
  String get launcherAiWeeklyPlanSubtitle => 'Анализ целей и прогресса';

  @override
  String get launcherAiInsights => 'AI-инсайты';

  @override
  String get launcherNavAndActions => 'Навигация и действия';

  @override
  String get navMenu => 'Меню';

  @override
  String get navPersonal => 'Личное';

  @override
  String get lifeBlocksSetupTitle => 'Что будем отслеживать?';

  @override
  String get lifeBlocksSetupSubtitle =>
      'Выбери сферы жизни. Ladna будет строить главную страницу, цели и отчёты вокруг них.';

  @override
  String get lifeBlocksSetupContinue => 'Продолжить';

  @override
  String get lifeBlocksSetupHint => 'Минимум 1 сфера';

  @override
  String get goalsScreenGoalsAndTasks => 'Цели и задачи';

  @override
  String get goalsScreenTasks => 'Задачи';

  @override
  String get goalsScreenDashboard => 'Дашборд';

  @override
  String get goalsScreenWeek => 'Неделя';

  @override
  String get goalsScreenMonth => 'Месяц';

  @override
  String get goalsScreenCalendar => 'Календарь';

  @override
  String get goalsScreenWeekView => 'Неделя';

  @override
  String get goalsScreenMonthView => 'Дни месяца';

  @override
  String get goalsScreenNoTasks => 'Нет задач';

  @override
  String get goalsScreenCompleted => 'выполнено';

  @override
  String get goalsScreenWeekSummary => 'Итог недели';

  @override
  String get goalsScreenThisWeek => 'Эта неделя';

  @override
  String get goalsScreenTodayShort => 'сег';

  @override
  String get goalsScreenAll => 'Все';

  @override
  String get goalsScreenPersonalTasks => 'Личные';

  @override
  String get goalsScreenUpToOneMonth => 'До 1 мес';

  @override
  String get goalsScreenUpToSixMonths => 'До 6 мес';

  @override
  String get goalsScreenYearPlus => 'На год+';

  @override
  String get goalsScreenBySpheres => 'По сферам';

  @override
  String get goalsScreenHide => '';

  @override
  String get goalsScreenProgress => 'Прогресс';

  @override
  String get goalsScreenAdd => 'Добавить';

  @override
  String get goalsScreenNoGoalsYet => 'Целей пока нет';

  @override
  String get goalsScreenNoGoalsYetSub =>
      'Добавь первую цель через кнопку ниже.';

  @override
  String get goalsScreenNewGoal => 'Новая цель';

  @override
  String get goalsScreenEditGoal => 'Редактировать цель';

  @override
  String get goalsScreenTitle => 'Название';

  @override
  String get goalsScreenDescription => 'Описание';

  @override
  String get goalsScreenSphere => 'Сфера';

  @override
  String get goalsScreenHorizon => 'Горизонт';

  @override
  String get goalsScreenDeleteGoal => 'Удалить цель';

  @override
  String get goalsScreenDeleteGoalQuestion =>
      'Эта цель будет удалена. Связанные ежедневные задачи останутся без связи с большой целью.';

  @override
  String goalsScreenCompletedTasks(int done, int total) {
    return '$done задач выполнено из $total';
  }

  @override
  String goalsScreenGoalsCount(int n) {
    return '$n цели';
  }

  @override
  String get moodScore1 => 'Очень тяжело';

  @override
  String get moodScore2 => 'Сложно';

  @override
  String get moodScore3 => 'Нейтрально';

  @override
  String get moodScore4 => 'Хорошо';

  @override
  String get moodScore5 => 'Отлично';

  @override
  String get moodScaleHint =>
      'Шкала настроения: 1 — очень тяжело, 3 — нейтрально, 5 — отлично.';

  @override
  String get moodHowAreYouTitle => 'Как ты сегодня?';

  @override
  String get moodWhatInfluencedLabel => 'Что повлияло на настроение?';

  @override
  String get moodRecentEntriesTitle => 'Последние записи';

  @override
  String get moodNoEntriesHint =>
      'Пока нет записей. Отметь настроение сегодня.';

  @override
  String get moodTodayLabel => 'Сегодня';

  @override
  String get moodSelectedDayLabel => 'Выбранный день';

  @override
  String get reportsScreenReports => 'Отчёты';

  @override
  String get reportsScreenDayShort => 'День';

  @override
  String get reportsScreenWeekShort => 'Нед';

  @override
  String get reportsScreenMonthShort => 'Мес';

  @override
  String get reportsScreenSummary => 'Сводка';

  @override
  String get reportsScreenProgress => 'Прогресс';

  @override
  String get reportsScreenMood => 'Настроение';

  @override
  String get reportsScreenTasksDone => 'Задач выполнено';

  @override
  String get reportsScreenFocusHours => 'Фокус-часов';

  @override
  String get reportsScreenOutOf => 'из';

  @override
  String get reportsScreenPeriodAverage => 'Среднее за период';

  @override
  String get reportsScreenMoodAverage => 'Среднее настроение';

  @override
  String get reportsScreenOutOfFiveAverage => 'из 5 в среднем';

  @override
  String get reportsScreenOutOfFive => 'из 5 баллов';

  @override
  String get reportsScreenHowMoodScoreWorks => 'Как считается настроение';

  @override
  String get reportsScreenMoodScoreExplanation =>
      'Пользователь выбирает одно из 5 настроений. Каждой иконке соответствует балл: 1 — очень тяжело, 2 — сложно, 3 — нейтрально, 4 — хорошо, 5 — отлично. В отчётах показывается среднее значение за выбранный период.';

  @override
  String get reportsScreenMoodVeryLow => 'Очень тяжело';

  @override
  String get reportsScreenMoodLow => 'Сложно';

  @override
  String get reportsScreenMoodNeutral => 'Нейтрально';

  @override
  String get reportsScreenMoodGood => 'Хорошо';

  @override
  String get reportsScreenMoodGreat => 'Отлично';

  @override
  String get reportsScreenPeriodEfficiency => 'Эффективность периода';

  @override
  String get reportsScreenPlan => 'План';

  @override
  String get reportsScreenFact => 'Факт';

  @override
  String get reportsScreenTimeBySphere => 'Время по сферам';

  @override
  String get reportsScreenTopProductiveDays => 'Топ-3 продуктивных дня';

  @override
  String get reportsScreenAiObservation => 'AI-наблюдение';

  @override
  String get reportsScreenPeriodStatistics => 'Статистика периода';

  @override
  String get reportsScreenExtendedAiObservationSchedule =>
      'Это твоя статистика за период. Расширенное AI-наблюдение обновится в воскресенье.';

  @override
  String get reportsScreenAiLoading => 'Готовлю персональное наблюдение…';

  @override
  String get reportsScreenAiUnavailable =>
      'AI-наблюдение пока недоступно. Проверь подключение к функции или попробуй обновить позже.';

  @override
  String get reportsScreenInsight => 'Инсайт';

  @override
  String get reportsScreenPattern => 'Паттерн';

  @override
  String get reportsScreenPeriodTasks => 'Задачи периода';

  @override
  String get reportsScreenDone => 'выполнено';

  @override
  String get reportsScreenPeriodProgress => 'Прогресс периода';

  @override
  String get reportsScreenTempoBelowNorm => 'Темп ниже нормы';

  @override
  String get reportsScreenTempoGood => 'Темп в норме';

  @override
  String get reportsScreenDetails => 'Детали';

  @override
  String get reportsScreenAvgTimePerTask => 'Среднее время / задачу';

  @override
  String get reportsScreenDoneOnTime => 'Выполнено в срок';

  @override
  String get reportsScreenMoved => 'Перенесено';

  @override
  String get reportsScreenCompleted => 'Выполнено';

  @override
  String get reportsScreenForThisPeriod => 'за этот период';

  @override
  String get reportsScreenBestStreak => 'Лучший страйк';

  @override
  String get reportsScreenDaysInARow => 'дней подряд';

  @override
  String get reportsScreenByHabits => 'По привычкам';

  @override
  String get reportsScreenStreaksFourWeeks => 'Страйки за 4 недели';

  @override
  String get reportsScreenFourWeeksAgo => '4 нед. назад';

  @override
  String get reportsScreenMissed => 'пропуск';

  @override
  String get reportsScreenToday => 'сегодня';

  @override
  String get reportsScreenBestDay => 'Лучший день';

  @override
  String get reportsScreenWeekDynamics => 'Динамика недели';

  @override
  String get reportsScreenByDays => 'По дням';

  @override
  String get reportsScreenOnTime => 'В срок';

  @override
  String get reportsScreenTasks => 'Задачи';

  @override
  String get reportsScreenHours => 'Часы';

  @override
  String get reportsScreenCurrentPeriodShort => 'эта';

  @override
  String get reportsScreenPreviousPeriodShort => 'прош.';

  @override
  String get reportsScreenCorrelations => 'Корреляции';

  @override
  String get reportsScreenStreaks => 'Страйки';

  @override
  String get reportsScreenWeakLink => 'Слабое звено';

  @override
  String get reportsScreenNoDataYet => 'Пока недостаточно данных';

  @override
  String get reportsScreenPulse => 'ПУЛЬС';

  @override
  String get reportsScreenMonthEfficiency => 'Эффективность месяца';

  @override
  String get reportsScreenFactVsDesiredBalance =>
      'Факт против желаемого баланса';

  @override
  String get reportsScreenBalancePlanFactHint =>
      'План — тонкая метка, факт — заполненная полоса.';

  @override
  String get reportsScreenBalanceEmptyHint =>
      'Задай желаемый баланс сфер в профиле — здесь появится сравнение факта с планом.';

  @override
  String get reportsScreenPlanLegend => 'план';

  @override
  String get reportsScreenFactLegend => 'факт';

  @override
  String get reportsScreenOverageLegend => 'перебор';

  @override
  String get reportsScreenSleepSevenPlus => 'Сон 7+ часов';

  @override
  String get reportsScreenHabitCompletion => 'Выполнение привычек';

  @override
  String get reportsScreenWeekStart => 'Пн–Вт';

  @override
  String get reportsScreenMoreStableThanWeekend => 'Стабильнее конца недели';

  @override
  String get reportsScreenHighLoad => 'Высокая нагрузка';

  @override
  String get reportsScreenTaskImpact => 'Влияние задач';

  @override
  String get reportsScreenDaysWithHabits => 'Дни с привычками';

  @override
  String get reportsScreenMoodHigher => 'Настроение выше';

  @override
  String get reportsScreenOpenTasks => 'Незакрытые задачи';

  @override
  String get reportsScreenMoodImpact => 'Влияние на настроение';

  @override
  String get reportsScreenExpensesAboveNorm => 'Расходы выше нормы';

  @override
  String get reportsScreenNextDayMood => 'Настроение следующего дня';

  @override
  String get reportsScreenComparisonTitleDay => 'Этот день vs прошлый';

  @override
  String get reportsScreenComparisonTitleWeek => 'Эта неделя vs прошлая';

  @override
  String get reportsScreenComparisonTitleMonth => 'Этот месяц vs прошлый';

  @override
  String reportsScreenBestDaySubtitle(int tasks, String hours) {
    return '$tasks задач · $hours ч фокуса';
  }

  @override
  String reportsScreenMonthEfficiencySubtitle(
    int completed,
    String outOf,
    int total,
    int daysLeft,
  ) {
    return '$completed задач $outOf $total · осталось $daysLeft дней';
  }

  @override
  String reportsScreenWeakLinkRecommendation(String label, int pct) {
    return '$label — $pct% за период. Привяжи к самой простой привычке.';
  }

  @override
  String get reportsScreenSummaryInsight =>
      'Ты продуктивнее во вторник и среду. Перенеси самые важные задачи на начало недели.';

  @override
  String get reportsScreenProgressInsight =>
      'Задачи по одной сфере откладываются чаще других. Попробуй закрепить для них отдельный утренний блок.';

  @override
  String get reportsScreenHabitsInsight =>
      'В дни, когда выполнены привычки, продуктивность обычно выше. Начинай день с самой простой привычки.';

  @override
  String get reportsScreenMoodInsight =>
      'Настроение выше в дни с выполненными привычками. Сохраняй маленький ритуал утром.';

  @override
  String get budgetCategoryNameLabel => 'Название';

  @override
  String get navGoals => 'Цели';

  @override
  String get navMood => 'Настроение';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navReports => 'Отчёты';

  @override
  String get navExpenses => 'Расходы';

  @override
  String get goalsDeleteConfirmBodyShort =>
      'Будет удалено без возможности восстановления.';

  @override
  String get paywallTitle => 'Ladna Premium';

  @override
  String get paywallSubtitle =>
      'Первые 30 дней бесплатно, затем подписка. Отменить можно в любой момент.';

  @override
  String get paywallOpenButton => 'Начать бесплатный период';

  @override
  String get paywallRestoreButton => 'Восстановить покупки';

  @override
  String get paywallLogoutButton => 'Выйти из аккаунта';
}
