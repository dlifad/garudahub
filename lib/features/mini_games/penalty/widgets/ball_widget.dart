// lib/features/mini_games/penalty/widgets/ball_widget.dart
import 'package:flutter/material.dart';
import '../models/penalty_game_model.dart';

class BallWidget extends StatefulWidget {
  final bool isShooting;
  final AimZone targetZone;
  final bool isGoal;
  final VoidCallback? onShootComplete;

  const BallWidget({
    super.key,
    required this.isShooting,
    required this.targetZone,
    this.isGoal = true,
    this.onShootComplete,
  });

  @override
  State<BallWidget> createState() => _BallWidgetState();
}

class _BallWidgetState extends State<BallWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _x;
  late Animation<double> _y;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    // Durasi sama dengan kiper (500ms) + sedikit lebih panjang agar kiper gerak dulu
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _resetAnims();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        widget.onShootComplete?.call();
      }
    });
  }

  void _resetAnims() {
    _x = Tween<double>(begin: 0, end: 0).animate(_ctrl);
    _y = Tween<double>(begin: 0, end: 0).animate(_ctrl);
    _scale = Tween<double>(begin: 1.0, end: 1.0).animate(_ctrl);
  }

  @override
  void didUpdateWidget(BallWidget old) {
    super.didUpdateWidget(old);
    if (widget.isShooting && !old.isShooting) {
      _startAnimation();
    } else if (!widget.isShooting && old.isShooting) {
      _ctrl.reset();
      setState(() => _resetAnims());
    }
  }

  void _startAnimation() {
    // Arah X berdasarkan zone tendangan (pixel absolut layar ~400px lebar)
    double endDx = 0;
    if (widget.targetZone == AimZone.left) endDx = -100;
    if (widget.targetZone == AimZone.right) endDx = 100;

    // Kalau GOL: bola sampai ke gawang (jauh, mengecil tapi masih terlihat)
    // Kalau SAVED: bola berhenti di tengah jalan sebelum gawang
    final double endDy = -480;
    final double endScale = 0.50; // tidak terlalu kecil

    // Delay 150ms agar kiper animasi gerak dulu
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _x = Tween<double>(begin: 0, end: endDx).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeInQuad),
        );
        _y = Tween<double>(begin: 0, end: endDy).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeInQuad),
        );
        _scale = Tween<double>(begin: 1.0, end: endScale).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeInQuad),
        );
      });
      _ctrl.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_x.value, _y.value),
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: const _BallPainterWidget(),
    );
  }
}

class _BallPainterWidget extends StatelessWidget {
  const _BallPainterWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 0.85,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFE0E0E0),
            Color(0xFFB0B0B0),
            Color(0xFF888888),
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(painter: _BallPanelPainter()),
    );
  }
}

class _BallPanelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final panelPaint = Paint()..color = const Color(0xFF111111);

    final p1 = Path()
      ..moveTo(cx, cy - 11)
      ..lineTo(cx + 5, cy - 6)
      ..lineTo(cx + 2, cy - 2)
      ..lineTo(cx - 2, cy - 2)
      ..lineTo(cx - 5, cy - 6)
      ..close();
    canvas.drawPath(p1, panelPaint);

    final p2 = Path()
      ..moveTo(cx + 8, cy + 3)
      ..lineTo(cx + 12, cy - 3)
      ..lineTo(cx + 6, cy - 5)
      ..lineTo(cx + 2, cy - 1)
      ..close();
    canvas.drawPath(p2, panelPaint);

    final p3 = Path()
      ..moveTo(cx - 8, cy + 5)
      ..lineTo(cx - 3, cy + 9)
      ..lineTo(cx + 1, cy + 6)
      ..lineTo(cx - 1, cy + 1)
      ..lineTo(cx - 6, cy + 1)
      ..close();
    canvas.drawPath(p3, panelPaint);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 5, cy - 7), width: 14, height: 9),
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withOpacity(0.85), Colors.transparent],
        ).createShader(
          Rect.fromCenter(
              center: Offset(cx - 5, cy - 7), width: 14, height: 9),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}