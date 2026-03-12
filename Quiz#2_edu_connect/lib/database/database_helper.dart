import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'educonnect.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        age INTEGER NOT NULL,
        imagePath TEXT,
        department TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // CREATE
  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ALL
  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('students', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  // SEARCH
  Future<List<Student>> searchStudents(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'name LIKE ? OR email LIKE ? OR department LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  // UPDATE
  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  // DELETE
  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // GET COUNT
  Future<int> getStudentCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM students');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // GET UNIQUE DEPARTMENTS COUNT
  Future<int> getDepartmentCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(DISTINCT department) FROM students');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
