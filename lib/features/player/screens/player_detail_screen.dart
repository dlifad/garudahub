import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:garudahub/core/constants/constants.dart';
import '../models/player_model.dart';

class PlayerDetailScreen extends StatelessWidget {
  final PlayerModel player;
  const PlayerDetailScreen({super.key, required this.player});

  static const _posColor = {
    'GK': Color(0xFFFFB300),
    'DEF': Color(0xFF42A5F5),
    'MID': Color(0xFF66BB6A),
    'FWD': Color(0xFFEF5350),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final col = _posColor[player.position] ?? cs.primary;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── Hero foto ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: cs.surface,
            surfaceTintColor: cs.surfaceTint,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Tint background warna posisi
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [col.withOpacity(0.12), cs.surface],
                      ),
                    ),
                  ),

                  // Foto — handle berbagai rasio dari storage
                  if (_resolvePhotoUrl(player.photoUrl) != null)
                    CachedNetworkImage(
                      imageUrl: _resolvePhotoUrl(player.photoUrl)!,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: cs.surfaceContainerHighest,
                        highlightColor: cs.surfaceContainer,
                        child: Container(color: cs.surfaceContainerHighest),
                      ),
                      errorWidget: (_, __, ___) =>
                          _HeroFallback(name: player.name, color: col),
                    )
                  else
                    _HeroFallback(name: player.name, color: col),

                  // Gradient fade ke surface di bawah
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [cs.surface, Colors.transparent],
                        ),
                      ),
                    ),
                  ),

                  // Badge posisi + naturalisasi
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: col.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            player.positionLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (player.isNaturalized) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.15),
                              border: Border.all(
                                color: const Color(0xFFD4AF37),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '🌍 Naturalisasi',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama + nickname
                  Text(
                    player.name.toUpperCase(),
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (player.nickname?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '"${player.nickname}"',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Stat cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          value: '${player.caps}',
                          label: 'Caps',
                          icon: Icons.shield_rounded,
                          cs: cs,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          value: '${player.goals}',
                          label: 'Gol',
                          icon: Icons.sports_soccer_rounded,
                          cs: cs,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section label
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 14,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'INFORMASI PEMAIN',
                        style: tt.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Info card
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.business_center_rounded,
                          label: 'Klub',
                          value: player.currentClub ?? '-',
                          cs: cs,
                        ),
                        _divider(cs),
                        if (player.clubCountry != null) ...[
                          _InfoRow(
                            icon: Icons.flag_rounded,
                            label: 'Negara Klub',
                            value: player.clubCountry!,
                            cs: cs,
                          ),
                          _divider(cs),
                        ],
                        _InfoRow(
                          icon: Icons.cake_rounded,
                          label: 'Tgl. Lahir',
                          value: _fmtDate(player.dateOfBirth),
                          cs: cs,
                        ),
                        _divider(cs),
                        _InfoRow(
                          icon: Icons.person_pin_rounded,
                          label: 'Posisi',
                          value: player.positionLabel,
                          cs: cs,
                        ),
                        _divider(cs),
                        _InfoRow(
                          icon: Icons.public_rounded,
                          label: 'Status',
                          value: player.isNaturalized
                              ? 'Naturalisasi'
                              : 'WNI Asli',
                          cs: cs,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme cs) =>
      Divider(height: 1, indent: 52, color: cs.outlineVariant.withOpacity(0.5));

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      const m = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      final age = DateTime.now().year - dt.year;
      return '${dt.day} ${m[dt.month]} ${dt.year}  •  $age tahun';
    } catch (_) {
      return raw;
    }
  }

  String? _resolvePhotoUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    final base = AppConstants.baseUrl.replaceAll('/api', '');
    if (raw.startsWith('/')) return '$base$raw';
    return '$base/$raw';
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────

class _HeroFallback extends StatelessWidget {
  final String name;
  final Color color;
  const _HeroFallback({required this.name, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.w900,
            color: color.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final ColorScheme cs;
  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.cs,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.onPrimaryContainer, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final ColorScheme cs;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: cs.primary),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
