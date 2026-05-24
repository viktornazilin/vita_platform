import 'package:flutter/material.dart';

import '../services/user_service.dart';
import '../widgets/life_blocks_first_setup_sheet.dart';

class FirstSetupService {
  FirstSetupService._();

  static bool _isShowing = false;

  static List<String> _readLifeBlocks(Map<String, dynamic>? user) {
    final raw = user?['life_blocks'];

    if (raw is List) {
      return raw
          .map((e) => e.toString().trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }

    return const [];
  }

  static Future<bool> ensureLifeBlocksSelected(BuildContext context) async {
    if (_isShowing || !context.mounted) return false;

    final userService = UserService();

    try {
      await userService.refreshCurrentUser();
    } catch (_) {
      // If refresh fails, continue with cached user data.
      // The update step will still fail loudly if the session is invalid.
    }

    final existingBlocks = _readLifeBlocks(userService.currentUser);
    if (existingBlocks.isNotEmpty) return true;

    if (!context.mounted) return false;

    _isShowing = true;

    try {
      final selected = await showModalBottomSheet<List<String>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: false,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        builder: (_) => LifeBlocksFirstSetupSheet(
          initialSelected: existingBlocks,
        ),
      );

      if (selected == null || selected.isEmpty) return false;

      await userService.updateUserDetails({
        'life_blocks': selected,
        'has_completed_questionnaire': true,
      });

      return true;
    } finally {
      _isShowing = false;
    }
  }
}
