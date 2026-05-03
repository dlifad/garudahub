// lib/features/mini_games/penalty/providers/penalty_provider.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/penalty_game_model.dart';

class PenaltyProvider extends ChangeNotifier {
  PenaltyGameState _state = const PenaltyGameState();
  StreamSubscription? _accelSub;
  final _random = Random();

  // Threshold miring (m/s²)
  static const double _tiltThreshold = 3.0;

  PenaltyGameState get state => _state;

  void startGame() {
    _state = const PenaltyGameState(phase: GamePhase.aiming);
    _startSensors();
    notifyListeners();
  }

  void _startSensors() {
    _accelSub?.cancel();

    _accelSub = accelerometerEventStream().listen((event) {
      if (_state.phase != GamePhase.aiming) return;

      // HP dipegang portrait tapi orientasi sensor landscape:
      // event.x positif = miring kanan, negatif = miring kiri
      final tilt = event.x;

      AimZone newZone;
      if (tilt < -_tiltThreshold) {
        newZone = AimZone.left;
      } else if (tilt > _tiltThreshold) {
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
    _accelSub?.cancel();
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
    _accelSub?.cancel();
    super.dispose();
  }
}
