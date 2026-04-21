import 'package:flutter/material.dart';
import 'package:garudahub/shared/widgets/garuda_widgets.dart';
import 'package:garudahub/features/auth/services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _submit() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      showGarudaSnackbar(context, 'Password tidak cocok', isError: true);
      return;
    }

    setState(() => _loading = true);

    final res = await AuthService.resetPassword(
      email: widget.email,
      code: _codeCtrl.text,
      newPassword: _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (res['success']) {
      showGarudaSnackbar(context, 'Password berhasil direset');

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } else {
      showGarudaSnackbar(context, res['message'], isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GarudaTextField(label: 'Kode OTP', controller: _codeCtrl),
            const SizedBox(height: 16),

            GarudaTextField(
              label: 'Password Baru',
              controller: _passCtrl,
              isPassword: true,
            ),
            const SizedBox(height: 16),

            GarudaTextField(
              label: 'Konfirmasi Password',
              controller: _confirmCtrl,
              isPassword: true,
            ),
            const SizedBox(height: 20),

            GarudaButton(
              text: 'Reset Password',
              onPressed: _submit,
              isLoading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}