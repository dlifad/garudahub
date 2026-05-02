import 'dart:convert';

import 'package:garudahub/core/constants/constants.dart';
import 'package:garudahub/features/dashboard/models/dashboard_data.dart';
import 'package:garudahub/features/dashboard/models/match_data.dart';
import 'package:garudahub/features/news/models/news_data.dart';
import 'package:http/http.dart' as http;

class DashboardService {
  Future<DashboardData> loadDashboardData() async {
    final results = await Future.wait([
      getMatches(status: 'scheduled'),
      getMatches(status: 'finished'),
      getNews(),
    ]);

    final scheduled = results[0] as List<MatchData>;
    final finished = results[1] as List<MatchData>;
    final news = results[2] as List<NewsData>;

    final recentMatches = [...finished]
      ..sort((a, b) => b.matchDateUtc.compareTo(a.matchDateUtc));

    return DashboardData(
      nextMatch: scheduled.isEmpty ? null : scheduled.first,
      recentMatches: recentMatches.take(5).toList(),
      news: news.take(4).toList(),
    );
  }

  Future<List<MatchData>> getMatches({required String status}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/matches?status=$status');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final decoded = jsonDecode(res.body);
    final data = decoded is Map<String, dynamic>
        ? (decoded['data'] as List<dynamic>? ?? const [])
        : (decoded as List<dynamic>);
    return data
        .whereType<Map<String, dynamic>>()
        .map(MatchData.fromJson)
        .toList()
      ..sort((a, b) => a.matchDateUtc.compareTo(b.matchDateUtc));
  }

  Future<List<NewsData>> getNews() async {
    final uri = Uri.parse('${AppConstants.baseUrl}/news?limit=2');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final data = decoded['data'] as List<dynamic>? ?? [];
    return data.whereType<Map<String, dynamic>>().map(NewsData.fromJson).toList();
  }
}
