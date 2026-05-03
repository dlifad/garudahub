import 'dart:async';

import 'package:flutter/material.dart';
import 'package:garudahub/core/providers/timezone_provider.dart';
import 'package:garudahub/features/auth/providers/auth_provider.dart';
import 'package:garudahub/features/dashboard/models/match_data.dart';
import 'package:garudahub/features/dashboard/services/dashboard_service.dart';
import 'package:garudahub/features/dashboard/widgets/ai_chat_widget.dart';
import 'package:garudahub/features/dashboard/widgets/hero_section.dart';
import 'package:garudahub/features/dashboard/widgets/news_list.dart';
import 'package:garudahub/features/dashboard/widgets/next_match_card.dart';
import 'package:garudahub/features/dashboard/widgets/prediction_mini_card.dart';
import 'package:garudahub/features/dashboard/widgets/section_title.dart';
import 'package:garudahub/features/notification/screens/notification_screen.dart';
import 'package:garudahub/features/notification/services/notification_inbox_service.dart';
import 'package:provider/provider.dart';

import 'package:garudahub/features/news/models/news_data.dart';
import 'package:garudahub/features/news/screen/news_screen.dart';
import 'package:garudahub/features/news/screen/news_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  static const int _fifaRank = 130;
  static const String _heroImageUrl =
      'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?auto=format&fit=crop&w=1200&q=80';

  final _service = DashboardService();

  late final AnimationController _heroAnim;
  late final AnimationController _matchAnim;
  late final AnimationController _predAnim;
  late final AnimationController _newsAnim;

  MatchData? _nextMatch;
  List<MatchData> _recentMatches = const [];
  List<NewsData> _news = const [];
  bool _isLoading = true;
  String? _errorText;

  Timer? _countdownTimer;
  Duration _timeToKickoff = Duration.zero;
  int _notifCount = 0;

  @override
  void initState() {
    super.initState();
    _heroAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _matchAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _predAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _newsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _playEntrance();
    _fetchData();
    _loadNotifCount();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _heroAnim.dispose();
    _matchAnim.dispose();
    _predAnim.dispose();
    _newsAnim.dispose();
    super.dispose();
  }

  void _playEntrance() {
    _heroAnim.forward();
    Future.delayed(
        const Duration(milliseconds: 150),
        () => mounted ? _matchAnim.forward() : null);
    Future.delayed(
        const Duration(milliseconds: 300),
        () => mounted ? _predAnim.forward() : null);
    Future.delayed(
        const Duration(milliseconds: 400),
        () => mounted ? _newsAnim.forward() : null);
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      final data = await _service.loadDashboardData();
      _nextMatch = data.nextMatch;
      _recentMatches = data.recentMatches;
      _news = data.news;
      _startCountdown();
    } catch (_) {
      _errorText = 'Gagal memuat beranda. Coba lagi.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateCountdown();
    _countdownTimer = Timer.periodic(
        const Duration(seconds: 1), (_) => _updateCountdown());
  }

  Future<void> _loadNotifCount() async {
    final count = await NotificationInboxService.instance.getUnreadCount();
    if (!mounted) return;
    setState(() => _notifCount = count);
  }

  void _updateCountdown() {
    final tzProvider = context.read<TimezoneProvider>();
    final target = _nextMatch == null
        ? null
        : tzProvider.convert(_nextMatch!.matchDateUtc);
    if (target == null || !mounted) return;
    setState(() {
      final now = tzProvider.convert(DateTime.now().toUtc());
      _timeToKickoff = target.difference(now);
    });
  }

  String _countdownLabel() {
    if (_timeToKickoff.inSeconds <= 0) return 'Match Selesai';
    if (_timeToKickoff.inDays >= 1) {
      final days = _timeToKickoff.inDays;
      final hours = _timeToKickoff.inHours % 24;
      return '${days}h ${hours}j lagi';
    }
    final h = _timeToKickoff.inHours.toString().padLeft(2, '0');
    final m = (_timeToKickoff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_timeToKickoff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Widget _animated({
    required Widget child,
    required AnimationController ctrl,
    required Offset begin,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic),
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
            CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.sports_soccer,
                        size: 20, color: cs.onPrimary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'GarudaHub',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  _notifCount > 0
                      ? Badge(
                          label: Text('$_notifCount'),
                          child: IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const NotificationScreen()),
                              );
                              await _loadNotifCount();
                            },
                            icon: const Icon(Icons.notifications_outlined),
                          ),
                        )
                      : IconButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationScreen()),
                            );
                            await _loadNotifCount();
                          },
                          icon: const Icon(Icons.notifications_outlined),
                        ),
                ],
              ),
              const SizedBox(height: 16),

              // Hero
              _animated(
                ctrl: _heroAnim,
                begin: const Offset(0, -0.3),
                child: HeroSection(
                  fifaRank: _fifaRank,
                  heroImageUrl: _heroImageUrl,
                  recentMatches: _recentMatches,
                  countdownLabel: _countdownLabel(),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Actions row: GarudaBot | Prediksi
              // Pakai Row biasa (bukan IntrinsicHeight) agar tidak overflow
              _animated(
                ctrl: _predAnim,
                begin: const Offset(0, 0.2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: AiChatWidget()),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PredictionMiniCard(
                        lastIndScore: 1,
                        lastOppScore: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Next Match
              const SectionTitle('Pertandingan Berikutnya'),
              const SizedBox(height: 12),
              _animated(
                ctrl: _matchAnim,
                begin: const Offset(0.3, 0),
                child: NextMatchCard(
                    isLoading: _isLoading, match: _nextMatch),
              ),
              const SizedBox(height: 20),

              // News
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle('Berita Terbaru'),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NewsScreen()),
                    ),
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              NewsList(
                isLoading: _isLoading,
                news: _news,
                newsAnim: _newsAnim,
                onTap: (item) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => NewsDetailScreen(news: item)),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(_errorText!,
                    style: TextStyle(color: cs.error)),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
