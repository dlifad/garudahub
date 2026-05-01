import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class ChantService {
  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();

  final List<String> _chants = [
    'sounds/chant1.mp3',
    'sounds/chant2.mp3',
  ];

  // kalau getDuration null
  static const Map<String, int> durations = {
    'sounds/chant1.mp3': 12,
    'sounds/chant2.mp3': 14,
  };

  // return nama + durasi
  Future<(String, Duration?)> playChant() async {
    final chant = _chants[_random.nextInt(_chants.length)];

    await _player.stop();
    await _player.play(AssetSource(chant));

    final duration = await _player.getDuration();

    return (chant, duration);
  }

  // event selesai audio
  Stream<void> get onComplete => _player.onPlayerComplete;

  void dispose() {
    _player.dispose();
  }
}