// lib/features/mini_games/penalty/widgets/goalkeeper_widget.dart
import 'package:flutter/material.dart';
import '../models/penalty_game_model.dart';

class GoalkeeperWidget extends StatefulWidget {
  final AimZone? diveZone;
  final bool isDiving;

  const GoalkeeperWidget({super.key, this.diveZone, this.isDiving = false});

  @override
  State<GoalkeeperWidget> createState() => _GoalkeeperWidgetState();
}

class _GoalkeeperWidgetState extends State<GoalkeeperWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _diveX;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _diveX = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(GoalkeeperWidget old) {
    super.didUpdateWidget(old);
    if (widget.isDiving && widget.diveZone != null) {
      double target = 0;
      if (widget.diveZone == AimZone.left) target = -50;
      if (widget.diveZone == AimZone.right) target = 50;
      _diveX = Tween<double>(begin: 0, end: target).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      );
      _ctrl.forward(from: 0);
    } else if (!widget.isDiving) {
      _ctrl.reverse();
    }
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
      builder: (_, __) => Transform.translate(
        offset: Offset(_diveX.value, 0),
        child: const _KeeperSVG(),
      ),
    );
  }
}

class _KeeperSVG extends StatelessWidget {
  const _KeeperSVG();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 100,
      child: CustomPaint(painter: _KeeperPainter()),
    );
  }
}

