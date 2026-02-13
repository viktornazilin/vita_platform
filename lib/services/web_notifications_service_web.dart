import 'dart:async';
import 'dart:html' as html;

class WebNotificationsService {
  final Map<String, Timer> _timers = {};
  final String _lsPrefix = 'vita_webnotif_';

  bool get isSupported => html.Notification.supported;

  Future<void> init() async {
    // ничего
  }

  Future<bool> requestPermission() async {
    if (!isSupported) return false;

    if (html.Notification.permission == 'granted') return true;
    if (html.Notification.permission == 'denied') return false;

    final p = await html.Notification.requestPermission();
    return p == 'granted';
  }

  void scheduleDaily({
    required String key,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) {
    _timers[key]?.cancel();

    void scheduleNext() {
      final now = DateTime.now();
      var next = DateTime(now.year, now.month, now.day, hour, minute);
      if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

      final delay = next.difference(now);

      _timers[key]?.cancel();
      _timers[key] = Timer(delay, () async {
        // анти-дубликат: не показываем дважды в один день
        final dayKey = '${next.year}-${next.month}-${next.day}';
        final lsKey = '$_lsPrefix$key:$dayKey';
        if (html.window.localStorage[lsKey] == '1') {
          scheduleNext();
          return;
        }

        if (html.Notification.permission != 'granted') {
          scheduleNext();
          return;
        }

        html.Notification(title, body: body);
        html.window.localStorage[lsKey] = '1';

        // планируем следующий запуск
        scheduleNext();
      });
    }

    scheduleNext();
  }

  void cancel(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  void cancelAll() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
  }
}
