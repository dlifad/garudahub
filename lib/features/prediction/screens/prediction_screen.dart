import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:garudahub/core/constants/constants.dart';
import 'package:garudahub/features/auth/providers/auth_provider.dart';
import 'package:garudahub/features/auth/services/auth_service.dart';
import 'package:garudahub/features/dashboard/models/match_data.dart';
import 'package:garudahub/features/dashboard/services/dashboard_service.dart';

// ── Model ─────────────────────────────────────────────
class PredictionHistory {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final String homeFlag;
  final String awayFlag;
  final DateTime matchDate;
  final int predictedHome;
  final int predictedAway;
  final String status;

  const PredictionHistory({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeFlag,
    required this.awayFlag,
    required this.matchDate,
    required this.predictedHome,
    required this.predictedAway,
    required this.status,
  });

  factory PredictionHistory.fromJson(Map<String, dynamic> j) {
    return PredictionHistory(
      id: j['id'] as int,
      homeTeam: j['home_team'] as String? ?? '',
      awayTeam: j['away_team'] as String? ?? '',
      homeFlag: j['home_flag'] as String? ?? '',
      awayFlag: j['away_flag'] as String? ?? '',
      matchDate:
          DateTime.tryParse(j['match_date'] as String? ?? '') ?? DateTime.now(),
      predictedHome: j['predicted_indonesia_score'] as int? ?? 0,
      predictedAway: j['predicted_opponent_score'] as int? ?? 0,
      status: j['status'] as String? ?? 'pending',
    );
  }
}

