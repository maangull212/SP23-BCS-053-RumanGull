import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../ui/screens/task_detail_screen.dart';
import 'timezone_helper.dart';

import 'package:provider/provider.dart';

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String _tzName = 'UTC';

  // Snapshot of tasks
  List<Task> _cachedTasks = [];

  // Daily Summary IDs
  static const int _dailySummaryId = 7000;
  static const int _snoozedSummaryId = 7001;
  static const int _manualSummaryId = 7002;
  static const int _infoId = 7100;

  TimeOfDay? _lastDailyTime;
  DateTime? _nextDailySummaryAt;
  DateTime? _lastSummaryShownDay;
  Timer? _summaryWatchdog;

  // Native backup channel
  static const MethodChannel _alarmChannel = MethodChannel('taskmate/alarms');

  // Deep link navigation
  GlobalKey<NavigatorState>? _navigatorKey;
  String? _pendingPayload;
  bool _pendingNavigationProcessed = false;
  void Function(int tabIndex)? _tabSelector;

  // Init
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final sysTz = await TimezoneHelper.getSystemTimezone();
      _tzName = sysTz;
      tz.setLocalLocation(tz.getLocation(sysTz));
      debugPrint('[Notify] Timezone set $_tzName');
    } catch (e) {
      tz.setLocalLocation(tz.local);
      _tzName = 'local';
      debugPrint('[Notify] TZ fallback $e');
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) async {
        final payload = resp.payload;
        if (payload != null) {
          _handleNavigationPayload(payload);
        }
        // Action buttons
        if ((resp.actionId?.isNotEmpty ?? false)) {
          await _handleSummaryAction(resp.actionId!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: _backgroundResponseHandler,
    );

    // FIX: NotificationAppLaunchDetails no longer exposes a direct 'payload' property.
    // Only use notificationResponse?.payload.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final launchPayload = launchDetails?.notificationResponse?.payload;
      if (launchPayload != null && launchPayload.isNotEmpty) {
        _pendingPayload = launchPayload;
        debugPrint('[Notify] Stored launch payload=$_pendingPayload');
      }
    }

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'taskmate_tasks',
        'Taskmate Tasks',
        description: 'Task reminders, repeats & daily summary',
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  // Background tap handler (Android only)
  @pragma('vm:entry-point')
  static void _backgroundResponseHandler(NotificationResponse response) {
    // Defer navigation until app foreground initializes.
  }

  // Deep link configuration
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  void registerTabSelector(void Function(int index) selector) {
    _tabSelector = selector;
  }

  // Try processing stored launch payload (after auth + tasks ready)
  void tryProcessPendingNavigation(BuildContext context) {
    if (_pendingPayload == null || _pendingNavigationProcessed) return;

    final auth = context.read<AuthProvider>();
    final taskProv = context.read<TaskProvider>();
    if (!auth.initialized ||
        auth.currentUser == null ||
        !taskProv.initialized) {
      return;
    }

    final payload = _pendingPayload!;
    _pendingPayload = null;
    _pendingNavigationProcessed = true;
    debugPrint('[Notify] Processing pending payload=$payload');
    _handleNavigationPayload(payload);
  }

  void _handleNavigationPayload(String payload) {
    final ctx = _navigatorKey?.currentContext;
    if (ctx == null) {
      _pendingPayload = payload;
      _pendingNavigationProcessed = false;
      debugPrint('[Notify] Context missing, deferring payload=$payload');
      return;
    }

    if (payload.startsWith('task:')) {
      final parts = payload.split(':');
      if (parts.length >= 2) {
        final id = int.tryParse(parts[1]);
        if (id != null) {
          _openTaskDetail(ctx, id);
          return;
        }
      }
    } else if (payload.startsWith('summary:')) {
      _tabSelector?.call(0);
      ScaffoldMessenger.of(ctx)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Daily summary opened')),
        );
      return;
    }

    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Unknown notification: $payload')),
      );
  }

  void _openTaskDetail(BuildContext context, int taskId) {
    try {
      final taskProv = context.read<TaskProvider>();
      final taskExists = taskProv.all.any((t) => t.id == taskId);
      if (!taskExists) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Task not found')),
          );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskId: taskId),
        ),
      );
    } catch (e) {
      debugPrint('[Notify] Navigation error: $e');
    }
  }

  // Snapshot
  void updateTasksSnapshot(List<Task> tasks) {
    _cachedTasks = List.unmodifiable(tasks);
  }

  Future<bool> requestPermissionIfNeeded() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final res = await Permission.notification.request();
    return res.isGranted;
  }

  // Reschedule all from snapshot
  Future<void> rescheduleFromSnapshot() async {
    await requestPermissionIfNeeded();
    final now = DateTime.now();
    for (final t in _cachedTasks) {
      if (t.id == null || t.isCompleted || t.notifyAt == null) continue;
      final notifyAt = DateTime.fromMillisecondsSinceEpoch(t.notifyAt!);
      if (t.repeatType == RepeatType.none) {
        if (notifyAt.isAfter(now)) {
          await _scheduleOneTimeExact(t.id!, notifyAt, t);
        }
      } else {
        await schedulePersistentForTask(t);
      }
    }
  }

  // Task scheduling
  Future<void> schedulePersistentForTask(Task task) async {
    if (task.id == null || task.notifyAt == null || task.isCompleted) return;
    await requestPermissionIfNeeded();
    final base = DateTime.fromMillisecondsSinceEpoch(task.notifyAt!);
    switch (task.repeatType) {
      case RepeatType.none:
        await _scheduleOneTimeExact(task.id!, base, task);
        break;
      case RepeatType.daily:
        await cancelForTask(task.id!);
        await _scheduleRollingDaily(task, base);
        break;
      case RepeatType.weekly:
        await cancelForTask(task.id!);
        await _scheduleRollingWeekly(task, base);
        break;
    }
  }

  Future<void> cancelForTask(int taskId) async {
    await _plugin.cancel(taskId);
    for (var wd = 1; wd <= 7; wd++) {
      await _plugin.cancel(taskId * 10 + wd);
    }
    for (var i = 1; i <= 10; i++) {
      await _plugin.cancel(taskId * 1000 + i);
      await _cancelNativeAlarm(taskId * 1000 + i);
    }
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      if ((p.id ~/ 2000) == taskId) {
        await _plugin.cancel(p.id);
        await _cancelNativeAlarm(p.id);
      }
    }
    await _cancelNativeAlarm(taskId);
  }

  Future<void> showImmediateTaskReminder(Task task) async {
    if (task.id == null) return;
    await requestPermissionIfNeeded();
    await _plugin.show(
      task.id!,
      task.title,
      _bodyFor(task),
      _androidDetails(),
      payload: 'task:${task.id}',
    );
  }

  // Rolling Daily
  Future<void> _scheduleRollingDaily(Task task, DateTime baseNotifyAt) async {
    final hour = baseNotifyAt.hour;
    final minute = baseNotifyAt.minute;
    final now = DateTime.now();
    for (int offset = 0; offset < 3; offset++) {
      final target = DateTime(now.year, now.month, now.day, hour, minute)
          .add(Duration(days: offset));
      if (target.isBefore(now)) continue;
      final tzTime = _safeFutureExact(target);
      final id = task.id! * 1000 + (offset + 1);
      await _scheduleZoned(
        id,
        task.title,
        _bodyFor(task),
        tzTime,
        payload: 'task:${task.id}:daily:$offset',
      );
      await _scheduleNativeBackupAlarm(
        id: id,
        when: tzTime,
        title: task.title,
        body: _bodyFor(task),
      );
    }
  }

  // Rolling Weekly
  Future<void> _scheduleRollingWeekly(Task task, DateTime baseNotifyAt) async {
    final hour = baseNotifyAt.hour;
    final minute = baseNotifyAt.minute;
    final weekdays = task.repeatDays.isEmpty
        ? <int>[
            DateTime.fromMillisecondsSinceEpoch(task.dueDate ?? task.createdAt)
                .weekday
          ]
        : task.repeatDays;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final wd in weekdays) {
      DateTime candidate = today;
      while (candidate.weekday != wd || candidate.isBefore(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      for (int rep = 0; rep < 2; rep++) {
        final occ = DateTime(
          candidate.year,
          candidate.month,
          candidate.day,
          hour,
          minute,
        ).add(Duration(days: 7 * rep));
        if (occ.isBefore(now)) continue;
        final tzTime = _safeFutureExact(occ);
        final ymd = occ.year * 10000 + occ.month * 100 + occ.day;
        final id = task.id! * 2000 + (ymd % 10000);
        await _scheduleZoned(
          id,
          task.title,
          _bodyFor(task),
          tzTime,
          payload: 'task:${task.id}:weekly:$wd:$rep',
        );
        await _scheduleNativeBackupAlarm(
          id: id,
          when: tzTime,
          title: task.title,
          body: _bodyFor(task),
        );
      }
    }
  }

  Future<void> _scheduleOneTimeExact(int id, DateTime when, Task task) async {
    final tzWhen = _safeFutureExact(when);
    await _scheduleZoned(
      id,
      task.title,
      _bodyFor(task),
      tzWhen,
      payload: 'task:$id:once',
    );
    await _scheduleNativeBackupAlarm(
      id: id,
      when: tzWhen,
      title: task.title,
      body: _bodyFor(task),
    );
  }

  Future<void> _scheduleZoned(
    int id,
    String title,
    String body,
    tz.TZDateTime when, {
    required String payload,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        _androidDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        _androidDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    }
  }

  // Native backup alarm via method channel
  Future<void> _scheduleNativeBackupAlarm({
    required int id,
    required tz.TZDateTime when,
    required String title,
    required String body,
  }) async {
    if (!Platform.isAndroid) return;
    final epoch = when.millisecondsSinceEpoch;
    try {
      await _alarmChannel.invokeMethod('scheduleAlarm', {
        'id': id,
        'epochMillis': epoch,
        'title': title,
        'body': body,
      });
    } catch (e) {
      debugPrint('[Notify] Native alarm schedule failed id=$id -> $e');
    }
  }

  Future<void> _cancelNativeAlarm(int id) async {
    if (!Platform.isAndroid) return;
    try {
      await _alarmChannel.invokeMethod('cancelAlarm', {'id': id});
    } catch (_) {}
  }

  // Daily Summary
  Future<void> scheduleDailySummary(TimeOfDay time) async {
    await requestPermissionIfNeeded();
    _lastDailyTime = time;
    await cancelDailySummary();

    final next = _nextInstanceOfTimeWithTolerance(time);
    _nextDailySummaryAt = next.toLocal();

    final lines = _buildSummaryLines(DateTime.now());
    final inbox = InboxStyleInformation(
      lines.isEmpty ? ['No tasks today'] : lines.take(6).toList(),
      contentTitle: 'Today\'s tasks',
      summaryText: lines.isEmpty ? 'No tasks' : '${lines.length} task(s)',
    );

    await _plugin.zonedSchedule(
      _dailySummaryId,
      'Daily Summary',
      lines.isEmpty ? 'No tasks today' : 'You have ${lines.length} task(s)',
      next,
      _androidDetails(inbox: inbox, addSummaryActions: true, summary: true),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'summary:daily',
    );

    await _scheduleNativeBackupAlarm(
      id: _dailySummaryId,
      when: next,
      title: 'Daily Summary',
      body:
          lines.isEmpty ? 'No tasks today' : 'You have ${lines.length} task(s)',
    );

    _startSummaryWatchdog();
  }

  Future<void> cancelDailySummary() async {
    await _plugin.cancel(_dailySummaryId);
    await _plugin.cancel(_snoozedSummaryId);
    await _cancelNativeAlarm(_dailySummaryId);
    await _cancelNativeAlarm(_snoozedSummaryId);
    _nextDailySummaryAt = null;
    _summaryWatchdog?.cancel();
    _summaryWatchdog = null;
  }

  Future<void> scheduleSnoozedSummary() async {
    if (_lastDailyTime == null) return;
    final now = DateTime.now();
    DateTime when = now.add(const Duration(hours: 1));
    if (when.day != now.day) {
      when = DateTime(
        now.year,
        now.month,
        now.day + 1,
        _lastDailyTime!.hour,
        _lastDailyTime!.minute,
      );
    }
    final tzWhen = _safeFutureExact(when);
    _nextDailySummaryAt = tzWhen.toLocal();

    final lines = _buildSummaryLines(DateTime.now());
    final inbox = InboxStyleInformation(
      lines.isEmpty ? ['No tasks today'] : lines.take(6).toList(),
      contentTitle: 'Snoozed summary',
      summaryText: lines.isEmpty ? 'No tasks' : '${lines.length} task(s)',
    );

    await _plugin.zonedSchedule(
      _snoozedSummaryId,
      'Daily Summary (Snoozed)',
      lines.isEmpty ? 'No tasks today' : 'You have ${lines.length} task(s)',
      tzWhen,
      _androidDetails(inbox: inbox, addSummaryActions: true, summary: true),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'summary:snoozed',
    );

    await _scheduleNativeBackupAlarm(
      id: _snoozedSummaryId,
      when: tzWhen,
      title: 'Daily Summary (Snoozed)',
      body:
          lines.isEmpty ? 'No tasks today' : 'You have ${lines.length} task(s)',
    );

    _startSummaryWatchdog();
  }

  Future<void> refreshDailySummaryIfEnabled({
    required bool enabled,
    required TimeOfDay? time,
  }) async {
    if (!enabled || time == null) return;
    final now = DateTime.now();
    final target =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (target.isAfter(now)) {
      await scheduleDailySummary(time);
    }
  }

  Future<void> showDailySummaryNow() async {
    await requestPermissionIfNeeded();
    final lines = _buildSummaryLines(DateTime.now());
    final inbox = InboxStyleInformation(
      lines.isEmpty ? ['No tasks today'] : lines.take(6).toList(),
      contentTitle: 'Today\'s tasks',
      summaryText: lines.isEmpty ? 'No tasks' : '${lines.length} task(s)',
    );
    await _plugin.show(
      _manualSummaryId,
      'Daily Summary',
      lines.isEmpty ? 'No tasks today' : 'You have ${lines.length} task(s)',
      _androidDetails(inbox: inbox, addSummaryActions: true, summary: true),
      payload: 'summary:manual',
    );
    _registerSummaryShown();
  }

  void _startSummaryWatchdog() {
    _summaryWatchdog?.cancel();
    if (_nextDailySummaryAt == null) return;
    _summaryWatchdog = Timer.periodic(const Duration(seconds: 10), (_) async {
      final nextAt = _nextDailySummaryAt;
      if (nextAt == null) return;
      final now = DateTime.now();
      if (_lastSummaryShownDay != null &&
          _isSameDate(_lastSummaryShownDay!, now)) return;
      if (now.isAfter(nextAt.add(const Duration(seconds: 10)))) {
        final pending = await listPending();
        final stillPending = pending
            .any((p) => p.id == _dailySummaryId || p.id == _snoozedSummaryId);
        if (stillPending) {
          await showDailySummaryNow();
          await _plugin.cancel(_dailySummaryId);
          await _plugin.cancel(_snoozedSummaryId);
          await _cancelNativeAlarm(_dailySummaryId);
          await _cancelNativeAlarm(_snoozedSummaryId);
          if (_lastDailyTime != null) {
            await _scheduleNextDaySummary(_lastDailyTime!);
          }
        }
      }
    });
  }

  Future<void> _scheduleNextDaySummary(TimeOfDay time) async {
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day + 1, time.hour, time.minute);
    _nextDailySummaryAt = tomorrow;
    final lines = _buildSummaryLines(DateTime.now());
    final inbox = InboxStyleInformation(
      lines.isEmpty ? ['No tasks today'] : lines.take(6).toList(),
      contentTitle: 'Tomorrow preview',
      summaryText: lines.isEmpty ? 'No tasks' : '${lines.length} task(s)',
    );
    final tzWhen = _safeFutureExact(tomorrow);
    await _plugin.zonedSchedule(
      _dailySummaryId,
      'Daily Summary',
      lines.isEmpty ? 'No tasks today' : 'You have ${lines.length} task(s)',
      tzWhen,
      _androidDetails(inbox: inbox, addSummaryActions: true, summary: true),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'summary:daily',
    );
    await _scheduleNativeBackupAlarm(
      id: _dailySummaryId,
      when: tzWhen,
      title: 'Daily Summary',
      body:
          lines.isEmpty ? 'No tasks today' : 'You have ${lines.length} task(s)',
    );
  }

  void _registerSummaryShown() {
    final now = DateTime.now();
    _lastSummaryShownDay = DateTime(now.year, now.month, now.day);
  }




  Future<void> _handleSummaryAction(String actionId) async {
    switch (actionId) {
      case 'mark_read':
        await _plugin.cancel(_dailySummaryId);
        await _plugin.cancel(_snoozedSummaryId);
        await _cancelNativeAlarm(_dailySummaryId);
        await _cancelNativeAlarm(_snoozedSummaryId);
        _registerSummaryShown();
        if (_lastDailyTime != null) {
          await _scheduleNextDaySummary(_lastDailyTime!);
        }
        break;
      case 'snooze':
        await scheduleSnoozedSummary();
        break;
      case 'mark_all_done':
        await _performMarkAllDone();
        break;
      default:
        debugPrint('[NotifySummary] Unknown action $actionId');
    }
  }

  Future<void> _performMarkAllDone() async {
    int marked = 0;
    int skipped = 0;
    final now = DateTime.now();
    final tasks = _selectSummaryTasks(now);
    for (final t in tasks) {
      if (t.id == null) {
        skipped++;
        continue;
      }
      final idx = _cachedTasks.indexWhere((x) => x.id == t.id);
      if (idx != -1) {
        _cachedTasks[idx] = t.copyWith(
          isCompleted: true,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        marked++;
        await cancelForTask(t.id!);
      } else {
        skipped++;
      }
    }
    await _plugin.cancel(_dailySummaryId);
    await _plugin.cancel(_snoozedSummaryId);
    await _cancelNativeAlarm(_dailySummaryId);
    await _cancelNativeAlarm(_snoozedSummaryId);
    _registerSummaryShown();
    await showInfo(
      'Daily Summary',
      marked == 0 && skipped == 0
          ? 'Nothing to mark'
          : 'Marked $marked, skipped $skipped',
    );
    if (_lastDailyTime != null) {
      await _scheduleNextDaySummary(_lastDailyTime!);
    }
  }

  Future<void> showInfo(String title, String body) async {
    await _plugin.show(
      _infoId,
      title,
      body,
      _androidDetails(),
    );
  }

  // Summary selection
  List<String> _buildSummaryLines(DateTime now) =>
      _selectSummaryTasks(now).map((t) => t.title).toList();

  List<Task> _selectSummaryTasks(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final selected = <Task>[];
    for (final t in _cachedTasks) {
      if (t.isCompleted) continue;
      if (t.notifyAt != null) {
        final nAt = DateTime.fromMillisecondsSinceEpoch(t.notifyAt!);
        if (nAt.isAfter(now)) continue;
      }
      bool include = false;
      if (t.repeatType != RepeatType.none) {
        final start = t.dueDate != null
            ? DateTime.fromMillisecondsSinceEpoch(t.dueDate!)
            : DateTime.fromMillisecondsSinceEpoch(t.createdAt);
        final startDate = DateTime(start.year, start.month, start.day);
        if (!today.isBefore(startDate)) {
          if (t.repeatType == RepeatType.daily) {
            include = true;
          } else if (t.repeatType == RepeatType.weekly) {
            final wdList = t.repeatDays;
            if (wdList.isEmpty) {
              include = today.weekday ==
                  DateTime.fromMillisecondsSinceEpoch(t.dueDate ?? t.createdAt)
                      .weekday;
            } else {
              include = wdList.contains(today.weekday);
            }
          }
        }
      } else {
        if (t.dueDate != null) {
          final due = DateTime.fromMillisecondsSinceEpoch(t.dueDate!);
          final dueDate = DateTime(due.year, due.month, due.day);
          if (dueDate.isAtSameMomentAs(today) || dueDate.isBefore(today)) {
            include = true;
          }
        }
      }
      if (include) selected.add(t);
    }
    return selected;
  }

  // Helpers
  String _bodyFor(Task task) => task.description.isEmpty
      ? 'Open Taskmate to view details.'
      : task.description;

  NotificationDetails _androidDetails({
    InboxStyleInformation? inbox,
    bool addSummaryActions = false,
    bool summary = false,
  }) {
    final actions = addSummaryActions
        ? <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'mark_all_done',
              'Mark All Done',
              showsUserInterface: true,
              cancelNotification: true,
            ),
            const AndroidNotificationAction(
              'mark_read',
              'Mark Read',
              showsUserInterface: true,
              cancelNotification: true,
            ),
            const AndroidNotificationAction(
              'snooze',
              'Snooze',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ]
        : <AndroidNotificationAction>[];

    final android = AndroidNotificationDetails(
      'taskmate_tasks',
      'Taskmate Tasks',
      channelDescription:
          'Task reminders, rolling repeats & daily summary notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
      icon: '@mipmap/ic_launcher',
      styleInformation: inbox,
      actions: actions,
      groupKey: summary ? 'taskmate_daily_summary_group' : null,
    );
    return NotificationDetails(android: android);
  }

  tz.TZDateTime _safeFutureExact(DateTime whenLocal) {
    final now = tz.TZDateTime.now(tz.local);
    var target = tz.TZDateTime.from(whenLocal, tz.local);
    if (target.isBefore(now)) {
      target = now.add(const Duration(seconds: 15));
    }
    return target;
  }

  tz.TZDateTime _nextInstanceOfTimeWithTolerance(TimeOfDay tod,
      {Duration tolerance = const Duration(seconds: 60)}) {
    final nowDart = DateTime.now();
    final intended = DateTime(
      nowDart.year,
      nowDart.month,
      nowDart.day,
      tod.hour,
      tod.minute,
    );
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime.from(intended, tz.local);
    if (scheduled.isBefore(now)) {
      final diff = now.difference(scheduled);
      if (diff <= tolerance) {
        scheduled = now.add(const Duration(seconds: 2));
      } else {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    }
    return scheduled;
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<List<PendingNotificationRequest>> listPending() =>
      _plugin.pendingNotificationRequests();
}
