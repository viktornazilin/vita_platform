import 'dart:ui';
import 'package:flutter/material.dart';

// Nest UI (проверь пути/имена)
import '../../widgets/nest/nest_card.dart';
import '../../widgets/nest/nest_sheet.dart';

class ProfileUi {
  // ======= Toast =======
  static void snack(BuildContext context, String text) {
    final sm = ScaffoldMessenger.maybeOf(context);
    if (sm == null) return;
    sm.showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  // ======= LifeBlock mapping (label + icon) =======
  static LifeBlockMeta blockMeta(String raw) {
    final k = raw.trim().toLowerCase();

    // тут можно расширять как хочешь
    switch (k) {
      case 'health':
      case 'здоровье':
        return const LifeBlockMeta(
          key: 'health',
          label: 'Здоровье',
          icon: Icons.favorite_rounded,
        );

      case 'career':
      case 'работа':
      case 'карьера':
        return const LifeBlockMeta(
          key: 'career',
          label: 'Карьера',
          icon: Icons.work_rounded,
        );

      case 'family':
      case 'семья':
        return const LifeBlockMeta(
          key: 'family',
          label: 'Семья',
          icon: Icons.home_rounded,
        );

      case 'finance':
      case 'финансы':
        return const LifeBlockMeta(
          key: 'finance',
          label: 'Финансы',
          icon: Icons.savings_rounded,
        );

      case 'learning':
      case 'education':
      case 'учёба':
        return const LifeBlockMeta(
          key: 'learning',
          label: 'Развитие',
          icon: Icons.auto_stories_rounded,
        );

      case 'social':
      case 'друзья':
        return const LifeBlockMeta(
          key: 'social',
          label: 'Социальное',
          icon: Icons.groups_rounded,
        );

      case 'rest':
      case 'fun':
      case 'отдых':
        return const LifeBlockMeta(
          key: 'rest',
          label: 'Отдых',
          icon: Icons.beach_access_rounded,
        );

      case 'general':
      default:
        return const LifeBlockMeta(
          key: 'general',
          label: 'Общее',
          icon: Icons.bubble_chart_rounded,
        );
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
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                      child: const Text('Сохранить'),
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
                      child: const Text('Отмена'),
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
                      child: const Text('Сохранить'),
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
                            color: const Color(0xFF2E4B5A),
                          ),
                        ),
                      ),
                      Text(
                        value.toStringAsFixed(decimals),
                        style: const TextStyle(fontWeight: FontWeight.w900),
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
                          child: const Text('Отмена'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(ctx, value),
                          child: const Text('Сохранить'),
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
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final raw = ctrl.text.trim();
                        final list =
                            raw.isEmpty
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
                      child: const Text('Сохранить'),
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
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w900,
      color: const Color(0xFF2E4B5A),
    );
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: const Color(0xFF2E4B5A).withOpacity(0.75),
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
              color: const Color(0xFF2E4B5A).withOpacity(0.65),
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
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w900,
      color: const Color(0xFF2E4B5A),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: const Color(0xFF2E4B5A).withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Text(
            '—',
            style: TextStyle(color: const Color(0xFF2E4B5A).withOpacity(0.55)),
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
    final meta = blockMeta(raw);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD6E6F5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142B5B7A),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 16, color: const Color(0xFF2E4B5A)),
          const SizedBox(width: 8),
          Text(
            meta.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E4B5A),
            ),
          ),
        ],
      ),
    );
  }
}

class LifeBlockMeta {
  final String key;
  final String label;
  final IconData icon;

  const LifeBlockMeta({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class _SheetHeader extends StatelessWidget {
  final String title;
  const _SheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    // маленький “граббер” сверху + заголовок
    return Column(
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF2E4B5A).withOpacity(0.20),
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
              color: const Color(0xFF2E4B5A),
            ),
          ),
        ),
      ],
    );
  }
}