// ── Screen ────────────────────────────────────────────
class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _dashService = DashboardService();
  final _scrollCtrl = ScrollController();

  MatchData? _nextMatch;
  int _indScore = 1;
  int _oppScore = 0;
  bool _predictionLocked = false;
  bool _submitting = false;
  String? _statusMsg;

  List<PredictionHistory> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadNextMatch(), _loadHistory()]);
  }

  Future<void> _loadNextMatch() async {
    try {
      final data = await _dashService.loadDashboardData();
      if (mounted) setState(() => _nextMatch = data.nextMatch);
    } catch (_) {}
  }

  Future<void> _loadHistory() async {
    if (mounted) setState(() => _loadingHistory = true);
    try {
      final token = await AuthService.getToken();
      final res = await http.get(
        Uri.parse('\${AppConstants.baseUrl}/predictions/mine'),
        headers: {
          if (token != null) 'Authorization': 'Bearer \$token',
        },
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final list = body['data'] as List? ?? [];
        if (mounted) {
          setState(() {
            _history = list
                .map((e) =>
                    PredictionHistory.fromJson(e as Map<String, dynamic>))
                .toList();
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _submitPrediction() async {
    if (_nextMatch == null) return;
    setState(() => _submitting = true);
    try {
      final token = await AuthService.getToken();
      final res = await http.post(
        Uri.parse('\${AppConstants.baseUrl}/predictions'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer \$token',
        },
        body: jsonEncode({
          'match_id': _nextMatch!.id,
          'predicted_indonesia_score': _indScore,
          'predicted_opponent_score': _oppScore,
        }),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201 || res.statusCode == 409) {
        setState(() {
          _predictionLocked = true;
          _statusMsg = body['message']?.toString();
        });
        await _loadHistory();
      } else {
        setState(() => _statusMsg = body['message']?.toString());
      }
    } catch (_) {
      setState(() => _statusMsg = 'Koneksi bermasalah');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _editPrediction(PredictionHistory item) async {
    setState(() {
      _indScore = item.predictedHome;
      _oppScore = item.predictedAway;
      _predictionLocked = false;
      _statusMsg = null;
    });
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
    final token = await AuthService.getToken();
    await http.delete(
      Uri.parse('\${AppConstants.baseUrl}/predictions/\${item.id}'),
      headers: {if (token != null) 'Authorization': 'Bearer \$token'},
    );
    await _loadHistory();
  }

  Future<void> _cancelPrediction(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan prediksi?'),
        content: const Text(
            'Prediksi ini akan dihapus dan tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFCC0001)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final token = await AuthService.getToken();
    await http.delete(
      Uri.parse('\${AppConstants.baseUrl}/predictions/\$id'),
      headers: {if (token != null) 'Authorization': 'Bearer \$token'},
    );
    await _loadHistory();
  }

  String _predSummary() {
    if (_indScore > _oppScore) return 'Indonesia Menang \$_indScore–\$_oppScore';
    if (_indScore < _oppScore) return 'Lawan Menang \$_indScore–\$_oppScore';
    return 'Imbang \$_indScore–\$_oppScore';
  }

  String _countryCode(String flag) =>
      flag.length >= 2 ? flag.substring(0, 2).toUpperCase() : flag.toUpperCase();

  String _formatDate(DateTime dt) {
    try {
      return DateFormat('EEE, d MMM yyyy', 'id_ID').format(dt.toLocal());
    } catch (_) {
      return DateFormat('EEE, d MMM yyyy').format(dt.toLocal());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final m = _nextMatch;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            controller: _scrollCtrl,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // ── Header ─────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Prediksi Skor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Input Card ─────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: cs.outline.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Siapa yang menang menurutmu?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    if (m != null) ...[  
                      const SizedBox(height: 3),
                      Text(
                        '\${m.homeTeam} vs \${m.awayTeam} · \${_formatDate(m.matchDateUtc)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Score stepper row
                    if (m == null)
                      Text('Belum ada pertandingan',
                          style:
                              TextStyle(color: cs.onSurfaceVariant))
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _teamCol(context, m.homeFlag, m.homeTeam),
                          const SizedBox(width: 10),
                          _stepperCol(
                            context,
                            score: _indScore,
                            onUp: _predictionLocked
                                ? null
                                : () => setState(() => _indScore++),
                            onDown: _predictionLocked
                                ? null
                                : () => setState(() =>
                                    _indScore =
                                        (_indScore - 1).clamp(0, 20)),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurfaceVariant
                                    .withOpacity(0.4),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          _stepperCol(
                            context,
                            score: _oppScore,
                            onUp: _predictionLocked
                                ? null
                                : () => setState(() => _oppScore++),
                            onDown: _predictionLocked
                                ? null
                                : () => setState(() =>
                                    _oppScore =
                                        (_oppScore - 1).clamp(0, 20)),
                          ),
                          const SizedBox(width: 10),
                          _teamCol(context, m.awayFlag, m.awayTeam),
                        ],
                      ),

                    const SizedBox(height: 18),

                    // Summary banner
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCC0001).withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              const Color(0xFFCC0001).withOpacity(0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCC0001),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFCC0001),
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Prediksimu: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  TextSpan(
                                    text: _predSummary(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_statusMsg != null) ...[  
                      const SizedBox(height: 8),
                      Text(
                        _statusMsg!,
                        style: TextStyle(
                          color: _predictionLocked
                              ? Colors.green.shade600
                              : cs.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFCC0001),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        onPressed:
                            (m == null || _predictionLocked || _submitting)
                                ? null
                                : _submitPrediction,
                        icon: _submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          _predictionLocked
                              ? 'Sudah Diprediksi'
                              : 'Kirim Prediksi',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Riwayat ────────────────────────────
              Text(
                'Riwayat Prediksi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              if (_loadingHistory)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ))
              else if (_history.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        const Text('⚽',
                            style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 10),
                        Text(
                          'Belum ada riwayat prediksi',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...(_history.map((item) => _historyItem(context, item))),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stepper ───────────────────────────────────────────
  Widget _stepperCol(
    BuildContext context, {
    required int score,
    VoidCallback? onUp,
    VoidCallback? onDown,
  }) {
    final cs = Theme.of(context).colorScheme;
    Widget btn(VoidCallback? fn, IconData icon) => GestureDetector(
          onTap: fn,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: fn != null
                  ? cs.onSurface
                  : cs.onSurface.withOpacity(0.25),
            ),
          ),
        );

    return Column(
      children: [
        btn(onUp, Icons.keyboard_arrow_up_rounded),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Text(
            '\$score',
            key: ValueKey(score),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        btn(onDown, Icons.keyboard_arrow_down_rounded),
      ],
    );
  }

  // ── Team label ────────────────────────────────────────
  Widget _teamCol(BuildContext context, String flag, String name) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          _countryCode(flag),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 58,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  // ── History Item ──────────────────────────────────────
  Widget _historyItem(BuildContext context, PredictionHistory item) {
    final cs = Theme.of(context).colorScheme;
    final isPending = item.status == 'pending';

    Color chipBg;
    Color chipFg;
    String chipLabel;
    switch (item.status) {
      case 'correct':
      case 'draw_correct':
        chipBg = Colors.green.shade50;
        chipFg = Colors.green.shade700;
        chipLabel = '🎯 Tepat!';
        break;
      case 'wrong':
        chipBg = Colors.red.shade50;
        chipFg = Colors.red.shade700;
        chipLabel = '❌ Meleset';
        break;
      default:
        chipBg = Colors.orange.shade50;
        chipFg = Colors.orange.shade700;
        chipLabel = '⏳ Menunggu';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\${item.homeTeam} vs \${item.awayTeam}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(item.matchDate),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chipLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: chipFg,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Score row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        _countryCode(item.homeFlag),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          item.homeTeam,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\${item.predictedHome}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '—',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: cs.onSurfaceVariant.withOpacity(0.4),
                    ),
                  ),
                ),
                Text(
                  '\${item.predictedAway}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          item.awayTeam,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _countryCode(item.awayFlag),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action buttons (pending only)
            if (isPending) ...[  
              const SizedBox(height: 10),
              Divider(
                  color: cs.outline.withOpacity(0.1), height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _editPrediction(item),
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC0001)
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_rounded,
                                size: 14,
                                color: Color(0xFFCC0001)),
                            SizedBox(width: 5),
                            Text(
                              'Edit Prediksi',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFCC0001),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _cancelPrediction(item.id),
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close_rounded,
                                size: 14,
                                color: cs.onSurfaceVariant),
                            const SizedBox(width: 5),
                            Text(
                              'Batalkan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
