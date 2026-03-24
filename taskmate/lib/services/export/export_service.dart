import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/task_model.dart';

enum ExportFormat { csv, json }

enum ExportScope { today, completed, repeated, all }

class ExportResult {
  final File file;
  final String filename;
  ExportResult({required this.file, required this.filename});
}

class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  Future<ExportResult> exportTasks({
    required List<Task> tasks,
    required ExportFormat format,
    required ExportScope scope,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final scopeName = scope.name;
    final ext = format == ExportFormat.csv ? 'csv' : 'json';
    final filename = 'taskmate_${scopeName}_$timestamp.$ext';
    final file = File('${dir.path}/$filename');

    final content =
        format == ExportFormat.csv ? _buildCsv(tasks) : _buildJson(tasks);

    await file.writeAsString(content);
    return ExportResult(file: file, filename: filename);
  }

  String _buildCsv(List<Task> tasks) {
    // Header
    final buffer = StringBuffer();
    buffer.writeln(
        'id,title,description,due_date,is_completed,repeat_type,repeat_days,notify_at,created_at,updated_at');
    for (final t in tasks) {
      buffer.writeln([
        t.id ?? '',
        _escape(t.title),
        _escape(t.description),
        t.dueDate ?? '',
        t.isCompleted ? 1 : 0,
        t.repeatType.name,
        t.repeatDays.join('|'),
        t.notifyAt ?? '',
        t.createdAt,
        t.updatedAt,
      ].join(','));
    }
    return buffer.toString();
  }

  String _escape(String value) {
    final replaced = value.replaceAll('"', '""');
    if (replaced.contains(',') || replaced.contains('"')) {
      return '"$replaced"';
    }
    return replaced;
  }

  String _buildJson(List<Task> tasks) {
    final list = tasks.map((t) {
      return {
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'due_date': t.dueDate,
        'is_completed': t.isCompleted,
        'repeat_type': t.repeatType.name,
        'repeat_days': t.repeatDays,
        'notify_at': t.notifyAt,
        'created_at': t.createdAt,
        'updated_at': t.updatedAt,
      };
    }).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }
}
