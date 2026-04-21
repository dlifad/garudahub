import 'package:flutter/material.dart';
import 'package:garudahub/shared/widgets/garuda_widgets.dart';
import 'package:garudahub/features/auth/services/auth_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);

    final res = await AuthService.forgotPassword(_emailCtrl.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    
    if (res['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: _emailCtrl.text.trim()),
        ),
      );
    } else {
      showGarudaSnackbar(context, res['message'], isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Kata Sandi')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GarudaTextField(
              label: 'Email',
              controller: _emailCtrl,
            ),
            const SizedBox(height: 20),
            GarudaButton(
              text: 'Kirim Kode',
              onPressed: _submit,
              isLoading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}