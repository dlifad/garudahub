import 'package:flutter/material.dart';
import 'package:garudahub/features/news/models/news_data.dart';

class NewsList extends StatelessWidget {
  const NewsList({
    super.key,
    required this.isLoading,
    required this.news,
    required this.newsAnim,
    this.onTap,
  });

  final bool isLoading;
  final List<NewsData> news;
  final AnimationController newsAnim;
  final void Function(NewsData)? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isLoading) {
      return Column(
        children: List.generate(3, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 90,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }),
      );
    }

    if (news.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Belum ada berita terbaru',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
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
              (index * 0.1).clamp(0.0, 0.8),
              1.0,
              curve: Curves.easeOut,
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: newsAnim,
              curve: Curves.easeOut,
            )),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: cs.surface,
                elevation: 1,
                shadowColor: cs.shadow.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: cs.outline.withValues(alpha: 0.15))
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onTap?.call(item),
                  child: Row(
                    children: [
                      // Thumbnail flush ke tepi kiri card
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(12),
                        ),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: (item.imageUrl == null || item.imageUrl!.isEmpty)
                              ? Container(
                                  color: cs.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 20,
                                    color: cs.onSurfaceVariant,
                                  ),
                                )
                              : Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: cs.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 20,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                  height: 1.3,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Time
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 11,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    item.relativeTime,
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}