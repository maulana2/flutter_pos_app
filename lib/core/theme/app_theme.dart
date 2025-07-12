// lib/app/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- 1. IMPORT GOOGLE FONTS
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    // Hapus fontFamily dari sini
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onSecondary: AppColors.black,
      onSurface: AppColors.text,
      error: Colors.redAccent,
      onError: AppColors.white,
    ),

    scaffoldBackgroundColor: AppColors.background,

    appBarTheme: AppBarTheme(
      // <-- Perbarui App Bar Theme
      backgroundColor: AppColors.primary,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.white),
      // Gunakan text style langsung dari Google Fonts
      titleTextStyle: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500),
    ),

    // 2. GUNAKAN textTheme DARI GOOGLE FONTS DAN GABUNGKAN DENGAN STYLE KITA
    textTheme: GoogleFonts.robotoTextTheme().copyWith(
      displayLarge: AppTextStyles.heading,
      displayMedium: AppTextStyles.heading,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.body,
      titleMedium: AppTextStyles.subtitle,
      labelLarge: AppTextStyles.button,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.black,
        // Gunakan style dari GoogleFonts untuk memastikan konsistensi
        textStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.black,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
  );
}
