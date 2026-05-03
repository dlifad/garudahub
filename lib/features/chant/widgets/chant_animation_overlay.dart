import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:garudahub/core/services/gyroscope_service.dart';
import 'package:garudahub/features/chant/providers/chant_provider.dart';

class ChantAnimationOverlay extends StatefulWidget {
  const ChantAnimationOverlay({super.key});

  @override
  State<ChantAnimationOverlay> createState() => _ChantAnimationOverlayState();
}

class _ChantAnimationOverlayState extends State<ChantAnimationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  final GyroscopeService _gyroscope = GyroscopeService();

  double _roll = 0.0;
  double _pitch = 0.0;
  double _rollVelocity = 0.0;
  double _pitchVelocity = 0.0;
  double _waveOffset = 0.0;

  Ticker? _ticker;

  bool _lastShow = false;
  bool _lastActive = false;
  Timer? _hintTimer;

  ChantProvider? _chantProvider;

  static const double _friction = 0.88;
  static const double _sensitivity = 0.045;
  static const double _maxRoll = 0.30;
  static const double _maxPitch = 0.12;
  static const double _waveAmplitude = 3.0; // pixel geser kiri-kanan, naikan ke 10-12 kalau mau lebih terasa

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
      reverseDuration: const Duration(seconds: 5),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: const Offset(0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    ));

    _ticker = createTicker((_) => _updateAngle());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chantProvider = context.read<ChantProvider>();
      _chantProvider!.addListener(_onChantChanged);
      _onChantChanged();
    });
  }

  void _onChantChanged() {
    if (!mounted) return;
    final chant = _chantProvider!;
    final shouldShow = chant.isActive && !chant.isCompleting;
    final isActive = chant.isActive;

    if (shouldShow != _lastShow) {
      _lastShow = shouldShow;
      if (shouldShow) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse(from: 1.0);
      }
    }

    if (isActive != _lastActive) {
      _lastActive = isActive;
      if (isActive) {
        _startGyro();
      } else {
        _stopGyro();
        _hintTimer?.cancel();
      }
    }
  }

  void _updateAngle() {
    _waveOffset += 0.04;

    final newRoll = (_roll * _friction + _rollVelocity * _sensitivity)
        .clamp(-_maxRoll, _maxRoll);
    final newPitch = (_pitch * _friction + _pitchVelocity * _sensitivity)
        .clamp(-_maxPitch, _maxPitch);

    setState(() {
      _roll = newRoll;
      _pitch = newPitch;
    });
  }

  void _startGyro() {
    _gyroscope.startListening((roll, pitch) {
      _rollVelocity = roll;
      _pitchVelocity = pitch;
    });
    _ticker?.start();
  }

  void _stopGyro() {
    _gyroscope.stopListening();
    _ticker?.stop();
    _rollVelocity = 0.0;
    _pitchVelocity = 0.0;
    _waveOffset = 0.0;
    setState(() {
      _roll = 0.0;
      _pitch = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final waveX = sin(_waveOffset) * _waveAmplitude;

    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0008)
      ..translate(waveX, 0.0) // geser horizontal tipis
      ..rotateZ(_roll)        // gyro tilt kiri/kanan
      ..rotateX(_pitch);      // gyro tilt depan/belakang

    return IgnorePointer(
      child: Stack(
        children: [
          // Layer 1: background gelap stadion saat tifo aktif
          AnimatedOpacity(
            opacity: _lastShow ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x66000000),
                    Color(0xBB1a0a00),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Layer 2: tifo dengan translate wave + gyro tilt + shadow
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slide,
              child: Transform(
                transform: transform,
                alignment: Alignment.bottomCenter,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/tifo.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chantProvider?.removeListener(_onChantChanged);
    _hintTimer?.cancel();
    _ticker?.dispose();
    _gyroscope.dispose();
    _controller.dispose();
    super.dispose();
  }
}