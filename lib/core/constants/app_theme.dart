// lib/core/constants/app_theme.dart
import 'package:flutter/material.dart';
import 'app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(AppColors.primaryBlue),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppColors.primaryBlue),
        primary: const Color(AppColors.primaryBlue),
        background: const Color(AppColors.backgroundWhite),
      ),
      scaffoldBackgroundColor: const Color(AppColors.backgroundWhite),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.divider), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.divider), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.primaryBlue), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        hintStyle: const TextStyle(color: Color(AppColors.textHint)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.primaryBlue),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(AppColors.primaryBlue),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(AppColors.divider)),
        ),
        color: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(AppColors.primaryBlue),
        unselectedItemColor: Color(AppColors.textHint),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(AppColors.chipBlue),
        labelStyle: const TextStyle(color: Color(AppColors.chipBlueText), fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      useMaterial3: true,
    );
  }
}
