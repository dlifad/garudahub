import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:garudahub/shared/widgets/garuda_widgets.dart';

import 'package:garudahub/core/services/biometric_service.dart';
import 'package:garudahub/core/models/user_model.dart';

import 'package:garudahub/features/auth/services/auth_service.dart';
import 'package:garudahub/features/auth/providers/auth_provider.dart';
import 'package:garudahub/features/auth/screens/forgot_password_screen.dart';
import 'package:garudahub/core/theme/app_theme.dart';

import 'package:garudahub/features/chant/providers/chant_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    try {
      final available = await BiometricService.canCheck();
      setState(() => _biometricAvailable = available);
    } catch (_) {}
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await AuthService.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      final userData = result['data']['user'];
      if (userData != null) {
        context.read<AuthProvider>().setUser(UserModel.fromJson(userData));
      }
      final chant = context.read<ChantProvider>();
      if (chant.isEnabled) {
        chant.start();
      }
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      showGarudaSnackbar(
        context,
        result['data']['message'] ?? 'Login gagal',
        isError: true,
      );
    }
  }

  Future<void> _biometricLogin() async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isBiometricEnabled) {
      showGarudaSnackbar(
        context,
        'Login biometrik belum diaktifkan',
        isError: true,
      );
      return;
    }

    final result = await BiometricService.loginWithBiometric();

    if (!mounted) return;

    switch (result) {
      case BiometricLoginResult.success:
        final user = await AuthService.getMe();
        if (!mounted) return;

        if (user != null) {
          context.read<AuthProvider>().setUser(user);
          final chant = context.read<ChantProvider>();
          if (chant.isEnabled) {
            chant.start();
          }
          Navigator.of(context).pushReplacementNamed('/home');
        }
        break;

      case BiometricLoginResult.noToken:
        showGarudaSnackbar(
          context,
          'Silakan login manual terlebih dahulu setelah mengganti kata sandi',
          isError: true,
        );
        break;

      case BiometricLoginResult.failedAuth:
        showGarudaSnackbar(
          context,
          'Autentikasi biometrik gagal',
          isError: true,
        );
        break;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();

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
                  const SizedBox(height: AppSpacing.xxl),
                  Image.asset(
                    'assets/images/logo_merah.png',
                    width: 120,
                    height: 120,
                  ),
                  Text(
                    'GARUDAHUB',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Selamat datang kembali!',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Masuk',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

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
                          const SizedBox(height: AppSpacing.xs),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text('Lupa kata sandi?'),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          GarudaButton(
                            text: 'Masuk',
                            onPressed: _login,
                            isLoading: _isLoading,
                          ),

                          if (_biometricAvailable &&
                              auth.isBiometricEnabled) ...[
                            const SizedBox(height: AppSpacing.base),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: cs.outlineVariant),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  child: Text(
                                    'atau',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: cs.outlineVariant),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.base),
                            OutlinedButton.icon(
                              onPressed: _biometricLogin,
                              icon: const Icon(Icons.fingerprint, size: 22),
                              label: const Text('Masuk dengan Biometrik'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed('/register'),
                        child: Text(
                          'Daftar sekarang',
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
