import 'package:flutter/material.dart';
import '../models/goal.dart';
import 'goal_cell.dart';
import 'dashed_line.dart';

class TimelineRow extends StatelessWidget {
  final Goal goal;
  final int index;
  final int total;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TimelineRow({
    super.key,
    required this.goal,
    required this.index,
    required this.total,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  static const double _railWidth = 84; // шире, чтобы уместить бейдж времени слева
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
              // -------- ЛЕВАЯ КОЛОНКА: время + пунктир + кружок --------
              SizedBox(
                width: _railWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Колонка с пунктиром и кружком
                    Column(
                      children: [
                        if (index != 0)
                          Expanded(
                            child: Center(child: DashedLine(color: railColor)),
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
                                child: goal.isCompleted
                                    ? const Icon(Icons.check,
                                        size: 16, color: Colors.white)
                                    : const SizedBox(),
                              ),
                            ),
                          ),
                        ),

                        if (index != total - 1)
                          Expanded(
                            child: Center(child: DashedLine(color: railColor)),
                          )
                        else
                          const SizedBox(height: 12),
                      ],
                    ),

                    // Бейдж времени — слева от кружка, по центру по вертикали
                    Positioned(
                      left: 0,
                      child: _TimeBadge(text: _fmtHHmm(goal.startTime)),
                    ),
                  ],
                ),
              ),

              // -------- ПРАВАЯ КАРТОЧКА (тап по карточке => меню редакт/удалить) --------
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showGoalActions(context),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: GoalCell(goal: goal),
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

  void _showGoalActions(BuildContext context) async {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Редактировать'),
                onTap: () {
                  Navigator.pop(ctx);
                  onEdit();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Удалить'),
                iconColor: theme.colorScheme.error,
                textColor: theme.colorScheme.error,
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  static String _fmtHHmm(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _TimeBadge extends StatelessWidget {
  final String text;
  const _TimeBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.18),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }
}
