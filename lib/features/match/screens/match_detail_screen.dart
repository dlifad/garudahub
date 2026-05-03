import 'package:flutter/material.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:garudahub/core/providers/timezone_provider.dart';
import 'package:garudahub/features/match/models/lineup_player.dart';
import 'package:garudahub/features/match/models/match_item.dart';
import 'package:garudahub/features/match/models/tournament_coach.dart';
import 'package:garudahub/features/match/services/match_service.dart';
import 'package:garudahub/features/match/screens/match_chat_screen.dart';
import 'package:garudahub/features/match/widgets/lineup_field_widget.dart';
import 'package:garudahub/core/utils/flag_utils.dart';
import 'package:garudahub/features/match/widgets/stadium_map_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:garudahub/core/services/directions_service.dart';

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({super.key, required this.match});
  final MatchItem match;

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final _service = MatchService();
  MatchLineupData? _lineup;
  TournamentCoach? _coach;
  bool _lineupLoading = true;
  bool _coachLoading  = true;

  // LBS
  double? _distanceKm;
  double? _durationMin;
  bool _locationLoading = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    Future.wait([_loadLineup(), _loadCoach(), _loadUserLocation()]);
  }

  Future<void> _loadLineup() async {
    final data = await _service.getMatchLineup(widget.match.id);
    if (mounted) setState(() { _lineup = data; _lineupLoading = false; });
  }

  Future<void> _loadCoach() async {
    final coaches =
        await _service.getTournamentCoaches(widget.match.tournamentId);
    final resolved =
        _service.resolveCoach(coaches, widget.match.matchDateUtc);
    if (mounted) setState(() { _coach = resolved; _coachLoading = false; });
  }

  Future<void> _loadUserLocation() async {
    final lat = widget.match.stadium.latitude;
    final lng = widget.match.stadium.longitude;

    if (lat == 0 || lng == 0) {
      if (mounted) setState(() { _locationLoading = false; _locationError = 'Lokasi stadion belum diumumkan'; });
      return;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() { _locationLoading = false; _locationError = 'Layanan lokasi nonaktif'; });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() { _locationLoading = false; _locationError = 'Izin lokasi ditolak'; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() { _locationLoading = false; _locationError = 'Izin lokasi diblokir permanen'; });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      final result = await DirectionsService.getRoute(
        startLat: position.latitude,
        startLng: position.longitude,
        endLat: lat,
        endLng: lng,
      );

      if (result != null) {
        setState(() {
          _distanceKm = result.distanceMeters / 1000;
          _durationMin = result.durationSeconds / 60;
          _locationLoading = false;
        });
      }   
    } catch (e) {
      if (mounted) setState(() { _locationLoading = false; _locationError = 'Gagal mendapatkan lokasi'; });
    }
  }

  void _openMapSheet(BuildContext context) {
    final m = widget.match;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (ctx, ctrl) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Header ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.base,
                  AppSpacing.base,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(Icons.stadium_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        m.venue ?? 'Stadion',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        padding: const EdgeInsets.all(AppSpacing.sm - 2),
                      ),
                    ),
                  ],
                ),
              ),

              // ── StadiumMap mengisi sisa ruang + tombol di dalamnya ──
              Expanded(
                child: StadiumMap(
                  stadiumLat: m.stadium.latitude,
                  stadiumLng: m.stadium.longitude,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final m  = widget.match;

    return Scaffold(
      backgroundColor: AppColors.softBackground(cs, isDark: Theme.of(context).brightness == Brightness.dark),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroHeader(
              match: m, coach: _coach, coachLoading: _coachLoading),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.base + AppSpacing.xs, AppSpacing.base, AppSpacing.xl + AppSpacing.sm),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Match Info ─────────────────────────────────────
                _MatchInfoCard(
                  match: m,
                  coach: _coach,
                  coachLoading: _coachLoading,
                ),
                const SizedBox(height: AppSpacing.base + AppSpacing.xs),

                // ── Lineup ─────────────────────────────────────────
                _buildLineupSection(context, cs),
                const SizedBox(height: AppSpacing.lg),

                // ── Stadium & LBS ─────────────────────────────────────────
                _StadiumLBSCard(
                  match: m,
                  distanceKm: _distanceKm,
                  durationMin: _durationMin,
                  locationLoading: _locationLoading,
                  locationError: _locationError,
                  onOpenMap: () => _openMapSheet(context),
                  onRetryLocation: () {
                    setState(() { _locationLoading = true; _locationError = null; });
                    _loadUserLocation();
                  },
                ),
                const SizedBox(height: AppSpacing.base + AppSpacing.xs),

                // ── Discussion CTA ─────────────────────────────────
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchChatScreen(match: m),
                    ),
                  ),
                  icon: const Icon(Icons.forum_rounded, size: 18),
                  label: const Text('Gabung Diskusi Laga'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineupSection(BuildContext context, ColorScheme cs) {
    final tt = Theme.of(context).textTheme;

    if (_lineupLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: cs.primary, strokeWidth: 2),
            const SizedBox(height: AppSpacing.md - 2),
            Text('Memuat susunan pemain...',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        )),
      );
    }

    if (_lineup == null || _lineup!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl + AppSpacing.xs),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Column(
          children: [
            Icon(Icons.groups_2_rounded, size: 42,
                color: cs.onSurfaceVariant.withOpacity(0.3)),
            const SizedBox(height: AppSpacing.sm),
            Text('Susunan pemain belum tersedia',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        )),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionTitle(
                icon: Icons.sports_outlined, label: 'SUSUNAN PEMAIN'),
            const Spacer(),
            if (widget.match.formation?.isNotEmpty == true)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.match.formation!,
                    style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 13, letterSpacing: 0.5)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md - 2),
        // Field
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LineupFieldWidget(
            players:   _lineup!.startingXi,
            formation: widget.match.formation,
          ),
        ),
        // Subs
        if (_lineup!.substitutes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.base),
          const _SectionTitle(
              icon: Icons.swap_horiz_rounded, label: 'PEMAIN PENGGANTI'),
          const SizedBox(height: AppSpacing.sm),
          _SubsCard(substitutes: _lineup!.substitutes),
        ],
      ],
    );
  }
}

