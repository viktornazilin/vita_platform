import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_goals_model.dart';
import '../../models/goal.dart';
import '../../services/user_goals_repo_mixin.dart';

import 'profile_ui_helpers.dart';

import '../../widgets/nest/nest_card.dart';
import '../../widgets/nest/nest_sheet.dart';

class GoalsByBlockCard extends StatefulWidget {
  final void Function(String text) onSnack;
  final List<String> allowedBlocks; // ✅ приходит снаружи

  /// ✅ фильтр сверху (all / career / education / ...)
  /// если null — считаем 'all'
  final String? selectedBlock;

  const GoalsByBlockCard({
    super.key,
    required this.onSnack,
    required this.allowedBlocks,
    this.selectedBlock,
  });

  @override
  State<GoalsByBlockCard> createState() => _GoalsByBlockCardState();
}

class _GoalsByBlockCardState extends State<GoalsByBlockCard> {
  GoalHorizon _selectedH = GoalHorizon.mid;

  String _hLabelShort(GoalHorizon h) {
    switch (h) {
      case GoalHorizon.tactical:
        return 'Тактика';
      case GoalHorizon.mid:
        return 'Средние';
      case GoalHorizon.long:
        return 'Долгие';
    }
  }

  String _hLabelLong(GoalHorizon h) {
    switch (h) {
      case GoalHorizon.tactical:
        return '2–6 недель';
      case GoalHorizon.mid:
        return '3–6 месяцев';
      case GoalHorizon.long:
        return '1+ год';
    }
  }

  IconData _hIcon(GoalHorizon h) {
    switch (h) {
      case GoalHorizon.tactical:
        return Icons.bolt_rounded;
      case GoalHorizon.mid:
        return Icons.trending_up_rounded;
      case GoalHorizon.long:
        return Icons.flag_rounded;
    }
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd.$mm.$yy';
  }

  Future<UserGoalUpsert?> _openGoalEditor(
    BuildContext context, {
    required List<String> allowedBlocks,
    UserGoal? existing,
    String? initialBlock,
    GoalHorizon? initialHorizon,
  }) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    DateTime? targetDate = existing?.targetDate;
    GoalHorizon horizon =
        initialHorizon ?? existing?.horizon ?? GoalHorizon.mid;

    String lifeBlock =
        existing?.lifeBlock ??
        (initialBlock ??
            (allowedBlocks.isNotEmpty ? allowedBlocks.first : 'general'));

