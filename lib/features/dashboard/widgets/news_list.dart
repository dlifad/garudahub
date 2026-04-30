import 'package:flutter/material.dart';
import 'package:garudahub/features/dashboard/models/news_data.dart';

class NewsList extends StatelessWidget {
  const NewsList({
    super.key,
    required this.isLoading,
    required this.news,
    required this.newsAnim,
    required this.categoryFromTitle,
  });

  final bool isLoading;
  final List<NewsData> news;
  final AnimationController newsAnim;
  final String Function(String title) categoryFromTitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (isLoading) {
      return Column(
        children: List.generate(2, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 90,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }),
      );
    }

    if (news.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          'Belum ada berita terbaru',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      );
    }

    return Column(
      children: List.generate(news.length, (index) {
        final item = news[index];
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: newsAnim,
            curve: Interval(
              (index * 0.1).clamp(0, 0.8),
              1,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: newsAnim, curve: Curves.easeOutCubic),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withOpacity(0.15)),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 8),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                      child: SizedBox(
                        width: 100,
                        height: 90,
                        child: item.imageUrl.isEmpty
                            ? Icon(
                                Icons.image_not_supported,
                                color: cs.onSurfaceVariant,
                              )
                            : Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.image_not_supported,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                categoryFromTitle(item.title),
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '🕐 ${item.relativeTime}',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
