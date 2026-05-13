import 'package:flutter/material.dart';
import 'package:garudahub/core/theme/app_theme.dart';

class SaranKesanScreen extends StatelessWidget {
  const SaranKesanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Saran & Kesan')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: cs.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  children: [
                    Text(
                      'Kesan: Mata kuliah TPM sangat menantang karena tugas dan proyek akhirnya ini sangat kompleks. '
                      'Materi yang diajarkan dalam teori juga kurang di pakai di saat pengerjakan proyek akhir yang gilaa ini.',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.base),
                    Text(
                      'Saran: Untuk keputusan individu atau berkelompok dalam proyek akhir bisa lebih di kasih tau di minggu minggu awal saja, karena untuk seperti kasus kita ini yang bikin backend sendiri menguras waktu banyak jadi bisa lebih awal menententukan tema dan dicicil proyek akhirnya.',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