// Stadium LBS Card
class _StadiumLBSCard extends StatelessWidget {
  const _StadiumLBSCard({
    required this.match,
    required this.distanceKm,
    required this.durationMin,
    required this.locationLoading,
    required this.locationError,
    required this.onOpenMap,
    required this.onRetryLocation,
  });

  final MatchItem match;
  final double? distanceKm;
  final double? durationMin;
  final bool locationLoading;
  final String? locationError;
  final VoidCallback onOpenMap;
  final VoidCallback onRetryLocation;

  String _formatDistance(double km) {
    if (km < 1.0) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  String _formatDuration(double min) {
    if (min < 60) return '${min.round()} menit';
    final h = min ~/ 60;
    final m = (min % 60).round();
    return m == 0 ? '$h jam' : '$h jam $m menit';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasVenue = match.venue?.isNotEmpty == true;
    final hasCoordinate = match.stadium.latitude != 0 && match.stadium.longitude != 0;
    final city = match.stadium.city;
    final country = match.stadium.country; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
            icon: Icons.stadium_rounded, label: 'LOKASI STADION'),
        const SizedBox(height: AppSpacing.sm),

        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // ── Stadium header row ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.md, AppSpacing.md, AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasVenue ? match.venue! : 'To be announced',
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          if (city != '-' || country != '-')
                            Text(
                              [city, country]
                                  .where((e) => e.isNotEmpty && e != '-')
                                  .join(', '),
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Lihat Peta button
                    FilledButton.icon(
                      onPressed: hasCoordinate ? onOpenMap : null,
                      icon: const Icon(Icons.map_rounded, size: 15),
                      label: const Text('Peta'),
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: cs.outline.withValues(alpha: 0.12)),

              // ── LBS section ────────────────────────────────────
              if (locationLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.base + AppSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: cs.primary),
                      ),
                      const SizedBox(width: AppSpacing.md - 2),
                      Text('Mendeteksi lokasi Anda...',
                          style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant)),
                    ],
                  ),
                )
              else if (locationError != null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Row(
                    children: [
                      Icon(Icons.location_off_rounded,
                          size: 18, color: cs.error),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(locationError!,
                            style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant)),
                      ),
                      TextButton(
                        onPressed: onRetryLocation,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Coba lagi', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                )
              else if (distanceKm != null) ...[
                // Distance + time strip
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.md, AppSpacing.base, AppSpacing.base),
                  child: Row(
                    children: [
                      _LBSStat(
                        icon: Icons.place,
                        iconColor: cs.primary,
                        label: 'Jarak',
                        value: _formatDistance(distanceKm!),
                        cs: cs, tt: tt,
                      ),
                      Container(width: 1, height: 40,
                          color: cs.outline.withValues(alpha: 0.15),
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base,
                          )),
                      _LBSStat(
                        icon: Icons.schedule_rounded,
                        iconColor: cs.primary,
                        label: 'Estimasi Perjalanan',
                        value: durationMin != null
                            ? _formatDuration(durationMin!)
                            : '-',
                        cs: cs, tt: tt,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// LBS stat widget (jarak / estimasi)
class _LBSStat extends StatelessWidget {
  const _LBSStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.cs,
    required this.tt,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: AppSpacing.md - 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant, fontSize: 10)),
                Text(value,
                    style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800, color: cs.onSurface),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Hero Header — red gradient, big flags, score
// ══════════════════════════════════════════════════════════════════════════
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.match,
    required this.coach,
    required this.coachLoading,
  });
  final MatchItem match;
  final TournamentCoach? coach;
  final bool coachLoading;

  @override
  Widget build(BuildContext context) {
    final tzProvider = context.watch<TimezoneProvider>();
    final local   = tzProvider.convert(match.matchDateUtc);
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(local);
    final timeStr = DateFormat('HH:mm').format(local);
    final hasCoordinate = match.stadium.latitude != 0 && match.stadium.longitude != 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCC0001), Color(0xFF7B0000)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.sm,
            AppSpacing.base,
            AppSpacing.base + AppSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top bar ──────────────────────────────────────────
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      padding: const EdgeInsets.all(AppSpacing.sm)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(match.tournamentName.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11,
                          fontWeight: FontWeight.w700, letterSpacing: 1.2),
                      overflow: TextOverflow.ellipsis),
                ),
                _StatusChip(match: match),
              ]),

              const SizedBox(height: AppSpacing.lg),

              // ── Teams + Score ─────────────────────────────────────
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FlagImage(
                            code: match.isHome ? match.homeFlag : match.awayFlag,
                            size: 60),
                        const SizedBox(height: AppSpacing.sm),
                        const Text('Indonesia',
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm - 2,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (match.isScheduled) ...[
                            const Text('VS',
                                style: TextStyle(color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(timeStr,
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 13)),
                          ] else ...[
                            Text(
                              '${match.indonesiaScore ?? 0}  :  ${match.opponentScore ?? 0}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1),
                            ),
                            if (match.isFinished && match.result != null)
                              Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.xs + 1),
                                child: _ResultBadge(result: match.result!),
                              ),
                            if (match.halfTimeScore?.isNotEmpty == true)
                              Text('(${match.halfTimeScore})',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12)),
                          ],
                        ],
                      ),
                    ),
                    Expanded(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FlagImage(code: match.opponentFlag, size: 60),
                        const SizedBox(height: AppSpacing.sm),
                        Text(match.opponentName,
                            style: const TextStyle(color: Colors.white70,
                                fontWeight: FontWeight.w500, fontSize: 14),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    )),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              if (match.goals != null && match.goals!.isNotEmpty)
                  _InlineGoalScorers(goals: match.goals!, match: match),

              const SizedBox(height: AppSpacing.base + 2),

              // ── Info strip ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        text: '$dateStr  •  $timeStr ${tzProvider.label}'),
                    const SizedBox(height: AppSpacing.xs),
                    _InfoRow(
                      icon: Icons.stadium_rounded,
                      text: hasCoordinate
                          ? (match.venue ?? 'Stadion')
                          : 'Stadion belum diumumkan',
                    ),
                  ],
                ),
              ),

              // ── Coach strip ───────────────────────────────────────
            ],
          ),
        ),
      ),
    );
  }
}

