// lib/app/modules/splash/views/splash_view.dart

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/gen/assets.gen.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            FadeTransition(
              opacity: controller.fadeAnimation, // Ambil nilai animasi dari controller
              child: Image.asset(
                Assets.images.logo.path, // Path ke logo Anda
                width: 180, // Sesuaikan ukuran logo
              ),
            ),
            const Spacer(),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
