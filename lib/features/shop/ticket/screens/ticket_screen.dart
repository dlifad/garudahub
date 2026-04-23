import 'package:flutter/material.dart';
import 'package:garudahub/core/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:garudahub/features/shop/ticket/services/ticket_service.dart';

class TicketScreen extends StatefulWidget {
  final String query;
  const TicketScreen({super.key, required this.query});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late Future<List<dynamic>> tickets;

  @override
  void initState() {
    super.initState();
    tickets = TicketService.getTickets();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppConstants.baseUrl.replaceAll('/api', '');

    return FutureBuilder<List<dynamic>>(
      future: tickets,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Terjadi kesalahan"));
        }

        final rawData = snapshot.data ?? [];

        final q = widget.query.toLowerCase().trim();

        final data = q.isEmpty
            ? rawData
            : rawData.where((match) {
                final home = (match['home_team'] ?? '').toLowerCase();
                final away = (match['away_team'] ?? '').toLowerCase();
                final tournament = (match['tournament_name'] ?? '').toLowerCase();
                final stadium = (match['stadium']?['name'] ?? '').toLowerCase();

                return home.contains(q) ||
                      away.contains(q) ||
                      tournament.contains(q) ||
                      stadium.contains(q);
              }).toList();

        if (rawData.isEmpty) {
          return _emptyState();
        }

        if (data.isEmpty) {
          return const Center(
            child: Text(
              'Tiket tidak ditemukan',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final match = data[index];
            final logo = match['tournament_logo'];
            final stadium = match['stadium']?['name'];

            return GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── HEADER: Tournament badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          match['tournament_name'] ?? '-',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // ── BODY
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 🔹 LOGO
                          Container(
                            width: 64,
                            height: 64,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: logo != null
                                ? Image.network(
                                    '$base$logo',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image,
                                        color: Colors.black54,
                                        size: 28),
                                  )
                                : const Icon(Icons.emoji_events,
                                    color: Colors.black54, size: 28),
                          ),

                          const SizedBox(width: 14),

                          // 🔹 INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Teams
                                Text(
                                  "${match['home_team']} vs ${match['away_team']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Date row
                                Row(
                                  children: [
                                    Icon(Icons.schedule_outlined,
                                        size: 12,
                                        color:
                                            Colors.white.withOpacity(0.5)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatWIB(match['match_date_local']),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.65),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                // Stadium row
                                Row(
                                  children: [
                                    Icon(Icons.stadium_outlined,
                                        size: 12,
                                        color:
                                            Colors.white.withOpacity(0.5)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        stadium ?? "To be announced",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              Colors.white.withOpacity(0.5),
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

                    // ── FOOTER: Divider + Price + CTA
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mulai dari",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.45),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatPrice(match['min_ticket_price']),
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          // CTA Button
                          GestureDetector(
                            onTap: () async {
                              final url = Uri.parse("https://kitagaruda.id/id/ticket");

                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Beli Tiket",
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
        );
      },
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return "N/A";
    final number = price.toString();
    return "Rp ${number.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}";
  }

  String _formatWIB(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final dt = DateTime.parse(date).toLocal();
      return "${_two(dt.day)}/${_two(dt.month)}/${dt.year} "
          "${_two(dt.hour)}:${_two(dt.minute)} WIB";
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
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Tiket Belum Tersedia',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}