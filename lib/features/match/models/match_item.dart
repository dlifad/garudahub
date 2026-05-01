class MatchGoal {
  final String scorerName;
  final int minute;
  final String? assistName;
  final bool isIndonesiaGoal;

  const MatchGoal({
    required this.scorerName,
    required this.minute,
    this.assistName,
    this.isIndonesiaGoal = true,
  });

  factory MatchGoal.fromJson(Map<String, dynamic> j) => MatchGoal(
        scorerName: j['scorer_name']?.toString() ??
            j['player_name']?.toString() ?? 'Unknown',
        minute: (j['minute'] as num?)?.toInt() ?? 0,
        assistName: j['assist_name']?.toString() ?? j['assist']?.toString(),
        isIndonesiaGoal:
            j['is_indonesia_goal'] == true || j['is_indonesia_goal'] == 1,
      );
}

class MatchItem {
  final int id;
  final int tournamentId;
  final String tournamentName;
  final String? tournamentLogo;
  final String? matchday;
  final String? round;
  final bool isHome;
  final String homeTeam;
  final String awayTeam;
  final String homeFlag;
  final String awayFlag;
  final DateTime matchDateUtc;
  final String? venue;
  final String status;
  final int? homeScore;
  final int? awayScore;
  final int? indonesiaScore;
  final int? opponentScore;
  final String? result;
  final String? formation;
  final String? headCoach;
  final String? halfTimeScore;
  final List<MatchGoal>? goals;

  const MatchItem({
    required this.id,
    required this.tournamentId,
    required this.tournamentName,
    this.tournamentLogo,
    this.matchday,
    this.round,
    required this.isHome,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeFlag,
    required this.awayFlag,
    required this.matchDateUtc,
    this.venue,
    required this.status,
    this.homeScore,
    this.awayScore,
    this.indonesiaScore,
    this.opponentScore,
    this.result,
    this.formation,
    this.headCoach,
    this.halfTimeScore,
    this.goals,
  });

  String get opponentName => isHome ? awayTeam : homeTeam;
  String get opponentFlag => isHome ? awayFlag : homeFlag;
  bool get isFinished => status == 'finished';
  bool get isScheduled => status == 'scheduled';
  bool get isOngoing => status == 'ongoing';

  factory MatchItem.fromJson(Map<String, dynamic> j) {
    int? parseInt(dynamic v) => v == null ? null : int.tryParse('$v');
    final isHome = j['is_home'] == true || j['is_home'] == 1;
    List<MatchGoal>? goals;
    if (j['goals'] is List) {
      goals = (j['goals'] as List)
          .whereType<Map<String, dynamic>>()
          .map(MatchGoal.fromJson)
          .toList();
    }
    return MatchItem(
      id: parseInt(j['id']) ?? 0,
      tournamentId: parseInt(j['tournament_id']) ?? 0,
      tournamentName: j['tournament_name']?.toString() ?? '',
      tournamentLogo: j['tournament_logo']?.toString(),
      matchday: j['matchday']?.toString(),
      round: j['round']?.toString(),
      isHome: isHome,
      homeTeam: j['home_team']?.toString() ?? 'Indonesia',
      awayTeam: j['away_team']?.toString() ?? 'Lawan',
      homeFlag: j['home_team_flag']?.toString().isNotEmpty == true
          ? j['home_team_flag'].toString()
          : (isHome ? 'ID' : '??'),
      awayFlag: j['away_team_flag']?.toString().isNotEmpty == true
          ? j['away_team_flag'].toString()
          : (isHome ? '??' : 'ID'),
      matchDateUtc:
          DateTime.tryParse(j['match_date_utc']?.toString() ?? '') ?? DateTime.now(),
      venue: (j['stadium'] is Map<String, dynamic>)
          ? j['stadium']['name']?.toString()
          : j['venue']?.toString(),
      status: j['status']?.toString() ?? 'scheduled',
      homeScore: parseInt(j['home_score']),
      awayScore: parseInt(j['away_score']),
      indonesiaScore: parseInt(j['indonesia_score']),
      opponentScore: parseInt(j['opponent_score']),
      result: j['result']?.toString(),
      formation: j['formation']?.toString(),
      headCoach: j['head_coach']?.toString(),
      halfTimeScore: j['half_time_score']?.toString(),
      goals: goals,
    );
  }
}
