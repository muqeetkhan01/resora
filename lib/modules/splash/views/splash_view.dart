import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    controller;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Lottie.asset(
            AppAssets.lottieIntro,
            repeat: false,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
