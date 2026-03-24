import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kEnabledKey = 'daily_summary_enabled';
  static const _kHourKey = 'daily_summary_hour';
  static const _kMinuteKey = 'daily_summary_minute';

  bool _dailySummaryEnabled = false;
  TimeOfDay? _dailySummaryTime;

  bool get dailySummaryEnabled => _dailySummaryEnabled;
  TimeOfDay? get dailySummaryTime => _dailySummaryTime;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _dailySummaryEnabled = prefs.getBool(_kEnabledKey) ?? false;
    final hour = prefs.getInt(_kHourKey);
    final minute = prefs.getInt(_kMinuteKey);
    if (hour != null && minute != null) {
      _dailySummaryTime = TimeOfDay(hour: hour, minute: minute);
    }
    notifyListeners();
  }

  Future<void> setDailySummaryEnabled(bool enabled) async {
    _dailySummaryEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, enabled);
    // If disabling, we keep stored time (user can re-enable later)
    notifyListeners();
  }

  Future<void> setDailySummaryTime(TimeOfDay? time) async {
    _dailySummaryTime = time;
    final prefs = await SharedPreferences.getInstance();
    if (time == null) {
      await prefs.remove(_kHourKey);
      await prefs.remove(_kMinuteKey);
    } else {
      await prefs.setInt(_kHourKey, time.hour);
      await prefs.setInt(_kMinuteKey, time.minute);
    }
    notifyListeners();
  }
}
