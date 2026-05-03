
import 'package:flutter/material.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:garudahub/features/match/models/match_record.dart';

class RecordStatsCard extends StatelessWidget {
  const RecordStatsCard({
    super.key,
    required this.year,
    required this.record,
    this.isLoading = false,
  });

  final int year;
  final MatchRecord record;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final title = year == -1 ? 'INDONESIA' : 'INDONESIA $year';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        AppSpacing.base,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFCC0001),
            const Color(0xFF8B0000),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCC0001).withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ────────────────────────────────────────
          Row(
            children: [
              const Text('🇮🇩', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: tt.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white54,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Stats row ─────────────────────────────────────────
          if (isLoading || record.isEmpty)
            _buildSkeleton(cs)
          else
            Row(
              children: [
                _StatItem(
                  label: 'Main',
                  value: '${record.total}',
                  color: Colors.white,
                ),
                _StatDivider(),
                _StatItem(
                  label: 'Menang',
                  value: '${record.wins}',
                  color: const Color(0xFF81C784),
                ),
                _StatDivider(),
                _StatItem(
                  label: 'Seri',
                  value: '${record.draws}',
                  color: const Color(0xFFFFD54F),
                ),
                _StatDivider(),
                _StatItem(
                  label: 'Kalah',
                  value: '${record.losses}',
                  color: const Color(0xFFEF9A9A),
                ),
                _StatDivider(),
                _StatItem(
                  label: 'Gol',
                  value: '${record.goalsFor}',
                  color: Colors.white,
                ),
                _StatDivider(),
                _StatItem(
                  label: 'Kebobolan',
                  value: '${record.goalsAgainst}',
                  color: Colors.white,
                ),
              ],
            ),

          // ── Win rate bar ──────────────────────────────────────
          if (!isLoading && !record.isEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  'Win rate',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: record.winRate,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF81C784)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${(record.winRate * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeleton(ColorScheme cs) {
    return Row(
      children: List.generate(6, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < 5 ? AppSpacing.sm : 0),
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      )),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.xs - 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        color: Colors.white.withOpacity(0.15),
      );
}
