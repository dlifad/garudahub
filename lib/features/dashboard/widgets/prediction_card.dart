import 'package:flutter/material.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:garudahub/features/dashboard/models/match_data.dart';
import 'package:garudahub/core/utils/flag_utils.dart';

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
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer.withOpacity(0.3), cs.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Siapa yang menang menurutmu?',
            style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          m == null
            ? Text(
                'Belum ada match untuk diprediksi',
                style: TextStyle(color: cs.onSurfaceVariant),
              )
            : Row(
                children: [
                  Text(m.homeTeam),
                  const SizedBox(width: AppSpacing.sm - 2),
                  Image.network(
                    FlagUtils.getFlagUrl(m.homeFlag),
                    width: 20,
                    height: 14,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.flag, size: 16),
                  ),    
                  const SizedBox(width: AppSpacing.sm),
                  const Text('VS'),
                  const SizedBox(width: AppSpacing.sm),
                  Image.network(
                    FlagUtils.getFlagUrl(m.awayFlag),
                    width: 20,
                    height: 14,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.flag, size: 16),
                  ),
                  const SizedBox(width: AppSpacing.sm - 2),
                  Text(m.awayTeam),
                ],
              ),
          const SizedBox(height: AppSpacing.md),
          if (m != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _scoreStepper(
                  canUse: !predictionLocked,
                  onUp: onUpInd,
                  onDown: onDownInd,
                ),
                const SizedBox(width: AppSpacing.sm),
                _scoreBox(indScore),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    '-',
                    style: TextStyle(fontSize: 26, color: cs.onSurfaceVariant),
                  ),
                ),
                _scoreBox(oppScore),
                const SizedBox(width: AppSpacing.sm),
                _scoreStepper(
                  canUse: !predictionLocked,
                  onUp: onUpOpp,
                  onDown: onDownOpp,
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.92, end: 1),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Text(
              'Hasil prediksimu: $predictionSummary',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (predictionStatus != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              predictionStatus!,
              style: TextStyle(color: predictionLocked ? Colors.green : cs.error),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (m == null || predictionLocked || submittingPrediction)
                  ? null
                  : onSubmit,
              icon: submittingPrediction
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(predictionLocked ? 'Sudah Diprediksi' : 'Kirim Prediksi'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreBox(int score) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [Color(0xFFDC0000), Color(0xFFB00000)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          '$score',
          key: ValueKey(score),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _scoreStepper({
    required VoidCallback onUp,
    required VoidCallback onDown,
    required bool canUse,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: FloatingActionButton(
            heroTag: null,
            elevation: 0,
            onPressed: canUse ? onUp : null,
            child: const Icon(Icons.arrow_upward),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: 44,
          height: 44,
          child: FloatingActionButton(
            heroTag: null,
            elevation: 0,
            onPressed: canUse ? onDown : null,
            child: const Icon(Icons.arrow_downward),
          ),
        ),
      ],
    );
  }
}
