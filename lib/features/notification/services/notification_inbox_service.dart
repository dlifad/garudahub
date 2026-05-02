import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart';

class NotificationInboxService {
  NotificationInboxService._();

  static final NotificationInboxService instance = NotificationInboxService._();

  static const _key = 'notification_inbox_items';

  Future<List<NotificationItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(NotificationItem.fromJson)
        .toList()
        .reversed
        .toList();
  }

  Future<int> getUnreadCount() async {
    final items = await getAll();
    return items.where((e) => !e.isRead).length;
  }

  Future<void> add(NotificationItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadRaw(prefs);
    list.add(item.toJson());
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();
    final updated = items
        .map((e) => e.copyWith(isRead: true).toJson())
        .toList();
    await prefs.setString(_key, jsonEncode(updated));
  }

  Future<void> markRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();
    final updated = items
        .map((e) => e.id == id ? e.copyWith(isRead: true).toJson() : e.toJson())
        .toList();
    await prefs.setString(_key, jsonEncode(updated));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<List<Map<String, dynamic>>> _loadRaw(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List? ?? [];
    return list.whereType<Map<String, dynamic>>().toList();
  }
}
