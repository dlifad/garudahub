import 'package:flutter/material.dart';
import 'dart:async';
import 'package:garudahub/shared/widgets/garuda_widgets.dart';
import 'package:garudahub/features/auth/services/auth_service.dart';


class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  String get _code => _codeControllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length < 6) {
      showGarudaSnackbar(context, 'Masukkan 6 digit kode verifikasi', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final result = await AuthService.verifyEmail(email: widget.email, code: _code);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      showGarudaSnackbar(context, 'Email berhasil diverifikasi!');
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } else {
      showGarudaSnackbar(context, result['data']['message'] ?? 'Kode tidak valid', isError: true);
    }
  }

  Future<void> _resend() async {
    if (_resendCountdown > 0) return;
    await AuthService.resendCode(email: widget.email);
    if (!mounted) return;
    showGarudaSnackbar(context, 'Kode baru telah dikirim!');
    setState(() => _resendCountdown = 60);
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Row(children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ]),
                  const SizedBox(height: 40),
            
                  Icon(
                    Icons.mark_email_unread,
                    size: 56,
                    color: cs.primary,
                  ),
                  const SizedBox(height: 20),
                  Text('Verifikasi Email',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: cs.onBackground, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    'Masukkan kode 6 digit yang dikirim ke\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 40),
            
                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      return SizedBox(
                        width: 48,
                        height: 56,
                        child: TextField(
                          controller: _codeControllers[i],
                          focusNode: _focusNodes[i],
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),

                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (i < 5) {
                                FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
                              } else {
                                FocusScope.of(context).unfocus();
                              }
                            } else {
                              if (i > 0) {
                                FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
                              }
                            }
                          },

                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: cs.surfaceVariant,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.primary, width: 2),
                            ),
                          ),
                        )
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
            
                  GarudaButton(text: 'Verifikasi', onPressed: _verify, isLoading: _isLoading),
                  const SizedBox(height: 24),
            
                  GestureDetector(
                    onTap: _resend,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                        children: [
                          const TextSpan(text: 'Tidak terima kode? '),
                          TextSpan(
                            text: _resendCountdown > 0
                                ? 'Kirim ulang (${_resendCountdown}s)'
                                : 'Kirim ulang',
                            style: TextStyle(
                              color: _resendCountdown > 0 ? cs.onSurfaceVariant : cs.primary,
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
          ),
        ),
      ),
    );
  }
}