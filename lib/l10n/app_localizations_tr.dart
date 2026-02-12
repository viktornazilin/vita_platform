// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Nest App';

  @override
  String get login => 'Giriş yap';

  @override
  String get register => 'Hesap oluştur';

  @override
  String get home => 'Ana sayfa';

  @override
  String get budgetSetupTitle => 'Bütçe ve kavanozlar';

  @override
  String get budgetSetupSaved => 'Ayarlar kaydedildi';

  @override
  String get budgetSetupSaveError => 'Kaydetme hatası';

  @override
  String get budgetIncomeCategoriesTitle => 'Gelir kategorileri';

  @override
  String get budgetIncomeCategoriesSubtitle => 'Gelir eklerken kullanılır';

  @override
  String get settingsLanguageTitle => 'Dil';

  @override
  String get settingsLanguageSubtitle =>
      'Uygulama dilini seç. “Sistem” cihaz dilini kullanır.';

  @override
  String get budgetExpenseCategoriesTitle => 'Gider kategorileri';

  @override
  String get budgetExpenseCategoriesSubtitle =>
      'Limitler, harcamayı kontrol altında tutmana yardımcı olur';

  @override
  String get budgetJarsTitle => 'Birikim kavanozları';

  @override
  String get budgetJarsSubtitle =>
      'Yüzde, otomatik eklenen serbest fon payını ifade eder';

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
  String get budgetAddJar => 'Kavanoz ekle';

  @override
  String get budgetJarAdded => 'Kavanoz eklendi';

  @override
  String budgetJarAddFailed(Object error) {
    return 'Eklenemedi: $error';
  }

  @override
  String get budgetJarDeleted => 'Kavanoz silindi';

  @override
  String budgetJarDeleteFailed(Object error) {
    return 'Silinemedi: $error';
  }

  @override
  String get budgetNoJarsTitle => 'Henüz kavanoz yok';

  @override
  String get budgetNoJarsSubtitle =>
      'İlk birikim hedefini oluştur — sana ulaşmanda yardımcı olacağız.';

  @override
  String get budgetSetOrChangeLimit => 'Limit belirle/değiştir';

  @override
  String get budgetDeleteCategoryTitle => 'Kategori silinsin mi?';

  @override
  String budgetCategoryLabel(Object name) {
    return 'Kategori: $name';
  }

  @override
  String get budgetDeleteJarTitle => 'Kavanoz silinsin mi?';

  @override
  String budgetJarLabel(Object title) {
    return 'Kavanoz: $title';
  }

  @override
  String budgetJarSummary(Object saved, Object percent, Object targetPart) {
    return 'Biriken: $saved ₽ • Yüzde: %$percent$targetPart';
  }

  @override
  String get commonAdd => 'Ekle';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonEdit => 'Düzenle';

  @override
  String get commonLoading => 'yükleniyor…';

  @override
  String get commonSaving => 'Kaydediliyor…';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonRetry => 'Tekrar dene';

  @override
  String get commonUpdate => 'Güncelle';

  @override
  String get commonCollapse => 'Daralt';

  @override
  String get commonDots => '...';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonNext => 'İleri';

  @override
  String get commonDone => 'Bitti';

  @override
  String get commonChange => 'Değiştir';

  @override
  String get commonDate => 'Tarih';

  @override
  String get commonRefresh => 'Yenile';

  @override
  String get commonDash => '—';

  @override
  String get commonPick => 'Seç';

  @override
  String get commonRemove => 'Kaldır';

  @override
  String get commonOr => 'veya';

  @override
  String get commonCreate => 'Oluştur';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonCloseTooltip => 'Kapat';

  @override
  String get commonTitle => 'Başlık';

  @override
  String get commonDeleteConfirmTitle => 'Girdi silinsin mi?';

  @override
  String get dayGoalsAllLifeBlocks => 'Tüm alanlar';

  @override
  String get dayGoalsEmpty => 'Bu gün için hedef yok';

  @override
  String dayGoalsAddFailed(Object error) {
    return 'Hedef eklenemedi: $error';
  }

  @override
  String get dayGoalsUpdated => 'Hedef güncellendi';

  @override
  String dayGoalsUpdateFailed(Object error) {
    return 'Hedef güncellenemedi: $error';
  }

  @override
  String get dayGoalsDeleted => 'Hedef silindi';

  @override
  String dayGoalsDeleteFailed(Object error) {
    return 'Silinemedi: $error';
  }

  @override
  String dayGoalsToggleFailed(Object error) {
    return 'Durum değiştirilemedi: $error';
  }

  @override
  String get dayGoalsDeleteConfirmTitle => 'Hedef silinsin mi?';

  @override
  String get dayGoalsFabAddTitle => 'Hedef ekle';

  @override
  String get dayGoalsFabAddSubtitle => 'Manuel oluştur';

  @override
  String get dayGoalsFabScanTitle => 'Tara';

  @override
  String get dayGoalsFabScanSubtitle => 'Günlük fotoğrafı';

  @override
  String get dayGoalsFabCalendarTitle => 'Google Calendar';

  @override
  String get dayGoalsFabCalendarSubtitle => 'Bugünkü hedefleri içe/dışa aktar';

  @override
  String get epicIntroSkip => 'Geç';

  @override
  String get epicIntroSubtitle =>
      'Düşünceler için bir yuva. Hedeflerin,\nhayallerin ve planların — sakin ve farkındalıkla — büyüdüğü bir yer.';

  @override
  String get epicIntroPrimaryCta => 'Yolculuğumu başlat';

  @override
  String get epicIntroLater => 'Sonra';

  @override
  String get epicIntroSecondaryCta => 'Giriş yap';

  @override
  String get epicIntroFooter =>
      'Ayarlar’dan prologa her zaman geri dönebilirsin.';

  @override
  String get homeMoodSaved => 'Ruh hali kaydedildi';

  @override
  String homeMoodSaveFailed(Object error) {
    return 'Kaydedilemedi: $error';
  }

  @override
  String get homeTodayAndWeekTitle => 'Bugün ve hafta';

  @override
  String get homeTodayAndWeekSubtitle =>
      'Hızlı bir özet — tüm önemli metrikler burada';

  @override
  String get homeMetricMoodTitle => 'Ruh hali';

  @override
  String get homeMoodNoEntry => 'kayıt yok';

  @override
  String get homeMoodNoNote => 'not yok';

  @override
  String get homeMoodHasNote => 'not var';

  @override
  String get homeMetricTasksTitle => 'Görevler';

  @override
  String get homeMetricHoursPerDayTitle => 'Saat/gün';

  @override
  String get homeMetricEfficiencyTitle => 'Verimlilik';

  @override
  String homeEfficiencyPlannedHours(Object hours) {
    return 'plan $hours sa';
  }

  @override
  String get homeMoodTodayTitle => 'Bugünkü ruh hali';

  @override
  String get homeMoodNoTodayEntry => 'Bugün için kayıt yok';

  @override
  String get homeMoodEntryNoNote => 'Kayıt var (not yok)';

  @override
  String get homeMoodQuickHint => 'Hızlı bir check-in ekle — 10 saniye sürer';

  @override
  String get homeMoodUpdateHint =>
      'Güncelleyebilirsin — bugünkü kaydı üzerine yazar';

  @override
  String get homeMoodNoteLabel => 'Not (isteğe bağlı)';

  @override
  String get homeMoodNoteHint => 'Ruh halini ne etkiledi?';

  @override
  String get homeOpenMoodHistoryCta => 'Ruh hali geçmişini aç';

  @override
  String get homeWeekSummaryTitle => 'Hafta özeti';

  @override
  String get homeOpenReportsCta => 'Detaylı raporları aç';

  @override
  String get homeWeekExpensesTitle => 'Haftalık harcamalar';

  @override
  String get homeNoExpensesThisWeek => 'Bu hafta harcama yok';

  @override
  String get homeOpenExpensesCta => 'Harcamaları aç';

  @override
  String homeExpensesTotal(Object total) {
    return 'Toplam: $total €';
  }

  @override
  String homeExpensesAvgPerDay(Object avg) {
    return 'Ort/gün: $avg €';
  }

  @override
  String get homeInsightsTitle => 'İçgörüler';

  @override
  String homeTopCategory(Object category, Object amount) {
    return '• En yüksek kategori: $category — $amount €';
  }

  @override
  String homePeakExpense(Object day, Object amount) {
    return '• En yüksek harcama: $day — $amount €';
  }

  @override
  String get homeOpenDetailedExpensesCta => 'Detaylı harcamaları aç';

  @override
  String get homeWeekCardTitle => 'Hafta';

  @override
  String get homeWeekLoadFailedTitle => 'İstatistikler yüklenemedi';

  @override
  String get homeWeekLoadFailedSubtitle =>
      'İnternetini kontrol et veya daha sonra tekrar dene.';

  @override
  String get gcalTitle => 'Google Calendar';

  @override
  String get gcalHeaderImport =>
      'Takvimindeki etkinlikleri bul ve hedef olarak içe aktar.';

  @override
  String get gcalHeaderExport =>
      'Bir dönem seç ve uygulamadaki hedefleri Google Calendar’a dışa aktar.';

  @override
  String get gcalModeImport => 'İçe aktar';

  @override
  String get gcalModeExport => 'Dışa aktar';

  @override
  String get gcalCalendarLabel => 'Takvim';

  @override
  String get gcalPrimaryCalendar => 'Birincil (varsayılan)';

  @override
  String get gcalPeriodLabel => 'Dönem';

  @override
  String get gcalRangeToday => 'Bugün';

  @override
  String get gcalRangeNext7 => 'Sonraki 7 gün';

  @override
  String get gcalRangeNext30 => 'Sonraki 30 gün';

  @override
  String get gcalRangeCustom => 'Dönem seç...';

  @override
  String get gcalDefaultLifeBlockLabel =>
      'Varsayılan yaşam alanı (içe aktarma için)';

  @override
  String get gcalLifeBlockForGoalLabel => 'Bu hedef için yaşam alanı';

  @override
  String get gcalEventsNotLoaded => 'Etkinlikler yüklenmedi';

  @override
  String get gcalConnectToLoadEvents =>
      'Etkinlikleri yüklemek için hesabını bağla';

  @override
  String get gcalExportHint =>
      'Dışa aktarma, seçilen takvimde seçilen dönem için etkinlikler oluşturur.';

  @override
  String get gcalConnect => 'Bağlan';

  @override
  String get gcalConnected => 'Bağlandı';

  @override
  String get gcalFindEvents => 'Etkinlikleri bul';

  @override
  String get gcalImport => 'İçe aktar';

  @override
  String get gcalExport => 'Dışa aktar';

  @override
  String get gcalNoTitle => 'Başlıksız';

  @override
  String gcalImportedGoalsCount(Object count) {
    return 'İçe aktarılan hedefler: $count';
  }

  @override
  String gcalExportedGoalsCount(Object count) {
    return 'Dışa aktarılan hedefler: $count';
  }

  @override
  String get launcherQuickFunctionsTitle => 'Hızlı işlemler';

  @override
  String get launcherQuickFunctionsSubtitle =>
      'Tek dokunuşla gezinme ve işlemler';

  @override
  String get launcherSectionsTitle => 'Bölümler';

  @override
  String get launcherQuickTitle => 'Hızlı';

  @override
  String get launcherHome => 'Ana sayfa';

  @override
  String get launcherGoals => 'Hedefler';

  @override
  String get launcherMood => 'Ruh hali';

  @override
  String get launcherProfile => 'Profil';

  @override
  String get launcherInsights => 'İçgörüler';

  @override
  String get launcherReports => 'Raporlar';

  @override
  String get launcherMassAddTitle => 'Gün için toplu ekle';

  @override
  String get launcherMassAddSubtitle => 'Harcamalar + Hedefler + Ruh hali';

  @override
  String get launcherAiPlanTitle => 'Hafta/ay için AI planı';

  @override
  String get launcherAiPlanSubtitle => 'Hedefler, anket ve ilerleme analizi';

  @override
  String get launcherAiInsightsTitle => 'AI içgörüleri';

  @override
  String get launcherAiInsightsSubtitle =>
      'Etkinliklerin hedefleri ve ilerlemeyi nasıl etkilediği';

  @override
  String get launcherRecurringGoalTitle => 'Tekrarlayan hedef';

  @override
  String get launcherRecurringGoalSubtitle => 'Birden fazla gün için plan yap';

  @override
  String get launcherGoogleCalendarSyncTitle =>
      'Google Calendar senkronizasyonu';

  @override
  String get launcherGoogleCalendarSyncSubtitle => 'Hedefleri takvime aktar';

  @override
  String get launcherNoDatesToCreate =>
      'Oluşturulacak tarih yok (son tarih/ayarları kontrol et).';

  @override
  String launcherCreateSeriesFailed(Object error) {
    return 'Hedef serisi oluşturulamadı: $error';
  }

  @override
  String launcherSaveError(Object error) {
    return 'Kaydetme hatası: $error';
  }

  @override
  String launcherCreatedGoalsCount(Object count) {
    return 'Oluşturulan hedefler: $count';
  }

  @override
  String launcherSavedSummary(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodPart,
  ) {
    return 'Kaydedildi: $expenses gider, $incomes gelir, $goals hedef, $habits alışkanlık$moodPart';
  }

  @override
  String get homeTitleHome => 'Ana sayfa';

  @override
  String get homeTitleGoals => 'Hedefler';

  @override
  String get homeTitleMood => 'Ruh hali';

  @override
  String get homeTitleProfile => 'Profil';

  @override
  String get homeTitleReports => 'Raporlar';

  @override
  String get homeTitleExpenses => 'Harcamalar';

  @override
  String get homeTitleApp => 'MyNEST';

  @override
  String get homeSignOutTooltip => 'Çıkış yap';

  @override
  String get homeSignOutTitle => 'Çıkış yapılsın mı?';

  @override
  String get homeSignOutSubtitle => 'Mevcut oturumun sonlandırılacak.';

  @override
  String get homeSignOutConfirm => 'Çıkış yap';

  @override
  String homeSignOutFailed(Object error) {
    return 'Çıkış yapılamadı: $error';
  }

  @override
  String get homeQuickActionsTooltip => 'Hızlı işlemler';

  @override
  String get expensesTitle => 'Harcamalar';

  @override
  String get expensesPickDate => 'Tarih seç';

  @override
  String get expensesCommitTooltip => 'Kavanoz dağıtımını kilitle';

  @override
  String get expensesCommitUndoTooltip => 'Kilidi geri al';

  @override
  String get expensesBudgetSettings => 'Bütçe ayarları';

  @override
  String get expensesCommitDone => 'Dağıtım kilitlendi';

  @override
  String get expensesCommitUndone => 'Kilit kaldırıldı';

  @override
  String get expensesMonthSummary => 'Aylık özet';

  @override
  String expensesIncomeLegend(Object value) {
    return 'Gelir $value €';
  }

  @override
  String expensesExpenseLegend(Object value) {
    return 'Gider $value €';
  }

  @override
  String expensesFreeLegend(Object value) {
    return 'Serbest $value €';
  }

  @override
  String expensesDaySum(Object value) {
    return 'Gün toplamı: $value €';
  }

  @override
  String get expensesNoTxForDay => 'Bu gün için işlem yok';

  @override
  String get expensesDeleteTxTitle => 'İşlem silinsin mi?';

  @override
  String expensesDeleteTxBody(Object category, Object amount) {
    return '$category — $amount €';
  }

  @override
  String get expensesCategoriesMonthTitle => 'Aylık gider kategorileri';

  @override
  String get expensesNoCategoryData => 'Henüz kategori verisi yok';

  @override
  String get expensesJarsTitle => 'Birikim kavanozları';

  @override
  String get expensesNoJars => 'Henüz kavanoz yok';

  @override
  String get expensesCommitShort => 'Kilitle';

  @override
  String get expensesCommitUndoShort => 'Geri al';

  @override
  String get expensesAddIncome => 'Gelir ekle';

  @override
  String get expensesAddExpense => 'Gider ekle';

  @override
  String get loginTitle => 'Giriş yap';

  @override
  String get loginEmailLabel => 'E-posta';

  @override
  String get loginPasswordLabel => 'Şifre';

  @override
  String get loginShowPassword => 'Şifreyi göster';

  @override
  String get loginHidePassword => 'Şifreyi gizle';

  @override
  String get loginForgotPassword => 'Şifreni mi unuttun?';

  @override
  String get loginCreateAccount => 'Hesap oluştur';

  @override
  String get loginBtnSignIn => 'Giriş yap';

  @override
  String get loginContinueGoogle => 'Google ile devam et';

  @override
  String get loginContinueApple => 'Apple ID ile devam et';

  @override
  String get loginErrEmailRequired => 'E-postayı gir';

  @override
  String get loginErrEmailInvalid => 'Geçersiz e-posta';

  @override
  String get loginErrPassRequired => 'Şifreyi gir';

  @override
  String get loginErrPassMin6 => 'En az 6 karakter';

  @override
  String get loginResetTitle => 'Şifre kurtarma';

  @override
  String get loginResetSend => 'Gönder';

  @override
  String get loginResetSent =>
      'Şifre sıfırlama e-postası gönderildi. Gelen kutunu kontrol et.';

  @override
  String loginResetFailed(Object error) {
    return 'E-posta gönderilemedi: $error';
  }

  @override
  String get moodTitle => 'Ruh hali';

  @override
  String get moodOnePerDay => '1 kayıt = 1 gün';

  @override
  String get moodHowDoYouFeel => 'Nasıl hissediyorsun?';

  @override
  String get moodNoteLabel => 'Not (isteğe bağlı)';

  @override
  String get moodNoteHint => 'Ruh halini ne etkiledi?';

  @override
  String get moodSaved => 'Ruh hali kaydedildi';

  @override
  String get moodUpdated => 'Kayıt güncellendi';

  @override
  String get moodHistoryTitle => 'Ruh hali geçmişi';

  @override
  String get moodTapToEdit => 'Düzenlemek için dokun';

  @override
  String get moodNoNote => 'Not yok';

  @override
  String get moodEditTitle => 'Kaydı düzenle';

  @override
  String get moodEmptyTitle => 'Henüz kayıt yok';

  @override
  String get moodEmptySubtitle => 'Bir tarih seç, ruh halini seç ve kaydet.';

  @override
  String moodErrSaveFailed(Object error) {
    return 'Ruh hali kaydedilemedi: $error';
  }

  @override
  String moodErrUpdateFailed(Object error) {
    return 'Kayıt güncellenemedi: $error';
  }

  @override
  String moodErrDeleteFailed(Object error) {
    return 'Kayıt silinemedi: $error';
  }

  @override
  String get onbTopTitle => 'Kahramanın Başlangıcı';

  @override
  String get onbErrSaveFailed => 'Yanıtların kaydedilemedi';

  @override
  String get onbProfileTitle => 'Seni tanıyalım';

  @override
  String get onbProfileSubtitle =>
      'Bu, profilin ve kişiselleştirme için yardımcı olur';

  @override
  String get onbNameLabel => 'İsim';

  @override
  String get onbNameHint => 'Örneğin: Viktor';

  @override
  String get onbAgeLabel => 'Yaş';

  @override
  String get onbAgeHint => 'Örneğin: 26';

  @override
  String get onbNameNote => 'İsmini daha sonra profilinden değiştirebilirsin.';

  @override
  String get onbBlocksTitle => 'Hangi yaşam alanlarını takip etmek istiyorsun?';

  @override
  String get onbBlocksSubtitle =>
      'Bu, hedeflerin ve görevlerin temelini oluşturacak';

  @override
  String get onbPrioritiesTitle =>
      'Önümüzdeki 3–6 ayda senin için en önemli olan nedir?';

  @override
  String get onbPrioritiesSubtitle =>
      'En fazla üç tane seç — bu, önerileri etkiler';

  @override
  String get onbPriorityHealth => 'Sağlık';

  @override
  String get onbPriorityCareer => 'Kariyer';

  @override
  String get onbPriorityMoney => 'Para';

  @override
  String get onbPriorityFamily => 'Aile';

  @override
  String get onbPriorityGrowth => 'Gelişim';

  @override
  String get onbPriorityLove => 'Aşk';

  @override
  String get onbPriorityCreativity => 'Yaratıcılık';

  @override
  String get onbPriorityBalance => 'Denge';

  @override
  String onbGoalsBlockTitle(Object block) {
    return '“$block” alanındaki hedefler';
  }

  @override
  String get onbGoalsBlockSubtitle =>
      'Odak: taktik → orta vadeli → uzun vadeli';

  @override
  String get onbGoalLongLabel => 'Uzun vadeli hedef (6–24 ay)';

  @override
  String get onbGoalLongHint => 'Örneğin: Almanca seviyesini B2’ye çıkarmak';

  @override
  String get onbGoalMidLabel => 'Orta vadeli hedef (2–6 ay)';

  @override
  String get onbGoalMidHint => 'Örneğin: A2→B1’i bitirip sınavı geçmek';

  @override
  String get onbGoalTacticalLabel => 'Taktik hedef (2–4 hafta)';

  @override
  String get onbGoalTacticalHint => 'Örneğin: 12×30 dk + 2 konuşma kulübü';

  @override
  String get onbWhyLabel => 'Bu neden önemli? (isteğe bağlı)';

  @override
  String get onbWhyHint => 'Motivasyon/anlam — yolda kalmana yardımcı olur';

  @override
  String get onbOptionalNote => 'Boş bırakıp “İleri”ye dokunabilirsin.';

  @override
  String get registerTitle => 'Hesap oluştur';

  @override
  String get registerNameLabel => 'İsim';

  @override
  String get registerEmailLabel => 'E-posta';

  @override
  String get registerPasswordLabel => 'Şifre';

  @override
  String get registerConfirmPasswordLabel => 'Şifreyi doğrula';

  @override
  String get registerShowPassword => 'Şifreyi göster';

  @override
  String get registerHidePassword => 'Şifreyi gizle';

  @override
  String get registerBtnSignUp => 'Kayıt ol';

  @override
  String get registerContinueGoogle => 'Google ile devam et';

  @override
  String get registerContinueApple => 'Apple ID ile devam et';

  @override
  String get registerContinueAppleIos => 'Apple ID ile devam et (iOS)';

  @override
  String get registerHaveAccountCta => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get registerErrNameRequired => 'İsmini gir';

  @override
  String get registerErrEmailRequired => 'E-postanı gir';

  @override
  String get registerErrEmailInvalid => 'Geçersiz e-posta';

  @override
  String get registerErrPassRequired => 'Bir şifre gir';

  @override
  String get registerErrPassMin8 => 'En az 8 karakter';

  @override
  String get registerErrPassNeedLower => 'Küçük harf ekle (a-z)';

  @override
  String get registerErrPassNeedUpper => 'Büyük harf ekle (A-Z)';

  @override
  String get registerErrPassNeedDigit => 'Rakam ekle (0-9)';

  @override
  String get registerErrConfirmRequired => 'Şifreyi tekrar gir';

  @override
  String get registerErrPasswordsMismatch => 'Şifreler eşleşmiyor';

  @override
  String get registerErrAcceptTerms =>
      'Şartlar ve Gizlilik Politikasını kabul etmelisin';

  @override
  String get registerAppleOnlyIos =>
      'Apple ID yalnızca iPhone/iPad’de kullanılabilir (sadece iOS)';

  @override
  String get welcomeAppName => 'VitaPlatform';

  @override
  String get welcomeSubtitle =>
      'Hedeflerini, ruh halini ve zamanını yönet\n— hepsi tek yerde';

  @override
  String get welcomeSignIn => 'Giriş yap';

  @override
  String get welcomeCreateAccount => 'Hesap oluştur';

  @override
  String get habitsWeekTitle => 'Alışkanlıklar';

  @override
  String get habitsWeekTopTitle => 'Alışkanlıklar (bu hafta öne çıkan)';

  @override
  String get habitsWeekEmptyHint =>
      'En az bir alışkanlık ekle — ilerlemen burada görünecek.';

  @override
  String get habitsWeekFooterHint =>
      'Son 7 gündeki en aktif alışkanlıklarını gösteriyoruz.';

  @override
  String get mentalWeekTitle => 'Ruh sağlığı';

  @override
  String mentalWeekLoadError(Object error) {
    return 'Yükleme hatası: $error';
  }

  @override
  String get mentalWeekNoAnswers =>
      'Bu hafta için yanıt bulunamadı (mevcut user_id için).';

  @override
  String get mentalWeekYesNoHeader => 'Evet/Hayır (hafta)';

  @override
  String get mentalWeekScalesHeader => 'Ölçekler (trend)';

  @override
  String get mentalWeekFooterHint =>
      'Ekranı sade tutmak için sadece birkaç soru gösteriyoruz.';

  @override
  String get mentalWeekNoData => 'Veri yok';

  @override
  String mentalWeekYesCount(Object yes, Object total) {
    return 'Evet: $yes/$total';
  }

  @override
  String get moodWeekTitle => 'Haftalık ruh hali';

  @override
  String moodWeekMarkedCount(Object filled, Object total) {
    return 'Kaydedilen: $filled/$total';
  }

  @override
  String get moodWeekAverageDash => 'Ortalama: —';

  @override
  String moodWeekAverageValue(Object avg) {
    return 'Ortalama: $avg/5';
  }

  @override
  String get moodWeekFooterHint =>
      'Bu hızlı bir özet. Detaylar aşağıda, geçmişte.';

  @override
  String get goalsByBlockTitle => 'Alana göre hedefler';

  @override
  String get goalsAddTooltip => 'Hedef ekle';

  @override
  String get goalsHorizonTacticalShort => 'Taktik';

  @override
  String get goalsHorizonMidShort => 'Orta vadeli';

  @override
  String get goalsHorizonLongShort => 'Uzun vadeli';

  @override
  String get goalsHorizonTacticalLong => '2–6 hafta';

  @override
  String get goalsHorizonMidLong => '3–6 ay';

  @override
  String get goalsHorizonLongLong => '1+ yıl';

  @override
  String get goalsEditorNewTitle => 'Yeni hedef';

  @override
  String get goalsEditorEditTitle => 'Hedefi düzenle';

  @override
  String get goalsEditorLifeBlockLabel => 'Alan';

  @override
  String get goalsEditorHorizonLabel => 'Ufuk';

  @override
  String get goalsEditorTitleLabel => 'Başlık';

  @override
  String get goalsEditorTitleHint => 'Örn. İngilizceyi B2’ye yükseltmek';

  @override
  String get goalsEditorDescLabel => 'Açıklama (isteğe bağlı)';

  @override
  String get goalsEditorDescHint =>
      'Kısaca: tam olarak ne ve başarıyı nasıl ölçeceğiz';

  @override
  String goalsEditorDeadlineLabel(Object date) {
    return 'Son tarih: $date';
  }

  @override
  String goalsDeadlineInline(Object date) {
    return 'Son tarih: $date';
  }

  @override
  String get goalsEmptyAllHint =>
      'Henüz hedef yok. Seçilen alanlar için ilk hedefini ekle.';

  @override
  String get goalsNoBlocksToShow => 'Gösterilecek uygun alan yok.';

  @override
  String get goalsNoGoalsForBlock => 'Seçilen alan için hedef yok.';

  @override
  String get goalsDeleteConfirmTitle => 'Hedef silinsin mi?';

  @override
  String goalsDeleteConfirmBody(Object title) {
    return '“$title” silinecek ve geri alınamayacak.';
  }

  @override
  String get habitsTitle => 'Alışkanlıklar';

  @override
  String get habitsEmptyHint => 'Henüz alışkanlık yok. İlkini ekle.';

  @override
  String get habitsEditorNewTitle => 'Yeni alışkanlık';

  @override
  String get habitsEditorEditTitle => 'Alışkanlığı düzenle';

  @override
  String get habitsEditorTitleLabel => 'Başlık';

  @override
  String get habitsEditorTitleHint => 'Örn. Sabah antrenmanı';

  @override
  String get habitsNegativeLabel => 'Olumsuz alışkanlık';

  @override
  String get habitsNegativeHint => 'Takip edip azaltmak istiyorsan işaretle.';

  @override
  String get habitsPositiveHint =>
      'Güçlendirmek için olumlu/nötr bir alışkanlık.';

  @override
  String get habitsNegativeShort => 'Olumsuz';

  @override
  String get habitsPositiveShort => 'Olumlu/nötr';

  @override
  String get habitsDeleteConfirmTitle => 'Alışkanlık silinsin mi?';

  @override
  String habitsDeleteConfirmBody(Object title) {
    return '“$title” silinecek ve geri alınamayacak.';
  }

  @override
  String get habitsFooterHint =>
      'Daha sonra ana ekranda alışkanlık “filtreleme” ekleyeceğiz.';

  @override
  String get profileTitle => 'Profilim';

  @override
  String get profileNameLabel => 'İsim';

  @override
  String get profileNameTitle => 'İsim';

  @override
  String get profileNamePrompt => 'Sana nasıl hitap edelim?';

  @override
  String get profileAgeLabel => 'Yaş';

  @override
  String get profileAgeTitle => 'Yaş';

  @override
  String get profileAgePrompt => 'Yaşını gir';

  @override
  String get profileAccountSection => 'Hesap';

  @override
  String get profileSeenPrologueTitle => 'Prolog tamamlandı';

  @override
  String get profileSeenPrologueSubtitle =>
      'Bunu manuel olarak değiştirebilirsin';

  @override
  String get profileFocusSection => 'Odak';

  @override
  String get profileTargetHoursLabel => 'Günlük hedef saat';

  @override
  String profileTargetHoursValue(Object hours) {
    return '$hours sa';
  }

  @override
  String get profileTargetHoursTitle => 'Günlük saat hedefi';

  @override
  String get profileTargetHoursFieldLabel => 'Saat';

  @override
  String get profileQuestionnaireSection => 'Anket ve yaşam alanları';

  @override
  String get profileQuestionnaireNotDoneTitle => 'Henüz anketi tamamlamadın.';

  @override
  String get profileQuestionnaireCta => 'Şimdi tamamla';

  @override
  String get profileLifeBlocksTitle => 'Yaşam alanları';

  @override
  String get profileLifeBlocksHint => 'örn. sağlık, kariyer, aile';

  @override
  String get profilePrioritiesTitle => 'Öncelikler';

  @override
  String get profilePrioritiesHint => 'örn. spor, finans, okuma';

  @override
  String get profileDangerZoneTitle => 'Tehlike bölgesi';

  @override
  String get profileDeleteAccountTitle => 'Hesap silinsin mi?';

  @override
  String get profileDeleteAccountBody =>
      'Bu işlem geri alınamaz.\nŞunlar silinecek: hedefler, alışkanlıklar, ruh hali, gider/gelir, kavanozlar, AI planları, XP ve profilin.';

  @override
  String get profileDeleteAccountConfirm => 'Kalıcı olarak sil';

  @override
  String get profileDeleteAccountCta => 'Hesabı ve tüm verileri sil';

  @override
  String get profileDeletingAccount => 'Siliniyor…';

  @override
  String get profileDeleteAccountFootnote =>
      'Silme işlemi geri alınamaz. Verilerin Supabase’den kalıcı olarak silinecek.';

  @override
  String get profileAccountDeletedToast => 'Hesap silindi';

  @override
  String get lifeBlockHealth => 'Sağlık';

  @override
  String get lifeBlockCareer => 'Kariyer';

  @override
  String get lifeBlockFamily => 'Aile';

  @override
  String get lifeBlockFinance => 'Finans';

  @override
  String get lifeBlockLearning => 'Gelişim';

  @override
  String get lifeBlockSocial => 'Sosyal';

  @override
  String get lifeBlockRest => 'Dinlenme';

  @override
  String get lifeBlockBalance => 'Denge';

  @override
  String get lifeBlockLove => 'Aşk';

  @override
  String get lifeBlockCreativity => 'Yaratıcılık';

  @override
  String get lifeBlockGeneral => 'Genel';

  @override
  String get addDayGoalTitle => 'Yeni günlük hedef';

  @override
  String get addDayGoalFieldTitle => 'Başlık *';

  @override
  String get addDayGoalTitleHint => 'Örn.: Antrenman / İş / Çalışma';

  @override
  String get addDayGoalFieldDescription => 'Açıklama';

  @override
  String get addDayGoalDescriptionHint => 'Kısaca: tam olarak ne yapılmalı';

  @override
  String get addDayGoalStartTime => 'Başlangıç saati';

  @override
  String get addDayGoalLifeBlock => 'Yaşam alanı';

  @override
  String get addDayGoalImportance => 'Önem';

  @override
  String get addDayGoalEmotion => 'Duygu';

  @override
  String get addDayGoalHours => 'Saat';

  @override
  String get addDayGoalEnterTitle => 'Bir başlık gir';

  @override
  String get addExpenseNewTitle => 'Yeni gider';

  @override
  String get addExpenseEditTitle => 'Gideri düzenle';

  @override
  String get addExpenseAmountLabel => 'Tutar';

  @override
  String get addExpenseAmountInvalid => 'Geçerli bir tutar gir';

  @override
  String get addExpenseCategoryLabel => 'Kategori';

  @override
  String get addExpenseCategoryRequired => 'Bir kategori seç';

  @override
  String get addExpenseCreateCategoryTooltip => 'Kategori oluştur';

  @override
  String get addExpenseNoteLabel => 'Not';

  @override
  String get addExpenseNewCategoryTitle => 'Yeni kategori';

  @override
  String get addExpenseCategoryNameLabel => 'İsim';

  @override
  String get addIncomeNewTitle => 'Yeni gelir';

  @override
  String get addIncomeEditTitle => 'Geliri düzenle';

  @override
  String get addIncomeSubtitle => 'Tutar, kategori ve not';

  @override
  String get addIncomeAmountLabel => 'Tutar';

  @override
  String get addIncomeAmountHint => 'örn. 1200.50';

  @override
  String get addIncomeAmountInvalid => 'Geçerli bir tutar gir';

  @override
  String get addIncomeCategoryLabel => 'Kategori';

  @override
  String get addIncomeCategoryRequired => 'Bir kategori seç';

  @override
  String get addIncomeNoteLabel => 'Not';

  @override
  String get addIncomeNoteHint => 'İsteğe bağlı';

  @override
  String get addIncomeNewCategoryTitle => 'Yeni gelir kategorisi';

  @override
  String get addIncomeCategoryNameLabel => 'İsim';

  @override
  String get addIncomeCategoryNameHint => 'örn. Maaş, Freelance…';

  @override
  String get addIncomeCategoryNameEmpty => 'Bir kategori adı gir';

  @override
  String get addJarNewTitle => 'Yeni kavanoz';

  @override
  String get addJarEditTitle => 'Kavanozu düzenle';

  @override
  String get addJarSubtitle => 'Hedefi ve serbest paranın payını belirle';

  @override
  String get addJarNameLabel => 'İsim';

  @override
  String get addJarNameHint => 'örn. Seyahat, Acil durum fonu, Ev';

  @override
  String get addJarNameRequired => 'Bir isim gir';

  @override
  String get addJarPercentLabel => 'Serbest paranın payı, %';

  @override
  String get addJarPercentHint => 'Manuel ekliyorsan 0';

  @override
  String get addJarPercentRange => 'Yüzde 0 ile 100 arasında olmalı';

  @override
  String get addJarTargetLabel => 'Hedef tutar';

  @override
  String get addJarTargetHint => 'örn. 5000';

  @override
  String get addJarTargetHelper => 'Zorunlu';

  @override
  String get addJarTargetRequired => 'Bir hedef gir (pozitif sayı)';

  @override
  String get aiInsightTypeDataQuality => 'Veri kalitesi';

  @override
  String get aiInsightTypeRisk => 'Risk';

  @override
  String get aiInsightTypeEmotional => 'Duygular';

  @override
  String get aiInsightTypeHabit => 'Alışkanlıklar';

  @override
  String get aiInsightTypeGoal => 'Hedefler';

  @override
  String get aiInsightTypeDefault => 'İçgörü';

  @override
  String get aiInsightStrengthStrong => 'Güçlü etki';

  @override
  String get aiInsightStrengthNoticeable => 'Belirgin etki';

  @override
  String get aiInsightStrengthWeak => 'Zayıf etki';

  @override
  String get aiInsightStrengthLowConfidence => 'Düşük güven';

  @override
  String aiInsightStrengthPercent(int value) {
    return '$value%';
  }

  @override
  String get aiInsightEvidenceTitle => 'Kanıt';

  @override
  String get aiInsightImpactPositive => 'Pozitif';

  @override
  String get aiInsightImpactNegative => 'Negatif';

  @override
  String get aiInsightImpactMixed => 'Karışık';

  @override
  String get aiInsightsTitle => 'AI içgörüleri';

  @override
  String get aiInsightsConfirmTitle => 'AI analizi çalıştırılsın mı?';

  @override
  String get aiInsightsConfirmBody =>
      'AI, seçilen dönem için görevlerini, alışkanlıklarını ve iyilik halini analiz eder ve içgörüleri kaydeder. Bu birkaç saniye sürebilir.';

  @override
  String get aiInsightsConfirmRun => 'Çalıştır';

  @override
  String get aiInsightsPeriod7 => '7 gün';

  @override
  String get aiInsightsPeriod30 => '30 gün';

  @override
  String get aiInsightsPeriod90 => '90 gün';

  @override
  String aiInsightsLastRun(String date) {
    return 'Son çalışma: $date';
  }

  @override
  String get aiInsightsEmptyNotRunTitle => 'AI henüz çalıştırılmadı';

  @override
  String get aiInsightsEmptyNotRunSubtitle =>
      'Bir dönem seç ve “Çalıştır”a dokun. İçgörüler kaydedilecek ve uygulamada kullanılabilir olacak.';

  @override
  String get aiInsightsCtaRun => 'Analizi çalıştır';

  @override
  String get aiInsightsEmptyNoInsightsTitle => 'Henüz içgörü yok';

  @override
  String get aiInsightsEmptyNoInsightsSubtitle =>
      'Daha fazla veri ekle (görevler, alışkanlıklar, yanıtlar) ve analizi tekrar çalıştır.';

  @override
  String get aiInsightsCtaRunAgain => 'Tekrar çalıştır';

  @override
  String aiInsightsErrorAi(String error) {
    return 'AI hatası: $error';
  }

  @override
  String get gcTitleDaySync => 'Google Calendar • gün senkronu';

  @override
  String get gcSubtitleImport =>
      'Bu günün etkinliklerini hedef olarak içe aktar.';

  @override
  String get gcSubtitleExport => 'Bu günün hedeflerini takvime dışa aktar.';

  @override
  String get gcModeImport => 'İçe aktar';

  @override
  String get gcModeExport => 'Dışa aktar';

  @override
  String get gcCalendarLabel => 'Takvim';

  @override
  String get gcCalendarPrimary => 'Birincil (varsayılan)';

  @override
  String get gcDefaultLifeBlockLabel =>
      'Varsayılan yaşam alanı (içe aktarma için)';

  @override
  String get gcLifeBlockForThisGoalLabel => 'Bu hedef için yaşam alanı';

  @override
  String get gcEventsNotLoaded => 'Etkinlikler yüklenmedi';

  @override
  String get gcConnectToLoadEvents =>
      'Etkinlikleri yüklemek için hesabını bağla';

  @override
  String get gcExportHint =>
      'Dışa aktarma, seçilen takvimde bu günün hedefleri için etkinlikler oluşturur.';

  @override
  String get gcConnect => 'Bağlan';

  @override
  String get gcConnected => 'Bağlandı';

  @override
  String get gcFindForDay => 'Gün için bul';

  @override
  String get gcImport => 'İçe aktar';

  @override
  String get gcExport => 'Dışa aktar';

  @override
  String get gcNoTitle => 'Başlık yok';

  @override
  String get gcLoadingDots => '...';

  @override
  String gcImportedGoals(int count) {
    return 'İçe aktarılan hedefler: $count';
  }

  @override
  String gcExportedGoals(int count) {
    return 'Dışa aktarılan hedefler: $count';
  }

  @override
  String get editGoalTitle => 'Hedefi düzenle';

  @override
  String get editGoalSectionDetails => 'Detaylar';

  @override
  String get editGoalSectionLifeBlock => 'Yaşam alanı';

  @override
  String get editGoalSectionParams => 'Ayarlar';

  @override
  String get editGoalFieldTitleLabel => 'Başlık';

  @override
  String get editGoalFieldTitleHint => 'Örnek: 3 km koşu';

  @override
  String get editGoalFieldDescLabel => 'Açıklama';

  @override
  String get editGoalFieldDescHint => 'Tam olarak ne yapılmalı?';

  @override
  String get editGoalFieldLifeBlockLabel => 'Yaşam alanı';

  @override
  String get editGoalFieldImportanceLabel => 'Önem';

  @override
  String get editGoalImportanceLow => 'Düşük';

  @override
  String get editGoalImportanceMedium => 'Orta';

  @override
  String get editGoalImportanceHigh => 'Yüksek';

  @override
  String get editGoalFieldEmotionLabel => 'Duygu';

  @override
  String get editGoalFieldEmotionHint => '😊';

  @override
  String get editGoalDurationHours => 'Süre (sa)';

  @override
  String get editGoalStartTime => 'Başlangıç';

  @override
  String get editGoalUntitled => 'Başlıksız';

  @override
  String get expenseCategoryOther => 'Diğer';

  @override
  String get goalStatusDone => 'Tamamlandı';

  @override
  String get goalStatusInProgress => 'Devam ediyor';

  @override
  String get actionDelete => 'Sil';

  @override
  String goalImportanceChip(int value) {
    return 'Öncelik $value/5';
  }

  @override
  String goalHoursChip(String value) {
    return 'Saat $value';
  }

  @override
  String get goalPathEmpty => 'Yolda hedef yok';

  @override
  String get timelineActionEdit => 'Düzenle';

  @override
  String get timelineActionDelete => 'Sil';

  @override
  String get saveBarSaving => 'Kaydediliyor…';

  @override
  String get saveBarSave => 'Kaydet';

  @override
  String get reportEmptyChartNotEnoughData => 'Yeterli veri yok';

  @override
  String limitSheetTitle(String categoryName) {
    return '“$categoryName” için limit';
  }

  @override
  String get limitSheetHintNoLimit => 'Boş bırak — limit yok';

  @override
  String get limitSheetFieldLabel => 'Aylık limit';

  @override
  String get limitSheetFieldHint => 'örn. 15000';

  @override
  String get limitSheetCtaNoLimit => 'Limit yok';
}
