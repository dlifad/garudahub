import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:garudahub/core/theme/app_theme.dart';
import 'package:garudahub/features/prediction/models/prediction_history.dart';
import 'package:garudahub/features/prediction/providers/prediction_provider.dart';

import 'package:garudahub/core/utils/flag_utils.dart';

class PredictionScreen extends StatelessWidget {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PredictionProvider()..loadData(),
      child: const _PredictionView(),
    );
  }
}

class _PredictionView extends StatefulWidget {
  const _PredictionView();

  @override
  State<_PredictionView> createState() => _PredictionViewState();
}

class _PredictionViewState extends State<_PredictionView> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _editPrediction(PredictionHistory item) async {
    final provider = context.read<PredictionProvider>();
    provider.prepareEdit(item);
    await _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
    await provider.deletePrediction(item.id);
  }

  Future<void> _cancelPrediction(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan prediksi?'),
        content: const Text(
          'Prediksi ini akan dihapus dan tidak bisa dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFCC0001),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await context.read<PredictionProvider>().deletePrediction(id);
  }

  String _predSummary(int indScore, int oppScore) {
    if (indScore > oppScore) {
      return 'Indonesia Menang $indScore\u2013$oppScore';
    }
    if (indScore < oppScore) {
      return 'Lawan Menang $indScore\u2013$oppScore';
    }
    return 'Imbang $indScore\u2013$oppScore';
  }

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
    final provider = context.watch<PredictionProvider>();
    final m = provider.nextMatch;
    final indScore = provider.indScore;
    final oppScore = provider.oppScore;

    return Scaffold(
      backgroundColor: AppColors.softBackground(
        cs,
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadData,
          child: ListView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // Header
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
                        size: 16,
                      ),
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

              // Input Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.outline.withOpacity(0.12)),
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
                        '${m.homeTeam} vs ${m.awayTeam} \u00b7 ${_formatDate(m.matchDateUtc)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (m == null)
                      Text(
                        'Belum ada pertandingan',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _teamCol(context, m.homeFlag, m.homeTeam),
                          const SizedBox(width: 10),
                          _stepperCol(
                            context,
                            score: indScore,
                            onUp: provider.predictionLocked
                                ? null
                                : provider.incrementIndScore,
                            onDown: provider.predictionLocked
                                ? null
                                : provider.decrementIndScore,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurfaceVariant.withOpacity(0.4),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          _stepperCol(
                            context,
                            score: oppScore,
                            onUp: provider.predictionLocked
                                ? null
                                : provider.incrementOppScore,
                            onDown: provider.predictionLocked
                                ? null
                                : provider.decrementOppScore,
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
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCC0001).withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCC0001).withOpacity(0.18),
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
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
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
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _predSummary(indScore, oppScore),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (provider.statusMsg != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        provider.statusMsg!,
                        style: TextStyle(
                          color: provider.predictionLocked
                              ? Colors.green.shade600
                              : cs.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),

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
                            (m == null ||
                                provider.predictionLocked ||
                                provider.submitting)
                            ? null
                            : provider.submitPrediction,
                        icon: provider.submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          provider.predictionLocked
                              ? 'Sudah Diprediksi'
                              : 'Kirim Prediksi',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Riwayat
              Text(
                'Riwayat Prediksi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              if (provider.loadingHistory)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.history.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        const Text('\u26bd', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 10),
                        Text(
                          'Belum ada riwayat prediksi',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...(provider.history.map(
                  (item) => _historyItem(context, item),
                )),
            ],
          ),
        ),
      ),
    );
  }

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
          color: fn != null ? cs.onSurface : cs.onSurface.withOpacity(0.25),
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
            '$score',
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

  Widget _teamCol(BuildContext context, String flag, String name) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            FlagUtils.getFlagUrl(flag),
            width: 32,
            height: 22,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.flag, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 58,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

  Widget _historyItem(BuildContext context, PredictionHistory item) {
    final cs = Theme.of(context).colorScheme;
    final isPending = item.status == 'pending';

    Color chipBg;
    Color chipFg;
    String chipLabel;
    switch (item.status) {
      case 'exact_score':
        chipBg = Colors.green.shade100;
        chipFg = Colors.green.shade800;
        chipLabel = '\u{1F3AF} Skor Tepat!';
        break;
      case 'correct_winner':
        chipBg = Colors.green.shade50;
        chipFg = Colors.green.shade700;
        chipLabel = '\u2705 Hasil Benar';
        break;
      case 'draw_correct':
        chipBg = Colors.blue.shade50;
        chipFg = Colors.blue.shade700;
        chipLabel = '\u{1F91D} Seri Tepat';
        break;
      case 'wrong':
        chipBg = Colors.red.shade50;
        chipFg = Colors.red.shade700;
        chipLabel = '\u274c Meleset';
        break;
      default:
        chipBg = Colors.orange.shade50;
        chipFg = Colors.orange.shade700;
        chipLabel = '\u23f3 Menunggu';
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.homeTeam} vs ${item.awayTeam}',
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
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
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
                    if (!isPending && item.pointsEarned != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+${item.pointsEarned} poin',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          FlagUtils.getFlagUrl(item.homeFlag),
                          width: 20,
                          height: 14,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.flag, size: 14),
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
                  '${item.predictedHome}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '\u2014',
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurfaceVariant.withOpacity(0.4),
                    ),
                  ),
                ),
                Text(
                  '${item.predictedAway}',
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          FlagUtils.getFlagUrl(item.awayFlag),
                          width: 20,
                          height: 14,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.flag, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 10),
              Divider(color: cs.outline.withOpacity(0.1), height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _editPrediction(item),
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC0001).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: Color(0xFFCC0001),
                            ),
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
                            Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: cs.onSurfaceVariant,
                            ),
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
