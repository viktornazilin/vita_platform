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
  String get home => 'Ev';

  @override
  String get budgetSetupTitle => 'Bütçe ve kumbaralar';

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
      'Uygulama dilini seç. “Sistem”, cihaz dilini kullanır.';

  @override
  String get budgetExpenseCategoriesTitle => 'Gider kategorileri';

  @override
  String get budgetExpenseCategoriesSubtitle =>
      'Limitler harcamaları kontrol altında tutmana yardımcı olur';

  @override
  String get budgetJarsTitle => 'Birikim kumbaraları';

  @override
  String get budgetJarsSubtitle =>
      'Yüzde, serbest bakiyeden otomatik eklenecek paydır';

  @override
  String get loginOr => 'veya';

  @override
  String get registerLegalPrefix => 'Kayıt olarak ';

  @override
  String get registerLegalTerms => 'Kullanım Şartları';

  @override
  String get registerLegalMiddle => ' ve ';

  @override
  String get registerLegalPrivacy => 'Gizlilik Politikası';

  @override
  String get registerLegalSuffix => 'nı kabul etmiş olursun.';

  @override
  String get budgetNewIncomeCategory => 'Yeni gelir kategorisi';

  @override
  String get budgetNewExpenseCategory => 'Yeni gider kategorisi';

  @override
  String get budgetCategoryNameHint => 'Kategori adı';

  @override
  String get budgetAddJar => 'Kumbara ekle';

  @override
  String get budgetJarAdded => 'Kumbara eklendi';

  @override
  String budgetJarAddFailed(Object error) {
    return 'Eklenemedi: $error';
  }

  @override
  String get budgetJarDeleted => 'Kumbara silindi';

  @override
  String budgetJarDeleteFailed(Object error) {
    return 'Silinemedi: $error';
  }

  @override
  String get budgetNoJarsTitle => 'Henüz kumbara yok';

  @override
  String get budgetNoJarsSubtitle =>
      'İlk birikim hedefini oluştur — ona ulaşmana yardımcı olalım.';

  @override
  String get budgetSetOrChangeLimit => 'Limit belirle/değiştir';

  @override
  String get budgetDeleteCategoryTitle => 'Kategori silinsin mi?';

  @override
  String budgetCategoryLabel(Object name) {
    return 'Kategori: $name';
  }

  @override
  String get budgetDeleteJarTitle => 'Kumbara silinsin mi?';

  @override
  String budgetJarLabel(Object title) {
    return 'Kumbara: $title';
  }

  @override
  String budgetJarSummary(Object saved, Object percent, Object targetPart) {
    return 'Birikmiş: $saved ₽ • Yüzde: %$percent$targetPart';
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
  String get commonDone => 'Tamamlandı';

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
  String get commonDeleteConfirmTitle => 'Kayıt silinsin mi?';

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
  String get dayGoalsFabCalendarSubtitle =>
      'Bugünün hedeflerini içe/dışa aktar';

  @override
  String get epicIntroSkip => 'Atla';

  @override
  String get epicIntroSubtitle =>
      'Düşünceler için bir yuva. Hedeflerin,\nhayallerin ve planların sakin ve bilinçli şekilde büyüdüğü yer.';

  @override
  String get epicIntroPrimaryCta => 'Yolculuğuma başla';

  @override
  String get epicIntroLater => 'Daha sonra';

  @override
  String get epicIntroSecondaryCta => 'Giriş yap';

  @override
  String get epicIntroFooter => 'Prologa Ayarlar’dan her zaman dönebilirsin.';

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
      'Hızlı bir özet — tüm temel metrikler burada';

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
      'Güncelleyebilirsin — bugünkü kaydın üzerine yazılır';

  @override
  String get homeMoodNoteLabel => 'Not (isteğe bağlı)';

  @override
  String get homeMoodNoteHint => 'Durumunu ne etkiledi?';

  @override
  String get homeOpenMoodHistoryCta => 'Ruh hali geçmişini aç';

  @override
  String get homeWeekSummaryTitle => 'Hafta özeti';

  @override
  String get homeOpenReportsCta => 'Detaylı raporları aç';

  @override
  String get homeWeekExpensesTitle => 'Haftalık giderler';

  @override
  String get homeNoExpensesThisWeek => 'Bu hafta gider yok';

  @override
  String get homeOpenExpensesCta => 'Giderleri aç';

  @override
  String homeExpensesTotal(Object total) {
    return 'Toplam: $total €';
  }

  @override
  String homeExpensesAvgPerDay(Object avg) {
    return 'Ort./gün: $avg €';
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
  String get homeOpenDetailedExpensesCta => 'Detaylı giderleri aç';

  @override
  String get homeWeekCardTitle => 'Hafta';

  @override
  String get homeWeekLoadFailedTitle => 'İstatistikler yüklenemedi';

  @override
  String get homeWeekLoadFailedSubtitle =>
      'İnternet bağlantını kontrol et veya daha sonra tekrar dene.';

  @override
  String get gcalTitle => 'Google Calendar';

  @override
  String get gcalHeaderImport =>
      'Takvimindeki etkinlikleri bul ve hedef olarak içe aktar.';

  @override
  String get gcalHeaderExport =>
      'Bir dönem seç ve uygulamadaki hedefleri Google Calendar’a aktar.';

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
      'Varsayılan yaşam bloğu (içe aktarma için)';

  @override
  String get gcalLifeBlockForGoalLabel => 'Bu hedef için yaşam bloğu';

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
      'Tek dokunuşla navigasyon ve işlemler';

  @override
  String get launcherSectionsTitle => 'Bölümler';

  @override
  String get launcherQuickTitle => 'Hızlı';

  @override
  String get launcherHome => 'Ev';

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
  String get launcherMassAddTitle => 'Gün için toplu ekleme';

  @override
  String get launcherMassAddSubtitle => 'Giderler + Hedefler + Ruh hali';

  @override
  String get launcherAiPlanTitle => 'Hafta/ay için AI planı';

  @override
  String get launcherAiPlanSubtitle => 'Hedefler, anket ve ilerleme analizi';

  @override
  String get launcherAiInsightsTitle => 'AI içgörüleri';

  @override
  String get launcherAiInsightsSubtitle =>
      'Olayların hedefleri ve ilerlemeyi nasıl etkilediği';

  @override
  String get launcherRecurringGoalTitle => 'Tekrarlayan hedef';

  @override
  String get launcherRecurringGoalSubtitle =>
      'Birden çok gün için önceden planla';

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
  String get homeTitleHome => 'Ev';

  @override
  String get homeTitleGoals => 'Hedefler';

  @override
  String get homeTitleMood => 'Ruh hali';

  @override
  String get homeTitleProfile => 'Profil';

  @override
  String get homeTitleReports => 'Raporlar';

  @override
  String get homeTitleExpenses => 'Giderler';

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
  String get expensesTitle => 'Giderler';

  @override
  String get expensesPickDate => 'Tarih seç';

  @override
  String get expensesCommitTooltip => 'Kumbara dağılımını kilitle';

  @override
  String get expensesCommitUndoTooltip => 'Kilidi geri al';

  @override
  String get expensesBudgetSettings => 'Bütçe ayarları';

  @override
  String get expensesCommitDone => 'Dağılım kilitlendi';

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
    return 'Giderler $value €';
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
  String get expensesJarsTitle => 'Birikim kumbaraları';

  @override
  String get expensesNoJars => 'Henüz kumbara yok';

  @override
  String get expensesCommitShort => 'Kilitle';

  @override
  String get expensesCommitUndoShort => 'Kilidi geri al';

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
  String get loginErrEmailRequired => 'E-posta gir';

  @override
  String get loginErrEmailInvalid => 'Geçersiz e-posta';

  @override
  String get loginErrPassRequired => 'Şifre gir';

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
  String get moodEmptySubtitle =>
      'Bir tarih seç, ruh halini belirle ve kaydet.';

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
  String get onbTopTitle => '';

  @override
  String get onbErrSaveFailed => 'Yanıtların kaydedilemedi';

  @override
  String get onbProfileTitle => 'Birbirimizi tanıyalım';

  @override
  String get onbProfileSubtitle =>
      'Bu, profil ve kişiselleştirme için yardımcı olur';

  @override
  String get onbNameLabel => 'Ad';

  @override
  String get onbNameHint => 'Örneğin: Viktor';

  @override
  String get onbAgeLabel => 'Yaş';

  @override
  String get onbAgeHint => 'Örneğin: 26';

  @override
  String get onbNameNote => 'Adını daha sonra profilinden değiştirebilirsin.';

  @override
  String get onbBlocksTitle => 'Hangi yaşam alanlarını takip etmek istiyorsun?';

  @override
  String get onbBlocksSubtitle =>
      'Bu, hedeflerinin ve görevlerinin temeli olacak';

  @override
  String get onbPrioritiesTitle =>
      'Önümüzdeki 3–6 ayda senin için en önemli şey ne?';

  @override
  String get onbPrioritiesSubtitle =>
      'En fazla üç tane seç — bu önerileri etkiler';

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
  String get onbGoalLongHint => 'Örneğin: Almanca B2 seviyesine ulaşmak';

  @override
  String get onbGoalMidLabel => 'Orta vadeli hedef (2–6 ay)';

  @override
  String get onbGoalMidHint => 'Örneğin: A2→B1’i bitirmek ve sınavı geçmek';

  @override
  String get onbGoalTacticalLabel => 'Taktik hedef (2–4 hafta)';

  @override
  String get onbGoalTacticalHint =>
      'Örneğin: 12×30 dk seans + 2 konuşma kulübü';

  @override
  String get onbWhyLabel => 'Bu neden önemli? (isteğe bağlı)';

  @override
  String get onbWhyHint => 'Motivasyon/anlam — yolda kalmana yardımcı olur';

  @override
  String get onbOptionalNote => 'Boş bırakıp “İleri”ye dokunabilirsin.';

  @override
  String get registerTitle => 'Hesap oluştur';

  @override
  String get registerNameLabel => 'Ad';

  @override
  String get registerEmailLabel => 'E-posta';

  @override
  String get registerPasswordLabel => 'Şifre';

  @override
  String get registerConfirmPasswordLabel => 'Şifreyi onayla';

  @override
  String get registerShowPassword => 'Şifreyi göster';

  @override
  String get registerHidePassword => 'Şifreyi gizle';

  @override
  String get registerBtnSignUp => 'Kaydol';

  @override
  String get registerContinueGoogle => 'Google ile devam et';

  @override
  String get registerContinueApple => 'Apple ID ile devam et';

  @override
  String get registerContinueAppleIos => 'Apple ID ile devam et (iOS)';

  @override
  String get registerHaveAccountCta => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get registerErrNameRequired => 'Adını gir';

  @override
  String get registerErrEmailRequired => 'E-postanı gir';

  @override
  String get registerErrEmailInvalid => 'Geçersiz e-posta';

  @override
  String get registerErrPassRequired => 'Şifre gir';

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
      'Şartları ve Gizlilik Politikasını kabul etmelisin';

  @override
  String get registerAppleOnlyIos =>
      'Apple ID iPhone/iPad’de kullanılabilir (yalnızca iOS)';

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
  String get habitsWeekTopTitle => 'Alışkanlıklar (bu haftanın öne çıkanları)';

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
      'Ekranı sade tutmak için yalnızca birkaç soru gösteriyoruz.';

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
    return 'Kaydedildi: $filled/$total';
  }

  @override
  String get moodWeekAverageDash => 'Ortalama: —';

  @override
  String moodWeekAverageValue(Object avg) {
    return 'Ortalama: $avg/5';
  }

  @override
  String get moodWeekFooterHint =>
      'Bu hızlı bir özettir. Detaylar aşağıdaki geçmişte.';

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
  String get goalsEditorTitleHint => 'örn. İngilizceni B2 seviyesine çıkar';

  @override
  String get goalsEditorDescLabel => 'Açıklama (isteğe bağlı)';

  @override
  String get goalsEditorDescHint =>
      'Kısaca: tam olarak ne yapılacak ve başarı nasıl ölçülecek';

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
      'Henüz hedef yok. Seçili alanlar için ilk hedefini ekle.';

  @override
  String get goalsNoBlocksToShow => 'Gösterilecek uygun alan yok.';

  @override
  String get goalsNoGoalsForBlock => 'Seçili alan için hedef yok.';

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
  String get habitsEditorTitleHint => 'örn. Sabah antrenmanı';

  @override
  String get habitsNegativeLabel => 'Negatif alışkanlık';

  @override
  String get habitsNegativeHint => 'Takip edip azaltmak istiyorsan işaretle.';

  @override
  String get habitsPositiveHint =>
      'Güçlendirmek için pozitif/nötr bir alışkanlık.';

  @override
  String get habitsNegativeShort => 'Negatif';

  @override
  String get habitsPositiveShort => 'Pozitif/nötr';

  @override
  String get habitsDeleteConfirmTitle => 'Alışkanlık silinsin mi?';

  @override
  String habitsDeleteConfirmBody(Object title) {
    return '“$title” silinecek ve geri alınamayacak.';
  }

  @override
  String get habitsFooterHint =>
      'Daha sonra ana ekrana alışkanlık “filtreleme” ekleyeceğiz.';

  @override
  String get profileTitle => 'Profilim';

  @override
  String get profileNameLabel => 'Ad';

  @override
  String get profileNameTitle => 'Ad';

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
  String get profileQuestionnaireNotDoneTitle => 'Anketi henüz tamamlamadın.';

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
  String get profileDangerZoneTitle => 'Tehlikeli bölge';

  @override
  String get profileDeleteAccountTitle => 'Hesap silinsin mi?';

  @override
  String get profileDeleteAccountBody =>
      'Bu işlem geri alınamaz.\nŞunlar silinecek: hedefler, alışkanlıklar, ruh hali, gider/gelir, kumbaralar, AI planları, XP ve profilin.';

  @override
  String get profileDeleteAccountConfirm => 'Kalıcı olarak sil';

  @override
  String get profileDeleteAccountCta => 'Hesabı ve tüm verileri sil';

  @override
  String get profileDeletingAccount => 'Siliniyor…';

  @override
  String get profileDeleteAccountFootnote =>
      'Silme işlemi geri alınamaz. Verilerin Supabase’den kalıcı olarak kaldırılacak.';

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
  String get addDayGoalTitleHint => 'Örn.: Antrenman / İş / Ders';

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
  String get addDayGoalEnterTitle => 'Başlık gir';

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
  String get addExpenseCategoryNameLabel => 'Ad';

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
  String get addIncomeCategoryNameLabel => 'Kategori adı';

  @override
  String get addIncomeCategoryNameHint => 'örn. Maaş, Serbest iş…';

  @override
  String get addIncomeCategoryNameEmpty => 'Kategori adı gir';

  @override
  String get addJarNewTitle => 'Yeni kumbara';

  @override
  String get addJarEditTitle => 'Kumbarayı düzenle';

  @override
  String get addJarSubtitle =>
      'Hedefi ve serbest paradan ayrılacak payı belirle';

  @override
  String get addJarNameLabel => 'Ad';

  @override
  String get addJarNameHint => 'örn. Seyahat, Acil durum fonu, Ev';

  @override
  String get addJarNameRequired => 'Bir ad gir';

  @override
  String get addJarPercentLabel => 'Serbest paranın payı, %';

  @override
  String get addJarPercentHint => 'Elle ekliyorsan 0';

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
    return '%$value';
  }

  @override
  String get aiInsightEvidenceTitle => 'Kanıt';

  @override
  String get aiInsightImpactPositive => 'Pozitif';

  @override
  String get aiInsightImpactNegative => 'Negatif';

  @override
  String get aiInsightImpactMixed => 'Karma';

  @override
  String get aiInsightsTitle => 'AI içgörüleri';

  @override
  String get aiInsightsConfirmTitle => 'AI analizi çalıştırılsın mı?';

  @override
  String get aiInsightsConfirmBody =>
      'AI, seçilen dönem için görevlerini, alışkanlıklarını ve iyi oluşunu analiz edip içgörüleri kaydedecek. Bu birkaç saniye sürebilir.';

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
    return 'Son çalıştırma: $date';
  }

  @override
  String get aiInsightsEmptyNotRunTitle => 'AI henüz çalıştırılmadı';

  @override
  String get aiInsightsEmptyNotRunSubtitle =>
      'Bir dönem seç ve “Çalıştır”a dokun. İçgörüler kaydedilecek ve uygulamada görünecek.';

  @override
  String get aiInsightsCtaRun => 'Analizi çalıştır';

  @override
  String get aiInsightsEmptyNoInsightsTitle => 'Henüz içgörü yok';

  @override
  String get aiInsightsEmptyNoInsightsSubtitle =>
      'Daha fazla veri ekle (görevler, alışkanlıklar, soru yanıtları) ve analizi tekrar çalıştır.';

  @override
  String get aiInsightsCtaRunAgain => 'Tekrar çalıştır';

  @override
  String aiInsightsErrorAi(String error) {
    return 'AI hatası: $error';
  }

  @override
  String get gcTitleDaySync => 'Google Calendar • gün senkronizasyonu';

  @override
  String get gcSubtitleImport => 'Bu günün etkinliklerini hedeflere içe aktar.';

  @override
  String get gcSubtitleExport => 'Bu günün hedeflerini takvime aktar.';

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
      'Varsayılan yaşam bloğu (içe aktarma için)';

  @override
  String get gcLifeBlockForThisGoalLabel => 'Bu hedef için yaşam bloğu';

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
  String get editGoalSectionLifeBlock => 'Yaşam bloğu';

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
  String get editGoalFieldLifeBlockLabel => 'Yaşam bloğu';

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
  String get editGoalStartTime => 'Başla';

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
  String get limitSheetCtaNoLimit => 'Limitsiz';

  @override
  String get profileWebNotificationsSection => 'Bildirimler (Web)';

  @override
  String get profileWebNotificationsPermissionTitle => 'Bildirimlere izin ver';

  @override
  String get profileWebNotificationsPermissionSubtitle =>
      'Web’de ve yalnızca sekme açıkken çalışır.';

  @override
  String get profileWebNotificationsEveningTitle => 'Akşam check-in’i';

  @override
  String profileWebNotificationsEveningSubtitle(Object time) {
    return 'Her gün $time';
  }

  @override
  String get profileWebNotificationsChangeTime => 'Saati değiştir';

  @override
  String get profileWebNotificationsUnsupported =>
      'Tarayıcı bildirimleri bu sürümde kullanılamaz. Yalnızca Web sürümünde çalışır (ve sadece sekme açıkken).';

  @override
  String get lifeBlockEducation => 'Eğitim';

  @override
  String get lifeBlockHobbies => 'Hobiler';

  @override
  String get userGoalsTitle => 'Hedeflerim';

  @override
  String get userGoalsSubtitle =>
      'Yaşam alanlarına göre stratejik hedefler: kısa, orta ve uzun vadeli.';

  @override
  String get userGoalsNewTitle => 'Yeni hedef';

  @override
  String get userGoalsEditTitle => 'Hedefi düzenle';

  @override
  String get userGoalsCreateGoal => 'Hedef oluştur';

  @override
  String get userGoalsCreated => 'Hedef oluşturuldu';

  @override
  String userGoalsCreateError(Object error) {
    return 'Hedef oluşturulamadı: $error';
  }

  @override
  String get userGoalsUpdated => 'Hedef güncellendi';

  @override
  String userGoalsUpdateError(Object error) {
    return 'Hedef güncellenemedi: $error';
  }

  @override
  String userGoalsStatusChangeError(Object error) {
    return 'Durum değiştirilemedi: $error';
  }

  @override
  String userGoalsDeleteError(Object error) {
    return 'Hedef silinemedi: $error';
  }

  @override
  String get userGoalsDeleteConfirmTitle => 'Hedef silinsin mi?';

  @override
  String get userGoalsAllBlocks => 'Tümü';

  @override
  String get userGoalsAllHorizons => 'Tüm ufuklar';

  @override
  String get userGoalsLoadErrorTitle => 'Yükleme hatası';

  @override
  String get userGoalsNoActiveBlocksTitle => 'Aktif yaşam alanı yok';

  @override
  String get userGoalsNoActiveBlocksSubtitle =>
      'Önce kullanıcının takip ettiği yaşam alanlarını seç.';

  @override
  String get userGoalsEmptyTitle => 'Henüz hedef yok';

  @override
  String get userGoalsEmptySubtitle =>
      'Yaşam alanlarından biri için ilk stratejik hedefini oluştur.';

  @override
  String userGoalsDeadline(Object date) {
    return 'Son tarih: $date';
  }

  @override
  String get userGoalsStatusCompleted => 'Tamamlandı';

  @override
  String get userGoalsStatusActive => 'Aktif';

  @override
  String get userGoalsReopen => 'Yeniden aç';

  @override
  String get userGoalsComplete => 'Tamamla';

  @override
  String get userGoalsFieldLifeBlock => 'Yaşam alanı';

  @override
  String get userGoalsFieldHorizon => 'Ufuk';

  @override
  String get userGoalsFieldTitle => 'Hedef başlığı';

  @override
  String get userGoalsFieldDescription => 'Açıklama';

  @override
  String get userGoalsPickTargetDate => 'Hedef tarihi seç';

  @override
  String get userGoalsClearDate => 'Tarihi temizle';

  @override
  String get monthJanuary => 'Ocak';

  @override
  String get monthFebruary => 'Şubat';

  @override
  String get monthMarch => 'Mart';

  @override
  String get monthApril => 'Nisan';

  @override
  String get monthMay => 'Mayıs';

  @override
  String get monthJune => 'Haziran';

  @override
  String get monthJuly => 'Temmuz';

  @override
  String get monthAugust => 'Ağustos';

  @override
  String get monthSeptember => 'Eylül';

  @override
  String get monthOctober => 'Ekim';

  @override
  String get monthNovember => 'Kasım';

  @override
  String get monthDecember => 'Aralık';

  @override
  String get weekdayMonShort => 'Pzt';

  @override
  String get weekdayTueShort => 'Sal';

  @override
  String get weekdayWedShort => 'Çar';

  @override
  String get weekdayThuShort => 'Per';

  @override
  String get weekdayFriShort => 'Cum';

  @override
  String get weekdaySatShort => 'Cmt';

  @override
  String get weekdaySunShort => 'Paz';

  @override
  String get lifeBlockRelations => 'İlişkiler';

  @override
  String get lifeBlockSpirituality => 'Maneviyat';

  @override
  String goalsHeaderWeek(Object month, Object year, Object week) {
    return '$month $year, $week. hafta';
  }

  @override
  String get goalsQuickActionsTitle => 'Hızlı işlemler';

  @override
  String get goalsQuickActionsSubtitle => 'Tek dokunuşla ekle ve planla';

  @override
  String get goalsMassAddTitle => 'Toplu günlük giriş';

  @override
  String get goalsMassAddSubtitle =>
      'Giderler + Gelir + Görevler + Ruh hali + Alışkanlıklar';

  @override
  String goalsMassAddSaved(
    Object expenses,
    Object incomes,
    Object goals,
    Object habits,
    Object moodSuffix,
  ) {
    return 'Kaydedildi: $expenses gider, $incomes gelir, $goals görev, $habits alışkanlık$moodSuffix';
  }

  @override
  String get goalsMassAddMoodSuffix => ', ruh hali';

  @override
  String goalsSaveError(Object error) {
    return 'Kaydetme hatası: $error';
  }

  @override
  String get goalsRecurringGoalTitle => 'Tekrarlayan hedef';

  @override
  String get goalsRecurringGoalSubtitle => 'Birkaç gün sonrasını planla';

  @override
  String get goalsRecurringNoDates =>
      'Oluşturulacak tarih yok. Son tarihi veya ayarları kontrol et.';

  @override
  String goalsPlanHoursDescription(Object hours) {
    return 'Plan: $hours sa';
  }

  @override
  String goalsCreatedCount(Object count) {
    return 'Oluşturulan hedefler: $count';
  }

  @override
  String goalsRecurringCreateError(Object error) {
    return 'Hedef serisi oluşturulamadı: $error';
  }

  @override
  String get goalsSimpleTaskTitle => 'Hızlı görev';

  @override
  String get goalsSimpleTaskSubtitle =>
      'Sadece başlık, isteğe bağlı saat, Genel kategori';

  @override
  String get goalsSimpleTaskSheetSubtitle =>
      'Sadece başlık, isteğe bağlı saat. Varsayılan kategori Genel.';

  @override
  String get goalsTaskCreated => 'Görev oluşturuldu';

  @override
  String goalsTaskCreateError(Object error) {
    return 'Görev oluşturma hatası: $error';
  }

  @override
  String get goalsAll => 'Tümü';

  @override
  String get goalsViewDashboard => 'Panel';

  @override
  String get goalsViewCalendar => 'Takvim';

  @override
  String get goalsViewWeek => 'Hafta';

  @override
  String get goalsViewMonth => 'Ay';

  @override
  String get goalsByBlocksTitle => 'Yaşam alanına göre hedefler';

  @override
  String get goalsShow => 'Göster';

  @override
  String get goalsByBlocksHiddenHint =>
      'Gizli. Göstermek için 👁 simgesine dokun.';

  @override
  String get goalsEnterTaskTitle => 'Görev başlığı gir';

  @override
  String get goalsTaskTitleLabel => 'Görev başlığı';

  @override
  String get goalsAddTime => 'Saat ekle';

  @override
  String goalsTimeValue(Object time) {
    return 'Saat: $time';
  }

  @override
  String get goalsRemoveTime => 'Saati kaldır';

  @override
  String get goalsCreateTask => 'Görev oluştur';

  @override
  String get goalsWeekSummaryTitle => 'Hafta özeti';

  @override
  String goalsHoursShort(Object hours) {
    return '$hours sa';
  }

  @override
  String goalsHoursTargetSuffix(Object hours) {
    return ' / $hours sa';
  }

  @override
  String goalsHoursShortNoSpace(Object hours) {
    return '$hours sa';
  }

  @override
  String goalsHoursTargetSuffixNoSpace(Object hours) {
    return ' / $hours sa';
  }

  @override
  String get dayGoalsHiddenCompletedEmpty =>
      'Tüm görünür hedefler gizlenmiş. “Tamamlananları gizle” filtresini kapat.';

  @override
  String get dayGoalsKanbanOpenShort => 'Açık';

  @override
  String get dayGoalsKanbanDoneShort => 'Tamamlandı';

  @override
  String get dayGoalsKanbanOpenTitle => 'Devam ediyor';

  @override
  String get dayGoalsKanbanDoneTitle => 'Tamamlandı';

  @override
  String get dayGoalsKanbanOpenEmpty => 'Aktif görev yok';

  @override
  String get dayGoalsKanbanDoneEmpty => 'Burada henüz bir şey yok';

  @override
  String dayGoalsHoursShort(Object hours) {
    return '$hours sa';
  }

  @override
  String get dayGoalsSectionMorning => 'Sabah';

  @override
  String get dayGoalsSectionDay => 'Gün';

  @override
  String get dayGoalsSectionEvening => 'Akşam';

  @override
  String get dayGoalsSummaryTitle => 'Gün özeti';

  @override
  String get dayGoalsSummarySubtitle =>
      'Önemli olana odaklan ve günü yönetilebilir tut.';

  @override
  String get dayGoalsSummaryTotal => 'Toplam';

  @override
  String get dayGoalsSummaryDone => 'Tamamlandı';

  @override
  String get dayGoalsSummaryRemaining => 'Kalan';

  @override
  String dayGoalsRemainingHours(Object hours) {
    return 'Kalan saat: $hours';
  }

  @override
  String get dayGoalsHideCompleted => 'Tamamlananları gizle';

  @override
  String get reportsTabSummary => 'Özet';

  @override
  String get reportsTabRelations => 'İlişkiler';

  @override
  String get reportsTabProductivity => 'Üretkenlik';

  @override
  String get reportsTabExpenses => 'Giderler';

  @override
  String get reportsCompletedTasks => 'Tamamlanan görevler';

  @override
  String get reportsSpentHours => 'Harcanan saat';

  @override
  String get reportsEfficiency => 'Verimlilik';

  @override
  String get reportsPeriodEfficiency => 'Dönem verimliliği';

  @override
  String reportsPlanFactHours(Object planned, Object actual) {
    return 'Plan: $planned sa • Gerçek: $actual sa';
  }

  @override
  String get reportsAdditionalMetrics => 'Ek metrikler';

  @override
  String get reportsCorrelations => 'Metrikler arası ilişkiler';

  @override
  String get reportsCorrelationsHint =>
      'Bu bilimsel bir korelasyon değil; dönem bazlı anlaşılır karşılaştırmalardır.';

  @override
  String get reportsMoodProductivity => 'Ruh hali → Üretkenlik';

  @override
  String get reportsGoodMood => 'İyi';

  @override
  String get reportsBadMood => 'Kötü';

  @override
  String get reportsHabitsMoodProductivity =>
      'Alışkanlıklar → Ruh hali / Üretkenlik';

  @override
  String get reportsMoodMostlyHappy => 'çoğunlukla 😊';

  @override
  String get reportsMoodMostlySad => 'çoğunlukla 😞';

  @override
  String get reportsMoodMostlyNeutral => 'çoğunlukla 😐';

  @override
  String reportsHabitsComparisonHint(int percent) {
    return 'Alışkanlıkların ≥ %$percent tamamlandığı günlerle diğer günlerin karşılaştırması.';
  }

  @override
  String get reportsMoodHigh => 'Ruh hali (yüksek)';

  @override
  String get reportsMoodLow => 'Ruh hali (düşük)';

  @override
  String get reportsHoursHigh => 'Saat (yüksek)';

  @override
  String get reportsHoursLow => 'Saat (düşük)';

  @override
  String get reportsHabitsHighShort => 'alışkanlık yüksek';

  @override
  String get reportsHabitsLowShort => 'alışkanlık düşük';

  @override
  String get reportsMentalMood => 'Ruhsal durum → Ruh hali';

  @override
  String get reportsExpensesMood => 'Giderler → Ruh hali';

  @override
  String get reportsHappyDays => '😊 günler';

  @override
  String get reportsSadDays => '😞 günler';

  @override
  String get reportsCompletedByBlocks => 'Bloklara göre tamamlananlar';

  @override
  String get reportsNoCompletedTasks => 'Tamamlanan görev yok';

  @override
  String reportsTasksCount(int count) {
    return '$count görev';
  }

  @override
  String get reportsHoursByDays => 'Güne göre harcanan saat';

  @override
  String get reportsExpensesForPeriod => 'Dönem giderleri';

  @override
  String reportsTotalEuro(Object amount) {
    return 'Toplam: $amount €';
  }

  @override
  String reportsAvgExpensePerDay(Object amount) {
    return 'Ortalama gider/gün: $amount €';
  }

  @override
  String get reportsNoExpensesByCategory => 'Kategoriye göre gider yok';

  @override
  String get reportsAvgTimePerGoal => 'Görev başına ortalama süre';

  @override
  String get reportsOnTimeConditional => '“Zamanında” (yaklaşık)';

  @override
  String get reportsTop3ProductiveDays => 'EN üretken 3 gün';

  @override
  String reportsTopDayLine(int day, int month, int year, Object hours) {
    return '• $day.$month.$year: $hours sa';
  }

  @override
  String get reportsPeriodDay => 'Gün';

  @override
  String get reportsPeriodWeekShort => 'Hafta';

  @override
  String get reportsPeriodMonthShort => 'Ay';

  @override
  String get reportsForward => 'İleri';

  @override
  String get reportsTapChartSector => 'Grafik segmentine dokun';

  @override
  String get reportsLatestAiInsights => 'Son AI içgörüleri';

  @override
  String get reportsOpenAll => 'Tümünü aç';

  @override
  String get reportsInsightsLoadFailed => 'İçgörüler yüklenemedi';

  @override
  String get reportsNoSavedInsights => 'Henüz kayıtlı içgörü yok.';

  @override
  String get reportsRunAiInsightsHint =>
      '“AI içgörüleri”ni aç ve analiz çalıştır — sonra burada görünecekler.';

  @override
  String get reportsAiPeriod7Days => 'son 7 gün';

  @override
  String get reportsAiPeriod30Days => 'son 30 gün';

  @override
  String get reportsAiPeriod90Days => 'son 90 gün';

  @override
  String reportsHoursValue(Object hours) {
    return '$hours sa';
  }

  @override
  String reportsEuroValue(Object amount) {
    return '$amount €';
  }

  @override
  String get commonError => 'Hata';

  @override
  String get aiPlanConsentSaved => 'AI işleme onayı kaydedildi';

  @override
  String aiPlanConsentCheckFailed(Object error) {
    return 'AI işleme onayı kontrol edilemedi veya kaydedilemedi. users tablosunda ai_processing_consent, ai_processing_consent_at ve ai_processing_consent_version alanlarının olduğundan emin ol. Detaylar: $error';
  }

  @override
  String get aiPlanConsentTitle => 'AI işleme onayı';

  @override
  String get aiPlanConsentBody =>
      'AI planı oluşturmak için Nest hedeflerini, görevlerini, alışkanlıklarını, ruh halini ve diğer uygulama verilerini analiz edecek. Bu veriler yalnızca kişisel öneriler, planlar ve içgörüler oluşturmak için kullanılır.';

  @override
  String get aiPlanConsentDeclineBody =>
      'Onay vermeyebilirsin — bu durumda AI özelliği çalışmaz.';

  @override
  String get aiPlanConsentNotNow => 'Şimdi değil';

  @override
  String get aiPlanConsentAgree => 'Kabul ediyorum';

  @override
  String aiPlanOpenLinkFailed(Object url) {
    return 'Bağlantı açılamadı: $url';
  }

  @override
  String get aiPlanUpdated => 'AI planı güncellendi';

  @override
  String get aiPlanEmptyEdgeFunction =>
      'Plan boş. ai-plan Edge Function’ı kontrol et.';

  @override
  String aiPlanHoursShort(Object hours) {
    return '$hours sa';
  }

  @override
  String aiPlanImportanceMeta(int importance) {
    return 'önem $importance/5';
  }

  @override
  String get aiPlanLinkedToGoal => 'bir hedefe bağlı';

  @override
  String get aiPlanNothingToApply =>
      'Uygulanacak bir şey yok — bazı öğeleri seç';

  @override
  String get aiPlanDefaultTaskTitle => 'AI görevi';

  @override
  String aiPlanTasksAdded(int count) {
    return 'Eklenen görevler: $count';
  }

  @override
  String get aiPlanApplyTypeError =>
      'Görev eklerken veri tipi hatası: alanlardan biri sayı yerine true/false olarak geldi. Dosyayı tekrar güncelle: bu sürümde bool değerler ayrıca sayılara dönüştürülür ve is_completed alanı artık manuel gönderilmez.';

  @override
  String get aiPlanTitleWeek => 'Haftalık AI planı';

  @override
  String get aiPlanTitleMonth => 'Aylık AI planı';

  @override
  String get aiPlanRegenerateTooltip => 'Tekrar oluştur';

  @override
  String aiPlanUpdatedAt(Object date) {
    return 'Güncellendi: $date';
  }

  @override
  String get aiPlanCheckingConsent => 'AI işleme onayı kontrol ediliyor...';

  @override
  String get aiPlanApplyingTasks => 'Görevler ekleniyor...';

  @override
  String get aiPlanGenerating => 'AI planı oluşturuluyor...';

  @override
  String aiPlanApplyCount(int count) {
    return 'Uygula ($count)';
  }

  @override
  String get aiPlanRejectTooltip => 'Reddet';

  @override
  String get aiPlanAcceptTooltip => 'Kabul et';

  @override
  String get aiPlanFieldBlock => 'Blok';

  @override
  String get aiPlanFieldImportance => 'Önem';

  @override
  String get aiPlanFieldHours => 'Saat';

  @override
  String get aiPlanFieldRepeat => 'Tekrar';

  @override
  String get aiPlanConsentRequiredTitle => 'AI işleme onayı gerekli';

  @override
  String get aiPlanConsentRequiredBody =>
      'AI planı oluşturmadan önce Nest’in kişisel öneriler için uygulama verilerini analiz edebileceğini onaylamalısın.';

  @override
  String get aiPlanGiveConsent => 'Onay ver';

  @override
  String get aiPlanPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get aiPlanDatenschutz => 'Veri Koruma Politikası';

  @override
  String get aiPlanTermsOfUse => 'Kullanım Şartları';

  @override
  String get aiPlanEmptyTitle => 'Plan boş';

  @override
  String get aiPlanEmptyBody =>
      'AI içgörüleri, hedefler, görevler, alışkanlıklar ve ruh haline dayalı plan oluşturmak için aşağıdaki düğmeye bas.';

  @override
  String get aiPlanGeneratePlan => 'Plan oluştur';

  @override
  String get aiPlanRepeatNone => 'Tekrar yok';

  @override
  String get aiPlanRepeatDaily => 'Her gün';

  @override
  String get aiPlanRepeatWeekdays => 'Hafta içi';

  @override
  String get aiPlanRepeatWeekly => 'Haftada bir';

  @override
  String get aiPlanLifeBlockOther => 'Diğer';

  @override
  String get aiInsightsConsentTitle => 'AI işleme onayı';

  @override
  String get aiInsightsConsentBody =>
      'AI içgörüleri oluşturmak için Nest hedeflerini, görevlerini, alışkanlıklarını, ruh halini ve diğer uygulama verilerini analiz edecek. Bu veriler yalnızca kişisel öneriler, planlar ve içgörüler oluşturmak için kullanılır.';

  @override
  String get aiInsightsConsentDeclineBody =>
      'Onay vermeyebilirsin — bu durumda AI özelliği çalışmaz.';

  @override
  String get aiInsightsConsentNotNow => 'Şimdi değil';

  @override
  String get aiInsightsConsentAgree => 'Kabul ediyorum';

  @override
  String get aiInsightsConsentSaved => 'AI işleme onayı kaydedildi';

  @override
  String aiInsightsConsentCheckFailed(Object error) {
    return 'AI işleme onayı kontrol edilemedi veya kaydedilemedi. users tablosunda ai_processing_consent, ai_processing_consent_at ve ai_processing_consent_version alanlarının olduğundan emin ol. Detaylar: $error';
  }

  @override
  String get aiInsightsCheckingConsent => 'AI işleme onayı kontrol ediliyor...';

  @override
  String get aiInsightsUserNotAuthorized => 'Kullanıcı kimliği doğrulanmamış';

  @override
  String aiInsightsOpenLinkFailed(Object url) {
    return 'Bağlantı açılamadı: $url';
  }

  @override
  String get aiInsightsDefaultTitle => 'AI içgörüsü';

  @override
  String get aiInsightsConsentRequiredTitle => 'AI işleme onayı gerekli';

  @override
  String get aiInsightsConsentRequiredBody =>
      'AI içgörüleri oluşturmadan önce Nest’in kişisel öneriler için uygulama verilerini analiz edebileceğini onaylamalısın.';

  @override
  String get aiInsightsGiveConsent => 'Onay ver';

  @override
  String get aiInsightsPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get aiInsightsDatenschutz => 'Veri Koruma Politikası';

  @override
  String get aiInsightsTermsOfUse => 'Kullanım Şartları';

  @override
  String get massDailyTitle => 'Toplu günlük giriş';

  @override
  String get massDailyDatePrefix => 'Tarih: ';

  @override
  String get massDailyChoose => 'Seç';

  @override
  String get massDailyBack => 'Geri';

  @override
  String get massDailyCancel => 'İptal';

  @override
  String get massDailyNext => 'İleri';

  @override
  String get massDailySaveAll => 'Tümünü kaydet';

  @override
  String get massDailyEmptyRowsIgnored => 'Boş satırlar yok sayılır.';

  @override
  String get massDailyMoodTitle => 'Ruh hali';

  @override
  String get massDailyMoodSubtitle =>
      'Günün nasıl geçtiğine dair isteğe bağlı not.';

  @override
  String get massDailyNote => 'Not';

  @override
  String get massDailyHabitsTitle => 'Alışkanlıklar';

  @override
  String get massDailyHabitsSubtitle =>
      'Tamamlanmayı işaretle ve gerekiyorsa miktar ekle.';

  @override
  String get massDailyRefresh => 'Yenile';

  @override
  String get massDailyNoHabits => 'Henüz alışkanlık yok. Profilinden ekle.';

  @override
  String massDailyHabitsLoadFailed(Object error) {
    return 'Alışkanlıklar yüklenemedi: $error';
  }

  @override
  String get massDailyMentalTitle => 'Ruh sağlığı';

  @override
  String get massDailyMentalSubtitle =>
      'Sonraki analizler için kısa günlük durum kontrolü.';

  @override
  String get massDailyMentalIntro =>
      'Birkaç soruya yanıt ver — bu durumunu takip etmeye yardımcı olur.';

  @override
  String get massDailyNoMentalQuestions =>
      'Henüz soru yok. Bunları mental_questions tablosuna ekle.';

  @override
  String massDailyMentalLoadFailed(Object error) {
    return 'Sorular yüklenemedi: $error';
  }

  @override
  String get massDailyExpensesTitle => 'Giderler';

  @override
  String get massDailyExpensesSubtitle => 'Seçilen gün için giderleri ekle.';

  @override
  String get massDailyIncomesTitle => 'Gelir';

  @override
  String get massDailyIncomesSubtitle => 'Seçilen gün için gelir ekle.';

  @override
  String get massDailyGoalsTitle => 'Görevler';

  @override
  String get massDailyGoalsSubtitle =>
      'O gün ne üzerinde çalıştığını ve ne kadar zaman aldığını kaydet.';

  @override
  String get massDailyAddRow => 'Satır ekle';

  @override
  String get massDailyNoMood => 'Ruh hali yok';

  @override
  String get massDailyQuantityExample => 'Miktar (örneğin, sigara)';

  @override
  String get massDailyQuantityOptional => 'Miktar (isteğe bağlı)';

  @override
  String get massDailyQuantityShort => 'Adet';

  @override
  String get massDailyHabitNegative => 'Negatif';

  @override
  String get massDailyHabitPositive => 'Pozitif';

  @override
  String get massDailyAnswer => 'Yanıt';

  @override
  String get massDailyAmount => 'Tutar';

  @override
  String get massDailyCategory => 'Kategori';

  @override
  String get massDailyNoCategories => 'Kategori yok';

  @override
  String get massDailyTaskTitle => 'Görev başlığı';

  @override
  String get massDailyHours => 'Saat';

  @override
  String get massDailyTime => 'Saat';

  @override
  String get massDailyEmotion => 'Duygu';

  @override
  String get massDailyNoEmotion => 'Duygu yok';

  @override
  String get massDailyImportance => 'Önem';

  @override
  String get massDailyBigGoal => 'Büyük hedef';

  @override
  String get massDailyNoLink => 'Bağlı değil';

  @override
  String get massDailyLoadingUserGoals => 'Büyük hedefler yükleniyor...';

  @override
  String get massDailyNoUserGoalsForCategory =>
      'Bu kategori için henüz büyük hedef yok.';

  @override
  String get massDailyHorizonTactical => 'Taktik';

  @override
  String get massDailyHorizonMid => 'Orta vadeli';

  @override
  String get massDailyHorizonLong => 'Uzun vadeli';

  @override
  String get massDailyLifeBlockGeneral => 'Genel';

  @override
  String get massDailyLifeBlockHealth => 'Sağlık';

  @override
  String get massDailyLifeBlockCareer => 'Kariyer';

  @override
  String get massDailyLifeBlockFamily => 'Aile';

  @override
  String get massDailyLifeBlockFinance => 'Finans';

  @override
  String get massDailyLifeBlockEducation => 'Eğitim';

  @override
  String get massDailyLifeBlockHobbies => 'Hobiler';

  @override
  String get importJournalTextNotRecognized =>
      'Metin tanınmadı. Başka bir fotoğraf dene.';

  @override
  String get importJournalRecognizedTextTitle => 'Tanınan metin';

  @override
  String get importJournalContinue => 'Devam';

  @override
  String get importJournalUntitled => 'Başlıksız';

  @override
  String get importJournalNoTasksFound => 'Metinden görevler çıkarılamadı.';

  @override
  String importJournalAddedGoals(Object count) {
    return 'Eklenen hedefler: $count';
  }

  @override
  String importJournalImportFailed(Object error) {
    return 'İçe aktarılamadı: $error';
  }

  @override
  String get importJournalVisionApiKeyMissing =>
      'VISION_API_KEY ayarlanmamış. Uygulamayı --dart-define=VISION_API_KEY=... ile çalıştır.';

  @override
  String importJournalVisionApiError(Object statusCode, Object body) {
    return 'Vision API hata döndürdü $statusCode: $body';
  }

  @override
  String get importJournalEditTitle => 'Düzenle';

  @override
  String get importJournalNameLabel => 'Ad';

  @override
  String get importJournalTimeColon => 'Saat:';

  @override
  String get importJournalHoursColon => 'Saat:';

  @override
  String get importJournalFoundTasksTitle => 'Bulunan görevler';

  @override
  String importJournalTaskSubtitle(Object time, Object hours) {
    return '$time • $hours sa';
  }

  @override
  String get importJournalAddSelected => 'Seçilenleri ekle';

  @override
  String get recurringGoalSelectAtLeastOneWeekday => 'En az bir hafta günü seç';

  @override
  String get recurringGoalTitle => 'Tekrarlayan hedef';

  @override
  String get recurringGoalSubtitle =>
      'Bugünden seçilen tarihe kadar görevler oluşturur.';

  @override
  String get recurringGoalDetailsSection => 'Detaylar';

  @override
  String get recurringGoalTitleLabel => 'Hedef başlığı';

  @override
  String get recurringGoalTitleHint => 'Örneğin: Antrenman';

  @override
  String get recurringGoalEmotionLabel => 'Duygu';

  @override
  String get recurringGoalEmotionHint => 'Örneğin: 💪 motivasyon';

  @override
  String get recurringGoalRegularitySection => 'Tekrar';

  @override
  String get recurringGoalEveryNDays => 'Her N günde bir';

  @override
  String get recurringGoalByWeekdays => 'Hafta günlerine göre';

  @override
  String get recurringGoalIntervalLabel => 'Aralık';

  @override
  String recurringGoalEveryNDaysShort(Object count) {
    return '$count g';
  }

  @override
  String get recurringGoalWeekdayMon => 'Pzt';

  @override
  String get recurringGoalWeekdayTue => 'Sal';

  @override
  String get recurringGoalWeekdayWed => 'Çar';

  @override
  String get recurringGoalWeekdayThu => 'Per';

  @override
  String get recurringGoalWeekdayFri => 'Cum';

  @override
  String get recurringGoalWeekdaySat => 'Cmt';

  @override
  String get recurringGoalWeekdaySun => 'Paz';

  @override
  String recurringGoalTimeButton(Object time) {
    return 'Saat: $time';
  }

  @override
  String recurringGoalUntilButton(Object date) {
    return 'Şu tarihe kadar: $date';
  }

  @override
  String get recurringGoalParametersSection => 'Parametreler';

  @override
  String get recurringGoalLifeBlockLabel => 'Yaşam bloğu';

  @override
  String get recurringGoalImportanceLabel => 'Önem';

  @override
  String get recurringGoalUserGoalLabel => 'Büyük hedef';

  @override
  String get recurringGoalNoLink => 'Bağlantı yok';

  @override
  String recurringGoalLoadingUserGoals(Object block) {
    return '“$block” için hedefler yükleniyor...';
  }

  @override
  String recurringGoalNoUserGoalsForBlock(Object block) {
    return '“$block” için henüz uygun hedef yok.';
  }

  @override
  String get recurringGoalPlannedHoursLabel => 'Planlanan saat';

  @override
  String recurringGoalOccurrencesCount(Object count) {
    return 'Oluşturulacak görevler: $count';
  }

  @override
  String get recurringGoalCreate => 'Oluştur';

  @override
  String get recurringGoalLifeBlockGeneral => 'Genel';

  @override
  String get recurringGoalLifeBlockHealth => 'Sağlık';

  @override
  String get recurringGoalLifeBlockCareer => 'Kariyer';

  @override
  String get recurringGoalLifeBlockFinance => 'Finans';

  @override
  String get recurringGoalLifeBlockRelationships => 'İlişkiler';

  @override
  String get recurringGoalLifeBlockSelf => 'Kişisel gelişim';

  @override
  String get recurringGoalLifeBlockEducation => 'Eğitim';

  @override
  String get recurringGoalLifeBlockTravel => 'Seyahat';

  @override
  String get recurringGoalLifeBlockHome => 'Ev';

  @override
  String get recurringGoalHorizonTactical => 'Taktik';

  @override
  String get recurringGoalHorizonMid => 'Orta vadeli';

  @override
  String get recurringGoalHorizonLong => 'Uzun vadeli';

  @override
  String get addDayGoalLinkSectionTitle => 'Bir hedefe bağla';

  @override
  String get addDayGoalUserGoalLabel => 'Büyük hedef';

  @override
  String get addDayGoalNoLinkedGoal => 'Bağlantı yok';

  @override
  String addDayGoalLoadingUserGoals(Object block) {
    return '“$block” için hedefler yükleniyor...';
  }

  @override
  String addDayGoalNoUserGoalsForBlock(Object block) {
    return '“$block” için henüz uygun hedef yok.';
  }

  @override
  String get addDayGoalLifeBlockGeneral => 'Genel';

  @override
  String get addDayGoalLifeBlockHealth => 'Sağlık';

  @override
  String get addDayGoalLifeBlockCareer => 'Kariyer';

  @override
  String get addDayGoalLifeBlockFinance => 'Finans';

  @override
  String get addDayGoalLifeBlockRelationships => 'İlişkiler';

  @override
  String get addDayGoalLifeBlockSelf => 'Kişisel gelişim';

  @override
  String get addDayGoalLifeBlockEducation => 'Eğitim';

  @override
  String get addDayGoalLifeBlockTravel => 'Seyahat';

  @override
  String get addDayGoalLifeBlockHome => 'Ev';

  @override
  String get addDayGoalHorizonTactical => 'Taktik';

  @override
  String get addDayGoalHorizonMid => 'Orta vadeli';

  @override
  String get addDayGoalHorizonLong => 'Uzun vadeli';

  @override
  String get lifeBlockSelf => 'Kişisel gelişim';

  @override
  String get lifeBlockTravel => 'Seyahat';

  @override
  String get lifeBlockHome => 'Ev';

  @override
  String get horizonTactical => 'Taktik';

  @override
  String get horizonMid => 'Orta vadeli';

  @override
  String get horizonLong => 'Uzun vadeli';

  @override
  String get editGoalSectionDateTime => 'Tarih ve saat';

  @override
  String get editGoalSectionUserGoalLink => 'Daha büyük bir hedefe bağla';

  @override
  String get userGoalLinkFieldLabel => 'Daha büyük hedef';

  @override
  String get userGoalLinkNone => 'Bağlantı yok';

  @override
  String userGoalLinkLoadingForBlock(Object block) {
    return '“$block” için hedefler yükleniyor...';
  }

  @override
  String userGoalLinkNoGoalsForBlock(Object block) {
    return '“$block” için henüz uygun hedef yok.';
  }

  @override
  String editGoalHoursValue(Object hours) {
    return 'Saat: $hours';
  }

  @override
  String commonHoursShort(Object hours) {
    return '$hours sa';
  }

  @override
  String get healthTrackerTitle => 'Sağlık takipçisi';

  @override
  String get healthCalorieTargetTitle => 'Kalori hedefi';

  @override
  String get healthDailyCaloriesLabel => 'Günlük kcal';

  @override
  String get healthAddMealTitle => 'Öğün ekle';

  @override
  String get healthMealTypeLabel => 'Öğün';

  @override
  String get healthMealBreakfast => 'Kahvaltı';

  @override
  String get healthMealLunch => 'Öğle yemeği';

  @override
  String get healthMealDinner => 'Akşam yemeği';

  @override
  String get healthMealSnack => 'Ara öğün';

  @override
  String get healthCaloriesLabel => 'Kalori';

  @override
  String get healthEnterCalories => 'Kalori gir';

  @override
  String get healthMealDescriptionLabel => 'Ne yedin?';

  @override
  String get healthAddDescription => 'Açıklama ekle';

  @override
  String get healthAddBurnTitle => 'Yakılan kalori ekle';

  @override
  String get healthCaloriesBurnedLabel => 'Yakılan kalori';

  @override
  String get healthCommentLabel => 'Yorum';

  @override
  String get healthWaterTodayTitle => 'Bugün ne kadar su içtin?';

  @override
  String get healthSaveWater => 'Suyu kaydet';

  @override
  String get healthSetTarget => 'Hedef belirle';

  @override
  String healthTargetCalories(Object calories) {
    return 'Hedef $calories kcal';
  }

  @override
  String get healthAddMealButton => 'Yemek ekle';

  @override
  String get healthAddBurnButton => 'Yakım ekle';

  @override
  String healthWaterButton(Object liters) {
    return 'Su $liters L';
  }

  @override
  String get healthConsumed => 'Alınan';

  @override
  String get healthBurned => 'Yakılan';

  @override
  String get healthBalance => 'Denge';

  @override
  String get healthDeltaVsTarget => 'Hedefe göre fark';

  @override
  String get healthWaterDrunk => 'İçilen su';

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
  String get healthMealsTodayTitle => 'Bugünkü öğünler';

  @override
  String get healthNoMeals => 'Henüz öğün kaydı yok.';

  @override
  String get healthBurnsTitle => 'Yakılan kalori';

  @override
  String get healthNoBurns => 'Henüz yakılan kalori kaydı yok.';

  @override
  String get healthNoComment => 'Yorum yok';

  @override
  String get hobbyTrackerTitle => 'Hobi takipçisi';

  @override
  String get hobbyTrackerNewHobbyTitle => 'Yeni hobi';

  @override
  String get hobbyTrackerHobbyNameLabel => 'Hobi adı';

  @override
  String get hobbyTrackerEnterHobbyValidator => 'Bir hobi gir';

  @override
  String get hobbyTrackerWeeklyGoalMinutesLabel => 'Haftalık hedef, dakika';

  @override
  String get hobbyTrackerEnterGoalValidator => 'Bir hedef gir';

  @override
  String get hobbyTrackerCreateButton => 'Oluştur';

  @override
  String hobbyTrackerAddTimeTitle(Object title) {
    return 'Süre ekle: $title';
  }

  @override
  String get hobbyTrackerMinutesSpentLabel => 'Harcanan dakika';

  @override
  String get hobbyTrackerNoteLabel => 'Not';

  @override
  String get hobbyTrackerDeleteConfirmTitle => 'Hobi silinsin mi?';

  @override
  String hobbyTrackerDeleteConfirmBody(Object title) {
    return '\"$title\" hobisi tüm kayıtlarıyla birlikte silinecek.';
  }

  @override
  String get hobbyTrackerAddHobbyTooltip => 'Hobi ekle';

  @override
  String get hobbyTrackerEmptyText =>
      'Henüz hobi yok. İlk aktiviteni ekle ve zamanı takip etmeye başla.';

  @override
  String get hobbyTrackerCreateHobbyButton => 'Hobi oluştur';

  @override
  String get hobbyTrackerDeleteHobbyTooltip => 'Hobiyi sil';

  @override
  String get hobbyTrackerAddEntryButton => 'Kayıt ekle';

  @override
  String hobbyTrackerToday(Object value) {
    return 'Bugün $value';
  }

  @override
  String hobbyTrackerWeek(Object value) {
    return 'Hafta $value';
  }

  @override
  String hobbyTrackerGoal(Object value) {
    return 'Hedef: $value';
  }

  @override
  String hobbyTrackerMinutesShort(Object minutes) {
    return '$minutes dk';
  }

  @override
  String hobbyTrackerHoursShort(Object hours) {
    return '$hours sa';
  }

  @override
  String hobbyTrackerHoursMinutesShort(Object hours, Object minutes) {
    return '$hours sa $minutes dk';
  }

  @override
  String get importGoalsReviewTitle => 'Hedefleri içe aktar';

  @override
  String get importGoalsReviewSubtitle =>
      'İçe aktarılacakları seç ve gerekirse başlık veya açıklamayı düzenle.';

  @override
  String get importGoalsReviewSelectAll => 'Tümünü seç';

  @override
  String get importGoalsReviewYes => 'Evet';

  @override
  String get importGoalsReviewNo => 'Hayır';

  @override
  String get importGoalsReviewListSection => 'Liste';

  @override
  String get importGoalsReviewImport => 'İçe aktar';

  @override
  String get importGoalsReviewFieldTitle => 'Başlık';

  @override
  String get importGoalsReviewFieldDescription => 'Açıklama';

  @override
  String importGoalsReviewTime(Object time) {
    return 'Saat: $time';
  }

  @override
  String get importGoalsReviewChange => 'Değiştir';

  @override
  String get shoppingBasketCopyHeader => '🛒 Alışveriş listesi';

  @override
  String shoppingDueDatePrefix(Object date) {
    return '$date tarihine kadar';
  }

  @override
  String get shoppingBasketCopied => 'Alışveriş listesi kopyalandı';

  @override
  String get shoppingNewWishlistItem => 'Yeni istek öğesi';

  @override
  String get shoppingNewPurchase => 'Yeni alışveriş';

  @override
  String get shoppingEditItem => 'Öğeyi düzenle';

  @override
  String get shoppingFieldTitle => 'Başlık';

  @override
  String get shoppingEnterTitle => 'Başlık gir';

  @override
  String get shoppingFieldDescription => 'Açıklama';

  @override
  String get shoppingFieldPrice => 'Fiyat';

  @override
  String get shoppingFieldStore => 'Mağaza';

  @override
  String get shoppingFieldExpenseCategory => 'Gider kategorisi';

  @override
  String get shoppingNoCategory => 'Kategori yok';

  @override
  String get shoppingAlreadyBought => 'Zaten alındı';

  @override
  String get shoppingPurchaseDate => 'Alışveriş tarihi';

  @override
  String get shoppingReset => 'Sıfırla';

  @override
  String get shoppingEmpty => 'Şimdilik boş.';

  @override
  String get shoppingTrackerTitle => 'Alışveriş takipçisi';

  @override
  String get shoppingCopyBasket => 'Sepeti kopyala';

  @override
  String get shoppingBasketTitle => 'Alışveriş listesi';

  @override
  String get shoppingWishlistTitle => 'İstek listesi';

  @override
  String get profileOpenLinkFailed => 'Bağlantı açılamadı.';

  @override
  String get profileDangerZoneSubtitle => 'Hesap silme';

  @override
  String get profileLegalDocumentsTitle => 'Yasal belgeler';

  @override
  String get profileLegalDocumentsSubtitle =>
      'Gizlilik Politikası, Veri Koruma Beyanı, Kullanım Şartları ve Künyeyi istediğin zaman açabilirsin.';

  @override
  String get profileLegalPrivacyTitle => 'Gizlilik Politikası';

  @override
  String get profileLegalPrivacySubtitle =>
      'Gizlilik politikasının İngilizce sürümü';

  @override
  String get profileLegalDatenschutzTitle => 'Veri Koruma Beyanı';

  @override
  String get profileLegalDatenschutzSubtitle =>
      'Gizlilik politikasının Almanca sürümü';

  @override
  String get profileLegalTermsTitle => 'Kullanım Şartları';

  @override
  String get profileLegalTermsSubtitle =>
      'Nest kullanımına ilişkin kurallar ve koşullar';

  @override
  String get profileLegalImpressumTitle => 'Künye';

  @override
  String get profileLegalImpressumSubtitle =>
      'Yasal bildirim ve sağlayıcı bilgileri';

  @override
  String get settingsLanguageSystem => 'Sistem';

  @override
  String get settingsLanguageRussian => 'Rusça';

  @override
  String get settingsLanguageEnglish => 'İngilizce';

  @override
  String get settingsLanguageGerman => 'Almanca';

  @override
  String get settingsLanguageFrench => 'Fransızca';

  @override
  String get settingsLanguageSpanish => 'İspanyolca';

  @override
  String get settingsLanguageTurkish => 'Türkçe';

  @override
  String get profileWebNotificationsEveningBody =>
      'Alışkanlıklarını işaretle ve gününü kapat 👌';

  @override
  String get profileWebNotificationsPermissionDeniedToast =>
      'İzin verilmedi. Tarayıcı bildirim ayarlarını kontrol et.';

  @override
  String get profileWebNotificationsPermissionGrantedToast =>
      'Tarayıcı bildirimleri etkin ✅';

  @override
  String profileWebNotificationsTimeChangedToast(Object time) {
    return 'Bildirim saati: $time';
  }

  @override
  String get profileWebNotificationsLoadingSettings => 'Ayarlar yükleniyor...';

  @override
  String get profileWebNotificationsEnabledToast =>
      'Etkinleştirildi. Tarayıcıda bildirimlere izin vermeyi unutma.';

  @override
  String get profileWebNotificationsDisabledToast => 'Devre dışı.';

  @override
  String get profileEditChipsDefaultHint => 'Değerleri virgülle ayırarak gir';

  @override
  String get onboardingWelcomeTitle => 'Nest’e hoş geldin';

  @override
  String get onboardingWelcomeBody =>
      'Sana ana özellikleri hızlıca göstereceğim: hızlı işlemler, görevler, büyük hedefler, profil, raporlar ve finans.';

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get onboardingStart => 'Başla';

  @override
  String get onboardingFinishTitle => 'Tamamlandı';

  @override
  String get onboardingFinishBody =>
      'Artık Nest’in ana özelliklerinin nerede olduğunu biliyorsun. Eğitimi daha sonra ana ekrandaki yardım simgesinden tekrar başlatabilirsin.';

  @override
  String get onboardingGotIt => 'Anladım';

  @override
  String get onboardingMainQuickActionsTitle => 'Hızlı işlemler';

  @override
  String get onboardingMainQuickActionsText =>
      'Bu düğmeyle hızlıca görev, ruh hali, gider, alışkanlık ekleyebilir ve AI planını başlatabilirsin.';

  @override
  String get onboardingMainNavigationTitle => 'Nest navigasyonu';

  @override
  String get onboardingMainNavigationText =>
      'Ana bölümler burada: ana sayfa, görevler, büyük hedefler, profil, raporlar ve finans.';

  @override
  String get onboardingMainHelpTitle => 'Kılavuzu tekrar aç';

  @override
  String get onboardingMainHelpText =>
      'Etkileşimli How-To’yu daha sonra tekrar görmek istediğinde bu simgeye dokun.';

  @override
  String get onboardingGoalsFilterTitle => 'Yaşam alanı filtresi';

  @override
  String get onboardingGoalsFilterText =>
      'Görevleri doğru bağlamda görmek için kariyer, sağlık, finans ve diğer alanları seç.';

  @override
  String get onboardingGoalsModeTitle => 'Panel veya takvim';

  @override
  String get onboardingGoalsModeText =>
      'Panel genel resmi gösterir; takvim ise görevleri gün ve haftaya göre planlamana yardımcı olur.';

  @override
  String get onboardingGoalsAddTitle => 'İşlem ekle';

  @override
  String get onboardingGoalsAddText =>
      'Buradan hızlıca görev, görev serisi ekleyebilir veya bir günü birden çok kayıtla doldurabilirsin.';

  @override
  String get onboardingReportsPeriodTitle => 'Analiz dönemi';

  @override
  String get onboardingReportsPeriodText =>
      'Zaman içinde hedefleri, ruh halini, alışkanlıkları ve finansı karşılaştırmak için gün, hafta ve ay arasında geçiş yap.';

  @override
  String get onboardingReportsChartTitle => 'Etkileşimli grafikler';

  @override
  String get onboardingReportsChartText =>
      'Grafik segmentlerine ve noktalara dokun — uygulama yalnızca seçilen öğenin detaylarını gösterir.';

  @override
  String get onboardingUserGoalsHeaderTitle => 'Büyük hedefler';

  @override
  String get onboardingUserGoalsHeaderText =>
      'Stratejik hedeflerin burada saklanır: kısa, orta ve uzun vadeli. Daha sonra günlük görevleri bunlara bağlayabilirsin.';

  @override
  String get onboardingUserGoalsFiltersTitle => 'Hedef filtreleri';

  @override
  String get onboardingUserGoalsFiltersText =>
      'İhtiyacın olan yöne hızlıca odaklanmak için hedefleri yaşam alanı ve ufka göre filtrele.';

  @override
  String get onboardingUserGoalsAddTitle => 'Büyük hedef oluştur';

  @override
  String get onboardingUserGoalsAddText =>
      'Hedef eklemek, yaşam alanı, ufuk ve son tarih seçmek için buraya dokun.';

  @override
  String get onboardingProfileHeaderTitle => 'Profil';

  @override
  String get onboardingProfileHeaderText =>
      'Bu, kişisel Nest ayarlarının merkezidir: hesap, odak, alışkanlıklar ve uygulama tercihleri.';

  @override
  String get onboardingProfileCardTitle => 'Kişisel veriler';

  @override
  String get onboardingProfileCardText =>
      'Ad, yaş ve temel parametreler arayüzü ve gelecekteki AI önerilerini kişiselleştirmek için kullanılır.';

  @override
  String get onboardingProfileFocusTitle => 'Odak ve ayarlar';

  @override
  String get onboardingProfileFocusText =>
      'Bu parametreler uygulamadaki günlük planlama, analiz ve önerileri etkiler.';

  @override
  String get onboardingBudgetIncomeTitle => 'Gelir kategorileri';

  @override
  String get onboardingBudgetIncomeText =>
      'Finansal analizin gelir yapını anlayabilmesi için gelir kaynakları ekle.';

  @override
  String get onboardingBudgetExpenseTitle => 'Gider kategorileri';

  @override
  String get onboardingBudgetExpenseText =>
      'Gider kategorilerini ve limitleri burada ayarla. Bu, bütçenin en hızlı nereye gittiğini görmene yardımcı olur.';

  @override
  String get onboardingBudgetJarsTitle => 'Kumbaralar ve dağıtım';

  @override
  String get onboardingBudgetJarsText =>
      'Birikim hedefleri için kumbaraları kullan: seyahat, acil durum fonu, yatırımlar veya büyük alışverişler.';

  @override
  String get onboardingBudgetSaveTitle => 'Ayarları kaydet';

  @override
  String get onboardingBudgetSaveText =>
      'Değişikliklerden sonra bütçeni kaydetmeyi unutma; böylece kategoriler ve limitler veritabanına kaydedilir.';

  @override
  String get onboardingDayGoalsSummaryTitle => 'Gün özeti';

  @override
  String get onboardingDayGoalsSummaryText =>
      'Bu kart gün ilerlemeni gösterir: kaç görev tamamlandı, ne kaldı ve hâlâ ne kadar süre planlandı.';

  @override
  String get onboardingDayGoalsFilterTitle => 'Tamamlananları gizle';

  @override
  String get onboardingDayGoalsFilterText =>
      'Ekranda yalnızca aktif görevleri bırakmak için bu filtreyi aç.';

  @override
  String get onboardingDayGoalsFabTitle => 'Aktivite ekle';

  @override
  String get onboardingDayGoalsFabText =>
      'Bu düğmeyle görev ekleyebilir, günlük kaydını tanıyabilir veya Google Calendar’ı senkronize edebilirsin.';

  @override
  String get onboardingQuestionnaireProgressTitle => 'Kurulum ilerlemesi';

  @override
  String get onboardingQuestionnaireProgressText =>
      'İlk kurulumda hangi adımda olduğunu burada görebilirsin.';

  @override
  String get onboardingQuestionnaireNextTitle => 'Devam et';

  @override
  String get onboardingQuestionnaireNextText =>
      'Mevcut adımı tamamladıktan sonra buraya dokun. Sonunda Nest profilini, yaşam alanlarını ve hedeflerini kaydedecek.';

  @override
  String get onboardingExpensesControlsTitle => 'Gün ve bütçe ayarları';

  @override
  String get onboardingExpensesControlsText =>
      'İşlem tarihini burada seç ve kategoriler, limitler ve kumbaralar için ayarları aç.';

  @override
  String get onboardingExpensesSummaryTitle => 'Aylık finans özeti';

  @override
  String get onboardingExpensesSummaryText =>
      'Bu kart aylık gelir, gider ve serbest bakiyeyi gösterir — bütçe analizinin temelidir.';

  @override
  String get onboardingExpensesTransactionsTitle => 'Seçilen günün işlemleri';

  @override
  String get onboardingExpensesTransactionsText =>
      'Burada günün gelir ve giderlerini görebilirsin. Düzenlemek için bir işleme dokun veya silmek için sola kaydır.';

  @override
  String get onboardingExpensesFabTitle => 'Gelir veya gider ekle';

  @override
  String get onboardingExpensesFabText =>
      'Menüyü açıp hızlıca yeni finansal işlem eklemek için artıya dokun.';

  @override
  String get onboardingNextHint => 'Devam etmek için ekrana dokun';

  @override
  String get registerLegalTermsTitle => 'Kullanım Şartları';

  @override
  String get registerLegalPrivacyTitle => 'Gizlilik Politikası';

  @override
  String get registerLegalDatenschutzTitle => 'Veri Koruma Beyanı';

  @override
  String get registerLegalImpressumTitle => 'Künye';

  @override
  String registerLegalOptionalTitle(Object title) {
    return '$title · isteğe bağlı';
  }

  @override
  String get registerErrOpenRequiredLegalDocs =>
      'Lütfen önce Kullanım Şartlarını ve Gizlilik Politikasını açıp oku.';

  @override
  String registerLegalOpenFailed(Object document) {
    return '$document açılamadı.';
  }

  @override
  String get registerLegalAcceptedText =>
      'Kullanım Şartlarını ve Gizlilik Politikasını okudum ve kabul ediyorum.';

  @override
  String get registerLegalOpenRequiredDocsText =>
      'Önce Kullanım Şartlarını ve Gizlilik Politikasını açıp oku. Veri Koruma Beyanı ve Künye ek yasal bilgi olarak mevcuttur.';
}
