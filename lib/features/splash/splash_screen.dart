import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    await auth.checkAuth();

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      auth.isAuthenticated ? '/home' : '/login',
    );
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            _buildLogo(),

            // Text
            Text(
              'GARUDAHUB',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 5,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Pusat Informasi Timnas Indonesia',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),

            const SizedBox(height: 64),

            // Loader (titik-titik)
            _DotLoader(
              controller: _dotController,
              color: cs.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 240,
      height: 240,
      child: Image.asset(
        'assets/images/logo_merah.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _DotLoader extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _DotLoader({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final progress = ((controller.value - i * 0.2) % 1.0);
            final scale = progress < 0.3
                ? (progress / 0.3)
                : progress < 0.6
                    ? ((0.6 - progress) / 0.3)
                    : 0.0;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale.clamp(0.0, 1.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}