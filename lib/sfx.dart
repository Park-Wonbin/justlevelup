import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class Sfx {
  Sfx._();
  static final _rng = Random();

  // 짧은 효과음은 겹쳐 재생될 수 있으니 매 호출마다 새 플레이어 생성
  static Future<void> _play(String asset) async {
    final p = AudioPlayer(playerId: 'sfx_${DateTime.now().microsecondsSinceEpoch}');
    // 지연 줄이기 (iOS/안드로이드에 특히 도움)
    await p.setVolume(1.0);
    await p.play(AssetSource('effect/$asset'));
    // 재생 끝나면 정리
    p.onPlayerComplete.first.then((_) => p.dispose());
  }

  static Future<void> success() async {
    const files = ['success1.wav','success2.wav','success3.wav','success4.wav'];
    await _play(files[_rng.nextInt(files.length)]);
  }

  static Future<void> fail() async {
    await _play('fail.wav');
  }

  static Future<void> drop() async {
    await _play('drop.wav');
  }

  static Future<void> hit() async {
    const files = ['hit1.wav','hit2.wav'];
    await _play(files[_rng.nextInt(files.length)]);
  }
}