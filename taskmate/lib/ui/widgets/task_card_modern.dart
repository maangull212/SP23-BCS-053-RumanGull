import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../../data/models/task_model.dart';
import '../widgets/progress_bar.dart';
import '../screens/task_detail_screen.dart';
import '../dialogs_sheets/subtasks_sheet.dart';

class TaskCardModern extends StatelessWidget {
  final Task task;
  const TaskCardModern({super.key, required this.task});

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '?';
    }
  }

  String primaryMeta() {
    if (task.repeatType == RepeatType.daily) return 'Every day';
    if (task.repeatType == RepeatType.weekly) {
      if (task.repeatDays.isEmpty) return 'Every week';
      return 'Weekly (${task.repeatDays.map(_weekdayShort).join(', ')})';
    }
    if (task.dueDate != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(task.dueDate!);
      return 'Due • ${DateFormat('EEE, MMM dd yyyy').format(dt)}';
    }
    return 'No due date';
  }

  String? reminderMeta() {
    if (task.notifyAt == null) return null;
    final dt = DateTime.fromMillisecondsSinceEpoch(task.notifyAt!);
    return DateFormat('hh:mm a').format(dt);
  }

  Future<void> _openSubtasks(BuildContext context) async {
    if (task.id == null) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SubtasksSheet(task: task),
    );
    // Ensure progress refreshes on return
    final provider = context.read<TaskProvider>();
    await provider.loadSubtasksSummary(task.id!);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<TaskProvider>();

    if (task.id != null && provider.getSubtaskSummary(task.id!) == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.loadSubtasksSummary(task.id!);
      });
    }
    final summary =
        task.id == null ? null : provider.getSubtaskSummary(task.id!);
    final reminder = reminderMeta();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (task.id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TaskDetailScreen(taskId: task.id!)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left status stripe
              Container(
                width: 4,
                height: 64,
                margin: const EdgeInsets.only(right: 12, top: 4),
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? cs.primary.withOpacity(.5)
                      : (task.repeatType != RepeatType.none
                          ? cs.primary
                          : cs.outline.withOpacity(.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + actions (subtasks + menu)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: cs.onSurface,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (task.id != null) ...[
                          IconButton(
                            tooltip: 'Subtasks',
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.checklist_rounded, size: 20),
                            onPressed: () => _openSubtasks(context),
                          ),
                        ],
                        PopupMenuButton<String>(
                          tooltip: 'More',
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (v) async {
                            if (v == 'edit' && task.id != null) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TaskDetailScreen(taskId: task.id!),
                                ),
                              );
                            } else if (v == 'delete' && task.id != null) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Task'),
                                  content: Text(
                                      'Are you sure you want to delete "${task.title}"?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel')),
                                    FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final snapshot = task;
                                await provider.deleteTask(task);
                                Future.microtask(() {
                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  messenger.hideCurrentSnackBar();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: const Text('Task deleted'),
                                      duration: const Duration(seconds: 3),
                                      action: SnackBarAction(
                                        label: 'UNDO',
                                        onPressed: () async {
                                          await provider.restoreTask(snapshot);
                                          messenger.hideCurrentSnackBar();
                                          messenger.showSnackBar(
                                            const SnackBar(
                                                content: Text('Task restored')),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                });
                              }
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),

                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(.75),
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),

                    // Meta line (due/repeat)
                    Row(
                      children: [
                        Icon(
                          task.repeatType == RepeatType.none
                              ? Icons.event
                              : Icons.schedule,
                          size: 16,
                          color: cs.onSurface.withOpacity(.75),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            primaryMeta(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(.75),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Chips row
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (finalReminderChip(reminder, cs) != null)
                          finalReminderChip(reminder, cs)!,
                        if (task.category != TaskCategories.none)
                          _InfoChip(
                            icon: Icons.label_rounded,
                            label: task.category[0].toUpperCase() +
                                task.category.substring(1),
                            color: cs.onSurface.withOpacity(.8),
                          ),
                        if (task.repeatType != RepeatType.none)
                          _InfoChip(
                            icon: Icons.repeat_rounded,
                            label: task.repeatType == RepeatType.daily
                                ? 'Daily'
                                : 'Weekly',
                            color: cs.primary,
                          ),
                      ],
                    ),

                    if (summary != null && summary.total > 0) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ProgressBar(
                              value: summary.completed / summary.total,
                              height: 6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${summary.completed}/${summary.total}',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Complete toggle (guarded)
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () async {
                  final ok = await provider.tryToggleComplete(task);
                  if (!ok) {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.hideCurrentSnackBar();
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('Complete all subtasks first'),
                        action: SnackBarAction(
                          label: 'Open',
                          onPressed: () => _openSubtasks(context),
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 24,
                    color: task.isCompleted ? cs.primary : cs.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? finalReminderChip(String? reminder, ColorScheme cs) {
    if (reminder == null) return null;
    return _InfoChip(
      icon: Icons.notifications_active,
      label: 'Reminder • $reminder',
      color: cs.primary,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final clr = color ?? cs.onSurface.withOpacity(.8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: clr.withOpacity(.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: clr.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: clr),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11, color: clr, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