class _FlagImage extends StatelessWidget {
  const _FlagImage({required this.code, required this.size});
  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        FlagUtils.getFlagUrl(code.toLowerCase()),
        width: size, height: size * 0.67,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.flag_rounded, size: size, color: Colors.white54),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.match});
  final MatchItem match;
  @override
  Widget build(BuildContext context) {
    if (match.isOngoing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: Colors.orange, borderRadius: BorderRadius.circular(6)),
        child: const Text('LIVE',
            style: TextStyle(color: Colors.white,
                fontSize: 10, fontWeight: FontWeight.bold)));
    }
    if (match.isFinished) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.24),
          borderRadius: BorderRadius.circular(6)),
        child: const Text(
            'SELESAI',
            style: TextStyle(color: Colors.white,
                fontSize: 10, fontWeight: FontWeight.bold)));
    }
    return const SizedBox.shrink();
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.result});
  final String result;
  @override
  Widget build(BuildContext context) {
    Color c; String label;
    if (result == 'WIN')  { c = const Color(0xFF4CAF50); label = 'MENANG'; }
    else if (result == 'LOSS') { c = const Color(0xFFEF5350); label = 'KALAH'; }
    else { c = Colors.orange; label = 'SERI'; }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs - 1),
      decoration: BoxDecoration(
        color: c.withOpacity(0.25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withOpacity(0.7)),
      ),
      child: Text(label,
          style: TextStyle(color: c,
              fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String   text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: Colors.white54, size: 12),
      const SizedBox(width: AppSpacing.sm - 2),
      Flexible(child: Text(text,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis)),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════════════
class _MatchInfoCard extends StatelessWidget {
  const _MatchInfoCard({
    required this.match,
    this.coach,
    this.coachLoading = false,
  });
  final MatchItem match;
  final TournamentCoach? coach;
  final bool coachLoading;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final rows = <({IconData icon, String label, String value})>[];
    if (match.round?.isNotEmpty == true)
      rows.add((icon: Icons.flag_rounded, label: 'Ronde', value: match.round!));
    rows.add((
      icon: Icons.swap_horiz_rounded,
      label: 'Kandang/Tandang',
      value: match.isHome ? 'Kandang (Home)' : 'Tandang (Away)',
    ));
    if (match.matchday?.isNotEmpty == true)
      rows.add((
        icon: Icons.calendar_month_rounded,
        label: 'Matchday',
        value: match.matchday!,
      ));
    if (match.formation?.isNotEmpty == true)
      rows.add((
        icon: Icons.grid_view_rounded,
        label: 'Formasi',
        value: match.formation!,
      ));
    if (!coachLoading && coach != null)
      rows.add((
        icon: Icons.person_rounded,
        label: 'Pelatih Kepala',
        value: coach!.name,
      ));
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
            icon: Icons.info_outline_rounded, label: 'INFO PERTANDINGAN'),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outline.withOpacity(0.15)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: rows.asMap().entries.map((e) {
              final r = e.value;
              final isLast = e.key == rows.length - 1;
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Icon(r.icon, size: 18, color: cs.primary),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(width: 110,
                        child: Text(r.label,
                            style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant))),
                    Expanded(child: Text(r.value,
                        style: tt.bodySmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600))),
                  ]),
                ),
                if (!isLast)
                  Divider(height: 1, indent: 46, endIndent: 16,
                      color: cs.outline.withOpacity(0.1)),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
