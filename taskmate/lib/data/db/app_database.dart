import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'taskmate.db');
    return await openDatabase(
      path,
      version: 3, // keep your latest schema version here
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Factory reset: close and delete the database file, next access recreates it.
  Future<void> wipeDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'taskmate.db');
    await deleteDatabase(path);
  }

  Future<void> _onCreate(Database db, int version) async {
    // users
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    // tasks
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_date INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0,
        repeat_type TEXT NOT NULL DEFAULT 'none',
        repeat_days TEXT,
        notify_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        category TEXT NOT NULL DEFAULT 'none',
        user_id INTEGER,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL
      );
    ''');

    // subtasks
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subtasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
      );
    ''');

    // indexes
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_tasks_is_completed ON tasks(is_completed);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_tasks_category ON tasks(category);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_subtasks_task_id ON subtasks(task_id);');
    await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users(email);');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE tasks ADD COLUMN category TEXT NOT NULL DEFAULT 'none';",
      );
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_tasks_category ON tasks(category);');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          password_salt TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');
      await db.execute('ALTER TABLE tasks ADD COLUMN user_id INTEGER;');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id);');
      await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users(email);');
    }
  }
}
