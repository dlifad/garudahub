
class MatchRecord {
  final int total;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;

  const MatchRecord({
    this.total = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
  });

  double get winRate => total == 0 ? 0 : wins / total;
  int get goalDiff => goalsFor - goalsAgainst;
  bool get isEmpty => total == 0;

  static const empty = MatchRecord();
}
