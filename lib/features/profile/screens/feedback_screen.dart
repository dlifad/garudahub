import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:garudahub/shared/widgets/garuda_widgets.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _controller = TextEditingController();

  Future<void> _submit() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      showGarudaSnackbar(context, 'Isi dulu penilaiannya', isError: true);
      return;
    }

    final subject = 'Feedback%20GarudaHub';
    final body = Uri.encodeComponent(text);

    final Uri emailUri = Uri.parse(
      'mailto:admin.garudahub@gmail.com?subject=$subject&body=$body',
    );

    try {
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (!mounted) return;
      showGarudaSnackbar(context, 'Tidak bisa membuka email', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Beri Penilaian')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Bagikan penilaian, saran, atau pesan kamu untuk GarudaHub',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Tulis di sini...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Kirim'),
              ),
            )
          ],
        ),
      ),
    );
  }
}