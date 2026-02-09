import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../widgets/add_day_goal_sheet.dart';
import '../widgets/timeline_row.dart';
import '../widgets/edit_goal_sheet.dart';
import '../widgets/import_journal.dart';

/// Лучше читать из --dart-define: --dart-define=VISION_API_KEY=...
const String _kVisionApiKey = String.fromEnvironment(
  'AIzaSyBBEjM1LYnJw1_SmsAJbZIl-y08xjF5X-s',
  defaultValue: '',
);

class DayGoalsScreen extends StatelessWidget {
  final DateTime date;
  final String? lifeBlock;
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

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _openAdd(BuildContext context) async {
    final vm = context.read<DayGoalsModel>();

    final res = await showModalBottomSheet<AddGoalResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PrettySheet(
        child: AddDayGoalSheet(
          fixedLifeBlock: vm.lifeBlock,
          availableBlocks: vm.availableBlocks,
        ),
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
        startTime: res.startTime,
      );

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 60));
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          );
        }
      }
    }
  }

  Future<void> _openEdit(BuildContext context, Goal g) async {
    final vm = context.read<DayGoalsModel>();

    final res = await showModalBottomSheet<AddGoalResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PrettySheet(
        child: EditGoalSheet(
          goal: g,
          fixedLifeBlock: vm.lifeBlock,
          availableBlocks: vm.availableBlocks,
        ),
      ),
    );

    if (res != null) {
      await vm.updateGoal(
        id: g.id,
        title: res.title,
        description: res.description,
        lifeBlockValue: res.lifeBlock,
        importance: res.importance,
        emotion: res.emotion,
        hours: res.hours,
        startTime: res.startTime,
      );
    }
  }

  List<Goal> _sortedByStartTime(List<Goal> src) {
    final list = List<Goal>.from(src);
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DayGoalsModel>();
    final goals = _sortedByStartTime(vm.goals);
    final title = vm.lifeBlock ?? 'Все сферы';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${vm.formattedDate}  •  $title'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: _PrettyFab(
        onManual: () => _openAdd(context),
        onScan: () =>
            importFromJournal(context, vm, visionApiKey: _kVisionApiKey),
      ),
      body: Stack(
        children: [
          const _SoftBackground(),
          SafeArea(
            child: vm.loading
                ? const Center(child: CircularProgressIndicator())
                : goals.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        controller: _scroll,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 116),
                        itemCount: goals.length,
                        itemBuilder: (_, i) {
                          final g = goals[i];
                          return _SoftLift(
                            index: i,
                            child: TimelineRow(
                              key: ValueKey(g.id),
                              goal: g,
                              index: i,
                              total: goals.length,
                              onToggle: () => vm.toggleComplete(g),
                              onDelete: () => vm.deleteGoal(g),
                              onEdit: () => _openEdit(context, g),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xB911121A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x22FFFFFF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const Text(
          'Целей на этот день нет',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

class _SoftBackground extends StatelessWidget {
  const _SoftBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B0C10), Color(0xFF0E1020), Color(0xFF0A0B12)],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(top: -120, left: -90, child: _GlowBlob(size: 280)),
          Positioned(bottom: -160, right: -110, child: _GlowBlob(size: 340)),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  const _GlowBlob({required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 44, sigmaY: 44),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color(0x332A7FFF), Color(0x001D1E2A)],
          ),
        ),
      ),
    );
  }
}

class _SoftLift extends StatelessWidget {
  final Widget child;
  final int index;

  const _SoftLift({required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    final lift = (index % 2 == 0) ? 0.0 : 1.5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Transform.translate(
        offset: Offset(0, -lift),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
              BoxShadow(
                color: Color(0x22FFFFFF),
                blurRadius: 18,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PrettySheet extends StatelessWidget {
  final Widget child;
  const _PrettySheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xCC11121A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
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
    );
  }
}

class _PrettyFab extends StatefulWidget {
  final VoidCallback onManual;
  final VoidCallback onScan;

  const _PrettyFab({required this.onManual, required this.onScan});

  @override
  State<_PrettyFab> createState() => _PrettyFabState();
}

class _PrettyFabState extends State<_PrettyFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  bool get _open => _c.value > 0.0;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toggle() => _open ? _c.reverse() : _c.forward();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_c.value);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _MiniAction(
              visibleT: t,
              icon: Icons.edit,
              label: 'Добавить',
              onTap: () {
                _c.reverse();
                widget.onManual();
              },
            ),
            const SizedBox(height: 10),
            _MiniAction(
              visibleT: t,
              icon: Icons.document_scanner_outlined,
              label: 'Скан',
              onTap: () {
                _c.reverse();
                widget.onScan();
              },
            ),
            const SizedBox(height: 10),
            _MainFabButton(
              open: _open,
              onTap: _toggle,
            ),
          ],
        );
      },
    );
  }
}

/// Мини-экшен без вложенных GestureDetector (важно для Web)
class _MiniAction extends StatelessWidget {
  final double visibleT;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniAction({
    required this.visibleT,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = visibleT.clamp(0.0, 1.0);
    final y = (1 - visibleT) * 14;

    return IgnorePointer(
      ignoring: opacity < 0.85,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, y),
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xCC11121A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x22FFFFFF)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 14,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(label, style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xCC11121A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x22FFFFFF)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 14,
                        offset: Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Color(0x11FFFFFF),
                        blurRadius: 12,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MainFabButton extends StatelessWidget {
  final bool open;
  final VoidCallback onTap;

  const _MainFabButton({
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6E7CFF), Color(0xFFB06CFF)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x22FFFFFF),
              blurRadius: 14,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Icon(
          open ? Icons.close : Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
