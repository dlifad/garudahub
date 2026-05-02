import 'package:flutter/material.dart';
import 'package:garudahub/features/match/models/tournament_model.dart';
import 'package:garudahub/features/match/services/match_service.dart';
import '../models/player_model.dart';
import '../services/player_service.dart';
import '../widgets/player_card.dart';
import 'player_detail_screen.dart';

class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key});
  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen>
    with AutomaticKeepAliveClientMixin {
  final _playerService = PlayerService();
  final _matchService  = MatchService();

  List<TournamentModel> _tournaments = [];
  TournamentModel?      _selectedTournament;
  SquadResponse?        _squad;
  bool   _isLoading = true;
  String? _error;
  String? _filterPos;

  static const _posOrder = ['GK', 'DEF', 'MID', 'FWD'];
  static const _posLabel = {
    'GK':  'Penjaga Gawang',
    'DEF': 'Bertahan',
    'MID': 'Tengah',
    'FWD': 'Penyerang',
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() { _isLoading = true; _error = null; });
    final tours = await _matchService.getTournaments();
    if (tours.isEmpty) {
      if (mounted) setState(() { _isLoading = false; _error = 'Gagal memuat data turnamen.'; });
      return;
    }
    // Ambil turnamen terbaru berdasarkan tahun
    final latest = tours.reduce((a, b) =>
        (a.endDate?.millisecondsSinceEpoch ?? a.year * 10000) >=
        (b.endDate?.millisecondsSinceEpoch ?? b.year * 10000) ? a : b);
    if (mounted) setState(() { _tournaments = tours; _selectedTournament = latest; });
    await _loadSquad(latest.id);
  }

  Future<void> _loadSquad(int id) async {
    setState(() { _isLoading = true; _error = null; });
    final result = await _playerService.getSquadByTournament(id);
    if (mounted) setState(() {
      _squad = result;
      _isLoading = false;
      if (result == null) _error = 'Gagal memuat skuad.';
    });
  }

  List<PlayerModel> get _filtered {
    if (_squad == null) return [];
    if (_filterPos == null) return _squad!.allPlayers;
    return _squad!.squad[_filterPos!] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: _init,
        color: cs.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── AppBar ──────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: cs.surface,
              surfaceTintColor: cs.surfaceTint,
              title: Row(children: [
                Icon(Icons.groups_rounded, color: cs.primary, size: 22),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900, letterSpacing: 0.3),
                    children: [
                      TextSpan(
                          text: 'GARUDA ',
                          style: TextStyle(color: cs.onSurface)),
                      TextSpan(
                          text: 'SQUAD',
                          style: TextStyle(color: cs.primary)),
                    ],
                  ),
                ),
                if (_squad != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Text(
                      '${_squad!.totalPlayers} Pemain',
                      style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ]),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(42),
                child: SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    children: [
                      _Chip(
                        label: 'Semua',
                        active: _filterPos == null,
                        onTap: () => setState(() => _filterPos = null),
                        cs: cs,
                      ),
                      ..._posOrder.map((p) => _Chip(
                            label: _posLabel[p]!,
                            active: _filterPos == p,
                            onTap: () => setState(() => _filterPos = p),
                            cs: cs,
                          )),
                    ],
                  ),
                ),
              ),
            ),

            // ── States ──────────────────────────────────────────
            if (_isLoading)
              const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: cs.error),
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                          onPressed: _init,
                          child: const Text('Coba Lagi')),
                    ],
                  ),
                ),
              )
            else if (_filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.groups_outlined,
                          size: 52,
                          color: cs.onSurfaceVariant.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text('Belum ada pemain',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 14)),
                    ],
                  ),
                ),
              )
            else ...[
              if (_filterPos == null)
                ..._posOrder.map((pos) {
                  final list = _squad!.squad[pos] ?? [];
                  if (list.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  return _PositionSection(
                    pos: pos,
                    label: _posLabel[pos]!,
                    players: list,
                    onTap: _openDetail,
                  );
                })
              else
                _PositionSection(
                  pos: _filterPos!,
                  label: _posLabel[_filterPos]!,
                  players: _filtered,
                  onTap: _openDetail,
                  showHeader: false,
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }

  void _openDetail(PlayerModel p) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerDetailScreen(player: p)),
    );
  }
}

// ── Position Section ───────────────────────────────────────────────────

class _PositionSection extends StatelessWidget {
  final String pos, label;
  final List<PlayerModel> players;
  final ValueChanged<PlayerModel> onTap;
  final bool showHeader;

  const _PositionSection({
    required this.pos,
    required this.label,
    required this.players,
    required this.onTap,
    this.showHeader = true,
  });

  static const _posColor = {
    'GK':  Color(0xFFFFB300),
    'DEF': Color(0xFF42A5F5),
    'MID': Color(0xFF66BB6A),
    'FWD': Color(0xFFEF5350),
  };

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final tt  = Theme.of(context).textTheme;
    final col = _posColor[pos] ?? cs.primary;

    return SliverMainAxisGroup(slivers: [
      if (showHeader)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Row(children: [
              Container(
                  width: 3, height: 14,
                  decoration: BoxDecoration(
                      color: col,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(label.toUpperCase(),
                  style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: cs.onSurface)),
              const SizedBox(width: 6),
              Text('(${players.length})',
                  style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant)),
            ]),
          ),
        ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(12, showHeader ? 0 : 12, 12, 4),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => PlayerCard(
              player: players[i],
              onTap: () => onTap(players[i]),
            ),
            childCount: players.length,
          ),
        ),
      ),
    ]);
  }
}

// ── Chip Filter ────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _Chip({required this.label, required this.active,
      required this.onTap, required this.cs});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: active ? cs.primary : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? cs.onPrimary : cs.onSurfaceVariant)),
        ),
      ),
    );
  }
}
