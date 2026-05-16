import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    controller;
    return const Scaffold(
      backgroundColor: Color(0xFF111111),
      body: _SplashSequence(),
    );
  }
}

class _SplashSequence extends StatefulWidget {
  const _SplashSequence();

  @override
  State<_SplashSequence> createState() => _SplashSequenceState();
}

class _SplashSequenceState extends State<_SplashSequence> {
  static const _crossfadeMs = 450;
  static const _imageDuration = Duration(milliseconds: 1500);
  static const _textFadeInMs = 900;

  static const _images = <String>[
    AppAssets.homeTalkOcean,
    AppAssets.spaceGarden,
    AppAssets.homeNormalStem,
  ];

  int _current = 0;
  int? _next;
  bool _textVisible = false;
  bool _screenFadeOut = false;
  Timer? _textTimer;
  Timer? _switchTimer1;
  Timer? _switchTimer2;
  Timer? _finishTimer;
  Timer? _crossfadeSettleTimer;

  @override
  void initState() {
    super.initState();
    _textTimer = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() => _textVisible = true);
    });
    _scheduleSwitch(1, _imageDuration);
    _scheduleSwitch(2, _imageDuration * 2);
    _finishTimer = Timer(
      _imageDuration * 3 + const Duration(milliseconds: _crossfadeMs + 200),
      () {
        if (!mounted) return;
        setState(() => _screenFadeOut = true);
      },
    );
  }

  void _scheduleSwitch(int toIndex, Duration delay) {
    final timer = Timer(delay, () {
      if (!mounted) return;
      setState(() => _next = toIndex);
      _crossfadeSettleTimer?.cancel();
      _crossfadeSettleTimer = Timer(
        const Duration(milliseconds: _crossfadeMs),
        () {
          if (!mounted) return;
          setState(() {
            _current = toIndex;
            _next = null;
          });
        },
      );
    });

    if (toIndex == 1) {
      _switchTimer1 = timer;
    } else {
      _switchTimer2 = timer;
    }
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _switchTimer1?.cancel();
    _switchTimer2?.cancel();
    _finishTimer?.cancel();
    _crossfadeSettleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _screenFadeOut ? 0 : 1,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOut,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _ImageLayer(path: _images[_current]),
          if (_next != null)
            AnimatedOpacity(
              opacity: _next != null ? 1 : 0,
              duration: const Duration(milliseconds: _crossfadeMs),
              curve: Curves.easeInOut,
              child: _ImageLayer(path: _images[_next!]),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.44),
                    Colors.black.withOpacity(0.08),
                    Colors.black.withOpacity(0.56),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 340,
              height: 260,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.black.withOpacity(0.38),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          _BrandLockup(textVisible: _textVisible),
          Positioned(
            left: 0,
            right: 0,
            bottom: 44,
            child: AnimatedOpacity(
              opacity: _textVisible ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    width: _current == index ? 22 : 6,
                    height: 1.5,
                    color: _current == index
                        ? AppColors.terracotta
                        : AppColors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageLayer extends StatelessWidget {
  const _ImageLayer({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup({required this.textVisible});

  final bool textVisible;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              opacity: textVisible ? 1 : 0,
              duration: const Duration(
                  milliseconds: _SplashSequenceState._textFadeInMs),
              curve: Curves.easeOut,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: textVisible ? 12 : 0, end: 0),
                duration: const Duration(
                    milliseconds: _SplashSequenceState._textFadeInMs),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                      offset: Offset(0, value), child: child);
                },
                child: Text(
                  'Resora',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 66,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 9.2,
                    color: const Color(0xFFFAFBF9),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedScale(
              scale: textVisible ? 1 : 0,
              duration: const Duration(
                  milliseconds: _SplashSequenceState._textFadeInMs),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: textVisible ? 1 : 0,
                duration: const Duration(
                    milliseconds: _SplashSequenceState._textFadeInMs),
                child: Container(
                  width: 36,
                  height: 0.5,
                  color: AppColors.terracotta,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: textVisible ? 0.82 : 0,
              duration: const Duration(
                  milliseconds: _SplashSequenceState._textFadeInMs),
              curve: Curves.easeOut,
              child: Text(
                'LIFE GETS BETTER WHEN YOU DO',
                style: GoogleFonts.jost(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2.5,
                  color: const Color(0xFFFAFBF9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
