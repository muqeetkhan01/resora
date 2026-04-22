import 'dart:async';
import 'dart:math' as math;

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

    if (_args.minimal) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            _closePlayer();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.canvas,
          body: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return _MinimalAudioPlayer(
                imagePath: _args.imagePath,
                progress: _progress,
                isPlaying: _isPlaying,
                isLoading: _isLoading,
                errorText: _loadError,
                onBack: _closePlayer,
                onPlayPause: _togglePlayback,
                onSeekBackward: () => _seekRelative(-10),
                onSeekForward: () => _seekRelative(10),
                onSeek: _seekToFraction,
              );
            },
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
                                AppIcons.back,
                                color: AppColors.white,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.favorite_border_rounded,
                              color: AppColors.white.withOpacity(0.84),
                              size: 20,
                            ),
                          ],
                        ),
                        const Spacer(flex: 3),
                        _CenterMotion(
                          scene: scene,
                          pulse: pulse,
                          animationValue: _controller.value,
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
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
                        const Spacer(flex: 4),
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
                          scene: scene,
                          pulse: pulse,
                          isPlaying: _isPlaying,
                          isLoading: _isLoading,
                          onPrevious: () => _seekRelative(-10),
                          onPlayPause: _togglePlayback,
                          onNext: () => _seekRelative(10),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _BottomMeta(icon: Icons.timer_outlined),
                            _BottomMeta(icon: Icons.repeat_rounded),
                            _BottomMeta(icon: Icons.close_rounded),
                          ],
                        ),
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
      return _AudioPlayerArgs(
        track: arguments['track'] as AudioTrack? ?? _fallbackTrack,
        minimal: arguments['minimal'] == true,
        imagePath: arguments['imagePath'] as String? ?? AppAssets.curtainLight,
        ritualFeature: arguments['ritualFeature'] as String?,
      );
    }

    return _AudioPlayerArgs(
      track: arguments as AudioTrack? ?? _fallbackTrack,
      minimal: false,
      imagePath: AppAssets.curtainLight,
      ritualFeature: null,
    );
  }

  static const _fallbackTrack = AudioTrack(
    title: 'Soft rain on leaves',
    category: 'Nature',
    description: 'Steady sound for nervous-system downshift',
    duration: '1 min',
    assetPath: AppAssets.ambientSoftRain,
  );
}

class _MinimalAudioPlayer extends StatelessWidget {
  const _MinimalAudioPlayer({
    required this.imagePath,
    required this.progress,
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
  final double progress;
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
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.canvas.withOpacity(0.14),
                AppColors.canvas.withOpacity(0.68),
                AppColors.canvas.withOpacity(0.94),
                AppColors.canvas,
              ],
              stops: const [0.0, 0.48, 0.72, 0.9, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: onBack,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      AppIcons.back,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const Spacer(),
                _MinimalAudioDock(
                  progress: progress,
                  isPlaying: isPlaying,
                  isLoading: isLoading,
                  errorText: errorText,
                  onPlayPause: onPlayPause,
                  onSeekBackward: onSeekBackward,
                  onSeekForward: onSeekForward,
                  onSeek: onSeek,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MinimalAudioDock extends StatelessWidget {
  const _MinimalAudioDock({
    required this.progress,
    required this.isPlaying,
    required this.isLoading,
    required this.errorText,
    required this.onPlayPause,
    required this.onSeekBackward,
    required this.onSeekForward,
    required this.onSeek,
  });

  final double progress;
  final bool isPlaying;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final width = context.size?.width ?? 1;
            onSeek(details.localPosition.dx / width);
          },
          child: SizedBox(
            height: 18,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: clampedProgress,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: AppColors.terracotta,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(clampedProgress * 2 - 1, 0),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.terracotta,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MinimalControl(
              icon: Icons.replay_10_rounded,
              small: true,
              onTap: onSeekBackward,
            ),
            const SizedBox(width: AppSpacing.xl),
            _MinimalControl(
              icon: isLoading
                  ? Icons.hourglass_empty_rounded
                  : (isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded),
              filled: true,
              onTap: onPlayPause,
            ),
            const SizedBox(width: AppSpacing.xl),
            _MinimalControl(
              icon: Icons.forward_10_rounded,
              small: true,
              onTap: onSeekForward,
            ),
          ],
        ),
      ],
    );
  }
}

class _MinimalControl extends StatelessWidget {
  const _MinimalControl({
    required this.icon,
    this.filled = false,
    this.small = false,
    this.onTap,
  });

  final IconData icon;
  final bool filled;
  final bool small;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = filled ? 74.0 : (small ? 46.0 : 56.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              filled ? AppColors.terracotta : AppColors.white.withOpacity(0.78),
          border: Border.all(
            color: filled ? AppColors.terracotta : AppColors.line,
          ),
        ),
        child: Icon(
          icon,
          color: filled ? AppColors.white : AppColors.primary,
        ),
      ),
    );
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
    required this.scene,
    required this.pulse,
    required this.isPlaying,
    required this.isLoading,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
  });

  final _PlayerScene scene;
  final double pulse;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _PlayerControl(
          icon: Icons.skip_previous_rounded,
          small: true,
          onTap: onPrevious,
        ),
        _PlayerControl(
          icon: isLoading
              ? Icons.hourglass_empty_rounded
              : (isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
          filled: true,
          glowColor: scene.accent.withOpacity(0.24 + (pulse * 0.14)),
          onTap: onPlayPause,
        ),
        _PlayerControl(
          icon: Icons.skip_next_rounded,
          small: true,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _PlayerControl extends StatelessWidget {
  const _PlayerControl({
    required this.icon,
    this.filled = false,
    this.small = false,
    this.glowColor,
    this.onTap,
  });

  final IconData icon;
  final bool filled;
  final bool small;
  final Color? glowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = filled ? 74.0 : (small ? 44.0 : 56.0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              filled ? AppColors.white.withOpacity(0.94) : Colors.transparent,
          border: Border.all(color: AppColors.white.withOpacity(0.18)),
          boxShadow: glowColor == null
              ? null
              : [
                  BoxShadow(
                    color: glowColor!,
                    blurRadius: 26,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Icon(
          icon,
          color: filled ? const Color(0xFF16201F) : AppColors.white,
        ),
      ),
    );
  }
}

class _BottomMeta extends StatelessWidget {
  const _BottomMeta({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white.withOpacity(0.12)),
        color: AppColors.white.withOpacity(0.03),
      ),
      child: Icon(
        icon,
        size: 20,
        color: AppColors.white.withOpacity(0.68),
      ),
    );
  }
}
