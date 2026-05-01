
import 'package:flutter/material.dart';
import 'package:garudahub/features/ai/screens/ai_chat_screen.dart';

class AiChatWidget extends StatelessWidget {
  const AiChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiChatScreen()),
          ),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCC0001), Color(0xFF8B0000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCC0001).withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                ),
                alignment: Alignment.center,
                child: const Text('🦅', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('GarudaBot',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          )),
                      SizedBox(width: 8),
                      _AiBadge(),
                    ]),
                    SizedBox(height: 5),
                    Text(
                      'Tanya jadwal, prediksi skor, lineup,\npemain & futsal Timnas Indonesia',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12, height: 1.35),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 14),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF81C784).withOpacity(0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF81C784).withOpacity(0.5)),
      ),
      child: const Text('AI',
          style: TextStyle(
              color: Color(0xFF81C784),
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    );
  }
}
