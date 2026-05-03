// lib/features/mini_games/penalty/widgets/field_painter.dart
import 'package:flutter/material.dart';

/// Custom painter lapangan + garis perspektif
class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stripe lapangan hijau
    final stripes = [
      const Color(0xFF1A5C28),
      const Color(0xFF1E6B30),
    ];
    final stripeH = 24.0;
    for (double y = 0; y < h; y += stripeH) {
      final idx = ((y / stripeH).floor()) % 2;
      canvas.drawRect(
        Rect.fromLTWH(0, y, w, stripeH),
        Paint()..color = stripes[idx],
      );
    }

    // Overlay perspektif (atas gelap jauh, bawah terang dekat)
    final perspGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.55),
        Colors.black.withOpacity(0.28),
        Colors.black.withOpacity(0.05),
        Colors.transparent,
        Colors.black.withOpacity(0.08),
      ],
      stops: const [0.0, 0.18, 0.42, 0.62, 1.0],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..shader = perspGrad.createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Lampu stadion dari atas
    final lightPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.0,
        colors: [
          const Color(0xFFFFE678).withOpacity(0.13),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.5));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.5), lightPaint);

    // Garis lapangan perspektif
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final horizonY = h * 0.34;

    // Garis horizon
    canvas.drawLine(Offset(0, horizonY), Offset(w, horizonY), linePaint);

    // Kotak penalti besar (trapezoid)
    final penBoxPath = Path()
      ..moveTo(w * 0.14, horizonY)
      ..lineTo(w * 0.86, horizonY)
      ..lineTo(w * 0.92, h * 0.52)
      ..lineTo(w * 0.08, h * 0.52)
      ..close();
    canvas.drawPath(penBoxPath, linePaint..color = Colors.white.withOpacity(0.28));

    // Kotak 6-yard
    final sixYardPath = Path()
      ..moveTo(w * 0.31, horizonY)
      ..lineTo(w * 0.69, horizonY)
      ..lineTo(w * 0.72, h * 0.43)
      ..lineTo(w * 0.28, h * 0.43)
      ..close();
    canvas.drawPath(sixYardPath, linePaint..color = Colors.white.withOpacity(0.22));

    // Busur penalti
    final arcPath = Path();
    arcPath.moveTo(w * 0.34, h * 0.52);
    arcPath.quadraticBezierTo(w * 0.5, h * 0.63, w * 0.66, h * 0.52);
    canvas.drawPath(arcPath, linePaint..color = Colors.white.withOpacity(0.22));

    // Garis tengah lapangan
    canvas.drawLine(
      Offset(0, h * 0.74),
      Offset(w, h * 0.74),
      linePaint..color = Colors.white.withOpacity(0.2),
    );

    // Lingkaran tengah (elips)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.74), width: w * 0.35, height: h * 0.09),
      linePaint..color = Colors.white.withOpacity(0.18),
    );

    // Titik tengah
    canvas.drawCircle(
      Offset(w / 2, h * 0.74),
      3,
      Paint()..color = Colors.white.withOpacity(0.35),
    );

    // Tepi lapangan kiri & kanan
    canvas.drawLine(Offset(w * 0.04, horizonY), Offset(0, h), linePaint..color = Colors.white.withOpacity(0.18));
    canvas.drawLine(Offset(w * 0.96, horizonY), Offset(w, h), linePaint..color = Colors.white.withOpacity(0.18));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
