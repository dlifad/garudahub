
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _db;
  static const _dbName = 'garudahub.db';
  static const _dbVersion = 1;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id            INTEGER PRIMARY KEY,
        name          TEXT NOT NULL,
        email         TEXT NOT NULL,
        is_verified   INTEGER DEFAULT 0,
        profile_photo TEXT,
        created_at    TEXT,
        cached_at     TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE match_cache (
        id              INTEGER PRIMARY KEY,
        opponent_name   TEXT,
        tournament_name TEXT,
        match_date      TEXT,
        venue           TEXT,
        indonesia_score INTEGER,
        opponent_score  INTEGER,
        is_finished     INTEGER DEFAULT 0,
        formation       TEXT,
        cached_at       TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE predictions (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        match_id       INTEGER,
        opponent_name  TEXT,
        predicted_indo INTEGER,
        predicted_opp  INTEGER,
        actual_indo    INTEGER,
        actual_opp     INTEGER,
        is_correct     INTEGER DEFAULT 0,
        created_at     TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE game_scores (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        game_name TEXT,
        score     INTEGER,
        played_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE preferences (
        key   TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    // future migrations here
  }

  static Future<void> close() async => _db?.close();
}
