import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme_colors.dart';
class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      scaffoldBackgroundColor: const Color(0xFFF8FAFC),

      cardColor: Colors.white,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAFC),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      extensions: const [
        AppThemeColors(
          gradientStart: Color(0xFFF8FAFC),
          gradientMiddle: Color(0xFFE2E8F0),
          gradientEnd: Color(0xFFCBD5E1),

          card: Colors.white,

          primaryText: Colors.black,
          secondaryText: Color(0xFF475569),
        ),
      ],
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}