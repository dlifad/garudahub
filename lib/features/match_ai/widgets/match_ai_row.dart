import 'package:flutter/material.dart';

class MatchAiRow extends StatelessWidget {
  const MatchAiRow({
    super.key,
    required this.homeWin,
    required this.draw,
    required this.awayWin,
    required this.isHome,
  });

  final double homeWin;
  final double draw;
  final double awayWin;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final win = isHome ? homeWin : awayWin;
    final lose = isHome ? awayWin : homeWin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              _Label(text: 'Menang', value: win, align: TextAlign.left),
              _Label(text: 'Seri', value: draw, align: TextAlign.center),
              _Label(text: 'Kalah', value: lose, align: TextAlign.right),
            ],
          ),

          const SizedBox(height: 6),

          // Segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Row(
              children: [
                _Segment(flex: (win * 1000).round(), color: Colors.white),
                const SizedBox(width: 2),
                _Segment(
                  flex: (draw * 1000).round(),
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 2),
                _Segment(
                  flex: (lose * 1000).round(),
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.text,
    required this.value,
    required this.align,
  });

  final String text;
  final double value;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RichText(
        textAlign: align,
        text: TextSpan(
          children: [
            TextSpan(
              text: '${(value * 100).toStringAsFixed(0)}% ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.flex, required this.color});

  final int flex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(height: 5, color: color),
    );
  }
}