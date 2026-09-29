import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

import 'storage_service.dart';

class VibrationService {
  static bool vibrationEnabled = true;

  static Future<void> init() async {
    vibrationEnabled =
    await StorageService.loadVibration();
  }

  static Future<void> vibrate({int duration = 50, bool ignoreSetting = false}) async {
    if (!ignoreSetting && !vibrationEnabled) return;

    final hasVibrator = await Vibration.hasVibrator();
    debugPrint('Vibration triggered. hasVibrator: $hasVibrator');
    if (hasVibrator != true) return;

    Vibration.vibrate(duration: duration);
  }

  static Future<void> vibrateStrong({bool ignoreSetting = false}) async {
    if (!ignoreSetting && !vibrationEnabled) return;

    final hasVibrator = await Vibration.hasVibrator();
    debugPrint('Strong vibration triggered. hasVibrator: $hasVibrator');
    if (hasVibrator != true) return;

    // Strong pattern for alert: 800ms pulse, 200ms gap, 800ms pulse
    if (await Vibration.hasCustomVibrationsSupport() == true) {
      Vibration.vibrate(pattern: [0, 800, 200, 800]);
    } else {
      debugPrint('Custom vibration not supported, falling back to simple long vibration');
      Vibration.vibrate(duration: 1000);
    }
  }
}