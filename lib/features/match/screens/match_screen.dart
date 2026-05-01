import 'package:flutter/material.dart';
import 'package:garudahub/features/match/models/match_item.dart';
import 'package:garudahub/features/match/models/match_record.dart';
import 'package:garudahub/features/match/models/tournament_coach.dart';
import 'package:garudahub/features/match/models/tournament_model.dart';
import 'package:garudahub/features/match/services/match_service.dart';
import 'package:garudahub/features/match/widgets/record_stats_card.dart';
import 'package:garudahub/features/match/widgets/tournament_section.dart';
import 'package:garudahub/features/match/widgets/year_selector.dart';
// kAllTimeYear = -1 (all time sentinel)

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});
  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen>
    with AutomaticKeepAliveClientMixin {
  final _service = MatchService();

  List<TournamentModel>               _allTournaments = [];
  final Map<int, List<MatchItem>>     _matchCache     = {};
  final Map<int, List<TournamentCoach>> _coachCache   = {};
  final Set<int>                      _loadingSet     = {};

  List<int> _years            = [];
  int       _selectedYear     = DateTime.now().year;
  bool      _isLoading        = true;
  String?   _error;

  @override bool get wantKeepAlive => true;

  @override
  void initState() { super.initState(); _init(); }

  List<TournamentModel> get _tournamentsForYear => _selectedYear == kAllTimeYear
      ? _allTournaments
      : _allTournaments.where((t) => t.year == _selectedYear).toList();

  bool get _yearIsLoading =>
      _tournamentsForYear.any((t) => _loadingSet.contains(t.id));

  MatchRecord get _recordForYear {
    final all = _tournamentsForYear
        .expand((t) => _matchCache[t.id] ?? const <MatchItem>[]).toList();
    return _service.computeRecord(all);
  }

  Future<void> _init() async {
    setState(() { _isLoading = true; _error = null; });
    final list = await _service.getTournaments();
    if (list.isEmpty && mounted) {
      setState(() { _isLoading = false; _error = 'Gagal memuat data. Coba lagi.'; });
      return;
    }
    final years = list.map((t) => t.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    if (years.isEmpty) years.add(DateTime.now().year);
    // All Time ditambah di YearSelector, tapi kita simpan di _years juga
    if (!years.contains(kAllTimeYear)) years.add(kAllTimeYear);
    final defaultYear = years.contains(DateTime.now().year)
        ? DateTime.now().year : years.first;
    if (mounted) {
      setState(() {
        _allTournaments = list;
        _years          = years;
        _selectedYear   = defaultYear;
        _isLoading      = false;
      });
    }
    await _loadDataForYear(defaultYear);
  }

  Future<void> _loadDataForYear(int year) async {
    final tours  = _allTournaments.where((t) => t.year == year).toList();
    final toLoad = tours.where((t) => !_matchCache.containsKey(t.id)).toList();
    if (toLoad.isEmpty) return;
    if (mounted) setState(() => _loadingSet.addAll(toLoad.map((t) => t.id)));
    await Future.wait(toLoad.map((t) async {
      final results = await Future.wait([
        _service.getMatchesByTournament(t.id),
        _service.getTournamentCoaches(t.id),
      ]);
      if (mounted) setState(() {
        _matchCache[t.id] = results[0] as List<MatchItem>;
        _coachCache[t.id] = results[1] as List<TournamentCoach>;
        _loadingSet.remove(t.id);
      });
    }));
  }

  Future<void> _changeYear(int year) async {
    if (year == _selectedYear) return;
    setState(() => _selectedYear = year);
    await _loadDataForYear(year);
  }

  Future<void> _refresh() async {
    _matchCache.clear(); _coachCache.clear(); _loadingSet.clear();
    setState(() { _allTournaments = []; _years = []; });
    await _init();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: cs.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: cs.surface,
              surfaceTintColor: cs.surfaceTint,
              title: Row(children: [
                Icon(Icons.sports_soccer_rounded, color: cs.primary, size: 22),
                const SizedBox(width: 8),
                Text('Match', style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800, letterSpacing: 0.3)),
              ]),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh_rounded,
                      color: cs.onSurfaceVariant),
                  onPressed: _isLoading ? null : _refresh,
                ),
                const SizedBox(width: 4),
              ],
              bottom: (_isLoading || _years.isEmpty) ? null :
                  PreferredSize(
                    preferredSize: const Size.fromHeight(58),
                    child: Column(children: [
                      YearSelector(years: _years, selected: _selectedYear,
                          onChanged: _changeYear),
                      const SizedBox(height: 8),
                    ]),
                  ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(
                  child: _ErrorState(message: _error!, onRetry: _init))
            else ...[
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: RecordStatsCard(
                  year: _selectedYear,
                  record: _recordForYear,
                  isLoading: _yearIsLoading,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(children: [
                    Container(width: 3, height: 14,
                        decoration: BoxDecoration(color: cs.primary,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    Text('TURNAMEN $_selectedYear',
                        style: tt.labelMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        )),
                    const SizedBox(width: 8),
                    if (_yearIsLoading)
                      SizedBox(width: 12, height: 12,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: cs.primary)),
                  ]),
                ),
              ),
              if (_tournamentsForYear.isEmpty)
                SliverToBoxAdapter(child: _EmptyYear(year: _selectedYear))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final t = _tournamentsForYear[i];
                      return TournamentSection(
                        tournament: t,
                        matches:   _matchCache[t.id] ?? [],
                        coaches:   _coachCache[t.id] ?? [],
                        isLoading: _loadingSet.contains(t.id),
                        initiallyExpanded: i == 0,
                      );
                    },
                    childCount: _tournamentsForYear.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyYear extends StatelessWidget {
  const _EmptyYear({required this.year});
  final int year;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(children: [
        Icon(Icons.sports_soccer_outlined, size: 52,
            color: cs.onSurfaceVariant.withOpacity(0.35)),
        const SizedBox(height: 12),
        Text('Belum ada turnamen di $year',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
      ]),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Coba Lagi'),
          ),
        ]),
      ),
    );
  }
}
