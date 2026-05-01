import 'dart:convert';
import 'package:garudahub/core/constants/constants.dart';
import 'package:garudahub/features/match/models/lineup_player.dart';
import 'package:garudahub/features/match/models/match_item.dart';
import 'package:garudahub/features/match/models/match_record.dart';
import 'package:garudahub/features/match/models/tournament_coach.dart';
import 'package:garudahub/features/match/models/tournament_model.dart';
import 'package:http/http.dart' as http;

class MatchLineupData {
  final List<LineupPlayer> startingXi;
  final List<LineupPlayer> substitutes;
  const MatchLineupData({required this.startingXi, required this.substitutes});
  bool get isEmpty => startingXi.isEmpty && substitutes.isEmpty;
}

class MatchService {
  static const _tz = 'Asia/Jakarta';
  static const _base = AppConstants.baseUrl;

  // ── Tournaments ──────────────────────────────────────────────────────
  Future<List<TournamentModel>> getTournaments() async {
    try {
      final res = await http.get(Uri.parse('$_base/tournaments'));
      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return (body['data'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TournamentModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Tournament Coaches ───────────────────────────────────────────────
  Future<List<TournamentCoach>> getTournamentCoaches(int tournamentId) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/tournaments/$tournamentId/coaches'));
      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return (body['data'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TournamentCoach.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Resolves 1 head coach for a specific match date.
  /// Handles 2-coach scenario: filters by date range first,
  /// falls back to is_active flag, then latest entry.
  TournamentCoach? resolveCoach(
      List<TournamentCoach> coaches, DateTime matchDate) {
    final heads =
        coaches.where((c) => c.role == 'head_coach').toList();
    final filtered = heads.where((c) => c.isActiveOn(matchDate)).toList();
    if (filtered.isNotEmpty) return filtered.first;
    final active = heads.where((c) => c.isActive).toList();
    if (active.isNotEmpty) return active.first;
    return heads.isNotEmpty ? heads.first : null;
  }

  // ── Matches ──────────────────────────────────────────────────────────
  Future<List<MatchItem>> getMatchesByTournament(int tournamentId) async {
    try {
      final results = await Future.wait([
        _fetchMatches(tournamentId: tournamentId, status: 'finished'),
        _fetchMatches(tournamentId: tournamentId, status: 'scheduled'),
        _fetchMatches(tournamentId: tournamentId, status: 'ongoing'),
      ]);
      return [...results[0], ...results[1], ...results[2]]
        ..sort((a, b) => a.matchDateUtc.compareTo(b.matchDateUtc));
    } catch (_) {
      return [];
    }
  }

  Future<List<MatchItem>> _fetchMatches(
      {int? tournamentId, String? status}) async {
    final params = <String, String>{'timezone': _tz};
    if (tournamentId != null) params['tournament_id'] = '$tournamentId';
    if (status != null) params['status'] = status;
    try {
      final res = await http.get(
          Uri.parse('$_base/matches').replace(queryParameters: params));
      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body);
      final list = body is Map<String, dynamic>
          ? (body['data'] as List? ?? [])
          : body as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map(MatchItem.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Match Lineup ─────────────────────────────────────────────────────
  Future<MatchLineupData?> getMatchLineup(int matchId) async {
    try {
      final res =
          await http.get(Uri.parse('$_base/matches/$matchId/lineup'));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] != true) return null;
      return MatchLineupData(
        startingXi: (body['starting_xi'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(LineupPlayer.fromJson)
            .toList(),
        substitutes: (body['substitutes'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(LineupPlayer.fromJson)
            .toList(),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Record Stats ─────────────────────────────────────────────────────
  MatchRecord computeRecord(List<MatchItem> matches) {
    final finished =
        matches.where((m) => m.isFinished && m.indonesiaScore != null);
    int total = 0, wins = 0, draws = 0, losses = 0, gf = 0, ga = 0;
    for (final m in finished) {
      total++;
      gf += m.indonesiaScore ?? 0;
      ga += m.opponentScore ?? 0;
      if (m.result == 'WIN') wins++;
      else if (m.result == 'DRAW') draws++;
      else if (m.result == 'LOSS') losses++;
    }
    return MatchRecord(
        total: total, wins: wins, draws: draws,
        losses: losses, goalsFor: gf, goalsAgainst: ga);
  }
}
