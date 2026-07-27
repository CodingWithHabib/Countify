import 'package:vibration/vibration.dart';

import 'storage_service.dart';

class VibrationService {
  static bool vibrationEnabled = true;

  static Future<void> init() async {
    vibrationEnabled =
    await StorageService.loadVibration();
  }

  static Future<void> vibrate() async {
    if (!vibrationEnabled) return;

    final hasVibrator =
    await Vibration.hasVibrator();

    if (hasVibrator != true) return;

    Vibration.vibrate(duration: 30);
  }
}