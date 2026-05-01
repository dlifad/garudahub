import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garudahub/features/chant/providers/chant_provider.dart';

class ChantAnimationOverlay extends StatefulWidget {
  const ChantAnimationOverlay({super.key});

  @override
  State<ChantAnimationOverlay> createState() => _ChantAnimationOverlayState();
}

class _ChantAnimationOverlayState extends State<ChantAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  bool _lastShow = false;

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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
        reverseCurve: Curves.linear,
      ),
    );
  }

  void _handle(bool shouldShow) {
    if (shouldShow == _lastShow) return;

    _lastShow = shouldShow;

    if (shouldShow) {
      _controller.forward(from: 0.0);
    } else {
      _controller.reverse(from: 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chant = context.watch<ChantProvider>();
    final shouldShow = chant.isActive && !chant.isCompleting;

    _handle(shouldShow);

    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: _slide,
          child: Image.asset(
            'assets/images/tifo.png',
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}