class _SubsCard extends StatelessWidget {
  const _SubsCard({required this.substitutes});
  final List<LineupPlayer> substitutes;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withOpacity(0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: substitutes.asMap().entries.map((e) {
          final p = e.value;
          final isLast = e.key == substitutes.length - 1;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surfaceContainer,
                    border: Border.all(
                        color: cs.outline.withOpacity(0.2)),
                  ),
                  child: Center(child: Text('${p.jerseyNumber ?? ''}',
                      style: tt.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface))),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: tt.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface)),
                    if (p.currentClub?.isNotEmpty == true)
                      Text(p.currentClub!,
                          style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant)),
                  ],
                )),
                if (p.position?.isNotEmpty == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(p.position!,
                        style: tt.labelSmall?.copyWith(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 10)),
                  ),
              ]),
            ),
            if (!isLast)
              Divider(height: 1, indent: 62, endIndent: 16,
                  color: cs.outline.withOpacity(0.1)),
          ]);
        }).toList(),
      ),
    );
  }
}

// ── Shared Section Title ──────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});
  final IconData icon;
  final String   label;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(children: [
      Container(width: 3, height: 16,
          decoration: BoxDecoration(
              color: cs.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: AppSpacing.sm),
      Icon(icon, size: 15, color: cs.primary),
      const SizedBox(width: AppSpacing.sm - 2),
      Text(label, style: tt.labelMedium?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w800, letterSpacing: 0.8)),
    ]);
  }
}

class _InlineGoalScorers extends StatelessWidget {
  const _InlineGoalScorers({
    required this.goals,
    required this.match,
  });

  final List<MatchGoal> goals;
  final MatchItem match;

  @override
  Widget build(BuildContext context) {
    final indoGoals =
        goals.where((g) => g.isIndonesiaGoal).toList();
    final oppGoals =
        goals.where((g) => !g.isIndonesiaGoal).toList();

    TextStyle style = const TextStyle(
      color: Colors.white70,
      fontSize: 11,
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: indoGoals.map((g) {
                return Text(
                  "${g.scorerName} ${g.minute}' ",
                  style: style,
                  textAlign: TextAlign.right,
                );
              }).toList(),
            ),
          ),
      
          const SizedBox(width: 72),
      
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: oppGoals.map((g) {
                return Text(
                  "${g.scorerName} ${g.minute}'",
                  style: style,
                  textAlign: TextAlign.left,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}




