
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garudahub/features/match/models/chat_message.dart';
import 'package:garudahub/features/match/models/match_item.dart';
import 'package:intl/intl.dart';

// ─── Dummy "me" user ──────────────────────────────────────────────────────
const _myUserId   = 'me_001';
const _myUsername = 'GarudaFan';

// ─── Yel-yel shortcuts ───────────────────────────────────────────────────
const _cheers = [
  'Ayo Garuda! \u{1F1EE}\u{1F1E9}',
  'Indonesia Juara! \u{1F3C6}',
  'Garuda di dadaku! \u2764\uFE0F',
  'Hajar lawan! \u26BD',
  'Majulah Indonesiaku! \u{1F525}',
];

// ─── Dummy messages for demo ──────────────────────────────────────────────
List<ChatMessage> _dummyMessages(MatchItem match) {
  final rng = Random(match.id);
  final users = [
    ('usr_a', 'BungKarno12'),
    ('usr_b', 'GarudaMuda'),
    ('usr_c', 'SurabayaFC'),
    ('usr_d', 'JakartaKickOff'),
    ('usr_e', 'MerahPutih99'),
  ];
  final msgs = <ChatMessage>[];
  final now  = DateTime.now();
  final texts = [
    'Semangat Indonesia! \u{1F1EE}\u{1F1E9}',
    'Prediksi gue 3-0 buat Garuda',
    'Pemain kita lagi on fire banget',
    'Siapa yang nonton bareng?',
    'Formasi ${match.formation ?? '4-3-3'} udah pas banget',
    'Pelatihnya strategi keren sih',
    'Gas gas gas Garuda!!!',
    'Ayo kita menang!',
  ];
  for (int i = 0; i < 6; i++) {
    final u = users[rng.nextInt(users.length)];
    msgs.add(ChatMessage(
      id: 'dummy_$i',
      userId: u.$1,
      username: u.$2,
      text: texts[rng.nextInt(texts.length)],
      createdAt: now.subtract(Duration(minutes: 30 - i * 5)),
      type: ChatMessageType.text,
    ));
  }
  if (match.isFinished && match.goals != null && match.goals!.isNotEmpty) {
    final g = match.goals!.first;
    msgs.add(ChatMessage(
      id: 'goal_0',
      userId: 'sys',
      username: 'System',
      text: '\u26BD GOL! ${g.scorerName} menit ${g.minute}\'',
      createdAt: now.subtract(const Duration(minutes: 10)),
      type: ChatMessageType.goal,
    ));
  }
  msgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return msgs;
}

// ═════════════════════════════════════════════════════════════════════════
class MatchChatScreen extends StatefulWidget {
  const MatchChatScreen({super.key, required this.match});
  final MatchItem match;

  @override
  State<MatchChatScreen> createState() => _MatchChatScreenState();
}

