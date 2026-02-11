import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../widgets/add_day_goal_sheet.dart';
import '../widgets/timeline_row.dart';
import '../widgets/edit_goal_sheet.dart';
import '../widgets/import_journal.dart';

/// ✅ Правильно: имя переменной, а не сам ключ
/// запуск: flutter run --dart-define=VISION_API_KEY=xxxxx
const String _kVisionApiKey = String.fromEnvironment(
  'VISION_API_KEY',
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
      builder: (_) => _NestSheet(
        child: AddDayGoalSheet(
          fixedLifeBlock: vm.lifeBlock,
          availableBlocks: vm.availableBlocks,
        ),
      ),
    );

    if (res == null) return;

    await vm.createGoal(
      title: res.title,
      description: res.description,
      lifeBlockValue: res.lifeBlock,
      importance: res.importance,
      emotion: res.emotion,
      hours: res.hours,
      startTime: res.startTime,
    );

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 80));
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _openEdit(BuildContext context, Goal g) async {
    final vm = context.read<DayGoalsModel>();

    final res = await showModalBottomSheet<AddGoalResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NestSheet(
        child: EditGoalSheet(
          goal: g,
          fixedLifeBlock: vm.lifeBlock,
          availableBlocks: vm.availableBlocks,
        ),
      ),
    );

    if (res == null) return;

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
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      /// ✅ Только “+”, меню появляется по нажатию
      floatingActionButton: _MainFab(
        onAdd: () => _openAdd(context),
        onScan: () => importFromJournal(
          context,
          vm,
          visionApiKey: _kVisionApiKey,
        ),
      ),

      body: Stack(
        children: [
          const _NestBackground(),
          SafeArea(
            child: vm.loading
                ? const Center(child: CircularProgressIndicator())
                : goals.isEmpty
                    ? const _NestEmptyState()
                    : ListView.builder(
                        controller: _scroll,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 116),
                        itemCount: goals.length,
                        itemBuilder: (_, i) {
                          final g = goals[i];
                          return TimelineRow(
                            key: ValueKey(g.id),
                            goal: g,
                            index: i,
                            total: goals.length,
                            onToggle: () => vm.toggleComplete(g),
                            onDelete: () => vm.deleteGoal(g),
                            onEdit: () => _openEdit(context, g),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _NestBackground extends StatelessWidget {
  const _NestBackground();

  @override
  Widget build(BuildContext context) {
    // Палитра как на интро (воздушный голубой)
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7FCFF),
            Color(0xFFEAF6FF),
            Color(0xFFD7EEFF),
            Color(0xFFF2FAFF),
          ],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(top: -140, left: -120, child: _SoftBlob(size: 360)),
          Positioned(bottom: -180, right: -140, child: _SoftBlob(size: 420)),
          Positioned(top: 120, right: -90, child: _SoftBlob(size: 240)),
        ],
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  final double size;
  const _SoftBlob({required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Color(0x663AA8E6),
              Color(0x0058B9FF),
            ],
          ),
        ),
      ),
    );
  }
}

class _NestEmptyState extends StatelessWidget {
  const _NestEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.70),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD6E6F5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A2B5B7A),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Text(
          'Целей на этот день нет',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E4B5A),
              ),
        ),
      ),
    );
  }
}

class _NestSheet extends StatelessWidget {
  final Widget child;
  const _NestSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2B5B7A),
                blurRadius: 28,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// ===============================
/// FAB: один "+" → меню (Add/Scan)
/// ===============================

enum _FabAction { add, scan }

class _MainFab extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onScan;

  const _MainFab({required this.onAdd, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 62,
      child: FloatingActionButton(
        onPressed: () => _openMenu(context),
        elevation: 10,
        backgroundColor: const Color(0xFF3AA8E6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    final action = await showModalBottomSheet<_FabAction>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FabMenuSheet(),
    );

    if (action == null) return;

    if (action == _FabAction.add) {
      onAdd();
    } else {
      onScan();
    }
  }
}

class _FabMenuSheet extends StatelessWidget {
  const _FabMenuSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2B5B7A),
                blurRadius: 28,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9BC7E6).withOpacity(0.55),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FabMenuButton(
                    icon: Icons.edit_rounded,
                    title: 'Добавить цель',
                    subtitle: 'Создать вручную',
                    onTap: () => Navigator.pop(context, _FabAction.add),
                  ),
                  const SizedBox(height: 10),
                  _FabMenuButton(
                    icon: Icons.document_scanner_rounded,
                    title: 'Скан',
                    subtitle: 'Фото ежедневника',
                    onTap: () => Navigator.pop(context, _FabAction.scan),
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

class _FabMenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FabMenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4FAFF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6E6F5)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3AA8E6), Color(0xFF7DD3FC)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x162B5B7A),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2E4B5A),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF2E4B5A).withOpacity(0.65),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF7AAECF)),
            ],
          ),
        ),
      ),
    );
  }
}
