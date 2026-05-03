import 'package:flutter/material.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:garudahub/core/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:garudahub/features/shop/ticket/providers/ticket_provider.dart';
import 'package:garudahub/core/providers/timezone_provider.dart';

class TicketScreen extends StatefulWidget {
  final String query;
  final double? minPrice;
  final double? maxPrice;
  final String sortOption;

  const TicketScreen({
    super.key,
    required this.query,
    this.minPrice,
    this.maxPrice,
    this.sortOption = 'default',
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 200;
      if (shouldShow != _showScrollToTop) {
        setState(() => _showScrollToTop = shouldShow);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TicketProvider>();
    final base = AppConstants.baseUrl.replaceAll('/api', '');
    final cs = Theme.of(context).colorScheme;

    if (prov.error != null) {
      return Center(child: Text(prov.error!));
    }

    if (prov.isLoading && prov.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prov.items.isEmpty) {
      return _emptyState();
    }

    // Filter by query
    final q = widget.query.toLowerCase().trim();
    var filtered = q.isEmpty
        ? List<Map<String, dynamic>>.from(prov.items)
        : prov.items.where((match) {
            final home = (match['home_team'] ?? '').toLowerCase();
            final away = (match['away_team'] ?? '').toLowerCase();
            final tournament = (match['tournament_name'] ?? '').toLowerCase();
            final stadium = (match['stadium']?['name'] ?? '').toLowerCase();
            return home.contains(q) ||
                away.contains(q) ||
                tournament.contains(q) ||
                stadium.contains(q);
          }).toList();

    // Filter by min price
    if (widget.minPrice != null) {
      filtered = filtered.where((match) {
        final price = ((match['min_ticket_price'] ?? 0) as num).toDouble();
        return price >= widget.minPrice!;
      }).toList();
    }

    // Filter by max price
    if (widget.maxPrice != null) {
      filtered = filtered.where((match) {
        final price = ((match['min_ticket_price'] ?? 0) as num).toDouble();
        return price <= widget.maxPrice!;
      }).toList();
    }

    // Sorting
    switch (widget.sortOption) {
      case 'price_asc':
        filtered.sort(
          (a, b) => ((a['min_ticket_price'] ?? 0) as num).compareTo(
            (b['min_ticket_price'] ?? 0) as num,
          ),
        );
        break;
      case 'price_desc':
        filtered.sort(
          (a, b) => ((b['min_ticket_price'] ?? 0) as num).compareTo(
            (a['min_ticket_price'] ?? 0) as num,
          ),
        );
        break;
      case 'name_asc':
        filtered.sort(
          (a, b) => (a['home_team'] ?? '').toLowerCase().compareTo(
            (b['home_team'] ?? '').toLowerCase(),
          ),
        );
        break;
      case 'name_desc':
        filtered.sort(
          (a, b) => (b['home_team'] ?? '').toLowerCase().compareTo(
            (a['home_team'] ?? '').toLowerCase(),
          ),
        );
        break;
      default:
        break;
    }

    if (prov.isLoading && prov.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Tiket tidak ditemukan',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await context.read<TicketProvider>().refresh();
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final match = filtered[index];
              final logo = match['tournament_logo'];
              final stadium = match['stadium']?['name'];

              return GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.base),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: AppSpacing.md - 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black.withValues(alpha: 0.06),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            match['tournament_name'] ?? '-',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // Body
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.base),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: logo != null
                                  ? Image.network(
                                      '$base$logo',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.image,
                                        color: Colors.black54,
                                        size: 28,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.emoji_events,
                                      color: Colors.black54,
                                      size: 28,
                                    ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${match['home_team']} vs ${match['away_team']}',
                                    style: TextStyle(
                                      color: cs.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_outlined,
                                        size: 12,
                                        color: cs.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        _formatTime(
                                          match['match_date_local'],
                                          context,
                                        ),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: cs.onSurface.withValues(
                                            alpha: 0.65,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.stadium_outlined,
                                        size: 12,
                                        color: cs.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          stadium ?? 'To be announced',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: cs.onSurface.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Footer
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.black.withValues(alpha: 0.06),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mulai dari',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: cs.onSurface.withValues(alpha: 0.55),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs - 2),
                                Text(
                                  _formatPrice(match['min_ticket_price']),
                                  style: TextStyle(
                                    color: cs.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                final url = Uri.parse(
                                  'https://kitagaruda.id/id/ticket',
                                );
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.base,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Beli Tiket',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (_showScrollToTop)
          Positioned(
            bottom: 90,
            right: AppSpacing.base,
            child: FloatingActionButton.small(
              onPressed: _scrollToTop,
              tooltip: 'Kembali ke atas',
              child: const Icon(Icons.keyboard_arrow_up),
            ),
          ),
      ],
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'N/A';
    final number = (price as num).toInt().toString();
    return 'Rp ${number.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  String _formatTime(String? date, BuildContext context) {
    if (date == null || date.isEmpty) return '';

    try {
      final tz = context.read<TimezoneProvider>();
      final utc = DateTime.parse(date).toUtc();
      final local = tz.convert(utc);

      return '${_two(local.day)}/${_two(local.month)}/${local.year} '
          '${_two(local.hour)}:${_two(local.minute)} ${tz.label}';
    } catch (_) {
      return date;
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 56,
            color: Colors.black.withValues(alpha: 0.15),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Tiket Belum Tersedia',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
