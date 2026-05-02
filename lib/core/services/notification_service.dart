import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garudahub/features/notification/models/notification_item.dart';
import 'package:garudahub/features/notification/services/notification_inbox_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _masterKey = 'notifications_enabled';
  static const _matchKey = 'match_notifications_enabled';
  static const _resultKey = 'result_notifications_enabled';
  static const _quizKey = 'quiz_notifications_enabled';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _notificationsEnabled = false;
  bool _matchNotificationsEnabled = false;
  bool _resultNotificationsEnabled = false;
  bool _quizNotificationsEnabled = false;

  bool get isInitialized => _initialized;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get matchNotificationsEnabled => _matchNotificationsEnabled;
  bool get resultNotificationsEnabled => _resultNotificationsEnabled;
  bool get quizNotificationsEnabled => _quizNotificationsEnabled;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.requestNotificationsPermission();

    await _loadState();
    _initialized = true;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_masterKey) ?? false;
    _matchNotificationsEnabled = prefs.getBool(_matchKey) ?? false;
    _resultNotificationsEnabled = prefs.getBool(_resultKey) ?? false;
    _quizNotificationsEnabled = prefs.getBool(_quizKey) ?? false;
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _saveBool(_masterKey, value);

    if (!value) {
      _matchNotificationsEnabled = false;
      _resultNotificationsEnabled = false;
      _quizNotificationsEnabled = false;
      await _saveBool(_matchKey, false);
      await _saveBool(_resultKey, false);
      await _saveBool(_quizKey, false);
      await _plugin.cancelAll();
      return;
    }

    await showNotification(
      id: 100,
      title: 'Notifikasi aktif',
      body: 'GarudaHub siap mengirim pengingat pertandingan dan hasil.',
      type: 'system',
    );
  }

  Future<void> setMatchNotificationsEnabled(bool value) async {
    _matchNotificationsEnabled = value;
    await _saveBool(_matchKey, value);

    if (value && _notificationsEnabled) {
      await showNotification(
        id: 101,
        title: 'Pengingat pertandingan aktif',
        body: 'Kamu akan mendapat pengingat saat jadwal pertandingan tersedia.',
        type: 'match',
      );
    }
  }

  Future<void> setResultNotificationsEnabled(bool value) async {
    _resultNotificationsEnabled = value;
    await _saveBool(_resultKey, value);

    if (value && _notificationsEnabled) {
      await showNotification(
        id: 102,
        title: 'Notifikasi hasil aktif',
        body: 'GarudaHub akan memberi info saat hasil pertandingan diperbarui.',
        type: 'result',
      );
    }
  }

  Future<void> setQuizNotificationsEnabled(bool value) async {
    _quizNotificationsEnabled = value;
    await _saveBool(_quizKey, value);

    if (value && _notificationsEnabled) {
      await showNotification(
        id: 103,
        title: 'Tebak score aktif',
        body: 'Kamu bisa dapat pengingat untuk fitur tebak score.',
        type: 'quiz',
      );
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String type = 'system',
  }) async {
    if (!_initialized) {
      await init();
    }

    if (!_notificationsEnabled && id != 100) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'garudahub_notifications',
      'GarudaHub Notifications',
      channelDescription: 'Notifikasi GarudaHub',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(id, title, body, details);

    await NotificationInboxService.instance.add(
      NotificationItem(
        id: '$id-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        createdAt: DateTime.now(),
        isRead: false,
        type: type,
      ),
    );
  }
}
