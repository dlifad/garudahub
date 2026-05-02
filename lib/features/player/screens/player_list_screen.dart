import 'package:flutter/material.dart';
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
  final _service = PlayerService();

  List<PlayerModel> _players  = [];
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
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    final result = await _service.getActivePlayers();
    if (mounted) {
      setState(() {
        _players   = result;
        _isLoading = false;
        if (result.isEmpty) _error = 'Belum ada data pemain aktif.';
      });
    }
  }

  List<PlayerModel> get _filtered {
    if (_filterPos == null) return _players;
    return _players.where((p) => p.position == _filterPos).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        centerTitle: false,          // ← title ke kiri
        title: RichText(
          text: TextSpan(
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
            children: [
              const TextSpan(text: 'GARUDA '),
              TextSpan(
                text: 'SQUAD',
                style: TextStyle(color: cs.primary),
              ),
            ],
          ),
        ),
        actions: [
          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text('${_filtered.length} Pemain'),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter posisi ──────────────────────────────────────
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
            FilledButton(onPressed: _load, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
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

    // Flat grid kalau filter posisi aktif
    if (_filterPos != null) {
      return _PlayerGrid(players: _filtered, onTap: _goDetail);
    }

    // Grouped by position dengan section header
    return CustomScrollView(
      slivers: _posOrder.expand((pos) {
        final list = _players.where((p) => p.position == pos).toList();
        if (list.isEmpty) return <Widget>[];
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '${_posLabel[pos]!.toUpperCase()}  (${list.length})',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => PlayerCard(
                  player: list[i],
                  onTap: () => _goDetail(list[i]),
                ),
                childCount: list.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
            ),
          ),
        ];
      }).toList(),
    );
  }

  void _goDetail(PlayerModel player) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerDetailScreen(player: player),
      ),
    );
  }
}

// ── Grid helper (untuk flat list per posisi) ──────────────────────────────────
class _PlayerGrid extends StatelessWidget {
  final List<PlayerModel> players;
  final void Function(PlayerModel) onTap;
  const _PlayerGrid({required this.players, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: players.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, i) => PlayerCard(
        player: players[i],
        onTap: () => onTap(players[i]),
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────
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
