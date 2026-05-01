
import 'package:sqflite/sqflite.dart';
import 'package:garudahub/core/database/db_helper.dart';

class PreferenceDao {
  static const _table = 'preferences';

  static const kNotifMatch      = 'notif_match';
  static const kNotifResult     = 'notif_result';
  static const kNotifPrediction = 'notif_prediction';
  static const kBiometric       = 'biometric_enabled';
  static const kDarkMode        = 'dark_mode';
  static const kCurrency        = 'currency_selected';
  static const kChantEnabled    = 'chant_enabled';

  static Future<void> set(String key, String value) async {
    final db = await DbHelper.database;
    await db.insert(
      _table,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> get(String key) async {
    final db = await DbHelper.database;
    final rows = await db.query(
      _table,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final v = await get(key);
    if (v == null) return defaultValue;
    return v == 'true';
  }

  static Future<void> setBool(String key, bool value) =>
      set(key, value.toString());

  static Future<void> remove(String key) async {
    final db = await DbHelper.database;
    await db.delete(_table, where: 'key = ?', whereArgs: [key]);
  }

  static Future<Map<String, String>> getAll() async {
    final db = await DbHelper.database;
    final rows = await db.query(_table);
    return {for (final r in rows) r['key'] as String: r['value'] as String};
  }
}
