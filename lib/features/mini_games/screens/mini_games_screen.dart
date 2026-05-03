// lib/features/mini_games/screens/mini_games_screen.dart
import 'package:flutter/material.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../penalty/providers/penalty_provider.dart';
import '../penalty/screens/penalty_game_screen.dart';

class MiniGamesScreen extends StatelessWidget {
  const MiniGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Games'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header section ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ayo Bermain!',
                          style: TextStyle(
                            color: AppColors.textOnRed,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Uji kemampuan & prediksimu\nbersama Timnas Indonesia',
                          style: TextStyle(
                            color: AppColors.textOnRed.withOpacity(0.75),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('🏆', style: TextStyle(fontSize: 42)),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Section label ──────────────────────────────────
            Text(
              'PILIH GAME',
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Adu Penalti card ───────────────────────────────
            _GameCard(
              title: 'Adu Penalti',
              subtitle: 'Tendang bola pakai gyro HP!\n5 tendangan, siapa yang menang?',
              tag: 'MAIN SEKARANG',
              tagColor: AppColors.success,
              icon: '⚽',
              accentColor: AppColors.primary,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => PenaltyProvider(),
                    child: const PenaltyGameScreen(),
                  ),
                ));
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Coming Soon card ───────────────────────────────
            _GameCard(
              title: 'Coming Soon',
              subtitle: 'Game seru lainnya\nsedang dalam pengembangan...',
              tag: 'SEGERA HADIR',
              tagColor: cs.onSurfaceVariant,
              icon: '🔒',
              accentColor: cs.onSurfaceVariant,
              onTap: null,
              disabled: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ── _GameCard ──────────────────────────────────────────────────────────────────
class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final String icon;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool disabled;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.icon,
    required this.accentColor,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            boxShadow: disabled
                ? []
                : [
                    BoxShadow(
                      color: accentColor.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Accent top bar ────────────────────────────
                Container(
                  height: 3,
                  color: disabled ? cs.outlineVariant : accentColor,
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Icon box ──────────────────────────
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: disabled
                              ? cs.surfaceContainerHighest
                              : accentColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: disabled
                                ? cs.outlineVariant
                                : accentColor.withOpacity(0.18),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // ── Text content ──────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      color: cs.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // ── Tag badge ─────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: tagColor.withOpacity(0.10),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                                border: Border.all(
                                  color: tagColor.withOpacity(0.25),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: tagColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Arrow ────────────────────────────
                      if (!disabled) ...[  
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.08),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: accentColor,
                            size: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
