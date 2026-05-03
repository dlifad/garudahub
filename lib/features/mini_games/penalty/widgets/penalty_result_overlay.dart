// lib/features/mini_games/penalty/widgets/penalty_result_overlay.dart
import 'dart:math';
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
    with TickerProviderStateMixin {
  late AnimationController _textCtrl;
  late AnimationController _confettiCtrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _dropY;
  late Animation<double> _dropFade;
  bool _isGoal = false;
  final List<_Confetti> _confettis = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _isGoal = widget.result == ShotResult.goal;

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.elasticOut));
    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    // Teks GOOOL! jatuh dari atas (-120px → 0) dengan bounce
    _dropY = Tween<double>(
      begin: -120,
      end: 0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.bounceOut));
    _dropFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    if (_isGoal) {
      for (int i = 0; i < 55; i++) {
        _confettis.add(_Confetti(random: _random));
      }
      _confettiCtrl.repeat();
    }

    _textCtrl.forward();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = widget.currentShot >= widget.totalShots;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background gelap
        FadeTransition(
          opacity: _fade,
          child: Container(color: Colors.black.withOpacity(0.72)),
        ),

        // Confetti burst (hanya gol)
        if (_isGoal)
          AnimatedBuilder(
            animation: _confettiCtrl,
            builder: (ctx, __) => CustomPaint(
              size: size,
              painter: _ConfettiPainter(
                confettis: _confettis,
                progress: _confettiCtrl.value,
              ),
            ),
          ),

        // Konten utama
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Teks: GOL drop dari atas, GAGAL scale biasa
              AnimatedBuilder(
                animation: _textCtrl,
                builder: (ctx, child) {
                  if (_isGoal) {
                    return Transform.translate(
                      offset: Offset(0, _dropY.value),
                      child: Opacity(
                        opacity: _dropFade.value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  } else {
                    return ScaleTransition(
                      scale: _scale,
                      child: FadeTransition(opacity: _fade, child: child),
                    );
                  }
                },
                child: Column(
                  children: [
                    Text(
                      _isGoal ? '⚽ GOOOL!' : '🧤 GAGAL!',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: _isGoal
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFF87171),
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color:
                                (_isGoal
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFFEF4444))
                                    .withOpacity(0.7),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isGoal ? 'Tendangan Sempurna!' : 'Kiper Menyelamatkan!',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tendangan ${widget.currentShot} / ${widget.totalShots}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.45),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              FadeTransition(
                opacity: _fade,
                child: GestureDetector(
                  onTap: widget.onContinue,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isGoal
                            ? [const Color(0xFF16A34A), const Color(0xFF15803D)]
                            : [
                                const Color(0xFFDC2626),
                                const Color(0xFFB91C1C),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isGoal
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626))
                                  .withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      isLast ? 'Lihat Hasil' : 'Tendangan Berikutnya →',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Confetti {
  final double x, speed, size, initialY, swayAmplitude, swayFreq;
  final Color color;

  _Confetti({required Random random})
    : x = random.nextDouble(),
      speed = 0.3 + random.nextDouble() * 0.5,
      size = 7 + random.nextDouble() * 9,
      initialY = -0.05 - random.nextDouble() * 0.2,
      swayAmplitude = 0.02 + random.nextDouble() * 0.03,
      swayFreq = 1 + random.nextDouble() * 3,
      color = [
        const Color(0xFFFCD34D),
        const Color(0xFF4ADE80),
        const Color(0xFF60A5FA),
        const Color(0xFFF472B6),
        const Color(0xFFA78BFA),
        const Color(0xFFFB923C),
        const Color(0xFFFFFFFF),
      ][random.nextInt(7)];
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> confettis;
  final double progress;

  const _ConfettiPainter({required this.confettis, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in confettis) {
      final t = (c.initialY + progress * c.speed * 1.4).clamp(0.0, 1.5);
      final y = t * size.height;
      final x =
          (c.x + c.swayAmplitude * sin(progress * c.swayFreq * pi * 2)) *
          size.width;
      final opacity = (1.0 - (t / 1.4)).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * c.swayFreq * pi);
      final tp = TextPainter(
        text: TextSpan(
          text: 'GOOOL',
          style: TextStyle(
            fontSize: c.size * 1.1,
            fontWeight: FontWeight.w900,
            color: c.color.withOpacity(opacity * 0.9),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
