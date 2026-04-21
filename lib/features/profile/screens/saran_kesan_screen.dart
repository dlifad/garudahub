import 'package:flutter/material.dart';

class SaranKesanScreen extends StatelessWidget {
  const SaranKesanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Saran & Kesan')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: cs.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Mata kuliah TPM sangat bermanfaat dalam pengembangan aplikasi mobile. '
                  'Materi yang diajarkan relevan dan aplikatif. Semoga ke depannya '
                  'semakin banyak praktik langsung dan studi kasus nyata.',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}