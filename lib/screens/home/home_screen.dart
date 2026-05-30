import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/home_model.dart';
import '../expenses_screen.dart';
import '../goals_screen.dart';
import '../mood_screen.dart';
import '../profile_screen.dart';
import '../reports_screen.dart';
import 'home_dashboard_tab.dart';
import 'home_launcher_sheet.dart';
import '../../services/onboarding_tour_service.dart';
import '../../services/user_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<Widget> _screens = <Widget>[
    const HomeDashboardTab(),
    const GoalsScreen(),
    const MoodScreen(),
    const ProfileScreen(),
    const ReportsScreen(),
    const ExpensesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeModel(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final GlobalKey _launcherKey = GlobalKey(debugLabel: 'home_launcher_key');
  final GlobalKey _helpKey = GlobalKey(debugLabel: 'home_help_key');
  final GlobalKey _navigationKey = GlobalKey(debugLabel: 'home_navigation_key');

  bool _initialFlowStarted = false;

  static const Color _surface = Color(0xFFF5F3FA);
  static const Color _card = Color(0xFFFAFAFE);
  static const Color _cardTint = Color(0xFFEAE6F5);
  static const Color _primary = Color(0xFF6B54C0);
  static const Color _dark = Color(0xFF160E38);
  static const Color _muted = Color(0xFF9090A8);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runInitialOnboardingFlow();
    });
  }

  Future<void> _runInitialOnboardingFlow() async {
    if (_initialFlowStarted || !mounted) return;
    _initialFlowStarted = true;

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    final userService = UserService();
    if (userService.currentUser == null) return;

    final shouldAskLifeBlocks =
        userService.needsLifeBlocksSetup || !userService.hasCompletedQuestionnaire;

    if (shouldAskLifeBlocks) {
      final selected = await showModalBottomSheet<List<String>>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => _LifeBlocksSetupSheet(
          initialSelection: userService.selectedLifeBlocks,
        ),
      );

      if (!mounted) return;
      if (selected == null || selected.isEmpty) return;

      await userService.completeLifeBlocksSetup(selected);
    }

    if (!mounted) return;

    final model = context.read<HomeModel>();
    model.select(0);
    OnboardingTourService.setActiveHomeTab(0);

    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    await OnboardingTourService.startFullAppOnboardingIfNeeded(
      context: context,
      onSelectTab: (index) {
        if (!mounted) return;
        context.read<HomeModel>().select(index);
        OnboardingTourService.setActiveHomeTab(index);
      },
      launcherKey: _launcherKey,
      helpKey: _helpKey,
      navigationKey: _navigationKey,
    );

    if (!mounted) return;
    await userService.markEpicIntroSeen();
  }

  String _menuLabel(BuildContext context) => _pick(context, const {
        'ru': 'Меню',
        'en': 'Menu',
        'de': 'Menü',
        'fr': 'Menu',
        'es': 'Menú',
        'tr': 'Menü',
      });

  String _personalLabel(BuildContext context) => _pick(context, const {
        'ru': 'Личное',
        'en': 'Personal',
        'de': 'Persönlich',
        'fr': 'Personnel',
        'es': 'Personal',
        'tr': 'Kişisel',
      });

  String _homeLabel(BuildContext context) => _pick(context, const {
        'ru': 'Главная',
        'en': 'Home',
        'de': 'Home',
        'fr': 'Accueil',
        'es': 'Inicio',
        'tr': 'Ana sayfa',
      });

  String _goalsLabel(BuildContext context) => _pick(context, const {
        'ru': 'Цели',
        'en': 'Goals',
        'de': 'Ziele',
        'fr': 'Objectifs',
        'es': 'Metas',
        'tr': 'Hedefler',
      });

  String _reportsLabel(BuildContext context) => _pick(context, const {
        'ru': 'Отчёты',
        'en': 'Reports',
        'de': 'Berichte',
        'fr': 'Rapports',
        'es': 'Informes',
        'tr': 'Raporlar',
      });

  String _mainTitle(BuildContext context) => _pick(context, const {
        'ru': 'Главная',
        'en': 'Home',
        'de': 'Home',
        'fr': 'Accueil',
        'es': 'Inicio',
        'tr': 'Ana sayfa',
      });

  String _dateLabel(BuildContext context) {
    final now = DateTime.now();
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    final weekdays = switch (code) {
      'ru' => ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'],
      'de' => ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
      'fr' => ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'],
      'es' => ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'],
      'tr' => ['pzt', 'sal', 'çar', 'per', 'cum', 'cmt', 'paz'],
      _ => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    };
    final months = switch (code) {
      'ru' => [
          'января',
          'февраля',
          'марта',
          'апреля',
          'мая',
          'июня',
          'июля',
          'августа',
          'сентября',
          'октября',
          'ноября',
          'декабря'
        ],
      'de' => [
          'Jan.',
          'Feb.',
          'März',
          'Apr.',
          'Mai',
          'Juni',
          'Juli',
          'Aug.',
          'Sept.',
          'Okt.',
          'Nov.',
          'Dez.'
        ],
      _ => [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ],
    };
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  static String _pick(BuildContext context, Map<String, String> values) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return values[code] ?? values['en'] ?? values.values.first;
  }

  void _openMenu(BuildContext context, HomeModel model) {
    showHomeLauncherSheet(context: context, model: model);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeModel>();
    final selected = model.selectedIndex.clamp(0, HomeScreen._screens.length - 1);
    final isHome = selected == 0;

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF100C1E) : _surface;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF100C1E),
                    Color(0xFF100C1E),
                    Color(0xFF160F2C),
                    Color(0xFF0A0614),
                  ]
                : const [
                    Color(0xFFFAF7EE),
                    Color(0xFFF5F3FA),
                    Color(0xFFEAF7F5),
                    Color(0xFFEAF1FF),
                  ],
            stops: const [0.0, 0.36, 0.70, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: selected,
                  children: HomeScreen._screens,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _LadnaBottomNav(
        selectedIndex: selected,
        homeLabel: _homeLabel(context),
        goalsLabel: _goalsLabel(context),
        menuLabel: _menuLabel(context),
        personalLabel: _personalLabel(context),
        reportsLabel: _reportsLabel(context),
        launcherKey: _launcherKey,
        helpKey: _helpKey,
        navigationKey: _navigationKey,
        onHome: () {
          model.select(0);
          OnboardingTourService.setActiveHomeTab(0);
        },
        onGoals: () {
          model.select(1);
          OnboardingTourService.setActiveHomeTab(1);
        },
        onMenu: () => _openMenu(context, model),
        onPersonal: () {
          model.select(2);
          OnboardingTourService.setActiveHomeTab(2);
        },
        onReports: () {
          model.select(4);
          OnboardingTourService.setActiveHomeTab(4);
        },
      ),
    );
  }
}


