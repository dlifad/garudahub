import 'package:flutter/material.dart';
import 'package:garudahub/features/news/models/news_data.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsData news;

  const NewsDetailScreen({super.key, required this.news});

  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Future<void> _openSource(String url) async {
    final fixedUrl = url.startsWith('http') ? url : 'https://$url';
    final uri = Uri.parse(fixedUrl);

    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success) {
        throw 'Gagal membuka URL';
      }
    } catch (e) {
      debugPrint('Error buka URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar dengan hero image
          SliverAppBar(
            expandedHeight: news.imageUrl != null ? 260 : 0,
            pinned: true,
            backgroundColor: cs.surface,
            foregroundColor: cs.onSurface,
            flexibleSpace: news.imageUrl != null
                ? FlexibleSpaceBar(
                    background: Image.network(
                      news.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: cs.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 40,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Gambar tidak tersedia',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : null,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori / source badge
                  if (news.source != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        news.source!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Judul
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Author & tanggal
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [
                            news.author ?? 'Redaksi',
                            _formatDate(news.publishedAt),
                          ].where((s) => s.isNotEmpty).join(' · '),
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(color: cs.outlineVariant),
                  const SizedBox(height: 16),

                  // Konten
                  Text(
                    news.content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol baca di sumber asli
                  if (news.sourceUrl != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openSource(news.sourceUrl!),
                        icon: const Icon(Icons.open_in_browser, size: 18),
                        label: const Text('Baca di sumber asli'),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}