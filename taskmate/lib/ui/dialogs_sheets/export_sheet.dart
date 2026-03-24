import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/task_provider.dart';
import '../../services/export/export_service.dart';
import '../../services/export/pdf_export_service.dart';
import '../../data/models/task_model.dart';

enum ExportUiFormat { csv, json, pdf }

class ExportSheet extends StatefulWidget {
  const ExportSheet({super.key});

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  ExportUiFormat _format = ExportUiFormat.csv;
  ExportScope _scope = ExportScope.today;
  bool _working = false;

  Future<void> _doExport() async {
    final provider = context.read<TaskProvider>();

    List<Task> tasks;
    switch (_scope) {
      case ExportScope.today:
        tasks = provider.todayTasks;
        break;
      case ExportScope.completed:
        tasks = provider.completedTasks;
        break;
      case ExportScope.repeated:
        tasks = provider.repeatedTasks;
        break;
      case ExportScope.all:
        tasks = provider.all;
        break;
    }

    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tasks in selected scope.')),
      );
      return;
    }

    setState(() => _working = true);
    try {
      if (_format == ExportUiFormat.pdf) {
        final file = await PdfExportService.instance.generateTasksReport(
          tasks: tasks,
          scopeLabel: _scope.name,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('PDF exported: ${file.path.split("/").last}')),
          );
        }
        await Share.shareXFiles([XFile(file.path)],
            text: 'Taskmate ${_scope.name} PDF report');
      } else {
        final exportFormat = _format == ExportUiFormat.csv
            ? ExportFormat.csv
            : ExportFormat.json;

        final result = await ExportService.instance.exportTasks(
          tasks: tasks,
          format: exportFormat,
          scope: _scope,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported: ${result.filename}')),
          );
        }
        await Share.shareXFiles([XFile(result.file.path)],
            text: 'Taskmate ${_scope.name} ${_format.name} export');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
            Text('Export Tasks',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Scope',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: cs.onSurface)),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExportScope.values.map((s) {
                final sel = _scope == s;
                return ChoiceChip(
                  label: Text(_labelScope(s)),
                  selected: sel,
                  onSelected: (_) => setState(() => _scope = s),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Format',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: cs.onSurface)),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: ExportUiFormat.values.map((f) {
                final sel = _format == f;
                return ChoiceChip(
                  label: Text(f.name.toUpperCase()),
                  selected: sel,
                  onSelected: (_) => setState(() => _format = f),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _working ? null : _doExport,
              icon: _working
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(_working ? 'Working...' : 'Export & Share'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelScope(ExportScope s) {
    switch (s) {
      case ExportScope.today:
        return 'Today';
      case ExportScope.completed:
        return 'Completed';
      case ExportScope.repeated:
        return 'Repeated';
      case ExportScope.all:
        return 'All';
    }
  }
}
