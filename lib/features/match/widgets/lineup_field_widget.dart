import 'package:flutter/material.dart';
import 'package:garudahub/features/match/models/lineup_player.dart';

// Position name → relative (x, y) on field.
// y=0 = top (GK side), y=1 = bottom (FW side).
// We invert y for painting so GK is at bottom of the widget.
const Map<String, Offset> _posMap = {
  'GK':  Offset(0.50, 0.06),
  'LB':  Offset(0.12, 0.22), 'RB':  Offset(0.88, 0.22),
  'CB':  Offset(0.50, 0.22), 'LCB': Offset(0.30, 0.22), 'RCB': Offset(0.70, 0.22),
  'LWB': Offset(0.10, 0.40), 'RWB': Offset(0.90, 0.40),
  'DM':  Offset(0.50, 0.40), 'CDM': Offset(0.50, 0.40),
  'CM':  Offset(0.50, 0.55), 'LM':  Offset(0.18, 0.55), 'RM': Offset(0.82, 0.55),
  'CAM': Offset(0.50, 0.68),
  'LW':  Offset(0.14, 0.78), 'RW':  Offset(0.86, 0.78),
  'SS':  Offset(0.50, 0.72), 'CF':  Offset(0.50, 0.84),
  'ST':  Offset(0.50, 0.84), 'FWD': Offset(0.50, 0.84),
  'DEF': Offset(0.50, 0.22), 'MID': Offset(0.50, 0.55),
};

class LineupFieldWidget extends StatelessWidget {
  const LineupFieldWidget({
    super.key,
    required this.players,
    required this.formation,
  });

  final List<LineupPlayer> players;
  final String? formation;

  List<int> _parseFormation(String? f) {
    if (f == null || f.isEmpty) return [4, 3, 3];
    try { return f.split('-').map(int.parse).toList(); }
    catch (_) { return [4, 3, 3]; }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.60,
      child: LayoutBuilder(builder: (_, box) {
        final W = box.maxWidth;
        final H = box.maxHeight;
        final dots = _buildDots(W, H);
        return Stack(children: [
          CustomPaint(size: Size(W, H), painter: _FieldPainter()),
          ...dots,
        ]);
      }),
    );
  }

  List<Widget> _buildDots(double W, double H) {
    const dotW = 48.0;
    const dotH = 60.0;

    // Group players by position key
    final grouped = <String, List<LineupPlayer>>{};
    final unpos   = <LineupPlayer>[];
    for (final p in players) {
      final pos = (p.position ?? '').toUpperCase();
      if (_posMap.containsKey(pos)) {
        grouped.putIfAbsent(pos, () => []).add(p);
      } else {
        unpos.add(p);
      }
    }

    final result = <Widget>[];

    // Positioned players
    for (final entry in grouped.entries) {
      final base   = _posMap[entry.key]!;
      final list   = entry.value;
      final n      = list.length;
      for (int i = 0; i < n; i++) {
        final spreadX = n == 1 ? 0.0 : (i - (n - 1) / 2.0) * 0.18;
        final fx = (base.dx + spreadX).clamp(0.06, 0.94);
        final fy = base.dy;
        final left = (fx * W - dotW / 2).clamp(0.0, W - dotW);
        final top  = (fy * H - dotH / 2).clamp(0.0, H - dotH);
        result.add(Positioned(
            left: left, top: top,
            child: _PlayerDot(player: list[i])));
      }
    }

    // Auto-layout for unpositioned players using formation rows
    if (unpos.isNotEmpty) {
      final rows  = [1, ..._parseFormation(formation)]; // [1 GK, ...rest]
      final total = rows.fold(0, (a, b) => a + b);
      int idx     = 0;
      for (int r = 0; r < rows.length && idx < unpos.length; r++) {
        final count = rows[r];
        final fy    = (r + 0.5) / rows.length;
        for (int c = 0; c < count && idx < unpos.length; c++) {
          final fx   = (c + 1.0) / (count + 1.0);
          final left = (fx * W - dotW / 2).clamp(0.0, W - dotW);
          final top  = (fy * H - dotH / 2).clamp(0.0, H - dotH);
          result.add(Positioned(
              left: left, top: top,
              child: _PlayerDot(player: unpos[idx])));
          idx++;
        }
      }
    }

    return result;
  }
}

