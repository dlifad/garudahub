import 'package:flutter/material.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:garudahub/features/match/models/match_item.dart';
import 'package:garudahub/features/match/models/tournament_coach.dart';
import 'package:garudahub/features/match/models/tournament_model.dart';
import 'package:garudahub/features/match/screens/match_detail_screen.dart';
import 'package:garudahub/core/providers/timezone_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

const int kAllTimeYear = -1;

class TournamentSection extends StatefulWidget {
  const TournamentSection({
    super.key,
    required this.tournament,
    required this.matches,
    this.coaches = const [],
    this.isLoading = false,
    this.initiallyExpanded = false,
    this.selectedYear,
  });

  final TournamentModel tournament;
  final List<MatchItem> matches;
  final List<TournamentCoach> coaches;
  final bool isLoading;
  final bool initiallyExpanded;
  final int? selectedYear;

  @override
  State<TournamentSection> createState() => _TournamentSectionState();
}

class _TournamentSectionState extends State<TournamentSection>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _ctrl;
  late final Animation<double> _heightFactor;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
        value: _expanded ? 1 : 0);
    _heightFactor =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _rotate = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final finished = widget.matches.where((m) => m.isFinished).length;
    final total    = widget.matches.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        0,
        AppSpacing.base,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ────────────────────────────────────────────
          InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.tournament.logoUrl?.isNotEmpty == true
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(widget.tournament.logoUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                    Icons.emoji_events_rounded,
                                    size: 18, color: cs.primary)))
                        : Icon(Icons.emoji_events_rounded,
                            size: 18, color: cs.primary),
                  ),
                  const SizedBox(width: AppSpacing.md - 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tournament.name.toUpperCase(),
                          style: tt.labelMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5, fontSize: 12,
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs - 2),
                        Row(
                          children: [
                            if (total > 0)
                              Text('$finished/$total laga',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.tournament.confederation?.isNotEmpty == true) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xs - 1),
                      margin: const EdgeInsets.only(right: AppSpacing.sm - 2),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(widget.tournament.confederation!,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.bold, fontSize: 10,
                          )),
                    ),
                  ],
                  RotationTransition(
                    turns: _rotate,
                    child: Icon(Icons.expand_more_rounded,
                        color: cs.onSurfaceVariant, size: 22),
                  ),
                ],
              ),
            ),
          ),
          // ── Body ──────────────────────────────────────────────
          ClipRect(
            child: AnimatedBuilder(
              animation: _heightFactor,
              builder: (_, child) =>
                  Align(heightFactor: _heightFactor.value, child: child),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                    ),
                    color: cs.primary.withOpacity(0.28),
                  ),
                  if (widget.isLoading)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.base + AppSpacing.xs),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: cs.primary)),
                          const SizedBox(width: AppSpacing.md - 2),
                          Text('Memuat...',
                              style: TextStyle(
                                  color: cs.onSurfaceVariant, fontSize: 13)),
                        ],
                      ),
                    )
                  else if (widget.matches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.base + AppSpacing.xs),
                      child: Text('Belum ada data pertandingan',
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)))
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.matches.length, (i) {
                        final isLast = i == widget.matches.length - 1;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MatchRow(match: widget.matches[i]),
                            if (!isLast)
                              Divider(
                                height: 1,
                                indent: AppSpacing.base,
                                endIndent: AppSpacing.base,
                                color: cs.outline.withOpacity(0.1),
                              ),
                          ],
                        );
                      }),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match});
  final MatchItem match;

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;
    final tz = context.watch<TimezoneProvider>();
    final local = tz.convert(match.matchDateUtc);
    final dateStr = DateFormat('d MMM', 'id_ID').format(local);
    final timeStr = DateFormat('HH:mm').format(local);

    return InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(
              builder: (_) => MatchDetailScreen(match: match))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.md - 1,
          AppSpacing.md,
          AppSpacing.md - 1,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr,
                      style: tt.labelSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600, fontSize: 12)),
                  Text(timeStr,
                      style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ),
            _HABadge(isHome: match.isHome),
            const SizedBox(width: AppSpacing.md - 2),
            Expanded(
              child: Text(match.opponentName,
                  style: tt.bodySmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500, fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: AppSpacing.sm),
            _ScoreBadge(match: match),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant, size: 18),
          ],
        ),
      ),
    );
  }
}

class _HABadge extends StatelessWidget {
  const _HABadge({required this.isHome});
  final bool isHome;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm - 1,
        vertical: AppSpacing.xs - 1,
      ),
      decoration: BoxDecoration(
        color: isHome ? cs.primaryContainer : cs.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(isHome ? 'H' : 'A',
          style: TextStyle(
              color: isHome ? cs.onPrimaryContainer : cs.onSecondaryContainer,
              fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.match});
  final MatchItem match;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (match.isScheduled) {
      return Text('vs',
          style: TextStyle(color: cs.onSurfaceVariant,
              fontSize: 12, fontWeight: FontWeight.w600));
    }
    if (match.isOngoing) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm - 1,
          vertical: AppSpacing.xs - 1,
        ),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.18),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('LIVE',
            style: TextStyle(
                color: Colors.orange.shade400,
                fontSize: 10, fontWeight: FontWeight.bold)),
      );
    }
    if (match.indonesiaScore == null) {
      return Text('-',
          style: TextStyle(
              color: cs.onSurfaceVariant, fontWeight: FontWeight.bold));
    }
    final Color c;
    if (match.result == 'WIN') c = const Color(0xFF4CAF50);
    else if (match.result == 'LOSS') c = cs.error;
    else c = Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.withOpacity(0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('${match.indonesiaScore} : ${match.opponentScore}',
          style: TextStyle(
              color: c, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
