// lib/features/mini_games/penalty/screens/penalty_end_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/penalty_game_model.dart';

class PenaltyEndScreen extends StatefulWidget {
  final int goals;
  final int totalShots;
  final List<PenaltyShotRecord> shots;
  final VoidCallback onReplay;
  final VoidCallback onExit;

  const PenaltyEndScreen({
    super.key,
    required this.goals,
    required this.totalShots,
    required this.shots,
    required this.onReplay,
    required this.onExit,
  });

  @override
  State<PenaltyEndScreen> createState() => _PenaltyEndScreenState();
}

class _PenaltyEndScreenState extends State<PenaltyEndScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _entryScale;
  late Animation<double> _entryFade;
  final List<_Confetti> _confettis = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _entryScale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut));
    _entryFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    if (widget.goals >= 3) {
      _confettiCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
      for (int i = 0; i < 60; i++) _confettis.add(_Confetti(random: _random));
    } else {
      _confettiCtrl = AnimationController(vsync: this, duration: Duration.zero);
    }
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  String get _ratingTitle {
    final ratio = widget.goals / widget.totalShots;
    if (ratio >= 1.0) return '🏆 Legenda!';
    if (ratio >= 0.8) return '⭐ Luar Biasa!';
    if (ratio >= 0.6) return '👏 Bagus!';
    if (ratio >= 0.4) return '😅 Lumayan';
    return '😔 Latihan Lagi!';
  }

  Color get _ratingColor {
    final ratio = widget.goals / widget.totalShots;
    if (ratio >= 0.8) return const Color(0xFF4ADE80);
    if (ratio >= 0.6) return const Color(0xFFFBBF24);
    if (ratio >= 0.4) return const Color(0xFFFF9F43);
    return const Color(0xFFF87171);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B0E),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0D2B10), Color(0xFF061008)],
                ),
              ),
            ),
          ),
          if (widget.goals >= 3)
            AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (ctx, __) => CustomPaint(
                size: MediaQuery.of(ctx).size,
                painter: _ConfettiPainter(confettis: _confettis, progress: _confettiCtrl.value),
              ),
            ),
          FadeTransition(
            opacity: _entryFade,
            child: ScaleTransition(
              scale: _entryScale,
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      _ratingTitle,
                      style: TextStyle(
                        fontSize: 38, fontWeight: FontWeight.w900, color: _ratingColor,
                        letterSpacing: 1,
                        shadows: [Shadow(color: _ratingColor.withOpacity(0.5), blurRadius: 20)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Sesi Penalti Selesai',
                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), letterSpacing: 1.5)),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${widget.goals}',
                              style: TextStyle(
                                fontSize: 72, fontWeight: FontWeight.w900, color: _ratingColor, height: 1,
                                shadows: [Shadow(color: _ratingColor.withOpacity(0.4), blurRadius: 24)],
                              )),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(' / ${widget.totalShots}',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.45))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('GOL',
                        style: TextStyle(fontSize: 11, letterSpacing: 4, color: Colors.white.withOpacity(0.35), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.shots.map((s) {
                          final isGoal = s.result == ShotResult.goal;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isGoal ? const Color(0xFF16A34A) : const Color(0xFFB91C1C),
                                    boxShadow: [BoxShadow(
                                      color: (isGoal ? const Color(0xFF22C55E) : const Color(0xFFEF4444)).withOpacity(0.4),
                                      blurRadius: 10,
                                    )],
                                  ),
                                  child: Center(child: Text(isGoal ? '⚽' : '🧤', style: const TextStyle(fontSize: 16))),
                                ),
                                const SizedBox(height: 4),
                                Text('${s.shotNumber}', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4))),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      child: Row(
                        children: [
                          Expanded(child: _ActionButton(label: 'Ulangi', icon: Icons.replay_rounded, color: const Color(0xFF1D4ED8), onTap: widget.onReplay)),
                          const SizedBox(width: 12),
                          Expanded(child: _ActionButton(label: 'Keluar', icon: Icons.exit_to_app_rounded, color: const Color(0xFF374151), onTap: widget.onExit)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _Confetti {
  final double x, speed, size, initialY, swayAmplitude, swayFreq;
  final Color color;
  _Confetti({required Random random})
      : x = random.nextDouble(),
        speed = 0.15 + random.nextDouble() * 0.35,
        size = 6 + random.nextDouble() * 8,
        color = [const Color(0xFFFCD34D), const Color(0xFF4ADE80), const Color(0xFF60A5FA),
                 const Color(0xFFF472B6), const Color(0xFFA78BFA), const Color(0xFFFB923C)][random.nextInt(6)],
        initialY = -random.nextDouble(),
        swayAmplitude = 0.02 + random.nextDouble() * 0.03,
        swayFreq = 1 + random.nextDouble() * 3;
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> confettis;
  final double progress;
  const _ConfettiPainter({required this.confettis, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in confettis) {
      final t = ((c.initialY + progress * c.speed * 3) % 1.2);
      if (t < 0) continue;
      final y = t * size.height;
      final x = (c.x + c.swayAmplitude * sin(progress * c.swayFreq * 6.28)) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: c.size, height: c.size * 0.5), const Radius.circular(2)),
        Paint()..color = c.color.withOpacity(0.85),
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
