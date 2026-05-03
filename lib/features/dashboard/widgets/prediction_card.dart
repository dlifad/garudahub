import 'package:flutter/material.dart';
import 'package:garudahub/features/dashboard/models/match_data.dart';
import 'package:garudahub/core/utils/flag_utils.dart';
import 'package:intl/intl.dart';

class PredictionCard extends StatelessWidget {
  const PredictionCard({
    super.key,
    required this.match,
    required this.indScore,
    required this.oppScore,
    required this.predictionLocked,
    required this.submittingPrediction,
    required this.predictionStatus,
    required this.onUpInd,
    required this.onDownInd,
    required this.onUpOpp,
    required this.onDownOpp,
    required this.onSubmit,
    required this.predictionSummary,
  });

  final MatchData? match;
  final int indScore;
  final int oppScore;
  final bool predictionLocked;
  final bool submittingPrediction;
  final String? predictionStatus;
  final VoidCallback onUpInd;
  final VoidCallback onDownInd;
  final VoidCallback onUpOpp;
  final VoidCallback onDownOpp;
  final VoidCallback onSubmit;
  final String predictionSummary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final m = match;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────
          Text(
            'Siapa yang menang menurutmu?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: cs.onSurface,
            ),
          ),
          if (m != null) ...[
            const SizedBox(height: 3),
            Text(
              '${m.homeTeam} vs ${m.awayTeam} · ${_formatDate(m.matchDateUtc)}',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],

          if (m == null) ...[
            const SizedBox(height: 12),
            Text(
              'Belum ada match untuk diprediksi',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],

          if (m != null) ...[
            const SizedBox(height: 20),

            // ── Score Section ──────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tim Home
                _teamLabel(
                  context,
                  code: _countryCode(m.homeFlag),
                  flagUrl: FlagUtils.getFlagUrl(m.homeFlag),
                  name: m.homeTeam,
                ),
                const SizedBox(width: 12),

                // Stepper + Skor Home
                _scoreStepper(
                  context,
                  canUse: !predictionLocked,
                  onUp: onUpInd,
                  onDown: onDownInd,
                  score: indScore,
                ),

                // VS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                // Stepper + Skor Away
                _scoreStepper(
                  context,
                  canUse: !predictionLocked,
                  onUp: onUpOpp,
                  onDown: onDownOpp,
                  score: oppScore,
                  reversed: true,
                ),

                const SizedBox(width: 12),
                // Tim Away
                _teamLabel(
                  context,
                  code: _countryCode(m.awayFlag),
                  flagUrl: FlagUtils.getFlagUrl(m.awayFlag),
                  name: m.awayTeam,
                  alignRight: true,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Prediksi Summary Banner ────────────
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.95, end: 1),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC0000).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFDC0000).withOpacity(0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC0000),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFDC0000),
                          ),
                          children: [
                            const TextSpan(
                              text: 'Prediksimu: ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            TextSpan(
                              text: predictionSummary,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Status locked / error ──────────────
            if (predictionStatus != null && predictionLocked) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 13,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    predictionStatus!,
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ] else if (predictionStatus != null) ...[
              const SizedBox(height: 8),
              Text(
                predictionStatus!,
                style: TextStyle(color: cs.error, fontSize: 12),
              ),
            ],

            const SizedBox(height: 14),

            // ── Submit Button ──────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC0000),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                onPressed: (predictionLocked || submittingPrediction)
                    ? null
                    : onSubmit,
                icon: submittingPrediction
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  predictionLocked ? 'Sudah Diprediksi' : 'Kirim Prediksi',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Kolom stepper (chevron atas + skor + chevron bawah)
  Widget _scoreStepper(
    BuildContext context, {
    required bool canUse,
    required VoidCallback onUp,
    required VoidCallback onDown,
    required int score,
    bool reversed = false,
  }) {
    final cs = Theme.of(context).colorScheme;

    Widget chevronBtn(VoidCallback fn, IconData icon) => GestureDetector(
          onTap: canUse ? fn : null,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: canUse ? cs.onSurface : cs.onSurface.withOpacity(0.3),
            ),
          ),
        );

    return Column(
      children: [
        chevronBtn(onUp, Icons.keyboard_arrow_up_rounded),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: child,
          ),
          child: Text(
            '$score',
            key: ValueKey(score),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        chevronBtn(onDown, Icons.keyboard_arrow_down_rounded),
      ],
    );
  }

  /// Label tim (kode + nama)
  Widget _teamLabel(
    BuildContext context, {
    required String code,
    required String flagUrl,
    required String name,
    bool alignRight = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          code,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Image.network(
          flagUrl,
          width: 24,
          height: 16,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.flag, size: 16, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  String _countryCode(String flagCode) {
    if (flagCode.length >= 2) return flagCode.substring(0, 2).toUpperCase();
    return flagCode.toUpperCase();
  }

  String _formatDate(DateTime dt) {
    try {
      return DateFormat('EEE, d MMM yyyy', 'id_ID').format(dt.toLocal());
    } catch (_) {
      return DateFormat('EEE, d MMM yyyy').format(dt.toLocal());
    }
  }
}