class PredictionHistory {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final String homeFlag;
  final String awayFlag;
  final DateTime matchDate;
  final int predictedHome;
  final int predictedAway;
  final String status;
  final int? pointsEarned;

  const PredictionHistory({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeFlag,
    required this.awayFlag,
    required this.matchDate,
    required this.predictedHome,
    required this.predictedAway,
    required this.status,
    this.pointsEarned,
  });

  factory PredictionHistory.fromJson(Map<String, dynamic> json) {
    return PredictionHistory(
      id: json['id'] as int,
      homeTeam: json['home_team'] as String? ?? '',
      awayTeam: json['away_team'] as String? ?? '',
      homeFlag: json['home_flag'] as String? ?? '',
      awayFlag: json['away_flag'] as String? ?? '',
      matchDate:
          DateTime.tryParse(json['match_date'] as String? ?? '') ??
          DateTime.now(),
      predictedHome: json['predicted_indonesia_score'] as int? ?? 0,
      predictedAway: json['predicted_opponent_score'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      pointsEarned: json['points_earned'] as int?,
    );
  }
}
