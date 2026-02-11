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

  // ЛЕВАЯ КОЛОНКА: timeBadge + gap + dot
  static const double _timeBadgeWidth = 72;
  static const double _timeToDotGap = 10;
  static const double _dotRadius = 14;

  // ширина всей колонки слева
  static const double _railWidth = _timeBadgeWidth + _timeToDotGap + _dotRadius * 2;

  // X-координата центра dot внутри левой колонки — нужна для пунктиров
  static const double _dotCenterX = _timeBadgeWidth + _timeToDotGap + _dotRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final railColor = goal.isCompleted
        ? primary.withOpacity(0.85)
        : theme.colorScheme.outline.withOpacity(0.25);

    final duration = Duration(milliseconds: 220 + index * 60);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * 10), child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------- ЛЕВАЯ КОЛОНКА (время + чек строго на одной линии) ----------
              SizedBox(
                width: _railWidth,
                child: Stack(
                  children: [
                    // пунктиры — строго по X центра dot
                    Positioned.fill(
                      child: Column(
                        children: [
                          if (index != 0)
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Transform.translate(
                                  offset: const Offset(_dotCenterX - 1.5, 0), // 1.5 ~ половина dashedLine width
                                  child: DashedLine(color: railColor),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 12),

                          const SizedBox(height: _dotRadius * 2),

                          if (index != total - 1)
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Transform.translate(
                                  offset: const Offset(_dotCenterX - 1.5, 0),
                                  child: DashedLine(color: railColor),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    // время + dot в одной строке (❗️вот это фиксит “бегание”)
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          SizedBox(
                            width: _timeBadgeWidth,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _TimeBadge(
                                text: _fmtHHmm(goal.startTime),
                                isCompleted: goal.isCompleted,
                              ),
                            ),
                          ),
                          const SizedBox(width: _timeToDotGap),

                          // dot / check
                          GestureDetector(
                            onTap: onToggle,
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedScale(
                              scale: goal.isCompleted ? 1.06 : 1.0,
                              duration: const Duration(milliseconds: 180),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ---------- ПРАВАЯ КАРТОЧКА ----------
              Expanded(
                child: _GlassCard(
                  isCompleted: goal.isCompleted,
                  onTap: () => _showGoalActions(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                _SheetGrabber(color: theme.colorScheme.onSurface.withOpacity(0.25)),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Редактировать'),
                  onTap: () {
                    Navigator.pop(ctx);
                    onEdit();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  title: const Text('Удалить'),
                  textColor: theme.colorScheme.error,
                  iconColor: theme.colorScheme.error,
                  onTap: () {
                    Navigator.pop(ctx);
                    onDelete();
                  },
                ),
                const SizedBox(height: 10),
              ],
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
        color: Color(0x22000000),
        blurRadius: 18,
        offset: Offset(0, 12),
      ),
      const BoxShadow(
        color: Color(0x10FFFFFF),
        blurRadius: 14,
        offset: Offset(0, -6),
      ),
    ];

    final completedGlow = <BoxShadow>[
      BoxShadow(
        color: color.withOpacity(0.20),
        blurRadius: 18,
        spreadRadius: 1,
        offset: const Offset(0, 10),
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? color : surface,
        border: Border.all(
          color: isCompleted ? Colors.transparent : outline.withOpacity(0.45),
          width: isCompleted ? 0 : 2,
        ),
        boxShadow: isCompleted ? (baseShadows + completedGlow) : baseShadows,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
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
                    Colors.white.withOpacity(isCompleted ? 0.20 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 140),
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

class _GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isCompleted;

  const _GlassCard({
    required this.child,
    required this.onTap,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final overlay = isCompleted ? 0.10 : 0.06;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.72),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD6E6F5), width: 1.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(overlay),
                    Colors.transparent,
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x142B5B7A),
                    blurRadius: 22,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: child,
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

  const _TimeBadge({
    required this.text,
    required this.isCompleted,
  });

  static const _accent = Color(0xFF3AA8E6);
  static const _ink = Color(0xFF2E4B5A);

  @override
  Widget build(BuildContext context) {
    final borderColor = isCompleted ? _accent.withOpacity(0.45) : _accent.withOpacity(0.25);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x102B5B7A),
            blurRadius: 16,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
              color: _ink.withOpacity(0.92),
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
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.white.withOpacity(0.86),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              border: Border.all(color: const Color(0xFFD6E6F5)),
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
