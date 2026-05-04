import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerService {
  final double threshold;
  final Duration cooldown;

  bool _isFirstReading = true;
  bool _isListening = false;

  StreamSubscription? _subscription;
  DateTime? _lastShake;

  double _lastAcceleration = 0;

  AccelerometerService({
    this.threshold = 8,
    this.cooldown = const Duration(seconds: 2),
  });

  void startListening(void Function() onShake) {
    if (_isListening) return;
    _isListening = true;

    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.normalInterval,
    ).listen((event) {
      final currentAcceleration = sqrt(
        event.x * event.x +
        event.y * event.y +
        event.z * event.z,
      );

      if (_isFirstReading) {
        _lastAcceleration = currentAcceleration;
        _isFirstReading = false;
        return;
      }

      final delta = (currentAcceleration - _lastAcceleration).abs();
      _lastAcceleration = currentAcceleration;

      final now = DateTime.now();

      if (delta > threshold) {
        if (_lastShake == null ||
            now.difference(_lastShake!) > cooldown) {
          _lastShake = now;
          onShake();
        }
      }
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;

    _isFirstReading = true;
    _isListening = false;
  }
}