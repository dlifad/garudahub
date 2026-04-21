import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class ChantService {
  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();

  final List<String> _chants = [
    'sounds/chant1.mp3',
    'sounds/chant2.mp3',
    'sounds/chant3.mp3',
  ];

  Future<void> playChant() async {
    try {
      final chant = _chants[_random.nextInt(_chants.length)];
      await _player.stop();
      await _player.play(AssetSource(chant));
    } catch (e) {
      print('Error play chant: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}