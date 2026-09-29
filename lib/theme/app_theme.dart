import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.midnightOrchid,
    fontFamily: 'Georgia',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.plumBlossom,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.midnightOrchid,
      foregroundColor: AppColors.cream,
      elevation: 0,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Colors.white,
      contentTextStyle: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
