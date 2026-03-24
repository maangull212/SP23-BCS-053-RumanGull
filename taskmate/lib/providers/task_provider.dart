import 'dart:async';
import 'package:flutter/material.dart';

import '../data/models/task_model.dart';
import '../data/models/subtask_model.dart';
import '../data/repositories/task_repository.dart';
import '../data/repositories/subtask_repository.dart';
import '../utils/date_time_utils.dart';
import '../services/notifications/notifications_service.dart';
import '../services/toast_service.dart';
import 'settings_provider.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repo = TaskRepository();
  final SubtaskRepository _subRepo = SubtaskRepository();

  bool _initialized = false;
  bool get initialized => _initialized;

  int? _userId;
  int? get userId => _userId;

  List<Task> _all = [];
  List<Task> get all => _all;

  String? _error;
  String? get error => _error;

  // Subtask summaries cache
  final Map<int, SubtaskSummary> _subSummary = {};
  SubtaskSummary? getSubtaskSummary(int taskId) => _subSummary[taskId];

  // Fallback fired tracking
  final Set<int> _firedTaskIds = {};
  Timer? _fallbackTimer;

  DateTime _selectedDate = normalizeDate(DateTime.now());
  DateTime get selectedDate => _selectedDate;

  // Sample tasks used for onboarding removal
  static const _sampleTitles = {
    'Welcome to Taskmate',
    'Daily Standup',
  };

  // ---------------- Initialization ----------------
  Future<void> init({required int userId, SettingsProvider? settings}) async {
    _userId = userId;
    try {
      await _repo.init();
      _all = await _repo.fetchAllByUser(userId);

      // Remove samples if user has real tasks
      if (_all.any((t) => !_sampleTitles.contains(t.title))) {
        final sampleIds = _all
            .where((t) => _sampleTitles.contains(t.title))
            .map((t) => t.id)
            .whereType<int>()
            .toList();
        for (final id in sampleIds) {
          await _repo.delete(id);
        }
        if (sampleIds.isNotEmpty) {
          _all = await _repo.fetchAllByUser(userId);
        }
      }

      _error = null;
    } catch (e, st) {
      _error = e.toString();
      _all = const [];
      // ignore: avoid_print
      print('TaskProvider.init error: $e\n$st');
    } finally {
      _initialized = true;
      // Update snapshot & persistently schedule future reminders
      NotificationsService.instance.updateTasksSnapshot(_all);
      await NotificationsService.instance.rescheduleFromSnapshot();

      // Daily summary refresh if already enabled
      if (settings != null) {
        await NotificationsService.instance.refreshDailySummaryIfEnabled(
          enabled: settings.dailySummaryEnabled,
          time: settings.dailySummaryTime,
        );
      }

      _startFallbackWatcher();
      notifyListeners();
    }
  }

  void reset() {
    _fallbackTimer?.cancel();
    _initialized = false;
    _userId = null;
    _all = [];
    _subSummary.clear();
    _firedTaskIds.clear();
    _error = null;
    _selectedDate = normalizeDate(DateTime.now());
    NotificationsService.instance.updateTasksSnapshot(_all);
    notifyListeners();
  }

  // ---------------- Basic Derived Lists ----------------
  List<Task> get todayTasks => tasksForDate(DateTime.now());

  List<Task> get completedTasks => _all.where((t) => t.isCompleted).toList();

  List<Task> get repeatedTasks =>
      _all.where((t) => t.repeatType != RepeatType.none).toList();

  void selectDate(DateTime date) {
    final normalized = normalizeDate(date);
    if (isSameDay(normalized, _selectedDate)) return;
    _selectedDate = normalized;
    notifyListeners();
  }

  List<Task> tasksForDate(DateTime date) {
    final target = normalizeDate(date);
    final weekday = target.weekday;
    return _all.where((t) {
      if (t.isCompleted) return false;
      if (t.repeatType != RepeatType.none) {
        final start = _repeatStartDate(t);
        if (target.isBefore(start)) return false;
        if (t.repeatType == RepeatType.daily) return true;
        if (t.repeatType == RepeatType.weekly) {
          if (t.repeatDays.isEmpty) {
            return weekday ==
                DateTime.fromMillisecondsSinceEpoch(t.dueDate ?? t.createdAt)
                    .weekday;
          }
          return t.repeatDays.contains(weekday);
        }
        return false;
      }
      if (t.dueDate == null) return false;
      final due = DateTime.fromMillisecondsSinceEpoch(t.dueDate!);
      return isSameDay(due, target);
    }).toList();
  }

  DateTime _repeatStartDate(Task t) {
    if (t.dueDate != null) {
      return normalizeDate(DateTime.fromMillisecondsSinceEpoch(t.dueDate!));
    }
    return normalizeDate(DateTime.fromMillisecondsSinceEpoch(t.createdAt));
  }

  // ---------------- Calendar Markers ----------------
  Map<DateTime, int> markersForMonth(DateTime month,
      {String categoryFilter = TaskCategories.all}) {
    final first = startOfMonth(month);
    final last = endOfMonth(month);
    final map = <DateTime, int>{};
    for (final day in daysBetweenInclusive(first, last)) {
      final dailyTasks = tasksForDate(day).where((t) {
        if (categoryFilter == TaskCategories.all) return true;
        if (categoryFilter == TaskCategories.none) {
          return t.category == TaskCategories.none;
        }
        return t.category == categoryFilter;
      }).toList();
      if (dailyTasks.isNotEmpty) {
        map[normalizeDate(day)] = dailyTasks.length;
      }
    }
    return map;
  }

  // ---------------- Refresh (pull-to-refresh) ----------------
  Future<void> refresh([SettingsProvider? settings]) async {
    if (_userId == null) return;
    try {
      _all = await _repo.fetchAllByUser(_userId!);
      _error = null;
    } catch (e, st) {
      _error = e.toString();
      print('TaskProvider.refresh error: $e\n$st');
      ToastService.instance.showError('Refresh failed');
    } finally {
      NotificationsService.instance.updateTasksSnapshot(_all);
      await NotificationsService.instance.rescheduleFromSnapshot();

      if (settings != null) {
        await NotificationsService.instance.refreshDailySummaryIfEnabled(
          enabled: settings.dailySummaryEnabled,
          time: settings.dailySummaryTime,
        );
      }
      ToastService.instance.showInfo('Tasks refreshed');
      notifyListeners();
    }
  }

  // ---------------- CRUD ----------------
  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    RepeatType repeatType = RepeatType.none,
    List<int> repeatDays = const [],
    DateTime? notifyAt,
    String category = TaskCategories.none,
    SettingsProvider? settings,
  }) async {
    if (_userId == null) return;
    final now = DateTime.now();
    final task = Task(
      id: null,
      title: title,
      description: description ?? '',
      dueDate: dueDate?.millisecondsSinceEpoch,
      isCompleted: false,
      repeatType: repeatType,
      repeatDays: repeatDays,
      notifyAt: notifyAt?.millisecondsSinceEpoch,
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
      category: category,
      userId: _userId,
    );
    final id = await _repo.insert(task);
    final inserted = task.copyWith(id: id);
    _all.add(inserted);

    // Remove sample tasks if real content exists
    if (_all.any((t) => !_sampleTitles.contains(t.title))) {
      final sampleIds = _all
          .where((t) => _sampleTitles.contains(t.title))
          .map((t) => t.id)
          .whereType<int>()
          .toList();
      for (final sid in sampleIds) {
        await _repo.delete(sid);
      }
      _all.removeWhere((t) => sampleIds.contains(t.id));
    }

    NotificationsService.instance.updateTasksSnapshot(_all);
    await NotificationsService.instance.schedulePersistentForTask(inserted);

    if (settings != null) {
      NotificationsService.instance.refreshDailySummaryIfEnabled(
        enabled: settings.dailySummaryEnabled,
        time: settings.dailySummaryTime,
      );
    }

    ToastService.instance.showSuccess('Task added');
    notifyListeners();
  }

  Future<void> updateTask({
    required Task original,
    required String title,
    required String description,
    DateTime? dueDate,
    RepeatType repeatType = RepeatType.none,
    List<int> repeatDays = const [],
    DateTime? notifyAt,
    String category = TaskCategories.none,
    SettingsProvider? settings,
  }) async {
    final updated = original.copyWith(
      title: title,
      description: description,
      dueDate: dueDate?.millisecondsSinceEpoch,
      repeatType: repeatType,
      repeatDays: repeatDays,
      notifyAt: notifyAt?.millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      category: category,
      userId: _userId,
    );
    await _repo.update(updated);
    _replace(updated);

    if (updated.id != null) {
      await NotificationsService.instance.cancelForTask(updated.id!);
      await NotificationsService.instance.schedulePersistentForTask(updated);
    }

    NotificationsService.instance.updateTasksSnapshot(_all);

    if (settings != null) {
      NotificationsService.instance.refreshDailySummaryIfEnabled(
        enabled: settings.dailySummaryEnabled,
        time: settings.dailySummaryTime,
      );
    }

    ToastService.instance.showSuccess('Task updated');
  }

  Future<bool> tryToggleComplete(Task task,
      {SettingsProvider? settings}) async {
    final goingComplete = !task.isCompleted;
    if (goingComplete && task.id != null) {
      final counts = await _subRepo.getCounts(task.id!);
      final hasSubs = counts.totalCount > 0;
      final allDone = counts.completedCount >= counts.totalCount;
      if (hasSubs && !allDone) {
        ToastService.instance.showWarning('Complete subtasks first');
        return false;
      }
    }
    await toggleComplete(task);

    final refreshed = _all.firstWhere((t) => t.id == task.id);
    if (!refreshed.isCompleted &&
        refreshed.notifyAt != null &&
        refreshed.repeatType != RepeatType.none &&
        refreshed.id != null) {
      await NotificationsService.instance.schedulePersistentForTask(refreshed);
    }

    NotificationsService.instance.updateTasksSnapshot(_all);

    if (settings != null) {
      NotificationsService.instance.refreshDailySummaryIfEnabled(
        enabled: settings.dailySummaryEnabled,
        time: settings.dailySummaryTime,
      );
    }

    ToastService.instance
        .showInfo(goingComplete ? 'Task completed' : 'Task marked incomplete');
    return true;
  }

  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repo.update(updated);
    _replace(updated);
    if (updated.isCompleted && updated.id != null) {
      await NotificationsService.instance.cancelForTask(updated.id!);
    }
  }

  Future<void> deleteTask(Task task, {SettingsProvider? settings}) async {
    if (task.id == null) return;
    await _repo.delete(task.id!);
    _all.removeWhere((t) => t.id == task.id);
    _subSummary.remove(task.id);
    _firedTaskIds.remove(task.id);
    await NotificationsService.instance.cancelForTask(task.id!);

    NotificationsService.instance.updateTasksSnapshot(_all);
    if (settings != null) {
      NotificationsService.instance.refreshDailySummaryIfEnabled(
        enabled: settings.dailySummaryEnabled,
        time: settings.dailySummaryTime,
      );
    }
    ToastService.instance.showInfo('Task deleted');
    notifyListeners();
  }

  Future<Task> restoreTask(Task deleted, {SettingsProvider? settings}) async {
    final reminderAt = deleted.notifyAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(deleted.notifyAt!);
    final toInsert = deleted.copyWith(
      id: null,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      userId: _userId,
    );
    final newId = await _repo.insert(toInsert);
    final restored = toInsert.copyWith(id: newId);
    _all.add(restored);

    NotificationsService.instance.updateTasksSnapshot(_all);

    if (reminderAt != null) {
      await NotificationsService.instance.schedulePersistentForTask(restored);
    }

    if (settings != null) {
      NotificationsService.instance.refreshDailySummaryIfEnabled(
        enabled: settings.dailySummaryEnabled,
        time: settings.dailySummaryTime,
      );
    }
    ToastService.instance.showSuccess('Task restored');
    notifyListeners();
    return restored;
  }

  // ---------------- Subtasks ----------------
  Future<List<Subtask>> fetchSubtasks(int taskId) async {
    return _subRepo.fetchByTask(taskId);
  }

  Future<void> addSubtask(int taskId, String title,
      {SettingsProvider? settings}) async {
    final st =
        Subtask(id: null, taskId: taskId, title: title, isCompleted: false);
    await _subRepo.insert(st);
    await loadSubtasksSummary(taskId);

    NotificationsService.instance.updateTasksSnapshot(_all);
    if (settings != null) {
      NotificationsService.instance.refreshDailySummaryIfEnabled(
        enabled: settings.dailySummaryEnabled,
        time: settings.dailySummaryTime,
      );
    }
    ToastService.instance.showSuccess('Subtask added');
  }

  Future<void> toggleSubtask(Subtask subtask,
      {SettingsProvider? settings}) async {
    final updated = subtask.copyWith(isCompleted: !subtask.isCompleted);
    await _subRepo.update(updated);
    await loadSubtasksSummary(subtask.taskId);

    NotificationsService.instance.updateTasksSnapshot(_all);
    if (settings != null) {
      NotificationsService.instance.refreshDailySummaryIfEnabled(
        enabled: settings.dailySummaryEnabled,
        time: settings.dailySummaryTime,
      );
    }
    ToastService.instance
        .showInfo(updated.isCompleted ? 'Subtask done' : 'Subtask undone');
  }

  Future<void> deleteSubtask(Subtask subtask,
      {SettingsProvider? settings}) async {
    await _subRepo.delete(subtask.id!);
    await loadSubtasksSummary(subtask.taskId);

    NotificationsService.instance.updateTasksSnapshot(_all);
    if (settings != null) {
      NotificationsService.instance.refreshDailySummaryIfEnabled(
        enabled: settings.dailySummaryEnabled,
        time: settings.dailySummaryTime,
      );
    }
    ToastService.instance.showInfo('Subtask deleted');
  }

  Future<void> loadSubtasksSummary(int taskId) async {
    final counts = await _subRepo.getCounts(taskId);
    _subSummary[taskId] = SubtaskSummary(
      total: counts.totalCount,
      completed: counts.completedCount,
    );
    notifyListeners();
  }

  void _replace(Task task) {
    final idx = _all.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _all[idx] = task;
      notifyListeners();
    }
  }

  // ---------------- Fallback Polling (Backup) ----------------
  void _startFallbackWatcher() {
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _pollDueNotifications();
    });
  }

  void _pollDueNotifications() {
    final now = DateTime.now();
    for (final t in _all) {
      if (t.id == null) continue;
      if (t.isCompleted) continue;
      if (t.notifyAt == null) continue;
      final notifyAt = DateTime.fromMillisecondsSinceEpoch(t.notifyAt!);
      if (notifyAt.isBefore(now) ||
          notifyAt.difference(now).inSeconds.abs() <= 5) {
        if (!_firedTaskIds.contains(t.id)) {
          _firedTaskIds.add(t.id!);
          NotificationsService.instance.showImmediateTaskReminder(t);
        }
      }
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }
}

class SubtaskSummary {
  final int total;
  final int completed;
  SubtaskSummary({required this.total, required this.completed});
}
