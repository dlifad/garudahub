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
      backgroundColor: AppColors.softBackground(cs, isDark: isDark),
      appBar: AppBar(
        backgroundColor: AppColors.softBackground(cs, isDark: isDark),
        elevation: 0,
        title: Text('Mini Games',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: cs.onSurface)),
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Game',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.8), letterSpacing: 2, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _GameCard(
              title: 'Adu Penalti',
              subtitle: 'Tendang bola pakai gyro HP!\n5 tendangan, siapa yang menang?',
              emoji: '⚽',
              gradientColors: [const Color(0xFF15803D), const Color(0xFF166534)],
              glowColor: const Color(0xFF22C55E),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => PenaltyProvider(),
                    child: const PenaltyGameScreen(),
                  ),
                ));
              },
            ),
            const SizedBox(height: 14),
            _GameCard(
              title: 'Coming Soon',
              subtitle: 'Game seru lainnya\nsedang dalam pengembangan...',
              emoji: '🔒',
              gradientColors: [const Color(0xFF1F2937), const Color(0xFF111827)],
              glowColor: Colors.transparent,
              onTap: null,
              disabled: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title, subtitle, emoji;
  final List<Color> gradientColors;
  final Color glowColor;
  final VoidCallback? onTap;
  final bool disabled;

  const _GameCard({
    required this.title, required this.subtitle, required this.emoji,
    required this.gradientColors, required this.glowColor,
    this.onTap, this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.45 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
            borderRadius: BorderRadius.circular(18),
            boxShadow: disabled ? [] : [BoxShadow(color: glowColor.withOpacity(0.28), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              Container(
                width: 62, height: 62,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.62), fontSize: 12, height: 1.5)),
                  ],
                ),
              ),
              if (!disabled) Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.55), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
