import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../widgets/add_day_goal_sheet.dart';

class DayGoalsScreen extends StatelessWidget {
  final DateTime date;
  final String? lifeBlock; // null => показать все блоки
  final List<String> availableBlocks;

  const DayGoalsScreen({
    super.key,
    required this.date,
    required this.lifeBlock,
    this.availableBlocks = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DayGoalsModel(
        date: date,
        lifeBlock: lifeBlock,
        availableBlocks: availableBlocks,
      )..load(),
      child: const _DayGoalsView(),
    );
  }
}

class _DayGoalsView extends StatefulWidget {
  const _DayGoalsView();

  @override
  State<_DayGoalsView> createState() => _DayGoalsViewState();
}

class _DayGoalsViewState extends State<_DayGoalsView> {
  final _scroll = ScrollController();

  Future<void> _openAdd(BuildContext context) async {
    final vm = context.read<DayGoalsModel>();
    final res = await showModalBottomSheet<AddGoalResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => AddDayGoalSheet(
        fixedLifeBlock: vm.lifeBlock,
        availableBlocks: vm.availableBlocks,
      ),
    );

    if (res != null) {
      await vm.createGoal(
        title: res.title,
        description: res.description,
        lifeBlockValue: res.lifeBlock,
        importance: res.importance,
        emotion: res.emotion,
        hours: res.hours,
      );

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 60));
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    }
  }

  // Сортировка: старые сверху → новые снизу (если есть createdAt — по нему)
  List<Goal> _sorted(List<Goal> src) {
    final list = List<Goal>.from(src);
    try {
      if (list.isNotEmpty && (list.first as dynamic).createdAt != null) {
        list.sort((a, b) {
          final da = (a as dynamic).createdAt as DateTime?;
          final db = (b as dynamic).createdAt as DateTime?;
          if (da == null && db == null) return 0;
          if (da == null) return -1;
          if (db == null) return 1;
          return da.compareTo(db);
        });
      }
    } catch (_) {}
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DayGoalsModel>();
    final goals = _sorted(vm.goals);
    final title = vm.lifeBlock ?? 'Все сферы';

    return Scaffold(
      appBar: AppBar(
        title: Text('${vm.formattedDate}  •  $title'),
        actions: [
          IconButton(
            onPressed: () => _openAdd(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        label: const Text('Добавить цель'),
        icon: const Icon(Icons.add),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : goals.isEmpty
              ? const Center(child: Text('Целей на этот день нет'))
              : ListView.builder(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: goals.length,
                  itemBuilder: (_, i) {
                    final g = goals[i];
                    return _TimelineRow(
                      key: ValueKey(g.id),
                      goal: g,
                      index: i,
                      total: goals.length,
                      onToggle: () => vm.toggleComplete(g),
                    );
                  },
                ),
    );
  }
}

/// Одна строка таймлайна: слева — пунктир + кружок (с анимацией), справа — карточка.
/// Без фиксированных высот: IntrinsicHeight гарантирует конечную высоту строки.
class _TimelineRow extends StatelessWidget {
  final Goal goal;
  final int index;
  final int total;
  final VoidCallback onToggle;

  const _TimelineRow({
    super.key,
    required this.goal,
    required this.index,
    required this.total,
    required this.onToggle,
  });

  static const double _railWidth = 64;
  static const double _dotRadius = 14;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final railColor = goal.isCompleted
        ? primary
        : theme.colorScheme.outline.withOpacity(0.35);

    // Стэггер-анимация появления строки
    final duration = Duration(milliseconds: 200 + index * 60);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 12),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -------- ЛЕВАЯ КОЛОНКА: пунктир + кружок --------
              SizedBox(
                width: _railWidth,
                child: Column(
                  children: [
                    if (index != 0)
                      Expanded(
                        child: Center(child: _DashedLine(color: railColor)),
                      )
                    else
                      const SizedBox(height: 12),

                    // Кружок: пульс при выполнении + плавная смена стиля
                    GestureDetector(
                      onTap: onToggle,
                      child: AnimatedScale(
                        scale: goal.isCompleted ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          width: _dotRadius * 2,
                          height: _dotRadius * 2,
                          decoration: BoxDecoration(
                            color: goal.isCompleted
                                ? primary
                                : theme.colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: goal.isCompleted
                                  ? primary
                                  : theme.colorScheme.outline,
                              width: goal.isCompleted ? 0 : 2,
                            ),
                            boxShadow: goal.isCompleted
                                ? [
                                    BoxShadow(
                                      color: primary.withOpacity(0.25),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 160),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: goal.isCompleted
                                ? const Icon(Icons.check,
                                    key: ValueKey('check'),
                                    size: 16,
                                    color: Colors.white)
                                : const SizedBox(key: ValueKey('empty')),
                          ),
                        ),
                      ),
                    ),

                    if (index != total - 1)
                      Expanded(
                        child: Center(child: _DashedLine(color: railColor)),
                      )
                    else
                      const SizedBox(height: 12),
                  ],
                ),
              ),

              // -------- ПРАВАЯ КАРТОЧКА --------
              Expanded(
                child: Card(
                  elevation: 0,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.15),
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: _GoalCell(goal: goal), // передаём goal напрямую
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

class _GoalCell extends StatelessWidget {
  final Goal goal;
  const _GoalCell({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      // без зачёркивания
    );
    final metaColor = theme.colorScheme.onSurface.withOpacity(0.75);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок + эмоция
        Row(
          children: [
            Expanded(
              child: Text(
                goal.title,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (goal.emotion.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(goal.emotion, style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
        const SizedBox(height: 6),

        // Метаданные “чипами”
        Wrap(
          runSpacing: 6,
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ChipLike(label: goal.lifeBlock),
            _ChipLike(label: 'Важность ${goal.importance}/5'),
            _ChipLike(label: 'Часы ${goal.spentHours.toStringAsFixed(1)}'),
          ],
        ),

        if (goal.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            goal.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: metaColor),
          ),
        ],
      ],
    );
  }
}

class _ChipLike extends StatelessWidget {
  final String label;
  const _ChipLike({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.75),
        ),
      ),
    );
  }
}

/// Пунктирная вертикальная линия (используется слева от кружков)
class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    // Ширина фиксированная (3px), высота — берётся от родителя (Expanded в колонке)
    return SizedBox(
      width: 3,
      child: CustomPaint(
        painter: _DashedLinePainter(color: color),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round;

    const dash = 8.0;
    const gap = 6.0;

    double y = 0;
    while (y < size.height) {
      double y2 = (y + dash).clamp(0, size.height);
      final cx = size.width / 2;
      canvas.drawLine(Offset(cx, y), Offset(cx, y2), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
