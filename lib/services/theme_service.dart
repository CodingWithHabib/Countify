import 'package:flutter/material.dart';

import 'storage_service.dart';

class ThemeService {
  static bool isDarkMode = true;

  static Future<void> init() async {
    isDarkMode = await StorageService.loadDarkMode();
  }

  static ThemeMode get themeMode {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> changeTheme(bool value) async {
    isDarkMode = value;
    await StorageService.saveDarkMode(value);
  }
}