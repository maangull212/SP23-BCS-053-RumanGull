import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../data/models/task_model.dart';
import '../../utils/date_time_utils.dart';
import '../widgets/task_card_modern.dart';

class TodayTasksScreen extends StatefulWidget {
  const TodayTasksScreen({super.key});

  @override
  State<TodayTasksScreen> createState() => _TodayTasksScreenState();
}

class _TodayTasksScreenState extends State<TodayTasksScreen> {
  String _categoryFilter = TaskCategories.all; // All, none, work, ...

  List<Task> _tasksForDate({
    required List<Task> all,
    required DateTime selectedDate,
  }) {
    bool matchCategory(Task t) {
      if (_categoryFilter == TaskCategories.all) return true;
      if (_categoryFilter == TaskCategories.none) {
        return t.category == TaskCategories.none;
      }
      return t.category == _categoryFilter;
    }

    return all.where((t) {
      if (!matchCategory(t)) return false;

      // Only pending tasks in this list
      if (t.isCompleted) return false;

      // Non-repeated: due on selected date
      if (t.repeatType == RepeatType.none) {
        if (t.dueDate == null) return false;
        final d = DateTime.fromMillisecondsSinceEpoch(t.dueDate!);
        return isSameDay(d, selectedDate);
      }

      // Repeated (daily/weekly): included if pattern matches selected date
      if (t.repeatType == RepeatType.daily) return true;
      if (t.repeatType == RepeatType.weekly) {
        return t.repeatDays.contains(selectedDate.weekday);
      }
      return false;
    }).toList();
  }

  List<DateTime> _weekDays(DateTime anchor) {
    // Build Mon..Sun for week of anchor
    final int weekday = anchor.weekday; // 1=Mon..7=Sun
    final monday = anchor.subtract(Duration(days: weekday - 1));
    return List.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    if (!provider.initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedDate = provider.selectedDate;
    final tasks = _tasksForDate(all: provider.all, selectedDate: selectedDate);

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _SevenDayHeader(
            selected: selectedDate,
            days: _weekDays(selectedDate),
            onSelect: (d) => provider.selectDate(d),
          ),
          const SizedBox(height: 8),
          _CategoryFilter(
            value: _categoryFilter,
            onChanged: (v) => setState(() => _categoryFilter = v),
          ),
          const SizedBox(height: 8),
          if (tasks.isEmpty)
            const _EmptyState(
              title: 'No tasks',
              subtitle: 'No tasks for the selected day and category.',
              icon: Icons.inbox_outlined,
            )
          else
            ...List.generate(
                tasks.length, (i) => TaskCardModern(task: tasks[i])),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SevenDayHeader extends StatelessWidget {
  final DateTime selected;
  final List<DateTime> days;
  final ValueChanged<DateTime> onSelect;
  const _SevenDayHeader({
    required this.selected,
    required this.days,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmtDay = DateFormat('EEE');
    final fmtDate = DateFormat('d');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((d) {
          final bool sel = isSameDay(d, selected);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelect(d),
              child: Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? cs.primary : cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fmtDay.format(d),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: sel ? cs.onPrimary : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: sel
                          ? cs.onPrimary
                          : cs.primaryContainer.withOpacity(.15),
                      child: Text(
                        fmtDate.format(d),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: sel ? cs.primary : cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _CategoryFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String labelOf(String v) {
      if (v == TaskCategories.all) return 'All';
      if (v == TaskCategories.none) return 'None';
      return v[0].toUpperCase() + v.substring(1);
    }

    final items = <String>[
      TaskCategories.all,
      TaskCategories.none,
      TaskCategories.work,
      TaskCategories.home,
      TaskCategories.personal,
      TaskCategories.study,
      TaskCategories.shopping,
      TaskCategories.health,
      TaskCategories.finance,
      TaskCategories.other,
    ];

    return Row(
      children: [
        Text(
          'Category',
          style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
        ),
        const Spacer(),
        DropdownButton<String>(
          value: value,
          onChanged: (v) => onChanged(v ?? TaskCategories.all),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(labelOf(e)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: cs.onBackground.withOpacity(.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
