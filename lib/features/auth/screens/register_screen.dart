import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:garudahub/shared/widgets/garuda_widgets.dart';
import 'package:garudahub/core/theme/app_theme.dart';
import 'package:garudahub/features/auth/services/auth_service.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;
  bool _agreeTerms = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      showGarudaSnackbar(
        context,
        'Setujui syarat & ketentuan terlebih dahulu',
        isError: true,
      );
      return;
    }
    setState(() => _isLoading = true);
    final result = await AuthService.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      showGarudaSnackbar(context, 'Registrasi berhasil! Cek email kamu.');
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(email: _emailCtrl.text.trim()),
        ),
      );
    } else {
      showGarudaSnackbar(
        context,
        result['data']['message'] ?? 'Registrasi gagal',
        isError: true,
      );
    }
  }

  void _showTerms() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.base),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Judul
                  Center(
                    child: Text(
                      'Syarat & Ketentuan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: Text(
                      'GarudaHub',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  // Konten scroll
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: const [
                        _TermsIntro(),
                        SizedBox(height: AppSpacing.base),
                        _TermsSection(
                          number: '1',
                          title: 'Penggunaan Akun',
                          content:
                              'Pengguna wajib memberikan data yang benar, lengkap, dan terbaru saat melakukan pendaftaran. Pengguna bertanggung jawab penuh atas keamanan akun masing-masing.',
                        ),
                        _TermsSection(
                          number: '2',
                          title: 'Aktivitas Pengguna',
                          content:
                              'Pengguna setuju untuk tidak menggunakan aplikasi untuk aktivitas ilegal, penyebaran konten yang merugikan atau melanggar hukum, serta tindakan yang dapat merusak sistem atau merugikan pengguna lain.',
                        ),
                        _TermsSection(
                          number: '3',
                          title: 'Konten & Informasi',
                          content:
                              'Seluruh informasi yang tersedia di GarudaHub ditujukan untuk keperluan informasi dan pengembangan komunitas. Kami berusaha menjaga akurasi, namun tidak menjamin seluruh data selalu terbaru.',
                        ),
                        _TermsSection(
                          number: '4',
                          title: 'Privasi Pengguna',
                          content:
                              'Data pengguna akan dikelola sesuai kebijakan privasi yang berlaku. Kami tidak akan membagikan data pribadi tanpa izin, kecuali diwajibkan oleh hukum.',
                        ),
                        _TermsSection(
                          number: '5',
                          title: 'Perubahan Layanan',
                          content:
                              'GarudaHub berhak untuk mengubah, menambah, atau menghentikan sebagian atau seluruh layanan sewaktu-waktu tanpa pemberitahuan sebelumnya.',
                        ),
                        _TermsSection(
                          number: '6',
                          title: 'Penangguhan Akun',
                          content:
                              'Kami berhak menangguhkan atau menghapus akun pengguna yang melanggar ketentuan tanpa pemberitahuan.',
                        ),
                        _TermsSection(
                          number: '7',
                          title: 'Persetujuan',
                          content:
                              'Dengan mencentang "Syarat & Ketentuan", Anda menyatakan setuju untuk terikat dengan seluruh aturan yang berlaku di GarudaHub.',
                        ),
                        SizedBox(height: AppSpacing.base),
                        _TermsFooter(),
                        SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cs.surface, cs.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Back + Title
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buat Akun Baru',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Mau lihat perkembangan King Indonesia? Daftar sekarang.',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          GarudaTextField(
                            label: 'Nama Lengkap',
                            controller: _nameCtrl,
                            prefixIcon: Icons.person_outline,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Nama wajib diisi';
                              if (v.length < 2) return 'Nama terlalu pendek';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.base),
                          GarudaTextField(
                            label: 'Email',
                            controller: _emailCtrl,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Email wajib diisi';
                              if (!v.contains('@')) return 'Email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.base),
                          GarudaTextField(
                            label: 'Kata Sandi',
                            controller: _passCtrl,
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Kata sandi wajib diisi';
                              if (v.length < 6) return 'Minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.base),
                          GarudaTextField(
                            label: 'Konfirmasi Kata Sandi',
                            controller: _confirmPassCtrl,
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            validator: (v) {
                              if (v != _passCtrl.text)
                                return 'Kata sandi tidak cocok';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Terms checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: _agreeTerms,
                                onChanged: (v) =>
                                    setState(() => _agreeTerms = v ?? false),
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Saya setuju dengan ',
                                      ),
                                      TextSpan(
                                        text: 'Syarat & Ketentuan',
                                        style: TextStyle(
                                          color: cs.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = _showTerms,
                                      ),
                                      const TextSpan(text: ' GarudaHub'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          GarudaButton(
                            text: 'Daftar Sekarang',
                            onPressed: _register,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Masuk',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// WIDGET HELPER TERMS

class _TermsIntro extends StatelessWidget {
  const _TermsIntro();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Dengan mendaftar dan menggunakan aplikasi GarudaHub, Anda dianggap telah membaca, memahami, dan menyetujui seluruh ketentuan berikut:',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
      textAlign: TextAlign.left,
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String number;
  final String title;
  final String content;

  const _TermsSection({
    required this.number,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor bulat
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 1, right: AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          // Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsFooter extends StatelessWidget {
  const _TermsFooter();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Terakhir diperbarui: April 2026',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
