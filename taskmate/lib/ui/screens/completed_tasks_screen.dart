import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../data/models/task_model.dart';
import '../widgets/task_card_modern.dart';

class CompletedTasksScreen extends StatefulWidget {
  const CompletedTasksScreen({super.key});

  @override
  State<CompletedTasksScreen> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  String _categoryFilter = TaskCategories.all;

  List<Task> _filtered(BuildContext context) {
    final provider = context.read<TaskProvider>();
    final all = provider.completedTasks;
    if (_categoryFilter == TaskCategories.all) return all;
    if (_categoryFilter == TaskCategories.none) {
      return all.where((t) => t.category == TaskCategories.none).toList();
    }
    return all.where((t) => t.category == _categoryFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    if (!provider.initialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final tasks = _filtered(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        _CategoryFilter(
          value: _categoryFilter,
          onChanged: (v) => setState(() => _categoryFilter = v),
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          const _EmptyState(
            title: 'No completed tasks',
            subtitle: 'No tasks match this category.',
            icon: Icons.task_alt,
          )
        else
          ...List.generate(tasks.length, (i) => TaskCardModern(task: tasks[i])),
      ],
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _CategoryFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
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
        const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
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
