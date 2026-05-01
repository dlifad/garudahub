import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garudahub/features/auth/providers/auth_provider.dart';
import 'package:garudahub/features/profile/providers/profile_provider.dart';
import 'package:garudahub/shared/widgets/garuda_widgets.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final String name;

  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  String get _code => _codeControllers.map((c) => c.text).join();

  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNodes[0].requestFocus();
    });

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

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;

    final provider = context.read<ProfileProvider>();

    try {
      await provider.requestEmailOtp(widget.email);

      if (!mounted) return;

      showGarudaSnackbar(context, 'OTP berhasil dikirim ulang');

      setState(() => _resendCountdown = 60);
      _startCountdown();
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceAll('Exception: ', '');
      showGarudaSnackbar(context, message, isError: true);
    }
  }

  Future<void> _verify() async {
    final provider = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();

    if (_code.length < 6) {
      showGarudaSnackbar(
        context,
        'Masukkan 6 digit kode verifikasi',
        isError: true,
      );
      return;
    }

    try {
      await provider.verifyEmailOtp(
        auth,
        email: widget.email,
        otp: _code,
      );

      if (auth.user?.name != widget.name) {
        await provider.updateProfile(
          auth,
          name: widget.name,
        );
      }

      if (!mounted) return;

      showGarudaSnackbar(context, 'Profil berhasil diperbarui');
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      showGarudaSnackbar(context, 'OTP salah', isError: true);
    }
  }

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
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

                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Icon(
                    Icons.mark_email_unread,
                    size: 56,
                    color: cs.primary,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Verifikasi Email',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: cs.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Masukkan kode 6 digit yang dikirim ke\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),

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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (value) {
                            if (value.length > 1) {
                              final pasted =
                                  value.replaceAll(RegExp(r'[^0-9]'), '');

                              for (int j = 0;
                                  j < pasted.length && j < 6;
                                  j++) {
                                _codeControllers[j].text = pasted[j];
                              }

                              FocusScope.of(context).unfocus();
                              return;
                            }

                            if (value.isNotEmpty) {
                              if (i < 5) {
                                FocusScope.of(context)
                                    .requestFocus(_focusNodes[i + 1]);
                              } else {
                                FocusScope.of(context).unfocus();
                              }
                            } else {
                              if (i > 0) {
                                FocusScope.of(context)
                                    .requestFocus(_focusNodes[i - 1]);
                              }
                            }
                          },
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: cs.surfaceVariant,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: cs.primary, width: 2),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  GarudaButton(
                    text: 'Verifikasi',
                    onPressed: _verify,
                    isLoading: provider.isLoading,
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: _resendOtp,
                    child: Text(
                      _resendCountdown > 0
                          ? 'Kirim ulang (${_resendCountdown}s)'
                          : 'Kirim ulang',
                      style: TextStyle(
                        color: _resendCountdown > 0
                            ? cs.onSurfaceVariant
                            : cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}