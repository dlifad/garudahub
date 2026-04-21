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

  bool get isEnabled => _isEnabled;
  bool get isActive => _isActive;
  bool get isInitialized => _isInitialized;

  static const _key = 'chant_enabled';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_key) ?? false;

    if (_isEnabled) {
      start();
    }

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

  void start() {
    if (_isListening) return;

    _isListening = true;

    _accelerometer.startListening(() async {
      if (!_isEnabled) return;
      if (_isActive) return;

      _isActive = true;
      notifyListeners();

      try {
        await _chantService.playChant();

        if (!_isEnabled) return;

        await Future.delayed(const Duration(seconds: 2));
        if (!_isEnabled) return;
      } catch (_) {
      } finally {
        _isActive = false;
        notifyListeners();
      }
    });
  }

  void stop() {
    if (!_isListening) return;

    _accelerometer.stopListening();

    _isListening = false;
    _isActive = false;

    notifyListeners();
  }
}