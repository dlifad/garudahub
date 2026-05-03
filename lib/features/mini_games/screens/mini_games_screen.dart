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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.base,
          ),
          children: [
            // ── Header (sama persis dengan PredictionScreen) ───
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mini Games',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Section label ───────────────────────────────
            Text(
              'Pilih Game',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Uji kemampuan & prediksimu bersama Timnas',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            // ── Adu Penalti ────────────────────────────────
            _GameCard(
              title: 'Adu Penalti',
              subtitle: 'Tendang bola pakai gyro HP!\n5 tendangan, siapa yang menang?',
              icon: '⚽',
              tag: 'MAIN SEKARANG',
              tagColor: AppColors.success,
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

            const SizedBox(height: 10),

            // ── Coming Soon ────────────────────────────────
            _GameCard(
              title: 'Coming Soon',
              subtitle: 'Game seru lainnya\nsedang dalam pengembangan...',
              icon: '🔒',
              tag: 'SEGERA HADIR',
              tagColor: cs.onSurfaceVariant,
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
  final String icon;
  final String tag;
  final Color tagColor;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool disabled;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tag,
    required this.tagColor,
    required this.accentColor,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outline.withOpacity(0.12)),
            boxShadow: disabled
                ? []
                : [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Icon ─────────────────────────────────
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: disabled
                      ? cs.surfaceContainerHighest
                      : accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: disabled
                        ? cs.outlineVariant
                        : accentColor.withOpacity(0.15),
                  ),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // ── Text ─────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ── Tag (mirip summary banner Prediction) ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: tagColor.withOpacity(0.20),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: tagColor,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Arrow ─────────────────────────────────
              if (!disabled) ...[  
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
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
      ),
    );
  }
}
