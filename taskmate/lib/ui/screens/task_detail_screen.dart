import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../data/models/task_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  Task? _original;

  DateTime? _dueDate;
  String _repeat = 'none'; // none | daily | weekly
  final Set<int> _repeatDays = {}; // 1=Mon..7=Sun

  bool _reminderOn = false;
  TimeOfDay? _reminderTime;

  String _category = TaskCategories.none;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TaskProvider>();
    _original = provider.all.firstWhere(
      (t) => t.id == widget.taskId,
      orElse: () {
        if (provider.all.isNotEmpty) {
          return provider.all.first;
        } else {
          throw Exception('Task not found');
        }
      },
    );
    if (_original == null) {
      // Task deleted or not present
      Future.microtask(() {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Task not found')));
        Navigator.pop(context);
      });
      return;
    }

    _titleCtrl.text = _original!.title;
    _descCtrl.text = _original!.description;

    if (_original!.dueDate != null) {
      final d = DateTime.fromMillisecondsSinceEpoch(_original!.dueDate!);
      _dueDate = DateTime(d.year, d.month, d.day);
    }

    _repeat = _original!.repeatType.name; // none/daily/weekly
    _repeatDays
      ..clear()
      ..addAll(_original!.repeatDays);

    if (_original!.notifyAt != null) {
      final n = DateTime.fromMillisecondsSinceEpoch(_original!.notifyAt!);
      _reminderOn = true;
      _reminderTime = TimeOfDay(hour: n.hour, minute: n.minute);
    }

    _category = _original!.category;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final initial = _dueDate ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      initialDate: initial,
    );
    if (date != null) {
      setState(() {
        _dueDate = DateTime(date.year, date.month, date.day);
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
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

  Future<void> _save() async {
    if (_original == null) return;
    if (!_formKey.currentState!.validate()) return;

    if (_dueDate == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text('Please select a due date')));
      return;
    }

    final notifyAt = _buildReminderDateTime();
    final provider = context.read<TaskProvider>();

    await provider.updateTask(
      original: _original!,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dueDate: _dueDate,
      repeatType: _repeat == 'none'
          ? RepeatType.none
          : _repeat == 'daily'
              ? RepeatType.daily
              : RepeatType.weekly,
      repeatDays: _repeat == 'weekly' ? _repeatDays.toList() : const [],
      notifyAt: notifyAt,
      category: _category,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Task updated')));
    }
  }

  String _dueLabel() {
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
    String label(String v) =>
        v == TaskCategories.none ? 'None' : v[0].toUpperCase() + v.substring(1);
    return cats
        .map((c) => DropdownMenuItem<String>(value: c, child: Text(label(c))))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_original == null) {
      return const SizedBox(); // Already handled not found
    }

    final cs = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom + 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.check_rounded),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      label: Text(_dueLabel()),
                    ),
                  ),
                ],
              ),
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
                onChanged: (v) =>
                    setState(() => _category = v ?? TaskCategories.none),
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
                              : '${(_reminderTime!.hour % 12 == 0 ? 12 : _reminderTime!.hour % 12).toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')} '
                                  '${_reminderTime!.hour >= 12 ? 'PM' : 'AM'}',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Changes'),
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
          label: Text(labels[i], style: const TextStyle(fontSize: 12)),
          onSelected: (_) => onChanged(day),
        );
      }),
    );
  }
}
