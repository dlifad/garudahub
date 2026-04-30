class NewsData {
  const NewsData({
    required this.title,
    required this.imageUrl,
    required this.publishedAt,
  });

  final String title;
  final String imageUrl;
  final DateTime publishedAt;

  String get relativeTime {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  factory NewsData.fromJson(Map<String, dynamic> json) {
    return NewsData(
      title: json['title']?.toString() ?? 'Tanpa Judul',
      imageUrl: json['image_url']?.toString() ?? '',
      publishedAt:
          DateTime.tryParse(json['published_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}
