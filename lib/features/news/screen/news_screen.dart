import 'package:flutter/material.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:garudahub/features/news/providers/news_provider.dart';
import 'package:garudahub/features/news/screen/news_detail_screen.dart';
import 'package:provider/provider.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<NewsProvider>().fetchNews(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<NewsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita'),
        actions: [
          IconButton(
            tooltip: provider.sort == 'desc' ? 'Terlama dulu' : 'Terbaru dulu',
            icon: Icon(
              provider.sort == 'desc'
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
            ),
            onPressed: provider.toggleSort,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchNews,
        child: Builder(
          builder: (_) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(provider.error!),
                    const SizedBox(height: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: provider.fetchNews,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              );
            }
            if (provider.news.isEmpty) {
              return const Center(child: Text('Belum ada berita'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.base),
              itemCount: provider.news.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) {
                final item = provider.news[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailScreen(news: item),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.imageUrl != null)
                          Image.network(
                            item.imageUrl!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              if (item.author != null || item.source != null) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  [item.author, item.source]
                                      .whereType<String>()
                                      .join(' · '),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
