import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/task_model.dart';
import '../../utils/date_time_utils.dart' as dt_utils;
import '../../services/notifications/notifications_service.dart';

import 'today_tasks_screen.dart';
import 'completed_tasks_screen.dart';
import 'repeated_tasks_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import '../widgets/app_bottom_nav.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    TodayTasksScreen(),
    RepeatedTasksScreen(),
    CompletedTasksScreen(),
    ProfileScreen(),
  ];

  String _titleFor(int i) {
    switch (i) {
      case 0:
        return 'Today';
      case 1:
        return 'Repeated';
      case 2:
        return 'Completed';
      case 3:
        return 'Profile';
      default:
        return 'Taskmate';
    }
  }

  @override
  void initState() {
    super.initState();

    // Register tab selector for deep links
    NotificationsService.instance.registerTabSelector((tabIdx) {
      if (mounted) {
        setState(() => _index = tabIdx);
      }
    });

    // Initialize tasks for authenticated user
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      if (auth.currentUserId != null) {
        context.read<TaskProvider>().init(userId: auth.currentUserId!);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Attempt processing pending navigation when provider becomes ready
    Future.microtask(() {
      final taskProv = context.read<TaskProvider>();
      if (taskProv.initialized) {
        NotificationsService.instance.tryProcessPendingNavigation(context);
      }
    });
  }

  Future<void> _openAddTask() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _AddTaskSheet(),
    );

    if (result == 'saved') {
      if (_index != 0) {
        setState(() => _index = 0);
      }
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Task added')),
      );
    }
  }




  Future<void> _openCalendarDialog() async {
    final tp = context.read<TaskProvider>();
    final initial = tp.initialized ? tp.selectedDate : DateTime.now();

    final picked = await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _CalendarWithDotsDialog(initialSelected: initial),
    );

    if (picked != null) {
      tp.selectDate(picked);
      if (_index != 0) {
        setState(() => _index = 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(_index)),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Pick a date',
            icon: const Icon(Icons.calendar_month),
            onPressed: _openCalendarDialog,
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: taskProvider.initialized
          ? _pages[_index]
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTask,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        onCenterTap: _openAddTask,
      ),
    );
  }
}

// --- Add Task Sheet (unchanged) ---
class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  DateTime? _dueDate;
  bool _triedSave = false;
  bool _saving = false;

  String _repeat = 'none';
  final Set<int> _repeatDays = {};

  bool _reminderOn = false;
  TimeOfDay? _reminderTime;

  String? _category = TaskCategories.none;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (date == null) return;
    setState(() => _dueDate = DateTime(date.year, date.month, date.day));
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  DateTime? _buildReminderDateTime() {
    if (!_reminderOn || _reminderTime == null) return null;
    final now = DateTime.now();
    if (_repeat == 'none') {
      final base = _dueDate ?? now;
      var dt = DateTime(base.year, base.month, base.day, _reminderTime!.hour,
          _reminderTime!.minute);
      if (dt.isBefore(now)) dt = now.add(const Duration(minutes: 1));
      return dt;
    }
    var dt = DateTime(now.year, now.month, now.day, _reminderTime!.hour,
        _reminderTime!.minute);
    if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
    return dt;
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _triedSave = true);

    final formOk = _formKey.currentState!.validate();
    final hasDue = _dueDate != null;
    final hasCategory = _category != null && _category!.isNotEmpty;
    if (!formOk || !hasDue || !hasCategory) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      if (!hasDue) {
        messenger.showSnackBar(
            const SnackBar(content: Text('Please select a due date')));
      } else if (!hasCategory) {
        messenger.showSnackBar(
            const SnackBar(content: Text('Please pick a category')));
      }
      return;
    }

    setState(() => _saving = true);
    final provider = context.read<TaskProvider>();
    final reminderAt = _buildReminderDateTime();

    await provider.addTask(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      dueDate: _dueDate,
      repeatType: _repeat == 'none'
          ? RepeatType.none
          : _repeat == 'daily'
              ? RepeatType.daily
              : RepeatType.weekly,
      repeatDays: _repeat == 'weekly' ? _repeatDays.toList() : const [],
      notifyAt: reminderAt,
      category: _category ?? TaskCategories.none,
    );

    if (!mounted) return;
    FocusScope.of(context).unfocus();
    Navigator.pop(context, 'saved');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String dueLabel() {
      if (_dueDate == null) return 'Pick Due Date';
      return '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}';
    }

    List<DropdownMenuItem<String>> _categoryItems() {
      const cats = [
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
      String label(String v) => v == TaskCategories.none
          ? 'None'
          : v[0].toUpperCase() + v.substring(1);
      return cats
          .map((c) => DropdownMenuItem<String>(value: c, child: Text(label(c))))
          .toList();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 48,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Text('Add Task',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDueDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(dueLabel()),
                    ),
                  ),
                ],
              ),
              if (_triedSave && _dueDate == null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Due date is required',
                      style: TextStyle(color: cs.error, fontSize: 12)),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Category',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: cs.onSurface)),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _categoryItems(),
                onChanged: (v) => setState(() => _category = v),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Category required' : null,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Repeat',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: cs.onSurface)),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'none',
                      groupValue: _repeat,
                      onChanged: (v) => setState(() => _repeat = v!),
                      title: const Text('None',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'daily',
                      groupValue: _repeat,
                      onChanged: (v) => setState(() => _repeat = v!),
                      title: const Text('Daily',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'weekly',
                      groupValue: _repeat,
                      onChanged: (v) => setState(() => _repeat = v!),
                      title: const Text('Weekly',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                    ),
                  ),
                ],
              ),
              if (_repeat == 'weekly') ...[
                const SizedBox(height: 8),
                _WeekdayChips(
                  selected: _repeatDays,
                  onChanged: (day) {
                    setState(() {
                      if (_repeatDays.contains(day)) {
                        _repeatDays.remove(day);
                      } else {
                        _repeatDays.add(day);
                      }
                    });
                  },
                ),
              ],
              const SizedBox(height: 12),
              SwitchListTile(
                value: _reminderOn,
                onChanged: (v) => setState(() => _reminderOn = v),
                title: const Text('Reminder'),
                subtitle: const Text('Notification at selected time'),
                secondary: const Icon(Icons.notifications_active_outlined),
                contentPadding: EdgeInsets.zero,
              ),
              if (_reminderOn) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickReminderTime,
                        icon: const Icon(Icons.alarm),
                        label: Text(
                          _reminderTime == null
                              ? 'Pick Time'
                              : '${(_reminderTime!.hour % 12 == 0 ? 12 : _reminderTime!.hour % 12).toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')} ${_reminderTime!.hour >= 12 ? 'PM' : 'AM'}',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayChips extends StatelessWidget {
  final Set<int> selected;
  final ValueChanged<int> onChanged;
  const _WeekdayChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final labels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSel = selected.contains(day);
        return FilterChip(
          selected: isSel,
          label: Text(labels[i]),
          onSelected: (_) => onChanged(day),
        );
      }),
    );
  }
}

