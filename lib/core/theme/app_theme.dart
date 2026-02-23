import 'package:flutter/material.dart';
import 'package:internal_issue_tracking_portal/core/constants/app_colors.dart';

class AppTheme {
  // LIGHT THEME (White UI)
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 35,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColors.lightText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightButton,
        foregroundColor: Colors.white,
      ),
    ),
  );

  // DARK THEME (Black UI)
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColors.darkText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkButton,
        foregroundColor: Colors.black,
      ),
    ),
  );
}
