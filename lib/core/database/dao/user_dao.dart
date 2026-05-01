
import 'package:sqflite/sqflite.dart';
import 'package:garudahub/core/database/db_helper.dart';
import 'package:garudahub/core/models/user_model.dart';

class UserDao {
  static const _table = 'users';

  static Future<void> upsert(UserModel user) async {
    final db = await DbHelper.database;
    await db.insert(
      _table,
      {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'is_verified': user.isVerified ? 1 : 0,
        'profile_photo': user.profilePhoto,
        'created_at': user.createdAt?.toIso8601String(),
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<UserModel?> getFirst() async {
    final db = await DbHelper.database;
    final rows = await db.query(_table, limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  static Future<void> clear() async {
    final db = await DbHelper.database;
    await db.delete(_table);
  }

  static UserModel _fromRow(Map<String, dynamic> r) => UserModel(
        id: r['id'] as int,
        name: r['name'] as String,
        email: r['email'] as String,
        isVerified: (r['is_verified'] as int) == 1,
        profilePhoto: r['profile_photo'] as String?,
        createdAt: r['created_at'] != null
            ? DateTime.tryParse(r['created_at'] as String)
            : null,
      );
}
