import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

class ThemeService {
  static bool isDarkMode = true;
  static int currentAccentIndex = 0;

  static const List<Color> accentColors = [
    Color(0xFF3B82F6), // Sapphire Blue
    Color(0xFF10B981), // Emerald Green
    Color(0xFF8B5CF6), // Cyber Purple
    Color(0xFFF97316), // Sunset Orange
    Color(0xFFEC4899), // Rose Pink
    Color(0xFFF59E0B), // Amber Gold
    Color(0xFF06B6D4), // Neon Cyan
    Color(0xFFEF4444), // Crimson Red
  ];

  static const List<String> accentNames = [
    "Sapphire Blue 💎",
    "Emerald Green 💚",
    "Cyber Purple 💜",
    "Sunset Orange 🍊",
    "Rose Pink 🌸",
    "Amber Gold 👑",
    "Neon Cyan 🩵",
    "Crimson Red 🔴",
  ];

  static Color get primaryColor =>
      accentColors[currentAccentIndex.clamp(0, accentColors.length - 1)];

  static Future<void> init() async {
    isDarkMode = await StorageService.loadDarkMode();
    try {
      final prefs = await SharedPreferences.getInstance();
      currentAccentIndex = prefs.getInt("custom_accent_index") ?? 0;
    } catch (_) {
      currentAccentIndex = 0;
    }
  }

  static ThemeMode get themeMode {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> changeTheme(bool value) async {
    isDarkMode = value;
    await StorageService.saveDarkMode(value);
  }

  static Future<void> changeAccentIndex(int index) async {
    currentAccentIndex = index.clamp(0, accentColors.length - 1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("custom_accent_index", currentAccentIndex);
  }
}
