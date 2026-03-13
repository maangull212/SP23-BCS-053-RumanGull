import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  static const String _dbName = 'doctor_app.db';
  static const int _dbVersion = 1;
  static const String tablePatients = 'patients';

  // ── Singleton DB ──────────────────────────────────────────
  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path;
    if (kIsWeb) {
      // On web, sqflite_common_ffi_web uses IndexedDB; path is just the db name
      path = _dbName;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, _dbName);
    }

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablePatients (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        name             TEXT    NOT NULL,
        age              INTEGER NOT NULL,
        gender           TEXT    NOT NULL,
        phone            TEXT    NOT NULL,
        email            TEXT    DEFAULT '',
        address          TEXT    DEFAULT '',
        blood_group      TEXT    NOT NULL,
        medical_history  TEXT    DEFAULT '',
        diagnosis        TEXT    DEFAULT '',
        medications      TEXT    DEFAULT '',
        allergies        TEXT    DEFAULT '',
        emergency_contact TEXT   DEFAULT '',
        image_path       TEXT,
        documents        TEXT    DEFAULT '[]',
        last_visit       TEXT    NOT NULL,
        created_at       TEXT    NOT NULL,
        is_active        INTEGER DEFAULT 1
      )
    ''');
    await _seedSampleData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> _seedSampleData(Database db) async {
    final now = DateTime.now();
    final samples = [
      {
        'name': 'Sarah Johnson',
        'age': 34,
        'gender': 'Female',
        'phone': '+1 555-0101',
        'email': 'sarah.j@email.com',
        'address': '42 Maple Street, New York',
        'blood_group': 'A+',
        'medical_history': 'Hypertension, managed with medication since 2020',
        'diagnosis': 'Stage 1 Hypertension',
        'medications': 'Lisinopril 10mg daily, Aspirin 81mg daily',
        'allergies': 'Penicillin',
        'emergency_contact': 'Mark Johnson +1 555-0102',
        'image_path': null,
        'documents': '[]',
        'last_visit': now.subtract(const Duration(days: 3)).toIso8601String(),
        'created_at': now.subtract(const Duration(days: 180)).toIso8601String(),
        'is_active': 1,
      },
      {
        'name': 'James Miller',
        'age': 58,
        'gender': 'Male',
        'phone': '+1 555-0201',
        'email': 'james.miller@email.com',
        'address': '18 Oak Avenue, Chicago',
        'blood_group': 'O+',
        'medical_history': 'Type 2 Diabetes diagnosed 2018, Mild obesity',
        'diagnosis': 'Type 2 Diabetes Mellitus',
        'medications': 'Metformin 500mg twice daily, Glipizide 5mg daily',
        'allergies': 'Sulfa drugs, Shellfish',
        'emergency_contact': 'Linda Miller +1 555-0202',
        'image_path': null,
        'documents': '[]',
        'last_visit': now.subtract(const Duration(days: 7)).toIso8601String(),
        'created_at': now.subtract(const Duration(days: 365)).toIso8601String(),
        'is_active': 1,
      },
      {
        'name': 'Emily Chen',
        'age': 27,
        'gender': 'Female',
        'phone': '+1 555-0301',
        'email': 'emily.chen@email.com',
        'address': '9 Pine Road, San Francisco',
        'blood_group': 'B+',
        'medical_history': 'Seasonal allergies, Asthma',
        'diagnosis': 'Mild Persistent Asthma',
        'medications': 'Albuterol inhaler PRN, Fluticasone inhaler daily',
        'allergies': 'Pollen, Dust mites',
        'emergency_contact': 'Wei Chen +1 555-0302',
        'image_path': null,
        'documents': '[]',
        'last_visit': now.subtract(const Duration(days: 14)).toIso8601String(),
        'created_at': now.subtract(const Duration(days: 90)).toIso8601String(),
        'is_active': 1,
      },
    ];

    for (final sample in samples) {
      await db.insert(tablePatients, sample);
    }
  }

  // ── CRUD ──────────────────────────────────────────────────
  Future<int> insertPatient(Patient patient) async {
    final db = await database;
    final map = patient.toMap()..remove('id');
    return await db.insert(tablePatients, map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Patient>> getAllPatients({bool activeOnly = true}) async {
    final db = await database;
    final maps = await db.query(
      tablePatients,
      where: activeOnly ? 'is_active = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'last_visit DESC',
    );
    return maps.map(Patient.fromMap).toList();
  }

  Future<Patient?> getPatientById(int id) async {
    final db = await database;
    final maps = await db.query(tablePatients,
        where: 'id = ?', whereArgs: [id], limit: 1);
    return maps.isNotEmpty ? Patient.fromMap(maps.first) : null;
  }

  Future<List<Patient>> searchPatients(String query) async {
    final db = await database;
    final like = '%${query.toLowerCase()}%';
    final maps = await db.query(
      tablePatients,
      where:
          '(LOWER(name) LIKE ? OR phone LIKE ? OR blood_group LIKE ?) AND is_active = 1',
      whereArgs: [like, like, like],
      orderBy: 'last_visit DESC',
    );
    return maps.map(Patient.fromMap).toList();
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await database;
    return await db.update(tablePatients, patient.toMap(),
        where: 'id = ?', whereArgs: [patient.id]);
  }

  Future<int> hardDeletePatient(int id) async {
    final db = await database;
    return await db
        .delete(tablePatients, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>> getStats() async {
    final db = await database;

    final total = (await db.rawQuery(
            'SELECT COUNT(*) as c FROM $tablePatients WHERE is_active = 1'))
        .first['c'] as int;

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final todayVisits = (await db.rawQuery(
            "SELECT COUNT(*) as c FROM $tablePatients WHERE last_visit LIKE '$todayStr%' AND is_active = 1"))
        .first['c'] as int;

    final male = (await db.rawQuery(
            "SELECT COUNT(*) as c FROM $tablePatients WHERE gender = 'Male' AND is_active = 1"))
        .first['c'] as int;

    final female = (await db.rawQuery(
            "SELECT COUNT(*) as c FROM $tablePatients WHERE gender = 'Female' AND is_active = 1"))
        .first['c'] as int;

    final weekAgo =
        DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
    final weeklyVisits = (await db.rawQuery(
            "SELECT COUNT(*) as c FROM $tablePatients WHERE last_visit >= '$weekAgo' AND is_active = 1"))
        .first['c'] as int;

    return {
      'total': total,
      'todayVisits': todayVisits,
      'male': male,
      'female': female,
      'weeklyVisits': weeklyVisits,
    };
  }
}
