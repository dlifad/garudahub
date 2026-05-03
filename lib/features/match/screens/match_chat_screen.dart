import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:garudahub/features/match/models/match_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ────────────────────────────────────────────────
// Model pesan (dari Supabase)
// ────────────────────────────────────────────────
class MatchChatMessage {
  final String  id;
  final String  matchId;
  final String  userId;
  final String  username;
  final String  avatarEmoji;
  final String  body;
  final String? type; // null=normal, 'predict','chant'
  final DateTime createdAt;

  const MatchChatMessage({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.username,
    required this.avatarEmoji,
    required this.body,
    this.type,
    required this.createdAt,
  });

  factory MatchChatMessage.fromMap(Map<String, dynamic> m) =>
      MatchChatMessage(
        id:          m['id']           as String,
        matchId:     m['match_id']     as String,
        userId:      m['user_id']      as String,
        username:    m['username']     as String,
        avatarEmoji: m['avatar_emoji'] as String? ?? '🦅',
        body:        m['body']         as String,
        type:        m['type']         as String?,
        createdAt:   DateTime.parse(m['created_at'] as String),
      );
}

// ────────────────────────────────────────────────
// Screen
// ────────────────────────────────────────────────
class MatchChatScreen extends StatefulWidget {
  const MatchChatScreen({super.key, required this.match});
  final MatchItem match;

  @override
  State<MatchChatScreen> createState() => _MatchChatScreenState();
}

