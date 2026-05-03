// lib/features/mini_games/penalty/screens/penalty_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/penalty_game_model.dart';
import '../providers/penalty_provider.dart';
import '../widgets/aim_arrow_widget.dart';
import '../widgets/ball_widget.dart';
import '../widgets/field_painter.dart';
import '../widgets/goalkeeper_widget.dart';
import '../widgets/penalty_result_overlay.dart';
import 'penalty_end_screen.dart';

class PenaltyGameScreen extends StatefulWidget {
  const PenaltyGameScreen({super.key});

  @override
  State<PenaltyGameScreen> createState() => _PenaltyGameScreenState();
}

class _PenaltyGameScreenState extends State<PenaltyGameScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PenaltyProvider>().startGame();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PenaltyProvider>(
      builder: (ctx, provider, _) {
        final state = provider.state;

        if (state.phase == GamePhase.finished) {
          return PenaltyEndScreen(
            goals: state.goals,
            totalShots: state.totalShots,
            shots: state.shots,
            onReplay: provider.resetGame,
            onExit: () => Navigator.of(context).pop(),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: state.phase == GamePhase.aiming ? provider.shoot : null,
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: FieldPainter())),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.22 - 80,
                  left: 0,
                  right: 0,
                  child: _GoalWidget(),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.22 - 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GoalkeeperWidget(
                      diveZone: state.keeperDive,
                      isDiving:
                          state.phase == GamePhase.result ||
                          state.phase == GamePhase.shooting,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: _HudBar(
                      currentShot: state.currentShot,
                      totalShots: state.totalShots,
                      goals: state.goals,
                    ),
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.14,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      AimArrowWidget(
                        currentZone: state.currentAim,
                        isActive: state.phase == GamePhase.aiming,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: BallWidget(
                          isShooting:
                              state.phase == GamePhase.shooting ||
                              state.phase == GamePhase.result,
                          targetZone: state.currentAim,
                          isGoal: state.lastResult == ShotResult.goal,
                          onShootComplete: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.phase == GamePhase.aiming)
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.06,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'TAP LAYAR UNTUK TEMBAK',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 11,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (state.phase == GamePhase.result && state.lastResult != null)
                  Positioned.fill(
                    child: PenaltyResultOverlay(
                      result: state.lastResult!,
                      currentShot: state.currentShot,
                      totalShots: state.totalShots,
                      onContinue: provider.nextShot,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GoalWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Center(
      child: CustomPaint(size: Size(w * 0.72, 80), painter: _GoalPainter()),
    );
  }
}

class _GoalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final postPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = Colors.white.withOpacity(0.07),
    );
    final netPaint = Paint()
      ..color = Colors.white.withOpacity(0.14)
      ..strokeWidth = 0.8;
    for (double x = 0; x <= w; x += 12)
      canvas.drawLine(Offset(x, 0), Offset(x, h), netPaint);
    for (double y = 0; y <= h; y += 12)
      canvas.drawLine(Offset(0, y), Offset(w, y), netPaint);
    canvas.drawLine(Offset(0, 0), Offset(0, h), postPaint);
    canvas.drawLine(Offset(w, 0), Offset(w, h), postPaint);
    canvas.drawLine(Offset(0, 0), Offset(w, 0), postPaint);
    canvas.drawRect(
      Rect.fromLTWH(0, h - 4, w, 4),
      Paint()..color = Colors.black.withOpacity(0.3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _HudBar extends StatelessWidget {
  final int currentShot, totalShots, goals;
  const _HudBar({
    required this.currentShot,
    required this.totalShots,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _HudChip(label: 'TENDANGAN', value: '$currentShot / $totalShots'),
          _HudChip(label: 'GOL', value: '⚽ $goals', accent: true),
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  final String label, value;
  final bool accent;
  const _HudChip({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: accent
            ? const Color(0xFF16A34A).withOpacity(0.25)
            : Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent
              ? const Color(0xFF22C55E).withOpacity(0.4)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.45),
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: accent ? const Color(0xFF4ADE80) : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
