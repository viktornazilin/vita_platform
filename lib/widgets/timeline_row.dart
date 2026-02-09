// lib/widgets/timeline_row.dart
import 'dart:ui';
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

  // ширина левой колонки (время + зазор + круг)
  static const double _railWidth = 100;
  static const double _dotRadius = 14;

  // фиксированная ширина под бейдж времени и зазор до кружка
  static const double _timeBadgeWidth = 58; // под "HH:mm"
  static const double _timeToDotGap = 8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final railColor = goal.isCompleted
        ? primary.withOpacity(0.9)
        : theme.colorScheme.outline.withOpacity(0.28);

    // Стэггер-анимация появления строки
    final duration = Duration(milliseconds: 220 + index * 60);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
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
                    // Сдвигаем рейку (пунктир + круг) вправо, оставив место под время
                    Padding(
                      padding: const EdgeInsets.only(
                        left: _timeBadgeWidth + _timeToDotGap,
                      ),
                      child: Column(
                        children: [
                          if (index != 0)
                            Expanded(
                              child: Center(
                                child: DashedLine(color: railColor),
                              ),
                            )
                          else
                            const SizedBox(height: 12),

                          // Кружок: мягкий объём + glow при выполнении
                          GestureDetector(
                            onTap: onToggle,
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedScale(
                              scale: goal.isCompleted ? 1.08 : 1.0,
                              duration: const Duration(milliseconds: 190),
                              curve: Curves.easeOutBack,
                              child: _SoftDot(
                                radius: _dotRadius,
                                isCompleted: goal.isCompleted,
                                color: primary,
                                surface: theme.colorScheme.surface,
                                outline: theme.colorScheme.outline,
                              ),
                            ),
                          ),

                          if (index != total - 1)
                            Expanded(
                              child: Center(
                                child: DashedLine(color: railColor),
                              ),
                            )
                          else
                            const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    // Бейдж времени — фикс-ширина слева, по центру по вертикали
                    Positioned(
                      left: 0,
                      child: SizedBox(
                        width: _timeBadgeWidth,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _TimeBadge(
                            text: _fmtHHmm(goal.startTime),
                            isCompleted: goal.isCompleted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // -------- ПРАВАЯ КАРТОЧКА (клик => actions) --------
              Expanded(
                child: _GlassCard(
                  isCompleted: goal.isCompleted,
                  onTap: () => _showGoalActions(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: GoalCell(goal: goal),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalActions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _GlassSheet(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SheetGrabber(
                    color: theme.colorScheme.onSurface.withOpacity(0.25),
                  ),
                  const SizedBox(height: 12),

                  _ActionTile(
                    icon: Icons.edit_outlined,
                    title: 'Редактировать',
                    onTap: () {
                      Navigator.pop(ctx);
                      onEdit();
                    },
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.delete_outline,
                    title: 'Удалить',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(ctx);
                      onDelete();
                    },
                  ),

                  const SizedBox(height: 6),
                ],
              ),
            ),
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

class _SoftDot extends StatelessWidget {
  final double radius;
  final bool isCompleted;
  final Color color;
  final Color surface;
  final Color outline;

  const _SoftDot({
    required this.radius,
    required this.isCompleted,
    required this.color,
    required this.surface,
    required this.outline,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    final baseShadows = <BoxShadow>[
      const BoxShadow(
        color: Color(0x55000000),
        blurRadius: 16,
        offset: Offset(0, 10),
      ),
      const BoxShadow(
        color: Color(0x22FFFFFF),
        blurRadius: 14,
        offset: Offset(0, -6),
      ),
    ];

    final completedGlow = <BoxShadow>[
      BoxShadow(
        color: color.withOpacity(0.28),
        blurRadius: 18,
        spreadRadius: 1,
        offset: const Offset(0, 8),
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? color : surface,
        border: Border.all(
          color: isCompleted
              ? color.withOpacity(0.0)
              : outline.withOpacity(0.55),
          width: isCompleted ? 0 : 2,
        ),
        boxShadow: isCompleted ? (baseShadows + completedGlow) : baseShadows,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // “блик” сверху для 3D-эффекта
          Positioned(
            top: 3,
            left: 4,
            child: Container(
              width: radius,
              height: radius * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(isCompleted ? 0.22 : 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    key: ValueKey('check'),
                    size: 16,
                    color: Colors.white,
                  )
                : const SizedBox(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isCompleted;

  const _GlassCard({
    required this.child,
    required this.onTap,
    required this.isCompleted,
  });

  @override
  State<_GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<_GlassCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseColor = const Color(0xB911121A);
    final overlay = widget.isCompleted ? 0.10 : 0.06;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.99 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(overlay),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 22,
                    offset: Offset(0, 14),
                  ),
                  const BoxShadow(
                    color: Color(0x18FFFFFF),
                    blurRadius: 18,
                    offset: Offset(0, -6),
                  ),
                  if (_pressed)
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  final String text;
  final bool isCompleted;

  const _TimeBadge({required this.text, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x8011121A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (isCompleted ? primary : Colors.white).withOpacity(0.18),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 16,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Color(0x14FFFFFF),
                blurRadius: 12,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: 0.2,
              color: theme.colorScheme.onSurface.withOpacity(0.85),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSheet extends StatelessWidget {
  final Widget child;
  const _GlassSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xCC11121A),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              border: Border.all(color: const Color(0x22FFFFFF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 30,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  final Color color;
  const _SheetGrabber({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface.withOpacity(0.92);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0x6611121A),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 16,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x14FFFFFF),
              blurRadius: 12,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}
