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

  List<TournamentModel> _tournaments     = [];
  List<TournamentModel> _filledTournaments = []; // hanya yang punya pemain
  TournamentModel?      _selectedTournament;
  SquadResponse?        _squad;
  bool    _isLoading = true;
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

    // Urutkan dari terbaru ke terlama
    final sorted = List<TournamentModel>.from(tours)
      ..sort((a, b) {
        final aMs = a.endDate?.millisecondsSinceEpoch ?? (a.year * 10000);
        final bMs = b.endDate?.millisecondsSinceEpoch ?? (b.year * 10000);
        return bMs.compareTo(aMs);
      });

    // Cari tournament terbaru yang punya pemain
    TournamentModel? selectedTour;
    SquadResponse?   firstSquad;
    final filled = <TournamentModel>[];

    for (final t in sorted) {
      final squad = await _playerService.getSquadByTournament(t.id);
      if (squad != null && squad.totalPlayers > 0) {
        filled.add(t);
        selectedTour ??= t;
        firstSquad   ??= squad;
      }
    }

    if (mounted) {
      setState(() {
        _tournaments          = sorted;
        _filledTournaments    = filled;
        _selectedTournament   = selectedTour;
        _squad                = firstSquad;
        _isLoading            = false;
        if (selectedTour == null) _error = 'Belum ada skuad yang tersedia.';
      });
    }
  }

  Future<void> _loadSquad(TournamentModel tour) async {
    setState(() { _isLoading = true; _error = null; _filterPos = null; });
    final result = await _playerService.getSquadByTournament(tour.id);
    if (mounted) {
      setState(() {
        _selectedTournament = tour;
        _squad      = result;
        _isLoading  = false;
        if (result == null) _error = 'Gagal memuat skuad.';
      });
    }
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
      appBar: AppBar(
        title: const Text('GARUDA SQUAD'),
        titleTextStyle: tt.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
        actions: [
          if (_squad != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text('${_squad!.totalPlayers} Pemain'),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Tournament Picker ──────────────────────────────────────
          if (_filledTournaments.length > 1)
            _TournamentPicker(
              tournaments: _filledTournaments,
              selected: _selectedTournament,
              onSelect: _loadSquad,
            ),

          // ── Position Filter Chips ──────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _FilterChip(
                  label: 'Semua',
                  selected: _filterPos == null,
                  onTap: () => setState(() => _filterPos = null),
                ),
                ..._posOrder.map((pos) => _FilterChip(
                  label: _posLabel[pos]!,
                  selected: _filterPos == pos,
                  onTap: () => setState(() => _filterPos = pos),
                )),
              ],
            ),
          ),

          // ── Body ───────────────────────────────────────────────────
          Expanded(child: _buildBody(cs, tt)),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme cs, TextTheme tt) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 8),
            Text(_error!, style: tt.bodyMedium),
            const SizedBox(height: 16),
            FilledButton(onPressed: _init, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    final players = _filtered;
    if (players.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada pemain', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Kalau filter posisi aktif → flat list
    if (_filterPos != null) {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: players.length,
        itemBuilder: (_, i) => PlayerCard(
          player: players[i],
          onTap: () => _goDetail(players[i]),
        ),
      );
    }

    // Grouped by position
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: _posOrder.map((pos) {
        final list = _squad!.squad[pos] ?? [];
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                _posLabel[pos]!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...list.map((p) => PlayerCard(
              player: p,
              onTap: () => _goDetail(p),
            )),
          ],
        );
      }).toList(),
    );
  }

  void _goDetail(PlayerModel player) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerDetailScreen(
          player: player,
          tournamentId: _selectedTournament?.id,
        ),
      ),
    );
  }
}

// ── Widget Helpers ─────────────────────────────────────────────────────────────

class _TournamentPicker extends StatelessWidget {
  final List<TournamentModel> tournaments;
  final TournamentModel?      selected;
  final void Function(TournamentModel) onSelect;

  const _TournamentPicker({
    required this.tournaments,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: tournaments.length,
        itemBuilder: (_, i) {
          final t = tournaments[i];
          final isSelected = selected?.id == t.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(t.name, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (_) => onSelect(t),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool   selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
