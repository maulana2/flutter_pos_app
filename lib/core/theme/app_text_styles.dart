// lib/app/core/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Tidak perlu lagi _fontFamily

  // Gaya untuk Judul Besar (seperti total harga atau nama halaman)
  static final TextStyle heading = GoogleFonts.roboto(
    // <-- 2. GUNAKAN GoogleFonts.roboto()
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: AppColors.text,
  );

  // Gaya untuk Teks Body/Utama (seperti nama item di daftar)
  static final TextStyle body = GoogleFonts.roboto(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 16,
    color: AppColors.text,
  );

  // Gaya untuk Tombol
  static final TextStyle button = GoogleFonts.roboto(
    fontWeight: FontWeight.w500, // Medium
    fontSize: 16,
    color: AppColors.white,
  );

  // Gaya untuk Subtitle atau teks kecil
  static final TextStyle subtitle = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.grey,
  );
}
