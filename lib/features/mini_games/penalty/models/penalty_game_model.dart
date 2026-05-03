// lib/features/mini_games/penalty/models/penalty_game_model.dart

enum AimZone { left, center, right }

enum ShotResult { goal, saved, miss }

enum GamePhase { idle, aiming, shooting, result, finished }

class PenaltyShotRecord {
  final int shotNumber;
  final AimZone zone;
  final ShotResult result;

  const PenaltyShotRecord({
    required this.shotNumber,
    required this.zone,
    required this.result,
  });
}

class PenaltyGameState {
  final int totalShots;
  final int currentShot;     // 1-based
  final int goals;
  final List<PenaltyShotRecord> shots;
  final GamePhase phase;
  final AimZone currentAim;
  final AimZone? keeperDive;
  final ShotResult? lastResult;

  const PenaltyGameState({
    this.totalShots = 5,
    this.currentShot = 1,
    this.goals = 0,
    this.shots = const [],
    this.phase = GamePhase.idle,
    this.currentAim = AimZone.center,
    this.keeperDive,
    this.lastResult,
  });

  bool get isFinished => currentShot > totalShots;

  PenaltyGameState copyWith({
    int? currentShot,
    int? goals,
    List<PenaltyShotRecord>? shots,
    GamePhase? phase,
    AimZone? currentAim,
    AimZone? keeperDive,
    ShotResult? lastResult,
  }) {
    return PenaltyGameState(
      totalShots: totalShots,
      currentShot: currentShot ?? this.currentShot,
      goals: goals ?? this.goals,
      shots: shots ?? this.shots,
      phase: phase ?? this.phase,
      currentAim: currentAim ?? this.currentAim,
      keeperDive: keeperDive,
      lastResult: lastResult ?? this.lastResult,
    );
  }
}