// Calendar dialog (unchanged below)
class _CalendarWithDotsDialog extends StatefulWidget {
  final DateTime initialSelected;
  const _CalendarWithDotsDialog({required this.initialSelected});

  @override
  State<_CalendarWithDotsDialog> createState() =>
      _CalendarWithDotsDialogState();
}

class _CalendarWithDotsDialogState extends State<_CalendarWithDotsDialog> {
  late DateTime _focused;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = dt_utils.normalizeDate(widget.initialSelected);
    _focused = _selected;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<TaskProvider>();
    final markers =
        provider.markersForMonth(_focused, categoryFilter: TaskCategories.all);

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      title: Text(
        '${_selected.year}-${_selected.month.toString().padLeft(2, '0')}-${_selected.day.toString().padLeft(2, '0')}',
        style: TextStyle(
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 380,
        child: TableCalendar(
          firstDay: DateTime(DateTime.now().year - 5, 1, 1),
          lastDay: DateTime(DateTime.now().year + 5, 12, 31),
          focusedDay: _focused,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (d) => isSameDay(d, _selected),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              fontSize: 16,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: cs.onSurface),
            rightChevronIcon: Icon(Icons.chevron_right, color: cs.onSurface),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle:
                TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
            weekendStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withOpacity(.8),
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: true,
            isTodayHighlighted: true,
            todayDecoration: BoxDecoration(
              color: cs.primary.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: cs.onPrimary,
              fontWeight: FontWeight.w700,
            ),
            defaultTextStyle: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
            weekendTextStyle: TextStyle(
              color: cs.onSurface.withOpacity(.85),
              fontWeight: FontWeight.w600,
            ),
            outsideTextStyle: TextStyle(
              color: cs.onSurface.withOpacity(.35),
              fontWeight: FontWeight.w500,
            ),
          ),
          onDaySelected: (sel, foc) {
            setState(() {
              _selected = dt_utils.normalizeDate(sel);
              _focused = foc;
            });
          },
          onPageChanged: (newFocused) {
            setState(() => _focused = newFocused);
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, _) {
              final key = dt_utils.normalizeDate(date);
              final count = markers[key];
              if (count == null || count == 0) return null;
              final displayCount = count;
              final maxDots = 4;
              final dotsToShow =
                  displayCount <= maxDots ? displayCount : maxDots;
              final extra = displayCount - maxDots;
              return Positioned(
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(dotsToShow, (i) {
                    if (i == maxDots - 1 && extra > 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+$extra',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: cs.onPrimary,
                          ),
                        ),
                      );
                    }
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
