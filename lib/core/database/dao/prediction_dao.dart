
import 'package:sqflite/sqflite.dart';
import 'package:garudahub/core/database/db_helper.dart';

class PredictionDao {
  static const _table = 'predictions';

  static Future<int> insert({
    required int matchId,
    required String opponentName,
    required int predictedIndo,
    required int predictedOpp,
  }) async {
    final db = await DbHelper.database;
    return db.insert(_table, {
      'match_id': matchId,
      'opponent_name': opponentName,
      'predicted_indo': predictedIndo,
      'predicted_opp': predictedOpp,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> updateResult({
    required int matchId,
    required int actualIndo,
    required int actualOpp,
  }) async {
    final db = await DbHelper.database;
    final rows = await db.query(_table,
        where: 'match_id = ?', whereArgs: [matchId]);
    for (final row in rows) {
      final predIndo = row['predicted_indo'] as int;
      final predOpp  = row['predicted_opp'] as int;
      final isCorrect =
          predIndo == actualIndo && predOpp == actualOpp ? 1 : 0;
      await db.update(
        _table,
        {
          'actual_indo': actualIndo,
          'actual_opp': actualOpp,
          'is_correct': isCorrect,
        },
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  static Future<Map<String, dynamic>?> getByMatchId(int matchId) async {
    final db = await DbHelper.database;
    final rows = await db.query(_table,
        where: 'match_id = ?', whereArgs: [matchId], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DbHelper.database;
    return db.query(_table, orderBy: 'created_at DESC');
  }

  static Future<Map<String, int>> getStats() async {
    final db = await DbHelper.database;
    final total = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_table')) ?? 0;
    final correct = Sqflite.firstIntValue(await db
        .rawQuery('SELECT COUNT(*) FROM $_table WHERE is_correct = 1')) ?? 0;
    return {'total': total, 'correct': correct, 'wrong': total - correct};
  }
}
