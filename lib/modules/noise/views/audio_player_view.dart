import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';

class AudioPlayerView extends StatefulWidget {
  const AudioPlayerView({super.key});

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final AudioPlayer _player;
  late final _AudioPlayerArgs _args;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _args = _AudioPlayerArgs.from(Get.arguments);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _player = AudioPlayer();
    _durationSubscription = _player.durationStream.listen((value) {
      if (!mounted || value == null) {
        return;
      }

      setState(() {
        _duration = value;
      });
    });
    _positionSubscription = _player.positionStream.listen((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        _position = value;
      });
    });
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (!mounted) {
        return;
      }

      final completed = state.processingState == ProcessingState.completed;
      setState(() {
        _isPlaying = state.playing && !completed;
        _isLoading = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
        if (completed) {
          _position = _duration;
        }
      });

      if (completed) {
        unawaited(_player.pause());
        unawaited(_player.seek(Duration.zero));
      }
    });
    unawaited(_loadTrack());
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTrack() async {
    try {
      final source = _args.track.assetPath.trim();
      final loadedDuration =
          source.startsWith('http://') || source.startsWith('https://')
              ? await _player.setUrl(source)
              : await _player.setAsset(source);
      if (!mounted) {
        return;
      }

      setState(() {
        _duration = loadedDuration ?? Duration.zero;
        _isLoading = false;
        _loadError = null;
      });
      await _player.play();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = 'This audio track is not available right now.';
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_loadError != null) {
      return;
    }

    if (_isPlaying) {
      await _player.pause();
      return;
    }

    if (_duration > Duration.zero && _position >= _duration) {
      await _player.seek(Duration.zero);
    }

    await _player.play();
  }

  Future<void> _seekRelative(int seconds) async {
    if (_loadError != null) {
      return;
    }

    final target = _position + Duration(seconds: seconds);
    await _player.seek(_clampPosition(target));
  }

  Future<void> _seekToFraction(double fraction) async {
    if (_loadError != null || _duration <= Duration.zero) {
      return;
    }

    final clamped = fraction.clamp(0.0, 1.0);
    final target =
        Duration(milliseconds: (_duration.inMilliseconds * clamped).round());
    await _player.seek(target);
  }

  Duration _clampPosition(Duration value) {
    if (value < Duration.zero) {
      return Duration.zero;
    }
    if (_duration > Duration.zero && value > _duration) {
      return _duration;
    }
    return value;
  }

  double get _progress {
    if (_duration <= Duration.zero) {
      return 0;
    }

    return (_position.inMilliseconds / _duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  void _closePlayer() {
    if (_args.ritualFeature != null) {
      Get.offNamed(
        AppRoutes.ritualWrap,
        arguments: RitualWrapArgs.exit(
          feature: _args.ritualFeature!,
        ).toMap(),
      );
      return;
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final track = _args.track;
    final scene = _PlayerScene.fromTrack(track);
    final textTheme = Theme.of(context).textTheme;

    final useMuseumMinimal =
        _args.minimal || _args.ritualFeature == RitualWrapFeature.asmr;
    if (useMuseumMinimal) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            _closePlayer();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: _MuseumMinimalPlayer(
            imagePath: _args.imagePath,
            title: track.title,
            category: track.category,
            progress: _progress,
            positionLabel: _formatDuration(_position),
            remainingLabel: _remainingDurationLabel(track.duration),
            isPlaying: _isPlaying,
            isLoading: _isLoading,
            errorText: _loadError,
            onBack: _closePlayer,
            onPlayPause: _togglePlayback,
            onSeekBackward: () => _seekRelative(-15),
            onSeekForward: () => _seekRelative(15),
            onSeek: _seekToFraction,
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _closePlayer();
        }
      },
      child: Scaffold(
        backgroundColor: scene.base,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final pulse = Curves.easeInOut.transform(
              0.5 + 0.5 * math.sin(_controller.value * math.pi * 2),
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                _AnimatedBackdrop(
                  scene: scene,
                  animationValue: _controller.value,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: _closePlayer,
                              icon: const Icon(
                                AppIcons.close,
                                color: AppColors.terracotta,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.terracotta.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.terracotta.withOpacity(0.34),
                                ),
                              ),
                              child: const Icon(
                                CupertinoIcons.slider_horizontal_3,
                                color: AppColors.terracotta,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(flex: 2),
                        _CenterMotion(
                          scene: scene,
                          pulse: pulse,
                          animationValue: _controller.value,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          track.title,
                          style: textTheme.displayMedium?.copyWith(
                            color: AppColors.white.withOpacity(0.92),
                            fontSize: 31,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          track.description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withOpacity(0.58),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _ProgressSection(
                          progress: _progress,
                          positionLabel: _formatDuration(_position),
                          durationLabel: _duration > Duration.zero
                              ? _formatDuration(_duration)
                              : track.duration,
                          onSeek: _seekToFraction,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _TransportRow(
                          isPlaying: _isPlaying,
                          isLoading: _isLoading,
                          onPrevious: () => _seekRelative(-15),
                          onPlayPause: _togglePlayback,
                          onNext: () => _seekRelative(15),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                if (_loadError != null)
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.xl,
                          AppSpacing.xl,
                          0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Text(
                            _loadError!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (value.inHours > 0) {
      final hours = value.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  String _remainingDurationLabel(String fallbackDuration) {
    if (_duration <= Duration.zero) {
      return '-$fallbackDuration';
    }

    final remaining = _clampPosition(_duration - _position);
    return '-${_formatDuration(remaining)}';
  }
}

class _AudioPlayerArgs {
  const _AudioPlayerArgs({
    required this.track,
    required this.minimal,
    required this.imagePath,
    this.ritualFeature,
  });

  final AudioTrack track;
  final bool minimal;
  final String imagePath;
  final String? ritualFeature;

  factory _AudioPlayerArgs.from(dynamic arguments) {
    if (arguments is Map) {
      final imagePath = (arguments['imagePath'] as String? ?? '').trim();
      return _AudioPlayerArgs(
        track: arguments['track'] as AudioTrack? ?? _fallbackTrack,
        minimal: arguments['minimal'] == true,
        imagePath: imagePath.isEmpty ? AppAssets.curtainLight : imagePath,
        ritualFeature: arguments['ritualFeature'] as String?,
      );
    }

    final track = arguments as AudioTrack? ?? _fallbackTrack;
    return _AudioPlayerArgs(
      track: track,
      minimal: false,
      imagePath:
          track.imagePath.isEmpty ? AppAssets.curtainLight : track.imagePath,
      ritualFeature: null,
    );
  }

  static const _fallbackTrack = AudioTrack(
    title: 'Soft rain on leaves',
    category: 'Nature',
    description: 'Steady sound for nervous-system downshift',
    duration: '1 min',
    assetPath: AppAssets.ambientSoftRain,
    imagePath: AppAssets.splashWaterfall,
  );
}

class _MuseumMinimalPlayer extends StatelessWidget {
  const _MuseumMinimalPlayer({
    required this.imagePath,
    required this.title,
    required this.category,
    required this.progress,
    required this.positionLabel,
    required this.remainingLabel,
    required this.isPlaying,
    required this.isLoading,
    required this.errorText,
    required this.onBack,
    required this.onPlayPause,
    required this.onSeekBackward,
    required this.onSeekForward,
    required this.onSeek,
  });

  final String imagePath;
  final String title;
  final String category;
  final double progress;
  final String positionLabel;
  final String remainingLabel;
  final bool isPlaying;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onBack;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final slider = progress.clamp(0.0, 1.0);
    final isNetwork = imagePath.startsWith('http');

    return Stack(
      fit: StackFit.expand,
      children: [
        isNetwork
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              )
            : Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
        const _MuseumBottomVignette(),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, top: 28),
              child: GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CustomPaint(
                    size: const Size(16, 16),
                    painter: _CloseXPainter(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 52),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withOpacity(0.55),
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.98,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.white.withOpacity(0.95),
                          fontSize: 34,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.7,
                          height: 1.15,
                        ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        positionLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withOpacity(0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.54,
                            ),
                      ),
                      Text(
                        remainingLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withOpacity(0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.54,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  _ResoraProgressSlider(
                    progress: slider,
                    onSeek: onSeek,
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      errorText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.terracotta,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SeekIconButton(
                        icon: CupertinoIcons.gobackward,
                        onTap: onSeekBackward,
                      ),
                      const SizedBox(width: 56),
                      if (isLoading)
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white.withOpacity(0.7),
                            ),
                          ),
                        )
                      else
                        _PlayerPaintButton(
                          onTap: onPlayPause,
                          size: const Size(28, 28),
                          painter: isPlaying
                              ? _PausePainter(
                                  color: AppColors.white.withOpacity(0.92),
                                )
                              : _PlayPainter(
                                  color: AppColors.white.withOpacity(0.92),
                                ),
                        ),
                      const SizedBox(width: 56),
                      _SeekIconButton(
                        icon: CupertinoIcons.goforward,
                        onTap: onSeekForward,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SeekIconButton extends StatelessWidget {
  const _SeekIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(
          icon,
          color: AppColors.white.withOpacity(0.86),
          size: 28,
        ),
      ),
    );
  }
}

class _MuseumBottomVignette extends StatelessWidget {
  const _MuseumBottomVignette();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.55,
        widthFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: [0, 0.35, 0.65, 1],
              colors: [
                Color(0xB8000000),
                Color(0x73000000),
                Color(0x26000000),
                Color(0x00000000),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResoraProgressSlider extends StatelessWidget {
  const _ResoraProgressSlider({
    required this.progress,
    required this.onSeek,
  });

  final double progress;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final pct = (details.localPosition.dx / box.size.width).clamp(0.0, 1.0);
        onSeek(pct);
      },
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final pct = (details.localPosition.dx / box.size.width).clamp(0.0, 1.0);
        onSeek(pct);
      },
      child: SizedBox(
        height: 20,
        child: CustomPaint(
          painter: _ProgressTrackPainter(progress: progress),
          size: const Size(double.infinity, 20),
        ),
      ),
    );
  }
}

class _ProgressTrackPainter extends CustomPainter {
  const _ProgressTrackPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final trackPaint = Paint()
      ..color = AppColors.white.withOpacity(0.25)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), trackPaint);

    final fillPaint = Paint()
      ..color = AppColors.white.withOpacity(0.9)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, cy),
      Offset(size.width * progress.clamp(0.0, 1.0), cy),
      fillPaint,
    );

    final thumbPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * progress.clamp(0.0, 1.0), cy),
        width: 5,
        height: 5,
      ),
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressTrackPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PlayerPaintButton extends StatelessWidget {
  const _PlayerPaintButton({
    required this.onTap,
    required this.size,
    required this.painter,
  });

  final VoidCallback onTap;
  final Size size;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CustomPaint(
          size: size,
          painter: painter,
        ),
      ),
    );
  }
}

