import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class GyroscopeService {
  StreamSubscription? _subscription;
  bool _isListening = false;

  /// [onGyro] dipanggil tiap sample: (rollVelocity, pitchVelocity) dalam rad/s
  void startListening(void Function(double roll, double pitch) onGyro) {
    if (_isListening) return;
    _isListening = true;

    _subscription = gyroscopeEventStream(
      samplingPeriod: SensorInterval.gameInterval, // ~20ms
    ).listen((event) {
      // Z = roll (miringin kiri/kanan), X = pitch (maju/mundur)
      onGyro(event.z, event.x);
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  void dispose() {
    stopListening();
  }
}