class _KeeperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bayangan bawah
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h - 4), width: w * 0.9, height: 10),
      Paint()..color = Colors.black.withOpacity(0.35),
    );

    // Sepatu
    _drawShoe(canvas, Offset(w * 0.22, h - 8), false);
    _drawShoe(canvas, Offset(w * 0.62, h - 8), true);

    // Celana
    _drawRect(canvas, Offset(w * 0.17, h * 0.68), 18, 26, const Color(0xFF1E40AF));
    _drawRect(canvas, Offset(w * 0.55, h * 0.68), 18, 26, const Color(0xFF1E40AF));

    // Jersey
    _drawJersey(canvas, Offset(w / 2, h * 0.55), w, h);

    // Lengan + sarung tangan
    _drawArm(canvas, Offset(w * 0.04, h * 0.38), false);
    _drawArm(canvas, Offset(w * 0.7, h * 0.38), true);

    // Kepala
    _drawHead(canvas, Offset(w / 2, h * 0.2), w);
  }

  void _drawShoe(Canvas canvas, Offset pos, bool flip) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos, width: 20, height: 10),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );
  }

  void _drawRect(Canvas canvas, Offset pos, double w, double h, Color c) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx, pos.dy, w, h), const Radius.circular(5)),
      Paint()..color = c,
    );
  }

  void _drawJersey(Canvas canvas, Offset center, double w, double h) {
    final jerseyPath = Path()
      ..moveTo(w * 0.12, h * 0.36)
      ..lineTo(w * 0.09, h * 0.72)
      ..quadraticBezierTo(w / 2, h * 0.78, w * 0.91, h * 0.72)
      ..lineTo(w * 0.88, h * 0.36)
      ..quadraticBezierTo(w / 2, h * 0.3, w * 0.12, h * 0.36)
      ..close();

    canvas.drawPath(
      jerseyPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFFCD34D), const Color(0xFFD97706)],
        ).createShader(Rect.fromLTWH(0, h * 0.3, w, h * 0.5)),
    );

    final tp = TextPainter(
      text: const TextSpan(
        text: '1',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - 5, h * 0.5));

    final badgePaint = Paint()..color = Colors.white.withOpacity(0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.16, h * 0.4, 18, 10), const Radius.circular(2)),
      badgePaint,
    );
    final ghPainter = TextPainter(
      text: const TextSpan(
        text: 'GH',
        style: TextStyle(fontSize: 6, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    ghPainter.paint(canvas, Offset(w * 0.17, h * 0.41));
  }

  void _drawArm(Canvas canvas, Offset pos, bool isRight) {
    final armPath = Path()
      ..moveTo(pos.dx, pos.dy)
      ..lineTo(pos.dx + (isRight ? 12 : -12), pos.dy + 16)
      ..lineTo(pos.dx + (isRight ? 18 : -18), pos.dy + 14)
      ..lineTo(pos.dx + 6, pos.dy)
      ..close();

    canvas.drawPath(
      armPath,
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFFFCD34D), const Color(0xFFD97706)],
        ).createShader(Rect.fromLTWH(pos.dx - 20, pos.dy, 40, 20)),
    );

    final gloveCenter = Offset(pos.dx + (isRight ? 18 : -14), pos.dy + 20);
    canvas.drawOval(
      Rect.fromCenter(center: gloveCenter, width: 18, height: 16),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFFEF3C7), const Color(0xFFFBBF24)],
        ).createShader(Rect.fromCenter(center: gloveCenter, width: 18, height: 16)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: gloveCenter, width: 18, height: 16),
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    for (int i = 0; i < 3; i++) {
      final fy = gloveCenter.dy - 4 + (i * 4.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(gloveCenter.dx - (isRight ? 9 : 2), fy, 10, 3.5),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFFFEF3C7),
      );
    }
  }

  void _drawHead(Canvas canvas, Offset center, double w) {
    final facePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [const Color(0xFFF5C89A), const Color(0xFFD4864A)],
      ).createShader(Rect.fromCenter(center: center, width: 36, height: 36));

    // Leher
    canvas.drawRect(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 14), width: 14, height: 12),
      facePaint,
    );

    // Telinga
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - 18, center.dy + 2), width: 8, height: 10), facePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + 18, center.dy + 2), width: 8, height: 10), facePaint);

    // Wajah
    canvas.drawOval(Rect.fromCenter(center: center, width: 34, height: 34), facePaint);

    // Rambut
    final hairPath = Path()
      ..moveTo(center.dx - 17, center.dy - 6)
      ..quadraticBezierTo(center.dx, center.dy - 22, center.dx + 17, center.dy - 6)
      ..quadraticBezierTo(center.dx + 19, center.dy - 2, center.dx + 17, center.dy)
      ..quadraticBezierTo(center.dx, center.dy - 12, center.dx - 17, center.dy)
      ..close();
    canvas.drawPath(hairPath, Paint()..color = const Color(0xFF1A0A00));

    // Ikat kepala merah Garuda
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - 17, center.dy - 4)
        ..quadraticBezierTo(center.dx, center.dy - 18, center.dx + 17, center.dy - 4)
        ..lineTo(center.dx + 17, center.dy - 1)
        ..quadraticBezierTo(center.dx, center.dy - 15, center.dx - 17, center.dy - 1)
        ..close(),
      Paint()..color = const Color(0xFFE8003D),
    );

    // Alis
    final browPaint = Paint()
      ..color = const Color(0xFF1A0A00)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(Path()..moveTo(center.dx - 12, center.dy - 3)..quadraticBezierTo(center.dx - 8, center.dy - 6, center.dx - 4, center.dy - 3), browPaint);
    canvas.drawPath(Path()..moveTo(center.dx + 4, center.dy - 3)..quadraticBezierTo(center.dx + 8, center.dy - 6, center.dx + 12, center.dy - 3), browPaint);

    // Mata kiri
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - 8, center.dy + 2), width: 7, height: 7.5), Paint()..color = Colors.white);
    canvas.drawCircle(Offset(center.dx - 8, center.dy + 2.5), 2.5, Paint()..color = const Color(0xFF3B2506));
    canvas.drawCircle(Offset(center.dx - 9, center.dy + 1.5), 0.8, Paint()..color = Colors.white);

    // Mata kanan
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + 8, center.dy + 2), width: 7, height: 7.5), Paint()..color = Colors.white);
    canvas.drawCircle(Offset(center.dx + 8, center.dy + 2.5), 2.5, Paint()..color = const Color(0xFF3B2506));
    canvas.drawCircle(Offset(center.dx + 7, center.dy + 1.5), 0.8, Paint()..color = Colors.white);

    // Hidung
    canvas.drawPath(
      Path()..moveTo(center.dx - 2, center.dy + 4)..quadraticBezierTo(center.dx, center.dy + 8, center.dx + 2, center.dy + 4),
      Paint()..color = const Color(0xFFC0733A)..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );

    // Senyum
    canvas.drawPath(
      Path()..moveTo(center.dx - 8, center.dy + 10)..quadraticBezierTo(center.dx, center.dy + 15, center.dx + 8, center.dy + 10),
      Paint()..color = const Color(0xFFA05A2C)..strokeWidth = 1.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
