// lib/features/mini_games/penalty/providers/penalty_provider.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/penalty_game_model.dart';

class PenaltyProvider extends ChangeNotifier {
  PenaltyGameState _state = const PenaltyGameState();
  StreamSubscription? _gyroSub;
  final _random = Random();

  // Gyro threshold (derajat)
  static const double _tiltThreshold = 12.0;

  PenaltyGameState get state => _state;

  void startGame() {
    _state = const PenaltyGameState(phase: GamePhase.aiming);
    _startGyro();
    notifyListeners();
  }

  void _startGyro() {
    _gyroSub?.cancel();
    _gyroSub = gyroscopeEventStream().listen((event) {
      if (_state.phase != GamePhase.aiming) return;

      // event.x = tilt kiri/kanan (negatif = kanan, positif = kiri)
      final tilt = event.x * -1;

      AimZone newZone;
      if (tilt < -_tiltThreshold / 100) {
        newZone = AimZone.left;
      } else if (tilt > _tiltThreshold / 100) {
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

  /// Dipanggil dari accelerometer untuk smooth aim
  void updateAimFromTilt(double gamma) {
    if (_state.phase != GamePhase.aiming) return;
    AimZone newZone;
    if (gamma < -_tiltThreshold) {
      newZone = AimZone.left;
    } else if (gamma > _tiltThreshold) {
      newZone = AimZone.right;
    } else {
      newZone = AimZone.center;
    }
    if (newZone != _state.currentAim) {
      _state = _state.copyWith(currentAim: newZone);
      notifyListeners();
    }
  }

  void shoot() {
    if (_state.phase != GamePhase.aiming) return;

    _gyroSub?.cancel();
    _state = _state.copyWith(phase: GamePhase.shooting);
    notifyListeners();

    // Kiper AI: mudah → 35% chance benar tebak
    final keeperChoice = _randomKeeperZone();
    final isGoal = keeperChoice != _state.currentAim ||
        (_random.nextDouble() < 0.15); // 15% chance gol walau tebak benar

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

    _state = _state.copyWith(
      currentShot: nextNum,
      phase: GamePhase.aiming,
      keeperDive: null,
      lastResult: null,
    );
    _startGyro();
    notifyListeners();
  }

  void resetGame() {
    _gyroSub?.cancel();
    _state = const PenaltyGameState(phase: GamePhase.aiming);
    _startGyro();
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
    super.dispose();
  }
}
