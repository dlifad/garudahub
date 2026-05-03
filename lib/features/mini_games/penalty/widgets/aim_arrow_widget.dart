// lib/features/mini_games/penalty/widgets/aim_arrow_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/penalty_game_model.dart';

class AimArrowWidget extends StatefulWidget {
  final AimZone currentZone;
  final bool isActive;

  const AimArrowWidget({
    super.key,
    required this.currentZone,
    required this.isActive,
  });

  @override
  State<AimArrowWidget> createState() => _AimArrowWidgetState();
}

class _AimArrowWidgetState extends State<AimArrowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  StreamSubscription? _accelSub;
  double _tiltX = 0.0;

  static const double _maxTilt = 9.0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.12)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _startAccel();
  }

  void _startAccel() {
    _accelSub?.cancel();
    _accelSub = accelerometerEventStream().listen((event) {
      if (!widget.isActive) return;
      final clamped = event.x.clamp(-_maxTilt, _maxTilt);
      setState(() => _tiltX = clamped / _maxTilt);
    });
  }

  @override
  void didUpdateWidget(AimArrowWidget old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) _startAccel();
    if (!widget.isActive) {
      _accelSub?.cancel();
      setState(() => _tiltX = 0);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _accelSub?.cancel();
    super.dispose();
  }

  Color get _zoneColor {
    switch (widget.currentZone) {
      case AimZone.left:
        return const Color(0xFF60A5FA);
      case AimZone.right:
        return const Color(0xFF34D399);
      case AimZone.center:
        return const Color(0xFFFBBF24);
    }
  }

  String get _zoneLabel {
    switch (widget.currentZone) {
      case AimZone.left:
        return 'KIRI';
      case AimZone.right:
        return 'KANAN';
      case AimZone.center:
        return 'TENGAH';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulse,
          child: CustomPaint(
            size: const Size(80, 80),
            painter: _ArrowPainter(tiltX: _tiltX, color: _zoneColor),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _zoneColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _zoneColor.withOpacity(0.55), width: 1.2),
          ),
          child: Text(
            _zoneLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _zoneColor,
              letterSpacing: 2.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Miringkan HP untuk arahkan',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.55),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final double tiltX;
  final Color color;

  const _ArrowPainter({required this.tiltX, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final angle = tiltX * 0.7;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    canvas.drawCircle(
      Offset.zero,
      30,
      Paint()
        ..color = color.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    final arrowPaint = Paint()..color = color..style = PaintingStyle.fill;
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.45)..style = PaintingStyle.fill;

    final head = Path()
      ..moveTo(0, -30)..lineTo(14, -10)..lineTo(-14, -10)..close();
    final shaft = Path()
      ..moveTo(-6, -12)..lineTo(6, -12)..lineTo(6, 14)
      ..lineTo(12, 14)..lineTo(0, 26)..lineTo(-12, 14)..lineTo(-6, 14)..close();

    canvas.save();
    canvas.translate(2, 3);
    canvas.drawPath(head, shadowPaint);
    canvas.drawPath(shaft, shadowPaint);
    canvas.restore();

    canvas.drawPath(head, arrowPaint);
    canvas.drawPath(shaft, arrowPaint);
    canvas.drawPath(
      head,
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.tiltX != tiltX || old.color != color;
}
