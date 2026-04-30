class MatchData {
  const MatchData({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeFlag,
    required this.awayFlag,
    required this.matchDateUtc,
    required this.venueName,
    required this.tournamentName,
    required this.round,
    this.indonesiaScore,
    this.opponentScore,
  });

  final int id;
  final String homeTeam;
  final String awayTeam;
  final String homeFlag;
  final String awayFlag;
  final DateTime matchDateUtc;
  final String venueName;
  final String tournamentName;
  final String round;
  final int? indonesiaScore;
  final int? opponentScore;

  factory MatchData.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) =>
        value == null ? null : int.tryParse('$value');
    return MatchData(
      id: parseInt(json['id']) ?? 0,
      homeTeam: json['home_team']?.toString() ?? 'Indonesia',
      awayTeam: json['away_team']?.toString() ?? 'Lawan',
      homeFlag: json['home_team_flag']?.toString().isNotEmpty == true
          ? json['home_team_flag'].toString()
          : '🇮🇩',
      awayFlag: json['away_team_flag']?.toString().isNotEmpty == true
          ? json['away_team_flag'].toString()
          : '🏳️',
      matchDateUtc:
          DateTime.tryParse(json['match_date_utc']?.toString() ?? '') ??
              DateTime.now(),
      venueName: (json['stadium'] is Map<String, dynamic>)
          ? (((json['stadium'] as Map<String, dynamic>)['name']?.toString()) ??
              'TBD')
          : (json['venue']?.toString() ?? 'TBD'),
      tournamentName: json['tournament_name']?.toString() ?? 'Turnamen',
      round: json['round']?.toString() ?? 'Stage',
      indonesiaScore: parseInt(json['indonesia_score']),
      opponentScore: parseInt(json['opponent_score']),
    );
  }
}
