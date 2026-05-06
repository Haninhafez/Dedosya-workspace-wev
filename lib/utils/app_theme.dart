import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF0F1F2E);
  static const navyMid = Color(0xFF1A3045);
  static const navySoft = Color(0xFF243D52);
  static const teal = Color(0xFF1A9E8A);
  static const tealLight = Color(0xFF22C5AD);
  static const tealPale = Color(0xFFE0F7F4);
  static const sky = Color(0xFF4AABCA);
  static const cream = Color(0xFFF8F5F0);
  static const warmWhite = Color(0xFFFDFCFA);
  static const gold = Color(0xFFC9944A);
  static const goldPale = Color(0xFFFDF3E3);
  static const red = Color(0xFFD94F4F);
  static const redPale = Color(0xFFFDE8E8);
  static const green = Color(0xFF27B06E);
  static const greenPale = Color(0xFFE4F8EE);
  static const textDark = Color(0xFF1A2B38);
  static const textMid = Color(0xFF4A5A68);
  static const textSoft = Color(0xFF8A9BAB);
  static const border = Color(0xFFE2DBD2);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          background: AppColors.cream,
        ),
        scaffoldBackgroundColor: AppColors.cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cream,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
          ),
        ),
      );
}
