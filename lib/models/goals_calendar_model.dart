import 'package:flutter/foundation.dart';
import '../main.dart'; // dbRepo

class GoalsCalendarModel extends ChangeNotifier {
  List<String> _lifeBlocks = [];
  List<String> get lifeBlocks => _lifeBlocks;

  String _selectedBlock = 'all';
  String get selectedBlock => _selectedBlock;
  void setSelectedBlock(String v) {
    _selectedBlock = v;
    notifyListeners();
  }

  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime get month => _month;

  String get monthTitle =>
      '${_month.year}, ${_month.month.toString().padLeft(2, '0')}';

  Future<void> loadBlocks() async {
    // GoalService убран — идём напрямую в dbRepo
    _lifeBlocks = await dbRepo.getUserLifeBlocks();
    notifyListeners();
  }

  void prevMonth() {
    _month = DateTime(_month.year, _month.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _month = DateTime(_month.year, _month.month + 1);
    notifyListeners();
  }

  bool isSameMonth(DateTime d) =>
      d.month == _month.month && d.year == _month.year;

  List<DateTime> get daysInMonth {
    final first = DateTime(_month.year, _month.month, 1);
    final daysCount = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingEmpty = (first.weekday % 7); // воскресенье = 0
    final total = leadingEmpty + daysCount;
    final slots = (total / 7.0).ceil() * 7;

    return List.generate(slots, (i) {
      final dayOffset = i - leadingEmpty + 1;
      return DateTime(_month.year, _month.month, dayOffset);
    });
  }

  String? get selectedBlockOrNull =>
      _selectedBlock == 'all' ? null : _selectedBlock;
}
