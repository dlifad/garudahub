import 'package:flutter/material.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:garudahub/features/dashboard/models/match_data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:garudahub/core/utils/flag_utils.dart';
import 'package:garudahub/core/providers/timezone_provider.dart';

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
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy, color: cs.onSurfaceVariant),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Belum ada pertandingan terjadwal',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    final tzProvider = context.watch<TimezoneProvider>();
    final localDate = tzProvider.convert(m.matchDateUtc);
    final dateLabel = DateFormat('EEE, d MMM yyyy', 'id_ID').format(localDate);
    final timeLabel = DateFormat('HH:mm').format(localDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC0000), Color(0xFFB00000)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC0000).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm - 2,
            ),
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
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        FlagUtils.getFlagUrl(m.homeFlag),
                        width: 28,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm - 2),
                    Expanded(
                      child: Text(
                        m.homeTeam,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                  const SizedBox(height: AppSpacing.xs - 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$timeLabel ${tzProvider.label}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        m.awayTeam,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm - 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        FlagUtils.getFlagUrl(m.awayFlag),
                        width: 28,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md - 2),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(dateLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 16, color: Colors.white24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.stadium, size: 14, color: Colors.white),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(m.venueName,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
