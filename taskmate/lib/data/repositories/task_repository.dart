import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/task_model.dart';

class TaskRepository {
  Database? _db;

  Future<void> init() async {
    _db = await AppDatabase.instance.database;
  }

  Future<List<Task>> fetchAllByUser(int userId) async {
    final rows = await _db!.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy:
          'is_completed ASC, (due_date IS NULL) ASC, due_date ASC, id DESC',
    );
    return rows.map((e) => Task.fromMap(e)).toList();
  }

  Future<List<Task>> fetchAll() async {
    final rows = await _db!.query(
      'tasks',
      orderBy:
          'is_completed ASC, (due_date IS NULL) ASC, due_date ASC, id DESC',
    );
    return rows.map((e) => Task.fromMap(e)).toList();
  }

  Future<int> insert(Task task) async {
    return await _db!.insert('tasks', task.toMap());
  }

  Future<int> update(Task task) async {
    return await _db!.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(int id) async {
    return await _db!.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> reassignNullTasksTo(int userId) async {
    return await _db!.update(
      'tasks',
      {'user_id': userId},
      where: 'user_id IS NULL',
    );
  }

  /// Pending tasks for user in a due_date range (non-repeating only).
  /// Repeating tasks often need logic outside the DB (because occurrences
  /// can extend beyond a single stored due_date or have no due_date).
  Future<List<Task>> fetchPendingByUserWithinRange(
      int userId, int startMillis, int endMillis) async {
    final rows = await _db!.query(
      'tasks',
      where:
          'user_id = ? AND is_completed = 0 AND due_date IS NOT NULL AND due_date BETWEEN ? AND ?',
      whereArgs: [userId, startMillis, endMillis],
      orderBy: 'due_date ASC',
    );
    return rows.map((e) => Task.fromMap(e)).toList();
  }
}
