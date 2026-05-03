import 'package:flutter/material.dart';
import 'package:garudahub/core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang GarudaHub'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base + AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/images/logo.png', width: 120, height: 120)),
            Center(
              child: Text(
                'GarudaHub',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            Center(
              child: Text(
                'Versi 1.0.0',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _sectionTitle(context, 'Tentang Aplikasi'),
            const SizedBox(height: AppSpacing.sm),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Text(
                  'GarudaHub adalah aplikasi mobile yang menjadi pusat informasi '
                  'Tim Nasional Sepak Bola Indonesia. Aplikasi ini menyediakan data pertandingan, '
                  'pemain, turnamen, hingga fitur interaktif seperti prediksi skor, '
                  'notifikasi, dan chatbot AI untuk meningkatkan pengalaman pengguna.',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            _sectionTitle(context, 'Fitur Utama'),
            const SizedBox(height: AppSpacing.sm),

            Card(
              child: Column(
                children: const [
                  _FeatureTile('Jadwal & Hasil Pertandingan', Icons.schedule),
                  Divider(height: 1),
                  _FeatureTile('Data Pemain Timnas Indonesia', Icons.people_outline),
                  Divider(height: 1),
                  _FeatureTile('Mini Game Tebak Skor', Icons.emoji_events_outlined),
                  Divider(height: 1),
                  _FeatureTile('Lokasi Stadion & Rute', Icons.location_on_outlined),
                  Divider(height: 1),
                  _FeatureTile('Infomasi Tiket & Merchandise', Icons.shopping_bag_outlined),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            _sectionTitle(context, 'Fitur Tambahan'),
            const SizedBox(height: AppSpacing.sm),

            Card(
              child: Column(
                children: const [
                  _FeatureTile('Konversi Zona Waktu Match', Icons.access_time),
                  Divider(height: 1),
                  _FeatureTile('Konversi Mata Uang Merchandise', Icons.attach_money),
                  Divider(height: 1),
                  _FeatureTile('Notifikasi Pertandingan', Icons.notifications),
                  Divider(height: 1),
                  _FeatureTile('AI Chatbot', Icons.smart_toy_outlined),
                  Divider(height: 1),
                  _FeatureTile('Sensor Chant Supporter', Icons.vibration),
                  Divider(height: 1),
                  _FeatureTile('Gyroscope Parallax', Icons.screen_rotation),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            _sectionTitle(context, 'Pengembang'),
            const SizedBox(height: AppSpacing.sm),

            Card(
              child: Column(
                children: const [
                  _DevTile(
                    name: 'Ahmad Zainur Fadli',
                    nim: '123230049',
                    imagePath: '',
                  ),
                  Divider(height: 1),
                  _DevTile(
                    name: 'Ikhsan Fillah Hidayat',
                    nim: '123230219',
                    imagePath: '',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Center(
              child: Text(
                '© 2026 GarudaHub',
                style: TextStyle(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: cs.primary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _DevTile extends StatelessWidget {
  final String name;
  final String nim;
  final String imagePath;

  const _DevTile({
    required this.name,
    required this.nim,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundImage: AssetImage(imagePath),
        backgroundColor: cs.secondaryContainer,
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'NIM: $nim',
        style: TextStyle(color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String text;
  final IconData icon;

  const _FeatureTile(this.text, this.icon);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: cs.onSurfaceVariant),
      title: Text(text),
    );
  }
}
