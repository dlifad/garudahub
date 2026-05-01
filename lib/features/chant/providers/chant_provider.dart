import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garudahub/core/services/accelerometer_service.dart';
import 'package:garudahub/features/chant/services/chant_service.dart';

class ChantProvider extends ChangeNotifier {
  final AccelerometerService _accelerometer = AccelerometerService();
  final ChantService _chantService = ChantService();

  bool _isActive = false;
  bool _isListening = false;
  bool _isEnabled = false;
  bool _isInitialized = false;
  bool _isCompleting = false;

  Timer? _reverseTimer;

  bool get isEnabled => _isEnabled;
  bool get isActive => _isActive;
  bool get isInitialized => _isInitialized;
  bool get isCompleting => _isCompleting;
  bool get isListening => _isListening;

  static const _key = 'chant_enabled';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_key) ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool val) async {
    _isEnabled = val;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, val);

    if (val) {
      start();
    } else {
      stop();
    }

    notifyListeners();
  }

  void _cancelTimers() {
    _reverseTimer?.cancel();
  }

  void start() {
    if (!_isEnabled) return;
    if (_isListening) return;

    _isListening = true;

    _accelerometer.startListening(() async {
      if (!_isEnabled) return;
      if (_isActive || _isCompleting) return;

      _isActive = true;
      _isCompleting = false;
      notifyListeners();

      try {
        _cancelTimers();

        final (chantName, duration) = await _chantService.playChant();

        final totalSeconds =
            duration?.inSeconds ?? ChantService.durations[chantName] ?? 12;

        final downStartSeconds =
            (totalSeconds - 5).clamp(0, totalSeconds);

        _reverseTimer = Timer(Duration(seconds: downStartSeconds), () {
          if (!_isEnabled) return;
          _isCompleting = true;
          notifyListeners();
        });

        _chantService.onComplete.first.then((_) {
          if (!_isListening) return;

          _isActive = false;
          _isCompleting = false;
          notifyListeners();
        });
      } catch (_) {
        _isActive = false;
        _isCompleting = false;
        notifyListeners();
      }
    });
  }

  void stop() {
    if (!_isListening) return;

    _accelerometer.stopListening();
    _isListening = false;

    _cancelTimers();

    _isActive = false;
    _isCompleting = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimers();
    _accelerometer.stopListening();
    _chantService.dispose();
    super.dispose();
  }
}