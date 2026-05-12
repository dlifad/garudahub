import 'package:flutter/foundation.dart';

import 'package:garudahub/features/dashboard/models/match_data.dart';
import 'package:garudahub/features/dashboard/services/dashboard_service.dart';
import 'package:garudahub/features/prediction/models/prediction_history.dart';
import 'package:garudahub/features/prediction/services/prediction_service.dart';

class PredictionProvider extends ChangeNotifier {
  final _dashService = DashboardService();
  final _predictionService = PredictionService();

  MatchData? _nextMatch;
  int _indScore = 1;
  int _oppScore = 0;
  bool _predictionLocked = false;
  bool _submitting = false;
  String? _statusMsg;

  List<PredictionHistory> _history = [];
  bool _loadingHistory = true;

  MatchData? get nextMatch => _nextMatch;
  int get indScore => _indScore;
  int get oppScore => _oppScore;
  bool get predictionLocked => _predictionLocked;
  bool get submitting => _submitting;
  String? get statusMsg => _statusMsg;
  List<PredictionHistory> get history => _history;
  bool get loadingHistory => _loadingHistory;

  Future<void> loadData() async {
    await Future.wait([loadNextMatch(), loadHistory()]);
  }

  Future<void> loadNextMatch() async {
    try {
      final data = await _dashService.loadDashboardData();
      _nextMatch = data.nextMatch;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadHistory() async {
    _loadingHistory = true;
    notifyListeners();
    try {
      _history = await _predictionService.getMyPredictions();
    } catch (_) {
    } finally {
      _loadingHistory = false;
      notifyListeners();
    }
  }

  void setIndScore(int value) {
    _indScore = value.clamp(0, 20);
    notifyListeners();
  }

  void setOppScore(int value) {
    _oppScore = value.clamp(0, 20);
    notifyListeners();
  }

  void incrementIndScore() => setIndScore(_indScore + 1);
  void decrementIndScore() => setIndScore(_indScore - 1);
  void incrementOppScore() => setOppScore(_oppScore + 1);
  void decrementOppScore() => setOppScore(_oppScore - 1);

  void prepareEdit(PredictionHistory item) {
    _indScore = item.predictedHome;
    _oppScore = item.predictedAway;
    _predictionLocked = false;
    _statusMsg = null;
    notifyListeners();
  }

  Future<void> submitPrediction() async {
    if (_nextMatch == null) return;
    _submitting = true;
    notifyListeners();
    try {
      final result = await _predictionService.submitPrediction(
        matchId: _nextMatch!.id,
        predictedIndonesiaScore: _indScore,
        predictedOpponentScore: _oppScore,
      );
      if (result.statusCode == 201 || result.statusCode == 409) {
        _predictionLocked = true;
        _statusMsg = result.message;
        notifyListeners();
        await loadHistory();
      } else {
        _statusMsg = result.message;
      }
    } catch (_) {
      _statusMsg = 'Koneksi bermasalah';
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> deletePrediction(int id) async {
    await _predictionService.deletePrediction(id);
    await loadHistory();
  }
}