    final res = await showModalBottomSheet<UserGoalUpsert>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NestSheet(
        child: StatefulBuilder(
          builder: (ctx, setSt) {
            final meta = ProfileUi.blockMeta(lifeBlock);

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
                  _SheetHeader(
                    title: existing == null
                        ? 'Новая цель'
                        : 'Редактировать цель',
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Сфера',
                    style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E4B5A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  NestCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          meta.icon,
                          size: 18,
                          color: const Color(0xFF2E4B5A),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: lifeBlock,
                              isExpanded: true,
                              items:
                                  (allowedBlocks.isEmpty
                                          ? [lifeBlock]
                                          : allowedBlocks)
                                      .map((b) {
                                        final m = ProfileUi.blockMeta(b);
                                        return DropdownMenuItem(
                                          value: b,
                                          child: Row(
                                            children: [
                                              Icon(m.icon, size: 16),
                                              const SizedBox(width: 8),
                                              Text(m.label),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList(),
                              onChanged: (v) =>
                                  setSt(() => lifeBlock = v ?? lifeBlock),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Горизонт',
                    style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E4B5A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  NestCard(
                    padding: const EdgeInsets.all(8),
                    child: SegmentedButton<GoalHorizon>(
                      segments: GoalHorizon.values
                          .map(
                            (h) => ButtonSegment(
                              value: h,
                              label: Text(_hLabelShort(h)),
                              icon: Icon(_hIcon(h)),
                            ),
                          )
                          .toList(),
                      selected: {horizon},
                      onSelectionChanged: (v) => setSt(() => horizon = v.first),
                      showSelectedIcon: false,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _hLabelLong(horizon),
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF2E4B5A).withOpacity(0.65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: titleCtrl,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      labelText: 'Название',
                      hintText: 'Например: Подтянуть английский до B2',
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Описание (опционально)',
                      hintText: 'Коротко: что именно и как измерим результат',
                    ),
                  ),

                  const SizedBox(height: 12),

                  NestCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Дедлайн: ${_fmtDate(targetDate)}',
                            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E4B5A),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: ctx,
                              firstDate: DateTime(now.year - 1, 1, 1),
                              lastDate: DateTime(now.year + 10, 12, 31),
                              initialDate: targetDate ?? now,
                            );
                            if (picked != null) {
                              setSt(
                                () => targetDate = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                ),
                              );
                            }
                          },
                          child: const Text('Выбрать'),
                        ),
                        if (targetDate != null)
                          IconButton(
                            tooltip: 'Убрать',
                            onPressed: () => setSt(() => targetDate = null),
                            icon: const Icon(Icons.clear_rounded),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

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
                            final t = titleCtrl.text.trim();
                            if (t.isEmpty) return;

                            Navigator.pop(
                              ctx,
                              UserGoalUpsert(
                                id: existing?.id,
                                lifeBlock: lifeBlock.trim(),
                                horizon: horizon,
                                title: t,
                                description: descCtrl.text.trim(),
                                targetDate: targetDate,
                              ),
                            );
                          },
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

    titleCtrl.dispose();
    descCtrl.dispose();
    return res;
  }

  Future<bool> _confirmDelete(
    BuildContext context, {
    required String title,
  }) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NestSheet(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHeader(title: 'Удалить цель?'),
              const SizedBox(height: 10),
              Text(
                '«$title» будет удалена без возможности восстановления.',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF2E4B5A).withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Удалить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final goalsModel = context.watch<UserGoalsModel>();

    final allowedBlocks = widget.allowedBlocks;

    // ✅ фильтр сверху: all / конкретная сфера
    final selected = (widget.selectedBlock ?? 'all').trim().toLowerCase();

    // 1) базовый список блоков из модели
    final allBlocks = goalsModel.grouped.keys.toList()..sort();

    // 2) ограничиваем на allowedBlocks профиля (если он не пуст)
    final blocksAllowedByProfile = allBlocks.where((b) {
      if (allowedBlocks.isEmpty) return true;
      return allowedBlocks.contains(b);
    }).toList();

    // 3) применяем фильтр выбранного блока (если не all)
    final List<String> blocksToShow = selected == 'all'
        ? blocksAllowedByProfile
        : blocksAllowedByProfile
              .where((b) => b.toLowerCase() == selected)
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ⚠️ Если ты уже рисуешь заголовок "Цели по сферам" СНАРУЖИ (в goals_screen),
        // можешь удалить этот Row целиком, чтобы не было дубля.
        Row(
          children: [
            Expanded(
              child: Text(
                'Цели по сферам',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E4B5A),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Добавить цель',
              onPressed: goalsModel.loading
                  ? null
                  : () async {
                      final dto = await _openGoalEditor(
                        context,
                        allowedBlocks: allowedBlocks,
                        initialHorizon: _selectedH,
                        // ✅ если сверху выбрана сфера — ставим её как initialBlock
                        initialBlock: selected == 'all' ? null : selected,
                      );
                      if (dto == null) return;
                      final err = await context.read<UserGoalsModel>().upsert(
                        dto,
                      );
                      if (err != null && context.mounted) widget.onSnack(err);
                    },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 10),

        NestCard(
          padding: const EdgeInsets.all(8),
          child: SegmentedButton<GoalHorizon>(
            segments: GoalHorizon.values
                .map(
                  (h) => ButtonSegment(
                    value: h,
                    label: Text(_hLabelShort(h)),
                    icon: Icon(_hIcon(h)),
                  ),
                )
                .toList(),
            selected: {_selectedH},
            onSelectionChanged: (v) => setState(() => _selectedH = v.first),
            showSelectedIcon: false,
          ),
        ),
        const SizedBox(height: 12),

        if (goalsModel.loading)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else if (goalsModel.error != null)
          NestCard(
            padding: const EdgeInsets.all(14),
            child: Text(
              goalsModel.error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else if (goalsModel.grouped.isEmpty)
          NestCard(
            padding: const EdgeInsets.all(14),
            child: Text(
              'Пока нет целей. Добавь первую цель для выбранных сфер.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF2E4B5A).withOpacity(0.7),
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else if (blocksToShow.isEmpty)
          NestCard(
            padding: const EdgeInsets.all(14),
            child: Text(
              selected == 'all'
                  ? 'Нет доступных сфер для отображения.'
                  : 'Нет целей для выбранной сферы.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF2E4B5A).withOpacity(0.7),
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          ...blocksToShow.map((block) {
            final meta = ProfileUi.blockMeta(block);
            final byH = goalsModel.grouped[block] ?? {};
            final list = byH[_selectedH] ?? const <UserGoal>[];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NestCard(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          meta.icon,
                          size: 18,
                          color: const Color(0xFF2E4B5A),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            meta.label,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF2E4B5A),
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: goalsModel.loading
                              ? null
                              : () async {
                                  final dto = await _openGoalEditor(
                                    context,
                                    allowedBlocks: allowedBlocks.isEmpty
                                        ? [block]
                                        : allowedBlocks,
                                    initialBlock: block,
                                    initialHorizon: _selectedH,
                                  );
                                  if (dto == null) return;
                                  final err = await context
                                      .read<UserGoalsModel>()
                                      .upsert(dto);
                                  if (err != null && context.mounted)
                                    widget.onSnack(err);
                                },
                          child: const Text('Добавить'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_hLabelShort(_selectedH)} • ${_hLabelLong(_selectedH)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF2E4B5A).withOpacity(0.60),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (list.isEmpty)
                      Text(
                        '—',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF2E4B5A).withOpacity(0.55),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      ...list.map((g) {
                        final subtitleParts = <String>[
                          if (g.description.trim().isNotEmpty)
                            g.description.trim(),
                          if (g.targetDate != null)
                            'Дедлайн: ${_fmtDate(g.targetDate)}',
                        ];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _GoalRow(
                            title: g.title,
                            subtitle: subtitleParts.isEmpty
                                ? null
                                : subtitleParts.join(' • '),
                            onTap: () async {
                              final dto = await _openGoalEditor(
                                context,
                                allowedBlocks: allowedBlocks.isEmpty
                                    ? [block]
                                    : allowedBlocks,
                                existing: g,
                              );
                              if (dto == null) return;
                              final err = await context
                                  .read<UserGoalsModel>()
                                  .upsert(dto);
                              if (err != null && context.mounted)
                                widget.onSnack(err);
                            },
                            onDelete: () async {
                              final ok = await _confirmDelete(
                                context,
                                title: g.title,
                              );
                              if (!ok) return;
                              final err = await context
                                  .read<UserGoalsModel>()
                                  .delete(g.id);
                              if (err != null && context.mounted)
                                widget.onSnack(err);
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _GoalRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tTitle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w900,
      color: const Color(0xFF2E4B5A),
    );
    final tSub = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF2E4B5A).withOpacity(0.65),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD6E6F5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: tTitle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: tSub),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              tooltip: 'Удалить',
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  const _SheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
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
