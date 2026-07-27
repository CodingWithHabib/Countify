import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme_colors.dart';
class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor: AppColors.background,

      cardColor: AppColors.card,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      extensions: const [
        AppThemeColors(
          gradientStart: Color(0xFF0F172A),
          gradientMiddle: Color(0xFF1E293B),
          gradientEnd: Color(0xFF334155),

          card: AppColors.card,

          primaryText: Colors.white,
          secondaryText: Color(0xFFCBD5E1),
        ),
      ],
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}