import 'dart:convert';
import 'package:garudahub/core/constants/constants.dart';
import 'package:garudahub/features/news/models/news_data.dart';
import 'package:http/http.dart' as http;

class NewsService {
  Future<List<NewsData>> getNews({
    String sort = 'desc',
    int limit = 20,
    int offset = 0,
    String? source,
  }) async {
    final queryParams = {
      'sort': sort,
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (source != null) 'source': source,
    };

    final uri = Uri.parse('${AppConstants.baseUrl}/news')
        .replace(queryParameters: queryParams);

    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Gagal memuat berita');

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>;
    return list.map((e) => NewsData.fromJson(e as Map<String, dynamic>)).toList();
  }
}