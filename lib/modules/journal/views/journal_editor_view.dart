import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/controllers/app_session_controller.dart';
import '../../../core/services/user_generated_content_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_snackbar.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';

class JournalEditorView extends StatefulWidget {
  const JournalEditorView({super.key});

  @override
  State<JournalEditorView> createState() => _JournalEditorViewState();
}

class _JournalEditorViewState extends State<JournalEditorView> {
  late final TextEditingController _controller;
  late final String _prompt;
  final _userGeneratedContentService = UserGeneratedContentService();
  late final AppSessionController _session;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _session = Get.find<AppSessionController>();
    final argument = Get.arguments;

    if (argument is JournalEntry) {
      _prompt = argument.prompt ?? 'What helped more than you expected today?';
      _controller = TextEditingController(text: argument.preview);
    } else if (argument is String) {
      _prompt = argument.trim();
      _controller = TextEditingController();
    } else {
      _prompt = 'What helped more than you expected today?';
      _controller = TextEditingController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.82, -0.9),
                  radius: 1.2,
                  colors: [
                    Color(0x44F5EEDE),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(child: _PaperTextureLayer()),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: Get.back,
                        icon:
                            const Icon(AppIcons.back, color: AppColors.primary),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isSaving ? null : _onDonePressed,
                        child: Text(
                          _isSaving ? 'saving...' : 'done',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_prompt.isNotEmpty) ...[
                    Text(
                      _prompt,
                      style: textTheme.displayMedium?.copyWith(
                        color: AppColors.primary.withOpacity(0.45),
                        fontSize: 34,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Container(
                    height: 0.8,
                    color: AppColors.primary.withOpacity(0.12),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      maxLines: null,
                      expands: true,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.warmDark,
                        fontSize: 20,
                        height: 1.8,
                      ),
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: 'start here',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onDonePressed() async {
    if (_isSaving) {
      return;
    }

    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final uid = _session.firebaseUser?.uid;
      if (uid == null) {
        showAppSnackbar(
          'Sign in required',
          'Please sign in to save this journal entry.',
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        await _userGeneratedContentService.saveJournalEntry(
          uid: uid,
          prompt: _prompt,
          body: text,
        );
      } catch (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isSaving = false;
        });
        showAppSnackbar(
          'Could not save journal',
          'Your journal entry could not be saved right now. Please try again.',
        );
        return;
      }
    }

    if (!mounted) {
      return;
    }

    Get.offNamed(
      AppRoutes.ritualWrap,
      arguments: RitualWrapArgs.exit(
        feature: RitualWrapFeature.journal,
      ).toMap(),
    );
  }
}

class _PaperTextureLayer extends StatelessWidget {
  const _PaperTextureLayer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PaperTexturePainter(),
    );
  }
}

class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grainPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF0F4438).withOpacity(0.035);

    final softPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFB89470).withOpacity(0.028);

    const step = 7.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        final noise = math.sin((x * 0.37) + (y * 0.53));
        if (noise > 0.7) {
          canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), grainPaint);
        } else if (noise < -0.72) {
          canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), softPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
