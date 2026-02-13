class WebNotificationsService {
  Future<void> init() async {}
  Future<bool> requestPermission() async => false;
  bool get isSupported => false;

  void scheduleDaily({
    required String key,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) {}

  void cancel(String key) {}
  void cancelAll() {}
}