class _MatchChatScreenState extends State<MatchChatScreen>
    with TickerProviderStateMixin {

  static final _sb       = Supabase.instance.client;
  static const _table    = 'match_chats';
  static const _emojis   = ['🦅','🇮🇩','⚽','🔥','💪','🎯','🏆','😎'];
  static const _chants   = [
    'Ayo Garuda! 🦅🔥',
    'Indonesia Bisa! 💪',
    'Merah Putih Juara! 🇮🇩',
    'Garuda di Dadaku! ❤️',
  ];

  final _ctrl    = TextEditingController();
  final _scroll  = ScrollController();
  final _focusNode = FocusNode();

  List<MatchChatMessage> _messages = [];
  bool   _loading     = true;
  bool   _sending     = false;
  String _msgType     = 'normal'; // normal | predict | chant
  bool   _showChants  = false;
  bool   _showScrollBtn = false;

  RealtimeChannel? _channel;

  late final AnimationController _fabAnim;

  String get _matchId => '${widget.match.id}';
  String get _me      => _sb.auth.currentUser?.id ?? 'anon';
  String get _myName  {
    final u = _sb.auth.currentUser;
    return u?.userMetadata?['full_name'] as String?
        ?? u?.email?.split('@').first
        ?? 'Garuda Fan';
  }
  String get _myEmoji {
    final code = _me.codeUnitAt(0) % _emojis.length;
    return _emojis[code];
  }

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 250));
    _scroll.addListener(_onScroll);
    _load();
    _subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _ctrl.dispose();
    _scroll.dispose();
    _focusNode.dispose();
    _fabAnim.dispose();
    super.dispose();
  }

  void _onScroll() {
    final atBottom = _scroll.offset >=
        (_scroll.position.maxScrollExtent - 80);
    if (!atBottom && !_showScrollBtn) {
      setState(() => _showScrollBtn = true);
      _fabAnim.forward();
    } else if (atBottom && _showScrollBtn) {
      _fabAnim.reverse().then((_) {
        if (mounted) setState(() => _showScrollBtn = false);
      });
    }
  }

  // ── Fetch history ──────────────────────────────
  Future<void> _load() async {
    try {
      final rows = await _sb
          .from(_table)
          .select()
          .eq('match_id', _matchId)
          .order('created_at')
          .limit(200);
      if (mounted) {
        setState(() {
          _messages = (rows as List)
              .map((r) => MatchChatMessage.fromMap(r as Map<String, dynamic>))
              .toList();
          _loading  = false;
        });
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToBottom(animate: false));
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Realtime subscription ──────────────────────
  void _subscribe() {
    _channel = _sb
        .channel('match_chat_$_matchId')
        .onPostgresChanges(
          event:  PostgresChangeEvent.insert,
          schema: 'public',
          table:  _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: _matchId,
          ),
          callback: (payload) {
            final msg = MatchChatMessage.fromMap(
                payload.newRecord as Map<String, dynamic>);
            if (mounted) {
              setState(() => _messages.add(msg));
              final atBottom = _scroll.hasClients &&
                  _scroll.offset >=
                      (_scroll.position.maxScrollExtent - 120);
              if (atBottom) _scrollToBottom();
            }
          },
        )
        .subscribe();
  }

  // ── Send ───────────────────────────────────────
  Future<void> _send({String? overrideText, String? overrideType}) async {
    final text = (overrideText ?? _ctrl.text).trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _ctrl.clear();
    try {
      await _sb.from(_table).insert({
        'match_id':    _matchId,
        'user_id':     _me,
        'username':    _myName,
        'avatar_emoji':_myEmoji,
        'body':        text,
        'type':        overrideType ?? (_msgType == 'normal' ? null : _msgType),
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal kirim pesan, coba lagi.')));
      }
    } finally {
      if (mounted) setState(() { _sending = false; _msgType = 'normal'; });
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scroll.hasClients) return;
    if (animate) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scroll.jumpTo(_scroll.position.maxScrollExtent + 200);
    }
  }

  // ────────────────────────────────────────────────
  // Build
  // ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final tt  = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isUpcoming = widget.match.result == null;
    final vs = widget.match.opponentName;

    return Scaffold(
      backgroundColor: AppColors.softBackground(cs, isDark: isDark),
      // ── AppBar ──
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0001),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: AppSpacing.xs - 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diskusi Laga',
              style: tt.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14),
            ),
            Text(
              'Indonesia vs $vs',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: [
          // mini scoreboard / status
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md - 2, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              const Text('🇮🇩', style: TextStyle(fontSize: 13)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isUpcoming
                    ? 'vs'
                    : '${widget.match.indonesiaScore ?? 0} - ${widget.match.opponentScore ?? 0}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(widget.match.opponentFlag ?? '🏳️',
                  style: const TextStyle(fontSize: 13)),
            ]),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xFFCC0001), Color(0xFF8B0000)
              ]),
            ),
          ),
        ),
      ),

      body: Column(children: [
        // ── Messages list ──
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _messages.isEmpty
                  ? _EmptyChat(vs: vs)
                  : Stack(children: [
                      ListView.builder(
                        controller:   _scroll,
                        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
                        itemCount:    _messages.length,
                        itemBuilder:  (ctx, i) {
                          final msg    = _messages[i];
                          final isMine = msg.userId == _me;
                          final prev   = i > 0 ? _messages[i - 1] : null;
                          final showName = !isMine &&
                              (prev == null || prev.userId != msg.userId);
                          return _ChatBubble(
                            msg:       msg,
                            isMine:    isMine,
                            showName:  showName,
                            isDark:    isDark,
                          );
                        },
                      ),
                      // FAB scroll-to-bottom
                      if (_showScrollBtn)
                        Positioned(
                          right: 12, bottom: 8,
                          child: ScaleTransition(
                            scale: CurvedAnimation(
                                parent: _fabAnim,
                                curve: Curves.elasticOut),
                            child: FloatingActionButton.small(
                              onPressed: _scrollToBottom,
                              backgroundColor: const Color(0xFFCC0001),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              child: const Icon(
                                  Icons.keyboard_arrow_down_rounded),
                            ),
                          ),
                        ),
                    ]),
        ),

        // ── Chant shortcut row ──
        if (_showChants) _ChantRow(
          chants: _chants,
          onTap: (c) {
            setState(() => _showChants = false);
            _send(overrideText: c, overrideType: 'chant');
          },
        ),

        // ── Input bar ──
        _InputBar(
          ctrl:         _ctrl,
          focusNode:    _focusNode,
          msgType:      _msgType,
          sending:      _sending,
          showChants:   _showChants,
          onTypeChanged: (t) => setState(() => _msgType = t),
          onToggleChants: () => setState(() => _showChants = !_showChants),
          onSend:       _send,
        ),
      ]),
    );
  }
}