// ── Field painter ─────────────────────────────────────────────────────────
class _FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final W = s.width;
    final H = s.height;

    // Grass stripes
    for (int i = 0; i < 9; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * H / 9, W, H / 9),
        Paint()..color = i.isEven ? const Color(0xFF2D8C2D) : const Color(0xFF288528),
      );
    }

    final lp = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Outer boundary
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(5, 5, W - 10, H - 10), const Radius.circular(3)), lp);

    // Halfway line
    canvas.drawLine(Offset(5, H * 0.5), Offset(W - 5, H * 0.5), lp);

    // Centre circle + dot
    canvas.drawCircle(Offset(W / 2, H * 0.5), W * 0.135, lp);
    canvas.drawCircle(Offset(W / 2, H * 0.5), 2.5,
        Paint()..color = Colors.white.withOpacity(0.75));

    // Big box top + bottom
    final bw = W * 0.55;
    final bh = H * 0.13;
    canvas.drawRect(Rect.fromLTWH((W - bw) / 2, 5, bw, bh), lp);
    canvas.drawRect(Rect.fromLTWH((W - bw) / 2, H - 5 - bh, bw, bh), lp);

    // Small box top + bottom
    final sw = W * 0.28;
    final sh = H * 0.052;
    canvas.drawRect(Rect.fromLTWH((W - sw) / 2, 5, sw, sh), lp);
    canvas.drawRect(Rect.fromLTWH((W - sw) / 2, H - 5 - sh, sw, sh), lp);

    // Penalty arcs
    canvas.drawArc(Rect.fromCenter(
        center: Offset(W / 2, bh + 5), width: W * 0.26, height: W * 0.26),
        0, 3.14159, false, lp);
    canvas.drawArc(Rect.fromCenter(
        center: Offset(W / 2, H - bh - 5), width: W * 0.26, height: W * 0.26),
        -3.14159, 3.14159, false, lp);

    // Corner arcs
    const cr = 8.0;
    for (final q in [
      [5.0, 5.0, 0.0],
      [W - 5.0 - cr * 2, 5.0, 1.5708],
      [5.0, H - 5.0 - cr * 2, -1.5708],
      [W - 5.0 - cr * 2, H - 5.0 - cr * 2, 3.14159],
    ]) {
      canvas.drawArc(
          Rect.fromLTWH(q[0], q[1], cr * 2, cr * 2), q[2], 1.5708, false, lp);
    }
  }

  @override bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Player dot ────────────────────────────────────────────────────────────
class _PlayerDot extends StatelessWidget {
  const _PlayerDot({required this.player});
  final LineupPlayer player;

  @override
  Widget build(BuildContext context) {
    final isCapt = player.isCaptain;
    return SizedBox(
      width: 48,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCapt ? const Color(0xFFFFCC00) : const Color(0xFFCC0001),
                  border: Border.all(color: Colors.white, width: 1.8),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 5, offset: const Offset(0, 2))],
                ),
                child: Center(
                  child: Text(
                    '${player.jerseyNumber ?? ''}',
                    style: TextStyle(
                      color: isCapt ? Colors.black87 : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              if (isCapt)
                Positioned(
                  top: -5, right: -5,
                  child: Container(
                    width: 14, height: 14,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFFFFCC00),
                        boxShadow: [BoxShadow(color: Colors.black26,
                            blurRadius: 2, offset: Offset(0, 1))]),
                    child: const Center(child: Text('C',
                        style: TextStyle(fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87))),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.60),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              player.displayName,
              style: const TextStyle(
                  color: Colors.white, fontSize: 9,
                  fontWeight: FontWeight.w600, height: 1.1),
              textAlign: TextAlign.center,
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
