import 'package:flutter/material.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:garudahub/features/dashboard/models/match_data.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.fifaRank,
    required this.heroImageUrl,
    required this.recentMatches,
    required this.countdownLabel,
  });

  final int fifaRank;
  final String heroImageUrl;
  final List<MatchData> recentMatches;
  final String countdownLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final form = recentMatches.map((m) {
      final ind = m.indonesiaScore ?? 0;
      final opp = m.opponentScore ?? 0;
      if (ind > opp) return '✅';
      if (ind < opp) return '❌';
      return '➖';
    }).join();

    return Container(
      height: 200,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Image.network(
            heroImageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) =>
                Container(color: cs.surfaceContainerHighest),
          ),
          Container(color: const Color(0x99000000)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [cs.primary.withOpacity(0.85), Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm - 2,
                      ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text(
                    'Satu Jiwa, Satu Bangsa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _HeroStatCard(title: 'FIFA', value: 'Rank #$fifaRank'),
                    const SizedBox(width: AppSpacing.sm),
                    _HeroStatCard(title: 'Form', value: form.isEmpty ? '—' : form),
                    const SizedBox(width: AppSpacing.sm),
                    _HeroStatCard(title: 'Kickoff', value: countdownLabel),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  const _HeroStatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: AppSpacing.xs - 2),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