class _LifeBlocksSetupSheet extends StatefulWidget {
  const _LifeBlocksSetupSheet({
    required this.initialSelection,
  });

  final List<String> initialSelection;

  @override
  State<_LifeBlocksSetupSheet> createState() => _LifeBlocksSetupSheetState();
}

class _LifeBlocksSetupSheetState extends State<_LifeBlocksSetupSheet> {
  late final Set<String> _selected = widget.initialSelection.toSet();

  static const List<_LifeBlockOption> _options = [
    _LifeBlockOption('health', '💪'),
    _LifeBlockOption('career', '💼'),
    _LifeBlockOption('family', '💛'),
    _LifeBlockOption('finance', '💰'),
    _LifeBlockOption('education', '📚'),
    _LifeBlockOption('hobbies', '🎨'),
  ];

  String _t(BuildContext context, Map<String, String> values) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return values[code] ?? values['en'] ?? values.values.first;
  }

  String _title(BuildContext context) => _t(context, const {
        'ru': 'Что будем отслеживать?',
        'en': 'What should we track?',
        'de': 'Was möchtest du verfolgen?',
        'fr': 'Que veux-tu suivre ?',
        'es': '¿Qué quieres seguir?',
        'tr': 'Neyi takip edelim?',
      });

  String _subtitle(BuildContext context) => _t(context, const {
        'ru': 'Выбери сферы жизни. Ladna будет строить главную страницу, цели и отчёты вокруг них.',
        'en': 'Choose life areas. Ladna will build your home screen, goals and reports around them.',
        'de': 'Wähle Lebensbereiche. Ladna richtet Startseite, Ziele und Berichte danach aus.',
        'fr': 'Choisis tes domaines de vie. Ladna adaptera l’accueil, les objectifs et les rapports.',
        'es': 'Elige áreas de vida. Ladna adaptará el inicio, los objetivos y los informes.',
        'tr': 'Yaşam alanlarını seç. Ladna ana ekranı, hedefleri ve raporları buna göre düzenler.',
      });

  String _button(BuildContext context) => _t(context, const {
        'ru': 'Продолжить',
        'en': 'Continue',
        'de': 'Weiter',
        'fr': 'Continuer',
        'es': 'Continuar',
        'tr': 'Devam et',
      });

  String _hint(BuildContext context) => _t(context, const {
        'ru': 'Минимум 1 сфера',
        'en': 'Choose at least 1 area',
        'de': 'Wähle mindestens 1 Bereich',
        'fr': 'Choisis au moins 1 domaine',
        'es': 'Elige al menos 1 área',
        'tr': 'En az 1 alan seç',
      });

  String _label(BuildContext context, String key) {
    final labels = <String, Map<String, String>>{
      'health': {
        'ru': 'Здоровье',
        'en': 'Health',
        'de': 'Gesundheit',
        'fr': 'Santé',
        'es': 'Salud',
        'tr': 'Sağlık',
      },
      'career': {
        'ru': 'Карьера',
        'en': 'Career',
        'de': 'Karriere',
        'fr': 'Carrière',
        'es': 'Carrera',
        'tr': 'Kariyer',
      },
      'family': {
        'ru': 'Семья',
        'en': 'Family',
        'de': 'Familie',
        'fr': 'Famille',
        'es': 'Familia',
        'tr': 'Aile',
      },
      'finance': {
        'ru': 'Финансы',
        'en': 'Finance',
        'de': 'Finanzen',
        'fr': 'Finances',
        'es': 'Finanzas',
        'tr': 'Finans',
      },
      'education': {
        'ru': 'Обучение',
        'en': 'Education',
        'de': 'Bildung',
        'fr': 'Éducation',
        'es': 'Educación',
        'tr': 'Eğitim',
      },
      'hobbies': {
        'ru': 'Хобби',
        'en': 'Hobbies',
        'de': 'Hobbys',
        'fr': 'Loisirs',
        'es': 'Aficiones',
        'tr': 'Hobiler',
      },
    };
    return _t(context, labels[key] ?? {'en': key});
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF171126) : const Color(0xFFFFFCF4);
    final card = isDark ? const Color(0xFF211832) : const Color(0xFFFFFFFF);
    final text = isDark ? const Color(0xFFF4F0FF) : const Color(0xFF160E38);
    final muted = isDark ? Colors.white.withOpacity(0.58) : const Color(0xFF8E88A3);
    final primary = isDark ? const Color(0xFFD4E040) : const Color(0xFF6B54C0);

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(18, 10, 18, 18 + bottom),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.42 : 0.12),
              blurRadius: 28,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: muted.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(isDark ? 0.16 : 0.11),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text('✦', style: TextStyle(fontSize: 20, color: primary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _title(context),
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 22,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        color: text,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _subtitle(context),
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: muted,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 54,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final option = _options[index];
                  final selected = _selected.contains(option.key);

                  return InkWell(
                    borderRadius: BorderRadius.circular(17),
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selected.remove(option.key);
                        } else {
                          _selected.add(option.key);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: selected ? primary.withOpacity(isDark ? 0.18 : 0.12) : card,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: selected ? primary.withOpacity(0.65) : muted.withOpacity(0.18),
                          width: selected ? 1.4 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(option.emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              _label(context, option.key),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: text,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_circle_rounded, size: 18, color: primary),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(_selected.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: isDark ? const Color(0xFF161221) : Colors.white,
                    disabledBackgroundColor: muted.withOpacity(0.18),
                    disabledForegroundColor: muted.withOpacity(0.70),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _selected.isEmpty ? _hint(context) : _button(context),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LifeBlockOption {
  const _LifeBlockOption(this.key, this.emoji);

  final String key;
  final String emoji;
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.title,
    required this.date,
    required this.onProfileTap,
  });

  final String title;
  final String date;
  final VoidCallback onProfileTap;

  static const Color _dark = Color(0xFF160E38);
  static const Color _muted = Color(0xFF9090A8);
  static const Color _primary = Color(0xFF6B54C0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerGradient = isDark
        ? const [Color(0x1F6B54C0), Color(0x1F6B54C0)]
        : const [Color(0xFFF5F3FA), Color(0xFFE2DDEF)];
    final titleColor = isDark ? const Color(0xFFF0EEFF) : _dark;
    final mutedColor = isDark ? Colors.white.withOpacity(0.30) : _muted;
    final borderColor = isDark ? const Color(0x406B54C0) : const Color(0xFFDCD5F2);
    final iconBg = isDark ? _primary.withOpacity(0.20) : _primary.withOpacity(0.12);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: headerGradient,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.40 : 0.035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('🏠', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 22,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.0,
                      fontWeight: FontWeight.w600,
                      color: mutedColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(isDark ? 0.25 : 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: _primary.withOpacity(isDark ? 0.40 : 0.25), width: 1.5),
                ),
                child: const Text('👤', style: TextStyle(fontSize: 22)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LadnaBottomNav extends StatelessWidget {
  const _LadnaBottomNav({
    required this.selectedIndex,
    required this.homeLabel,
    required this.goalsLabel,
    required this.menuLabel,
    required this.personalLabel,
    required this.reportsLabel,
    required this.launcherKey,
    required this.helpKey,
    required this.navigationKey,
    required this.onHome,
    required this.onGoals,
    required this.onMenu,
    required this.onPersonal,
    required this.onReports,
  });

  final int selectedIndex;
  final String homeLabel;
  final String goalsLabel;
  final String menuLabel;
  final String personalLabel;
  final String reportsLabel;
  final GlobalKey launcherKey;
  final GlobalKey helpKey;
  final GlobalKey navigationKey;
  final VoidCallback onHome;
  final VoidCallback onGoals;
  final VoidCallback onMenu;
  final VoidCallback onPersonal;
  final VoidCallback onReports;

  static const Color _primary = Color(0xFF6B54C0);
  static const Color _muted = Color(0xFF9090A8);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xF2100C1E) : const Color(0xFFFAF6EE).withOpacity(0.96);
    final navBorder = isDark ? _primary.withOpacity(0.20) : _primary.withOpacity(0.12);
    final activeColor = isDark ? const Color(0xFFD4E040) : _primary;
    final inactiveColor = isDark ? Colors.white.withOpacity(0.25) : _muted;
    return Container(
      key: navigationKey,
      height: 78 + bottom,
      padding: EdgeInsets.only(bottom: bottom, top: 8),
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(color: navBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NavItem(
            icon: '🏠',
            label: homeLabel,
            active: selectedIndex == 0,
            onTap: onHome,
          ),
          _NavItem(
            icon: '🎯',
            label: goalsLabel,
            active: selectedIndex == 1,
            onTap: onGoals,
          ),
          Expanded(
            child: GestureDetector(
              onTap: onMenu,
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KeyedSubtree(
                    key: launcherKey,
                    child: Container(
                      width: 58,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6B54C0), Color(0xFFE8B854)],
                        ),
                        borderRadius: BorderRadius.circular(19),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(isDark ? 0.60 : 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Text('✦', style: TextStyle(color: Colors.white, fontSize: 21)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menuLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xCC6B54C0) : _primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _NavItem(
            key: helpKey,
            icon: '💛',
            label: personalLabel,
            active: selectedIndex == 2,
            onTap: onPersonal,
          ),
          _NavItem(
            icon: '📊',
            label: reportsLabel,
            active: selectedIndex == 4,
            onTap: onReports,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFF6B54C0);
  static const Color _muted = Color(0xFF9090A8);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFFD4E040) : _primary;
    final inactiveColor = isDark ? Colors.white.withOpacity(0.25) : _muted;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: TextStyle(fontSize: 23, color: active ? activeColor : inactiveColor)),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
