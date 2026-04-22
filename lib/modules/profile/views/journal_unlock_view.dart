import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/centered_back_header.dart';
import '../controllers/profile_controller.dart';

class JournalUnlockView extends StatefulWidget {
  const JournalUnlockView({super.key});

  @override
  State<JournalUnlockView> createState() => _JournalUnlockViewState();
}

class _JournalUnlockViewState extends State<JournalUnlockView> {
  final controller = Get.find<ProfileController>();
  final _digits = <String>[];
  String _error = '';

  void _onKey(String key) {
    if (_digits.length >= 4) {
      return;
    }

    setState(() {
      _digits.add(key);
      _error = '';
    });

    if (_digits.length == 4) {
      Future<void>.delayed(const Duration(milliseconds: 160), () {
        if (!mounted) return;
        final pin = _digits.join();
        if (controller.verifyJournalPin(pin)) {
          controller.markJournalUnlocked();
          Get.back(result: true);
          return;
        }

        setState(() {
          _error = 'Incorrect PIN. Try again.';
          _digits.clear();
        });
      });
    }
  }

  void _deleteDigit() {
    if (_digits.isEmpty) {
      return;
    }

    setState(() {
      _digits.removeLast();
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              const CenteredBackHeader(title: 'unlock journal'),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Enter your 4-digit PIN',
                style: textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your journal stays private.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _error,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.terracotta,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      color: _digits.length > index
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: const [
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                  '6',
                  '7',
                  '8',
                  '9',
                  '',
                  '0',
                  'del',
                ].map((key) {
                  if (key.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _PinKey(digit: key);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({required this.digit});

  final String digit;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_JournalUnlockViewState>();
    final isDelete = digit == 'del';

    return InkWell(
      onTap: () {
        if (state == null) return;
        if (isDelete) {
          state._deleteDigit();
        } else {
          state._onKey(digit);
        }
      },
      child: Center(
        child: Text(
          isDelete ? '⌫' : digit,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: isDelete ? 20 : 28,
                color: isDelete ? AppColors.terracotta : AppColors.primary,
              ),
        ),
      ),
    );
  }
}
