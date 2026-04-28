import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart'; // dbRepo
import '../models/profile_model.dart';

// HABITS
import '../models/habits_model.dart';

import '../widgets/profile/profile_view.dart';
import '../services/onboarding_tour_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey _profileHeaderKey = GlobalKey();
  final GlobalKey _profileCardKey = GlobalKey();
  final GlobalKey _profileFocusKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    OnboardingTourService.activeHomeTab.addListener(_maybeShowProfileOnboarding);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowProfileOnboarding());
  }

  void _maybeShowProfileOnboarding() {
    if (!mounted || OnboardingTourService.activeHomeTab.value != 3) return;

    if (OnboardingTourService.shouldRunFullStep(NestFullOnboardingStep.profile)) {
      OnboardingTourService.runFullFlowScreenStep(
        context: context,
        step: NestFullOnboardingStep.profile,
        showTour: () => OnboardingTourService.showProfileTour(
          context: context,
          headerKey: _profileHeaderKey,
          profileCardKey: _profileCardKey,
          focusKey: _profileFocusKey,
          markAsSeen: false,
        ),
      );
      return;
    }

    if (OnboardingTourService.isFullFlowActive) return;

    OnboardingTourService.showProfileTourIfNeeded(
      context: context,
      headerKey: _profileHeaderKey,
      profileCardKey: _profileCardKey,
      focusKey: _profileFocusKey,
    );
  }

  @override
  void dispose() {
    OnboardingTourService.activeHomeTab.removeListener(_maybeShowProfileOnboarding);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileModel(repo: dbRepo)..load(),
        ),
        ChangeNotifierProvider(create: (_) => HabitsModel()..load()),
        // ✅ Убрали UserGoalsModel отсюда
      ],
      child: Stack(
        children: [
          const ProfileView(),

          // Invisible onboarding anchors.
          // Важно: не ставим GlobalKey на весь ProfileView, иначе tutorial_coach_mark
          // подсвечивает почти весь экран и карточка уезжает вниз.
          Positioned(
            left: 20,
            right: 20,
            top: 18,
            height: 92,
            child: IgnorePointer(
              child: SizedBox(key: _profileHeaderKey),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 136,
            height: 210,
            child: IgnorePointer(
              child: SizedBox(key: _profileCardKey),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 440,
            height: 120,
            child: IgnorePointer(
              child: SizedBox(key: _profileFocusKey),
            ),
          ),
        ],
      ),
    );
  }
}
