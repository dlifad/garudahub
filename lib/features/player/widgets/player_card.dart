import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:garudahub/core/constants/constants.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';
import '../models/player_model.dart';

class PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final VoidCallback onTap;

  const PlayerCard({super.key, required this.player, required this.onTap});

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
    final posCol = _posColor[player.position] ?? cs.primary;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cs.surfaceContainerHighest,
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Foto area ──────────────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildPhoto(cs, posCol),

                  // Gradient bawah
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            cs.surfaceContainerHighest,
                            cs.surfaceContainerHighest.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Badge posisi kiri atas
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: _PosBadge(label: player.position, color: posCol),
                  ),

                  // Badge NAT kanan atas
                  if (player.isNaturalized)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm - 2,
                          vertical: AppSpacing.xs - 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.2),
                          border: Border.all(
                            color: const Color(0xFFD4AF37),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'NAT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD4AF37),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info bawah ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _twoWordName(player.name).toUpperCase(),
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    player.currentClub ?? '-',
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto(ColorScheme cs, Color posCol) {
    final url = _resolvePhotoUrl(player.photoUrl);
    if (url == null) {
      return _PhotoFallback(name: player.name, color: posCol);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: cs.surfaceContainerHighest,
        highlightColor: cs.surfaceContainer,
        child: Container(color: cs.surfaceContainerHighest),
      ),
      errorWidget: (_, __, ___) =>
          _PhotoFallback(name: player.name, color: posCol),
    );
  }

  String? _resolvePhotoUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    final base = AppConstants.baseUrl.replaceAll('/api', '');
    if (raw.startsWith('/')) return '$base$raw';
    return '$base/$raw';
  }

  String _twoWordName(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return raw;
    if (parts.length == 1) return parts[0];
    return '${parts[0]} ${parts[1]}';
  }
}

class _PhotoFallback extends StatelessWidget {
  final String name;
  final Color color;
  const _PhotoFallback({required this.name, required this.color});
  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: color.withOpacity(0.12),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: color.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

class _PosBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _PosBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm - 1,
        vertical: AppSpacing.xs - 1,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
