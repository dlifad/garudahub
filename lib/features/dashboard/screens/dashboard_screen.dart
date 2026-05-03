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

// Mini Games
import 'package:garudahub/features/mini_games/screens/mini_games_screen.dart';

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
  late final AnimationController _miniGameAnim;

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
    _miniGameAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
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
    _miniGameAnim.dispose();
    super.dispose();
  }

  void _playEntrance() {
    _heroAnim.forward();
    Future.delayed(
      const Duration(milliseconds: 150),
      () => mounted ? _matchAnim.forward() : null,
    );
    Future.delayed(
      const Duration(milliseconds: 300),
      () => mounted ? _predAnim.forward() : null,
    );
    Future.delayed(
      const Duration(milliseconds: 420),
      () => mounted ? _miniGameAnim.forward() : null,
    );
    Future.delayed(
      const Duration(milliseconds: 500),
      () => mounted ? _newsAnim.forward() : null,
    );
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
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
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
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic)),
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
              // ── Top Bar ──────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sports_soccer,
                      size: 20,
                      color: cs.onPrimary,
                    ),
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
                                  builder: (_) => const NotificationScreen(),
                                ),
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
                                builder: (_) => const NotificationScreen(),
                              ),
                            );
                            await _loadNotifCount();
                          },
                          icon: const Icon(Icons.notifications_outlined),
                        ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Hero ─────────────────────────────────────────────────
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

              // ── Pertandingan Berikutnya ───────────────────────────────
              const SectionTitle('Pertandingan Berikutnya'),
              const SizedBox(height: 12),
              _animated(
                ctrl: _matchAnim,
                begin: const Offset(0.3, 0),
                child: NextMatchCard(isLoading: _isLoading, match: _nextMatch),
              ),
              const SizedBox(height: 20),

              // ── Quick Actions: GarudaBot | Prediksi ──────────────────
              _animated(
                ctrl: _predAnim,
                begin: const Offset(0, 0.2),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
              ),
              const SizedBox(height: 20),

              // ── ✨ Mini Game Banner ───────────────────────────────────
              _animated(
                ctrl: _miniGameAnim,
                begin: const Offset(0, 0.4),
                child: _MiniGameBanner(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MiniGamesScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Berita Terbaru ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle('Berita Terbaru'),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewsScreen()),
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
                    builder: (_) => NewsDetailScreen(news: item),
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(_errorText!, style: TextStyle(color: cs.error)),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mini Game Banner ──────────────────────────────────────────────────────────
class _MiniGameBanner extends StatefulWidget {
  final VoidCallback onTap;
  const _MiniGameBanner({required this.onTap});

  @override
  State<_MiniGameBanner> createState() => _MiniGameBannerState();
}

class _MiniGameBannerState extends State<_MiniGameBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerCtrl,
        builder: (_, __) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF14532D),
                  Color(0xFF166534),
                  Color(0xFF15803D),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF22C55E).withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ikon bola + shimmer ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4ADE80).withOpacity(
                            0.3 +
                                0.4 *
                                    (0.5 +
                                        0.5 *
                                            (_shimmerCtrl.value * 2 - 1).abs()),
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('⚽', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Teks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Mini Games',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ADE80).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF4ADE80).withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Color(0xFF4ADE80),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Adu penalti pakai gyro HP kamu!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
