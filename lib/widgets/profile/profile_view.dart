// lib/screens/profile/profile_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../../models/profile_model.dart';
import '../../models/habits_model.dart';
import '../../models/user_goals_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/nest/nest_background.dart';

import 'profile_left_column.dart';
import 'profile_right_column.dart';
import 'profile_ui_helpers.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // чтобы не спамить одним и тем же snackbar при каждом rebuild
  String? _lastShownError;

  Future<void> _refreshAll(BuildContext context) async {
    await context.read<ProfileModel>().load();
    await context.read<HabitsModel>().load();
    await context.read<UserGoalsModel>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<ProfileModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final err = model.error;
      if (!mounted) return;
      if (err == null) return;
      if (err == _lastShownError) return;

      _lastShownError = err;
      ProfileUi.snack(context, err);
    });

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isWide = w >= 960;

        final outerPad = EdgeInsets.symmetric(
          horizontal: isWide ? 24 : 16,
          vertical: isWide ? 16 : 12,
        );

        final titleRow = Row(
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 10),
            Text(l.profileTitle),
          ],
        );

        final Widget content = model.loading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : RefreshIndicator(
                onRefresh: () => _refreshAll(context),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 1200 : 560,
                      ),
                      child: Padding(
                        padding: outerPad,
                        child: isWide
                            ? const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 5, child: ProfileLeftColumn()),
                                  SizedBox(width: 16),
                                  Expanded(
                                    flex: 7,
                                    child: ProfileRightColumn(),
                                  ),
                                ],
                              )
                            : const Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ProfileLeftColumn(),
                                  SizedBox(height: 24),
                                  ProfileRightColumn(),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              );

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: titleRow,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: NestBackground(child: content),
        );
      },
    );
  }
}