class _MatchChatScreenState extends State<MatchChatScreen>
    with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  final _inputCtrl  = TextEditingController();
  final _focusNode  = FocusNode();
  late List<ChatMessage> _messages;
  bool _showScrollFab = false;
  bool _showCheers    = false;
  late AnimationController _sendAnim;

  @override
  void initState() {
    super.initState();
    _messages = _dummyMessages(widget.match);
    _sendAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scrollCtrl.addListener(() {
      final atBottom = _scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 80;
      if (atBottom == _showScrollFab) {
        setState(() => _showScrollFab = !atBottom);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _inputCtrl.dispose();
    _focusNode.dispose();
    _sendAnim.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    if (animated) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    }
  }

  void _sendMessage(String text, {ChatMessageType type = ChatMessageType.text}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        userId: _myUserId,
        username: _myUsername,
        text: trimmed,
        createdAt: DateTime.now(),
        type: type,
        isMe: true,
      ));
      _showCheers = false;
    });
    _inputCtrl.clear();
    _sendAnim.forward(from: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final m  = widget.match;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────
          _ChatHeader(match: m),

          // ── Messages ───────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, i) {
                    final msg  = _messages[i];
                    final prev = i > 0 ? _messages[i - 1] : null;
                    final showDate = prev == null ||
                        !_isSameDay(prev.createdAt, msg.createdAt);
                    final showName = !msg.isMe &&
                        (prev == null || prev.userId != msg.userId ||
                            showDate);
                    return Column(
                      children: [
                        if (showDate)
                          _DateSeparator(date: msg.createdAt),
                        _ChatBubble(
                            message: msg, showName: showName),
                      ],
                    );
                  },
                ),

                // Scroll-to-bottom FAB
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  bottom: _showScrollFab ? 12 : -60,
                  right: 12,
                  child: FloatingActionButton.small(
                    onPressed: () => _scrollToBottom(),
                    backgroundColor: cs.primaryContainer,
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: cs.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),

          // ── Cheer shortcuts ────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _showCheers
                ? Container(
                    color: cs.surfaceContainerHighest,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Wrap(
                      spacing: 8, runSpacing: 6,
                      children: _cheers.map((c) => ActionChip(
                        label: Text(c,
                            style: TextStyle(
                                fontSize: 12, color: cs.onSurface)),
                        backgroundColor: cs.surfaceContainer,
                        side: BorderSide(
                            color: cs.outline.withOpacity(0.2)),
                        onPressed: () => _sendMessage(c,
                            type: ChatMessageType.cheer),
                      )).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // ── Input bar ──────────────────────────────────────────
          _InputBar(
            controller: _inputCtrl,
            focusNode: _focusNode,
            showCheers: _showCheers,
            onToggleCheers: () =>
                setState(() => _showCheers = !_showCheers),
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Chat Header ───────────────────────────────────────────────────────────
class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.match});
  final MatchItem match;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFFCC0001), Color(0xFF7B0000)],
        ),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 16, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('Indonesia',
                          style: tt.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: match.isFinished
                            ? Text(
                                '${match.indonesiaScore} : ${match.opponentScore}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16))
                            : const Text('VS',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                      ),
                      Flexible(child: Text(match.opponentName,
                          style: tt.titleSmall?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.circle,
                          size: 7, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 5),
                      Text('1.2k online',
                          style: tt.labelSmall?.copyWith(
                              color: Colors.white60, fontSize: 11)),
                      const SizedBox(width: 12),
                      Icon(Icons.emoji_events_rounded,
                          size: 11, color: Colors.white54),
                      const SizedBox(width: 4),
                      Flexible(child: Text(match.tournamentName,
                          style: tt.labelSmall?.copyWith(
                              color: Colors.white54, fontSize: 11),
                          overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded,
                    color: Colors.white70, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chat Bubble ───────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.showName});
  final ChatMessage message;
  final bool        showName;

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final tt  = Theme.of(context).textTheme;
    final msg = message;

    // ── System / goal event ──────────────────────────────────────
    if (msg.type == ChatMessageType.goal ||
        msg.type == ChatMessageType.system) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: msg.type == ChatMessageType.goal
                    ? const Color(0xFF4CAF50).withOpacity(0.15)
                    : cs.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: msg.type == ChatMessageType.goal
                      ? const Color(0xFF4CAF50).withOpacity(0.4)
                      : cs.outline.withOpacity(0.2),
                ),
              ),
              child: Text(msg.text,
                  style: tt.labelSmall?.copyWith(
                      color: msg.type == ChatMessageType.goal
                          ? const Color(0xFF4CAF50)
                          : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ),
          ),
        ]),
      );
    }

    final isMe = msg.isMe;
    final isCheer = msg.type == ChatMessageType.cheer;

    // ── Bubble alignment ─────────────────────────────────────────
    return Padding(
      padding: EdgeInsets.only(
        top: showName ? 10 : 2,
        bottom: 0,
        left: isMe ? 48 : 0,
        right: isMe ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar (only for others, last in group)
          if (!isMe)
            Container(
              width: 28, height: 28,
              margin: const EdgeInsets.only(right: 6, bottom: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: msg.userColor.withOpacity(0.18),
                border: Border.all(
                    color: msg.userColor.withOpacity(0.5), width: 1.2),
              ),
              child: Center(
                child: Text(
                  msg.username.isNotEmpty
                      ? msg.username[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: msg.userColor,
                      fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),

          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (showName && !isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(msg.username,
                        style: TextStyle(
                            color: msg.userColor,
                            fontWeight: FontWeight.w700, fontSize: 11)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe
                        ? (isCheer
                            ? const Color(0xFFFF9800).withOpacity(0.9)
                            : const Color(0xFFCC0001))
                        : (isCheer
                            ? const Color(0xFFFF9800).withOpacity(0.12)
                            : cs.surfaceContainerHighest),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    border: !isMe
                        ? Border.all(
                            color: isCheer
                                ? Colors.orange.withOpacity(0.3)
                                : cs.outline.withOpacity(0.12))
                        : null,
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                  child: Text(
                    msg.text,
                    style: tt.bodySmall?.copyWith(
                      color: isMe ? Colors.white : cs.onSurface,
                      fontSize: 13, height: 1.35,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                  child: Text(
                    DateFormat('HH:mm').format(msg.createdAt),
                    style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant.withOpacity(0.5),
                        fontSize: 10),
                  ),
                ),
              ],
            ),
          ),

          if (isMe)
            const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ── Date Separator ────────────────────────────────────────────────────────
class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date});
  final DateTime date;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    String label;
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    if (d == today) label = 'Hari ini';
    else if (d == today.subtract(const Duration(days: 1))) label = 'Kemarin';
    else label = DateFormat('d MMMM yyyy', 'id_ID').format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(child: Divider(
            color: cs.outline.withOpacity(0.2), height: 1)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11, fontWeight: FontWeight.w500)),
        ),
        Expanded(child: Divider(
            color: cs.outline.withOpacity(0.2), height: 1)),
      ]),
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────
class _InputBar extends StatefulWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.showCheers,
    required this.onToggleCheers,
    required this.onSend,
  });
  final TextEditingController controller;
  final FocusNode             focusNode;
  final bool                  showCheers;
  final VoidCallback          onToggleCheers;
  final void Function(String, {ChatMessageType type}) onSend;

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(
        () => setState(() => _hasText = widget.controller.text.trim().isNotEmpty));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.only(
          left: 8, right: 8, top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(
            color: cs.outline.withOpacity(0.12))),
      ),
      child: Row(
        children: [
          // Yel-yel toggle
          IconButton(
            onPressed: widget.onToggleCheers,
            icon: Icon(
              widget.showCheers
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.campaign_rounded,
              color: widget.showCheers ? cs.primary : cs.onSurfaceVariant,
              size: 22,
            ),
            tooltip: 'Yel-yel',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),

          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outline.withOpacity(0.2)),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (v) =>
                    widget.onSend(v),
                style: TextStyle(color: cs.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  hintStyle: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.5),
                      fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hasText ? const Color(0xFFCC0001) : cs.surfaceContainer,
            ),
            child: IconButton(
              onPressed: _hasText
                  ? () => widget.onSend(widget.controller.text)
                  : null,
              icon: Icon(Icons.send_rounded,
                  size: 18,
                  color: _hasText ? Colors.white : cs.onSurfaceVariant),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
