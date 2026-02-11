import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/profile_model.dart';
import '../../models/habits_model.dart';
import '../../models/user_goals_model.dart';

import '../../widgets/nest/nest_background.dart'; // <-- проверь путь

import 'profile_left_column.dart';
import 'profile_right_column.dart';
import 'profile_ui_helpers.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Future<void> _refreshAll(BuildContext context) async {
    await context.read<ProfileModel>().load();
    await context.read<HabitsModel>().load();
    await context.read<UserGoalsModel>().load();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProfileModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final err = model.error;
      if (err != null && ScaffoldMessenger.maybeOf(context) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
        );
      }
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
            const Text('My Profile'),
          ],
        );

        Widget content;

        if (model.loading) {
          content = const Center(child: CircularProgressIndicator());
        } else if (isWide) {
          // ВАЖНО: RefreshIndicator должен оборачивать scrollable
          content = RefreshIndicator(
            onRefresh: () => _refreshAll(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: outerPad,
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: ProfileLeftColumn()),
                        SizedBox(width: 16),
                        Expanded(flex: 7, child: ProfileRightColumn()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          content = RefreshIndicator(
            onRefresh: () => _refreshAll(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding: outerPad,
                    child: const Column(
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
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: titleRow,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: NestBackground(
            child: content,
          ),
        );
      },
    );
  }
}
