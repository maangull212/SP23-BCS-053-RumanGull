import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/task_model.dart';
import '../../data/models/subtask_model.dart';
import '../../providers/task_provider.dart';
import '../widgets/progress_bar.dart';

class SubtasksSheet extends StatefulWidget {
  final Task task;
  const SubtasksSheet({super.key, required this.task});

  @override
  State<SubtasksSheet> createState() => _SubtasksSheetState();
}

class _SubtasksSheetState extends State<SubtasksSheet> {
  late Future<List<Subtask>> _future;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _reload() {
    _future = context.read<TaskProvider>().fetchSubtasks(widget.task.id!);
  }

  Future<void> _add() async {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;
    final provider = context.read<TaskProvider>();
    await provider.addSubtask(widget.task.id!, title);
    _ctrl.clear();
    setState(_reload);
  }

  Future<void> _toggle(Subtask st) async {
    final provider = context.read<TaskProvider>();
    await provider.toggleSubtask(st);
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<TaskProvider>();
    final summary = provider.getSubtaskSummary(widget.task.id!);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: SafeArea(
        top: false,
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
            Text(
              'Subtasks',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              widget.task.title,
              style: TextStyle(color: cs.onSurface.withOpacity(.7)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            if (summary != null && summary.total > 0)
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
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(.7),
                    ),
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No subtasks yet',
                  style: TextStyle(color: cs.onSurface.withOpacity(.7)),
                ),
              ),
            const SizedBox(height: 12),
            FutureBuilder<List<Subtask>>(
              future: _future,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  );
                }
                final items = snap.data!;
                return Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (_, i) {
                      final st = items[i];
                      return Material(
                        color: Colors.transparent,
                        child: CheckboxListTile(
                          value: st.isCompleted,
                          onChanged: (_) => _toggle(st),
                          title: Text(
                            st.title,
                            style: TextStyle(
                              decoration: st.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          secondary: IconButton(
                            tooltip: 'Delete subtask',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await context
                                  .read<TaskProvider>()
                                  .deleteSubtask(st);
                              setState(_reload);
                            },
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a subtask',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _add,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
