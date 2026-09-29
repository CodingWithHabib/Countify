import 'package:flutter_soloud/flutter_soloud.dart';
import 'storage_service.dart';
import 'theme_detection_service.dart';

class SoundService {
  static AudioSource? _clickSound;
  static bool soundEnabled = true;

  static Future<void> init() async {
    await SoLoud.instance.init();
    soundEnabled = await StorageService.loadSound();
    _clickSound = await SoLoud.instance.loadAsset(
      'assets/sounds/click.mp3',
    );
  }

  static Future<void> playClick({double pitch = 1.0}) async {
    if (!soundEnabled) return;

    if (_clickSound == null) return;

    final handle = SoLoud.instance.play(_clickSound!);
    SoLoud.instance.setRelativePlaySpeed(handle, pitch);
  }

  static void playThemeSound(CounterThemeStyle style) {
    double pitch = 1.0;
    switch (style) {
      case CounterThemeStyle.islamic:
        pitch = 0.8; // Deeper for spiritual feel
        break;
      case CounterThemeStyle.fitness:
        pitch = 1.2; // Sharper for energy
        break;
      case CounterThemeStyle.sports:
        pitch = 1.3; // Energetic
        break;
      case CounterThemeStyle.programming:
        pitch = 1.5; // Techy feel
        break;
      case CounterThemeStyle.health:
        pitch = 1.1;
        break;
      case CounterThemeStyle.finance:
        pitch = 0.9;
        break;
      case CounterThemeStyle.creative:
        pitch = 1.4;
        break;
      default:
        pitch = 1.0;
    }
    playClick(pitch: pitch);
  }
}