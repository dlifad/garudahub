
import 'package:sqflite/sqflite.dart';
import 'package:garudahub/core/database/db_helper.dart';

class MatchCacheDao {
  static const _table = 'match_cache';

  static Future<void> upsertAll(List<Map<String, dynamic>> matches) async {
    final db = await DbHelper.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();
    for (final m in matches) {
      batch.insert(
        _table,
        {...m, 'cached_at': now},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DbHelper.database;
    return db.query(_table, orderBy: 'match_date DESC');
  }

  static Future<List<Map<String, dynamic>>> getUpcoming() async {
    final db = await DbHelper.database;
    return db.query(
      _table,
      where: 'is_finished = 0',
      orderBy: 'match_date ASC',
    );
  }

  static Future<List<Map<String, dynamic>>> getFinished() async {
    final db = await DbHelper.database;
    return db.query(
      _table,
      where: 'is_finished = 1',
      orderBy: 'match_date DESC',
    );
  }

  static Future<void> clear() async {
    final db = await DbHelper.database;
    await db.delete(_table);
  }
}
