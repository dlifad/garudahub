// lib/features/mini_games/penalty/providers/penalty_provider.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/penalty_game_model.dart';

class PenaltyProvider extends ChangeNotifier {
  PenaltyGameState _state = const PenaltyGameState();
  StreamSubscription? _gyroSub;
  StreamSubscription? _accelSub;
  final _random = Random();

  static const double _tiltThreshold = 10.0;
  static const double _alpha = 0.85; // gyro weight (0.0-1.0)

  double _filteredAngle = 0.0;
  double _accelAngle = 0.0;
  DateTime? _lastGyroTime;

  PenaltyGameState get state => _state;

  void startGame() {
    _state = const PenaltyGameState(phase: GamePhase.aiming);
    _filteredAngle = 0.0;
    _startSensors();
    notifyListeners();
  }

  void _startSensors() {
    _gyroSub?.cancel();
    _accelSub?.cancel();
    _filteredAngle = 0.0;
    _lastGyroTime = null;

    // Accelerometer — baca posisi tilt sebagai referensi koreksi drift
    _accelSub = accelerometerEventStream().listen((event) {
      // Portrait: event.y negatif = miring kanan, positif = miring kiri
      _accelAngle = -event.y * (90.0 / 9.81);
    });

    // Gyroscope — integrate kecepatan rotasi untuk dapat sudut
    _gyroSub = gyroscopeEventStream().listen((event) {
      if (_state.phase != GamePhase.aiming) return;

      final now = DateTime.now();
      final dt = _lastGyroTime == null
          ? 0.016
          : now.difference(_lastGyroTime!).inMicroseconds / 1000000.0;
      _lastGyroTime = now;

      // Portrait: event.z = rotasi kiri/kanan
      // Negatif = kanan, positif = kiri → balik tanda
      final gyroDelta = -event.z * dt * (180 / pi);

      // Complementary filter:
      // 85% gyro (smooth, responsif) + 15% accel (koreksi drift)
      _filteredAngle = _alpha * (_filteredAngle + gyroDelta) +
          (1 - _alpha) * _accelAngle;

      _filteredAngle = _filteredAngle.clamp(-60.0, 60.0);

      AimZone newZone;
      if (_filteredAngle < -_tiltThreshold) {
        newZone = AimZone.left;
      } else if (_filteredAngle > _tiltThreshold) {
        newZone = AimZone.right;
      } else {
        newZone = AimZone.center;
      }

      if (newZone != _state.currentAim) {
        _state = _state.copyWith(currentAim: newZone);
        notifyListeners();
      }
    });
  }

  void shoot() {
    if (_state.phase != GamePhase.aiming) return;

    _gyroSub?.cancel();
    _accelSub?.cancel();
    _state = _state.copyWith(phase: GamePhase.shooting);
    notifyListeners();

    final keeperChoice = _randomKeeperZone();
    final isGoal = keeperChoice != _state.currentAim ||
        (_random.nextDouble() < 0.15);

    final result = isGoal ? ShotResult.goal : ShotResult.saved;
    final newRecord = PenaltyShotRecord(
      shotNumber: _state.currentShot,
      zone: _state.currentAim,
      result: result,
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      final newShots = [..._state.shots, newRecord];
      final newGoals = _state.goals + (isGoal ? 1 : 0);
      _state = _state.copyWith(
        goals: newGoals,
        shots: newShots,
        phase: GamePhase.result,
        keeperDive: keeperChoice,
        lastResult: result,
      );
      notifyListeners();
    });
  }

  void nextShot() {
    final nextNum = _state.currentShot + 1;
    if (nextNum > _state.totalShots) {
      _state = _state.copyWith(
        currentShot: nextNum,
        phase: GamePhase.finished,
      );
      notifyListeners();
      return;
    }
    _filteredAngle = 0.0;
    _state = _state.copyWith(
      currentShot: nextNum,
      phase: GamePhase.aiming,
      keeperDive: null,
      lastResult: null,
    );
    _startSensors();
    notifyListeners();
  }

  void resetGame() {
    _gyroSub?.cancel();
    _accelSub?.cancel();
    _filteredAngle = 0.0;
    _state = const PenaltyGameState(phase: GamePhase.aiming);
    _startSensors();
    notifyListeners();
  }

  AimZone _randomKeeperZone() {
    final r = _random.nextDouble();
    if (r < 0.33) return AimZone.left;
    if (r < 0.66) return AimZone.right;
    return AimZone.center;
  }

  @override
  void dispose() {
    _gyroSub?.cancel();
    _accelSub?.cancel();
    super.dispose();
  }
}
