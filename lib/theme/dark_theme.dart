import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import 'app_colors.dart';
import 'app_theme_colors.dart';
import 'default_theme.dart';

class DarkTheme {
  static ThemeData get theme {
    final primary = ThemeService.primaryColor;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,

      scaffoldBackgroundColor: DefaultTheme.background,

      cardColor: AppColors.card,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        brightness: Brightness.dark,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      extensions: [
        AppThemeColors(
          gradientStart: DefaultTheme.backgroundGradient[0],
          gradientMiddle: DefaultTheme.backgroundGradient[1],
          gradientEnd: DefaultTheme.backgroundGradient[2],

          card: DefaultTheme.surface,

          primaryText: Colors.white,
          secondaryText: const Color(0xFFCBD5E1),
        ),
      ],
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
