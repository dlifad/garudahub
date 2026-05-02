import 'package:garudahub/features/dashboard/models/match_data.dart';
import 'package:garudahub/features/news/models/news_data.dart';

class DashboardData {
  const DashboardData({
    required this.nextMatch,
    required this.recentMatches,
    required this.news,
  });

  final MatchData? nextMatch;
  final List<MatchData> recentMatches;
  final List<NewsData> news;
}
