import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:garudahub/shared/widgets/garuda_widgets.dart';

import 'package:garudahub/features/auth/providers/auth_provider.dart';
import 'package:garudahub/features/auth/services/auth_service.dart';
import 'package:garudahub/features/auth/screens/forgot_password_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.changePassword(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      showGarudaSnackbar(context, 'Password berhasil diubah, silakan login ulang');

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      context.read<AuthProvider>().logout();

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } else {
      showGarudaSnackbar(
        context,
        result['message'] ?? 'Gagal mengubah password',
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(title: const Text('Ganti Kata Sandi')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GarudaTextField(
                label: 'Kata Sandi Lama',
                controller: _currentCtrl,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  return null;
                },
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text('Lupa password lama? Reset di sini', style: TextStyle(fontSize: 12),),
                ),
              ),
              const SizedBox(height: 16),

              GarudaTextField(
                label: 'Kata Sandi Baru',
                controller: _newCtrl,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (v.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              GarudaTextField(
                label: 'Konfirmasi Kata Sandi',
                controller: _confirmCtrl,
                isPassword: true,
                validator: (v) {
                  if (v != _newCtrl.text) return 'Tidak cocok';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              GarudaButton(
                text: 'Simpan Perubahan',
                onPressed: _submit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}