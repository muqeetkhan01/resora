import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../models/ritual_wrap_args.dart';

class RitualWrapView extends StatefulWidget {
  const RitualWrapView({super.key});

  @override
  State<RitualWrapView> createState() => _RitualWrapViewState();
}

class _RitualWrapViewState extends State<RitualWrapView> {
  static const Duration _fadeInDelay = Duration(milliseconds: 150);
  static const Duration _doneAt = Duration(milliseconds: 2500);

  late final RitualWrapArgs _args;
  late final _WrapCopy _copy;

  Timer? _fadeInTimer;
  Timer? _doneTimer;
  bool _visible = false;
  late final Future<void> _preloadFuture;
  Map<String, dynamic>? _preparedNextArguments;
  AudioPlayer? _preloadedPlayer;
  bool _didTransferPlayer = false;

  @override
  void initState() {
    super.initState();
    _args = RitualWrapArgs.from(Get.arguments);
    _copy = _copyFor(feature: _args.feature, isEntry: _args.isEntry);
    _preloadFuture = _preloadNextPlayerMedia();

    _fadeInTimer = Timer(_fadeInDelay, () {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
    });
    _doneTimer = Timer(_doneAt, () {
      unawaited(_finishEntry());
    });
  }

  @override
  void dispose() {
    _fadeInTimer?.cancel();
    _doneTimer?.cancel();
    if (!_didTransferPlayer) {
      unawaited(_preloadedPlayer?.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF145C4F),
      body: SafeArea(
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 290),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _copy.sublabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(0xFFFAFBF9).withOpacity(0.5),
                            letterSpacing: 2.75,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _copy.label,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: const Color(0xFFFAFBF9),
                                fontSize: 32,
                                height: 1.3,
                                letterSpacing: 0.9,
                                fontWeight: FontWeight.w300,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finishEntry() async {
    await _preloadFuture;
    if (!mounted) return;

    setState(() => _visible = false);
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (mounted) _continue(_args);
  }

  Future<void> _preloadNextPlayerMedia() async {
    if (_args.nextRoute != AppRoutes.audioPlayer ||
        _args.nextArguments is! Map) {
      return;
    }

    final arguments = Map<String, dynamic>.from(_args.nextArguments as Map);
    _preparedNextArguments = arguments;
    final track = arguments['track'];
    if (track is! AudioTrack) return;

    final imagePath = (arguments['imagePath'] as String? ?? '').trim();
    final imageFuture = imagePath.startsWith('http')
        ? _precacheNetworkImage(imagePath)
        : Future<void>.value();
    final player = AudioPlayer();

    Future<void> audioFuture() async {
      try {
        final source = track.assetPath.trim();
        final duration =
            source.startsWith('http://') || source.startsWith('https://')
                ? await player.setUrl(source)
                : await player.setAsset(source);
        if (!mounted) {
          await player.dispose();
          return;
        }
        _preloadedPlayer = player;
        arguments['preloadedPlayer'] = player;
        arguments['preloadedDuration'] = duration;
      } catch (_) {
        await player.dispose();
        arguments['preloadError'] =
            'This audio track is not available right now.';
      }
    }

    await Future.wait([audioFuture(), imageFuture]);
  }

  Future<void> _precacheNetworkImage(String url) {
    final completer = Completer<void>();
    final stream = NetworkImage(url).resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (_, __) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete();
      },
      onError: (_, __) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete();
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  void _continue(RitualWrapArgs args) {
    if (!mounted) {
      return;
    }

    if (args.nextRoute != null) {
      _didTransferPlayer = _preloadedPlayer != null;
      Get.offNamed(
        args.nextRoute!,
        arguments: _preparedNextArguments ?? args.nextArguments,
      );
      return;
    }

    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      Get.back();
      return;
    }

    Get.offAllNamed(AppRoutes.dashboard);
  }

  _WrapCopy _copyFor({
    required String feature,
    required bool isEntry,
  }) {
    _WrapCopy select({
      required _WrapCopy entry,
      required _WrapCopy exit,
    }) {
      return isEntry ? entry : exit;
    }

    switch (feature) {
      case RitualWrapFeature.meditation:
        return select(
          entry: const _WrapCopy(
            sublabel: 'ENTERING YOUR RESET',
            label: 'Take a breath.',
          ),
          exit: const _WrapCopy(
            sublabel: 'SESSION COMPLETE',
            label: 'You reset.',
          ),
        );
      case RitualWrapFeature.asmr:
        return select(
          entry: const _WrapCopy(
            sublabel: 'ENTERING YOUR SESSION',
            label: 'Let it go quiet.',
          ),
          exit: const _WrapCopy(
            sublabel: 'SESSION COMPLETE',
            label: 'You found stillness.',
          ),
        );
      case RitualWrapFeature.visualization:
        return select(
          entry: const _WrapCopy(
            sublabel: 'ENTERING YOUR SESSION',
            label: 'Get ready.',
          ),
          exit: const _WrapCopy(
            sublabel: 'SESSION COMPLETE',
            label: 'You practiced.',
          ),
        );
      case RitualWrapFeature.normal:
        return select(
          entry: const _WrapCopy(
            sublabel: 'ENTERING YOUR SESSION',
            label: 'Ask what you need.',
          ),
          exit: const _WrapCopy(
            sublabel: 'SESSION COMPLETE',
            label: 'Someone heard you.',
          ),
        );
      case RitualWrapFeature.talk:
        return select(
          entry: const _WrapCopy(
            sublabel: 'ENTERING YOUR SESSION',
            label: 'Start anywhere.',
          ),
          exit: const _WrapCopy(
            sublabel: 'SESSION COMPLETE',
            label: 'You were heard.',
          ),
        );
      case RitualWrapFeature.journal:
      default:
        return select(
          entry: const _WrapCopy(
            sublabel: 'OPENING YOUR JOURNAL',
            label: 'Find the words.',
          ),
          exit: const _WrapCopy(
            sublabel: 'SESSION COMPLETE',
            label: 'You showed up.',
          ),
        );
    }
  }
}

class _WrapCopy {
  const _WrapCopy({
    required this.sublabel,
    required this.label,
  });

  final String sublabel;
  final String label;
}
