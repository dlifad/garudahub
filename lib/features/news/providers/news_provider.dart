import 'package:flutter/material.dart';
import 'package:garudahub/features/news/models/news_data.dart';
import 'package:garudahub/features/news/services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final _service = NewsService();

  List<NewsData> _news = [];
  bool _isLoading = false;
  String? _error;
  String _sort = 'desc';

  List<NewsData> get news => _news;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sort => _sort;

  Future<void> fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _news = await _service.getNews(sort: _sort);
    } catch (e) {
      _error = 'Gagal memuat berita. Coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSort() {
    _sort = _sort == 'desc' ? 'asc' : 'desc';
    fetchNews();
  }
}