class _CloseXPainter extends CustomPainter {
  const _CloseXPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_CloseXPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PausePainter extends CustomPainter {
  const _PausePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas
      ..drawRect(Rect.fromLTWH(3, 2, 4.5, size.height - 4), paint)
      ..drawRect(Rect.fromLTWH(14.5, 2, 4.5, size.height - 4), paint);
  }

  @override
  bool shouldRepaint(_PausePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PlayPainter extends CustomPainter {
  const _PlayPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(4, 2)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(4, size.height - 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PlayPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _SkipBackPainter extends CustomPainter {
  const _SkipBackPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.38;
    final arcPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2,
      -3 * math.pi / 2,
      false,
      arcPaint,
    );

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final p1 = Path()
      ..moveTo(cx - 1, cy - radius - 4)
      ..lineTo(cx - 6, cy - radius + 2)
      ..lineTo(cx - 1, cy - radius + 2)
      ..close();
    final p2 = Path()
      ..moveTo(cx - 5, cy - radius - 4)
      ..lineTo(cx - 10, cy - radius + 2)
      ..lineTo(cx - 5, cy - radius + 2)
      ..close();
    canvas
      ..drawPath(p1, arrowPaint)
      ..drawPath(p2, arrowPaint);
  }

  @override
  bool shouldRepaint(_SkipBackPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _SkipForwardPainter extends CustomPainter {
  const _SkipForwardPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.38;
    final arcPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2,
      3 * math.pi / 2,
      false,
      arcPaint,
    );

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final p1 = Path()
      ..moveTo(cx + 1, cy - radius - 4)
      ..lineTo(cx + 6, cy - radius + 2)
      ..lineTo(cx + 1, cy - radius + 2)
      ..close();
    final p2 = Path()
      ..moveTo(cx + 5, cy - radius - 4)
      ..lineTo(cx + 10, cy - radius + 2)
      ..lineTo(cx + 5, cy - radius + 2)
      ..close();
    canvas
      ..drawPath(p1, arrowPaint)
      ..drawPath(p2, arrowPaint);
  }

  @override
  bool shouldRepaint(_SkipForwardPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PlayerScene {
  const _PlayerScene({
    required this.base,
    required this.top,
    required this.bottom,
    required this.accent,
    required this.kind,
  });

  final Color base;
  final Color top;
  final Color bottom;
  final Color accent;
  final _SceneKind kind;

  factory _PlayerScene.fromTrack(AudioTrack track) {
    final category = track.category.toLowerCase();
    final title = track.title.toLowerCase();

    if (category.contains('brown')) {
      return const _PlayerScene(
        base: Color(0xFF171412),
        top: Color(0xFF2F261F),
        bottom: Color(0xFF130F0D),
        accent: Color(0xFFE2C6A7),
        kind: _SceneKind.noise,
      );
    }

    if (category.contains('guided') || title.contains('exhale')) {
      return const _PlayerScene(
        base: Color(0xFF1B2220),
        top: Color(0xFF4A6A61),
        bottom: Color(0xFF101616),
        accent: Color(0xFFCFE5DB),
        kind: _SceneKind.glow,
      );
    }

    return const _PlayerScene(
      base: Color(0xFF121A19),
      top: Color(0xFF33403C),
      bottom: Color(0xFF0E1414),
      accent: Color(0xFFD7E0DC),
      kind: _SceneKind.rain,
    );
  }
}

enum _SceneKind { rain, noise, glow }

class _AnimatedBackdrop extends StatelessWidget {
  const _AnimatedBackdrop({
    required this.scene,
    required this.animationValue,
  });

  final _PlayerScene scene;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scene.top, scene.base, scene.bottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        if (scene.kind == _SceneKind.rain)
          ...List.generate(54, (index) {
            final x = ((index * 17.0) % 430) - 30;
            final startY = ((index * 31.0) % 920) - 120;
            final drift = animationValue * (280 + (index % 6) * 28.0);
            final top = (startY + drift) % 980 - 120;
            final length = 18.0 + (index % 5) * 14.0;

            return Positioned(
              left: x,
              top: top,
              child: Transform.rotate(
                angle: -0.24,
                child: Container(
                  width: 1.5,
                  height: length,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color:
                        AppColors.white.withOpacity(index.isEven ? 0.18 : 0.08),
                  ),
                ),
              ),
            );
          }),
        if (scene.kind == _SceneKind.noise)
          ...List.generate(9, (index) {
            final phase = (animationValue * math.pi * 2) + index;
            final height = 180 + 40 * math.sin(phase);
            final width = 42 + (index % 3) * 16.0;
            final left = 28 + index * 38.0;

            return Positioned(
              left: left,
              bottom: 120 + 18 * math.cos(phase),
              child: Container(
                width: width,
                height: height.abs(),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [
                      scene.accent.withOpacity(0.12),
                      scene.accent.withOpacity(0.02),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            );
          }),
        if (scene.kind == _SceneKind.glow)
          ...List.generate(5, (index) {
            final offset =
                math.sin((animationValue * math.pi * 2) + index) * 18;
            final size = 180 + index * 52.0;

            return Positioned(
              left: 36 + index * 20.0,
              top: 120 + offset + index * 24.0,
              child: IgnorePointer(
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        scene.accent.withOpacity(index == 0 ? 0.16 : 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.08),
                Colors.transparent,
                Colors.black.withOpacity(0.34),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class _CenterMotion extends StatelessWidget {
  const _CenterMotion({
    required this.scene,
    required this.pulse,
    required this.animationValue,
  });

  final _PlayerScene scene;
  final double pulse;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    if (scene.kind == _SceneKind.noise) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (index) {
          final height =
              20 + 28 * math.sin((animationValue * math.pi * 2) + index);
          return Container(
            width: 6,
            height: height.abs(),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: scene.accent.withOpacity(0.82),
            ),
          );
        }),
      );
    }

    return Transform.scale(
      scale: 0.96 + (pulse * 0.06),
      child: Container(
        width: 168,
        height: 168,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withOpacity(0.12)),
          gradient: RadialGradient(
            colors: [
              scene.accent.withOpacity(0.2),
              scene.accent.withOpacity(0.04),
              Colors.transparent,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withOpacity(0.08),
              border: Border.all(color: AppColors.white.withOpacity(0.14)),
            ),
            child: Icon(
              scene.kind == _SceneKind.rain
                  ? Icons.water_drop_outlined
                  : Icons.self_improvement_rounded,
              color: AppColors.white.withOpacity(0.82),
              size: 34,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.progress,
    required this.positionLabel,
    required this.durationLabel,
    required this.onSeek,
  });

  final double progress;
  final String positionLabel;
  final String durationLabel;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final clamped = progress.clamp(0.0, 1.0);
            final knobOffset = (constraints.maxWidth * clamped)
                .clamp(0.0, constraints.maxWidth);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  onSeek(details.localPosition.dx / constraints.maxWidth),
              child: SizedBox(
                height: 10,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: clamped,
                      child: Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.82),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Positioned(
                      left: knobOffset - 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Text(
              positionLabel,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.white.withOpacity(0.58),
              ),
            ),
            const Spacer(),
            Text(
              durationLabel,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.white.withOpacity(0.58),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TransportRow extends StatelessWidget {
  const _TransportRow({
    required this.isPlaying,
    required this.isLoading,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
  });

  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PlayerPaintButton(
          onTap: onPrevious,
          size: const Size(34, 34),
          painter: _SkipBackPainter(
            color: AppColors.white.withOpacity(0.86),
          ),
        ),
        const SizedBox(width: 48),
        if (isLoading)
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 1,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.white.withOpacity(0.72),
              ),
            ),
          )
        else
          _PlayerPaintButton(
            onTap: onPlayPause,
            size: const Size(22, 22),
            painter: isPlaying
                ? _PausePainter(color: AppColors.white.withOpacity(0.92))
                : _PlayPainter(color: AppColors.white.withOpacity(0.92)),
          ),
        const SizedBox(width: 48),
        _PlayerPaintButton(
          onTap: onNext,
          size: const Size(34, 34),
          painter: _SkipForwardPainter(
            color: AppColors.white.withOpacity(0.86),
          ),
        ),
      ],
    );
  }
}
