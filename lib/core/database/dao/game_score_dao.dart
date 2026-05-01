
import 'package:garudahub/core/database/db_helper.dart';

class GameScoreDao {
  static const _table = 'game_scores';

  static Future<int> insert({
    required String gameName,
    required int score,
  }) async {
    final db = await DbHelper.database;
    return db.insert(_table, {
      'game_name': gameName,
      'score': score,
      'played_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getByGame(String gameName) async {
    final db = await DbHelper.database;
    return db.query(
      _table,
      where: 'game_name = ?',
      whereArgs: [gameName],
      orderBy: 'score DESC',
    );
  }

  static Future<int> getHighScore(String gameName) async {
    final db = await DbHelper.database;
    final result = await db.rawQuery(
      'SELECT MAX(score) as max_score FROM $_table WHERE game_name = ?',
      [gameName],
    );
    return (result.first['max_score'] as int?) ?? 0;
  }

  static Future<List<Map<String, dynamic>>> getAllScores() async {
    final db = await DbHelper.database;
    return db.query(_table, orderBy: 'played_at DESC');
  }
}
