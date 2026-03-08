// lib/widgets/timeline_row.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../models/goal.dart';
import 'dashed_line.dart';

class TimelineRow extends StatefulWidget {
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

  @override
  State<TimelineRow> createState() => _TimelineRowState();

  // ЛЕВАЯ КОЛОНКА: timeBadge + gap + dot
  static const double timeBadgeWidth = 72;
  static const double timeToDotGap = 10;
  static const double dotRadius = 14;

  // ширина всей колонки слева
  static const double railWidth =
      timeBadgeWidth + timeToDotGap + dotRadius * 2;

  // X-координата центра dot внутри левой колонки — нужна для пунктиров
  static const double dotCenterX =
      timeBadgeWidth + timeToDotGap + dotRadius;
}

class _TimelineRowState extends State<TimelineRow> {
  bool _expanded = false;

  Goal get goal => widget.goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blockStyle = _goalBlockStyle(goal.lifeBlock);

    final railColor = goal.isCompleted
        ? blockStyle.accent.withOpacity(0.85)
        : theme.colorScheme.outline.withOpacity(0.22);

    final duration = Duration(milliseconds: 220 + widget.index * 45);

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
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: TimelineRow.railWidth,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Column(
                        children: [
                          if (widget.index != 0)
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Transform.translate(
                                  offset: const Offset(
                                    TimelineRow.dotCenterX - 1.5,
                                    0,
                                  ),
                                  child: DashedLine(color: railColor),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 12),
                          const SizedBox(height: TimelineRow.dotRadius * 2),
                          if (widget.index != widget.total - 1)
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Transform.translate(
                                  offset: const Offset(
                                    TimelineRow.dotCenterX - 1.5,
                                    0,
                                  ),
                                  child: DashedLine(color: railColor),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          SizedBox(
                            width: TimelineRow.timeBadgeWidth,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _TimeBadge(
                                text: _fmtHHmm(goal.startTime),
                                isCompleted: goal.isCompleted,
                                accent: blockStyle.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: TimelineRow.timeToDotGap),
                          GestureDetector(
                            onTap: widget.onToggle,
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedScale(
                              scale: goal.isCompleted ? 1.06 : 1.0,
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutBack,
                              child: _SoftDot(
                                radius: TimelineRow.dotRadius,
                                isCompleted: goal.isCompleted,
                                color: blockStyle.accent,
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
              Expanded(
                child: _GlassCard(
                  isCompleted: goal.isCompleted,
                  accent: blockStyle.accent,
                  softBg: blockStyle.softBg,
                  onTap: () => setState(() => _expanded = !_expanded),
                  onMore: () => _showGoalActions(context),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: _GoalContent(
                        goal: goal,
                        expanded: _expanded,
                        accent: blockStyle.accent,
                        softBg: blockStyle.softBg,
                        icon: blockStyle.icon,
                        onEdit: widget.onEdit,
                        onDelete: widget.onDelete,
                      ),
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

  void _showGoalActions(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

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
                _SheetGrabber(
                  color: theme.colorScheme.onSurface.withOpacity(0.22),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(t.timelineActionEdit),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onEdit();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(t.timelineActionDelete),
                  textColor: theme.colorScheme.error,
                  iconColor: theme.colorScheme.error,
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onDelete();
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

class _GoalContent extends StatelessWidget {
  final Goal goal;
  final bool expanded;
  final Color accent;
  final Color softBg;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalContent({
    required this.goal,
    required this.expanded,
    required this.accent,
    required this.softBg,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
      height: 1.18,
      color: const Color(0xFF2E4B5A).withOpacity(goal.isCompleted ? 0.62 : 0.98),
    );

    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      height: 1.35,
      color: const Color(0xFF496474).withOpacity(goal.isCompleted ? 0.58 : 0.88),
    );

    return Opacity(
      opacity: goal.isCompleted ? 0.82 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AccentStripe(accent: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  goal.title,
                  maxLines: expanded ? 4 : 2,
                  overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
              const SizedBox(width: 10),
              _EmotionBadge(
                emotion: goal.emotion,
                accent: accent,
              ),
            ],
          ),

          if ((goal.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                goal.description!.trim(),
                maxLines: expanded ? null : 2,
                overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: bodyStyle,
              ),
            ),
          ],

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Text(
                  expanded ? 'Скрыть детали' : 'Показать детали',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accent.withOpacity(0.92),
                  ),
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: accent.withOpacity(0.9),
                  size: 24,
                ),
              ),
            ],
          ),

          if (expanded) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(
                  icon: icon,
                  text: goal.lifeBlock,
                  accent: accent,
                  softBg: softBg,
                ),
                _MetaChip(
                  icon: Icons.flag_rounded,
                  text: 'Важность ${goal.importance}/5',
                  accent: accent,
                  softBg: softBg,
                ),
                _MetaChip(
                  icon: Icons.schedule_rounded,
                  text: 'Часы ${goal.hours.toStringAsFixed(1)}',
                  accent: accent,
                  softBg: softBg,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Изменить',
                  accent: accent,
                  onTap: onEdit,
                ),
                const SizedBox(width: 10),
                _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Удалить',
                  accent: const Color(0xFFE76F6F),
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ],
      ),
    );
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
        color: color.withOpacity(0.22),
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
          color: isCompleted ? Colors.transparent : outline.withOpacity(0.42),
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
  final VoidCallback onMore;
  final bool isCompleted;
  final Color accent;
  final Color softBg;

  const _GlassCard({
    required this.child,
    required this.onTap,
    required this.onMore,
    required this.isCompleted,
    required this.accent,
    required this.softBg,
  });

  @override
  Widget build(BuildContext context) {
    final overlay = isCompleted ? 0.08 : 0.05;

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
                border: Border.all(
                  color: accent.withOpacity(isCompleted ? 0.16 : 0.26),
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    softBg.withOpacity(overlay + 0.08),
                    Colors.white.withOpacity(0.02),
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
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 5,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.95),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: child,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: onMore,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: accent.withOpacity(0.15),
                            ),
                          ),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            size: 20,
                            color: const Color(0xFF5C7A8E).withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
  final Color accent;

  const _TimeBadge({
    required this.text,
    required this.isCompleted,
    required this.accent,
  });

  static const _ink = Color(0xFF2E4B5A);

  @override
  Widget build(BuildContext context) {
    final borderColor = isCompleted
        ? accent.withOpacity(0.44)
        : accent.withOpacity(0.24);

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

class _EmotionBadge extends StatelessWidget {
  final String? emotion;
  final Color accent;

  const _EmotionBadge({
    required this.emotion,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final text = (emotion ?? '').trim().isEmpty ? '🙂' : emotion!.trim();

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.18)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x122B5B7A),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color accent;
  final Color softBg;

  const _MetaChip({
    required this.icon,
    required this.text,
    required this.accent,
    required this.softBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: softBg.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF385262),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccentStripe extends StatelessWidget {
  final Color accent;
  const _AccentStripe({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 34,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
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

class _GoalBlockStyle {
  final Color accent;
  final Color softBg;
  final IconData icon;

  const _GoalBlockStyle({
    required this.accent,
    required this.softBg,
    required this.icon,
  });
}

_GoalBlockStyle _goalBlockStyle(String? block) {
  switch ((block ?? '').trim().toLowerCase()) {
    case 'career':
    case 'карьера':
    case 'работа':
      return const _GoalBlockStyle(
        accent: Color(0xFF3B82F6),
        softBg: Color(0x663B82F6),
        icon: Icons.work_rounded,
      );
    case 'family':
    case 'семья':
      return const _GoalBlockStyle(
        accent: Color(0xFFF59E0B),
        softBg: Color(0x66F59E0B),
        icon: Icons.home_rounded,
      );
    case 'health':
    case 'здоровье':
    case 'спорт':
      return const _GoalBlockStyle(
        accent: Color(0xFF22C55E),
        softBg: Color(0x6622C55E),
        icon: Icons.favorite_rounded,
      );
    case 'finance':
    case 'финансы':
      return const _GoalBlockStyle(
        accent: Color(0xFFEAB308),
        softBg: Color(0x66EAB308),
        icon: Icons.savings_rounded,
      );
    case 'learning':
    case 'обучение':
    case 'учеба':
      return const _GoalBlockStyle(
        accent: Color(0xFFA855F7),
        softBg: Color(0x66A855F7),
        icon: Icons.school_rounded,
      );
    case 'social':
    case 'социальное':
    case 'друзья':
      return const _GoalBlockStyle(
        accent: Color(0xFFEF4444),
        softBg: Color(0x66EF4444),
        icon: Icons.groups_rounded,
      );
    case 'personal':
    case 'личное':
      return const _GoalBlockStyle(
        accent: Color(0xFFEC4899),
        softBg: Color(0x66EC4899),
        icon: Icons.person_rounded,
      );
    default:
      return const _GoalBlockStyle(
        accent: Color(0xFF64748B),
        softBg: Color(0x6664748B),
        icon: Icons.grid_view_rounded,
      );
  }
}