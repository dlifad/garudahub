// lib/features/mini_games/penalty/widgets/penalty_result_overlay.dart
import 'package:flutter/material.dart';
import '../models/penalty_game_model.dart';

class PenaltyResultOverlay extends StatefulWidget {
  final ShotResult result;
  final int currentShot;
  final int totalShots;
  final VoidCallback onContinue;

  const PenaltyResultOverlay({
    super.key,
    required this.result,
    required this.currentShot,
    required this.totalShots,
    required this.onContinue,
  });

  @override
  State<PenaltyResultOverlay> createState() => _PenaltyResultOverlayState();
}

class _PenaltyResultOverlayState extends State<PenaltyResultOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  bool _isGoal = false;

  @override
  void initState() {
    super.initState();
    _isGoal = widget.result == ShotResult.goal;
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _scale = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = widget.currentShot >= widget.totalShots;
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.black.withOpacity(0.72),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Column(
                  children: [
                    Text(
                      _isGoal ? '⚽ GOOOL!' : '🧤 GAGAL!',
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: _isGoal ? const Color(0xFF4ADE80) : const Color(0xFFF87171),
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: (_isGoal ? const Color(0xFF22C55E) : const Color(0xFFEF4444)).withOpacity(0.6),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isGoal ? 'Tendangan Sempurna!' : 'Kiper Menyelamatkan!',
                      style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tendangan ${widget.currentShot} / ${widget.totalShots}',
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.45), letterSpacing: 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: widget.onContinue,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isGoal
                          ? [const Color(0xFF16A34A), const Color(0xFF15803D)]
                          : [const Color(0xFFDC2626), const Color(0xFFB91C1C)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: (_isGoal ? const Color(0xFF16A34A) : const Color(0xFFDC2626)).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    isLast ? 'Lihat Hasil' : 'Tendangan Berikutnya →',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
