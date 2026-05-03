import 'package:flutter/material.dart';
import 'package:garudahub/features/prediction/screens/prediction_screen.dart';

class PredictionMiniCard extends StatelessWidget {
  const PredictionMiniCard({
    super.key,
    this.lastIndScore,
    this.lastOppScore,
  });

  final int? lastIndScore;
  final int? lastOppScore;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final homeScore = lastIndScore ?? 1;
    final awayScore = lastOppScore ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PredictionScreen(),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Bola dekoratif kanan bawah
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Opacity(
                    opacity: 0.08,
                    child: Text(
                      '\u26bd',
                      style: TextStyle(
                        fontSize: 72,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
                // Konten
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFCC0001).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('\u26bd',
                                    style: TextStyle(fontSize: 9)),
                                SizedBox(width: 4),
                                Text(
                                  'Prediksi',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFCC0001),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Prediksi\nSkor',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _scoreChip(homeScore),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5),
                                child: Text(
                                  '\u2014',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurfaceVariant
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ),
                              _scoreChip(awayScore),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Masuk & prediksi \u2192',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFCC0001),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreChip(int score) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFCC0001),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$score',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
