import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class TimezoneHelper {
  static const _channel = MethodChannel('taskmate/timezone');

  /// Returns a full timezone ID (e.g., "Asia/Karachi") or "UTC" as fallback.
  static Future<String> getSystemTimezone() async {
    if (!Platform.isAndroid) {
      return 'UTC'; // iOS not targeted now
    }
    try {
      final tz = await _channel.invokeMethod<String>('getTimezone');
      if (tz != null && tz.trim().isNotEmpty) {
        return tz;
      }
      return 'UTC';
    } catch (_) {
      return 'UTC';
    }
  }
}
