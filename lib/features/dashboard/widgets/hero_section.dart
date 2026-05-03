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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final form = recentMatches.map((m) {
      final ind = m.indonesiaScore ?? 0;
      final opp = m.opponentScore ?? 0;
      if (ind > opp) return '\u2705';
      if (ind < opp) return '\u274c';
      return '\u2796';
    }).join();

    // Shadow ter-clip karena ListView tidak memberi ruang ekstra
    // di luar bounds child. Solusi: beri Padding(bottom) = blurRadius/2
    // agar shadow layer punya ruang render tanpa menggeser layout.
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // Layer 1 — ambient, soft dan lebar
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.45 : 0.22),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
            // Layer 2 — contact shadow, tajam tepat di bawah card
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.30 : 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
            // Layer 3 — red glow dari primary, hanya light mode
            if (!isDark)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.14),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        // ClipRRect HANYA di sini, TIDAK di Container luar
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image
              Image.network(
                heroImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) =>
                    Container(color: cs.surfaceContainerHighest),
              ),
              // Dark overlay
              Container(color: const Color(0x88000000)),
              // Bottom gradient merah
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.90),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
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
                        _HeroStatCard(
                          title: 'Form',
                          value: form.isEmpty ? '\u2014' : form,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _HeroStatCard(title: 'Kickoff', value: countdownLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
