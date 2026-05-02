class NewsData {
  final int id;
  final String title;
  final String content;
  final String? author;
  final String? source;
  final String? sourceUrl;
  final String? imageUrl;
  final String? publishedAt;

  const NewsData({
    required this.id,
    required this.title,
    required this.content,
    this.author,
    this.source,
    this.sourceUrl,
    this.imageUrl,
    this.publishedAt,
  });

  factory NewsData.fromJson(Map<String, dynamic> json) => NewsData(
    id: json['id'] as int,
    title: json['title'] as String,
    content: json['content'] as String,
    author: json['author'] as String?,
    source: json['source'] as String?,
    sourceUrl: json['source_url'] as String?,
    imageUrl: json['image_url'] as String?,
    publishedAt: json['published_at'] as String?,
  );

  String get relativeTime {
    if (publishedAt == null) return '';

    final dt = DateTime.tryParse(publishedAt!);
    if (dt == null) return '';

    final diff = DateTime.now().difference(dt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else {
      return '${diff.inDays} hari lalu';
    }
  }
}

