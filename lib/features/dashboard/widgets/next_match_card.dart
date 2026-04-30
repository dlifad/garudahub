import 'package:flutter/material.dart';
import 'package:garudahub/features/dashboard/models/match_data.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class NextMatchCard extends StatelessWidget {
  const NextMatchCard({
    super.key,
    required this.isLoading,
    required this.match,
  });

  final bool isLoading;
  final MatchData? match;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: cs.surfaceContainerHighest,
        highlightColor: cs.surface,
        child: Container(
          height: 165,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    final m = match;
    if (m == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy, color: cs.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              'Belum ada pertandingan terjadwal',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    final localDate = m.matchDateUtc.toLocal();
    final dateLabel = DateFormat('EEE, d MMM yyyy', 'id_ID').format(localDate);
    final timeLabel = DateFormat('HH:mm').format(localDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC0000), Color(0xFFB00000)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4DDC0000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${m.tournamentName} • ${m.round}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _teamText('${m.homeFlag} ${m.homeTeam}', true)),
              Column(
                children: [
                  const Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$timeLabel WIB',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
              Expanded(child: _teamText('${m.awayFlag} ${m.awayTeam}', false)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '📅 $dateLabel',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              Container(width: 1, height: 16, color: Colors.white24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '📍 ${m.venueName}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamText(String text, bool left) {
    return Align(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}