// ────────────────────────────────────────────────
// Bubble
// ────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.msg,
    required this.isMine,
    required this.showName,
    required this.isDark,
  });
  final MatchChatMessage msg;
  final bool isMine, showName, isDark;

  Color _userColor(String uid) {
    const colors = [
      Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFF43A047),
      Color(0xFFFB8C00), Color(0xFF8E24AA), Color(0xFF00897B),
    ];
    return colors[uid.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final isPredict = msg.type == 'predict';
    final isChant   = msg.type == 'chant';

    Color bubbleBg;
    if (isMine) {
      bubbleBg = const Color(0xFFCC0001);
    } else if (isPredict) {
      bubbleBg = isDark
          ? const Color(0xFF1B3A2A)
          : const Color(0xFFE8F5E9);
    } else if (isChant) {
      bubbleBg = isDark
          ? const Color(0xFF3E2A00)
          : const Color(0xFFFFF3E0);
    } else {
      bubbleBg = isDark
          ? const Color(0xFF2A2A2A)
          : Colors.white;
    }

    final radius = BorderRadius.only(
      topLeft:     const Radius.circular(18),
      topRight:    const Radius.circular(18),
      bottomLeft:  Radius.circular(isMine ? 18 : 4),
      bottomRight: Radius.circular(isMine ? 4 : 18),
    );

    return Padding(
      padding: EdgeInsets.only(
        top:    showName ? 12 : 3,
        bottom: 2,
        left:   isMine ? 48 : 0,
        right:  isMine ? 0  : 48,
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showName && !isMine)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs - 1),
              child: Row(children: [
                Text(msg.avatarEmoji,
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(width: AppSpacing.xs + 1),
                Text(
                  msg.username,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _userColor(msg.userId),
                  ),
                ),
              ]),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 1, vertical: AppSpacing.sm + 1),
            decoration: BoxDecoration(
              color:       bubbleBg,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.07),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPredict)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(children: [
                      const Text('🔮', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Prediksi Skor',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[700],
                          )),
                    ]),
                  ),
                if (isChant)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(children: [
                      const Text('📣', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Yel-Yel',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange[700],
                          )),
                    ]),
                  ),
                Text(
                  msg.body,
                  style: TextStyle(
                    color: isMine ? Colors.white : cs.onSurface,
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs - 1),
                Text(
                  _time(msg.createdAt),
                  style: TextStyle(
                    fontSize: 9.5,
                    color: isMine
                        ? Colors.white54
                        : cs.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _time(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ────────────────────────────────────────────────
// Input Bar
// ────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.ctrl,
    required this.focusNode,
    required this.msgType,
    required this.sending,
    required this.showChants,
    required this.onTypeChanged,
    required this.onToggleChants,
    required this.onSend,
  });
  final TextEditingController ctrl;
  final FocusNode focusNode;
  final String  msgType;
  final bool    sending, showChants;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onToggleChants;
  final Future<void> Function({String? overrideText, String? overrideType}) onSend;

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(left: AppSpacing.sm, right: AppSpacing.sm, top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? AppSpacing.sm : MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(
              color: cs.outline.withOpacity(0.12), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(children: [
        // Predict button
        _TypeBtn(
          icon: '🔮',
          active:  msgType == 'predict',
          tooltip: 'Prediksi Skor',
          onTap:   () => onTypeChanged(
              msgType == 'predict' ? 'normal' : 'predict'),
        ),
        const SizedBox(width: AppSpacing.xs),
        // Chant button
        _TypeBtn(
          icon:    '📣',
          active:  showChants,
          tooltip: 'Yel-Yel',
          onTap:   onToggleChants,
        ),
        const SizedBox(width: AppSpacing.sm),
        // Text field
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 120),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              controller:  ctrl,
              focusNode:   focusNode,
              maxLines:    null,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: msgType == 'predict'
                    ? 'Prediksi skor... mis: 2-1'
                    : 'Tulis komentar...',
                hintStyle: TextStyle(
                    color: cs.onSurfaceVariant.withOpacity(0.5),
                    fontSize: 13),
                border:      InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md - 2),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Send button
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: sending
                ? cs.surfaceContainerHighest
                : const Color(0xFFCC0001),
            shape: BoxShape.circle,
          ),
          child: sending
              ? const Padding(
                  padding: EdgeInsets.all(AppSpacing.md - 2),
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: Colors.white))
              : IconButton(
                  onPressed: onSend,
                  icon: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
                  padding: EdgeInsets.zero,
                ),
        ),
      ]),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  const _TypeBtn({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });
  final String icon;
  final bool   active;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFCC0001).withOpacity(0.12)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: active
                ? Border.all(
                    color: const Color(0xFFCC0001).withOpacity(0.4))
                : null,
          ),
          alignment: Alignment.center,
          child: Text(icon, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Chant Row
// ────────────────────────────────────────────────
class _ChantRow extends StatelessWidget {
  const _ChantRow({required this.chants, required this.onTap});
  final List<String> chants;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      color: cs.surfaceContainerLow,
      child: ListView.separated(
        scrollDirection:   Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm - 2),
        itemCount:         chants.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) => InkWell(
          onTap: () => onTap(chants[i]),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2, vertical: AppSpacing.xs + 1),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8F00).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFFF8F00).withOpacity(0.35)),
            ),
            child: Text(chants[i],
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Empty State
// ────────────────────────────────────────────────
class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.vs});
  final String vs;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🦅', style: TextStyle(fontSize: 52)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Jadilah yang pertama\nberdiskusi tentang laga ini!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm - 2),
          Text(
            'Indonesia vs $vs',
            style: TextStyle(
                fontSize: 12, color: cs.onSurfaceVariant.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}


