import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/user_model.dart';

class UserRepository {
  Database? _db;

  Future<void> init() async {
    _db = await AppDatabase.instance.database;
  }

  Future<User?> getByEmail(String email) async {
    final rows = await _db!.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<User?> getById(int id) async {
    final rows =
        await _db!.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<bool> anyExists() async {
    final rows = await _db!.rawQuery('SELECT COUNT(1) as c FROM users');
    final c = (rows.first['c'] as int?) ?? 0;
    return c > 0;
  }

  Future<int> create(User user) async {
    return _db!.insert('users', user.toMap());
  }
}
