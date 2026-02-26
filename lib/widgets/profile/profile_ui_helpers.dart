// lib/screens/profile/profile_ui_helpers.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:nest_app/l10n/app_localizations.dart';

// Nest UI (проверь пути/имена)
import '../../widgets/nest/nest_card.dart';
import '../../widgets/nest/nest_sheet.dart';

class ProfileUi {
  // ======= Toast =======
  static void snack(BuildContext context, String text) {
  final sm = ScaffoldMessenger.maybeOf(context);
  if (sm == null) return;

  final scheme = Theme.of(context).colorScheme;

  sm.showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.surfaceContainerHigh.withOpacity(0.92),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

  // ======= LifeBlock mapping (label + icon) =======
  // ВАЖНО: label хранится как l10n-key, а отображение — через локализацию.
  static LifeBlockMeta blockMeta(String raw) {
    final k = raw.trim().toLowerCase();

    switch (k) {
      case 'health':
      case 'здоровье':
        return const LifeBlockMeta(
          key: 'health',
          labelKey: 'lifeBlockHealth',
          icon: Icons.favorite_rounded,
        );

      case 'career':
      case 'работа':
      case 'карьера':
        return const LifeBlockMeta(
          key: 'career',
          labelKey: 'lifeBlockCareer',
          icon: Icons.work_rounded,
        );

      case 'family':
      case 'семья':
        return const LifeBlockMeta(
          key: 'family',
          labelKey: 'lifeBlockFamily',
          icon: Icons.home_rounded,
        );

      case 'finance':
      case 'финансы':
      case 'money':
      case 'деньги':
        return const LifeBlockMeta(
          key: 'finance',
          labelKey: 'lifeBlockFinance',
          icon: Icons.savings_rounded,
        );

      case 'learning':
      case 'education':
      case 'study':
      case 'учёба':
      case 'развитие':
        return const LifeBlockMeta(
          key: 'learning',
          labelKey: 'lifeBlockLearning',
          icon: Icons.auto_stories_rounded,
        );

      case 'social':
      case 'friends':
      case 'друзья':
        return const LifeBlockMeta(
          key: 'social',
          labelKey: 'lifeBlockSocial',
          icon: Icons.groups_rounded,
        );

      case 'rest':
      case 'fun':
      case 'отдых':
        return const LifeBlockMeta(
          key: 'rest',
          labelKey: 'lifeBlockRest',
          icon: Icons.beach_access_rounded,
        );

      case 'balance':
      case 'баланс':
        return const LifeBlockMeta(
          key: 'balance',
          labelKey: 'lifeBlockBalance',
          icon: Icons.spa_rounded,
        );

      case 'love':
      case 'любовь':
        return const LifeBlockMeta(
          key: 'love',
          labelKey: 'lifeBlockLove',
          icon: Icons.favorite_border_rounded,
        );

      case 'creativity':
      case 'творчество':
        return const LifeBlockMeta(
          key: 'creativity',
          labelKey: 'lifeBlockCreativity',
          icon: Icons.palette_rounded,
        );

      case 'general':
      default:
        return const LifeBlockMeta(
          key: 'general',
          labelKey: 'lifeBlockGeneral',
          icon: Icons.bubble_chart_rounded,
        );
    }
  }

  static String blockLabel(BuildContext context, String raw) {
    final l = AppLocalizations.of(context)!;
    final meta = blockMeta(raw);

    // без рефлексии: обычный switch по labelKey
    switch (meta.labelKey) {
      case 'lifeBlockHealth':
        return l.lifeBlockHealth;
      case 'lifeBlockCareer':
        return l.lifeBlockCareer;
      case 'lifeBlockFamily':
        return l.lifeBlockFamily;
      case 'lifeBlockFinance':
        return l.lifeBlockFinance;
      case 'lifeBlockLearning':
        return l.lifeBlockLearning;
      case 'lifeBlockSocial':
        return l.lifeBlockSocial;
      case 'lifeBlockRest':
        return l.lifeBlockRest;
      case 'lifeBlockBalance':
        return l.lifeBlockBalance;
      case 'lifeBlockLove':
        return l.lifeBlockLove;
      case 'lifeBlockCreativity':
        return l.lifeBlockCreativity;
      case 'lifeBlockGeneral':
      default:
        return l.lifeBlockGeneral;
    }
  }

  // ======= Nest-styled dialogs =======

  static Future<String?> promptText(
    BuildContext context, {
    required String title,
    required String label,
    String initial = '',
    int maxLen = 200,
    int maxLines = 1,
    String? hint,
  }) async {
    final l = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: initial);

    final res = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NestSheet(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetHeader(title: title),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                maxLength: maxLen,
                maxLines: maxLines,
                decoration: InputDecoration(labelText: label, hintText: hint),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                      child: Text(l.commonSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    ctrl.dispose();
    return res;
  }

  static Future<int?> promptInt(
    BuildContext context, {
    required String title,
    required String label,
    int? initial,
    int min = 0,
    int max = 120,
  }) async {
    final l = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: initial?.toString() ?? '');

    final res = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NestSheet(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetHeader(title: title),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: '$min…$max',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final t = ctrl.text.trim();
                        if (t.isEmpty) return Navigator.pop(ctx, null);
                        final v = int.tryParse(t);
                        if (v == null || v < min || v > max) return;
                        Navigator.pop(ctx, v);
                      },
                      child: Text(l.commonSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    ctrl.dispose();
    return res;
  }

  static Future<double?> promptDouble(
    BuildContext context, {
    required String title,
    required String label,
    required double initial,
    double min = 1,
    double max = 24,
    int decimals = 1,
  }) async {
    final l = AppLocalizations.of(context)!;

    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NestSheet(
        child: StatefulBuilder(
          builder: (ctx, setSt) {
            double value = initial.clamp(min, max);

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SheetHeader(title: title),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(ctx).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      Text(
                        value.toStringAsFixed(decimals),
                        style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(ctx).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: ((max - min) * 2).round(),
                    onChanged: (v) => setSt(() => value = v),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(l.commonCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(ctx, value),
                          child: Text(l.commonSave),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Future<List<String>?> editChipsDialog(
    BuildContext context, {
    required String title,
    required List<String> initial,
    String hint = 'Введите через запятую',
  }) async {
    final l = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: initial.join(', '));

    final res = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NestSheet(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetHeader(title: title),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                maxLines: 3,
                decoration: InputDecoration(hintText: hint),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final raw = ctrl.text.trim();
                        final list =
                            (raw.isEmpty)
                                  ? <String>[]
                                  : raw
                                        .split(',')
                                        .map((e) => e.trim())
                                        .where((e) => e.isNotEmpty)
                                        .toSet()
                                        .toList()
                              ..sort();
                        Navigator.pop(ctx, list);
                      },
                      child: Text(l.commonSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    ctrl.dispose();
    return res;
  }

  // ======= Nest widgets =======

  static Widget editableRow({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onEdit,
    IconData icon = Icons.edit_outlined,
  }) {
    final scheme = Theme.of(context).colorScheme;

    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: scheme.onSurface,
        );
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withOpacity(0.92),
          fontWeight: FontWeight.w600,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NestCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: onEdit,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: labelStyle),
                  const SizedBox(height: 4),
                  Text(value, style: valueStyle),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              icon,
              size: 18,
              color: scheme.onSurfaceVariant.withOpacity(0.80),
            ),
          ],
        ),
      ),
    );
  }

  static Widget chipsCard(
    BuildContext context, {
    required String title,
    required List<String> items,
    required VoidCallback onEdit,
  }) {
    final scheme = Theme.of(context).colorScheme;

    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: scheme.onSurface,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: titleStyle)),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: scheme.onSurfaceVariant.withOpacity(0.85),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Text(
            '—',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant.withOpacity(0.55),
                  fontWeight: FontWeight.w700,
                ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items.map((e) => nestChip(context, e)).toList(),
          ),
      ],
    );
  }

  static Widget nestChip(BuildContext context, String raw) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final meta = blockMeta(raw);
    final label = blockLabel(context, raw);

    final chipBg = isDark
        ? scheme.surfaceContainerHigh.withOpacity(0.90)
        : scheme.surfaceContainerHigh.withOpacity(0.92);

    final chipBorder = isDark
        ? scheme.outlineVariant.withOpacity(0.60)
        : scheme.outlineVariant.withOpacity(0.50);

    final shadow = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF004A98).withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: chipBorder),
        boxShadow: shadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 16, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

class LifeBlockMeta {
  final String key;
  final String labelKey;
  final IconData icon;

  const LifeBlockMeta({
    required this.key,
    required this.labelKey,
    required this.icon,
  });

  /// ✅ FIX: goals_by_block_card.dart ожидает meta.label
  /// Тут возвращаем просто ключ локализации — а "человеческий" текст
  /// получается через ProfileUi.blockLabel(context, raw).
  /// Но чтобы сборка не падала, label должен существовать.
  String get label => labelKey;
}

class _SheetHeader extends StatelessWidget {
  final String title;
  const _SheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final handleColor = isDark
        ? scheme.onSurfaceVariant.withOpacity(0.28)
        : scheme.onSurfaceVariant.withOpacity(0.20);

    return Column(
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}