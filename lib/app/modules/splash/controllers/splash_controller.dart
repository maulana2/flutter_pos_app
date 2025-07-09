import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:pos_app/app/routes/app_pages.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);

    animationController.forward();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed(Routes.HOME);
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
