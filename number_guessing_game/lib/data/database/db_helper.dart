import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_result.dart';

/// Singleton database helper.
/// Access via: DatabaseHelper.instance
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'numquest.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game_results (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        difficulty   TEXT    NOT NULL,
        target_number INTEGER NOT NULL,
        attempts     INTEGER NOT NULL,
        max_attempts  INTEGER NOT NULL,
        won          INTEGER NOT NULL DEFAULT 0,
        score        INTEGER NOT NULL DEFAULT 0,
        played_at    TEXT    NOT NULL
      )
    ''');
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  /// Insert a completed game result.
  Future<int> insertResult(GameResult result) async {
    try {
      final db = await database;
      return db.insert(
        'game_results',
        result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('DB insertResult error: $e');
      return -1;
    }
  }

  /// Return all results ordered newest first.
  Future<List<GameResult>> getAllResults() async {
    try {
      final db = await database;
      final maps = await db.query('game_results', orderBy: 'played_at DESC');
      return maps.map(GameResult.fromMap).toList();
    } catch (e) {
      debugPrint('DB getAllResults error: $e');
      return [];
    }
  }

  /// Aggregate stats for the History screen.
  Future<Map<String, dynamic>> getStats() async {
    try {
      final db = await database;
      final totalQ =
          await db.rawQuery('SELECT COUNT(*) AS c FROM game_results');
      final wonQ = await db.rawQuery(
          'SELECT COUNT(*) AS c FROM game_results WHERE won = 1');
      final hsQ = await db.rawQuery(
          'SELECT MAX(score) AS hs FROM game_results WHERE won = 1');

      final total = (totalQ.first['c'] as int?) ?? 0;
      final won = (wonQ.first['c'] as int?) ?? 0;
      final highScore = (hsQ.first['hs'] as int?) ?? 0;
      final winRate =
          total > 0 ? (won / total * 100).toStringAsFixed(0) : '0';

      return {
        'total': total,
        'won': won,
        'highScore': highScore,
        'winRate': winRate,
      };
    } catch (e) {
      debugPrint('DB getStats error: $e');
      return {'total': 0, 'won': 0, 'highScore': 0, 'winRate': '0'};
    }
  }

  /// Delete every record (called from History screen clear button).
  Future<void> clearAll() async {
    try {
      final db = await database;
      await db.delete('game_results');
    } catch (e) {
      debugPrint('DB clearAll error: $e');
    }
  }
}
