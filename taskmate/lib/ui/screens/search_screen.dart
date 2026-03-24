import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../../data/models/task_model.dart';
import '../../utils/date_time_utils.dart';
import '../widgets/task_card_modern.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _qCtrl = TextEditingController();
  String _category = TaskCategories.all;
  DateTime? _date; // if set: match due date OR repeated rule for that date

  @override
  void dispose() {
    _qCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = _date ?? DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: initial,
    );
    if (d != null) setState(() => _date = DateTime(d.year, d.month, d.day));
  }

  void _clearDate() => setState(() => _date = null);

  List<Task> _applyFilters(List<Task> all) {
    final q = _qCtrl.text.trim().toLowerCase();

    bool matchTitle(Task t) {
      if (q.isEmpty) return true;
      return t.title.toLowerCase().contains(q);
    }

    bool matchCategory(Task t) {
      if (_category == TaskCategories.all) return true;
      if (_category == TaskCategories.none)
        return t.category == TaskCategories.none;
      return t.category == _category;
    }

    bool matchDate(Task t) {
      if (_date == null) return true;
      if (t.repeatType == RepeatType.none) {
        if (t.dueDate == null) return false;
        return isSameDay(
            DateTime.fromMillisecondsSinceEpoch(t.dueDate!), _date!);
      }
      if (t.repeatType == RepeatType.daily) return true;
      if (t.repeatType == RepeatType.weekly) {
        return t.repeatDays.contains(_date!.weekday);
      }
      return true;
    }

    return all
        .where((t) => matchTitle(t) && matchCategory(t) && matchDate(t))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final cs = Theme.of(context).colorScheme;

    if (!provider.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final all = provider.all; // include completed + pending
    final results = _applyFilters(all);
    final df = DateFormat('EEE, MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Title query
          TextField(
            controller: _qCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Title',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _qCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _qCtrl.clear();
                        setState(() {});
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Date filter
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(_date == null ? 'Any date' : df.format(_date!)),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Clear date',
                onPressed: _date == null ? null : _clearDate,
                icon: const Icon(Icons.clear_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Category filter
          _CategoryFilter(
            value: _category,
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 16),

          // Active filter chips (optional, handy to clear)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_qCtrl.text.trim().isNotEmpty)
                _FilterChip(
                  label: 'Title: "${_qCtrl.text.trim()}"',
                  onClear: () {
                    _qCtrl.clear();
                    setState(() {});
                  },
                ),
              if (_date != null)
                _FilterChip(
                  label: 'Date: ${df.format(_date!)}',
                  onClear: _clearDate,
                ),
              if (_category != TaskCategories.all)
                _FilterChip(
                  label: 'Category: ${_labelOf(_category)}',
                  onClear: () => setState(() => _category = TaskCategories.all),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Result header
          Row(
            children: [
              Text(
                'Results',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface),
              ),
              const Spacer(),
              Text(
                '${results.length}',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (results.isEmpty)
            _EmptyState(
              title: 'No results',
              subtitle: _buildEmptySubtitle(),
              icon: Icons.search_off_rounded,
            )
          else
            ...results.map((t) => TaskCardModern(task: t)),
        ],
      ),
    );
  }

  String _buildEmptySubtitle() {
    final parts = <String>[];
    if (_qCtrl.text.trim().isNotEmpty) parts.add('title');
    if (_date != null) parts.add('date');
    if (_category != TaskCategories.all) parts.add('category');
    if (parts.isEmpty)
      return 'Try typing a title, selecting a date, or choosing a category.';
    return 'No tasks match the selected ${parts.join(', ')}.';
  }

  String _labelOf(String v) {
    if (v == TaskCategories.all) return 'All';
    if (v == TaskCategories.none) return 'None';
    return v[0].toUpperCase() + v.substring(1);
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
        Text('Category',
            style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
        const Spacer(),
        DropdownButton<String>(
          value: value,
          onChanged: (v) => onChanged(v ?? TaskCategories.all),
          items: items
              .map((e) =>
                  DropdownMenuItem<String>(value: e, child: Text(labelOf(e))))
              .toList(),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  const _FilterChip({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: cs.onSurface)),
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onClear,
            child:
                Icon(Icons.close_rounded, size: 16, color: cs.onSurfaceVariant),
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: cs.primary),
          const SizedBox(height: 16),
          Text(title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onBackground,
              )),
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
    );
  }
}
