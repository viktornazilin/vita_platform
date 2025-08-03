import 'package:hive/hive.dart';
import '../models/xp.dart';

class XPService {
  final Box<XP> _xpBox = Hive.box<XP>('xp');

  XP get xp {
    if (_xpBox.isEmpty) {
      _xpBox.put('xp', XP());
    }
    return _xpBox.get('xp')!;
  }

  void _save(XP updated) {
    _xpBox.put('xp', updated);
  }

  void rewardForGoal() {
    final current = xp;
    current.addXP(30);
    _save(current);
  }

  void rewardForMoodEntry() {
    final current = xp;
    current.addXP(10);
    _save(current);
  }
}
