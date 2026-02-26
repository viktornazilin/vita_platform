// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Nest App';

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
  String get dayGoalsFabAddTitle => 'Добавить цель';

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
  String get launcherGoals => 'Цели';

  @override
  String get launcherMood => 'Настроение';

  @override
  String get launcherProfile => 'Профиль';

  @override
  String get launcherInsights => 'Инсайты';

  @override
  String get launcherReports => 'Отчёты';

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
  String get homeTitleGoals => 'Цели';

  @override
  String get homeTitleMood => 'Настроение';

  @override
  String get homeTitleProfile => 'Профиль';

  @override
  String get homeTitleReports => 'Отчёты';

  @override
  String get homeTitleExpenses => 'Расходы';

  @override
  String get homeTitleApp => 'MyNEST';

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
  String get onbPriorityFamily => 'Семья';

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
  String get mentalWeekNoAnswers =>
      'За эту неделю нет найденных ответов (для текущего user_id).';

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
  String get lifeBlockFamily => 'Семья';

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
  String get addIncomeCategoryNameLabel => 'Name';

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
}
