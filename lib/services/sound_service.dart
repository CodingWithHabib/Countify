import 'package:flutter_soloud/flutter_soloud.dart';
import 'storage_service.dart';
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

  static Future<void> playClick() async {
    if (!soundEnabled) return;

    if (_clickSound == null) return;

    await SoLoud.instance.play(_clickSound!);
  }
}