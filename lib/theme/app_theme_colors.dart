import 'package:flutter/material.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color gradientStart;
  final Color gradientMiddle;
  final Color gradientEnd;

  final Color card;

  final Color primaryText;
  final Color secondaryText;

  const AppThemeColors({
    required this.gradientStart,
    required this.gradientMiddle,
    required this.gradientEnd,
    required this.card,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  AppThemeColors copyWith({
    Color? gradientStart,
    Color? gradientMiddle,
    Color? gradientEnd,
    Color? card,
    Color? primaryText,
    Color? secondaryText,
  }) {
    return AppThemeColors(
      gradientStart: gradientStart ?? this.gradientStart,
      gradientMiddle: gradientMiddle ?? this.gradientMiddle,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      card: card ?? this.card,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
    );
  }

  @override
  AppThemeColors lerp(
      ThemeExtension<AppThemeColors>? other,
      double t,
      ) {
    if (other is! AppThemeColors) return this;

    return AppThemeColors(
      gradientStart:
      Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientMiddle:
      Color.lerp(gradientMiddle, other.gradientMiddle, t)!,
      gradientEnd:
      Color.lerp(gradientEnd, other.gradientEnd, t)!,
      card: Color.lerp(card, other.card, t)!,
      primaryText:
      Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText:
      Color.lerp(secondaryText, other.secondaryText, t)!,
    );
  }
}