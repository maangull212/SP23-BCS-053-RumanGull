import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/subtask_model.dart';

class SubtaskRepository {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<List<Subtask>> fetchByTask(int taskId) async {
    final db = await _db;
    final rows = await db.query(
      'subtasks',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'id ASC',
    );
    return rows.map((e) => Subtask.fromMap(e)).toList();
  }

  Future<_Counts> getCounts(int taskId) async {
    final db = await _db;
    final total = Sqflite.firstIntValue(
          await db.rawQuery(
              'SELECT COUNT(*) FROM subtasks WHERE task_id = ?', [taskId]),
        ) ??
        0;
    final completed = Sqflite.firstIntValue(
          await db.rawQuery(
              'SELECT COUNT(*) FROM subtasks WHERE task_id = ? AND is_completed = 1',
              [taskId]),
        ) ??
        0;
    return _Counts(total, completed);
  }

  Future<int> insert(Subtask st) async {
    final db = await _db;
    return db.insert('subtasks', st.toMap());
  }

  Future<int> update(Subtask st) async {
    final db = await _db;
    return db.update(
      'subtasks',
      st.toMap(),
      where: 'id = ?',
      whereArgs: [st.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }
}

class _Counts {
  final int totalCount;
  final int completedCount;
  _Counts(this.totalCount, this.completedCount);
}
