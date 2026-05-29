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

class _HomeView extends StatelessWidget {
  const _HomeView();

  static const Color _surface = Color(0xFFF5F3FA);
  static const Color _card = Color(0xFFFAFAFE);
  static const Color _cardTint = Color(0xFFEAE6F5);
  static const Color _primary = Color(0xFF6B54C0);
  static const Color _dark = Color(0xFF160E38);
  static const Color _muted = Color(0xFF9090A8);

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
        onHome: () => model.select(0),
        onGoals: () => model.select(1),
        onMenu: () => _openMenu(context, model),
        onPersonal: () => model.select(2),
        onReports: () => model.select(4),
      ),
    );
  }
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
                      fontFamily: 'Playfair Display',
                      fontSize: 25,
                      height: 1.0,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      letterSpacing: -0.5,
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
                  Container(
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
