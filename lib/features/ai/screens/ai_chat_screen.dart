import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:garudahub/features/ai/models/chat_message_model.dart';
import 'package:garudahub/features/ai/services/gemini_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<AiChatMessage> _msgs = [];
  bool _loading = false;

  static const _suggestions = [
    '📅 Jadwal Timnas terdekat',
    '🔮 Prediksi skor next match',
    '📋 Prediksi lineup Timnas',
    '⚽ Top scorer Timnas Indonesia',
    '🏆 Prestasi terbaru Timnas',
  ];

  String? _getTemplateAnswer(String text) {
    final t = text.toLowerCase();
    if (t.contains('jadwal')) return _jadwalAnswer();
    if (t.contains('prediksi skor') || t.contains('next match'))
      return _prediksiSkorAnswer();
    if (t.contains('prediksi lineup') || t.contains('lineup'))
      return _lineupAnswer();
    if (t.contains('top scorer')) return _topScorerAnswer();
    if (t.contains('prestasi')) return _prestasiAnswer();
    return null;
  }

  String _jadwalAnswer() => """🗓 Jadwal Timnas Senior terdekat:

• Indonesia vs Oman
• FIFA Matchday
• 6 Juni 2026 | GBK Jakarta 🏟

Selanjutnya: Piala AFF/ASEAN Cup Juli–Agustus 2026 🏆

Pantau terus GarudaHub ya Sobat Garuda! 🦅""";

  String _prediksiSkorAnswer() => """🔮 Prediksi skor: Indonesia vs Oman

Indonesia 2-1 Oman 🇮🇩

• Kandang GBK — dukungan penuh Sobat Garuda
• Ole Romeny & Rafael Struick tajam di depan
• Oman tangguh tapi Indonesia lebih termotivasi

⚠️ Ini prediksi ya, bukan kepastian! 😄⚽""";

  String _lineupAnswer() => """📋 Prediksi Starting XI vs Oman
Formasi: 3-4-2-1

GK: Maarten Paes
CB: Jay Idzes (C) • Justin Hubner • Rizky Ridho
WB: Kevin Diks • Calvin Verdonk
CM: Ivar Jenner • Thom Haye
AM: Ragnar Oratmangoen • Eliano Reijnders
ST: Ole Romeny

Cadangan: Rafael Struick, Ernando Ari, Marc Klok, Pratama Arhan, Hokky Caraka

⚠️ Prediksi berdasarkan formasi Coach John Herdman 🦅""";

  String _topScorerAnswer() => """⚽ Top Scorer Timnas Indonesia

Sepanjang masa:
• 🥇 Soetjipto Soentoro (Gareng) — 57 gol / 68 caps

Era modern (aktif):
• Ole Romeny — top skorer terkini
• Ragnar Oratmangoen — produktif di kualifikasi
• Rafael Struick — ancaman di kotak penalti

Data lengkap cek pssi.id ya Sobat Garuda! 🦅""";

  String _prestasiAnswer() => """🏆 Prestasi terbaru Timnas Indonesia

• 2024 — Lolos Kualifikasi Piala Dunia 2026 Ronde 3 (sejarah!)
• 2023 — Runner-up Piala AFF U-23
• 2023 — Lolos Piala Asia (Qatar)
• 2022 — Juara AFF U-16 & U-19
• Peringkat FIFA naik signifikan

Era kebangkitan Garuda dimulai! 🦅🇮🇩""";

  @override
  void initState() {
    super.initState();
    _msgs.add(
      AiChatMessage(
        text:
            'Halo Sobat Garuda! 🦅\n\nAku GarudaBot, siap bantu kamu soal Timnas Indonesia sepak bola dan futsal. Mau tanya apa hari ini?',
        role: MessageRole.model,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    GeminiService.clearHistory();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _ctrl.text).trim();
    if (text.isEmpty || _loading) return;
    HapticFeedback.lightImpact();
    _ctrl.clear();

    setState(() {
      _msgs.add(AiChatMessage(text: text, role: MessageRole.user));
      _loading = true;
    });

    // Cek template dulu — jika cocok, tidak perlu ke Gemini
    final template = _getTemplateAnswer(text);
    if (template != null) {
      await Future.delayed(const Duration(milliseconds: 400)); // natural feel
      setState(() {
        _msgs.add(AiChatMessage(text: template, role: MessageRole.model));
        _loading = false;
      });
      _toBottom();
      return;
    }

    // Bukan template → kirim ke Gemini dengan loading bubble
    setState(() {
      _msgs.add(
        AiChatMessage(text: '', role: MessageRole.model, isLoading: true),
      );
    });
    _toBottom();

    final reply = await GeminiService.sendMessage(text);
    setState(() {
      _msgs.removeLast();
      _msgs.add(AiChatMessage(text: reply, role: MessageRole.model));
      _loading = false;
    });
    _toBottom();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0001),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              alignment: Alignment.center,
              child: const Text('🦅', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: AppSpacing.md - 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Garuda Bot',
                  style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs - 2),
                Text(
                  'Ai • Timnas Expert',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Reset chat',
            onPressed: () {
              GeminiService.clearHistory();
              setState(() {
                _msgs.clear();
                _msgs.add(
                  AiChatMessage(
                    text:
                        'Chat direset! Halo Sobat Garuda! 🦅 Mau tanya apa soal Timnas?',
                    role: MessageRole.model,
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_msgs.length <= 2)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) => ActionChip(
                  label: Text(
                    _suggestions[i],
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: const Color(0xFFCC0001).withOpacity(0.08),
                  side: BorderSide(
                    color: const Color(0xFFCC0001).withOpacity(0.3),
                  ),
                  onPressed: () => _send(_suggestions[i]),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
              itemCount: _msgs.length,
              itemBuilder: (_, i) {
                final m = _msgs[i];
                return m.isUser
                    ? _UserBubble(text: m.text)
                    : _BotBubble(text: m.text, loading: m.isLoading);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                top: BorderSide(color: cs.outline.withOpacity(0.12)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    enabled: !_loading,
                    decoration: InputDecoration(
                      hintText: 'Tanya soal Timnas Indonesia...',
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: _loading ? null : _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _loading
                          ? cs.surfaceContainer
                          : const Color(0xFFCC0001),
                    ),
                    child: _loading
                        ? const Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bubbles ──────────────────────────────────────────────────────────────
class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm, left: 56),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2, vertical: AppSpacing.md - 2),
        decoration: const BoxDecoration(
          color: Color(0xFFCC0001),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            height: 1.45,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

class _BotBubble extends StatefulWidget {
  const _BotBubble({required this.text, this.loading = false});
  final String text;
  final bool loading;

  @override
  State<_BotBubble> createState() => _BotBubbleState();
}

class _BotBubbleState extends State<_BotBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _dot;

  @override
  void initState() {
    super.initState();
    _dot = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _dot.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: AppSpacing.sm - 2, bottom: AppSpacing.sm),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFCC0001), Color(0xFF7B0000)],
              ),
            ),
            alignment: Alignment.center,
            child: const Text('🦅', style: TextStyle(fontSize: 13)),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm, right: 56),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2, vertical: AppSpacing.md - 2),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: cs.outline.withOpacity(0.12)),
              ),
              child: widget.loading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < 3; i++) ...[
                          AnimatedBuilder(
                            animation: _dot,
                            builder: (_, __) {
                              final t = ((_dot.value - i * 0.22) % 1.0);
                              final op = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(
                                0.3,
                                1.0,
                              );
                              return Opacity(
                                opacity: op,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (i < 2) const SizedBox(width: AppSpacing.xs),
                        ],
                      ],
                    )
                  : Text(
                      widget.text,
                      style: TextStyle(
                        color: cs.onSurface,
                        height: 1.45,
                        fontSize: 13.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

