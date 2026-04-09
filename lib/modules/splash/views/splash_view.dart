import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    controller;

    return const Scaffold(
      backgroundColor: AppColors.canvas,
      body: _SplashWordmark(),
    );
  }
}

class _SplashWordmark extends StatefulWidget {
  const _SplashWordmark();

  @override
  State<_SplashWordmark> createState() => _SplashWordmarkState();
}

class _SplashWordmarkState extends State<_SplashWordmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1320),
    )..forward();

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.82, curve: Curves.easeOut),
    );
    _translateY = Tween<double>(
      begin: -44,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = width < 380 ? 100.0 : 126.0;

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _translateY.value),
            child: Opacity(
              opacity: _opacity.value.clamp(0.0, 1.0),
              child: Transform.scale(
                scaleX: 0.94,
                child: Text(
                  'resora',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond Regular',
                    fontSize: fontSize,
                    height: 1,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 7.6,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
