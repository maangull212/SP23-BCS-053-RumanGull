import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../data/models/task_model.dart';

class PdfExportService {
  PdfExportService._();
  static final PdfExportService instance = PdfExportService._();

  Future<File> generateTasksReport({
    required List<Task> tasks,
    required String scopeLabel,
  }) async {
    final pdf = pw.Document();

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          textDirection: pw.TextDirection.ltr,
        ),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Taskmate Report',
                style:
                    pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Scope: $scopeLabel',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            pw.Text('Generated: $dateStr',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
            pw.Divider(),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ),
          ],
        ),
        build: (context) {
          if (tasks.isEmpty) {
            return [
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(40),
                  child: pw.Text(
                    'No tasks available in this scope.',
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.grey600),
                  ),
                ),
              ),
            ];
          }

          return [
            pw.TableHelper.fromTextArray(
              headers: [
                'ID',
                'Title',
                'Completed',
                'Repeat',
                'Due Date',
                'Reminder',
              ],
              data: tasks.map((t) {
                final due = t.dueDate == null
                    ? '-'
                    : DateFormat('dd/MM/yyyy').format(
                        DateTime.fromMillisecondsSinceEpoch(t.dueDate!),
                      );
                final reminder = t.notifyAt == null
                    ? '-'
                    : DateFormat('dd/MM/yyyy HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(t.notifyAt!),
                      );
                final repeat = t.repeatType == RepeatType.none
                    ? 'None'
                    : t.repeatType == RepeatType.daily
                        ? 'Daily'
                        : t.repeatDays.isEmpty
                            ? 'Weekly'
                            : 'Weekly (${t.repeatDays.join(',')})';

                return [
                  (t.id ?? '').toString(),
                  t.title,
                  t.isCompleted ? 'Yes' : 'No',
                  repeat,
                  due,
                  reminder,
                ];
              }).toList(),
              cellAlignment: pw.Alignment.centerLeft,
              headerStyle: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.indigo500),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: .3),
                ),
              ),
            ),
            pw.SizedBox(height: 18),
            pw.Text('Details',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            ...tasks.map((t) {
              final due = t.dueDate == null
                  ? '-'
                  : DateFormat('dd/MM/yyyy').format(
                      DateTime.fromMillisecondsSinceEpoch(t.dueDate!),
                    );
              final reminder = t.notifyAt == null
                  ? '-'
                  : DateFormat('dd/MM/yyyy HH:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(t.notifyAt!),
                    );
              final repeat = t.repeatType == RepeatType.none
                  ? 'None'
                  : t.repeatType == RepeatType.daily
                      ? 'Daily'
                      : t.repeatDays.isEmpty
                          ? 'Weekly'
                          : 'Weekly (${t.repeatDays.join(',')})';

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: .5),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${t.title} ${t.isCompleted ? "(Completed)" : ""}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo800,
                      ),
                    ),
                    if (t.description.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 2),
                        child: pw.Text(
                          t.description,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    pw.SizedBox(height: 4),
                    pw.Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _infoChip('Due: $due'),
                        _infoChip('Repeat: $repeat'),
                        _infoChip('Reminder: $reminder'),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = 'taskmate_${scopeLabel.toLowerCase()}_$stamp.pdf';
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _infoChip(String label) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: pw.BoxDecoration(
        color: PdfColors.indigo50,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.indigo200, width: .5),
      ),
      child: pw.Text(label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.indigo900)),
    );
  }
}
