import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;

export 'web_notifications_service_stub.dart'
    if (dart.library.html) 'web_notifications_service_web.dart';
